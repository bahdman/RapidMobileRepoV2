import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rapid_app/core/services/api_service.dart';
import 'package:rapid_app/core/config/api_config.dart';
import 'package:rapid_app/core/utils/snackbar_utils.dart';

// Events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {}

class MarkAllAsRead extends NotificationEvent {}

class MarkSingleAsRead extends NotificationEvent {
  final String id;
  const MarkSingleAsRead(this.id);
  @override
  List<Object?> get props => [id];
}

class DeleteNotification extends NotificationEvent {
  final String id;
  const DeleteNotification(this.id);
  @override
  List<Object?> get props => [id];
}

class BroadcastNotification extends NotificationEvent {
  final String category;
  final String title;
  final String body;
  final String entityType;
  final String entityId;
  final int channel;
  final Map<String, String>? pushData;

  const BroadcastNotification({
    required this.category,
    required this.title,
    required this.body,
    required this.entityType,
    required this.entityId,
    required this.channel,
    this.pushData,
  });

  @override
  List<Object?> get props => [category, title, body, entityType, entityId, channel, pushData];
}

// States
abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationItem> notifications;
  const NotificationLoaded(this.notifications);
  @override
  List<Object?> get props => [notifications];
}

class NotificationItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final String time;
  final bool isRead;
  final NotificationType type;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    this.isRead = false,
    required this.type,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? description,
    String? time,
    bool? isRead,
    NotificationType? type,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['body'] as String? ?? '',
      time: json['createdAt'] != null ? _formatTime(json['createdAt'] as String) : '',
      isRead: json['isRead'] as bool? ?? false,
      type: _parseType(json['category'] as String?),
    );
  }

  static String _formatTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (_) {
      return '';
    }
  }

  static NotificationType _parseType(String? category) {
    if (category == null) return NotificationType.info;
    switch (category.toLowerCase()) {
      case 'critical':
      case 'danger':
      case 'error':
        return NotificationType.critical;
      case 'settings':
      case 'config':
        return NotificationType.settings;
      case 'success':
      case 'completed':
        return NotificationType.success;
      case 'info':
      default:
        return NotificationType.info;
    }
  }

  @override
  List<Object?> get props => [id, title, description, time, isRead, type];
}

enum NotificationType { critical, settings, info, success }

// Bloc
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final ApiService _apiService;

  NotificationBloc(this._apiService) : super(NotificationInitial()) {
    on<LoadNotifications>((event, emit) async {
      emit(NotificationLoading());
      try {
        final response = await _apiService.get(
          ApiConfig.getNotifications,
          queryParameters: {
            'unreadOnly': false,
            'skip': 0,
            'take': 50,
          },
        );
        final dataMap = response.data as Map<String, dynamic>;
        if (dataMap['isSuccess'] == true) {
          final list = dataMap['data'] as List<dynamic>? ?? [];
          final notifications = list
              .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
              .toList();
          emit(NotificationLoaded(notifications));
        } else {
          showGlobalSnackBar(dataMap['message'] as String? ?? 'Failed to load notifications', isError: true);
          emit(const NotificationLoaded([]));
        }
      } catch (e) {
        showGlobalSnackBar('Failed to load notifications', isError: true);
        emit(const NotificationLoaded([]));
      }
    });

    on<MarkAllAsRead>((event, emit) async {
      if (state is NotificationLoaded) {
        final current = (state as NotificationLoaded).notifications;
        final hasUnread = current.any((n) => !n.isRead);
        if (!hasUnread) {
          showGlobalSnackBar('No unread notifications to mark as read');
          return;
        }

        try {
          final response = await _apiService.post(
            ApiConfig.markAllAsRead,
          );
          final dataMap = response.data as Map<String, dynamic>;
          if (dataMap['isSuccess'] == true) {
            final updated = current.map((e) => e.copyWith(isRead: true)).toList();
            emit(NotificationLoaded(updated));
            showGlobalSnackBar('All notifications marked as read');
          } else {
            showGlobalSnackBar(dataMap['message'] as String? ?? 'Failed to mark all as read', isError: true);
          }
        } catch (e) {
          showGlobalSnackBar('Failed to mark all notifications as read', isError: true);
        }
      } else {
        showGlobalSnackBar('No notifications available');
      }
    });

    on<MarkSingleAsRead>((event, emit) async {
      if (state is NotificationLoaded) {
        final current = (state as NotificationLoaded).notifications;
        final index = current.indexWhere((n) => n.id == event.id);
        if (index == -1) return;
        if (current[index].isRead) return;

        try {
          final response = await _apiService.post(
            ApiConfig.markAsRead,
            data: {
              'ids': [event.id],
            },
          );
          final dataMap = response.data as Map<String, dynamic>;
          if (dataMap['isSuccess'] == true) {
            final updated = current.map((e) {
              if (e.id == event.id) {
                return e.copyWith(isRead: true);
              }
              return e;
            }).toList();
            emit(NotificationLoaded(updated));
          } else {
            showGlobalSnackBar(dataMap['message'] as String? ?? 'Failed to mark notification as read', isError: true);
          }
        } catch (e) {
          showGlobalSnackBar('Failed to mark notification as read', isError: true);
        }
      }
    });

    on<DeleteNotification>((event, emit) async {
      if (state is NotificationLoaded) {
        final current = (state as NotificationLoaded).notifications;

        try {
          final response = await _apiService.delete(
            ApiConfig.deleteNotification(event.id),
          );
          final dataMap = response.data as Map<String, dynamic>;
          if (dataMap['isSuccess'] == true) {
            final updated = current.where((e) => e.id != event.id).toList();
            emit(NotificationLoaded(updated));
            showGlobalSnackBar('Notification deleted successfully!');
          } else {
            showGlobalSnackBar(dataMap['message'] as String? ?? 'Failed to delete notification', isError: true);
          }
        } catch (e) {
          showGlobalSnackBar('Failed to delete notification', isError: true);
        }
      }
    });

    on<BroadcastNotification>((event, emit) async {
      try {
        final response = await _apiService.post(
          ApiConfig.broadcastNotification,
          data: {
            'category': event.category,
            'title': event.title,
            'body': event.body,
            'entityType': event.entityType,
            'entityId': event.entityId,
            'channel': event.channel,
            if (event.pushData != null) 'pushData': event.pushData,
          },
        );
        final dataMap = response.data as Map<String, dynamic>;
        if (dataMap['isSuccess'] == true) {
          showGlobalSnackBar('Notification broadcasted successfully!');
          add(LoadNotifications());
        } else {
          showGlobalSnackBar(dataMap['message'] as String? ?? 'Failed to broadcast notification', isError: true);
        }
      } catch (e) {
        showGlobalSnackBar('Failed to broadcast notification', isError: true);
      }
    });
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get(ApiConfig.getUnreadCount);
      final dataMap = response.data as Map<String, dynamic>;
      if (dataMap['isSuccess'] == true) {
        return dataMap['data'] as int? ?? 0;
      }
    } catch (_) {}
    return 0;
  }
}

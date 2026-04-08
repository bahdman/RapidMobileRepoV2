import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rapid_app/core/services/api_service.dart';

// Events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {}

class MarkAsRead extends NotificationEvent {}

class DeleteNotification extends NotificationEvent {
  final String id;
  const DeleteNotification(this.id);
  @override
  List<Object?> get props => [id];
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
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      emit(
        const NotificationLoaded([
          NotificationItem(
            id: '1',
            title: 'Critical Code Detected',
            description:
                'U0201 — ECM/PCM communication issue found during your morning scan.',
            time: '2:34 PM',
            type: NotificationType.critical,
          ),
          NotificationItem(
            id: '2',
            title: 'Oil Change Due',
            description:
                'Your scheduled oil change is tomorrow at 9:00 AM. Don\'t forget!',
            time: '1 hr ago',
            type: NotificationType.settings,
          ),
          NotificationItem(
            id: '3',
            title: 'Scan Complete',
            description:
                'Your scan completed successfully. No new issues found.',
            time: '3 hr ago',
            type: NotificationType.success,
            isRead: true,
          ),
          NotificationItem(
            id: '4',
            title: 'Brake Inspection Reminder',
            description:
                'It\'s been 6 months since your last brake inspection. Schedule one soon.',
            time: '3 hr ago',
            type: NotificationType.info,
            isRead: true,
          ),
          NotificationItem(
            id: '5',
            title: 'Subscription Renewal',
            description: 'Your Pro plan has been renewed for another month.',
            time: '2 days ago',
            type: NotificationType.info,
            isRead: true,
          ),
        ]),
      );
    });

    on<MarkAsRead>((event, emit) {
      if (state is NotificationLoaded) {
        final current = (state as NotificationLoaded).notifications;
        final updated = current
            .map(
              (e) => NotificationItem(
                id: e.id,
                title: e.title,
                description: e.description,
                time: e.time,
                type: e.type,
                isRead: true,
              ),
            )
            .toList();
        emit(NotificationLoaded(updated));
      }
    });

    on<DeleteNotification>((event, emit) {
      if (state is NotificationLoaded) {
        final current = (state as NotificationLoaded).notifications;
        final updated = current.where((e) => e.id != event.id).toList();
        emit(NotificationLoaded(updated));
      }
    });
  }
}

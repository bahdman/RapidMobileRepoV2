import 'package:flutter/foundation.dart';
import 'package:rapid_app/core/config/api_config.dart';
import 'package:rapid_app/core/services/api_service.dart';

class ScheduleEntry {
  final String id;
  final int day;
  final String time;

  ScheduleEntry({
    required this.id,
    required this.day,
    required this.time,
  });

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      id: json['id'] as String? ?? '',
      day: json['day'] as int? ?? 0,
      time: json['time'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'time': time,
    };
  }
}

class ScheduleModel {
  final String id;
  final String name;
  final String note;
  final String createdAt;
  final String updatedAt;
  final List<ScheduleEntry> entries;

  ScheduleModel({
    required this.id,
    required this.name,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.entries,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    final entriesList = json['entries'] as List? ?? [];
    return ScheduleModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      note: json['note'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      entries: entriesList
          .map((e) => ScheduleEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ScheduleService {
  final ApiService _apiService;

  ScheduleService(this._apiService);

  /// Creates a new schedule.
  Future<ScheduleModel?> createSchedule({
    required String name,
    required String note,
    required List<ScheduleEntry> entries,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.createSchedule,
        data: {
          'name': name,
          'note': note,
          'entries': entries.map((e) => e.toJson()).toList(),
        },
      );
      final data = response.data;
      if (data == null) return null;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          return ScheduleModel.fromJson(data['data'] as Map<String, dynamic>);
        }
        return ScheduleModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating schedule: $e');
      rethrow;
    }
  }

  /// Gets all schedules.
  Future<List<ScheduleModel>> getAllSchedules() async {
    try {
      final response = await _apiService.get(ApiConfig.getAllSchedules);
      final data = response.data;
      if (data == null) return [];

      List<dynamic> listData = [];
      if (data is Map<String, dynamic> && data['data'] is List) {
        listData = data['data'] as List;
      } else if (data is List) {
        listData = data;
      }

      return listData
          .map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting all schedules: $e');
      rethrow;
    }
  }

  /// Gets a single schedule by id.
  Future<ScheduleModel?> getSchedule(String id) async {
    try {
      final response = await _apiService.get(ApiConfig.getSchedule(id));
      final data = response.data;
      if (data == null) return null;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          return ScheduleModel.fromJson(data['data'] as Map<String, dynamic>);
        }
        return ScheduleModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting schedule: $e');
      rethrow;
    }
  }

  /// Updates a schedule by id.
  Future<ScheduleModel?> updateSchedule(
    String id, {
    required String name,
    required String note,
    required List<ScheduleEntry> entries,
  }) async {
    try {
      final response = await _apiService.put(
        ApiConfig.updateSchedule(id),
        data: {
          'name': name,
          'note': note,
          'entries': entries.map((e) => e.toJson()).toList(),
        },
      );
      final data = response.data;
      if (data == null) return null;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          return ScheduleModel.fromJson(data['data'] as Map<String, dynamic>);
        }
        return ScheduleModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating schedule: $e');
      rethrow;
    }
  }

  /// Deletes schedules by a list of ids.
  Future<bool> deleteSchedules(List<String> ids) async {
    try {
      final response = await _apiService.delete(
        ApiConfig.deleteSchedules,
        data: {
          'ids': ids,
        },
      );
      final data = response.data;
      if (data == null) return false;

      if (data is Map<String, dynamic>) {
        return data['isSuccess'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting schedules: $e');
      return false;
    }
  }
}

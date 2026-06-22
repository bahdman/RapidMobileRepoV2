import 'package:flutter/foundation.dart';
import 'package:rapid_app/core/config/api_config.dart';
import 'package:rapid_app/core/services/api_service.dart';

class DeviceService {
  final ApiService _apiService;

  DeviceService(this._apiService);

  /// Registers a push notification token with the backend.
  /// [platform] is typically 1 for iOS, 2 for Android.
  Future<bool> registerPushToken({
    required String deviceToken,
    required int platform,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.registerPushToken,
        data: {
          'deviceToken': deviceToken,
          'platform': platform,
        },
      );

      final data = response.data;
      if (data == null) return false;

      if (data is Map<String, dynamic>) {
        return data['isSuccess'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error registering push token: $e');
      return false;
    }
  }

  /// Deactivates a push notification token on the backend.
  Future<bool> deactivatePushToken({
    required String deviceToken,
  }) async {
    try {
      final response = await _apiService.delete(
        ApiConfig.deactivatePushToken,
        data: {
          'deviceToken': deviceToken,
        },
      );

      final data = response.data;
      if (data == null) return false;

      if (data is Map<String, dynamic>) {
        return data['isSuccess'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error deactivating push token: $e');
      return false;
    }
  }
}

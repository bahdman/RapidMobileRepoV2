import 'package:flutter/foundation.dart';
import 'package:rapid_app/core/config/api_config.dart';
import 'package:rapid_app/core/services/api_service.dart';
import 'package:rapid_app/core/services/cache_service.dart';

class UserProfile {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String createdAt;
  final String? avatar;

  UserProfile({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.createdAt,
    this.avatar,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      avatar: json['avatar'] as String?,
    );
  }
}

class UserService {
  final ApiService _apiService;

  UserService(this._apiService);

  /// Clears all HTTP request caches (memory and persistent).
  Future<void> clearCache() async {
    await _apiService.clearAllCache();
  }

  /// Fetches the user profile.
  Future<UserProfile?> getUserProfile({bool refresh = false}) async {
    try {
      final response = await _apiService.get(
        ApiConfig.userProfile,
        options: CacheOptions.build(
          cache: true,
          policy: CachePolicy.persistent,
          duration: const Duration(days: 7),
          refresh: refresh,
        ),
      );
      final data = response.data;
      if (data == null) return null;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          return UserProfile.fromJson(data['data'] as Map<String, dynamic>);
        }
        return UserProfile.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      rethrow;
    }
  }

  /// Updates the user profile.
  Future<UserProfile?> updateUserProfile({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      final response = await _apiService.put(
        ApiConfig.updateUserProfile,
        data: {
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
        },
      );
      
      // Invalidate user profile cache on successful update
      await _apiService.invalidateCache(ApiConfig.userProfile);

      final data = response.data;
      if (data == null) return null;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          return UserProfile.fromJson(data['data'] as Map<String, dynamic>);
        }
        return UserProfile.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }
}

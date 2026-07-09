import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'device_service.dart';

/// Top-level background message handler for FCM.
/// Must be annotated with @pragma('vm:entry-point') to prevent tree shaking.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[PushNotificationService] Background message received: ${message.messageId}');
}

class PushNotificationService {
  final DeviceService _deviceService;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  PushNotificationService(this._deviceService);

  /// Initializes permissions and sets up callbacks for foreground & interaction events.
  Future<void> initialize() async {
    try {
      // 1. Request permissions (iOS and Android 13+ prompt)
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('[PushNotificationService] Notification permission granted.');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('[PushNotificationService] Notification permission provisionally granted.');
      } else {
        debugPrint('[PushNotificationService] Notification permission denied.');
      }

      // 2. Set presentation options for when the app is in the foreground
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Listen to foreground incoming messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[PushNotificationService] Foreground message received: ${message.notification?.title}');
        // You can use a local notification service here to show a custom banner if needed.
      });

      // 4. Handle clicks/interactions when app is opened via a notification click
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[PushNotificationService] User opened app via notification click: ${message.data}');
      });

      // 5. Handle initial message (if the app was completely terminated and opened by notification click)
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[PushNotificationService] App launched from terminated state via notification click: ${initialMessage.data}');
      }
    } catch (e) {
      debugPrint('[PushNotificationService] Initialization error: $e');
    }
  }

  /// Fetches FCM token and registers it with the backend database.
  Future<void> registerDevice() async {
    try {
      final token = await _fcm.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('[PushNotificationService] FCM token is null or empty.');
        return;
      }

      debugPrint('[PushNotificationService] Registering device token: $token');
      final platform = Platform.isAndroid ? 2 : 1; // 2 for Android, 1 for iOS
      final success = await _deviceService.registerPushToken(
        deviceToken: token,
        platform: platform,
      );

      if (success) {
        debugPrint('[PushNotificationService] Device token registered successfully with backend.');
      } else {
        debugPrint('[PushNotificationService] Backend failed to register device token.');
      }
    } catch (e) {
      debugPrint('[PushNotificationService] Error registering device token: $e');
    }
  }

  /// Deactivates device token on the backend (usually called upon logout).
  Future<void> deactivateDevice() async {
    try {
      final token = await _fcm.getToken();
      if (token == null || token.isEmpty) return;

      debugPrint('[PushNotificationService] Deactivating device token on logout.');
      final success = await _deviceService.deactivatePushToken(
        deviceToken: token,
      );

      if (success) {
        debugPrint('[PushNotificationService] Device token deactivated successfully on backend.');
      } else {
        debugPrint('[PushNotificationService] Backend failed to deactivate device token.');
      }

      // Clear token to prevent stale registrations
      await _fcm.deleteToken();
    } catch (e) {
      debugPrint('[PushNotificationService] Error deactivating device token: $e');
    }
  }
}

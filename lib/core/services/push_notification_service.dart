import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'device_service.dart';
import 'package:rapid_app/core/utils/shared_prefs_helper.dart';

/// Top-level background message handler for FCM.
/// Must be annotated with @pragma('vm:entry-point') to prevent tree shaking.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[PushNotificationService] Background message received: ${message.messageId}');
}

/// Android notification channel details.
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'rapid_high_importance_channel',
  'Rapid Notifications',
  description: 'Important notifications from Rapid.',
  importance: Importance.high,
  playSound: true,
);

class PushNotificationService {
  final DeviceService _deviceService;
  final SharedPrefsHelper _prefsHelper;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Broadcast stream for in-app notification banners
  final StreamController<RemoteMessage> _foregroundMessageController =
      StreamController<RemoteMessage>.broadcast();

  Stream<RemoteMessage> get foregroundMessageStream =>
      _foregroundMessageController.stream;

  PushNotificationService(this._deviceService, this._prefsHelper);

  /// Initializes permissions, local notifications plugin, and FCM listeners.
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
        await _prefsHelper.setNotificationsEnabled(false);
      }

      // 2. Set presentation options for when the app is in the foreground
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: false, // We handle this ourselves with local notifications
        badge: true,
        sound: true,
      );

      // 3. Initialize flutter_local_notifications
      await _initLocalNotifications();

      // 4. Listen to foreground incoming messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[PushNotificationService] Foreground message: ${message.notification?.title}');

        // Show a local (system) notification since FCM suppresses foreground notifications
        _showLocalNotification(message);

        // Emit to in-app banner stream
        _foregroundMessageController.add(message);
      });

      // 5. Handle clicks/interactions when app is opened via a notification click
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[PushNotificationService] App opened via notification: ${message.data}');
        // Emit so the overlay can handle navigation if needed
        _foregroundMessageController.add(message);
      });

      // 6. Handle initial message (app terminated, opened via notification click)
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[PushNotificationService] Launched from terminated state: ${initialMessage.data}');
      }
    } catch (e) {
      debugPrint('[PushNotificationService] Initialization error: $e');
    }
  }

  /// Sets up FlutterLocalNotificationsPlugin for Android + iOS.
  Future<void> _initLocalNotifications() async {
    const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await _localNotifications.initialize(initSettings);

    // Create Android channel (no-op on other platforms)
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);
  }

  /// Displays a notification in the system notification centre.
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'rapid_high_importance_channel',
      'Rapid Notifications',
      channelDescription: 'Important notifications from Rapid.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
    );
  }

  /// Fetches FCM token and registers it with the backend database.
  Future<void> registerDevice() async {
    try {
      // 1. Request/Verify permissions
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final isGranted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      if (!isGranted) {
        debugPrint('[PushNotificationService] Notification permission not granted. Skipping device registration.');
        await _prefsHelper.setNotificationsEnabled(false);
        return;
      }

      if (Platform.isIOS) {
        String? apnsToken;
        for (int i = 0; i < 5; i++) {
          apnsToken = await _fcm.getAPNSToken();
          if (apnsToken != null) break;
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
        if (apnsToken == null) {
          debugPrint('[PushNotificationService] APNS token not set (Simulator or missing capability).');
          return;
        }
      }

      // Log the Firebase Options used to fetch the device token
      final options = _fcm.app.options;
      debugPrint('[PushNotificationService] Fetching FCM token with options: '
          'Project ID: ${options.projectId}, '
          'Sender ID (Project Number): ${options.messagingSenderId}, '
          'API Key: ${options.apiKey}, '
          'App ID: ${options.appId}');

      final token = await _fcm.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('[PushNotificationService] FCM token is null or empty.');
        return;
      }

      debugPrint('[PushNotificationService] Registering device token: $token');
      final platform = Platform.isAndroid ? 2 : 1;
      final success = await _deviceService.registerPushToken(
        deviceToken: token,
        platform: platform,
      );

      if (success) {
        debugPrint('[PushNotificationService] Device token registered successfully.');
        await _prefsHelper.setNotificationsEnabled(true);
      } else {
        debugPrint('[PushNotificationService] Backend failed to register device token.');
      }
    } catch (e) {
      debugPrint('[PushNotificationService] Error registering device token: $e');
    }
  }

  /// Deactivates device token on the backend (called on logout or push toggle off).
  Future<void> deactivateDevice() async {
    try {
      if (Platform.isIOS) {
        final apnsToken = await _fcm.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('[PushNotificationService] APNS token not set, skipping deactivation.');
          return;
        }
      }

      final token = await _fcm.getToken();
      if (token == null || token.isEmpty) return;

      debugPrint('[PushNotificationService] Deactivating device token.');
      final success = await _deviceService.deactivatePushToken(deviceToken: token);

      if (success) {
        debugPrint('[PushNotificationService] Device token deactivated successfully.');
      } else {
        debugPrint('[PushNotificationService] Backend failed to deactivate device token.');
      }

      await _fcm.deleteToken();
    } catch (e) {
      debugPrint('[PushNotificationService] Error deactivating device token: $e');
    }
  }

  void dispose() {
    _foregroundMessageController.close();
  }
}

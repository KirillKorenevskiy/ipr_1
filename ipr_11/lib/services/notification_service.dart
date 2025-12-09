import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ipr_11/main.dart';
import 'package:ipr_11/utils/firebase_options.dart';

import '../utils/app_constants.dart';
import '../utils/app_logger.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  AppLogger.info('notificationTapBackground: ${notificationResponse.payload}');
  if (notificationResponse.payload != null) {
    handleNotificationNavigation();
  }
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotification() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await _firebaseMessaging.requestPermission();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      AppConstants.highImportanceChannelId,
      AppConstants.highImportanceChannelName,
      description: AppConstants.notificationChannelDescription,
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings(AppConstants.notificationIcon),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        AppLogger.info('onDidReceiveNotificationResponse: ${notificationResponse.payload}');
        handleNotificationNavigation();
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      AppLogger.info('Got a message whilst in the foreground!');
      AppLogger.info('Message data: ${message.data}');

      final RemoteNotification? notification = message.notification;
      if (notification != null) {
        AppLogger.info('Message also contained a notification: $notification');

        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: AppConstants.notificationIcon,
            ),
          ),
          payload: AppConstants.remoteNotificationTappedPayload,
        );
      }
      final FlutterBackgroundService service = FlutterBackgroundService();

      service.invoke(AppConstants.startWebSocketEvent);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info('onMessageOpenedApp: ${message.data}');
      handleNotificationNavigation();
    });

    await _getFcmToken();
  }

  static Future<void> _getFcmToken() async {
    final String? token = await _firebaseMessaging.getToken();

    AppLogger.info('FCM token: $token');
  }

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    final FlutterBackgroundService service = FlutterBackgroundService();

    service.invoke(AppConstants.startWebSocketEvent);

    AppLogger.info('Handled a background message: ${message.messageId}');
  }
}

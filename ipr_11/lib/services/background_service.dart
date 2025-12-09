import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ipr_11/utils/app_constants.dart';

import '../utils/app_logger.dart';
import 'websocket_service.dart';

class BackgroundService {
  Future<void> initializeService() async {
    final FlutterBackgroundService service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      AppConstants.notificationChannelId,
      AppConstants.foregroundServiceTitle,
      description: AppConstants.notificationChannelDescription,
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: AppConstants.notificationChannelId,
        initialNotificationTitle: AppConstants.awesomeServiceNotificationTitle,
        initialNotificationContent: AppConstants.awesomeServiceNotificationContent,
        foregroundServiceNotificationId: AppConstants.notificationId,
      ),
      iosConfiguration: IosConfiguration(autoStart: true, onForeground: onStart, onBackground: onIosBackground),
    );
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  AppLogger.info('Background service onStart executed.');

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final WebSocketService webSocketService = WebSocketService(
    service,
    flutterLocalNotificationsPlugin,
    AppConstants.notificationChannelId,
    AppConstants.notificationId,
  );

  AppLogger.info('Registering start_web_socket listener.');

  service.on(AppConstants.startWebSocketEvent).listen((event) {
    AppLogger.info('start_web_socket event received');
    webSocketService.disconnect();
    webSocketService.connect();
  });

  AppLogger.info('Registering stop_web_socket listener.');

  service.on(AppConstants.stopWebSocketEvent).listen((event) {
    AppLogger.info('stop_web_socket event received');

    webSocketService.disconnect();
  });

  AppLogger.info('Registering get_cache listener.');
  service.on(AppConstants.getCacheEvent).listen((event) {
    AppLogger.info('get_cache event received');

    service.invoke(AppConstants.cacheResponseEvent, {AppConstants.messagesKey: webSocketService.messagesCache});
  });

  Timer.periodic(AppConstants.oneSecondDuration, (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        if (!webSocketService.isConnected) {
          flutterLocalNotificationsPlugin.show(
            AppConstants.notificationId,
            AppConstants.serviceRunningNotificationTitle,
            '${AppConstants.serviceRunningNotificationContent}${DateTime.now()}',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                AppConstants.notificationChannelId,
                AppConstants.foregroundServiceTitle,
                icon: AppConstants.notificationIcon,
                ongoing: true,
              ),
            ),
          );
        }
      }
    }
  });
}

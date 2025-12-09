class AppConstants {
  static const String webSocketUrl = 'wss://echo.websocket.org';
  static const String startWebSocketEvent = 'start_web_socket';
  static const String stopWebSocketEvent = 'stop_web_socket';
  static const String getCacheEvent = 'get_cache';
  static const String cacheResponseEvent = 'cache_response';
  static const String updateEvent = 'update';

  static const Duration oneSecondDuration = Duration(seconds: 1);
  static const Duration fiveSecondDuration = Duration(seconds: 5);

  static const String notificationChannelId = 'my_foreground';
  static const int notificationId = 888;
  static const String foregroundServiceTitle = 'MY FOREGROUND SERVICE';
  static const String notificationChannelDescription = 'This channel is used for important notifications.';
  static const String awesomeServiceNotificationTitle = 'AWESOME SERVICE';
  static const String awesomeServiceNotificationContent = 'Initializing';
  static const String serviceRunningNotificationTitle = 'SERVICE RUNNING';
  static const String serviceRunningNotificationContent = 'Waiting for FCM to trigger WebSocket... ';
  static const String notificationIcon = '@mipmap/ic_launcher';
  static const String highImportanceChannelId = 'high_importance_channel';
  static const String highImportanceChannelName = 'High Importance Notifications';
  static const String remoteNotificationTappedPayload = 'remote_notification_tapped';
  static const String webSocketActiveNotificationTitle = 'WebSocket Active';
  static const String webSocketActiveNotificationContentPrefix = 'Received: ';

  static const String messagesKey = 'messages';
  static const String messageKey = 'message';
}

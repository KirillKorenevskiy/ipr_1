import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../utils/app_constants.dart';
import '../utils/app_logger.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _webSocketPingTimer;
  int _counter = 0;
  bool _isConnected = false;
  final List<String> _messagesCache = [];
  final ServiceInstance _service;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final String _notificationChannelId;
  final int _notificationId;

  WebSocketService(
    this._service,
    this._flutterLocalNotificationsPlugin,
    this._notificationChannelId,
    this._notificationId,
  );

  void connect() {
    AppLogger.info('[WebSocketService] connect: _isConnected: $_isConnected');

    if (_isConnected) return;

    try {
      AppLogger.info('[WebSocketService] Connecting to WebSocket...');

      final wsUrl = Uri.parse(AppConstants.webSocketUrl);
      _channel = WebSocketChannel.connect(wsUrl);
      _isConnected = true;

      AppLogger.info('[WebSocketService] WebSocket connected.');

      _webSocketPingTimer?.cancel();
      _webSocketPingTimer = Timer.periodic(AppConstants.oneSecondDuration, (timer) {
        _counter++;
        if (_channel != null) {
          _channel!.sink.add('$_counter');
        }
      });

      _subscription = _channel!.stream.listen(
        (message) {
          AppLogger.info('[WebSocketService] WebSocket message: $message');

          _messagesCache.add(message);

          _service.invoke(AppConstants.updateEvent, {AppConstants.messageKey: message});

          if (_service is AndroidServiceInstance) {
            (_service).isForegroundService().then((isForeground) {
              if (isForeground) {
                _flutterLocalNotificationsPlugin.show(
                  _notificationId,
                  AppConstants.webSocketActiveNotificationTitle,
                  '${AppConstants.webSocketActiveNotificationContentPrefix}$message',
                  NotificationDetails(
                    android: AndroidNotificationDetails(
                      _notificationChannelId,
                      AppConstants.foregroundServiceTitle,
                      icon: '@mipmap/ic_launcher',
                      ongoing: true,
                    ),
                  ),
                );
              }
            });
          }
        },
        onDone: () {
          AppLogger.warning('[WebSocketService] WebSocket connection closed. Reconnecting in 5 seconds...');
          _handleWebSocketDisconnection();
        },
        onError: (error) {
          AppLogger.error('[WebSocketService] WebSocket error: $error. Reconnecting in 5 seconds...');
          _handleWebSocketDisconnection();
        },
      );
    } catch (e) {
      AppLogger.error('[WebSocketService] WebSocket connection failed: $e. Retrying in 5 seconds...');

      _isConnected = false;
      Future.delayed(AppConstants.fiveSecondDuration, connect);
    }
  }

  void _handleWebSocketDisconnection() {
    _isConnected = false;
    _subscription?.cancel();
    _webSocketPingTimer?.cancel();
    Future.delayed(AppConstants.fiveSecondDuration, connect);
  }

  void disconnect() {
    AppLogger.info('[WebSocketService] Disconnecting WebSocket.');

    _isConnected = false;
    _subscription?.cancel();
    _webSocketPingTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  List<String> get messagesCache => _messagesCache;
  bool get isConnected => _isConnected;
}

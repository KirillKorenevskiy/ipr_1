import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:ipr_11/screens/details_screen.dart';
import 'package:ipr_11/services/background_service.dart';
import 'package:ipr_11/services/notification_service.dart';

import 'screens/home_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await BackgroundService().initializeService();

  await NotificationService.initializeNotification();

  runApp(const MyApp());
}

void handleNotificationNavigation() async {
  final FlutterBackgroundService service = FlutterBackgroundService();

  service.invoke('get_cache');

  await for (var event in service.on('cache_response')) {
    final List<String> messages = List<String>.from(event!['messages'] ?? []);
    navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => DetailsScreen(messages: messages)));

    break;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,

      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
      routes: {'/secondScreen': (context) => DetailsScreen(messages: const [])},
    );
  }
}

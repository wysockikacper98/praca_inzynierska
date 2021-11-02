import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../helpers/colorfull_print_messages.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings('mipmap/ic_launcher'),
    );

    _notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? data) async {
      if (data != null) {
        //TODO: Do something onTap
        printColor(text: data.toString(), color: PrintColor.blue);
      }
    });
  }

  static void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          '4eda5bda-3bd6-11ec-8d3d-0242ac130003',
          'main channel',
          channelDescription: 'This is our channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
      );

      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data['data'],
      );
    } catch (e) {
      print(e);
    }
  }
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationUtil {
  static Future initialize(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async {
    var androidInit = const AndroidInitializationSettings("mipmap/ic_launcher");
    var iosInit = const DarwinInitializationSettings();
    var initSetting = InitializationSettings(android: androidInit, iOS: iosInit);
    await flutterLocalNotificationsPlugin.initialize(
      initSetting,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  static Future showBigTextNotification({
    var id = 0,
    var payload,
    required String title,
    required String body,
    required FlutterLocalNotificationsPlugin fl,
  }) async {
    AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
      "test_channel",
      "channelName",
      playSound: true,
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      enableLights: true,
    );

    DarwinNotificationDetails iosNotificationDetails = const DarwinNotificationDetails();

    var notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await fl.show(0, title, body, notificationDetails);
  }
}

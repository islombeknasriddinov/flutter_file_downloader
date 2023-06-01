import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef FNP = FlutterLocalNotificationsPlugin;

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
    required String channelId,
    required String title,
    required String body,
    required FlutterLocalNotificationsPlugin fl,
  }) async {
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channelId,
      channelId,
      playSound: true,
      importance: Importance.max,
      priority: Priority.max,
      enableLights: true,
      enableVibration: true,
    );

    DarwinNotificationDetails iosNotificationDetails = const DarwinNotificationDetails();

    var notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await fl.show(id, title, body, notificationDetails);
  }
}

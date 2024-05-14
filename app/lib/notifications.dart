import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Class handles notifications. Currently only supports Android.
class NotificationService{
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Setup and initialize notifications service.
  Future<void> init() async{
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// Create single notification.
  void makeNotification(String text) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('1', 'BestBurger', importance: Importance.max, priority: Priority.high);
    const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show( 0, "Best burger", text, notificationDetails);
  }
}
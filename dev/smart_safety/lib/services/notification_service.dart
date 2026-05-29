import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:typed_data';
import 'package:smart_community_safety/utils/constants.dart';
import 'package:latlong2/latlong.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    // Use the default launcher icon that EVERY Flutter app has
    final AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('ic_launcher'); // ✅ String, not null

    final InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: 'Community safety alerts',
      importance: Importance.high,
      priority: Priority.high,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      enableVibration: true,
      playSound: true,
    );

    final NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _plugin.show(id, title, body, platformDetails);
  }
}
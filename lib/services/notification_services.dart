import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _noti =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzData.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _noti.initialize(settings);
  }

  static Future<void> schedulePeriodReminder(DateTime date) async {
    final tz.TZDateTime scheduledDate =
    tz.TZDateTime.from(date, tz.local).subtract(const Duration(days: 2));

    if (scheduledDate.isBefore(DateTime.now())) return;

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'period_channel',
      'Period Reminders',
      channelDescription: 'Notifications for upcoming periods',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notiDetails =
    NotificationDetails(android: androidDetails);

    await _noti.zonedSchedule(
      1,
      'Your period is coming soon',
      'You might get your period in about 2 days.',
      scheduledDate,
      notiDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

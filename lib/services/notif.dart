import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class Notif {
  final _p = FlutterLocalNotificationsPlugin();
  bool ready = false;

  Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      const s = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );
      await _p.initialize(s, onDidReceiveNotificationResponse: (_) {});
      ready = true;
    } catch (_) {}
  }

  Future<void> permission() async {
    try {
      final impl = await _p
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await impl?.requestNotificationsPermission();
    } catch (_) {}
  }

  Future<void> show(int id, String title, String body) async {
    if (!ready) return;
    try {
      await _p.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'savewise_general',
            'SaveWise',
            channelDescription: 'Reminders and alerts',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(''),
          ),
        ),
      );
    } catch (_) {}
  }

  tz.TZDateTime _next(int h, int m) {
    final now = DateTime.now();
    var dt = DateTime(now.year, now.month, now.day, h, m);
    if (!dt.isAfter(now)) dt = dt.add(const Duration(days: 1));
    final utc = dt.subtract(now.timeZoneOffset);
    return tz.TZDateTime.utc(utc.year, utc.month, utc.day, utc.hour, utc.minute);
  }

  Future<void> scheduleDaily(
    int hour,
    int minute,
    String title,
    String body,
  ) async {
    if (!ready) return;
    try {
      await _p.zonedSchedule(
        100,
        title,
        body,
        _next(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'savewise_daily',
            'Daily reminder',
            channelDescription: 'Daily expense logging reminder',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  Future<void> cancelAllSchedules() async {
    try {
      await _p.cancel(100);
    } catch (_) {}
  }
}

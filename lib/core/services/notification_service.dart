import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();

    tz.setLocalLocation(
      tz.getLocation('Asia/Kolkata'),
    );

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
    );

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final notificationPermission =
        await androidPlugin?.requestNotificationsPermission();

    debugPrint(
      'CHRONOS: Notification permission = $notificationPermission',
    );

    final exactAlarmPermission =
        await androidPlugin?.requestExactAlarmsPermission();

    debugPrint(
      'CHRONOS: Exact alarm permission request = $exactAlarmPermission',
    );

    debugPrint(
      'CHRONOS: Timezone = ${tz.local.name}',
    );
  }

  Future<void> requestExactAlarmPermission() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final result =
        await androidPlugin?.requestExactAlarmsPermission();

    debugPrint(
      'CHRONOS: Exact alarm permission = $result',
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
  }) async {
    final now = DateTime.now();

    debugPrint('========================================');
    debugPrint('CHRONOS ALARM');
    debugPrint('ID: $id');
    debugPrint('Title: $title');
    debugPrint('Current time: $now');
    debugPrint('Scheduled time: $scheduledDateTime');
    debugPrint('Timezone: ${tz.local.name}');

    if (!scheduledDateTime.isAfter(now)) {
      debugPrint(
        'CHRONOS ERROR: Scheduled time is in the past!',
      );
      debugPrint('========================================');
      return;
    }

    final scheduled = tz.TZDateTime.from(
      scheduledDateTime,
      tz.local,
    );

    debugPrint(
      'TZ scheduled time: $scheduled',
    );

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduled,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'chronos_task_channel',
            'Task Reminders',
            channelDescription:
                'Notifications for scheduled tasks',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            ticker: 'Chronos Task Reminder',
          ),
        ),
        androidScheduleMode:
            AndroidScheduleMode.exactAllowWhileIdle,
      );

      debugPrint(
        'CHRONOS SUCCESS: Notification scheduled!',
      );

      final pending =
          await _plugin.pendingNotificationRequests();

      debugPrint(
        'CHRONOS: Pending notifications = ${pending.length}',
      );

      for (final notification in pending) {
        debugPrint(
          'Pending ID: ${notification.id}, '
          'Title: ${notification.title}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        'CHRONOS ERROR SCHEDULING NOTIFICATION: $e',
      );

      debugPrint(
        stackTrace.toString(),
      );
    }

    debugPrint('========================================');
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id: id);

    debugPrint(
      'CHRONOS: Cancelled notification $id',
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();

    debugPrint(
      'CHRONOS: Cancelled all notifications',
    );
  }

  Future<void> showTestNotification() async {
    await _plugin.show(
      id: 999999,
      title: 'Chronos Test',
      body: 'Notifications are working!',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'chronos_test_channel',
          'Test Notifications',
          channelDescription: 'Chronos notification test',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
    );

    debugPrint(
      'CHRONOS: Instant test notification sent',
    );
  }
}
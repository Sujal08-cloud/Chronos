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

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> init() async {
    // Initialize timezone database
    tz_data.initializeTimeZones();

    // India timezone
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
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // IMPORTANT:
    // Correct generic syntax is <AndroidFlutterLocalNotificationsPlugin>
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Android 13+ notification permission
    final bool? notificationPermission =
        await androidPlugin?.requestNotificationsPermission();

    debugPrint(
      'CHRONOS: Notification permission = $notificationPermission',
    );

    // Exact alarm permission
    final bool? exactAlarmPermission =
        await androidPlugin?.requestExactAlarmsPermission();

    debugPrint(
      'CHRONOS: Exact alarm permission = $exactAlarmPermission',
    );

    debugPrint(
      'CHRONOS: Timezone = ${tz.local.name}',
    );
  }

  // ============================================================
  // EXACT ALARM PERMISSION
  // ============================================================

  Future<void> requestExactAlarmPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool? result =
        await androidPlugin?.requestExactAlarmsPermission();

    debugPrint(
      'CHRONOS: Exact alarm permission = $result',
    );
  }

  // ============================================================
  // NOTIFICATION RESPONSE
  // ============================================================

  void _onNotificationResponse(
    NotificationResponse response,
  ) {
    debugPrint(
      'CHRONOS: Notification response '
      'actionId=${response.actionId}, '
      'id=${response.id}',
    );

    // Stop button
    if (response.actionId == 'stop_action' &&
        response.id != null) {
      _plugin.cancel(
        id: response.id!,
      );
    }
  }

  // ============================================================
  // SCHEDULE ALARM
  // ============================================================

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
  }) async {
    final DateTime now = DateTime.now();

    debugPrint('========================================');
    debugPrint('CHRONOS ALARM');
    debugPrint('ID: $id');
    debugPrint('Title: $title');
    debugPrint('Current time: $now');
    debugPrint('Scheduled time: $scheduledDateTime');
    debugPrint('Timezone: ${tz.local.name}');

    // Don't schedule past alarms
    if (!scheduledDateTime.isAfter(now)) {
      debugPrint(
        'CHRONOS ERROR: Scheduled time is in the past!',
      );
      debugPrint('========================================');
      return;
    }

    final tz.TZDateTime scheduled =
        tz.TZDateTime.from(
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
            'chronos_alarm_channel',
            'Task Alarms',

            channelDescription:
                'Alarm sound for scheduled tasks',

            importance: Importance.max,
            priority: Priority.high,

            playSound: true,
            enableVibration: true,

            ticker: 'Chronos Task Alarm',

            // Custom alarm sound
            sound: RawResourceAndroidNotificationSound(
              'alarm_sound',
            ),

            category: AndroidNotificationCategory.alarm,

            fullScreenIntent: true,

            actions: [
              AndroidNotificationAction(
                'stop_action',
                'Stop',
                cancelNotification: true,
              ),
            ],
          ),
        ),

        androidScheduleMode:
            AndroidScheduleMode.exactAllowWhileIdle,
      );

      debugPrint(
        'CHRONOS SUCCESS: Alarm scheduled!',
      );

      // Check pending alarms
      final List<PendingNotificationRequest> pending =
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
        'CHRONOS ERROR SCHEDULING ALARM: $e',
      );

      debugPrint(
        stackTrace.toString(),
      );
    }

    debugPrint('========================================');
  }

  // ============================================================
  // CANCEL ALARM
  // ============================================================

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(
      id: id,
    );

    debugPrint(
      'CHRONOS: Cancelled notification $id',
    );
  }

  // ============================================================
  // CANCEL ALL
  // ============================================================

  Future<void> cancelAll() async {
    await _plugin.cancelAll();

    debugPrint(
      'CHRONOS: Cancelled all notifications',
    );
  }

  // ============================================================
  // TEST NOTIFICATION
  // ============================================================

  Future<void> showTestNotification() async {
    await _plugin.show(
      id: 999999,
      title: 'Chronos Test',
      body: 'Notifications are working!',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'chronos_test_channel',
          'Test Notifications',
          channelDescription:
              'Chronos notification test',

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
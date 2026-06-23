import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/models/app_settings_model.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final ValueNotifier<String?> launchPayload = ValueNotifier<String?>(null);

  Future<void> init() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final details = await _plugin.getNotificationAppLaunchDetails();
    launchPayload.value = details?.notificationResponse?.payload;
    await _plugin.initialize(
      settings: const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (response) {
        launchPayload.value = response.payload;
      },
    );
  }

  String? consumeLaunchPayload() {
    final payload = launchPayload.value;
    launchPayload.value = null;
    return payload;
  }

  Future<bool> requestNotificationPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? true;
  }

  Future<bool> requestExactAlarmPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestExactAlarmsPermission() ?? false;
  }

  Future<void> scheduleDaily(AppSettingsModel settings) async {
    await _plugin.cancel(id: 1001);
    await _plugin.cancel(id: 1002);
    await _plugin.cancel(id: 1003);
    if (!settings.notificationsEnabled) return;

    final mode = settings.strongReminderMode
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    await _scheduleWithFallback(
      id: 1001,
      title: 'DayProof',
      body: 'Choose what matters today.',
      payload: 'morning',
      time: settings.morningTime,
      mode: mode,
    );
    await _scheduleWithFallback(
      id: 1002,
      title: 'DayProof Review',
      body: 'Did you do what you promised yourself?',
      payload: 'night',
      time: settings.nightTime,
      mode: mode,
    );

    final missed = TimeOfDay(
      hour:
          (settings.nightTime.hour + ((settings.nightTime.minute + 30) ~/ 60)) %
          24,
      minute: (settings.nightTime.minute + 30) % 60,
    );
    await _scheduleWithFallback(
      id: 1003,
      title: 'Still want to close the day?',
      body: 'No guilt. Just truth.',
      payload: 'night',
      time: missed,
      mode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> _scheduleWithFallback({
    required int id,
    required String title,
    required String body,
    required String payload,
    required TimeOfDay time,
    required AndroidScheduleMode mode,
  }) async {
    try {
      await _schedule(
        id: id,
        title: title,
        body: body,
        payload: payload,
        time: time,
        mode: mode,
      );
    } catch (_) {
      if (mode == AndroidScheduleMode.inexactAllowWhileIdle) rethrow;
      await _schedule(
        id: id,
        title: title,
        body: body,
        payload: payload,
        time: time,
        mode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details(),
      payload: payload,
    );
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required String payload,
    required TimeOfDay time,
    required AndroidScheduleMode mode,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstance(time),
      notificationDetails: _details(),
      androidScheduleMode: mode,
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'dayproof_daily',
        'DayProof daily reminders',
        channelDescription: 'Morning planning and night review reminders.',
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
      ),
    );
  }

  tz.TZDateTime _nextInstance(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

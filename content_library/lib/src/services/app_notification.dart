import 'dart:async';
import 'dart:io' show Platform;

import 'package:content_library/src/utils/custom_log.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

export 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show NotificationResponse;

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  customLog('Tapped (background): ${response.payload}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService I = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const String _defaultChannelId = 'default_channel';
  static const String _defaultChannelName = 'Notificações';
  static const String _defaultChannelDesc = 'Canal padrão para notificações gerais';

  bool _initialized = false;

  Future<void> init({void Function(NotificationResponse resp)? onTap}) async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final String localTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings();

    final ok = await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: darwinInit),
      onDidReceiveNotificationResponse: onTap,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    if (Platform.isAndroid) {
      try {
        final androidImpl = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        await androidImpl?.requestNotificationsPermission();
        // await androidImpl?.requestFullScreenIntentPermission();
        await androidImpl?.requestExactAlarmsPermission();
      } catch (_) {}
    }

    _initialized = ok ?? true;
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    final android = AndroidNotificationDetails(
      _defaultChannelId,
      _defaultChannelName,
      channelDescription: _defaultChannelDesc,
      importance: importance,
      priority: priority,
    );
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(android: android),
      payload: payload,
    );
  }

  Future<void> showOrUpdateProgress({
    required int id,
    required String title,
    required String body,
    required int progress,
    int maxProgress = 100,
    bool indeterminate = false,
    bool ongoing = true,
    String? payload,
  }) async {
    final android = AndroidNotificationDetails(
      _defaultChannelId,
      _defaultChannelName,
      channelDescription: _defaultChannelDesc,
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
      indeterminate: indeterminate,
      ongoing: ongoing,
      onlyAlertOnce: true,
    );

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(android: android),
      payload: payload,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    String? payload,
  }) async {
    final android = AndroidNotificationDetails(
      _defaultChannelId,
      _defaultChannelName,
      channelDescription: _defaultChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );

    final scheduled = tz.TZDateTime.from(when, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      NotificationDetails(android: android),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
  }) async {
    final next = _nextInstanceOfTime(time.hour, time.minute);
    final android = AndroidNotificationDetails(
      _defaultChannelId,
      _defaultChannelName,
      channelDescription: _defaultChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      next,
      NotificationDetails(android: android),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    var now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

class TimeOfDay {
  final int hour;
  final int minute;
  const TimeOfDay({required this.hour, required this.minute});
}

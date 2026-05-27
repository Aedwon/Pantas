import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:cse_cet_reviewer/features/notifications/data/notifications_gateway.dart';
import 'package:cse_cet_reviewer/features/notifications/domain/notification_payload.dart';
import 'package:cse_cet_reviewer/features/notifications/domain/notification_permission.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class FlutterLocalNotificationsGateway implements NotificationsGateway {
  FlutterLocalNotificationsGateway({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final _permissionController =
      StreamController<NotificationPermission>.broadcast();
  var _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: darwinInit),
    );
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_dailyChannel);
    await android?.createNotificationChannel(_streakChannel);
    _initialized = true;
    _permissionController.add(await permissionStatus());
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  Future<void> openAppNotificationSettings() {
    return AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  @override
  Future<NotificationPermission> permissionStatus() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted = await android?.areNotificationsEnabled();
    if (androidGranted != null) {
      return androidGranted
          ? NotificationPermission.granted
          : NotificationPermission.denied;
    }

    return NotificationPermission.notYetAsked;
  }

  @override
  Future<NotificationPermission> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted = await android?.requestNotificationsPermission();
    if (androidGranted != null) {
      final status = androidGranted
          ? NotificationPermission.granted
          : NotificationPermission.denied;
      _permissionController.add(status);
      return status;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await ios?.requestPermissions();
    final status = switch (iosGranted) {
      true => NotificationPermission.granted,
      false => NotificationPermission.denied,
      null => NotificationPermission.notYetAsked,
    };
    _permissionController.add(status);
    return status;
  }

  @override
  Future<void> schedule(ScheduledNotification notification) {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        notification.kind == NotificationKind.dailyReminder
            ? _dailyChannel.id
            : _streakChannel.id,
        notification.kind == NotificationKind.dailyReminder
            ? _dailyChannel.name
            : _streakChannel.name,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    return _plugin.zonedSchedule(
      notification.id,
      notification.title,
      notification.body,
      tz.TZDateTime.from(notification.fireAt, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: notification.payload,
    );
  }

  @override
  Stream<NotificationPermission> watchPermissionStatus() async* {
    yield await permissionStatus();
    yield* _permissionController.stream;
  }
}

const _dailyChannel = AndroidNotificationChannel(
  'daily_reminder',
  'Daily reminder',
  description: 'Daily study reminders',
);

const _streakChannel = AndroidNotificationChannel(
  'streak_save',
  'Streak save',
  description: 'Streak save reminders',
);

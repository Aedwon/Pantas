import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/features/notifications/data/notifications_gateway.dart';
import 'package:pantas/features/notifications/domain/notification_payload.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class FlutterLocalNotificationsGateway implements NotificationsGateway {
  FlutterLocalNotificationsGateway({
    FlutterLocalNotificationsPlugin? plugin,
    AndroidFlutterLocalNotificationsPlugin? Function(
      FlutterLocalNotificationsPlugin plugin,
    )? androidPluginResolver,
  })  : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        _androidPluginResolver = androidPluginResolver;

  final FlutterLocalNotificationsPlugin _plugin;
  final AndroidFlutterLocalNotificationsPlugin? Function(
    FlutterLocalNotificationsPlugin plugin,
  )? _androidPluginResolver;
  final _permissionController =
      StreamController<NotificationPermission>.broadcast();
  final _tapController = StreamController<String?>.broadcast();
  var _initialized = false;
  NotificationPermission? _lastPermission;

  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin {
    final resolver = _androidPluginResolver;
    if (resolver != null) return resolver(_plugin);
    return _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
      ),
      onDidReceiveNotificationResponse: (response) {
        _tapController.add(response.payload);
      },
    );
    final android = _androidPlugin;
    for (final channel in _channels.values) {
      await android?.createNotificationChannel(channel);
    }
    _initialized = true;
    await permissionStatus();
  }

  @override
  Future<String?> initialNotificationTapPayload() async {
    await initialize();
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    return details?.notificationResponse?.payload;
  }

  @override
  Stream<String?> get notificationTapPayloads => _tapController.stream;

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  Future<void> openAppNotificationSettings() {
    return AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  @override
  Future<NotificationPermission> permissionStatus() async {
    final androidGranted = await _androidPlugin?.areNotificationsEnabled();
    if (androidGranted != null) {
      return _publishPermission(androidGranted
          ? NotificationPermission.granted
          : NotificationPermission.denied,);
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final permission = await ios?.checkPermissions();
    if (permission != null) {
      return _publishPermission(permission.isEnabled
          ? NotificationPermission.granted
          : NotificationPermission.denied,);
    }
    return _publishPermission(NotificationPermission.notYetAsked);
  }

  NotificationPermission _publishPermission(NotificationPermission status) {
    if (_lastPermission != status) {
      _lastPermission = status;
      _permissionController.add(status);
    }
    return status;
  }

  @override
  Future<NotificationPermission> requestPermission() async {
    final android = _androidPlugin;
    final androidGranted = await android?.requestNotificationsPermission();
    if (androidGranted != null) {
      final status = androidGranted
          ? NotificationPermission.granted
          : NotificationPermission.denied;
      if (androidGranted) {
        final exactAlarmsAvailable =
            await android?.canScheduleExactNotifications();
        if (exactAlarmsAvailable == false) {
          await android?.requestExactAlarmsPermission();
        }
      }
      return _publishPermission(status);
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await ios?.requestPermissions();
    final status = switch (iosGranted) {
      true => NotificationPermission.granted,
      false => NotificationPermission.denied,
      null => NotificationPermission.notYetAsked,
    };
    return _publishPermission(status);
  }

  @override
  Future<void> schedule(ScheduledNotification notification) async {
    final exactAlarmsAvailable =
        await _androidPlugin?.canScheduleExactNotifications();
    if (exactAlarmsAvailable == false) return;

    final channel = _channels[notification.kind]!;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(channel.id, channel.name),
      iOS: const DarwinNotificationDetails(),
    );
    await _plugin.zonedSchedule(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      scheduledDate: tz.TZDateTime.from(notification.fireAt, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: notification.payload,
    );
  }

  @override
  Stream<NotificationPermission> watchPermissionStatus() async* {
    yield await permissionStatus();
    yield* _permissionController.stream;
  }
}

const _channels = {
  NotificationKind.dailyReminder: AndroidNotificationChannel(
    'daily_reminder',
    'Daily reminder',
    description: 'Daily study reminders',
  ),
  NotificationKind.followUp: AndroidNotificationChannel(
    'follow_up',
    'Follow up',
    description: 'Follow-up study reminders',
  ),
  NotificationKind.examCountdown: AndroidNotificationChannel(
    'exam_countdown',
    'Exam countdown',
    description: 'Exam countdown reminders',
  ),
  NotificationKind.comeBack: AndroidNotificationChannel(
    'come_back',
    'Come back',
    description: 'Study reminders after a break',
  ),
  NotificationKind.trialEnding: AndroidNotificationChannel(
    'trial_ending',
    'Trial ending',
    description: 'Monthly trial charge reminder',
  ),
};

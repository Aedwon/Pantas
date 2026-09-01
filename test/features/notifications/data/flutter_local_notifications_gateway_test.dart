import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/features/notifications/data/flutter_local_notifications_gateway.dart';
import 'package:pantas/features/notifications/data/notifications_gateway.dart';
import 'package:pantas/features/notifications/notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    registerFallbackValue(tz.TZDateTime(tz.UTC, 2026));
    registerFallbackValue(const NotificationDetails());
  });

  late _MockFlutterLocalNotificationsPlugin plugin;
  late _MockAndroidFlutterLocalNotificationsPlugin android;
  late FlutterLocalNotificationsGateway gateway;

  setUp(() {
    plugin = _MockFlutterLocalNotificationsPlugin();
    android = _MockAndroidFlutterLocalNotificationsPlugin();
    gateway = FlutterLocalNotificationsGateway(
      plugin: plugin,
      androidPluginResolver: (_) => android,
    );
  });

  test(
    'posting permission denied does not request exact alarm access',
    () async {
      when(
        () => android.requestNotificationsPermission(),
      ).thenAnswer((_) async => false);

      expect(await gateway.requestPermission(), NotificationPermission.denied);

      verifyNever(() => android.canScheduleExactNotifications());
      verifyNever(() => android.requestExactAlarmsPermission());
    },
  );

  test(
    'posting permission granted keeps existing exact alarm access',
    () async {
      when(
        () => android.requestNotificationsPermission(),
      ).thenAnswer((_) async => true);
      when(
        () => android.canScheduleExactNotifications(),
      ).thenAnswer((_) async => true);

      expect(await gateway.requestPermission(), NotificationPermission.granted);

      verify(() => android.canScheduleExactNotifications()).called(1);
      verifyNever(() => android.requestExactAlarmsPermission());
    },
  );

  test(
    'posting permission granted requests missing exact alarm access once',
    () async {
      when(
        () => android.requestNotificationsPermission(),
      ).thenAnswer((_) async => true);
      when(
        () => android.canScheduleExactNotifications(),
      ).thenAnswer((_) async => false);
      when(
        () => android.requestExactAlarmsPermission(),
      ).thenAnswer((_) async => false);

      expect(await gateway.requestPermission(), NotificationPermission.granted);

      verify(() => android.requestExactAlarmsPermission()).called(1);
    },
  );

  test('available exact alarms keep exactAllowWhileIdle scheduling', () async {
    when(
      () => android.canScheduleExactNotifications(),
    ).thenAnswer((_) async => true);
    _stubZonedSchedule(plugin);

    await gateway.schedule(_dailyNotification());

    _verifyExactScheduleSubmitted(plugin);
  });

  test('unavailable exact alarms skip scheduling without throwing', () async {
    when(
      () => android.canScheduleExactNotifications(),
    ).thenAnswer((_) async => false);

    await expectLater(gateway.schedule(_dailyNotification()), completes);

    _verifyNoExactScheduleSubmitted(plugin);
  });

  test(
    'null Android implementation keeps the existing scheduling path',
    () async {
      final nonAndroidGateway = FlutterLocalNotificationsGateway(
        plugin: plugin,
        androidPluginResolver: (_) => null,
      );
      _stubZonedSchedule(plugin);

      await nonAndroidGateway.schedule(_dailyNotification());

      _verifyExactScheduleSubmitted(plugin);
    },
  );
}

ScheduledNotification _dailyNotification() {
  return ScheduledNotification(
    id: NotificationIds.dailyReminder,
    kind: NotificationKind.dailyReminder,
    fireAt: DateTime(2026, 8, 26, 19),
    title: 'Title',
    body: 'Body',
    payload: 'payload',
  );
}

void _stubZonedSchedule(_MockFlutterLocalNotificationsPlugin plugin) {
  when(
    () => plugin.zonedSchedule(
      id: NotificationIds.dailyReminder,
      title: 'Title',
      body: 'Body',
      scheduledDate: any(named: 'scheduledDate'),
      notificationDetails: any(named: 'notificationDetails'),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'payload',
    ),
  ).thenAnswer((_) async {});
}

void _verifyExactScheduleSubmitted(
  _MockFlutterLocalNotificationsPlugin plugin,
) {
  verify(
    () => plugin.zonedSchedule(
      id: NotificationIds.dailyReminder,
      title: 'Title',
      body: 'Body',
      scheduledDate: any(named: 'scheduledDate'),
      notificationDetails: any(named: 'notificationDetails'),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'payload',
    ),
  ).called(1);
}

void _verifyNoExactScheduleSubmitted(
  _MockFlutterLocalNotificationsPlugin plugin,
) {
  verifyNever(
    () => plugin.zonedSchedule(
      id: NotificationIds.dailyReminder,
      title: 'Title',
      body: 'Body',
      scheduledDate: any(named: 'scheduledDate'),
      notificationDetails: any(named: 'notificationDetails'),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'payload',
    ),
  );
}

class _MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class _MockAndroidFlutterLocalNotificationsPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

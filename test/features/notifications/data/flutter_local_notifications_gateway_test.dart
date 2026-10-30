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
  test('foreground permission refresh publishes a phone-settings change',
      () async {
    when(android.areNotificationsEnabled).thenAnswer((_) async => true);
    final statuses = <NotificationPermission>[];
    final subscription = gateway.watchPermissionStatus().listen(statuses.add);
    await Future<void>.delayed(Duration.zero);
    when(android.areNotificationsEnabled).thenAnswer((_) async => false);
    expect(await gateway.permissionStatus(), NotificationPermission.denied);
    await Future<void>.delayed(Duration.zero);
    expect(statuses,
        [NotificationPermission.granted, NotificationPermission.denied]);
    await subscription.cancel();
  });

  test('iOS foreground permission reads granted status without another prompt',
      () async {
    final ios = _MockIOSFlutterLocalNotificationsPlugin();
    when(
      () => plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>(),
    ).thenReturn(ios);
    when(ios.checkPermissions).thenAnswer(
      (_) async => const NotificationsEnabledOptions(
        isEnabled: true,
        isSoundEnabled: true,
        isAlertEnabled: true,
        isBadgeEnabled: true,
        isProvisionalEnabled: false,
        isCriticalEnabled: false,
        isProvidesAppNotificationSettingsEnabled: false,
      ),
    );
    final iosGateway = FlutterLocalNotificationsGateway(
      plugin: plugin,
      androidPluginResolver: (_) => null,
    );
    expect(await iosGateway.permissionStatus(), NotificationPermission.granted);
  });

  for (final entry in [
    (NotificationKind.dailyReminder, 'daily_reminder', 'Daily reminder'),
    (NotificationKind.followUp, 'follow_up', 'Follow up'),
    (NotificationKind.examCountdown, 'exam_countdown', 'Exam countdown'),
    (NotificationKind.comeBack, 'come_back', 'Come back'),
    (NotificationKind.trialEnding, 'trial_ending', 'Trial ending'),
  ]) {
    test('${entry.$1.name} uses its own Android channel', () async {
      when(() => android.canScheduleExactNotifications())
          .thenAnswer((_) async => true);
      _stubZonedSchedule(plugin);
      final base = _dailyNotification();
      await gateway.schedule(
        ScheduledNotification(
          id: base.id,
          kind: entry.$1,
          fireAt: base.fireAt,
          title: base.title,
          body: base.body,
          payload: base.payload,
        ),
      );
      final details = verify(
        () => plugin.zonedSchedule(
          id: NotificationIds.dailyReminder,
          title: 'Title',
          body: 'Body',
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: captureAny(named: 'notificationDetails'),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'payload',
        ),
      ).captured.single as NotificationDetails;
      expect(details.android?.channelId, entry.$2);
      expect(details.android?.channelName, entry.$3);
    });
  }
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

class _MockIOSFlutterLocalNotificationsPlugin extends Mock
    implements IOSFlutterLocalNotificationsPlugin {}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/notifications/data/notifications_gateway.dart';
import 'package:pantas/features/notifications/notifications.dart';

void main() {
  test(
    'fake gateway records initialize schedule cancel and cancelAll calls',
    () async {
      final gateway = RecordingNotificationsGateway();

      await gateway.initialize();
      await gateway.schedule(
        ScheduledNotification(
          id: NotificationIds.dailyReminder,
          kind: NotificationKind.dailyReminder,
          fireAt: DateTime(2026, 5, 22, 19),
          title: 'Title',
          body: 'Body',
          payload: 'payload',
        ),
      );
      await gateway.cancel(NotificationIds.followUp);
      await gateway.cancelAll();

      expect(gateway.log, [
        'initialize',
        'schedule:9001:daily_reminder:Title:Body',
        'cancel:9002',
        'cancelAll',
      ]);
    },
  );

  test('fake gateway emits permission status changes', () async {
    final gateway = RecordingNotificationsGateway();

    final expectation = expectLater(
      gateway.watchPermissionStatus(),
      emitsInOrder([
        NotificationPermission.notYetAsked,
        NotificationPermission.denied,
      ]),
    );

    await Future<void>.delayed(Duration.zero);
    gateway.permission = NotificationPermission.denied;
    await expectation;
  });

  test('fake gateway records app notification settings requests', () async {
    final gateway = RecordingNotificationsGateway();

    await gateway.openAppNotificationSettings();

    expect(gateway.log, ['openSettings']);
  });
}

class RecordingNotificationsGateway implements NotificationsGateway {
  final log = <String>[];
  final _permissionController =
      StreamController<NotificationPermission>.broadcast();
  final _tapController = StreamController<String?>.broadcast();
  NotificationPermission _permission = NotificationPermission.notYetAsked;

  NotificationPermission get permission => _permission;

  set permission(NotificationPermission value) {
    _permission = value;
    _permissionController.add(value);
  }

  @override
  Future<void> cancel(int id) async => log.add('cancel:$id');

  @override
  Future<void> cancelAll() async => log.add('cancelAll');

  @override
  Future<void> initialize() async => log.add('initialize');

  @override
  Future<String?> initialNotificationTapPayload() async => null;

  @override
  Stream<String?> get notificationTapPayloads => _tapController.stream;

  @override
  Future<void> openAppNotificationSettings() async => log.add('openSettings');

  @override
  Future<NotificationPermission> permissionStatus() async => _permission;

  @override
  Future<NotificationPermission> requestPermission() async => _permission;

  @override
  Future<void> schedule(ScheduledNotification notification) async {
    log.add(
      'schedule:${notification.id}:${notification.kind.storageValue}:'
      '${notification.title}:${notification.body}',
    );
  }

  @override
  Stream<NotificationPermission> watchPermissionStatus() async* {
    yield _permission;
    yield* _permissionController.stream;
  }
}

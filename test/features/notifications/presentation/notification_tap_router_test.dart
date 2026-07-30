import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/features/notifications/data/notifications_gateway.dart';
import 'package:pantas/features/notifications/domain/notification_payload.dart';
import 'package:pantas/features/notifications/presentation/notification_tap_router.dart';

void main() {
  testWidgets('warm notification tap opens fresh payload route',
      (tester) async {
    final gateway = TapOnlyGateway();
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        builder: (context, child) => NotificationTapRouter(
          gateway: gateway,
          router: router,
          now: () => DateTime(2026, 5, 23, 8),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );

    gateway.emit(
      NotificationPayload(
        kind: NotificationKind.dailyReminder,
        scheduledFor: DateTime(2026, 5, 23, 7),
        route: '/quiz/today/cse',
      ).encode(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Today quiz'), findsOneWidget);
  });

  testWidgets('cold notification tap falls back home when payload is stale',
      (tester) async {
    final gateway = TapOnlyGateway(
      initialPayload: NotificationPayload(
        kind: NotificationKind.streakSave,
        scheduledFor: DateTime(2026, 5, 22, 20),
        route: '/quiz/today/cse',
      ).encode(),
    );
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        builder: (context, child) => NotificationTapRouter(
          gateway: gateway,
          router: router,
          now: () => DateTime(2026, 5, 23, 1),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (_, __) => const Text('Home')),
      GoRoute(
        path: '/quiz/today/:examId',
        builder: (_, __) => const Text('Today quiz'),
      ),
    ],
  );
}

class TapOnlyGateway implements NotificationsGateway {
  TapOnlyGateway({this.initialPayload});

  final String? initialPayload;
  final _controller = StreamController<String?>.broadcast();

  void emit(String? payload) => _controller.add(payload);

  @override
  Stream<String?> get notificationTapPayloads => _controller.stream;

  @override
  Future<String?> initialNotificationTapPayload() async => initialPayload;

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> openAppNotificationSettings() async {}

  @override
  Future<NotificationPermission> permissionStatus() async {
    return NotificationPermission.granted;
  }

  @override
  Future<NotificationPermission> requestPermission() async {
    return NotificationPermission.granted;
  }

  @override
  Future<void> schedule(ScheduledNotification notification) async {}

  @override
  Stream<NotificationPermission> watchPermissionStatus() {
    return Stream.value(NotificationPermission.granted);
  }
}

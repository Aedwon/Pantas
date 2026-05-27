import 'package:cse_cet_reviewer/core/notifications/notification_service.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/notifications/application/notifications_providers.dart';
import 'package:cse_cet_reviewer/features/notifications/presentation/permission_rationale_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('sounds good requests permission marks shown and routes home',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final notifications = RecordingNotificationService();
    final router = GoRouter(
      initialLocation: '/notifications/rationale',
      routes: [
        GoRoute(
          path: '/notifications/rationale',
          builder: (_, __) => const PermissionRationalePage(),
        ),
        GoRoute(path: '/home', builder: (_, __) => const Text('Home')),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpAppWithRouter(
      router,
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
    );

    await tester.tap(find.text('Sounds good'));
    await tester.pumpAndSettle();

    expect(notifications.requestCount, 1);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    expect(
      await container.read(notificationRationaleShownProvider.future),
      isTrue,
    );
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('not right now marks shown without requesting permission',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final notifications = RecordingNotificationService();
    final router = GoRouter(
      initialLocation: '/notifications/rationale',
      routes: [
        GoRoute(
          path: '/notifications/rationale',
          builder: (_, __) => const PermissionRationalePage(),
        ),
        GoRoute(path: '/home', builder: (_, __) => const Text('Home')),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpAppWithRouter(
      router,
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
    );

    await tester.tap(find.text('Not right now'));
    await tester.pumpAndSettle();

    expect(notifications.requestCount, 0);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    expect(
      await container.read(notificationRationaleShownProvider.future),
      isTrue,
    );
    expect(find.text('Home'), findsOneWidget);
  });
}

class RecordingNotificationService implements NotificationService {
  int requestCount = 0;

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> onSessionCompleted() async {}

  @override
  Future<void> openAppNotificationSettings() async {}

  @override
  Future<NotificationPermission> requestPermission() async {
    requestCount += 1;
    return NotificationPermission.granted;
  }

  @override
  Future<void> rescheduleForForeground() async {}

  @override
  Future<void> scheduleDailyReminder(NotificationTime time) async {}
}

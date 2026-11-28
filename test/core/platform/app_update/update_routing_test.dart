import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/update_coordinator_provider.dart';
import 'package:pantas/core/platform/app_update/update_coordinator.dart';

import 'update_coordinator_test.dart' show SafePoints;

void main() {
  testWidgets('route binding handles boot, Home and quiz session end',
      (tester) async {
    final safe = SafePoints();
    final coordinator = UpdateCoordinator(
      onFailure: (error, _) => fail('$error'),
      onSafePoint: safe.call,
    );
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        for (final path in ['/home', '/quiz/run', '/quiz/debrief/attempt'])
          GoRoute(path: path, builder: (_, __) => const SizedBox()),
      ],
    );
    addTearDown(router.dispose);
    // This is deliberately before Router has parsed its first location.
    final stop = observeUpdateRoutes(router, coordinator);
    addTearDown(stop);
    expect(safe.count, 0);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(safe.count, 1);
    router.go('/quiz/run');
    await tester.pumpAndSettle();
    expect(safe.count, 1);
    router.go('/quiz/debrief/attempt');
    await tester.pumpAndSettle();
    expect(safe.count, 2);
  });
}

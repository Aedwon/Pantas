import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/update_coordinator_provider.dart';
import 'package:pantas/core/platform/app_update/update_coordinator.dart';

import 'update_coordinator_test.dart' show FakeBridge;

void main() {
  testWidgets('route binding handles boot, Home and quiz session end',
      (tester) async {
    final bridge = FakeBridge();
    final coordinator = UpdateCoordinator(
      bridge: bridge,
      waitForWrites: () async {},
      onFailure: (error, _) => fail('$error'),
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
    expect(bridge.applies, 0);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(bridge.applies, 1);
    bridge.version = 'another';
    router.go('/quiz/run');
    await tester.pumpAndSettle();
    expect(bridge.applies, 1);
    router.go('/quiz/debrief/attempt');
    await tester.pumpAndSettle();
    expect(bridge.applies, 2);
    router.go('/home');
    await tester.pumpAndSettle();
    expect(bridge.applies, 2);
  });

  testWidgets('activation holds Home across navigation and gate refresh',
      (tester) async {
    final activation = Completer<void>();
    final bridge = FakeBridge()..applyWait = activation.future;
    final coordinator = UpdateCoordinator(
      bridge: bridge,
      waitForWrites: () async {},
      onFailure: (error, _) => fail('$error'),
    )..routeChanged('/home');
    var gated = false;
    var gateChecks = 0;
    final router = GoRouter(
      initialLocation: '/home',
      redirect: guardUpdateActivation(coordinator, (_, state) {
        gateChecks++;
        if (gated && state.uri.path != '/onboarding') return '/onboarding';
        return null;
      }),
      routes: [
        for (final path in ['/home', '/quiz/run', '/onboarding'])
          GoRoute(path: path, builder: (_, __) => const SizedBox()),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    final checking = coordinator.check();
    await tester.pump();
    expect(coordinator.isApplying, isTrue);
    final beforeActivation = gateChecks;
    router.go('/quiz/run');
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/home');
    gated = true;
    router.refresh();
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/home');
    expect(tester.takeException(), isNull);
    expect(gateChecks, beforeActivation);
    activation.complete();
    await checking;
    router.refresh();
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/onboarding');
  });
}

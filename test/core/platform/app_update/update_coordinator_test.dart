import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/platform/app_update/update_bridge.dart';
import 'package:pantas/core/platform/app_update/update_coordinator.dart';

class FakeBridge implements UpdateBridge {
  String version = 'next';
  bool available = true;
  int applies = 0;
  Future<void>? applyWait;
  Exception? failure;
  Exception? checkFailure;

  /// What the browser answers: false when the worker refused (another window
  /// is open) or nothing was waiting.
  bool applied = true;
  @override
  Future<UpdateStatus> check() async {
    if (checkFailure != null) throw checkFailure!;
    return UpdateStatus(available: available, version: version);
  }

  @override
  Future<bool> apply() async {
    applies++;
    await applyWait;
    if (failure != null) throw failure!;
    return applied;
  }
}

void main() {
  late FakeBridge bridge;
  late UpdateCoordinator coordinator;
  setUp(() {
    bridge = FakeBridge();
    coordinator = UpdateCoordinator(
      bridge: bridge,
      waitForWrites: () async {},
      onFailure: (_, __) {},
    );
  });

  test('available update applies at Home', () async {
    coordinator.routeChanged('/home');
    await coordinator.check();
    expect(bridge.applies, 1);
  });

  test('quiz stays pending until its session end route', () async {
    coordinator.routeChanged('/quiz/quick/exam');
    await coordinator.check();
    expect(bridge.applies, 0);
    coordinator.routeChanged('/quiz/debrief/attempt');
    await coordinator.check();
    expect(bridge.applies, 1);
  });

  test('all completed quiz and mock result routes are safe', () async {
    for (final path in ['/quiz/all/attempt', '/mock/results/attempt']) {
      final resultBridge = FakeBridge();
      final updates = UpdateCoordinator(
        bridge: resultBridge,
        waitForWrites: () async {},
        onFailure: (_, __) {},
      )..routeChanged(path);
      await updates.check();
      expect(resultBridge.applies, 1, reason: path);
    }
  });

  test('waits for writes before applying', () async {
    final write = Completer<void>();
    coordinator = UpdateCoordinator(
      bridge: bridge,
      waitForWrites: () => write.future,
      onFailure: (_, __) {},
    )..routeChanged('/home');
    final checking = coordinator.check();
    await Future<void>.delayed(Duration.zero);
    expect(bridge.applies, 0);
    write.complete();
    await checking;
    expect(bridge.applies, 1);
  });

  test('rechecks route after waiting for writes', () async {
    final write = Completer<void>();
    coordinator = UpdateCoordinator(
      bridge: bridge,
      waitForWrites: () => write.future,
      onFailure: (_, __) {},
    )..routeChanged('/home');
    final checking = coordinator.check();
    await Future<void>.delayed(Duration.zero);
    coordinator.routeChanged('/quiz/quick/exam');
    write.complete();
    await checking;
    expect(bridge.applies, 0);
    coordinator.routeChanged('/home');
    await coordinator.check();
    expect(bridge.applies, 1);
  });

  test('applies once per detected version', () async {
    coordinator.routeChanged('/home');
    await coordinator.check();
    await coordinator.check();
    expect(bridge.applies, 1);
    bridge.version = 'another';
    await coordinator.check();
    expect(bridge.applies, 2);
  });

  test(
      'a refused apply is not recorded as attempted, so the next safe point '
      'tries again', () async {
    // A second window made the worker refuse. Closing it must let the update
    // through, not leave this version marked as done (audit 2, Medium 7).
    bridge.applied = false;
    coordinator.routeChanged('/home');
    await coordinator.check();
    await coordinator.check();
    expect(bridge.applies, 2);
    bridge.applied = true;
    await coordinator.check();
    expect(bridge.applies, 3);
    await coordinator.check();
    expect(bridge.applies, 3, reason: 'applied once, then no more');
  });

  test('failed apply does not consume the reload attempt', () async {
    final failures = <Object>[];
    bridge.failure = Exception('activation failed');
    coordinator = UpdateCoordinator(
      bridge: bridge,
      waitForWrites: () async {},
      onFailure: (error, _) => failures.add(error),
    )..routeChanged('/home');
    await coordinator.check();
    await coordinator.check();
    expect(bridge.applies, 2);
    expect(failures, hasLength(2));
    bridge.failure = null;
    await coordinator.check();
    await coordinator.check();
    expect(bridge.applies, 3);
  });

  test('failed check does not consume a detected version', () async {
    coordinator.routeChanged('/home');
    bridge.checkFailure = Exception('offline');
    await coordinator.check();
    expect(bridge.applies, 0);
    bridge.checkFailure = null;
    await coordinator.check();
    expect(bridge.applies, 1);
  });

  test('unsafe routes and overlays block apply', () async {
    for (final route in [
      '/lesson/one',
      '/mock/run/one',
      '/onboarding',
      '/checkout',
      '/settings',
    ]) {
      coordinator.routeChanged(route);
      await coordinator.check();
    }
    expect(bridge.applies, 0);
    coordinator
      ..routeChanged('/home')
      ..setOverlay('dialog', visible: true);
    await coordinator.check();
    expect(bridge.applies, 0);
    coordinator.setOverlay('dialog', visible: false);
    await coordinator.check();
    expect(bridge.applies, 1);
  });

  test('lesson ending signals a safe point within the reader', () async {
    coordinator.routeChanged('/lesson/one');
    await coordinator.check();
    expect(bridge.applies, 0);
    coordinator.lessonEnded();
    await coordinator.check();
    expect(bridge.applies, 1);
  });

  test('concurrent checks share one apply', () async {
    coordinator.routeChanged('/home');
    await Future.wait([coordinator.check(), coordinator.check()]);
    expect(bridge.applies, 1);
  });

  test('activation holds its safe route until apply settles', () async {
    final applying = Completer<void>();
    bridge.applyWait = applying.future;
    coordinator.routeChanged('/home');
    final checking = coordinator.check();
    await Future<void>.delayed(Duration.zero);
    expect(coordinator.isApplying, isTrue);
    expect(coordinator.currentPath, '/home');
    applying.complete();
    await checking;
    expect(coordinator.isApplying, isFalse);
  });

  test('reader reentry cancels a pending ending update', () async {
    final write = Completer<void>();
    coordinator = UpdateCoordinator(
      bridge: bridge,
      waitForWrites: () => write.future,
      onFailure: (_, __) {},
    )
      ..routeChanged('/lesson/one')
      ..lessonEnded();
    final checking = coordinator.check();
    await Future<void>.delayed(Duration.zero);
    coordinator.lessonStarted();
    write.complete();
    await checking;
    expect(bridge.applies, 0);
  });

  test('quiz completion clears on route change', () async {
    bridge.available = false;
    coordinator
      ..routeChanged('/quiz/inline/one')
      ..quizEnded();
    await coordinator.check();
    coordinator.routeChanged('/quiz/inline/two');
    bridge.available = true;
    await coordinator.check();
    expect(bridge.applies, 0);
  });

  test('new quiz cancels completion while writes are pending', () async {
    final write = Completer<void>();
    coordinator = UpdateCoordinator(
      bridge: bridge,
      waitForWrites: () => write.future,
      onFailure: (_, __) {},
    )
      ..routeChanged('/quiz/inline/one')
      ..quizEnded();
    final checking = coordinator.check();
    await Future<void>.delayed(Duration.zero);
    coordinator.quizStarted();
    write.complete();
    await checking;
    await coordinator.check();
    expect(bridge.applies, 0);
  });

  test('repeated quiz completion preserves a pending durability check',
      () async {
    final write = Completer<void>();
    coordinator = UpdateCoordinator(
      bridge: bridge,
      waitForWrites: () => write.future,
      onFailure: (_, __) {},
    )
      ..routeChanged('/quiz/inline/one')
      ..quizEnded();
    final checking = coordinator.check();
    await Future<void>.delayed(Duration.zero);
    coordinator.quizEnded();
    write.complete();
    await checking;
    expect(bridge.applies, 1);
  });

  test('quiz completion does not bypass an input overlay', () async {
    coordinator
      ..routeChanged('/quiz/inline/one')
      ..setOverlay('notes', visible: true)
      ..quizEnded();
    await coordinator.check();
    expect(bridge.applies, 0);
    coordinator.setOverlay('notes', visible: false);
    await coordinator.check();
    expect(bridge.applies, 1);
  });

  test('a safe point runs the content check; an unsafe one does not', () async {
    var checks = 0;
    coordinator = UpdateCoordinator(
      bridge: bridge,
      waitForWrites: () async {},
      onFailure: (_, __) {},
      onSafePoint: () async => checks++,
    )..routeChanged('/quiz/quick/exam');
    await coordinator.check();
    expect(checks, 0);
    coordinator.routeChanged('/home');
    await coordinator.check();
    expect(checks, 1);
  });

  test('a failing content check is reported and does not stop the update',
      () async {
    final failures = <Object>[];
    coordinator = UpdateCoordinator(
      bridge: bridge,
      waitForWrites: () async {},
      onFailure: (error, _) => failures.add(error),
      onSafePoint: () async => throw StateError('offline'),
    )..routeChanged('/home');
    await coordinator.check();
    await Future<void>.delayed(Duration.zero);
    expect(bridge.applies, 1);
    expect(failures, hasLength(1));
  });

  test('native bridge is a no-op', () async {
    final native = createUpdateBridge();
    expect((await native.check()).available, isFalse);
    expect(await native.apply(), isFalse);
  });
}

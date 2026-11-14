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
  @override
  Future<UpdateStatus> check() async =>
      UpdateStatus(available: available, version: version);
  @override
  Future<void> apply() async {
    applies++;
    await applyWait;
    if (failure != null) throw failure!;
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

  test('failed apply reports once and carries on', () async {
    final failures = <Object>[];
    bridge.failure = Exception('activation failed');
    coordinator = UpdateCoordinator(
      bridge: bridge,
      waitForWrites: () async {},
      onFailure: (error, _) => failures.add(error),
    )..routeChanged('/home');
    await coordinator.check();
    await coordinator.check();
    expect(bridge.applies, 1);
    expect(failures, hasLength(1));
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

  test('native bridge is a no-op', () async {
    final native = createUpdateBridge();
    expect((await native.check()).available, isFalse);
    await native.apply();
  });
}

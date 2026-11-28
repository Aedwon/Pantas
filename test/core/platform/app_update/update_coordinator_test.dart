import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/platform/app_update/update_coordinator.dart';

/// Counts the safe points the coordinator finds: it runs the content check at
/// each one and does nothing else (a build update no longer applies here).
class SafePoints {
  int count = 0;
  Future<void> call() async => count++;
}

void main() {
  late SafePoints safe;
  late UpdateCoordinator coordinator;
  setUp(() {
    safe = SafePoints();
    coordinator = UpdateCoordinator(
      onFailure: (_, __) {},
      onSafePoint: safe.call,
    );
  });

  test('Home is a safe point', () async {
    coordinator.routeChanged('/home');
    await coordinator.check();
    expect(safe.count, 1);
  });

  test('quiz stays unsafe until its session end route', () async {
    coordinator.routeChanged('/quiz/quick/exam');
    await coordinator.check();
    expect(safe.count, 0);
    coordinator.routeChanged('/quiz/debrief/attempt');
    await coordinator.check();
    expect(safe.count, 1);
  });

  test('all completed quiz and mock result routes are safe', () async {
    for (final path in ['/quiz/all/attempt', '/mock/results/attempt']) {
      final points = SafePoints();
      final updates = UpdateCoordinator(
        onFailure: (_, __) {},
        onSafePoint: points.call,
      )..routeChanged(path);
      await updates.check();
      expect(points.count, 1, reason: path);
    }
  });

  test('unsafe routes and overlays are not safe points', () async {
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
    expect(safe.count, 0);
    coordinator
      ..routeChanged('/home')
      ..setOverlay('dialog', visible: true);
    await coordinator.check();
    expect(safe.count, 0);
    coordinator.setOverlay('dialog', visible: false);
    await coordinator.check();
    expect(safe.count, 1);
  });

  test('lesson ending signals a safe point within the reader', () async {
    coordinator.routeChanged('/lesson/one');
    await coordinator.check();
    expect(safe.count, 0);
    coordinator.lessonEnded();
    await coordinator.check();
    expect(safe.count, 1);
  });

  test('reader reentry ends the lesson safe point', () async {
    coordinator
      ..routeChanged('/lesson/one')
      ..lessonEnded()
      ..lessonStarted();
    await coordinator.check();
    expect(safe.count, 0);
  });

  test('concurrent checks share one safe point', () async {
    coordinator.routeChanged('/home');
    await Future.wait([coordinator.check(), coordinator.check()]);
    expect(safe.count, 1);
  });

  test('quiz completion clears on route change', () async {
    coordinator
      ..routeChanged('/quiz/inline/one')
      ..quizEnded();
    await coordinator.check();
    final reached = safe.count;
    coordinator.routeChanged('/quiz/inline/two');
    await coordinator.check();
    expect(safe.count, reached);
  });

  test('a new quiz clears completion', () async {
    coordinator
      ..routeChanged('/quiz/inline/one')
      ..quizStarted();
    await coordinator.check();
    expect(safe.count, 0);
  });

  test('quiz completion does not bypass an input overlay', () async {
    coordinator
      ..routeChanged('/quiz/inline/one')
      ..setOverlay('notes', visible: true)
      ..quizEnded();
    await coordinator.check();
    expect(safe.count, 0);
    coordinator.setOverlay('notes', visible: false);
    await coordinator.check();
    expect(safe.count, 1);
  });

  test('a failing content check is reported', () async {
    final failures = <Object>[];
    coordinator = UpdateCoordinator(
      onFailure: (error, _) => failures.add(error),
      onSafePoint: () async => throw StateError('offline'),
    )..routeChanged('/home');
    await coordinator.check();
    await Future<void>.delayed(Duration.zero);
    expect(failures, hasLength(1));
  });
}

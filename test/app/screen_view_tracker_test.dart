import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/screen_view_tracker.dart';
import 'package:pantas/core/telemetry/gated_telemetry.dart';
import 'package:pantas/core/telemetry/telemetry.dart';

class _Sink implements Telemetry {
  final screens = <String>[];
  final others = <TelemetryEvent>[];

  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async {
    if (event == TelemetryEvent.screenViewed) {
      assertPropertiesAllowed(properties!);
      expect(properties.keys, ['screen']);
      screens.add(properties['screen']! as String);
    } else {
      others.add(event);
    }
  }

  @override
  Future<void> recordError(Object error, StackTrace stack) async {}

  @override
  Future<void> setEnabled({required bool enabled}) async {}

  @override
  Future<void> setUserIdentifier(String identifier) async {}
}

GoRouter _router() => GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
          builder: (context, state, child) => child,
          routes: [
            GoRoute(path: '/home', builder: (_, __) => const Text('home')),
            GoRoute(path: '/study', builder: (_, __) => const Text('study')),
            GoRoute(
              path: '/lesson/:lessonId',
              builder: (_, __) => const Text('lesson'),
            ),
          ],
        ),
        GoRoute(path: '/startup', builder: (_, __) => const Text('startup')),
      ],
    );

void main() {
  group('the tracker', () {
    test('logs a screen once however often the address repeats', () {
      final sink = _Sink();
      ScreenViewTracker(() => sink)
        ..locationChanged('/home')
        ..locationChanged('/home')
        ..locationChanged('/study?x=1')
        ..locationChanged('/study')
        ..locationChanged('/home');
      expect(sink.screens, ['home', 'study', 'home']);
    });

    test('two lessons in a row are one screen, not two', () {
      final sink = _Sink();
      ScreenViewTracker(() => sink)
        ..locationChanged('/lesson/a')
        ..locationChanged('/lesson/b');
      expect(sink.screens, ['lesson']);
    });

    test('the startup screen and an empty address are not recorded', () {
      final sink = _Sink();
      ScreenViewTracker(() => sink)
        ..locationChanged('')
        ..locationChanged('/startup')
        ..locationChanged('/home');
      expect(sink.screens, ['home']);
    });

    test('an unknown address is other', () {
      final sink = _Sink();
      ScreenViewTracker(() => sink).locationChanged('/who-knows/123');
      expect(sink.screens, ['other']);
    });

    test('a closed gate lets nothing through', () {
      final sink = _Sink();
      ScreenViewTracker(() => GatedTelemetry(sink, consent: false))
          .locationChanged('/home');
      expect(sink.screens, isEmpty);
    });

    test('a telemetry failure never reaches the caller', () {
      ScreenViewTracker(() => throw StateError('no sink'))
          .locationChanged('/home');
    });
  });

  group('attached to a router', () {
    testWidgets('logs the first screen, a go and a push, once each',
        (tester) async {
      final sink = _Sink();
      final router = _router();
      final detach = attachScreenViewTracker(router, () => sink);
      addTearDown(() {
        detach();
        router.dispose();
      });
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(sink.screens, ['home']);

      router.go('/study');
      await tester.pumpAndSettle();
      unawaited(router.push('/lesson/abc'));
      await tester.pumpAndSettle();
      expect(sink.screens, ['home', 'study', 'lesson']);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(sink.screens, ['home', 'study', 'lesson']);
    });

    testWidgets('stops logging after detach', (tester) async {
      final sink = _Sink();
      final router = _router();
      final detach = attachScreenViewTracker(router, () => sink);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      detach();
      router.go('/study');
      await tester.pumpAndSettle();
      expect(sink.screens, ['home']);
    });
  });
}

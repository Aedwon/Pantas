import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/bootstrap.dart';
import 'package:pantas/app/firebase_bootstrap.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/core/error/app_error_recovery.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

void main() {
  for (final stage in ['storage', 'content install']) {
    testWidgets(
        'bootstrap $stage failure shows recovery and retries in the same zone',
        (tester) async {
      final originalError = FlutterError.onError;
      final originalPlatform = PlatformDispatcher.instance.onError;
      final originalBuilder = ErrorWidget.builder;
      try {
        var attempts = 0;
        final zones = <Object>[];
        await bootstrap(
          Flavor.dev,
          initialize: (flavor, onContainerReady) async {
            attempts++;
            zones.add(Zone.current);
            if (attempts < 3) throw StateError('private $stage failure');
            runApp(
              MaterialApp(
                theme: buildLightTheme(),
                home: const Scaffold(body: Text('started')),
              ),
            );
          },
        );
        await tester.pump();
        await tester.pumpAndSettle();
        expect(find.text('Something went wrong.'), findsOneWidget);
        expect(find.textContaining('private'), findsNothing);
        await tester.tap(find.text('Try Again'));
        await tester.pump();
        await tester.pumpAndSettle();
        expect(find.text('Something went wrong.'), findsOneWidget);
        await tester.tap(find.text('Try Again'));
        await tester.pump();
        await tester.pumpAndSettle();
        expect(attempts, 3);
        expect(find.text('started'), findsOneWidget);
        expect(zones.toSet(), hasLength(1));
      } finally {
        FlutterError.onError = originalError;
        PlatformDispatcher.instance.onError = originalPlatform;
        ErrorWidget.builder = originalBuilder;
      }
    });
  }
  for (final nested in [false, true]) {
    testWidgets(
        'release error retry recreates the root router '
        'without restarting storage, nested=$nested', (tester) async {
      final originalError = FlutterError.onError;
      final originalPlatform = PlatformDispatcher.instance.onError;
      final originalBuilder = ErrorWidget.builder;
      final saved = StateProvider<int>((_) => 0);
      var starts = 0;
      var routers = 0;
      final container = ProviderContainer(
        overrides: [
          routerProvider.overrideWith((ref) {
            routers++;
            final router = GoRouter(
              initialLocation: '/home',
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (_, __) => const Scaffold(body: Text('root')),
                ),
                GoRoute(
                  path: '/broken',
                  builder: (_, __) => nested
                      ? Scaffold(
                          body: Column(
                            children: [
                              const Text('partial page'),
                              Builder(
                                builder: (_) =>
                                    throw StateError('private runtime failure'),
                              ),
                            ],
                          ),
                        )
                      : Builder(
                          builder: (_) =>
                              throw StateError('private runtime failure'),
                        ),
                ),
              ],
            );
            ref.onDispose(router.dispose);
            return router;
          }),
        ],
      );
      try {
        await bootstrap(
          Flavor.dev,
          releaseMode: true,
          initialize: (flavor, onContainerReady) async {
            starts++;
            onContainerReady(container);
            container.read(saved.notifier).state = 17;
            runApp(
              UncontrolledProviderScope(
                container: container,
                child: Consumer(
                  builder: (context, ref, _) => MaterialApp.router(
                    theme: buildLightTheme(),
                    routerConfig: ref.watch(routerProvider),
                    builder: (context, child) =>
                        AppErrorRecovery(child: child!),
                  ),
                ),
              ),
            );
          },
        );
        await tester.pump();
        await tester.pumpAndSettle();
        container.read(routerProvider).go('/broken');
        await tester.pump();
        await tester.pumpAndSettle();
        expect(find.text('Something went wrong.'), findsOneWidget);
        expect(find.text('partial page'), findsNothing);
        await tester.tap(find.text('Try Again'));
        await tester.pump();
        await tester.pumpAndSettle();
        expect(find.text('root'), findsOneWidget);
        expect(starts, 1);
        expect(routers, 2);
        expect(container.read(saved), 17);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
        FlutterError.onError = originalError;
        PlatformDispatcher.instance.onError = originalPlatform;
        ErrorWidget.builder = originalBuilder;
      }
    });
  }
  testWidgets('unavailable Firebase becomes startup recovery and then retries',
      (tester) async {
    final originalError = FlutterError.onError;
    final originalPlatform = PlatformDispatcher.instance.onError;
    final originalBuilder = ErrorWidget.builder;
    final firebase = _FirebaseAdapter();
    try {
      await bootstrap(
        Flavor.dev,
        initialize: (flavor, _) async {
          final result =
              await bootstrapFirebaseForStartup(flavor, adapter: firebase);

          runApp(
            MaterialApp(
              theme: buildLightTheme(),
              home: Scaffold(
                body: Text(
                  result == FirebaseBootstrapResult.configured
                      ? 'Firebase started'
                      : 'unavailable reached app',
                ),
              ),
            ),
          );
        },
      );
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Something went wrong.'), findsOneWidget);
      expect(find.textContaining('private Firebase'), findsNothing);
      await tester.tap(find.text('Try Again'));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Firebase started'), findsOneWidget);
      expect(firebase.calls, 2);
    } finally {
      FlutterError.onError = originalError;
      PlatformDispatcher.instance.onError = originalPlatform;
      ErrorWidget.builder = originalBuilder;
    }
  });
}

class _FirebaseAdapter implements FirebaseBootAdapter {
  int calls = 0;
  @override
  Future<void> initialize(FirebaseOptions options) async {
    calls++;
    if (calls == 1) throw StateError('private Firebase setup failure');
  }
}

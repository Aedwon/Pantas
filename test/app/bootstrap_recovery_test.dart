import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/bootstrap.dart';
import 'package:pantas/app/content_access_bridge.dart';
import 'package:pantas/app/firebase_bootstrap.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/remote/content_mirror.dart';
import 'package:pantas/core/error/app_error_recovery.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/sync/custom_track/custom_track_projection.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

import '../helpers/in_memory_database.dart';

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
  group('web start puts stored custom exams back', () {
    const examId = 'exam_custom_6f1d0a52-3c1b-4c0e-8a52-0f6a3d2c9b11';

    // A reload empties the in-memory content database. The study database
    // keeps the track, and no retry marker is left to bring it back.
    Future<
        ({
          AppDatabase db,
          ContentDatabase content,
          _Mirror mirror,
          ProviderContainer container,
        })> start({
      Future<void> Function(ContentDatabase content)? onMirrorStart,
      CustomTrackProjection? projection,
    }) async {
      final db = inMemoryDatabase();
      final content = inMemoryContentDatabase();
      addTearDown(db.close);
      addTearDown(content.close);
      await db.into(db.customTrackMetaLocal).insert(
            CustomTrackMetaLocalCompanion.insert(
              examId: examId,
              name: 'Barangay exam',
            ),
          );
      final mirror = _Mirror(content, onMirrorStart);
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
          contentMirrorProvider.overrideWithValue(mirror),
          contentAccessBridgeProvider.overrideWith((ref) {}),
          if (projection != null)
            customTrackRepositoryProvider.overrideWithValue(
              CustomTrackRepository(db, content, projection: projection),
            ),
        ],
      );
      addTearDown(container.dispose);
      return (db: db, content: content, mirror: mirror, container: container);
    }

    test('after the content mirror starts, before the first page', () async {
      final setup = await start();

      final failure = await startWebContent(setup.container);

      expect(failure, isNull);
      expect(setup.mirror.listedAtStart, isEmpty);
      final exams = await ContentRepository(setup.content).listExams();
      expect(exams.map((e) => e.id), [examId]);
      expect(exams.single.name, 'Barangay exam');
      expect(exams.single.isCustom, isTrue);
    });

    test('a content mirror that fails does not keep the track away', () async {
      final setup = await start(
        onMirrorStart: (_) async => throw StateError('offline'),
      );

      final failure = await startWebContent(setup.container);

      expect(failure, isNull);
      expect(
        (await ContentRepository(setup.content).listExams()).map((e) => e.id),
        [examId],
      );
    });

    test('a projection that fails does not stop startup and is handed back',
        () async {
      final setup = await start(projection: _FailingProjection());

      final failure = await startWebContent(setup.container);

      expect(failure, isNotNull);
      expect(failure!.$1, isA<StateError>());
      expect(setup.mirror.started, isTrue);
      expect(await ContentRepository(setup.content).listExams(), isEmpty);
    });
  });
}

class _Mirror implements ContentMirror {
  _Mirror(this._content, this._onStart);
  final ContentDatabase _content;
  final Future<void> Function(ContentDatabase content)? _onStart;
  bool started = false;
  List<String> listedAtStart = const [];

  @override
  Future<void> start() async {
    started = true;
    listedAtStart = [
      for (final exam in await ContentRepository(_content).listExams()) exam.id,
    ];
    await _onStart?.call(_content);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FailingProjection implements CustomTrackProjection {
  @override
  Future<void> upsert({required String examId, required String name}) =>
      Future.error(StateError('projection failed'));

  @override
  Future<void> delete(String examId) => Future.error(StateError('x'));
}

class _FirebaseAdapter implements FirebaseBootAdapter {
  int calls = 0;
  @override
  Future<void> initialize(FirebaseOptions options) async {
    calls++;
    if (calls == 1) throw StateError('private Firebase setup failure');
  }
}

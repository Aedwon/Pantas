import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/deferred_route.dart';
import 'package:pantas/app/routes/settings_routes_native.dart' as native;
import 'package:pantas/app/routes/settings_routes_web.dart' as web;
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/onboarding/presentation/steps/custom_track_name_step.dart';
import 'package:pantas/features/onboarding/presentation/steps/custom_track_subjects_step.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/delete_account_page.dart';

import '../helpers/in_memory_database.dart';

void main() {
  test('web declares the same paths and redirects as native', () {
    final ref = _RouteRef();
    final original = native.settingsRoutes(ref).cast<GoRoute>();
    final deferred = web.settingsRoutes(ref).cast<GoRoute>();
    expect(
      deferred.map((route) => route.path),
      original.map((route) => route.path),
    );
    expect(
      deferred
          .where((route) => route.redirect != null)
          .map((route) => route.path),
      original
          .where((route) => route.redirect != null)
          .map((route) => route.path),
    );
  });

  testWidgets(
      'web account deep link loads and Back returns to the previous page',
      (tester) async {
    final provider = Provider(
      (ref) => GoRouter(
        initialLocation: '/before',
        routes: [
          GoRoute(
            path: '/before',
            builder: (_, __) => const Text('Previous page'),
          ),
          ...web.settingsRoutes(ref),
        ],
      ),
    );
    final container = ProviderContainer(
      overrides: [
        entitlementProvider.overrideWith(
          (_) => Stream.value(const Entitlement.free()),
        ),
        isAnonymousProvider.overrideWith((_) async => false),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(provider);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: buildLightTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final pushed = router.push<void>('/settings/account/delete?source=link');
    await tester.pumpAndSettle();
    expect(find.byType(DeferredRoute), findsOneWidget);
    expect(find.byType(DeleteAccountPage), findsOneWidget);
    expect(
      GoRouterState.of(tester.element(find.byType(DeleteAccountPage)))
          .uri
          .queryParameters['source'],
      'link',
    );
    router.pop();
    await tester.pumpAndSettle();
    await pushed;
    expect(find.text('Previous page'), findsOneWidget);
  });

  group('the steps of your own exam, opened from Settings on the web', () {
    Future<GoRouter> open(
      WidgetTester tester, {
      List<Override> overrides = const [],
    }) async {
      final provider = Provider(
        (ref) => GoRouter(
          initialLocation: '/before',
          routes: [
            GoRoute(
              path: '/before',
              builder: (_, __) => const Text('Previous page'),
            ),
            // The exam change page needs a database of its own to build, and
            // is not what these tests look at, so a plain page stands in.
            GoRoute(
              path: '/settings/exam/change',
              builder: (_, __) => const Text('Change exam page'),
            ),
            ...web.settingsRoutes(ref).where(
                  (route) =>
                      route is! GoRoute ||
                      route.path != '/settings/exam/change',
                ),
          ],
        ),
      );
      final container = ProviderContainer(overrides: overrides);
      addTearDown(container.dispose);
      final router = container.read(provider);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: buildLightTheme(),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      return router;
    }

    testWidgets('the name step loads as a deferred Settings page',
        (tester) async {
      final router = await open(tester);
      unawaited(router.push<String>('/settings/exam/custom/name'));
      await tester.pumpAndSettle();
      expect(find.byType(DeferredRoute), findsOneWidget);
      expect(find.byType(CustomTrackNameStep), findsOneWidget);
      expect(find.text('What are you studying for?'), findsOneWidget);
    });

    testWidgets(
        'the subjects step makes the exam, keeps onboarding complete and '
        'gives its id back to the page that opened it', (tester) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final contentDb = openTestContentDatabase();
      await seedContentExam(contentDb, examId: 'exam_cse_pro');
      await seedContentSubject(
        contentDb,
        subjectId: 's1',
        examId: 'exam_cse_pro',
      );
      await seedContentTopic(contentDb, topicId: 't1', subjectId: 's1');
      final prefs = AppPreferencesRepository(db);
      await prefs.setSelectedExamId('exam_cse_pro');
      await prefs.setCompletedOnboarding(value: true);
      final router = await open(
        tester,
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          customTrackRepositoryProvider.overrideWithValue(
            CustomTrackRepository(db, contentDb),
          ),
          corpusSubjectsWithTopicsProvider.overrideWith(
            (ref) async => <String, Set<TopicId>>{
              'Mathematics': {'t1'},
            },
          ),
        ],
      );
      final made = router.push<String>(
        '/settings/exam/custom/subjects',
        extra: 'My Exam',
      );
      await tester.pumpAndSettle();
      final step = tester.widget<CustomTrackSubjectsStep>(
        find.byType(CustomTrackSubjectsStep),
      );
      expect(step.fromSettings, isTrue);
      expect(step.name, 'My Exam');
      // The typed name travels in the route's extra, never in the address.
      final address = GoRouterState.of(
        tester.element(find.byType(CustomTrackSubjectsStep)),
      ).uri.toString();
      expect(address, '/settings/exam/custom/subjects');
      await tester.tap(find.text('Mathematics'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      final id = await made;
      expect(id, startsWith('exam_custom_'));
      expect(find.text('Previous page'), findsOneWidget);
      expect(await prefs.hasCompletedOnboarding(), isTrue);
      // The step leaves the choice of exam to the picker's own save.
      expect(await prefs.selectedExamId(), 'exam_cse_pro');
      expect(await CustomTrackRepository(db, contentDb).name(id!), 'My Exam');
    });

    testWidgets(
        'the subjects step with no name, as after a reload or a typed '
        'address, goes to the exam change page and shows no step',
        (tester) async {
      final router = await open(tester);
      unawaited(router.push<String>('/settings/exam/custom/subjects'));
      await tester.pumpAndSettle();
      expect(find.byType(CustomTrackSubjectsStep), findsNothing);
      expect(find.text('Change exam page'), findsOneWidget);
      // A name in the address is not read either.
      unawaited(
        router.push<String>('/settings/exam/custom/subjects?name=My%20Exam'),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CustomTrackSubjectsStep), findsNothing);
    });
  });
}

class _RouteRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

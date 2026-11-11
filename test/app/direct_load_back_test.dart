import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/mock_routes.dart';
import 'package:pantas/app/routes/settings_routes.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/legal/application/legal_providers.dart';
import 'package:pantas/features/mock_exam/application/mock_results_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/presentation/pages/custom_mock_setup_page.dart';
import 'package:pantas/features/mock_exam/presentation/pages/custom_mock_setup_route.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/settings/application/carry_over_providers.dart';
import 'package:pantas/features/settings/settings.dart';

import '../helpers/in_memory_database.dart';
import '../helpers/pump_app.dart';

/// A page opened directly, or after a reload, is the first in its Navigator.
/// Back from it must still go somewhere. Each page here is opened that way,
/// and again pushed from another page, where Back must return to that page.

final _settingsRoutes = Provider(settingsRoutes);
final _mockRoutes = Provider(mockRoutes);

/// The real [routes] with the pages in [stubs] swapped for a bare marker, so
/// a test sees where Back lands without building that page.
List<RouteBase> _withStubs(List<RouteBase> routes, List<String> stubs) => [
      for (final route in routes)
        if (!(route is GoRoute && stubs.contains(route.path))) route,
      for (final path in stubs)
        GoRoute(
          path: path,
          builder: (context, _) => Scaffold(body: Text('stub $path')),
        ),
    ];

void main() {
  late ProviderContainer container;

  /// Opens [location] as the first page, or opens it on top of `/elsewhere`.
  Future<GoRouter> open(
    WidgetTester tester, {
    required Provider<List<RouteBase>> routes,
    required String location,
    required List<String> stubs,
    required List<Override> overrides,
    bool pushed = false,
  }) async {
    container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: pushed ? '/elsewhere' : location,
      routes: [
        ..._withStubs(container.read(routes), stubs),
        if (pushed)
          GoRoute(
            path: '/elsewhere',
            builder: (_, __) => const Scaffold(body: Text('stub /elsewhere')),
          ),
      ],
    );
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
    if (pushed) {
      unawaited(router.push<Object?>(location));
      await tester.pumpAndSettle();
    }
    return router;
  }

  String pathOf(GoRouter router) =>
      router.routerDelegate.currentConfiguration.uri.path;

  group('a settings page', () {
    late List<Override> overrides;
    setUp(() {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      overrides = [appDatabaseProvider.overrideWithValue(db)];
    });

    testWidgets('opened directly goes back to Settings', (tester) async {
      final router = await open(
        tester,
        routes: _settingsRoutes,
        location: '/settings/practice',
        stubs: ['/settings'],
        overrides: overrides,
      );
      expect(router.canPop(), isFalse);
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(pathOf(router), '/settings');
      expect(find.text('stub /settings'), findsOneWidget);
    });

    testWidgets('pushed from another page goes back to that page',
        (tester) async {
      final router = await open(
        tester,
        routes: _settingsRoutes,
        location: '/settings/practice',
        stubs: ['/settings'],
        overrides: overrides,
        pushed: true,
      );
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(pathOf(router), '/elsewhere');
    });
  });

  group('the account name page', () {
    late List<Override> overrides;
    setUp(() {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      overrides = [appDatabaseProvider.overrideWithValue(db)];
    });

    testWidgets('saves, then goes to Account when opened directly',
        (tester) async {
      final router = await open(
        tester,
        routes: _settingsRoutes,
        location: '/settings/account/name',
        stubs: ['/settings/account'],
        overrides: overrides,
      );
      await tester.enterText(find.byType(TextField), 'Ana');
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();
      expect(pathOf(router), '/settings/account');
      expect(
        (await container.read(settingsRepositoryProvider).readUserSettings())
            .name,
        'Ana',
      );
    });

    testWidgets('saves, then returns to the page it was pushed from',
        (tester) async {
      final router = await open(
        tester,
        routes: _settingsRoutes,
        location: '/settings/account/name',
        stubs: ['/settings/account'],
        overrides: overrides,
        pushed: true,
      );
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();
      expect(pathOf(router), '/elsewhere');
    });
  });

  group('the exam change page', () {
    final upcat = buildExam(
      id: 'exam_upcat',
      code: 'UPCAT',
      shortName: 'UPCAT',
      name: 'UP College Admissions Test',
    );
    final dost = buildExam(
      id: 'exam_dost',
      code: 'DOST',
      shortName: 'DOST',
      name: 'DOST Scholarship Exam',
    );
    late List<Override> overrides;
    setUp(() {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      overrides = [
        appDatabaseProvider.overrideWithValue(db),
        activeExamFocusProvider
            .overrideWith((ref) async => ActiveExamFocus.selected(upcat)),
        examPickerCatalogProvider.overrideWith(
          (ref) => Stream.value([
            for (final exam in [upcat, dost])
              ExamCatalogEntry(
                id: exam.id,
                name: exam.name,
                shortName: exam.shortName,
                priceTier: 'Student',
                group: 'College entrance',
                comingSoon: false,
                publishedSittings: const [],
                hasContent: true,
              ),
          ]),
        ),
        examListProvider.overrideWith((ref) async => [upcat, dost]),
        carryableCountProvider.overrideWith((ref, id) async => 0),
      ];
    });

    // Direct loads exist only on web. Setting the picker's onBack turns off
    // predictive back, so native keeps the picker's own handling.
    Future<bool> pickerCanPop(WidgetTester tester, {required bool web}) async {
      debugWebPlatformOverride = web;
      addTearDown(() => debugWebPlatformOverride = null);
      await open(
        tester,
        routes: _settingsRoutes,
        location: '/settings/exam/change',
        stubs: ['/settings/exam'],
        overrides: overrides,
      );
      final scope = tester.widget<PopScope<void>>(
        find
            .descendant(
              of: find.byType(ExamPickerScreen),
              matching: find.byType(PopScope<void>),
            )
            .first,
      );
      return scope.canPop;
    }

    testWidgets('on native the picker keeps its own back handling',
        (tester) async {
      expect(await pickerCanPop(tester, web: false), isTrue);
    });

    testWidgets('on web the picker leaves through the helper', (tester) async {
      expect(await pickerCanPop(tester, web: true), isFalse);
    });

    testWidgets('Back goes to the exam page when opened directly',
        (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      final router = await open(
        tester,
        routes: _settingsRoutes,
        location: '/settings/exam/change',
        stubs: ['/settings/exam'],
        overrides: overrides,
      );
      await tester.tap(find.text('Your exam'));
      await tester.pumpAndSettle();
      expect(pathOf(router), '/settings/exam');
    });

    testWidgets('Back returns to the page it was pushed from', (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      final router = await open(
        tester,
        routes: _settingsRoutes,
        location: '/settings/exam/change',
        stubs: ['/settings/exam'],
        overrides: overrides,
        pushed: true,
      );
      await tester.tap(find.text('Your exam'));
      await tester.pumpAndSettle();
      expect(pathOf(router), '/elsewhere');
    });

    testWidgets('choosing an exam goes to the exam page when opened directly',
        (tester) async {
      final router = await open(
        tester,
        routes: _settingsRoutes,
        location: '/settings/exam/change',
        stubs: ['/settings/exam'],
        overrides: overrides,
      );
      await tester.tap(find.text('DOST'));
      await tester.pumpAndSettle();
      expect(pathOf(router), '/settings/exam');
      expect(
        await container.read(appPreferencesRepositoryProvider).selectedExamId(),
        'exam_dost',
      );
    });
  });

  group('a legal page', () {
    Future<GoRouter> openLegal(
      WidgetTester tester, {
      required bool onboarding,
      bool pushed = false,
    }) =>
        open(
          tester,
          routes: _settingsRoutes,
          location: '/legal/terms',
          stubs: ['/settings/about', '/onboarding'],
          overrides: [
            guardianGateProvider.overrideWith(
              (ref) async => GuardianGate.notRequired,
            ),
            legalInOnboardingProvider.overrideWithValue(onboarding),
          ],
          pushed: pushed,
        );

    testWidgets('opened directly by a finished student goes to About',
        (tester) async {
      final router = await openLegal(tester, onboarding: false);
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();
      expect(pathOf(router), '/settings/about');
    });

    testWidgets('opened directly before onboarding goes to onboarding',
        (tester) async {
      final router = await openLegal(tester, onboarding: true);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(pathOf(router), '/onboarding');
    });

    testWidgets('pushed from a page returns to it', (tester) async {
      final router = await openLegal(tester, onboarding: true, pushed: true);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(pathOf(router), '/elsewhere');
    });
  });

  group('the mock pages', () {
    final attempt = MockAttempt(
      id: 'm1',
      userId: 'local',
      examId: 'exam_upcat',
      blueprintId: 'b',
      blueprintName: 'UPCAT simulation',
      durationMinutes: 60,
      status: MockAttemptStatus.completed,
      strictMode: false,
      sampledQuestionsJson: '[]',
      elapsedSeconds: 100,
      accumulatedPausedSeconds: 0,
      pausedAtLastFlush: false,
      answersJson: '{}',
      flagsJson: '[]',
      currentIndex: 0,
      startedAt: DateTime.utc(2026, 10, 21),
      lastFlushedAt: DateTime.utc(2026, 10, 21),
      updatedAt: DateTime.utc(2026, 10, 21),
      submittedAt: DateTime.utc(2026, 10, 21),
    );
    const results = MockResults(
      scoreRaw: 1,
      scoreTotal: 1,
      percent: 100,
      sections: [],
      topWeak: [],
      totalTimeSeconds: 100,
      wasStrict: false,
    );
    List<Override> resultsOverrides({required bool found}) => [
          mockResultsProvider.overrideWith(
            (ref, id) async => found
                ? MockHistoryEntry(attempt: attempt, results: results)
                : null,
          ),
          mockReviewAccessProvider.overrideWith(
            (ref, id) async => const MockReviewAccess(canReview: false),
          ),
          mockEarlierResultsProvider.overrideWith((ref, id) async => []),
          proForActiveExamProvider.overrideWith((ref) async => false),
          entitlementProvider
              .overrideWith((ref) => Stream.value(const Entitlement.free())),
        ];

    testWidgets('Done on the results goes to the Quiz tab when opened directly',
        (tester) async {
      final router = await open(
        tester,
        routes: _mockRoutes,
        location: '/mock/results/m1',
        stubs: ['/quiz'],
        overrides: resultsOverrides(found: true),
      );
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(pathOf(router), '/quiz');
    });

    testWidgets('Done on the results returns to the page it was pushed from',
        (tester) async {
      final router = await open(
        tester,
        routes: _mockRoutes,
        location: '/mock/results/m1',
        stubs: ['/quiz'],
        overrides: resultsOverrides(found: true),
        pushed: true,
      );
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(pathOf(router), '/elsewhere');
    });

    testWidgets('results that are not available have a Back', (tester) async {
      final router = await open(
        tester,
        routes: _mockRoutes,
        location: '/mock/results/gone',
        stubs: ['/quiz'],
        overrides: resultsOverrides(found: false),
      );
      expect(find.text('Results not available'), findsOneWidget);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(pathOf(router), '/quiz');
    });

    group('custom setup', () {
      const subjects = [
        Subject(
          id: 'math',
          examId: 'exam_custom_1',
          name: 'Mathematics',
          ordering: 0,
        ),
      ];
      late List<Override> overrides;
      setUp(() {
        final db = inMemoryDatabase();
        addTearDown(db.close);
        overrides = [
          appDatabaseProvider.overrideWithValue(db),
          customMockSetupDataProvider.overrideWith(
            (ref) async => const CustomMockSetupData(
              examId: 'exam_custom_1',
              subjects: subjects,
              topicsBySubject: {},
              availableQuestions: 240,
            ),
          ),
        ];
      });

      testWidgets('Back goes to the Quiz tab when opened directly',
          (tester) async {
        final router = await open(
          tester,
          routes: _mockRoutes,
          location: '/quiz/mock/custom-setup',
          stubs: ['/quiz'],
          overrides: overrides,
        );
        await tester.tap(find.text('Quiz'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(pathOf(router), '/quiz');
      });

      testWidgets('Save goes to the Quiz tab when opened directly',
          (tester) async {
        final router = await open(
          tester,
          routes: _mockRoutes,
          location: '/quiz/mock/custom-setup',
          stubs: ['/quiz'],
          overrides: overrides,
        );
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(pathOf(router), '/quiz');
      });

      testWidgets('Back returns to the page it was pushed from',
          (tester) async {
        final router = await open(
          tester,
          routes: _mockRoutes,
          location: '/quiz/mock/custom-setup',
          stubs: ['/quiz'],
          overrides: overrides,
          pushed: true,
        );
        await tester.tap(find.text('Quiz'));
        await tester.pumpAndSettle();
        expect(pathOf(router), '/elsewhere');
      });
    });
  });
}

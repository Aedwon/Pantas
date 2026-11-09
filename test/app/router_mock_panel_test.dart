import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/home/application/study_delivery.dart';
import 'package:pantas/features/mock_exam/application/server_mock_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/data/custom_blueprint_repository.dart';
import 'package:pantas/features/mock_exam/data/server_mock_api.dart';
import 'package:pantas/features/mock_exam/domain/custom_blueprint.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_route.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_start_route.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/quiz/presentation/pages/flagged_list_page.dart';

import '../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    await seedContentExam(
      contentDb,
      examId: 'upcat',
      code: 'UPCAT',
      name: 'UPCAT',
      shortName: 'UPCAT',
    );
  });

  tearDown(() => db.close());

  Future<void> pumpApp(
    WidgetTester tester, {
    AuthUser? currentUser,
    Entitlement entitlement = const Entitlement.free(),
    bool proForExam = false,
    List<Override> extra = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...extra,
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          entitlementProvider.overrideWith(
            (_) => Stream.value(entitlement),
          ),
          proForActiveExamProvider.overrideWith((_) async => proForExam),
          currentUserProvider.overrideWith((_) async => currentUser),
        ],
        child: const App(flavor: Flavor.dev),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> seedActiveMock() {
    return MockAttemptRepo(db).insertStart(
      MockAttemptStart(
        id: 'mock_local',
        userId: 'local',
        examId: 'upcat',
        blueprintId: 'bp_upcat',
        blueprintName: 'UPCAT Practice',
        durationMinutes: 30,
        strictMode: false,
        sampledQuestionsJson:
            '[{"sectionId":"s1","name":"Part 1","questionIds":["q1"]}]',
        startedAt: DateTime.utc(2026, 9, 4),
      ),
    );
  }

  const signedInUser = AuthUser(
    uid: 'firebase_account_2',
    email: 'student@example.com',
    displayName: 'Student',
  );

  testWidgets(
      'account cooldown without this exam history has no dead results action',
      (tester) async {
    await seedContentExam(
      contentDb,
      examId: 'exam_cse_sub',
      code: 'CSE',
      name: 'CSE Subprofessional',
      shortName: 'CSE Subprofessional',
    );
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('exam_cse_sub');
    await pumpApp(
      tester,
      currentUser: signedInUser,
      extra: [
        mockUsesServerProvider.overrideWithValue(true),
        serverMockIdentityProvider.overrideWithValue('a'),
        serverMockActorProvider.overrideWithValue(() => 'a'),
        serverMockApiProvider.overrideWithValue(
          ServerMockApi(
            (_, __) async => {
              'examId': 'exam_cse_sub',
              'serverNow': 2000,
              'nextEligibleAt': 2592002000,
              'status': 'cooldown',
              'proCovered': false,
              'lastMockId': null,
            },
          ),
        ),
      ],
    );
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    await tester.tap(find.text('Quiz'));
    await tester.pumpAndSettle();
    expect(find.byType(MockCard), findsOneWidget);
    expect(find.text('View Last Results'), findsNothing);
  });
  testWidgets('Quiz tab renders MockCard', (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('upcat');
    await pumpApp(tester);

    // Navigate to Quiz tab
    await tester.tap(find.text('Quiz'));
    await tester.pumpAndSettle();

    expect(find.byType(MockCard), findsOneWidget);
  });

  testWidgets('signed-in account sees the device-local mock attempt',
      (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('upcat');
    await seedActiveMock();
    await pumpApp(
      tester,
      currentUser: signedInUser,
    );

    await tester.tap(find.text('Quiz'));
    await tester.pumpAndSettle();

    expect(find.text('Resume'), findsOneWidget);
  });

  testWidgets('Resume opens the active mock attempt route', (tester) async {
    expect(
      collectRoutePaths(),
      contains('/quiz/mock/resume/:attemptId'),
    );
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('upcat');
    await seedActiveMock();
    await pumpApp(tester, currentUser: signedInUser);

    await tester.tap(find.text('Quiz'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Resume'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();

    final route = tester.widget<MockStartRoute>(find.byType(MockStartRoute));
    expect(route.resumeAttemptId, 'mock_local');
  });

  group('a custom exam on the web', () {
    const customId = 'exam_custom_6f1d0a52-3c1b-4c0e-8a52-0f6a3d2c9b11';

    late String serverStatus;
    late int repairs;
    late int availabilityReads;
    late Completer<void> settled;
    late String? lastMockId;

    Future<void> storePaper() => CustomBlueprintRepository(db).save(
          const CustomBlueprint(
            examId: customId,
            totalQuestions: 60,
            totalMinutes: 90,
          ),
          topicsBySubject: const {
            'subj_math': ['topic_upcat_algebra'],
          },
          now: DateTime.utc(2026, 11, 5),
        );

    Future<void> openQuiz(
      WidgetTester tester, {
      bool paper = true,
    }) async {
      serverStatus = 'available';
      repairs = 0;
      availabilityReads = 0;
      lastMockId = null;
      settled = Completer<void>();
      await seedContentExam(
        contentDb,
        examId: customId,
        code: 'MINE',
        name: 'PUP CET',
        shortName: 'PUP CET',
        isCustom: true,
      );
      await AppPreferencesRepository(db).setPassedAgeGate(value: true);
      await AppPreferencesRepository(db).setSelectedExamId(customId);
      if (paper) await storePaper();
    }

    Future<void> pump(WidgetTester tester, {bool web = true}) async {
      await pumpApp(
        tester,
        currentUser: signedInUser,
        extra: [
          mockUsesServerProvider.overrideWithValue(web),
          serverMockIdentityProvider.overrideWithValue('a'),
          serverMockActorProvider.overrideWithValue(() => 'a'),
          studySettingsCaptureProvider.overrideWith(
            (ref) => ({String? examId}) async => StudySettingsPublication(
                  () async {
                    repairs++;
                    expect(examId, customId);
                  },
                  settled: settled.future,
                ),
          ),
          serverMockApiProvider.overrideWithValue(
            ServerMockApi((name, data) async {
              availabilityReads++;
              return {
                'examId': customId,
                'serverNow': 2000,
                'nextEligibleAt':
                    serverStatus == 'cooldown' ? 2592002000 : null,
                'status': serverStatus,
                'proCovered': false,
                'lastMockId': lastMockId,
                if (serverStatus == 'in-progress')
                  'open': {
                    'mockId': 'mock0123456789',
                    'examId': customId,
                    'paused': false,
                  },
              };
            }),
          ),
        ],
      );
      addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
      await tester.tap(find.text('Quiz'));
      await tester.pumpAndSettle();
    }

    MockCardState panel(WidgetTester tester) =>
        tester.widget<MockCard>(find.byType(MockCard)).model.state;

    Future<void> reread(WidgetTester tester) async {
      ProviderScope.containerOf(tester.element(find.byType(MockCard)))
          .invalidate(serverMockAvailabilityProvider(customId));
      await tester.pumpAndSettle();
    }

    testWidgets('no paper on the server and none here: Set One Up',
        (tester) async {
      await openQuiz(tester, paper: false);
      serverStatus = 'no-blueprint';
      await pump(tester);
      expect(panel(tester), MockCardState.customUnset);
      expect(repairs, 0);
    });

    testWidgets(
        'no paper on the server but one here: it looks ready, the settings go '
        'up once, and the server is asked again', (tester) async {
      await openQuiz(tester);
      serverStatus = 'no-blueprint';
      await pump(tester);

      // Until the send finishes the saved paper is not shown as lost.
      expect(panel(tester), MockCardState.customReady);
      expect(find.textContaining('Change the'), findsOneWidget);
      expect(repairs, 1);
      final reads = availabilityReads;

      serverStatus = 'available';
      settled.complete();
      await tester.pumpAndSettle();
      expect(availabilityReads, greaterThan(reads));
      expect(panel(tester), MockCardState.customReady);
      expect(repairs, 1);
    });

    testWidgets('the repair never runs a second time', (tester) async {
      await openQuiz(tester);
      serverStatus = 'no-blueprint';
      await pump(tester);
      settled.complete();
      await tester.pumpAndSettle();
      // The server still has no paper after the send. Reading again, or
      // leaving and coming back, does not send again.
      await reread(tester);
      await reread(tester);
      expect(repairs, 1);
      expect(panel(tester), MockCardState.customReady);
    });

    testWidgets('a failed repair keeps the saved paper in view and stops',
        (tester) async {
      await openQuiz(tester);
      serverStatus = 'no-blueprint';
      await pump(tester);
      settled.completeError(StateError('offline'));
      await tester.pumpAndSettle();
      await reread(tester);
      expect(repairs, 1);
      expect(panel(tester), MockCardState.customReady);
      expect(find.textContaining('Change the'), findsOneWidget);
    });

    testWidgets('paper on the server and here: ready, and Take opens setup',
        (tester) async {
      await openQuiz(tester);
      await pump(tester);
      expect(panel(tester), MockCardState.customReady);
      expect(find.textContaining('60 questions'), findsOneWidget);
      expect(repairs, 0);

      await tester.ensureVisible(find.text('Take the Exam'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Take the Exam'));
      await tester.pumpAndSettle();
      final route = tester.widget<MockSetupRoute>(find.byType(MockSetupRoute));
      expect(route.examId, customId);
    });

    testWidgets(
        'paper on the server and none here (restore has not run): Set One '
        'Up, and ready once the row is written', (tester) async {
      await openQuiz(tester, paper: false);
      await pump(tester);
      expect(panel(tester), MockCardState.customUnset);
      expect(repairs, 0);

      await storePaper();
      ProviderScope.containerOf(tester.element(find.byType(MockCard)))
          .invalidate(customMockSummaryProvider(customId));
      await tester.pumpAndSettle();
      expect(panel(tester), MockCardState.customReady);
    });

    testWidgets('a cooldown waits, whatever this browser holds',
        (tester) async {
      for (final paper in [true, false]) {
        await db.delete(db.customBlueprintsLocal).go();
        await openQuiz(tester, paper: paper);
        serverStatus = 'cooldown';
        await pump(tester);
        expect(panel(tester), MockCardState.waiting);
        expect(repairs, 0);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('an open mock resumes, whatever this browser holds',
        (tester) async {
      await openQuiz(tester, paper: false);
      serverStatus = 'in-progress';
      await pump(tester);
      expect(panel(tester), MockCardState.inProgress);
      expect(repairs, 0);
    });

    testWidgets('a phone does not repair: its mock is read here',
        (tester) async {
      await openQuiz(tester);
      await pump(tester, web: false);
      expect(repairs, 0);
    });
  });

  for (final covered in [false, true]) {
    for (final route in [
      '/quiz',
      '/quiz/flagged/upcat',
    ]) {
      testWidgets('route $route uses active-exam coverage $covered',
          (tester) async {
        await AppPreferencesRepository(db).setPassedAgeGate(value: true);
        await AppPreferencesRepository(db).setSelectedExamId('upcat');
        await pumpApp(
          tester,
          entitlement: Entitlement(
            plan: EntitlementPlan.monthly,
            productId: 'pantas_pro_monthly',
            expiresAt: DateTime.utc(2030),
          ),
          proForExam: covered,
        );
        final container =
            ProviderScope.containerOf(tester.element(find.byType(App)));
        container.read(routerProvider).go(route);
        await tester.pumpAndSettle();
        expect(
          container
              .read(routerProvider)
              .routeInformationProvider
              .value
              .uri
              .path,
          route,
        );
        final actual = switch (route) {
          '/quiz' => tester.widget<MockCard>(find.byType(MockCard)).model.pro,
          '/quiz/flagged/upcat' => tester
              .widget<FlaggedListPage>(find.byType(FlaggedListPage))
              .proIsActive,
          _ => tester
              .widget<MockReviewPage>(find.byType(MockReviewPage))
              .proIsActive,
        };
        expect(actual, covered);
      });
    }
  }
}

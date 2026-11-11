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
import 'package:pantas/features/mock_exam/application/server_mock_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/data/server_mock_api.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';
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

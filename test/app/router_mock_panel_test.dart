import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_start_route.dart';
import 'package:pantas/features/paywall/paywall.dart';

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
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          entitlementProvider.overrideWith(
            (_) => Stream.value(const Entitlement.free()),
          ),
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

  testWidgets('Quiz tab renders MockPanel', (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('upcat');
    await pumpApp(tester);

    // Navigate to Quiz tab
    await tester.tap(find.text('Quiz'));
    await tester.pumpAndSettle();

    expect(find.byType(MockPanel), findsOneWidget);
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
    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();

    final route = tester.widget<MockStartRoute>(find.byType(MockStartRoute));
    expect(route.resumeAttemptId, 'mock_local');
  });
}

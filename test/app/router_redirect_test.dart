import 'package:cse_cet_reviewer/app/app.dart';
import 'package:cse_cet_reviewer/app/flavor.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/app_preferences_repository.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = inMemoryDatabase();
    await db.into(db.exams).insert(ExamsCompanion.insert(
          id: 'cse',
          code: 'CSE',
          name: 'Civil Service Exam',
          shortName: 'CSE',
          language: 'en',
        ));
    await db.into(db.exams).insert(ExamsCompanion.insert(
          id: 'upcat',
          code: 'UPCAT',
          name: 'UPCAT',
          shortName: 'UPCAT',
          language: 'en',
        ));
  });

  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const App(flavor: Flavor.dev),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('age gate not passed → boot lands on onboarding welcome',
      (tester) async {
    await pumpApp(tester);
    expect(find.text('Build your study plan'), findsOneWidget);
  });

  testWidgets(
      'age gate passed, needs selection → boot lands on onboarding picker',
      (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(true);
    await pumpApp(tester);
    expect(find.text('Choose your exam'), findsOneWidget);
  });

  testWidgets('age gate passed, valid selection → boot lands on home',
      (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(true);
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await pumpApp(tester);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Choose your exam'), findsNothing);
  });

  testWidgets('age gate passed, invalid persisted exam id → onboarding picker',
      (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(true);
    await AppPreferencesRepository(db).setSelectedExamId('removed-exam');
    await pumpApp(tester);
    expect(find.text('Choose your exam'), findsOneWidget);
  });
}

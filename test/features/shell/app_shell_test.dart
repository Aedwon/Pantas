import 'package:cse_cet_reviewer/app/app.dart';
import 'package:cse_cet_reviewer/app/flavor.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/app_preferences_repository.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  group('App navigation shell', () {
    late AppDatabase db;

    setUp(() async {
      db = inMemoryDatabase();
      await db.into(db.exams).insert(
            ExamsCompanion.insert(
              id: 'cse',
              code: 'CSE',
              name: 'Civil Service Exam',
              shortName: 'CSE',
              language: 'en',
            ),
          );
      await AppPreferencesRepository(db).setPassedAgeGate(true);
      await AppPreferencesRepository(db).setSelectedExamId('cse');
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

    testWidgets('renders four tabs: Home, Study, Quiz, More', (tester) async {
      await pumpApp(tester);

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Study'), findsWidgets);
      expect(find.text('Quiz'), findsWidgets);
      expect(find.text('More'), findsWidgets);
      expect(find.text('Learn'), findsNothing);
    });

    testWidgets('tapping Study tab navigates to Study screen', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Study').last);
      await tester.pumpAndSettle();

      expect(find.textContaining('Study'), findsWidgets);
    });

    testWidgets('tapping Quiz tab navigates to Quiz screen', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Quiz').last);
      await tester.pumpAndSettle();

      expect(find.textContaining('Quiz'), findsWidgets);
    });

    testWidgets('tapping More tab navigates to More screen', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('More').last);
      await tester.pumpAndSettle();

      expect(find.textContaining('More'), findsWidgets);
    });
  });
}

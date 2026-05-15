import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/learn_tab_home.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = inMemoryDatabase();
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'e1',
            code: 'CSE',
            name: 'Civil Service Exam',
            shortName: 'CSE',
            language: 'en',
          ),
        );
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'e2',
            code: 'UPCAT',
            name: 'UPCAT',
            shortName: 'UPCAT',
            language: 'en',
          ),
        );
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 's1',
            examId: 'e1',
            name: 'Verbal',
            ordering: 1,
          ),
        );
  });

  tearDown(() => db.close());

  testWidgets('shows exam names from seeded database', (tester) async {
    await tester.pumpAppWithProviders(
      const LearnTabHome(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Civil Service Exam'), findsOneWidget);
    expect(find.text('UPCAT'), findsOneWidget);
  });

  testWidgets('shows error banner when provider fails', (tester) async {
    await tester.pumpAppWithProviders(
      const LearnTabHome(),
      overrides: [
        examListProvider.overrideWith(
          (ref) => Future.error(Exception('db error')),
        ),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.byType(ErrorBanner), findsOneWidget);
  });

  testWidgets('expands exam to show subject names', (tester) async {
    await tester.pumpAppWithProviders(
      const LearnTabHome(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    // Tap the Civil Service Exam expansion tile
    await tester.tap(find.text('Civil Service Exam'));
    await tester.pumpAndSettle();

    expect(find.text('Verbal'), findsOneWidget);
  });
}

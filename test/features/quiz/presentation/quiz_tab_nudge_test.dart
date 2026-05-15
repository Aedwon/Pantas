import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_tab_home.dart';
import 'package:drift/drift.dart' show Value;
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
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 's1',
            examId: 'e1',
            name: 'Verbal',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 't1',
            subjectId: 's1',
            name: 'Vocabulary',
            ordering: 1,
          ),
        );
    await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: 'l1',
            topicId: 't1',
            title: 'Lesson 1',
            summary: 'Summary',
            bodyJson: jsonEncode([]),
            estimatedMinutes: 5,
          ),
        );
  });

  tearDown(() => db.close());

  testWidgets('shows nudge bottom sheet on first quiz tap with no lessons read',
      (tester) async {
    await tester.pumpAppWithProviders(
      const QuizTabHome(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Quick Quiz'));
    await tester.pumpAndSettle();

    expect(find.text('Study first for better results'), findsOneWidget);
  });

  testWidgets('does not show nudge when nudge already dismissed',
      (tester) async {
    await db.into(db.quizNudgeDismissedLocal).insert(
          QuizNudgeDismissedLocalCompanion.insert(
            id: const Value(1),
            dismissedAt: DateTime.now(),
          ),
        );

    await tester.pumpAppWithProviders(
      const QuizTabHome(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Quick Quiz'));
    await tester.pumpAndSettle();

    expect(find.text('Study first for better results'), findsNothing);
  });

  testWidgets('does not show nudge when at least one lesson is read',
      (tester) async {
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'l1',
            readAt: DateTime.now(),
          ),
        );

    await tester.pumpAppWithProviders(
      const QuizTabHome(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Quick Quiz'));
    await tester.pumpAndSettle();

    expect(find.text('Study first for better results'), findsNothing);
  });
}

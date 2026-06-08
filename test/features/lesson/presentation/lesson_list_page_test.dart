import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/lesson_list_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;

  Future<void> seedLesson(AppDatabase db, String id, String title) async {
    await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: id,
            topicId: 't1',
            title: title,
            summary: 'Summary for $title',
            bodyJson: jsonEncode([]),
            estimatedMinutes: 3,
          ),
        );
  }

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
  });

  tearDown(() => db.close());

  testWidgets('shows lesson titles for the topic', (tester) async {
    await seedLesson(db, 'l1', 'Synonyms');
    await seedLesson(db, 'l2', 'Antonyms');

    await tester.pumpAppWithProviders(
      const LessonListPage(topicId: 't1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Synonyms'), findsOneWidget);
    expect(find.text('Antonyms'), findsOneWidget);
  });

  testWidgets('shows empty state when topic has no lessons', (tester) async {
    await tester.pumpAppWithProviders(
      const LessonListPage(topicId: 't1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('No lessons yet'), findsOneWidget);
  });
}

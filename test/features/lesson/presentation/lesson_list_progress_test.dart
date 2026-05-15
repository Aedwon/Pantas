import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/lesson_list_page.dart';
import 'package:flutter/material.dart';
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
            name: 'CSE',
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
            title: 'Synonyms',
            summary: 'Summary',
            bodyJson: jsonEncode([]),
            estimatedMinutes: 5,
          ),
        );
    await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: 'l2',
            topicId: 't1',
            title: 'Antonyms',
            summary: 'Summary',
            bodyJson: jsonEncode([]),
            estimatedMinutes: 5,
          ),
        );
  });

  tearDown(() => db.close());

  testWidgets('shows no checkmarks when no lessons are read', (tester) async {
    await tester.pumpAppWithProviders(
      const LessonListPage(topicId: 't1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsNothing);
  });

  testWidgets('shows checkmark only on read lesson card', (tester) async {
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'l1',
            readAt: DateTime.now(),
          ),
        );

    await tester.pumpAppWithProviders(
      const LessonListPage(topicId: 't1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}

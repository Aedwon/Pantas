import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/lesson_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;

  Future<void> seedLesson(AppDatabase db) async {
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
            title: 'Vocabulary Basics',
            summary: 'Core vocab',
            bodyJson: jsonEncode(<Map<String, Object?>>[
              {
                '_type': 'block',
                'style': 'normal',
                'children': <Map<String, Object?>>[
                  {'_type': 'span', 'text': 'Study hard.', 'marks': <String>[]},
                ],
              },
            ]),
            estimatedMinutes: 5,
          ),
        );
  }

  setUp(() async {
    db = inMemoryDatabase();
    await seedLesson(db);
  });

  tearDown(() => db.close());

  testWidgets('shows Mark as read button when lesson is unread',
      (tester) async {
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Mark as read'), findsOneWidget);
    expect(find.text('✓ Lesson complete'), findsNothing);
  });

  testWidgets('tapping Mark as read shows Lesson complete', (tester) async {
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mark as read'));
    await tester.pumpAndSettle();

    expect(find.text('✓ Lesson complete'), findsOneWidget);
    expect(find.text('Mark as read'), findsNothing);
  });

  testWidgets('shows Lesson complete on open when already read',
      (tester) async {
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'l1',
            readAt: DateTime.now(),
          ),
        );

    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('✓ Lesson complete'), findsOneWidget);
    expect(find.text('Mark as read'), findsNothing);
  });
}

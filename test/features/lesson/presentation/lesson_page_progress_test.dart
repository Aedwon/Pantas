import 'dart:convert';

import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/lesson_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

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
    contentDb = openTestContentDatabase();
    await seedLesson(db);
  });

  tearDown(() => db.close());

  // There is no mark-as-read button any more, deliberately. With one, every
  // coverage figure in the app counted button presses rather than lessons
  // whose end was actually reached. Read marking is driven by scroll position
  // now, and `read_marking_test.dart` covers the rule itself.
  testWidgets('an unread lesson offers no way to declare itself read',
      (tester) async {
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Mark as read'), findsNothing);
    expect(find.text('Read'), findsNothing);
  });

  testWidgets('a read lesson says so, and says it was automatic',
      (tester) async {
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'l1',
            readAt: DateTime.now(),
          ),
        );

    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Read'), findsOneWidget);
    expect(find.text('marked automatically'), findsOneWidget);
    expect(find.text('Mark as read'), findsNothing);
  });
}

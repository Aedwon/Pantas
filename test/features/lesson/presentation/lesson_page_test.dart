import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/lesson_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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
            title: 'Vocabulary Basics',
            summary: 'Core vocab',
            bodyJson: jsonEncode(<Map<String, Object?>>[
              {
                '_type': 'block',
                'style': 'normal',
                'children': <Map<String, Object?>>[
                  {
                    '_type': 'span',
                    'text': 'Synonyms share meaning.',
                    'marks': <String>[],
                  },
                ],
              },
            ]),
            estimatedMinutes: 5,
          ),
        );
  });

  tearDown(() => db.close());

  testWidgets('shows lesson title and body content', (tester) async {
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Vocabulary Basics'), findsOneWidget);
    expect(find.text('Synonyms share meaning.'), findsOneWidget);
  });

  testWidgets('shows estimated read time', (tester) async {
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('5 min'), findsOneWidget);
  });

  testWidgets('lesson page renders Quiz yourself card after lesson body',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/lesson/l1?examId=e1',
      routes: [
        GoRoute(
          path: '/lesson/:lessonId',
          builder: (_, state) => LessonPage(
            lessonId: state.pathParameters['lessonId']!,
            examId: state.uri.queryParameters['examId'],
          ),
        ),
        GoRoute(
          path: '/quiz/inline/:examId/:lessonId',
          builder: (_, state) => Text(
            'Inline ${state.pathParameters['examId']} '
            '${state.pathParameters['lessonId']}',
          ),
        ),
      ],
    );

    await tester.pumpAppWithRouter(
      router,
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Quiz yourself'), findsOneWidget);
    await tester.tap(find.text('Quiz yourself'));
    await tester.pumpAndSettle();
    expect(find.text('Inline e1 l1'), findsOneWidget);
  });
}

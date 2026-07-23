import 'dart:convert';

import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/lesson_page.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/widgets/pull_to_advance.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();

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
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Vocabulary Basics'), findsOneWidget);
    expect(find.text('Synonyms share meaning.'), findsOneWidget);
  });

  testWidgets('shows estimated read time', (tester) async {
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('5 min'), findsOneWidget);
  });

  testWidgets('lesson page renders Quiz yourself card after lesson body',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/lesson/l1?from=study',
      routes: [
        GoRoute(
          path: '/lesson/:lessonId',
          builder: (_, state) => LessonPage(
            lessonId: state.pathParameters['lessonId']!,
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
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Quiz yourself'), findsOneWidget);
    await tester.tap(find.textContaining('Quiz yourself'));
    await tester.pumpAndSettle();
    expect(find.text('Inline e1 l1'), findsOneWidget);
  });

  testWidgets('advancing never falls back to the loading skeleton',
      (tester) async {
    // Aedwon: "when pulling up, the entire app still has a moment of loading
    // sort of". The skeleton replaces the whole body, chrome included, so a
    // swap flashed the bar and the rail out and back.
    await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: 'l2',
            topicId: 't1',
            title: 'Antonyms',
            summary: 'Opposites',
            bodyJson: jsonEncode([
              {
                '_type': 'block',
                'style': 'normal',
                'children': [
                  {
                    '_type': 'span',
                    'text': 'Antonyms are opposites.',
                    'marks': <String>[],
                  },
                ],
              },
            ]),
            estimatedMinutes: 4,
            ordering: const Value(2),
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

    expect(find.text('Vocabulary Basics'), findsOneWidget);

    // Drive the whole advance a frame at a time and watch for the skeleton.
    final body = tester.getRect(find.byType(PullToAdvance));
    final gesture = await tester.startGesture(body.center);
    await gesture.moveBy(const Offset(0, -140));
    await tester.pump();
    await gesture.up();

    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      expect(
        find.byType(FaintBars),
        findsNothing,
        reason: 'the reader must never blank out while advancing',
      );
    }
    await tester.pumpAndSettle();

    // Without this the loop above proves nothing: it would pass just as well
    // if the pull never committed.
    expect(find.text('Antonyms'), findsOneWidget);
  });
}

import 'dart:convert';

import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/learn_tab_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;

  GoRouter buildRouter() => GoRouter(
        initialLocation: '/study',
        routes: [
          GoRoute(
            path: '/onboarding',
            builder: (_, __) => const Text('Onboarding'),
          ),
          GoRoute(
            path: '/study',
            builder: (_, __) => const StudyTabHome(),
            routes: [
              GoRoute(
                path: 'topic/:topicId',
                builder: (_, state) => Scaffold(
                  body: Text(
                    'Topic ${state.pathParameters['topicId']} '
                    '${state.uri.queryParameters['examId']}',
                  ),
                ),
              ),
            ],
          ),
        ],
      );

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
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 's2',
            examId: 'e2',
            name: 'Language Proficiency',
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
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 't2',
            subjectId: 's2',
            name: 'Grammar',
            ordering: 1,
          ),
        );
    // The map is built from lessons. Without one per topic it renders its
    // empty state and there is no exam content to isolate.
    for (final (id, topicId) in [('l1', 't1'), ('l2', 't2')]) {
      await db.into(db.lessons).insert(
            LessonsCompanion.insert(
              id: id,
              topicId: topicId,
              title: 'Lesson $id',
              summary: 'Summary',
              bodyJson: jsonEncode([]),
              estimatedMinutes: 5,
            ),
          );
    }
  });

  tearDown(() => db.close());

  testWidgets('shows only selected exam content', (tester) async {
    await AppPreferencesRepository(db).setSelectedExamId('e1');

    await tester.pumpAppWithRouter(
      buildRouter(),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(openTestContentDatabase()),
      ],
    );
    await tester.pumpAndSettle();

    // The map heads with the short name. Exam isolation is the point of this
    // test and it still holds: nothing from the unselected exam appears.
    expect(find.text('CSE'), findsOneWidget);
    expect(find.text('UPCAT'), findsNothing);
    expect(find.text('Verbal'), findsOneWidget);
    expect(find.text('Language Proficiency'), findsNothing);
  });

  testWidgets('shows error banner when provider fails', (tester) async {
    await tester.pumpAppWithProviders(
      const StudyTabHome(),
      overrides: [
        examListProvider.overrideWith(
          (ref) => Future.error(Exception('db error')),
        ),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.byType(ErrorBanner), findsOneWidget);
  });

  testWidgets('missing selected focus shows choose exam fallback',
      (tester) async {
    await tester.pumpAppWithRouter(
      buildRouter(),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(openTestContentDatabase()),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose your exam'), findsOneWidget);
    expect(find.text('Pick the exam you are reviewing for.'), findsOneWidget);
  });
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/error_banner.dart';
import 'package:pantas/features/lesson/presentation/learn_tab_home.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

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
    contentDb = openTestContentDatabase();
    await seedContentExam(
      contentDb,
      examId: 'e1',
      code: 'CSE',
      name: 'Civil Service Exam',
      shortName: 'CSE',
    );
    await seedContentExam(
      contentDb,
      examId: 'e2',
      code: 'UPCAT',
      name: 'UPCAT',
      shortName: 'UPCAT',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 's1',
      examId: 'e1',
      name: 'Verbal',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 's2',
      examId: 'e2',
      name: 'Language Proficiency',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't1',
      subjectId: 's1',
      name: 'Vocabulary',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't2',
      subjectId: 's2',
      name: 'Grammar',
    );
    // The map is built from lessons. Without one per topic it renders its
    // empty state and there is no exam content to isolate.
    for (final (id, topicId) in [('l1', 't1'), ('l2', 't2')]) {
      await seedContentLesson(
        contentDb,
        lessonId: id,
        topicId: topicId,
        title: 'Lesson $id',
        bodyJson: jsonEncode([]),
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
        contentDatabaseProvider.overrideWithValue(contentDb),
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
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose your exam'), findsOneWidget);
    expect(find.text('Pick the exam you are reviewing for.'), findsOneWidget);
  });
}

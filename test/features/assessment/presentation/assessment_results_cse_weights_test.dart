import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/assessment_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/assessment/presentation/assessment_results_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

GoRouter _router(String examId) => GoRouter(
      initialLocation: '/assessment/$examId/results',
      routes: [
        GoRoute(
          path: '/assessment/:examId/results',
          builder: (_, state) =>
              AssessmentResultsPage(examId: state.pathParameters['examId']!),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Text('Home')),
        ),
      ],
    );

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() {
    db = inMemoryDatabase();
    contentDb = inMemoryContentDatabase();
  });

  tearDown(() async {
    await db.close();
    await contentDb.close();
  });

  Future<void> seed(String examId) async {
    await seedContentExam(
      contentDb,
      examId: examId,
      code: examId,
      name: examId,
    );
    await seedContentSubject(
      contentDb,
      subjectId: 'subj_$examId',
      examId: examId,
      name: 'Language',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't_vocab',
      subjectId: 'subj_$examId',
      name: 'Vocabulary',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't_alg',
      subjectId: 'subj_$examId',
      name: 'Algebra',
      ordering: 2,
    );
    await AssessmentRepository(db).saveResult(examId, DateTime(2026), [
      const TopicScore(topicId: 't_vocab', correct: 1, total: 3),
      const TopicScore(topicId: 't_alg', correct: 2, total: 3),
    ]);
  }

  Future<void> show(WidgetTester tester, String examId, {bool web = false}) {
    addTearDown(() => debugWebPlatformOverride = null);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    debugWebPlatformOverride = web;
    tester.view.physicalSize = Size(web ? 1440 : 390, 1800);
    return tester.pumpAppWithRouter(
      _router(examId),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
  }

  for (final web in [false, true]) {
    testWidgets('CSE Professional parts show their weight, web=$web',
        (tester) async {
      await seed('exam_cse_pro');
      await show(tester, 'exam_cse_pro', web: web);
      await tester.pumpAndSettle();
      expect(find.text('Verbal Ability (30%)'), findsOneWidget);
      expect(find.text('Numerical Ability (30%)'), findsOneWidget);
    });

    testWidgets('Subprofessional parts show no weight, web=$web',
        (tester) async {
      await seed('exam_cse_sub');
      await show(tester, 'exam_cse_sub', web: web);
      await tester.pumpAndSettle();
      expect(find.text('Verbal Ability'), findsOneWidget);
      expect(find.text('Numerical Ability'), findsOneWidget);
      expect(find.textContaining('%)'), findsNothing);
    });

    testWidgets('another exam shows no weight, web=$web', (tester) async {
      await seed('exam_other');
      await show(tester, 'exam_other', web: web);
      await tester.pumpAndSettle();
      expect(find.text('Language'), findsOneWidget);
      expect(find.textContaining('%)'), findsNothing);
    });
  }
}

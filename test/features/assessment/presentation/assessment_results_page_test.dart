import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/assessment_repository.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/assessment/presentation/assessment_results_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

GoRouter _buildRouter(String examId) => GoRouter(
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
        GoRoute(
          path: '/study',
          builder: (_, __) => const Scaffold(body: Text('Lessons')),
        ),
        GoRoute(
          path: '/quiz/quick/:examId',
          builder: (_, state) => Scaffold(
            body: Text('Quiz ${state.uri.queryParameters['topicId']}'),
          ),
        ),
      ],
    );

class _FailingAcknowledge extends AppPreferencesRepository {
  _FailingAcknowledge(super.db);

  @override
  Future<void> setDeviceValue(String key, String value) =>
      Future.error(StateError('ack'));
}

class _ErrorSink extends DisabledTelemetry {
  final errors = <Object>[];
  @override
  Future<void> recordError(Object error, StackTrace stack) async {
    errors.add(error);
  }
}

class _MissingSubjectContent extends ContentRepository {
  _MissingSubjectContent(super.db, this.missing);
  final String missing;

  @override
  Future<Subject?> subjectById(SubjectId id) async =>
      id == missing ? null : super.subjectById(id);
}

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = inMemoryContentDatabase();

    await seedContentExam(
      contentDb,
      examId: 'e1',
      code: 'CSE',
      name: 'Civil Service Exam',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 's1',
      examId: 'e1',
      name: 'Verbal',
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
      subjectId: 's1',
      name: 'Reading Comprehension',
      ordering: 2,
    );
    await seedContentTopic(
      contentDb,
      topicId: 't3',
      subjectId: 's1',
      name: 'Using context clues in unusually long reading passages',
      ordering: 3,
    );

    // t1: weak, t3: moderate, t2: strong.
    await AssessmentRepository(db).saveResult('e1', DateTime(2026), [
      const TopicScore(topicId: 't1', correct: 0, total: 3),
      const TopicScore(topicId: 't2', correct: 3, total: 3),
      const TopicScore(topicId: 't3', correct: 1, total: 2),
    ]);
  });

  tearDown(() async {
    await db.close();
    await contentDb.close();
  });

  List<Override> databaseOverrides() => [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ];

  testWidgets(
      'subjects aggregate actual topic scores, weakest topic is retained',
      (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: databaseOverrides(),
    );
    await tester.pumpAndSettle();
    expect(find.text("Where you're starting"), findsOneWidget);
    expect(find.text('Verbal'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('Vocabulary'), findsOneWidget);
    expect(find.text('YOUR PLAN STARTS WITH'), findsOneWidget);
    expect(find.text('in 24 minutes'), findsNothing);
  });
  testWidgets('the ring counts only the subjects the rows show',
      (tester) async {
    // Topic t9 scored, but its subject cannot be read, so it has no row.
    await seedContentSubject(
      contentDb,
      subjectId: 's9',
      examId: 'e1',
      name: 'Lost',
      ordering: 2,
    );
    await seedContentTopic(
      contentDb,
      topicId: 't9',
      subjectId: 's9',
      name: 'Orphan topic',
    );
    await AssessmentRepository(db).saveResult('e1', DateTime(2027), [
      const TopicScore(topicId: 't1', correct: 0, total: 3),
      const TopicScore(topicId: 't2', correct: 3, total: 3),
      const TopicScore(topicId: 't3', correct: 1, total: 2),
      const TopicScore(topicId: 't9', correct: 4, total: 4),
    ]);
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: [
        ...databaseOverrides(),
        contentRepositoryProvider
            .overrideWithValue(_MissingSubjectContent(contentDb, 's9')),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('Verbal'), findsOneWidget);
    expect(find.text('Lost'), findsNothing);
    expect(find.textContaining('8 questions'), findsOneWidget);
    expect(find.textContaining('12 questions'), findsNothing);
    final ring = tester.widget<HalfRingGauge>(find.byType(HalfRingGauge));
    expect((ring.correct, ring.total), (4, 8));
  });
  testWidgets('a failed acknowledgement is reported and can be retried',
      (tester) async {
    final sink = _ErrorSink();
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: [
        ...databaseOverrides(),
        telemetryProvider.overrideWithValue(sink),
        appPreferencesRepositoryProvider
            .overrideWithValue(_FailingAcknowledge(db)),
      ],
    );
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Go to Today'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(sink.errors, hasLength(1));
  });
  testWidgets('Go to Today acknowledges once and reopening goes Home',
      (tester) async {
    final router = _buildRouter('e1');
    await tester.pumpAppWithRouter(router, overrides: databaseOverrides());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Go to Today'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    router.go('/assessment/e1/results');
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });
  testWidgets('empty results can safely reach Home', (tester) async {
    await AssessmentRepository(db).saveResult('e1', DateTime(2026), const []);
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: databaseOverrides(),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Go to Today'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });
  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('results supports $brightness $scale', (tester) async {
        tester.view
          ..physicalSize = const Size(390, 844)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            overrides: databaseOverrides(),
            child: MaterialApp.router(
              theme: brightness == Brightness.dark
                  ? buildDarkTheme()
                  : buildLightTheme(),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(scale),
                  disableAnimations: true,
                ),
                child: child!,
              ),
              routerConfig: _buildRouter('e1'),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text("Where you're starting"), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}

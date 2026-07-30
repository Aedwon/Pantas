import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/assessment_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late ProviderContainer container;

  setUp(() {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
  });
  tearDown(() {
    container.dispose();
    db.close();
  });

  Future<SessionPanelState> read() =>
      container.read(sessionPanelProvider('exam_cse_pro').future);

  test('a student who has not been assessed is asked to be', () async {
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'exam_cse_pro',
      topicId: 'topic_algebra',
      topicName: 'Algebra',
      questionIds: ['q_1', 'q_2', 'q_3'],
    );

    final state = await read();

    expect(state, isA<SessionPanelNeedsAssessment>());
    expect((state as SessionPanelNeedsAssessment).questionCount, 3);
  });

  test('an assessed student with a backlog gets a session', () async {
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'exam_cse_pro',
      topicId: 'topic_algebra',
      topicName: 'Algebra',
      questionIds: ['q_1', 'q_2', 'q_3'],
    );
    await AssessmentRepository(db).saveResult(
      'exam_cse_pro',
      DateTime.utc(2026, 8),
      const [],
    );

    final state = await read();

    expect(state, isA<SessionPanelAvailable>());
    expect((state as SessionPanelAvailable).plan.length, 3);
  });

  test('the average minutes are withheld below seven sessions', () async {
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'exam_cse_pro',
      topicId: 'topic_algebra',
      topicName: 'Algebra',
      questionIds: ['q_1'],
    );
    await AssessmentRepository(db).saveResult(
      'exam_cse_pro',
      DateTime.utc(2026, 8),
      const [],
    );

    final state = await read() as SessionPanelAvailable;

    expect(state.averageMinutes, isNull);
  });

  test('an assessed student with nothing left is caught up', () async {
    await AssessmentRepository(db).saveResult(
      'exam_cse_pro',
      DateTime.utc(2026, 8),
      const [],
    );

    final state = await read();

    expect(state, isA<SessionPanelCaughtUp>());
  });

  test('an open session outranks every other state', () async {
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'exam_cse_pro',
      topicId: 'topic_algebra',
      topicName: 'Algebra',
      questionIds: ['q_1', 'q_2', 'q_3'],
    );
    await QuizSessionRepository(db).create(
      sessionId: 's_open',
      userId: 'local',
      examId: 'exam_cse_pro',
      origin: SessionOrigin.todayTopic,
      topicId: 'topic_algebra',
      questionIds: const ['q_1', 'q_2', 'q_3'],
      startedAt: DateTime.utc(2026, 8, 2, 9),
    );

    final state = await read();

    expect(state, isA<SessionPanelInProgress>());
    final inProgress = state as SessionPanelInProgress;
    expect(inProgress.total, 3);
    expect(inProgress.answered, 0);
    expect(inProgress.topicName, 'Algebra');
  });
}

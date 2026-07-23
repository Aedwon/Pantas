import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/session_origin.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = inMemoryDatabase();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(openTestContentDatabase()),
      ],
    );
  });
  tearDown(() {
    container.dispose();
    db.close();
  });

  test('resuming with no open session fails rather than starting one',
      () async {
    await container
        .read(quizControllerProvider.notifier)
        .resumeToday(examId: 'exam_cse_pro');

    expect(container.read(quizControllerProvider), isA<QuizFailure>());
  });

  test('resuming returns the questions already saved', () async {
    await seedTopicWithQuestions(
      db,
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

    await container
        .read(quizControllerProvider.notifier)
        .resumeToday(examId: 'exam_cse_pro');

    final state = container.read(quizControllerProvider) as QuizRunning;
    expect(state.session.sessionId, 's_open');
    expect(state.persisted, isTrue);
  });
}

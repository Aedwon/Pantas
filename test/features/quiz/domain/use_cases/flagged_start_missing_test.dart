import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_practice.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  test('missing flagged content keeps the previous session intact', () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(contentDb.close);
    addTearDown(db.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'e',
      topicId: 't',
      topicName: 'Topic',
      questionIds: ['q'],
    );
    final sessions = QuizSessionRepository(db);
    await sessions.create(
      sessionId: 'previous',
      userId: 'local',
      examId: 'e',
      origin: SessionOrigin.drill,
      questionIds: ['q'],
      startedAt: DateTime.utc(2026),
    );
    final start = StartPractice(
      content: ContentRepository(contentDb),
      sessions: sessions,
      attempts: AttemptsRepository(db),
      reviews: ReviewStateRepository(db),
    );
    await expectLater(
      start.fromQuestionIds(
        userId: 'local',
        examId: 'e',
        questionIds: ['q', 'missing'],
        now: DateTime.utc(2026, 10),
        origin: SessionOrigin.flagged,
      ),
      throwsStateError,
    );
    expect(
      (await sessions.activeFor(userId: 'local', examId: 'e'))?.id,
      'previous',
    );
    expect(await db.select(db.quizSessions).get(), hasLength(1));
  });
}

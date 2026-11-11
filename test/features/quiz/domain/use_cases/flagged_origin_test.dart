import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
import 'package:pantas/features/quiz/application/quiz_completion_coordinator.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/restart_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/resume_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_practice.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  test('flagged practice keeps stored origin, timing and streak rules',
      () async {
    final db = inMemoryDatabase();
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    addTearDown(contentDb.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'e',
      topicId: 't',
      topicName: 'Topic',
      questionIds: ['q'],
    );
    final content = ContentRepository(contentDb);
    final sessions = QuizSessionRepository(db);
    final attempts = AttemptsRepository(db);
    final started = DateTime.utc(2026, 10, 16);
    final origin = SessionOrigin.fromStorage('flagged');
    await sessions.create(
      sessionId: 's',
      userId: 'local',
      examId: 'e',
      origin: origin,
      questionIds: ['q'],
      startedAt: started,
    );
    expect(
      (await sessions.activeFor(userId: 'local', examId: 'e'))!.origin,
      'flagged',
    );
    final restarted = (await RestartSession(
      content: content,
      sessions: sessions,
      newSessionId: () => 's2',
    )(userId: 'local', examId: 'e', now: started))!;
    expect(restarted.origin.storageValue, 'flagged');
    final resumed = (await ResumeSession(content: content, sessions: sessions)(
      userId: 'local',
      examId: 'e',
    ))!;
    expect(resumed.origin.storageValue, 'flagged');
    expect(resumed.origin.isStreakEligible, isFalse);
    final question = resumed.questions.single;
    final outcome = AnswerOutcome(
      questionId: question.id,
      questionVersion: question.version,
      chosenChoiceId: question.correctChoice.id,
      correctChoiceId: question.correctChoice.id,
      responseMs: 12000,
    );
    await sessions.recordAnswer(
      sessionId: 's2',
      outcome: outcome,
      answeredAt: started.add(const Duration(seconds: 12)),
    );
    final attempt =
        await QuizCompletionCoordinator(attempts: attempts, sessions: sessions)
            .complete(
      session: resumed.record(outcome),
      now: started.add(const Duration(seconds: 12)),
      persisted: true,
    );
    expect(attempt.origin, 'flagged');
    expect((await attempts.byId('s2'))!.origin, 'flagged');
    expect(
      await attempts.averageResponseMs(examId: 'e', minimumSessions: 1),
      12000,
    );
  });
  for (final flagged in [false, true]) {
    test('explicit flagged opt-in $flagged keeps generic ID launches separate',
        () async {
      final db = inMemoryDatabase();
      final contentDb = ContentDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      addTearDown(contentDb.close);
      await seedContentTopicWithQuestions(
        contentDb,
        examId: 'e',
        topicId: 't',
        topicName: 'Topic',
        questionIds: ['q'],
      );
      final sessions = QuizSessionRepository(db);
      final start = StartPractice(
        content: ContentRepository(contentDb),
        sessions: sessions,
        attempts: AttemptsRepository(db),
        reviews: ReviewStateRepository(db),
      );
      final result = flagged
          ? await start.fromQuestionIds(
              userId: 'local',
              examId: 'e',
              questionIds: ['q'],
              now: DateTime.utc(2026),
              origin: SessionOrigin.flagged,
            )
          : await start.fromQuestionIds(
              userId: 'local',
              examId: 'e',
              questionIds: ['q'],
              now: DateTime.utc(2026),
            );
      expect(
        (result as StartPracticeStarted).session.origin.storageValue,
        flagged ? 'flagged' : 'drill',
      );
      expect(
        (await sessions.activeFor(userId: 'local', examId: 'e'))!.origin,
        flagged ? 'flagged' : 'drill',
      );
    });
  }
  test('legacy drill remains drill and never acquires flag identity', () {
    expect(SessionOrigin.fromStorage('drill'), SessionOrigin.drill);
    expect(SessionOrigin.fromStorage('drill').isStreakEligible, isFalse);
  });
}

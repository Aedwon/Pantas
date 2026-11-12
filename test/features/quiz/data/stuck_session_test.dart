import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/data/repos/review_log_repository.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
import 'package:pantas/features/quiz/application/quiz_completion_coordinator.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/data/repos/review_batch_repository.dart';
import 'package:pantas/features/quiz/domain/models/quiz_ordering.dart';
import 'package:pantas/features/quiz/domain/models/quiz_preferences.dart';
import 'package:pantas/features/quiz/domain/models/review_batch.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/resume_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/submit_answer.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late ContentRepository content;
  late ReviewBatchScope scope;
  late ReviewBatchRepository batches;
  late QuizSessionRepository sessions;
  late SubmitAnswer submit;
  final repairs = <Object>[];
  var clock = 0;
  final now = DateTime(2026, 10, 16, 9);

  setUp(() async {
    repairs.clear();
    db = inMemoryDatabase();
    contentDb = ContentDatabase(NativeDatabase.memory());
    content = ContentRepository(contentDb);
    scope = const ReviewBatchScope(
      userId: 'local',
      examId: 'exam',
      principal: 'anonymous:one',
      accountLifetimeToken: 'anonymous:one:0',
    );
    batches = ReviewBatchRepository(
      db,
      currentScope: (_, __) => scope,
      onRepair: (e, _) => repairs.add(e),
    );
    sessions = QuizSessionRepository(
      db,
      reviewBatches: batches,
      onRepair: (e, _) => repairs.add(e),
    );
    submit = SubmitAnswer(
      reviewRepo: ReviewStateRepository(db),
      scheduler: const FsrsScheduler(),
      sessions: sessions,
      reviewLog: ReviewLogRepository(db),
    );
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'exam',
      subjectId: 's',
      topicId: 't',
      topicName: 'Topic',
      questionIds: [for (var n = 1; n <= 12; n++) 'q$n'],
    );
  });
  tearDown(() async {
    await contentDb.close();
    await db.close();
  });

  Future<ReviewBatchSession?> resume() => batches.continueBatch(
        scope: scope,
        content: content,
        now: now,
        canPersist: () => true,
      );

  Future<ReviewBatchSession> startAndAnswerTwo() async {
    final prepared = PreparedReviewBatch.fromReviews(
      scope: scope,
      preferences: QuizPreferences(
        sessionLength: 5,
        ordering: QuizOrdering.interleavedTail,
      ),
      localDay: now,
      orderedDueReviews: await content
          .hydrateSelectedQuestions([for (var n = 1; n <= 12; n++) 'q$n']),
    );
    final started = (await batches.start(
      prepared: prepared,
      content: content,
      now: now,
      canPersist: () => true,
    ))!;
    for (final q in started.session.questions.take(2)) {
      await submit(
        question: q,
        chosenChoiceId: q.correctChoice.id,
        responseMs: 4000,
        now: now,
        sessionId: started.session.sessionId,
        userId: 'local',
        examId: 'exam',
      );
    }
    return started;
  }

  Future<Object?> trySave(ReviewBatchSession s, {int at = 2}) async {
    final q = s.session.questions[at];
    try {
      await submit(
        question: q,
        chosenChoiceId: q.correctChoice.id,
        responseMs: 4000,
        now: now.add(Duration(minutes: ++clock)),
        sessionId: s.session.sessionId,
        userId: 'local',
        examId: 'exam',
      );
      return null;
    } on Object catch (e) {
      return e;
    }
  }

  Future<void> writeRow(
    String id, {
    int? currentIndex,
    String? outcomesJson,
  }) =>
      (db.update(db.quizSessions)..where((r) => r.id.equals(id))).write(
        QuizSessionsCompanion(
          currentIndex:
              currentIndex == null ? const Value.absent() : Value(currentIndex),
          outcomesJson:
              outcomesJson == null ? const Value.absent() : Value(outcomesJson),
        ),
      );

  Future<QuizSessionLocalRow> rowOf(String id) =>
      (db.select(db.quizSessions)..where((r) => r.id.equals(id))).getSingle();

  group('a session whose stored answers already include the position', () {
    test('Check saves and Continue resumes, as the stuck account needs',
        () async {
      final s = await startAndAnswerTwo();
      final id = s.session.sessionId;
      final row = await rowOf(id);
      // The third answer is stored but the position still says 2: the state
      // that made the save and the resume fail forever.
      final outcomes = row.outcomes;
      final third = AnswerOutcome(
        questionId: s.session.questions[2].id,
        questionVersion: s.session.questions[2].version,
        chosenChoiceId: 'x',
        correctChoiceId: 'x',
        responseMs: 1,
      );
      await writeRow(
        id,
        currentIndex: 2,
        outcomesJson: jsonEncode([
          for (final o in [...outcomes, third])
            {
              'questionId': o.questionId,
              'questionVersion': o.questionVersion,
              'chosenChoiceId': o.chosenChoiceId,
              'correctChoiceId': o.correctChoiceId,
              'responseMs': o.responseMs,
              'derivedRating': o.derivedRating.grade,
              'nextReviewIntervalDays': o.nextReviewIntervalDays,
            },
        ]),
      );

      expect(await trySave(s), isNull, reason: 'Check must not fail');
      final resumed = await resume();
      expect(resumed, isNotNull);
      expect(resumed!.session.outcomes, hasLength(3));
      expect(resumed.session.currentIndex, 3);
      expect(repairs, isNotEmpty);
      // The next question saves in order.
      expect(await trySave(resumed, at: 3), isNull);
      expect((await rowOf(id)).currentIndex, 4);
    });

    test('answers for the wrong questions are dropped, the rest are kept',
        () async {
      final s = await startAndAnswerTwo();
      final id = s.session.sessionId;
      final row = await rowOf(id);
      final decoded =
          (jsonDecode(row.outcomesJson) as List).cast<Map<String, Object?>>();
      decoded[1]['questionId'] = 'not-in-this-session';
      await writeRow(id, outcomesJson: jsonEncode(decoded));

      final resumed = await resume();
      expect(resumed!.session.outcomes, hasLength(1));
      expect(resumed.session.currentIndex, 1);
      expect(await trySave(resumed, at: 1), isNull);
      expect(repairs, isNotEmpty);
    });

    test('unreadable stored answers restart that session at its first question',
        () async {
      final s = await startAndAnswerTwo();
      await writeRow(s.session.sessionId, outcomesJson: '{"oops": true}');
      final resumed = await resume();
      expect(resumed!.session.outcomes, isEmpty);
      expect(resumed.session.currentIndex, 0);
      expect(repairs, isNotEmpty);
    });
  });

  group('a question that changed or left the content', () {
    test('a changed version no longer blocks the session', () async {
      final s = await startAndAnswerTwo();
      final target = s.session.questions[2].id;
      await (contentDb.update(contentDb.contentQuestions)
            ..where((q) => q.id.equals(target)))
          .write(const ContentQuestionsCompanion(version: Value(9)));
      final resumed = await resume();
      expect(resumed, isNotNull);
      expect(resumed!.session.questions, hasLength(5));
      expect(resumed.session.questions[2].version, 9);
      expect(await trySave(resumed), isNull);
      expect(repairs, isNotEmpty);
    });

    test('a missing question is skipped, the rest finish', () async {
      final s = await startAndAnswerTwo();
      final target = s.session.questions[2].id;
      await (contentDb.delete(contentDb.contentQuestions)
            ..where((q) => q.id.equals(target)))
          .go();
      final resumed = await resume();
      expect(resumed, isNotNull);
      expect(resumed!.session.questions, hasLength(4));
      expect(
        resumed.session.questions.map((q) => q.id),
        isNot(contains(target)),
      );
      expect(resumed.session.outcomes, hasLength(2));
      expect(resumed.session.currentIndex, 2);
      expect(repairs, isNotEmpty);
      for (var i = 2; i < 4; i++) {
        expect(await trySave(resumed, at: i), isNull);
      }
      final done = await resume();
      // All four answers are in, so the session can be completed.
      expect(done!.session.outcomes, hasLength(4));
      await QuizCompletionCoordinator(
        attempts: AttemptsRepository(db),
        sessions: sessions,
      ).complete(session: done.session, now: now, persisted: true);
      expect((await rowOf(s.session.sessionId)).completedAt, isNotNull);
    });
  });

  group('the Quiz tab Resume', () {
    test(
        'resumes a Reviews session with a stored position gap and a '
        'missing question', () async {
      final s = await startAndAnswerTwo();
      final target = s.session.questions[3].id;
      await (contentDb.delete(contentDb.contentQuestions)
            ..where((q) => q.id.equals(target)))
          .go();
      await writeRow(s.session.sessionId, currentIndex: 1);
      final resumed = await ResumeSession(
        content: content,
        sessions: sessions,
      )(userId: 'local', examId: 'exam');
      expect(resumed, isNotNull);
      expect(resumed!.questions, hasLength(4));
      expect(resumed.outcomes, hasLength(2));
      expect(resumed.currentIndex, 2);
      expect(repairs, isNotEmpty);
    });

    test('resumes an ordinary session without the question that left',
        () async {
      await sessions.create(
        sessionId: 'plain',
        userId: 'local',
        examId: 'exam',
        origin: SessionOrigin.drill,
        questionIds: ['q1', 'q2', 'q3'],
        startedAt: now,
      );
      await (contentDb.delete(contentDb.contentQuestions)
            ..where((q) => q.id.equals('q2')))
          .go();
      final resumed = await ResumeSession(
        content: content,
        sessions: sessions,
      )(userId: 'local', examId: 'exam');
      expect(resumed!.questions.map((q) => q.id), ['q1', 'q3']);
      expect((await rowOf('plain')).questionIds, ['q1', 'q3']);
    });
  });
}

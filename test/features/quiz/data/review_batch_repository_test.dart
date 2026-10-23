import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/features/quiz/application/quiz_completion_coordinator.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/data/repos/review_batch_repository.dart';
import 'package:pantas/features/quiz/domain/models/quiz_ordering.dart';
import 'package:pantas/features/quiz/domain/models/quiz_preferences.dart';
import 'package:pantas/features/quiz/domain/models/review_batch.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/resume_session.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late ContentRepository content;
  late ReviewBatchScope scope;
  late ReviewBatchRepository batches;
  late QuizSessionRepository sessions;
  final now = DateTime(2026, 10, 16, 9);
  const key = 'quiz_review_batch.v1.local.exam';

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = ContentDatabase(NativeDatabase.memory());
    content = ContentRepository(contentDb);
    scope = const ReviewBatchScope(
      userId: 'local',
      examId: 'exam',
      principal: 'anonymous:one',
      accountLifetimeToken: 'anonymous:one:0',
    );
    batches = ReviewBatchRepository(db, currentScope: (_, __) => scope);
    sessions = QuizSessionRepository(db, reviewBatches: batches);
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

  Future<PreparedReviewBatch> prepare({int length = 5}) async =>
      PreparedReviewBatch.fromReviews(
        scope: scope,
        preferences: QuizPreferences(
          sessionLength: length,
          ordering: QuizOrdering.interleavedTail,
        ),
        localDay: now,
        orderedDueReviews: await content
            .hydrateSelectedQuestions([for (var n = 1; n <= 12; n++) 'q$n']),
      );
  Future<ReviewBatchSession?> start({
    PreparedReviewBatch? prepared,
    bool Function()? guard,
  }) async =>
      batches.start(
        prepared: prepared ?? await prepare(),
        content: content,
        now: now,
        canPersist: guard ?? () => true,
      );
  Future<String?> stored() async =>
      (await (db.select(db.devicePrefs)..where((p) => p.key.equals(key)))
              .getSingleOrNull())
          ?.value;
  Future<QuizSession> finish(QuizSession session) async {
    var answered = session;
    for (final question in session.questions) {
      final outcome = AnswerOutcome(
        questionId: question.id,
        questionVersion: question.version,
        chosenChoiceId: question.correctChoice.id,
        correctChoiceId: question.correctChoice.id,
        responseMs: 1000,
      );
      await sessions.recordAnswer(
        sessionId: session.sessionId,
        outcome: outcome,
        answeredAt: now,
      );
      answered = answered.record(outcome);
    }
    await QuizCompletionCoordinator(
      attempts: AttemptsRepository(db),
      sessions: sessions,
    ).complete(session: answered, now: now, persisted: true);
    return answered;
  }

  test(
      'packs actual whole groups under cap, excludes '
      'oversized sets, All stays one chunk', () async {
    final questions = await content
        .hydrateSelectedQuestions([for (var n = 1; n <= 12; n++) 'q$n']);
    final reviews = [
      questions[0],
      for (var n = 1; n <= 3; n++) questions[n].copyWith(passageId: 'p'),
      questions[4],
      for (var n = 5; n <= 10; n++)
        questions[n].copyWith(passageId: 'oversize'),
      questions[11],
    ];
    final prepared = PreparedReviewBatch.fromReviews(
      scope: scope,
      preferences:
          QuizPreferences(sessionLength: 5, ordering: QuizOrdering.blocked),
      localDay: now,
      orderedDueReviews: reviews,
    );
    expect(prepared.chunks.map((c) => c.map((q) => q.id).toList()).toList(), [
      ['q1', 'q2', 'q3', 'q4', 'q5'],
      ['q12'],
    ]);
    expect(
      prepared.excludedQuestionIds,
      ['q6', 'q7', 'q8', 'q9', 'q10', 'q11'],
    );
    final all = PreparedReviewBatch.fromReviews(
      scope: scope,
      preferences:
          QuizPreferences(sessionLength: -1, ordering: QuizOrdering.blocked),
      localDay: now,
      orderedDueReviews: reviews,
    );
    expect(all.chunks.length, 1);
    expect(all.chunks.single.length, 12);
  });

  test('freezes membership, captures versions and persists actual 3 sessions',
      () async {
    final first = (await start())!;
    expect(first.ordinal, 1);
    expect(first.total, 3);
    expect(
      first.session.questions.map((q) => q.id),
      ['q1', 'q2', 'q3', 'q4', 'q5'],
    );
    expect((await db.select(db.quizSessions).get()).length, 1);
    final json = jsonDecode((await stored())!) as Map<String, dynamic>;
    expect(json['sessionLength'], 5);
    expect(json['batchId'], first.session.sessionId);
    expect(
      (await start(prepared: await prepare(length: 10)))!.session.sessionId,
      first.session.sessionId,
    );
    expect(await stored(), jsonEncode(json));
  });

  test(
      'cancel during transaction rolls back metadata and '
      'first session together', () async {
    var calls = 0;
    expect(await start(guard: () => ++calls < 4), isNull);
    expect(await stored(), isNull);
    expect(await db.select(db.quizSessions).get(), isEmpty);
  });

  test(
      'duplicate concurrent starts return the same '
      'authoritative active session', () async {
    final prepared = await prepare();
    final results = await Future.wait(
      [start(prepared: prepared), start(prepared: prepared)],
    );
    expect(results[0]!.session.sessionId, results[1]!.session.sessionId);
    expect((await db.select(db.quizSessions).get()).length, 1);
  });

  test(
      'completion advances atomically and explicit '
      'concurrent Continue claims one next row', () async {
    final first = (await start())!;
    await finish(first.session);
    expect((await db.select(db.quizSessions).get()).length, 1);
    final before = await stored();
    final resumed = ReviewBatchRepository(db, currentScope: (_, __) => scope);
    final results = await Future.wait([
      resumed.continueBatch(
        scope: scope,
        content: content,
        now: now.add(const Duration(days: 1)),
        canPersist: () => true,
      ),
      resumed.continueBatch(
        scope: scope,
        content: content,
        now: now,
        canPersist: () => true,
      ),
    ]);
    expect(results[0]!.ordinal, 2);
    expect(results[0]!.total, 3);
    expect(results[0]!.session.sessionId, results[1]!.session.sessionId);
    expect(
      results[0]!.session.questions.map((q) => q.id),
      ['q6', 'q7', 'q8', 'q9', 'q10'],
    );
    expect((await db.select(db.quizSessions).get()).length, 2);
    expect(await stored(), isNot(before));
  });

  test('failed metadata terminal write rolls back Attempt and completedAt',
      () async {
    final first = (await start())!;
    await db.customStatement(
      'CREATE TRIGGER reject_batch_update BEFORE UPDATE ON '
      "device_prefs BEGIN SELECT RAISE(ABORT, 'test failure'); END",
    );
    await expectLater(finish(first.session), throwsA(anything));
    expect(await AttemptsRepository(db).byId(first.session.sessionId), isNull);
    expect(await sessions.completedAtFor(first.session.sessionId), isNull);
    final state = jsonDecode((await stored())!) as Map<String, dynamic>;
    expect(state['nextReady'], false);
  });

  test('next create failure rolls back lifecycle and retry claims stored chunk',
      () async {
    final first = (await start())!;
    await finish(first.session);
    final before = await stored();
    await db.customStatement(
      'CREATE TRIGGER reject_session BEFORE INSERT ON '
      "quiz_sessions BEGIN SELECT RAISE(ABORT, 'test failure'); END",
    );
    await expectLater(
      batches.continueBatch(
        scope: scope,
        content: content,
        now: now,
        canPersist: () => true,
      ),
      throwsA(anything),
    );
    expect(await stored(), before);
    expect((await db.select(db.quizSessions).get()).length, 1);
    await db.customStatement('DROP TRIGGER reject_session');
    expect(
      (await batches.continueBatch(
        scope: scope,
        content: content,
        now: now,
        canPersist: () => true,
      ))!
          .ordinal,
      2,
    );
  });

  test('never quits a different custom session to claim Reviews', () async {
    await sessions.create(
      sessionId: 'custom',
      userId: 'local',
      examId: 'exam',
      origin: SessionOrigin.drill,
      questionIds: ['q12'],
      startedAt: now,
    );
    await expectLater(start(), throwsStateError);
    expect(
      (await sessions.activeFor(userId: 'local', examId: 'exam'))!.id,
      'custom',
    );
    expect(await stored(), isNull);
  });

  test('changed lifetime during hydration cancels without writes', () async {
    final prepared = await prepare();
    scope = const ReviewBatchScope(
      userId: 'local',
      examId: 'exam',
      principal: 'anonymous:one',
      accountLifetimeToken: 'anonymous:one:1',
    );
    expect(await start(prepared: prepared), isNull);
    expect(await stored(), isNull);
    expect(await db.select(db.quizSessions).get(), isEmpty);
  });

  test(
      'wrong principal cannot use metadata without changing '
      'authoritative progress', () async {
    final first = (await start())!;
    scope = const ReviewBatchScope(
      userId: 'local',
      examId: 'exam',
      principal: 'signed-in:two',
      accountLifetimeToken: 'signed-in:two:1',
    );
    await expectLater(
      batches.continueBatch(
        scope: scope,
        content: content,
        now: now,
        canPersist: () => true,
      ),
      throwsStateError,
    );
    expect(await stored(), isNotNull);
    expect(
      (await sessions.activeFor(userId: 'local', examId: 'exam'))!.id,
      first.session.sessionId,
    );
  });

  test(
      'missing content blocks resume with saved membership '
      'and answers unchanged', () async {
    await start();
    final before = await stored();
    await (contentDb.delete(contentDb.contentQuestions)
          ..where((q) => q.id.equals('q3')))
        .go();
    await expectLater(
      ResumeSession(content: content, sessions: sessions)(
        userId: 'local',
        examId: 'exam',
      ),
      throwsStateError,
    );
    expect(await stored(), before);
    expect(
      (await sessions.activeFor(userId: 'local', examId: 'exam'))!.questionIds,
      ['q1', 'q2', 'q3', 'q4', 'q5'],
    );
  });

  test('revised content blocks batch resume and retains original versions',
      () async {
    await start();
    final before = await stored();
    await (contentDb.update(contentDb.contentQuestions)
          ..where((q) => q.id.equals('q2')))
        .write(const ContentQuestionsCompanion(version: Value(2)));
    await expectLater(
      ResumeSession(content: content, sessions: sessions)(
        userId: 'local',
        examId: 'exam',
      ),
      throwsStateError,
    );
    expect(await stored(), before);
  });

  test(
      'malformed metadata cannot claim next and keeps active '
      'row for explicit discard', () async {
    final first = (await start())!;
    await (db.update(db.devicePrefs)..where((p) => p.key.equals(key)))
        .write(const DevicePrefsCompanion(value: Value('{broken')));
    await expectLater(
      batches.continueBatch(
        scope: scope,
        content: content,
        now: now,
        canPersist: () => true,
      ),
      throwsStateError,
    );
    expect(
      (await sessions.activeFor(userId: 'local', examId: 'exam'))!.id,
      first.session.sessionId,
    );
    await sessions.quitAllOpen(userId: 'local', examId: 'exam', quitAt: now);
    expect(await stored(), isNull);
  });

  test(
      'final completion removes metadata, earlier duplicate '
      'completion cannot advance twice', () async {
    final first = (await start())!;
    await finish(first.session);
    final before = await stored();
    await sessions.completeRequired(
      sessionId: first.session.sessionId,
      completedAt: now,
    );
    expect(await stored(), before);
    final second = (await batches.continueBatch(
      scope: scope,
      content: content,
      now: now,
      canPersist: () => true,
    ))!;
    await finish(second.session);
    final third = (await batches.continueBatch(
      scope: scope,
      content: content,
      now: now,
      canPersist: () => true,
    ))!;
    expect(third.ordinal, 3);
    await finish(third.session);
    expect(await stored(), isNull);
    expect(third.total, 3);
    expect(await AttemptsRepository(db).countForExam('exam'), 3);
  });
  test('ordinary create cannot silently discard an unfinished Reviews batch',
      () async {
    final first = (await start())!;
    final before = await stored();
    await expectLater(
      sessions.create(
        sessionId: 'custom',
        userId: 'local',
        examId: 'exam',
        origin: SessionOrigin.drill,
        questionIds: ['q12'],
        startedAt: now,
      ),
      throwsStateError,
    );
    expect(
      (await sessions.activeFor(userId: 'local', examId: 'exam'))!.id,
      first.session.sessionId,
    );
    expect(await stored(), before);
    expect((await db.select(db.quizSessions).get()).length, 1);
  });

  test('actual account wipe leaves prefs and next use removes orphan metadata',
      () async {
    await start();
    await SyncLocalStateWiper(db).wipeAll();
    expect(await stored(), isNotNull);
    await expectLater(
      batches.continueBatch(
        scope: scope,
        content: content,
        now: now,
        canPersist: () => true,
      ),
      throwsStateError,
    );
    expect(await stored(), isNull);
    expect(await db.select(db.quizSessions).get(), isEmpty);
  });

  test('lifetime change while content is awaited rolls back first session',
      () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    final delayed = _DelayedContent(contentDb, () async {
      entered.complete();
      await release.future;
    });
    final prepared = await prepare();
    final pending = batches.start(
      prepared: prepared,
      content: delayed,
      now: now,
      canPersist: () => true,
    );
    await entered.future;
    scope = const ReviewBatchScope(
      userId: 'local',
      examId: 'exam',
      principal: 'anonymous:one',
      accountLifetimeToken: 'anonymous:one:1',
    );
    release.complete();
    expect(await pending, isNull);
    expect(await stored(), isNull);
    expect(await db.select(db.quizSessions).get(), isEmpty);
  });

  test('different exam cannot claim an existing batch', () async {
    final first = (await start())!;
    const other = ReviewBatchScope(
      userId: 'local',
      examId: 'other',
      principal: 'anonymous:one',
      accountLifetimeToken: 'anonymous:one:0',
    );
    expect(
      await batches.continueBatch(
        scope: other,
        content: content,
        now: now,
        canPersist: () => true,
      ),
      isNull,
    );
    expect(
      (await sessions.activeFor(userId: 'local', examId: 'exam'))!.id,
      first.session.sessionId,
    );
    expect(await stored(), isNotNull);
  });

  test(
      'legacy resume rejects missing IDs rather than shrinking saved questions',
      () async {
    await sessions.create(
      sessionId: 'legacy',
      userId: 'local',
      examId: 'exam',
      origin: SessionOrigin.drill,
      questionIds: ['q1', 'missing', 'q2'],
      startedAt: now,
    );
    await expectLater(
      ResumeSession(content: content, sessions: sessions)(
        userId: 'local',
        examId: 'exam',
      ),
      throwsStateError,
    );
    expect(
      (await sessions.activeFor(userId: 'local', examId: 'exam'))!.questionIds,
      ['q1', 'missing', 'q2'],
    );
  });

  test('completion account change rolls back Attempt and batch state',
      () async {
    final first = (await start())!;
    var answered = first.session;
    for (final q in first.session.questions) {
      final outcome = AnswerOutcome(
        questionId: q.id,
        questionVersion: q.version,
        chosenChoiceId: q.correctChoice.id,
        correctChoiceId: q.correctChoice.id,
        responseMs: 1000,
      );
      await sessions.recordAnswer(
        sessionId: first.session.sessionId,
        outcome: outcome,
        answeredAt: now,
      );
      answered = answered.record(outcome);
    }
    final before = await stored();
    final attempts = _ChangingAttempts(db, () {
      scope = const ReviewBatchScope(
        userId: 'local',
        examId: 'exam',
        principal: 'anonymous:one',
        accountLifetimeToken: 'anonymous:one:1',
      );
    });
    await expectLater(
      QuizCompletionCoordinator(attempts: attempts, sessions: sessions)
          .complete(session: answered, now: now, persisted: true),
      throwsStateError,
    );
    expect(await stored(), before);
    expect(await attempts.byId(first.session.sessionId), isNull);
    expect(await sessions.completedAtFor(first.session.sessionId), isNull);
  });

  test(
      'completion cannot save a different question order '
      'under a batch session ID', () async {
    final first = (await start())!;
    var answered = first.session;
    for (final q in first.session.questions) {
      final outcome = AnswerOutcome(
        questionId: q.id,
        questionVersion: q.version,
        chosenChoiceId: q.correctChoice.id,
        correctChoiceId: q.correctChoice.id,
        responseMs: 1000,
      );
      await sessions.recordAnswer(
        sessionId: first.session.sessionId,
        outcome: outcome,
        answeredAt: now,
      );
      answered = answered.record(outcome);
    }
    final before = await stored();
    await expectLater(
      QuizCompletionCoordinator(
        attempts: AttemptsRepository(db),
        sessions: sessions,
      ).complete(
        session: answered.copyWith(
          questions: answered.questions.reversed.toList(),
        ),
        now: now,
        persisted: true,
      ),
      throwsStateError,
    );
    expect(await stored(), before);
    expect(await AttemptsRepository(db).byId(first.session.sessionId), isNull);
  });

  test(
      'packing closes a shorter chunk before a whole passage '
      'exceeds remaining room', () async {
    final questions = await content
        .hydrateSelectedQuestions(['q1', 'q2', 'q3', 'q4', 'q5', 'q6']);
    final prepared = PreparedReviewBatch.fromReviews(
      scope: scope,
      preferences:
          QuizPreferences(sessionLength: 5, ordering: QuizOrdering.blocked),
      localDay: now,
      orderedDueReviews: [
        for (var i = 0; i < questions.length; i++)
          questions[i].copyWith(passageId: i < 3 ? 'a' : 'b'),
      ],
    );
    expect(prepared.chunks.map((c) => c.map((q) => q.id).toList()).toList(), [
      ['q1', 'q2', 'q3'],
      ['q4', 'q5', 'q6'],
    ]);
  });

  test(
      'strict parser rejects malformed lifecycle, types, '
      'scope and duplicate membership', () async {
    await start();
    final original = (await stored())!;
    final mutations = <void Function(Map<String, dynamic>)>[
      (m) => m['version'] = 2,
      (m) => m['version'] = '1',
      (m) => m['current'] = -1,
      (m) => m['current'] = 3,
      (m) => m['current'] = 0.0,
      (m) => m['nextReady'] = 1,
      (m) => m['nextReady'] = true,
      (m) => m['sessionLength'] = 7,
      (m) => m['userId'] = 'another',
      (m) => m['examId'] = 'another',
      (m) => m['ordering'] = 'unknown',
      (m) => m['chunks'] = <Object>[],
      (m) => m['versions'] = [
            [1],
            [1],
            [1],
          ],
      (m) => m['chunks'] = [
            ['q1', 'q1'],
            ['q6'],
            ['q11'],
          ],
      (m) => m['sessionIds'] = ['same', 'same', 'same'],
    ];
    for (final mutate in mutations) {
      final data = jsonDecode(original) as Map<String, dynamic>;
      mutate(data);
      await (db.update(db.devicePrefs)..where((p) => p.key.equals(key)))
          .write(DevicePrefsCompanion(value: Value(jsonEncode(data))));
      await expectLater(
        batches.continueBatch(
          scope: scope,
          content: content,
          now: now,
          canPersist: () => true,
        ),
        throwsStateError,
      );
      expect((await db.select(db.quizSessions).get()).length, 1);
    }
  });

  test(
      'ordinary resume retains actual batch ordinal and '
      'completion keeps that snapshot', () async {
    final first = (await start())!;
    final resumed = (await ResumeSession(content: content, sessions: sessions)(
      userId: 'local',
      examId: 'exam',
    ))!;
    expect(resumed.reviewBatch!.ordinal, 1);
    expect(resumed.reviewBatch!.total, 3);
    expect(resumed.reviewBatch!.batchId, first.session.sessionId);
    await finish(first.session);
    final second = (await batches.continueBatch(
      scope: scope,
      content: content,
      now: now,
      canPersist: () => true,
    ))!;
    expect(second.session.reviewBatch!.ordinal, 2);
    expect(resumed.reviewBatch!.ordinal, 1);
  });
  test(
      'wrong-principal repeated resume stays blocked until '
      'original principal returns', () async {
    final first = (await start())!;
    final original = scope;
    final before = await stored();
    scope = const ReviewBatchScope(
      userId: 'local',
      examId: 'exam',
      principal: 'signed-in:two',
      accountLifetimeToken: 'signed-in:two:1',
    );
    for (var i = 0; i < 2; i++) {
      await expectLater(
        ResumeSession(content: content, sessions: sessions)(
          userId: 'local',
          examId: 'exam',
        ),
        throwsStateError,
      );
      expect(await stored(), before);
    }
    scope = original;
    expect(
      (await ResumeSession(content: content, sessions: sessions)(
        userId: 'local',
        examId: 'exam',
      ))!
          .sessionId,
      first.session.sessionId,
    );
  });

  test(
      'metadata schema version requires an integer rather than an equal double',
      () async {
    await start();
    final data = jsonDecode((await stored())!) as Map<String, dynamic>;
    data['version'] = 1.0;
    await (db.update(db.devicePrefs)..where((p) => p.key.equals(key)))
        .write(DevicePrefsCompanion(value: Value(jsonEncode(data))));
    await expectLater(
      batches.continueBatch(
        scope: scope,
        content: content,
        now: now,
        canPersist: () => true,
      ),
      throwsStateError,
    );
  });

  test('stale historical quit cannot delete a newer active Reviews batch',
      () async {
    await sessions.create(
      sessionId: 'old',
      userId: 'local',
      examId: 'exam',
      origin: SessionOrigin.drill,
      questionIds: ['q12'],
      startedAt: now,
    );
    await sessions.quit(sessionId: 'old', quitAt: now);
    final first = (await start())!;
    final before = await stored();
    await sessions.quit(sessionId: 'old', quitAt: now);
    expect(await stored(), before);
    expect(
      (await sessions.activeFor(userId: 'local', examId: 'exam'))!.id,
      first.session.sessionId,
    );
  });

  test(
      'ordinary quiz between chunks preserves Reviews and '
      'Continue never quits it', () async {
    final first = (await start())!;
    await finish(first.session);
    final before = await stored();
    await sessions.create(
      sessionId: 'custom',
      userId: 'local',
      examId: 'exam',
      origin: SessionOrigin.drill,
      questionIds: ['q12'],
      startedAt: now,
    );
    expect(await stored(), before);
    await expectLater(
      batches.continueBatch(
        scope: scope,
        content: content,
        now: now,
        canPersist: () => true,
      ),
      throwsStateError,
    );
    expect(
      (await sessions.activeFor(userId: 'local', examId: 'exam'))!.id,
      'custom',
    );
    await sessions.quit(sessionId: 'custom', quitAt: now);
    expect(await stored(), before);
    expect(
      (await batches.continueBatch(
        scope: scope,
        content: content,
        now: now,
        canPersist: () => true,
      ))!
          .ordinal,
      2,
    );
  });

  test('resume guards lifetime from before its first database await', () async {
    await start();
    final delayed = _DelayedSessions(db, batches, () async {
      scope = const ReviewBatchScope(
        userId: 'local',
        examId: 'exam',
        principal: 'anonymous:one',
        accountLifetimeToken: 'anonymous:one:1',
      );
    });
    await expectLater(
      ResumeSession(content: content, sessions: delayed)(
        userId: 'local',
        examId: 'exam',
      ),
      throwsStateError,
    );
  });

  test('another principal cannot discard an anchored batch or its saved row',
      () async {
    final first = (await start())!;
    final before = await stored();
    scope = const ReviewBatchScope(
      userId: 'local',
      examId: 'exam',
      principal: 'signed-in:two',
      accountLifetimeToken: 'signed-in:two:1',
    );
    await expectLater(
      sessions.quitAllOpen(userId: 'local', examId: 'exam', quitAt: now),
      throwsStateError,
    );
    expect(await stored(), before);
    expect(
      (await sessions.activeFor(userId: 'local', examId: 'exam'))!.id,
      first.session.sessionId,
    );
  });

  test(
      'explicit inter-chunk discard preserves unrelated quiz '
      'and frees Reviews key', () async {
    final first = (await start())!;
    await finish(first.session);
    await sessions.create(
      sessionId: 'custom',
      userId: 'local',
      examId: 'exam',
      origin: SessionOrigin.drill,
      questionIds: ['q12'],
      startedAt: now,
    );
    await batches.discardBatch(scope: scope, now: now);
    expect(await stored(), isNull);
    expect(
      (await sessions.activeFor(userId: 'local', examId: 'exam'))!.id,
      'custom',
    );
  });

  test(
      'completing ordinary quiz between chunks leaves Reviews lifecycle intact',
      () async {
    final first = (await start())!;
    await finish(first.session);
    final before = await stored();
    await sessions.create(
      sessionId: 'custom',
      userId: 'local',
      examId: 'exam',
      origin: SessionOrigin.drill,
      questionIds: ['q12'],
      startedAt: now,
    );
    final custom = (await ResumeSession(content: content, sessions: sessions)(
      userId: 'local',
      examId: 'exam',
    ))!;
    expect(custom.reviewBatch, isNull);
    await finish(custom);
    expect(await stored(), before);
    expect(
      (await batches.continueBatch(
        scope: scope,
        content: content,
        now: now,
        canPersist: () => true,
      ))!
          .ordinal,
      2,
    );
  });

  test('first metadata write failure rolls back its new ordinary session row',
      () async {
    await db.customStatement(
      'CREATE TRIGGER reject_batch_insert BEFORE INSERT ON '
      "device_prefs BEGIN SELECT RAISE(ABORT, 'test failure'); END",
    );
    await expectLater(start(), throwsA(anything));
    expect(await stored(), isNull);
    expect(await db.select(db.quizSessions).get(), isEmpty);
  });
  test('completion guards lifetime before its first metadata database await',
      () async {
    final first = (await start())!;
    var answered = first.session;
    for (final q in first.session.questions) {
      final outcome = AnswerOutcome(
        questionId: q.id,
        questionVersion: q.version,
        chosenChoiceId: q.correctChoice.id,
        correctChoiceId: q.correctChoice.id,
        responseMs: 1000,
      );
      await sessions.recordAnswer(
        sessionId: first.session.sessionId,
        outcome: outcome,
        answeredAt: now,
      );
      answered = answered.record(outcome);
    }
    final before = await stored();
    final pending = QuizCompletionCoordinator(
      attempts: AttemptsRepository(db),
      sessions: sessions,
    ).complete(session: answered, now: now, persisted: true);
    scheduleMicrotask(() {
      scope = const ReviewBatchScope(
        userId: 'local',
        examId: 'exam',
        principal: 'anonymous:one',
        accountLifetimeToken: 'anonymous:one:1',
      );
    });
    await expectLater(pending, throwsStateError);
    expect(await stored(), before);
    expect(await AttemptsRepository(db).byId(first.session.sessionId), isNull);
  });

  test('explicit malformed batch discard keeps ordinary progress available',
      () async {
    final first = (await start())!;
    await finish(first.session);
    await sessions.create(
      sessionId: 'custom',
      userId: 'local',
      examId: 'exam',
      origin: SessionOrigin.drill,
      questionIds: ['q12'],
      startedAt: now,
    );
    await (db.update(db.devicePrefs)..where((p) => p.key.equals(key)))
        .write(const DevicePrefsCompanion(value: Value('{broken')));
    await batches.discardBatch(scope: scope, now: now);
    expect(await stored(), isNull);
    expect(
      (await sessions.activeFor(userId: 'local', examId: 'exam'))!.id,
      'custom',
    );
  });
  test('stale completed screen cannot claim the third session', () async {
    final first = (await start())!;
    final completed = await finish(first.session);
    final second = (await batches.continueBatch(
      scope: scope,
      content: content,
      now: now,
      canPersist: () => true,
      after: completed,
    ))!;
    await finish(second.session);
    final before = await stored();
    await expectLater(
      batches.continueBatch(
        scope: scope,
        content: content,
        now: now,
        canPersist: () => true,
        after: completed,
      ),
      throwsStateError,
    );
    expect(await stored(), before);
    expect(completed.reviewBatch!.ordinal, 1);
  });
  test('explicit next duplicates retain one row and reject changed answers',
      () async {
    final first = (await start())!;
    final completed = await finish(first.session);
    final invalid = completed.copyWith(
      outcomes: [
        completed.outcomes.first.copyWith(responseMs: 999),
        ...completed.outcomes.skip(1),
      ],
    );
    final before = await stored();
    await expectLater(
      batches.continueBatch(
        scope: scope,
        content: content,
        now: now,
        canPersist: () => true,
        after: invalid,
      ),
      throwsStateError,
    );
    expect(await stored(), before);
    final second = (await batches.continueBatch(
      scope: scope,
      content: content,
      now: now,
      canPersist: () => true,
      after: completed,
    ))!;
    final repeated = (await batches.continueBatch(
      scope: scope,
      content: content,
      now: now,
      canPersist: () => true,
      after: completed,
    ))!;
    expect(repeated.session.sessionId, second.session.sessionId);
    expect((await db.select(db.quizSessions).get()).length, 2);
  });
}

class _DelayedContent extends ContentRepository {
  _DelayedContent(super.db, this.beforeHydrate);
  final Future<void> Function() beforeHydrate;
  @override
  Future<List<Question>> hydrateSelectedQuestions(List<String> ids) async {
    await beforeHydrate();
    return super.hydrateSelectedQuestions(ids);
  }
}

class _ChangingAttempts extends AttemptsRepository {
  _ChangingAttempts(super.db, this.beforeWrite);
  final void Function() beforeWrite;
  @override
  Future<T> saveAtomically<T>(
    Attempt attempt,
    Future<T> Function() afterWrite,
  ) {
    beforeWrite();
    return super.saveAtomically(attempt, afterWrite);
  }
}

class _DelayedSessions extends QuizSessionRepository {
  _DelayedSessions(
    super.db,
    ReviewBatchRepository batches,
    this.afterActive,
  ) : super(reviewBatches: batches);
  final Future<void> Function() afterActive;
  @override
  Future<QuizSessionLocalRow?> activeFor({
    required String userId,
    required String examId,
  }) async {
    final row = await super.activeFor(userId: userId, examId: examId);
    await afterActive();
    return row;
  }
}

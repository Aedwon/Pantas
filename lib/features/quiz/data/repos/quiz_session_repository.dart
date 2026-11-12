import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pantas/core/fsrs/rating.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/quiz/data/repos/review_batch_repository.dart';
import 'package:pantas/features/quiz/domain/models/review_batch.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';

/// Receives the description of a repair made to stored quiz state.
typedef SessionRepairReporter = void Function(Object error, StackTrace stack);

class QuizSessionRepository {
  QuizSessionRepository(
    this._db, {
    ReviewBatchRepository? reviewBatches,
    this.onRepair,
  }) : reviewBatches = reviewBatches ?? ReviewBatchRepository(_db);

  /// Told whenever a stored session had to be repaired on read, so the repair
  /// reaches telemetry. It must never throw.
  final SessionRepairReporter? onRepair;

  final ReviewBatchRepository reviewBatches;

  final AppDatabase _db;

  /// Starting a session closes whatever was left open for the same exam.
  ///
  /// **This is the one place it can be done once.** Six use cases create a
  /// session and only one of them, restart, closed the previous one, so an
  /// abandoned session stayed open forever. `activeFor` reads the newest and
  /// only the newest, so the app never had a use for two at once: the extras
  /// were invisible until Discard had to close them one at a time.
  Future<void> create({
    required String sessionId,
    required String userId,
    required ExamId examId,
    required SessionOrigin origin,
    required List<QuestionId> questionIds,
    required DateTime startedAt,
    TopicId? topicId,
    SubtopicId? subtopicId,
    LessonId? lessonId,
  }) async {
    final created = await createGuarded(
      sessionId: sessionId,
      userId: userId,
      examId: examId,
      origin: origin,
      questionIds: questionIds,
      startedAt: startedAt,
      topicId: topicId,
      subtopicId: subtopicId,
      lessonId: lessonId,
      canPersist: () => true,
    );
    if (!created) {
      throw StateError('Unconditional quiz session creation was cancelled');
    }
  }

  Future<bool> createGuarded({
    required String sessionId,
    required String userId,
    required ExamId examId,
    required SessionOrigin origin,
    required List<QuestionId> questionIds,
    required DateTime startedAt,
    required FutureOr<bool> Function() canPersist,
    TopicId? topicId,
    SubtopicId? subtopicId,
    LessonId? lessonId,
  }) async {
    try {
      await _db.transaction(() async {
        if (!await canPersist()) throw const _QuizSessionCreateCancelled();

        await reviewBatches.requireNoBatch(userId, examId);
        await quitAllOpen(
          userId: userId,
          examId: examId,
          quitAt: startedAt,
        );

        if (!await canPersist()) throw const _QuizSessionCreateCancelled();

        await _db.into(_db.quizSessions).insert(
              QuizSessionsCompanion.insert(
                id: sessionId,
                userId: userId,
                examId: examId,
                origin: origin.storageValue,
                topicId: Value(topicId),
                subtopicId: Value(subtopicId),
                lessonId: Value(lessonId),
                questionIdsJson: jsonEncode(questionIds),
                startedAt: startedAt,
              ),
            );

        if (!await canPersist()) throw const _QuizSessionCreateCancelled();
      });
      return true;
    } on _QuizSessionCreateCancelled {
      return false;
    }
  }

  Future<QuizSessionLocalRow?> activeFor({
    required String userId,
    required ExamId examId,
  }) async {
    final row = await (_db.select(_db.quizSessions)
          ..where(
            (row) =>
                row.userId.equals(userId) &
                row.examId.equals(examId) &
                row.completedAt.isNull() &
                row.quitAt.isNull(),
          )
          ..orderBy([(row) => OrderingTerm.desc(row.startedAt)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    return repairSessionRow(_db, row, report: onRepair);
  }

  Future<void> recordAnswer({
    required String sessionId,
    required AnswerOutcome outcome,
    required DateTime answeredAt,
  }) async {
    await _db.transaction(() async {
      final stored = await (_db.select(_db.quizSessions)
            ..where((table) => table.id.equals(sessionId)))
          .getSingle();
      // A stored position that disagrees with the stored answers is repaired
      // here, so one bad row can no longer make every save fail.
      final row = stored.completedAt == null && stored.quitAt == null
          ? await repairSessionRow(_db, stored, report: onRepair)
          : stored;
      final questionIds = row.questionIds;
      final outcomes = row.outcomes;
      final at = questionIds.indexOf(outcome.questionId);
      if (at >= 0 && at < outcomes.length) {
        // Already stored at its own position, for example by another write
        // that half-succeeded. Saving it again would only duplicate it.
        return;
      }
      if (at < 0) {
        // The session does not hold this question. The review itself is
        // already saved, and there is no place in this session for it.
        onRepair?.call(
          StateError('quiz session $sessionId does not hold the answered item'),
          StackTrace.current,
        );
        return;
      }
      if (row.currentIndex != outcomes.length ||
          row.currentIndex >= questionIds.length ||
          questionIds[row.currentIndex] != outcome.questionId) {
        throw StateError(
          'Persisted quiz session $sessionId answer order is inconsistent',
        );
      }
      await (_db.update(_db.quizSessions)
            ..where((table) => table.id.equals(sessionId)))
          .write(
        QuizSessionsCompanion(
          outcomesJson: Value(
            jsonEncode([
              ...outcomes.map(encodeOutcome),
              encodeOutcome(outcome),
            ]),
          ),
          currentIndex: Value(row.currentIndex + 1),
          correctCount: Value(row.correctCount + (outcome.isCorrect ? 1 : 0)),
          lastAnsweredAt: Value(answeredAt),
        ),
      );
    });
  }

  /// Keeps only [keptQuestionIds] (in their stored order) in an open session,
  /// for a question that left the content. Answers to the dropped questions
  /// go with them; the rest stay in place.
  Future<void> keepQuestions(
    String sessionId,
    List<QuestionId> keptQuestionIds,
  ) =>
      _db.transaction(() async {
        final row = await (_db.select(_db.quizSessions)
              ..where((r) => r.id.equals(sessionId)))
            .getSingleOrNull();
        if (row == null) return;
        final kept = {...keptQuestionIds};
        final ids = [
          for (final id in row.questionIds)
            if (kept.contains(id)) id,
        ];
        final answers = <AnswerOutcome>[];
        try {
          answers
              .addAll(row.outcomes.where((o) => kept.contains(o.questionId)));
        } on Object {
          // Unreadable answers are cleared by the repair below.
        }
        await (_db.update(_db.quizSessions)
              ..where((r) => r.id.equals(sessionId)))
            .write(
          QuizSessionsCompanion(
            questionIdsJson: Value(jsonEncode(ids)),
            outcomesJson:
                Value(jsonEncode(answers.map(encodeOutcome).toList())),
          ),
        );
        final updated = await (_db.select(_db.quizSessions)
              ..where((r) => r.id.equals(sessionId)))
            .getSingle();
        await repairSessionRow(_db, updated, report: onRepair);
        onRepair?.call(
          StateError(
            'quiz session $sessionId kept ${ids.length} of '
            '${row.questionIds.length} questions',
          ),
          StackTrace.current,
        );
      });

  Future<void> complete({
    required String sessionId,
    required DateTime completedAt,
  }) {
    return (_db.update(_db.quizSessions)
          ..where((row) => row.id.equals(sessionId)))
        .write(QuizSessionsCompanion(completedAt: Value(completedAt)));
  }

  Future<DateTime?> completedAtFor(String sessionId) async {
    final row = await (_db.select(_db.quizSessions)
          ..where((table) => table.id.equals(sessionId)))
        .getSingleOrNull();
    return row?.completedAt;
  }

  /// Completes exactly the expected open row. A missing row is a terminal
  /// integrity error so callers can roll back the paired Attempt write.
  Future<void> completeRequired({
    required String sessionId,
    required DateTime completedAt,
    ReviewBatchScope? reviewScope,
    QuizSession? session,
  }) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.quizSessions)
            ..where((table) => table.id.equals(sessionId)))
          .getSingleOrNull();
      if (row == null || row.quitAt != null) {
        throw StateError('Persisted quiz session $sessionId is not open');
      }
      if (row.completedAt != null) return;
      final scope =
          reviewScope ?? reviewBatches.capture(row.userId, row.examId);
      await reviewBatches.completeRow(row, scope, session);
      final changed = await (_db.update(_db.quizSessions)
            ..where(
              (table) =>
                  table.id.equals(sessionId) & table.completedAt.isNull(),
            ))
          .write(QuizSessionsCompanion(completedAt: Value(completedAt)));
      if (changed != 1) {
        throw StateError('Persisted quiz session $sessionId was not completed');
      }
      reviewBatches.checkScope(scope);
    });
  }

  Future<ReviewBatchScope?> captureReviewScope(String sessionId) async {
    final row = await (_db.select(_db.quizSessions)
          ..where((r) => r.id.equals(sessionId)))
        .getSingleOrNull();
    if (row == null) return null;
    final pref = await (_db.select(_db.devicePrefs)
          ..where(
            (p) =>
                p.key.equals(ReviewBatchRepository.key(row.userId, row.examId)),
          ))
        .getSingleOrNull();
    if (pref == null) return null;
    final scope = reviewBatches.capture(row.userId, row.examId);
    if (scope == null) throw StateError('Reviews account changed');
    return scope;
  }

  Future<StoredReviewBatch?> reviewBatchFor(
    QuizSessionLocalRow row,
    ReviewBatchScope? scope,
  ) =>
      _db.transaction(() => reviewBatches.forRow(row, scope));

  /// Closes every session still open for this exam, not only the newest.
  ///
  /// Nothing closed a session when the next one started, so an abandoned
  /// session stayed open forever and they stacked up. Discard then closed
  /// the newest of the pile and the panel immediately showed the one under
  /// it, which reads as the button not working.
  Future<int> quitAllOpen({
    required String userId,
    required ExamId examId,
    required DateTime quitAt,
  }) =>
      _db.transaction(() async {
        final open = await (_db.select(_db.quizSessions)
              ..where(
                (r) =>
                    r.userId.equals(userId) &
                    r.examId.equals(examId) &
                    r.completedAt.isNull() &
                    r.quitAt.isNull(),
              ))
            .get();
        await reviewBatches.discardForSessions(
          userId,
          examId,
          [for (final row in open) row.id],
        );
        return (_db.update(_db.quizSessions)
              ..where(
                (row) =>
                    row.userId.equals(userId) &
                    row.examId.equals(examId) &
                    row.completedAt.isNull() &
                    row.quitAt.isNull(),
              ))
            .write(QuizSessionsCompanion(quitAt: Value(quitAt)));
      });

  Future<void> quit({required String sessionId, required DateTime quitAt}) =>
      _db.transaction(() async {
        final row = await (_db.select(_db.quizSessions)
              ..where((r) => r.id.equals(sessionId)))
            .getSingleOrNull();
        if (row == null) return;
        await reviewBatches
            .discardForSessions(row.userId, row.examId, [row.id]);
        await (_db.update(_db.quizSessions)
              ..where((r) => r.id.equals(sessionId)))
            .write(QuizSessionsCompanion(quitAt: Value(quitAt)));
      });

  Future<void> restartActive({
    required String userId,
    required ExamId examId,
    required DateTime restartedAt,
  }) async {
    final active = await activeFor(userId: userId, examId: examId);
    if (active == null) return;
    await quit(sessionId: active.id, quitAt: restartedAt);
  }

  /// The student's own average completed session, in whole minutes, or null
  /// when there is not enough history to average honestly.
  ///
  /// Mocks are deliberately excluded. A mock runs 3 hours 30, so folding one
  /// in would put an hour on a ten-question panel. `SessionShapeSignal` does
  /// include them, and is the right figure for its own surface, but reading it
  /// from here would also cross a feature boundary.
  ///
  /// [minimumSessions] matches `SessionShapeSignal.minDataPoints` so the app
  /// has one answer to "how much history is enough".
  Future<int?> averageCompletedMinutes({
    required String userId,
    required ExamId examId,
    int minimumSessions = 7,
  }) async {
    final rows = await (_db.select(_db.quizSessions)
          ..where(
            (row) =>
                row.userId.equals(userId) &
                row.examId.equals(examId) &
                row.completedAt.isNotNull(),
          ))
        .get();
    if (rows.length < minimumSessions) return null;

    var totalSeconds = 0;
    for (final row in rows) {
      totalSeconds += row.completedAt!.difference(row.startedAt).inSeconds;
    }
    return (totalSeconds / rows.length / 60).round();
  }
}

extension QuizSessionLocalRowQuestionIds on QuizSessionLocalRow {
  List<QuestionId> get questionIds =>
      (jsonDecode(questionIdsJson) as List).cast<QuestionId>();

  List<AnswerOutcome> get outcomes {
    final decoded = jsonDecode(outcomesJson);
    if (decoded is! List) {
      throw const FormatException(
        'quiz session outcomes must be a list',
      );
    }
    return [
      for (final value in decoded)
        _decodeOutcome((value as Map).cast<String, Object?>()),
    ];
  }
}

Map<String, Object> encodeOutcome(AnswerOutcome outcome) => {
      'questionId': outcome.questionId,
      'questionVersion': outcome.questionVersion,
      'chosenChoiceId': outcome.chosenChoiceId,
      'correctChoiceId': outcome.correctChoiceId,
      'responseMs': outcome.responseMs,
      'derivedRating': outcome.derivedRating.grade,
      'nextReviewIntervalDays': outcome.nextReviewIntervalDays,
    };

AnswerOutcome _decodeOutcome(Map<String, Object?> json) => AnswerOutcome(
      questionId: json['questionId']! as String,
      questionVersion: json['questionVersion']! as int,
      chosenChoiceId: json['chosenChoiceId']! as String,
      correctChoiceId: json['correctChoiceId']! as String,
      responseMs: json['responseMs']! as int,
      derivedRating: Rating.fromGrade(json['derivedRating']! as int),
      nextReviewIntervalDays: json['nextReviewIntervalDays']! as int,
    );

class _QuizSessionCreateCancelled implements Exception {
  const _QuizSessionCreateCancelled();
}

/// Brings an open session's stored answers and position back in line.
///
/// The answers must be the leading run that matches the session's own
/// questions, and the position must sit just after them. Anything else, such
/// as an answer for another question, unreadable answers or a position left
/// behind by a write that half-succeeded, used to make every save and every
/// resume of that session fail for good. Now the leading run that is valid is
/// kept, the rest is dropped, and [report] hears about it.
Future<QuizSessionLocalRow> repairSessionRow(
  AppDatabase db,
  QuizSessionLocalRow row, {
  SessionRepairReporter? report,
}) async {
  if (row.completedAt != null || row.quitAt != null) return row;
  final List<QuestionId> ids;
  try {
    ids = row.questionIds;
  } on Object {
    return row;
  }
  var unreadable = false;
  var outcomes = const <AnswerOutcome>[];
  try {
    outcomes = row.outcomes;
  } on Object {
    unreadable = true;
  }
  var valid = 0;
  while (valid < outcomes.length &&
      valid < ids.length &&
      outcomes[valid].questionId == ids[valid]) {
    valid++;
  }
  if (!unreadable && valid == outcomes.length && row.currentIndex == valid) {
    return row;
  }
  final kept = outcomes.take(valid).toList();
  await (db.update(db.quizSessions)..where((r) => r.id.equals(row.id))).write(
    QuizSessionsCompanion(
      outcomesJson: Value(jsonEncode(kept.map(encodeOutcome).toList())),
      currentIndex: Value(valid),
      correctCount: Value(kept.where((o) => o.isCorrect).length),
    ),
  );
  try {
    report?.call(
      StateError(
        'quiz session answers repaired: kept $valid of ${outcomes.length}, '
        'position was ${row.currentIndex}, unreadable $unreadable',
      ),
      StackTrace.current,
    );
  } on Object {
    // Reporting must never block a repair.
  }
  return (db.select(db.quizSessions)..where((r) => r.id.equals(row.id)))
      .getSingle();
}

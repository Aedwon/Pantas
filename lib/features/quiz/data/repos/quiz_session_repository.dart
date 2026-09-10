import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pantas/core/fsrs/rating.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';

class QuizSessionRepository {
  QuizSessionRepository(this._db);

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
    required bool Function() canPersist,
    TopicId? topicId,
    SubtopicId? subtopicId,
    LessonId? lessonId,
  }) async {
    try {
      await _db.transaction(() async {
        if (!canPersist()) throw const _QuizSessionCreateCancelled();

        await quitAllOpen(
          userId: userId,
          examId: examId,
          quitAt: startedAt,
        );

        if (!canPersist()) throw const _QuizSessionCreateCancelled();

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

        if (!canPersist()) throw const _QuizSessionCreateCancelled();
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
    return (_db.select(_db.quizSessions)
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
  }

  Future<void> recordAnswer({
    required String sessionId,
    required AnswerOutcome outcome,
    required DateTime answeredAt,
  }) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.quizSessions)
            ..where((table) => table.id.equals(sessionId)))
          .getSingle();
      final questionIds = row.questionIds;
      final outcomes = row.outcomes;
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
              ...outcomes.map(_encodeOutcome),
              _encodeOutcome(outcome),
            ]),
          ),
          currentIndex: Value(row.currentIndex + 1),
          correctCount: Value(row.correctCount + (outcome.isCorrect ? 1 : 0)),
          lastAnsweredAt: Value(answeredAt),
        ),
      );
    });
  }

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
  }) async {
    final row = await (_db.select(_db.quizSessions)
          ..where((table) => table.id.equals(sessionId)))
        .getSingleOrNull();
    if (row == null) {
      throw StateError('Persisted quiz session $sessionId does not exist');
    }
    if (row.completedAt != null) return;
    final changed = await (_db.update(_db.quizSessions)
          ..where(
            (table) => table.id.equals(sessionId) & table.completedAt.isNull(),
          ))
        .write(QuizSessionsCompanion(completedAt: Value(completedAt)));
    if (changed != 1) {
      throw StateError('Persisted quiz session $sessionId was not completed');
    }
  }

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
  }) {
    return (_db.update(_db.quizSessions)
          ..where(
            (row) =>
                row.userId.equals(userId) &
                row.examId.equals(examId) &
                row.completedAt.isNull() &
                row.quitAt.isNull(),
          ))
        .write(QuizSessionsCompanion(quitAt: Value(quitAt)));
  }

  Future<void> quit({required String sessionId, required DateTime quitAt}) {
    return (_db.update(_db.quizSessions)
          ..where((row) => row.id.equals(sessionId)))
        .write(QuizSessionsCompanion(quitAt: Value(quitAt)));
  }

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

Map<String, Object> _encodeOutcome(AnswerOutcome outcome) => {
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

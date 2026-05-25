import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/session_origin.dart';
import 'package:drift/drift.dart';

class QuizSessionRepository {
  QuizSessionRepository(this._db);

  final AppDatabase _db;

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
    required bool isCorrect,
    required DateTime answeredAt,
  }) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.quizSessions)
            ..where((table) => table.id.equals(sessionId)))
          .getSingle();
      await (_db.update(_db.quizSessions)
            ..where((table) => table.id.equals(sessionId)))
          .write(
        QuizSessionsCompanion(
          currentIndex: Value(row.currentIndex + 1),
          correctCount: Value(row.correctCount + (isCorrect ? 1 : 0)),
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
}

extension QuizSessionLocalRowQuestionIds on QuizSessionLocalRow {
  List<QuestionId> get questionIds =>
      (jsonDecode(questionIdsJson) as List).cast<QuestionId>();
}

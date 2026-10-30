import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/time/local_day.dart';
import 'package:pantas/features/notifications/application/reminder_service.dart';

/// Reads recorded starts and subject scores. No synthetic engagement figures.
class ReminderActivityReader {
  ReminderActivityReader(this._db, this._content);
  final AppDatabase _db;
  final ContentRepository _content;

  Future<DateTime?> lastSessionAt(String examId) async {
    final result = await _db.customSelect(
      '''
SELECT MAX(at) AS last_at FROM (
        SELECT MAX(started_at, COALESCE(last_answered_at, started_at),
          COALESCE(completed_at, started_at)) AS at
          FROM quiz_sessions WHERE exam_id = ?
        UNION ALL SELECT MAX(started_at, COALESCE(completed_at, started_at))
          AS at FROM attempts_local WHERE exam_id = ?
        UNION ALL SELECT MAX(started_at, last_flushed_at) AS at
          FROM mock_attempts WHERE exam_id = ?
      )''',
      variables: [
        Variable<String>(examId),
        Variable<String>(examId),
        Variable<String>(examId),
      ],
      readsFrom: {_db.quizSessions, _db.attemptsLocal, _db.mockAttempts},
    ).getSingle();
    return result.readNullable<DateTime>('last_at');
  }

  Future<bool> todayStarted(String examId, DateTime now) async {
    final last = await lastSessionAt(examId);
    return last != null && localDay(last) == localDay(now);
  }

  Future<ReminderActivitySnapshot> read(Exam exam) async {
    final last = await lastSessionAt(exam.id);
    final rows = await (_db.select(_db.attemptsLocal)
          ..where(
            (row) => row.examId.equals(exam.id) & row.completedAt.isNotNull(),
          )
          ..orderBy([(row) => OrderingTerm.desc(row.completedAt)])
          ..limit(1))
        .get();
    if (rows.isEmpty) return ReminderActivitySnapshot(lastSessionAt: last);
    final decoded = jsonDecode(rows.single.itemsJson) as List<dynamic>;
    final items = decoded
        .map((item) => AttemptItem.fromJson(item as Map<String, dynamic>))
        .toList();
    final questions =
        await _content.questionsByIds(items.map((item) => item.questionId));
    final topics = {
      for (final topic in await _content.topicsByExam(exam.id))
        topic.id: topic.subjectId,
    };
    final scores = <String, (int, int)>{};
    for (final item in items) {
      final subject = topics[questions[item.questionId]?.topicId];
      if (subject == null) continue;
      final score = scores[subject] ?? (0, 0);
      scores[subject] = (score.$1 + (item.isCorrect ? 1 : 0), score.$2 + 1);
    }
    for (final subject in exam.subjects) {
      final score = scores[subject.id];
      if (score == null) continue;
      return ReminderActivitySnapshot(
        lastSessionAt: last,
        subjectName: subject.name,
        correctCount: score.$1,
        totalCount: score.$2,
      );
    }
    return ReminderActivitySnapshot(lastSessionAt: last);
  }
}

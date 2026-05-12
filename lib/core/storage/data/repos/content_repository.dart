import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/lesson.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/domain/subject.dart';
import 'package:cse_cet_reviewer/core/storage/domain/topic.dart';

class ContentRepository {
  ContentRepository(this._db);

  final AppDatabase _db;

  Future<List<Exam>> listExams() async {
    final examRows = await _db.select(_db.exams).get();
    final subjectRows = await _db.select(_db.subjects).get();
    final byExam = <ExamId, List<Subject>>{};
    for (final s in subjectRows) {
      byExam.putIfAbsent(s.examId, () => []).add(
            Subject(
              id: s.id,
              examId: s.examId,
              name: s.name,
              ordering: s.ordering,
            ),
          );
    }
    return [
      for (final e in examRows)
        Exam(
          id: e.id,
          code: e.code,
          name: e.name,
          shortName: e.shortName,
          language: e.language,
          isActive: e.isActive,
          subjects: (byExam[e.id] ?? <Subject>[])
            ..sort((a, b) => a.ordering.compareTo(b.ordering)),
        ),
    ];
  }

  Future<List<Topic>> topicsBySubject(SubjectId subjectId) async {
    final rows = await (_db.select(_db.topics)
          ..where((t) => t.subjectId.equals(subjectId)))
        .get();
    return [
      for (final r in rows)
        Topic(
          id: r.id,
          subjectId: r.subjectId,
          name: r.name,
          ordering: r.ordering,
        ),
    ]..sort((a, b) => a.ordering.compareTo(b.ordering));
  }

  Future<List<Question>> questionsByTopic(TopicId topicId) async {
    final rows = await (_db.select(_db.questions)
          ..where((q) => q.topicId.equals(topicId)))
        .get();
    return rows.map(_hydrateQuestion).toList();
  }

  Future<Question?> questionById(QuestionId id) async {
    final row = await (_db.select(_db.questions)..where((q) => q.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _hydrateQuestion(row);
  }

  Future<List<Lesson>> lessonsByTopic(TopicId topicId) async {
    final rows = await (_db.select(_db.lessons)
          ..where((l) => l.topicId.equals(topicId)))
        .get();
    return [
      for (final r in rows)
        Lesson(
          id: r.id,
          topicId: r.topicId,
          title: r.title,
          summary: r.summary,
          bodyJson: List<Map<String, dynamic>>.from(
            jsonDecode(r.bodyJson) as List,
          ),
          estimatedMinutes: r.estimatedMinutes,
        ),
    ];
  }

  Question _hydrateQuestion(QuestionRow r) {
    final examIds = (jsonDecode(r.examIdsJson) as List).cast<String>();
    final choices = (jsonDecode(r.choicesJson) as List)
        .cast<Map<String, dynamic>>()
        .map(Choice.fromJson)
        .toList();
    return Question(
      id: r.id,
      version: r.version,
      examIds: examIds,
      topicId: r.topicId,
      language: r.language,
      stem: r.stem,
      choices: choices,
      explanation: r.explanation,
    );
  }
}

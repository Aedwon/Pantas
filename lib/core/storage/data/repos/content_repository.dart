import 'dart:convert';

import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/choice_order.dart';
import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/lesson.dart';
import 'package:cse_cet_reviewer/core/storage/domain/passage.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/domain/subject.dart';
import 'package:cse_cet_reviewer/core/storage/domain/topic.dart';
import 'package:drift/drift.dart';

class ContentRepository {
  ContentRepository(this._db);

  final ContentDatabase _db;

  Future<List<Exam>> listExams() async {
    final examRows = await _db.select(_db.contentExams).get();
    final subjectRows = await _db.select(_db.contentSubjects).get();
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
          isCustom: e.isCustom,
          subjects: (byExam[e.id] ?? <Subject>[])
            ..sort((a, b) => a.ordering.compareTo(b.ordering)),
        ),
    ];
  }

  Future<List<Topic>> topicsBySubject(SubjectId subjectId) async {
    final rows = await (_db.select(_db.contentTopics)
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

  Future<List<Topic>> topicsByExam(ExamId examId) async {
    final subjectRows = await (_db.select(_db.contentSubjects)
          ..where((s) => s.examId.equals(examId)))
        .get();
    final allTopics = <Topic>[];
    for (final s in subjectRows) {
      allTopics.addAll(await topicsBySubject(s.id));
    }
    return allTopics;
  }

  Future<List<Question>> questionsByTopic(TopicId topicId) async {
    final rows = await (_db.select(_db.contentQuestions)
          ..where(
            // isWithdrawn is isActive inverted
            (q) => q.topicId.equals(topicId) & q.isActive.equals(true),
          ))
        .get();
    return Future.wait(rows.map(_hydrateQuestion));
  }

  Future<Question?> questionById(QuestionId id) async {
    final row = await (_db.select(_db.contentQuestions)..where((q) => q.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : await _hydrateQuestion(row);
  }

  /// Every question named, in one query, keyed by id.
  ///
  /// The debrief was fetching them one at a time: a finished session asked
  /// the database once per question and then again for its topic, its
  /// subject and its passage. At 120 questions that is around 480 round
  /// trips to an encrypted database, in series, before the result appears.
  Future<Map<QuestionId, Question>> questionsByIds(
    Iterable<QuestionId> ids,
  ) async {
    final wanted = ids.toSet().toList();
    if (wanted.isEmpty) return const {};
    final rows = await (_db.select(_db.contentQuestions)
          ..where((q) => q.id.isIn(wanted)))
        .get();
    final questions = await Future.wait(rows.map(_hydrateQuestion));
    return {for (final q in questions) q.id: q};
  }

  Future<List<Lesson>> lessonsByTopic(TopicId topicId) async {
    final rows = await (_db.select(_db.contentLessons)
          ..where((l) => l.topicId.equals(topicId))
          ..orderBy([
            (l) => OrderingTerm.asc(l.ordering),
            // Unplaced lessons all share ordering 0. Their ids embed the
            // filename slug, so this reproduces the order students see today.
            (l) => OrderingTerm.asc(l.id),
          ]))
        .get();
    return rows.map(_hydrateLesson).toList();
  }

  /// Every topic's lessons in one round trip, each list in authored order.
  /// A topic with no lessons still gets a key, so a caller never has to tell
  /// "no lessons" apart from "topic I did not ask about".
  Future<Map<TopicId, List<Lesson>>> lessonsByTopics(
    List<TopicId> topicIds,
  ) async {
    final grouped = {for (final id in topicIds) id: <Lesson>[]};
    if (topicIds.isEmpty) return grouped;

    final rows = await (_db.select(_db.contentLessons)
          ..where((l) => l.topicId.isIn(topicIds))
          ..orderBy([
            (l) => OrderingTerm.asc(l.ordering),
            (l) => OrderingTerm.asc(l.id),
          ]))
        .get();

    for (final row in rows) {
      grouped[row.topicId]?.add(_hydrateLesson(row));
    }
    return grouped;
  }

  Future<Lesson?> lessonById(LessonId id) async {
    final row = await (_db.select(_db.contentLessons)..where((l) => l.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _hydrateLesson(row);
  }

  /// Narrows the corpus to rows whose title, summary or serialised body
  /// contains [query]. **This can only narrow**: the body column is Portable
  /// Text JSON, so a hit here may be on a key or a mark name. The caller
  /// confirms against the flattened text.
  Future<List<LessonRow>> searchLessonRows({
    required List<TopicId> topicIds,
    required String query,
  }) async {
    if (query.isEmpty || topicIds.isEmpty) return const [];
    final needle = '%${query.toLowerCase()}%';

    final rows = await (_db.select(_db.contentLessons)
          ..where(
            (l) =>
                l.topicId.isIn(topicIds) &
                (l.title.lower().like(needle) |
                    l.summary.lower().like(needle) |
                    l.bodyJson.lower().like(needle)),
          )
          ..orderBy([
            (l) => OrderingTerm.asc(l.ordering),
            (l) => OrderingTerm.asc(l.id),
          ]))
        .get();

    return [
      for (final r in rows)
        LessonRow(
          id: r.id,
          topicId: r.topicId,
          title: r.title,
          summary: r.summary,
          bodyJson: r.bodyJson,
          estimatedMinutes: r.estimatedMinutes,
          ordering: r.ordering,
        ),
    ];
  }

  Future<Topic?> topicById(TopicId id) async {
    final row = await (_db.select(_db.contentTopics)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return Topic(
      id: row.id,
      subjectId: row.subjectId,
      name: row.name,
      ordering: row.ordering,
    );
  }

  Future<Subject?> subjectById(SubjectId id) async {
    final row = await (_db.select(_db.contentSubjects)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return Subject(
      id: row.id,
      examId: row.examId,
      name: row.name,
      ordering: row.ordering,
    );
  }

  Lesson _hydrateLesson(ContentLessonRow r) {
    return Lesson(
      id: r.id,
      topicId: r.topicId,
      title: r.title,
      summary: r.summary,
      bodyJson: List<Map<String, dynamic>>.from(
        jsonDecode(r.bodyJson) as List,
      ),
      estimatedMinutes: r.estimatedMinutes,
      ordering: r.ordering,
    );
  }

  Future<Passage?> passageById(PassageId id) async {
    final row = await (_db.select(_db.contentPassages)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _hydratePassage(row);
  }

  Passage _hydratePassage(ContentPassageRow r) {
    return Passage(
      id: r.id,
      topicId: r.topicId,
      title: r.title,
      body: r.body,
      language: r.language,
      wordCount: r.wordCount,
    );
  }

  Future<Question> _hydrateQuestion(ContentQuestionRow r) async {
    final choiceRows = await (_db.select(_db.contentChoices)
          ..where(
            (choice) =>
                choice.questionId.equals(r.id) & choice.isActive.equals(true),
          )
          ..orderBy([(choice) => OrderingTerm.asc(choice.ordering)]))
        .get();
    final examRows = await (_db.select(_db.contentQuestionExams)
          ..where((exam) => exam.questionId.equals(r.id)))
        .get();
    return Question(
      id: r.id,
      version: r.version,
      examIds: [for (final exam in examRows) exam.examId],
      topicId: r.topicId,
      lessonId: r.lessonId,
      passageId: r.passageId,
      language: r.language,
      stem: _plainText(r.stemJson),
      choices: orderChoicesFor(r.id, [
        for (final choice in choiceRows)
          Choice(
            id: choice.id,
            label: choice.label,
            text: choice.textValue,
            isCorrect: choice.isCorrect,
          ),
      ]),
      explanation: _plainText(r.explanationJson),
      shortLabel: r.shortLabel,
    );
  }

  String _plainText(String portableTextJson) {
    final decoded = jsonDecode(portableTextJson);
    if (decoded is! List) return '';
    return decoded
        .whereType<Map<String, Object?>>()
        .expand((block) {
          final children = block['children'];
          if (children is! List) return const <String>[];
          return children
              .whereType<Map<String, Object?>>()
              .map((child) => child['text'])
              .whereType<String>();
        })
        .join('\n')
        .trim();
  }
}

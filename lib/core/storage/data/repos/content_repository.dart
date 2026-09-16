import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/tables/content_questions.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/choice_order.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/domain/passage.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/domain/question_selection_row.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/domain/topic.dart';

class ContentRepository {
  ContentRepository(this._db, {void Function()? onQuery}) : _onQuery = onQuery;

  final ContentDatabase _db;
  final void Function()? _onQuery;

  static const int _hydrationBatchSize = 400;

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

  Future<List<QuestionSelectionRow>> selectionRowsByTopic(
    TopicId topicId,
  ) async {
    final grouped = await selectionRowsByTopics([topicId]);
    return grouped[topicId] ?? const [];
  }

  Future<Map<TopicId, List<QuestionSelectionRow>>> selectionRowsByTopics(
    Iterable<TopicId> topicIds,
  ) async {
    final wanted = topicIds.toSet().toList();
    final grouped = {
      for (final topicId in wanted) topicId: <QuestionSelectionRow>[],
    };
    if (wanted.isEmpty) return grouped;

    final questions = _db.contentQuestions;
    for (final batch in _batches(wanted)) {
      final query = _db.selectOnly(questions)
        ..addColumns([
          questions.id,
          questions.version,
          questions.topicId,
          questions.lessonId,
          questions.passageId,
          questions.figureSpecJson,
        ])
        ..where(
          questions.topicId.isIn(batch) & questions.isActive.equals(true),
        );
      _onQuery?.call();
      for (final row in await query.get()) {
        final selection = _selectionRow(row, questions);
        grouped[selection.topicId]?.add(selection);
      }
    }
    return grouped;
  }

  Future<Map<TopicId, int>> activeQuestionCountsByTopics(
    Iterable<TopicId> topicIds,
  ) async {
    final wanted = topicIds.toSet().toList();
    final counts = {for (final topicId in wanted) topicId: 0};
    if (wanted.isEmpty) return counts;

    final questions = _db.contentQuestions;
    final total = questions.id.count();
    for (final batch in _batches(wanted)) {
      final query = _db.selectOnly(questions)
        ..addColumns([questions.topicId, total])
        ..where(
          questions.topicId.isIn(batch) & questions.isActive.equals(true),
        )
        ..groupBy([questions.topicId]);
      _onQuery?.call();
      for (final row in await query.get()) {
        final topicId = row.read(questions.topicId);
        if (topicId != null) counts[topicId] = row.read(total) ?? 0;
      }
    }
    return counts;
  }

  Future<List<QuestionSelectionRow>> selectionRowsByExam(ExamId examId) async {
    final memberships = _db.contentQuestionExams;
    _onQuery?.call();
    final membershipRows = await (_db.select(memberships)
          ..where((membership) => membership.examId.equals(examId)))
        .get();
    return _selectionRowsByIds([
      for (final membership in membershipRows) membership.questionId,
    ]);
  }

  Future<List<QuestionSelectionRow>> _selectionRowsByIds(
    List<QuestionId> ids,
  ) async {
    final wanted = _uniqueIds(ids);
    if (wanted.isEmpty) return const [];

    final questions = _db.contentQuestions;
    final byId = <QuestionId, QuestionSelectionRow>{};
    for (final batch in _batches(wanted)) {
      final query = _db.selectOnly(questions)
        ..addColumns([
          questions.id,
          questions.version,
          questions.topicId,
          questions.lessonId,
          questions.passageId,
          questions.figureSpecJson,
        ])
        ..where(
          questions.id.isIn(batch) & questions.isActive.equals(true),
        );
      _onQuery?.call();
      for (final row in await query.get()) {
        final selection = _selectionRow(row, questions);
        byId[selection.id] = selection;
      }
    }

    final result = <QuestionSelectionRow>[];
    for (final id in wanted) {
      final row = byId[id];
      if (row != null) result.add(row);
    }
    return result;
  }

  QuestionSelectionRow _selectionRow(
    TypedResult row,
    ContentQuestions questions,
  ) {
    return QuestionSelectionRow(
      id: row.read(questions.id)!,
      version: row.read(questions.version)!,
      topicId: row.read(questions.topicId)!,
      lessonId: row.read(questions.lessonId),
      passageId: row.read(questions.passageId),
      hasFigure: row.read(questions.figureSpecJson) != null,
    );
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
    final row = await (_db.select(_db.contentQuestions)
          ..where((q) => q.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : await _hydrateQuestion(row);
  }

  /// Every question named, keyed by id.
  Future<Map<QuestionId, Question>> questionsByIds(
    Iterable<QuestionId> ids,
  ) async {
    final questions = await hydrateSelectedQuestions(ids.toList());
    return {for (final q in questions) q.id: q};
  }

  /// Hydrates selected questions in bounded batches and restores caller order.
  ///
  /// Missing ids are omitted, withdrawn rows remain available when explicitly
  /// named (matching [questionById]), and duplicate ids keep their first
  /// occurrence only (matching the old set/map semantics of [questionsByIds]).
  Future<List<Question>> hydrateSelectedQuestions(
    List<QuestionId> ids,
  ) async {
    final wanted = _uniqueIds(ids);
    if (wanted.isEmpty) return const [];

    final questionRows = <QuestionId, ContentQuestionRow>{};
    final choicesByQuestion = <QuestionId, List<ContentChoiceRow>>{};
    final examsByQuestion = <QuestionId, List<ContentQuestionExamRow>>{};

    for (final batch in _batches(wanted)) {
      _onQuery?.call();
      final rows = await (_db.select(_db.contentQuestions)
            ..where((question) => question.id.isIn(batch)))
          .get();
      for (final row in rows) {
        questionRows[row.id] = row;
      }
    }

    for (final batch in _batches(wanted)) {
      _onQuery?.call();
      final rows = await (_db.select(_db.contentChoices)
            ..where(
              (choice) =>
                  choice.questionId.isIn(batch) & choice.isActive.equals(true),
            )
            ..orderBy([
              (choice) => OrderingTerm.asc(choice.questionId),
              (choice) => OrderingTerm.asc(choice.ordering),
            ]))
          .get();
      for (final row in rows) {
        choicesByQuestion.putIfAbsent(row.questionId, () => []).add(row);
      }
    }

    for (final batch in _batches(wanted)) {
      _onQuery?.call();
      final rows = await (_db.select(_db.contentQuestionExams)
            ..where((membership) => membership.questionId.isIn(batch)))
          .get();
      for (final row in rows) {
        examsByQuestion.putIfAbsent(row.questionId, () => []).add(row);
      }
    }

    final result = <Question>[];
    for (final id in wanted) {
      final row = questionRows[id];
      if (row == null) continue;
      result.add(
        _questionFromParts(
          row,
          choicesByQuestion[id] ?? const [],
          examsByQuestion[id] ?? const [],
        ),
      );
    }
    return result;
  }

  /// How many of [questionIds] are tagged for [examId].
  ///
  /// Answers the carry-over question: a student switching exams wants to know
  /// how much of what they have already answered still counts. Exam membership
  /// is a table of its own, so this is one query rather than a decode per row.
  Future<int> countQuestionsTaggedForExam({
    required Iterable<QuestionId> questionIds,
    required ExamId examId,
  }) async {
    final wanted = questionIds.toSet().toList();
    if (wanted.isEmpty) return 0;
    final rows = await (_db.select(_db.contentQuestionExams)
          ..where(
            (row) => row.questionId.isIn(wanted) & row.examId.equals(examId),
          ))
        .get();
    return rows.length;
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
    final row = await (_db.select(_db.contentLessons)
          ..where((l) => l.id.equals(id)))
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
    final row = await (_db.select(_db.contentTopics)
          ..where((t) => t.id.equals(id)))
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
    final row = await (_db.select(_db.contentSubjects)
          ..where((s) => s.id.equals(id)))
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
    final row = await (_db.select(_db.contentPassages)
          ..where((p) => p.id.equals(id)))
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
    return _questionFromParts(r, choiceRows, examRows);
  }

  Question _questionFromParts(
    ContentQuestionRow r,
    List<ContentChoiceRow> choiceRows,
    List<ContentQuestionExamRow> examRows,
  ) {
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
            rationale: choice.rationale,
          ),
      ]),
      explanation: _plainText(r.explanationJson),
      shortLabel: r.shortLabel,
      figureSpecJson: r.figureSpecJson,
    );
  }

  List<QuestionId> _uniqueIds(List<QuestionId> ids) {
    final seen = <QuestionId>{};
    return [
      for (final id in ids)
        if (seen.add(id)) id,
    ];
  }

  Iterable<List<T>> _batches<T>(List<T> ids) sync* {
    for (var start = 0; start < ids.length; start += _hydrationBatchSize) {
      final candidateEnd = start + _hydrationBatchSize;
      final end = candidateEnd < ids.length ? candidateEnd : ids.length;
      yield ids.sublist(start, end);
    }
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

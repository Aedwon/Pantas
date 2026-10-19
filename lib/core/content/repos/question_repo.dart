import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/repos/content_fetch_hook.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/choice_order.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/question.dart';

class QuestionRepo {
  /// [fetchHook] is passed on web only; see [ContentFetchHook].
  QuestionRepo(this._db, {ContentFetchHook? fetchHook})
      : _fetchHook = fetchHook;

  final ContentDatabase _db;
  final ContentFetchHook? _fetchHook;
  ContentDatabase get database => _db;

  Future<List<Question>> byTopic(TopicId topicId, {int? limit}) async {
    final query = _db.select(_db.contentQuestions)
      ..where(
        (row) => row.topicId.equals(topicId) & row.isActive.equals(true),
      )
      ..orderBy([(row) => OrderingTerm.asc(row.id)]);
    if (limit != null) query.limit(limit);
    final rows = await _withText(query);
    return Future.wait(rows.map(_hydrateQuestion));
  }

  Future<List<Question>> bySubtopic(SubtopicId subtopicId, {int? limit}) async {
    final query = _db.select(_db.contentQuestions)
      ..where(
        (row) => row.subtopicId.equals(subtopicId) & row.isActive.equals(true),
      )
      ..orderBy([(row) => OrderingTerm.asc(row.id)]);
    if (limit != null) query.limit(limit);
    final rows = await _withText(query);
    return Future.wait(rows.map(_hydrateQuestion));
  }

  Future<List<Question>> byExam(ExamId examId, {int? limit}) async {
    final junctionRows = await (_db.select(_db.contentQuestionExams)
          ..where((row) => row.examId.equals(examId)))
        .get();
    final questions = <Question>[];
    for (final junction in junctionRows) {
      final question = await findById(junction.questionId);
      if (question != null && await _isActive(question.id)) {
        questions.add(question);
      }
      if (limit != null && questions.length >= limit) break;
    }
    return questions;
  }

  Future<Question?> findById(QuestionId id) async {
    final query = _db.select(_db.contentQuestions)
      ..where((table) => table.id.equals(id));
    final rows = await _withText(query);
    return rows.isEmpty ? null : _hydrateQuestion(rows.single);
  }

  Future<List<Question>> byIds(List<QuestionId> ids) async {
    final questions = <Question>[];
    for (final id in ids) {
      final question = await findById(id);
      if (question != null) questions.add(question);
    }
    return questions;
  }

  /// Runs [query]. With a fetch hook, first makes sure the text of the rows it
  /// finds is present, runs it again to read that text, and leaves out the
  /// questions whose text could not be fetched.
  Future<List<ContentQuestionRow>> _withText(
    SimpleSelectStatement<$ContentQuestionsTable, ContentQuestionRow> query,
  ) async {
    final rows = await query.get();
    final hook = _fetchHook;
    if (hook == null || rows.isEmpty) return rows;
    final ready = await hook.ensureQuestions([for (final row in rows) row.id]);
    return [
      for (final row in await query.get())
        if (ready.contains(row.id)) row,
    ];
  }

  Future<bool> _isActive(QuestionId id) async {
    final row = await (_db.select(_db.contentQuestions)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return row?.isActive ?? false;
  }

  Future<Question> _hydrateQuestion(ContentQuestionRow row) async {
    final choiceRows = await (_db.select(_db.contentChoices)
          ..where(
            (choice) =>
                choice.questionId.equals(row.id) & choice.isActive.equals(true),
          )
          ..orderBy([(choice) => OrderingTerm.asc(choice.ordering)]))
        .get();
    final examRows = await (_db.select(_db.contentQuestionExams)
          ..where((exam) => exam.questionId.equals(row.id)))
        .get();
    return Question(
      id: row.id,
      version: row.version,
      examIds: [for (final exam in examRows) exam.examId],
      topicId: row.topicId,
      language: row.language,
      stem: _plainText(row.stemJson),
      choices: orderChoicesFor(row.id, [
        for (final choice in choiceRows)
          Choice(
            id: choice.id,
            label: choice.label,
            text: choice.textValue,
            isCorrect: choice.isCorrect,
            rationale: choice.rationale,
          ),
      ]),
      explanation: _plainText(row.explanationJson),
      figureSpecJson: row.figureSpecJson,
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

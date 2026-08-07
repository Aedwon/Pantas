import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/sanity/parser_exceptions.dart';
import 'package:pantas/core/content/sanity/parsers/parser_utils.dart';
import 'package:pantas/core/content/sanity/parsers/portable_text_parser.dart';
import 'package:pantas/core/content/sanity/schema_versions.dart';

class ParsedQuestion {
  const ParsedQuestion({
    required this.question,
    required this.choices,
    required this.examLinks,
  });

  final ContentQuestionsCompanion question;
  final List<ContentChoicesCompanion> choices;
  final List<ContentQuestionExamsCompanion> examLinks;
}

ParsedQuestion parseQuestion(Map<String, Object?> doc) {
  const doctype = 'question';
  checkSchemaVersion(
    doc: doc,
    doctype: doctype,
    expected: SchemaVersions.question,
  );
  final questionId = stringField(doc, doctype, '_id');
  final updatedAt = dateTimeField(doc, doctype, '_updatedAt');
  return ParsedQuestion(
    question: ContentQuestionsCompanion.insert(
      id: questionId,
      schemaVersion: SchemaVersions.question,
      isActive: Value(boolField(doc, doctype, 'isActive')),
      updatedAt: updatedAt,
      topicId: refField(doc, doctype, 'topic'),
      subtopicId: Value(optionalRefField(doc, doctype, 'subtopic')),
      language: stringField(doc, doctype, 'language'),
      stemJson:
          portableTextToJson(doc['stem'], doctype: doctype, field: 'stem'),
      explanationJson: portableTextToJson(
        doc['explanation'],
        doctype: doctype,
        field: 'explanation',
      ),
      version: intField(doc, doctype, 'version'),
      lessonId: Value(optionalRefField(doc, doctype, 'lesson')),
      passageId: Value(optionalRefField(doc, doctype, 'passage')),
      shortLabel: Value(optionalStringField(doc, doctype, 'shortLabel')),
      // Stored as text. The painter decodes it; nothing between here and
      // there needs to understand a gear from a spring.
      figureSpecJson: Value(
        doc['figureSpec'] == null ? null : jsonEncode(doc['figureSpec']),
      ),
    ),
    choices: _parseChoices(doc, questionId, updatedAt),
    examLinks: [
      for (final examId in refListField(doc, doctype, 'examIds'))
        ContentQuestionExamsCompanion.insert(
          questionId: questionId,
          examId: examId,
        ),
    ],
  );
}

List<ContentChoicesCompanion> _parseChoices(
  Map<String, Object?> doc,
  String questionId,
  DateTime updatedAt,
) {
  const doctype = 'question';
  final choices = doc['choices'];
  if (choices is! List || choices.isEmpty) {
    throw const ParseException(
      doctype: doctype,
      field: 'choices',
      message: 'expected non-empty list',
    );
  }
  return [
    for (var i = 0; i < choices.length; i++)
      _parseChoice(choices[i], questionId, updatedAt, i),
  ];
}

ContentChoicesCompanion _parseChoice(
  Object? value,
  String questionId,
  DateTime updatedAt,
  int index,
) {
  const doctype = 'question';
  if (value is! Map<String, Object?>) {
    throw ParseException(
      doctype: doctype,
      field: 'choices[$index]',
      message: 'expected object',
    );
  }
  return ContentChoicesCompanion.insert(
    id: stringField(value, doctype, '_key'),
    schemaVersion: SchemaVersions.question,
    updatedAt: updatedAt,
    questionId: questionId,
    label: stringField(value, doctype, 'label'),
    textValue: stringField(value, doctype, 'text'),
    isCorrect: boolField(value, doctype, 'isCorrect'),
    // Note B. Absent for every question authored before 13 August 2026,
    // and absent is not an error: it means Pro adds nothing on this one.
    rationale: Value(optionalStringField(value, doctype, 'rationale')),
    ordering: index + 1,
  );
}

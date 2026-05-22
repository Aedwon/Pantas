import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parser_exceptions.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/parser_utils.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/portable_text_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/schema_versions.dart';
import 'package:drift/drift.dart';

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
    ordering: index + 1,
  );
}

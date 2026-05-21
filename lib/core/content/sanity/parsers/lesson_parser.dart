import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/parser_utils.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/portable_text_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/schema_versions.dart';
import 'package:drift/drift.dart';

ContentLessonsCompanion parseLesson(Map<String, Object?> doc) {
  const doctype = 'lesson';
  checkSchemaVersion(
    doc: doc,
    doctype: doctype,
    expected: SchemaVersions.lesson,
  );
  return ContentLessonsCompanion.insert(
    id: stringField(doc, doctype, '_id'),
    schemaVersion: SchemaVersions.lesson,
    isActive: Value(boolField(doc, doctype, 'isActive')),
    updatedAt: dateTimeField(doc, doctype, '_updatedAt'),
    topicId: refField(doc, doctype, 'topic'),
    title: stringField(doc, doctype, 'title'),
    summary: stringField(doc, doctype, 'summary'),
    estimatedMinutes: intField(doc, doctype, 'estimatedMinutes'),
    bodyJson: portableTextToJson(doc['body'], doctype: doctype, field: 'body'),
  );
}

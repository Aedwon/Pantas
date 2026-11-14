import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/sanity/parsers/parser_utils.dart';
import 'package:pantas/core/content/sanity/parsers/portable_text_parser.dart';
import 'package:pantas/core/content/sanity/schema_versions.dart';

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
    subtopicId: Value(optionalRefField(doc, doctype, 'subtopic')),
    title: stringField(doc, doctype, 'title'),
    summary: stringField(doc, doctype, 'summary'),
    // Compatibility column only. No screen may show it; T10 removes every read.
    estimatedMinutes: doc['estimatedMinutes'] == null
        ? 0
        : intField(doc, doctype, 'estimatedMinutes'),
    // Absent means unplaced, which sorts first, exactly as the app's own
    // schema treats the three lessons that carry no ordering.
    ordering: Value(doc['ordering'] is int ? doc['ordering']! as int : 0),
    quizSize: Value(doc['quizSize'] as int? ?? 5),
    status: Value(doc['status'] as String? ?? 'active'),
    replacedBy:
        Value(doc['replacedBy'] == null ? null : jsonEncode(doc['replacedBy'])),
    part: Value(doc['part'] as int?),
    partCount: Value(doc['partCount'] as int?),
    keyPointsJson:
        Value(doc['keyPoints'] == null ? null : jsonEncode(doc['keyPoints'])),
    bodyJson: portableTextToJson(doc['body'], doctype: doctype, field: 'body'),
  );
}

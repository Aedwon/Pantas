import 'dart:convert';

import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parser_exceptions.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/parser_utils.dart';
import 'package:cse_cet_reviewer/core/content/sanity/schema_versions.dart';
import 'package:drift/drift.dart';

ContentMockBlueprintsCompanion parseMockBlueprint(Map<String, Object?> doc) {
  const doctype = 'mockBlueprint';
  checkSchemaVersion(
    doc: doc,
    doctype: doctype,
    expected: SchemaVersions.mockBlueprint,
  );
  final sections = doc['sections'];
  if (sections is! List) {
    throw const ParseException(
      doctype: doctype,
      field: 'sections',
      message: 'expected list',
    );
  }
  return ContentMockBlueprintsCompanion.insert(
    id: stringField(doc, doctype, '_id'),
    schemaVersion: SchemaVersions.mockBlueprint,
    isActive: Value(boolField(doc, doctype, 'isActive')),
    updatedAt: dateTimeField(doc, doctype, '_updatedAt'),
    examId: refField(doc, doctype, 'exam'),
    name: stringField(doc, doctype, 'name'),
    durationMinutes: intField(doc, doctype, 'durationMinutes'),
    sectionsJson: jsonEncode(sections),
  );
}

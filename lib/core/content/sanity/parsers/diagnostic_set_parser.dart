import 'dart:convert';

import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/parser_utils.dart';
import 'package:cse_cet_reviewer/core/content/sanity/schema_versions.dart';
import 'package:drift/drift.dart';

ContentDiagnosticSetsCompanion parseDiagnosticSet(Map<String, Object?> doc) {
  const doctype = 'diagnosticSet';
  checkSchemaVersion(
    doc: doc,
    doctype: doctype,
    expected: SchemaVersions.diagnosticSet,
  );
  return ContentDiagnosticSetsCompanion.insert(
    id: stringField(doc, doctype, '_id'),
    schemaVersion: SchemaVersions.diagnosticSet,
    isActive: Value(boolField(doc, doctype, 'isActive')),
    updatedAt: dateTimeField(doc, doctype, '_updatedAt'),
    examId: refField(doc, doctype, 'exam'),
    name: stringField(doc, doctype, 'name'),
    questionIdsJson: jsonEncode(
      refListField(doc, doctype, 'questionIds'),
    ),
  );
}

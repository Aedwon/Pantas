import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/parser_utils.dart';
import 'package:cse_cet_reviewer/core/content/sanity/schema_versions.dart';
import 'package:drift/drift.dart';

ContentMockExamsCompanion parseMockExam(Map<String, Object?> doc) {
  const doctype = 'mockExam';
  checkSchemaVersion(
    doc: doc,
    doctype: doctype,
    expected: SchemaVersions.mockExam,
  );
  return ContentMockExamsCompanion.insert(
    id: stringField(doc, doctype, '_id'),
    schemaVersion: SchemaVersions.mockExam,
    isActive: Value(boolField(doc, doctype, 'isActive')),
    updatedAt: dateTimeField(doc, doctype, '_updatedAt'),
    blueprintId: refField(doc, doctype, 'blueprint'),
    name: stringField(doc, doctype, 'name'),
    publishedAt: dateTimeField(doc, doctype, 'publishedAt'),
  );
}

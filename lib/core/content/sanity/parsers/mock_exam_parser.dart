import 'package:drift/drift.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/sanity/parsers/parser_utils.dart';
import 'package:pantas/core/content/sanity/schema_versions.dart';

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

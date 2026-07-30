import 'package:drift/drift.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/sanity/parsers/parser_utils.dart';
import 'package:pantas/core/content/sanity/schema_versions.dart';

ContentSubjectsCompanion parseSubject(Map<String, Object?> doc) {
  const doctype = 'subject';
  checkSchemaVersion(
    doc: doc,
    doctype: doctype,
    expected: SchemaVersions.subject,
  );
  return ContentSubjectsCompanion.insert(
    id: stringField(doc, doctype, '_id'),
    schemaVersion: SchemaVersions.subject,
    isActive: Value(boolField(doc, doctype, 'isActive')),
    updatedAt: dateTimeField(doc, doctype, '_updatedAt'),
    examId: refField(doc, doctype, 'exam'),
    name: stringField(doc, doctype, 'name'),
    ordering: intField(doc, doctype, 'ordering'),
  );
}

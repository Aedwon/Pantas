import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/sanity/parsers/parser_utils.dart';
import 'package:pantas/core/content/sanity/schema_versions.dart';
import 'package:drift/drift.dart';

ContentExamsCompanion parseExam(Map<String, Object?> doc) {
  const doctype = 'exam';
  checkSchemaVersion(
    doc: doc,
    doctype: doctype,
    expected: SchemaVersions.exam,
  );
  return ContentExamsCompanion.insert(
    id: stringField(doc, doctype, '_id'),
    schemaVersion: SchemaVersions.exam,
    isActive: Value(boolField(doc, doctype, 'isActive')),
    updatedAt: dateTimeField(doc, doctype, '_updatedAt'),
    code: stringField(doc, doctype, 'code'),
    name: stringField(doc, doctype, 'name'),
    shortName: stringField(doc, doctype, 'shortName'),
    language: stringField(doc, doctype, 'language'),
    ordering: intField(doc, doctype, 'ordering'),
    isCustom: Value(boolField(doc, doctype, 'isCustom')),
  );
}

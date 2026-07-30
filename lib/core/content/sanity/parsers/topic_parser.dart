import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/sanity/parsers/parser_utils.dart';
import 'package:pantas/core/content/sanity/schema_versions.dart';
import 'package:drift/drift.dart';

ContentTopicsCompanion parseTopic(Map<String, Object?> doc) {
  const doctype = 'topic';
  checkSchemaVersion(
    doc: doc,
    doctype: doctype,
    expected: SchemaVersions.topic,
  );
  return ContentTopicsCompanion.insert(
    id: stringField(doc, doctype, '_id'),
    schemaVersion: SchemaVersions.topic,
    isActive: Value(boolField(doc, doctype, 'isActive')),
    updatedAt: dateTimeField(doc, doctype, '_updatedAt'),
    subjectId: refField(doc, doctype, 'subject'),
    name: stringField(doc, doctype, 'name'),
    ordering: intField(doc, doctype, 'ordering'),
  );
}

import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/sanity/parsers/parser_utils.dart';
import 'package:pantas/core/content/sanity/schema_versions.dart';
import 'package:drift/drift.dart';

ContentPassagesCompanion parsePassage(Map<String, Object?> doc) {
  const doctype = 'passage';
  checkSchemaVersion(
    doc: doc,
    doctype: doctype,
    expected: SchemaVersions.passage,
  );
  return ContentPassagesCompanion.insert(
    id: stringField(doc, doctype, '_id'),
    schemaVersion: SchemaVersions.passage,
    isActive: Value(boolField(doc, doctype, 'isActive')),
    updatedAt: dateTimeField(doc, doctype, '_updatedAt'),
    topicId: refField(doc, doctype, 'topic'),
    title: stringField(doc, doctype, 'title'),
    body: stringField(doc, doctype, 'body'),
    language: stringField(doc, doctype, 'language'),
    wordCount: intField(doc, doctype, 'wordCount'),
  );
}

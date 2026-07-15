import 'dart:convert';

import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:cse_cet_reviewer/core/content/domain/mock_blueprint.dart';
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
    sectionalTiming: Value(_timing(doc['sectionalTiming'])),
    scoreBandsJson: Value(_scoreBands(doc['scoreBands'])),
  );
}

/// Absent is absent, and so is anything this app does not recognise. A
/// value invented here would tell a student they can go back on an exam
/// where they cannot.
String? _timing(Object? raw) {
  if (raw is! String) return null;
  for (final value in SectionalTiming.values) {
    if (value.name == raw) return value.name;
  }
  return null;
}

/// Both thresholds or neither: half a band cannot colour a result.
String? _scoreBands(Object? raw) {
  if (raw is! Map) return null;
  final pass = raw['passAtPercent'];
  final close = raw['closeAtPercent'];
  if (pass is! int || close is! int) return null;
  return jsonEncode({'passAtPercent': pass, 'closeAtPercent': close});
}

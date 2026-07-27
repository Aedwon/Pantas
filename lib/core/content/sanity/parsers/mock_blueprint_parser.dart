import 'dart:convert';

import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:cse_cet_reviewer/core/content/domain/mock_blueprint.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parser_exceptions.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/parser_utils.dart';
import 'package:cse_cet_reviewer/core/content/sanity/schema_versions.dart';
import 'package:drift/drift.dart';

ContentMockBlueprintsCompanion parseMockBlueprint(Map<String, Object?> doc) {
  const doctype = 'mockBlueprint';
  final version = requireSchemaVersion(doc, doctype);
  if (version != 1 && version != 2) {
    throw SchemaMismatchException(
      doctype: doctype,
      got: version,
      expected: SchemaVersions.mockBlueprint,
    );
  }
  final sections = doc['sections'];
  if (sections is! List) {
    throw const ParseException(
      doctype: doctype,
      field: 'sections',
      message: 'expected list',
    );
  }
  final rawSource = doc['source'];
  final parsedSource = _source(rawSource);
  final sourceStr = version == 1
      ? BlueprintSource.unknown.name
      : (parsedSource ?? BlueprintSource.unknown.name);
  final sourceNoteStr = version == 1
      ? null
      : optionalStringField(doc, doctype, 'sourceNote');

  return ContentMockBlueprintsCompanion.insert(
    id: stringField(doc, doctype, '_id'),
    schemaVersion: version,
    isActive: Value(boolField(doc, doctype, 'isActive')),
    updatedAt: dateTimeField(doc, doctype, '_updatedAt'),
    examId: refField(doc, doctype, 'exam'),
    name: stringField(doc, doctype, 'name'),
    durationMinutes: intField(doc, doctype, 'durationMinutes'),
    sectionsJson: jsonEncode(sections),
    sectionalTiming: Value(_timing(doc['sectionalTiming'])),
    scoreBandsJson: Value(_scoreBands(doc['scoreBands'])),
    totalPublishedItems: Value(_positiveInt(doc['totalPublishedItems'])),
    source: Value(sourceStr),
    sourceNote: Value(sourceNoteStr),
  );
}

String? _source(Object? raw) {
  if (raw is! String) return null;
  for (final value in BlueprintSource.values) {
    if (value.name == raw) return value.name;
  }
  return null;
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

int? _positiveInt(Object? raw) => raw is int && raw > 0 ? raw : null;

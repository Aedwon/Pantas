import 'package:pantas/core/content/sanity/parser_exceptions.dart';

int requireSchemaVersion(Map<String, Object?> doc, String doctype) {
  final got = doc['schemaVersion'] as int? ?? -1;
  return got;
}

void checkSchemaVersion({
  required Map<String, Object?> doc,
  required String doctype,
  required int expected,
}) {
  final got = requireSchemaVersion(doc, doctype);
  if (got != expected) {
    throw SchemaMismatchException(
      doctype: doctype,
      got: got,
      expected: expected,
    );
  }
}

String stringField(Map<String, Object?> doc, String doctype, String field) {
  final value = doc[field];
  if (value is String && value.isNotEmpty) return value;
  throw ParseException(
    doctype: doctype,
    field: field,
    message: 'expected non-empty string',
  );
}

String? optionalStringField(
  Map<String, Object?> doc,
  String doctype,
  String field,
) {
  if (!doc.containsKey(field) || doc[field] == null) return null;
  final value = doc[field];
  if (value is String && value.isNotEmpty) return value;
  throw ParseException(
    doctype: doctype,
    field: field,
    message: 'expected non-empty string or null',
  );
}

int intField(Map<String, Object?> doc, String doctype, String field) {
  final value = doc[field];
  if (value is int) return value;
  throw ParseException(
    doctype: doctype,
    field: field,
    message: 'expected int',
  );
}

bool boolField(
  Map<String, Object?> doc,
  String doctype,
  String field, {
  bool defaultValue = true,
}) {
  final value = doc[field];
  if (value == null) return defaultValue;
  if (value is bool) return value;
  throw ParseException(
    doctype: doctype,
    field: field,
    message: 'expected bool',
  );
}

DateTime dateTimeField(Map<String, Object?> doc, String doctype, String field) {
  final value = stringField(doc, doctype, field);
  return DateTime.parse(value).toUtc();
}

String refField(Map<String, Object?> doc, String doctype, String field) {
  final value = doc[field];
  if (value is String && value.isNotEmpty) return value;
  if (value is Map<String, Object?>) {
    final ref = value['_ref'];
    if (ref is String && ref.isNotEmpty) return ref;
  }
  throw ParseException(
    doctype: doctype,
    field: field,
    message: 'expected reference',
  );
}

String? optionalRefField(
  Map<String, Object?> doc,
  String doctype,
  String field,
) {
  if (!doc.containsKey(field) || doc[field] == null) return null;
  return refField(doc, doctype, field);
}

List<String> refListField(
  Map<String, Object?> doc,
  String doctype,
  String field,
) {
  final value = doc[field];
  if (value is! List) {
    throw ParseException(
      doctype: doctype,
      field: field,
      message: 'expected reference list',
    );
  }
  return [
    for (var i = 0; i < value.length; i++)
      _refValue(value[i], doctype, '$field[$i]'),
  ];
}

String _refValue(Object? value, String doctype, String field) {
  if (value is String && value.isNotEmpty) return value;
  if (value is Map<String, Object?>) {
    final ref = value['_ref'];
    if (ref is String && ref.isNotEmpty) return ref;
  }
  throw ParseException(
    doctype: doctype,
    field: field,
    message: 'expected reference',
  );
}

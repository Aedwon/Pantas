class ParseException implements Exception {
  const ParseException({
    required this.doctype,
    required this.field,
    required this.message,
  });

  final String doctype;
  final String field;
  final String message;

  @override
  String toString() => 'ParseException($doctype.$field: $message)';
}

class SchemaMismatchException implements Exception {
  const SchemaMismatchException({
    required this.doctype,
    required this.got,
    required this.expected,
  });

  final String doctype;
  final int got;
  final int expected;

  @override
  String toString() =>
      'SchemaMismatchException($doctype: got $got expected $expected)';
}

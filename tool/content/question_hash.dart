import 'dart:convert';

import 'package:crypto/crypto.dart';

/// The question's authored lesson, with the exporter's subtopic fallback.
String questionLesson(
  Map<Object?, Object?> question,
  Map<Object?, Object?> meta,
) =>
    (question['lesson'] ?? 'lesson-${meta['topic']}-${meta['subtopic']}')
        as String;

/// Normalize strings and sort object keys recursively before JSON encoding.
Object? canonicalValue(Object? value) {
  if (value is String) {
    return value.trim().replaceAll(RegExp(r'\s+', unicode: true), ' ');
  }
  if (value is Map) {
    final entries = <String, Object?>{
      for (final key in value.keys) key as String: canonicalValue(value[key]),
    };
    return {for (final key in entries.keys.toList()..sort()) key: entries[key]};
  }
  if (value is List) return value.map(canonicalValue).toList();
  return value;
}

/// SHA-256 of the content covered by approval, excluding display metadata.
String questionHash(
  Map<Object?, Object?> question,
  Map<Object?, Object?> meta,
) {
  final exams = (canonicalValue(meta['exams']) as List<Object?>?)
    ?..sort((a, b) => (a! as String).compareTo(b! as String));
  final value = <String, Object?>{
    for (final field in [
      'stem',
      'explanation',
      'passage',
      'figure',
      'figureSpec',
    ])
      field: question[field],
    'choices': (question['choices'] as List?)?.map((raw) {
      final choice = raw as Map;
      return <String, Object?>{
        'text': choice['text'],
        'correct': choice['correct'] ?? false,
        'rationale': choice['rationale'],
      };
    }).toList(),
    'exams': exams,
    'lesson': questionLesson(question, meta),
  };
  return sha256
      .convert(utf8.encode(jsonEncode(canonicalValue(value))))
      .toString();
}

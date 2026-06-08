import 'ids.dart';

class QuestionMeta {
  const QuestionMeta({
    required this.subjectSlug,
    required this.topicSlug,
    required this.subtopicSlug,
    required this.examCodes,
  });
  final String subjectSlug;
  final String topicSlug;
  final String subtopicSlug;
  final List<String> examCodes;
}

int _keyCounter = 0;
String _key(String prefix) => '$prefix${_keyCounter++}';

List<Map<String, Object?>> textToPortableText(String text) {
  final paragraphs = text
      .trim()
      .split(RegExp(r'\n\s*\n'))
      .map((p) => p.replaceAll(RegExp(r'\s*\n\s*'), ' ').trim())
      .where((p) => p.isNotEmpty)
      .toList();
  if (paragraphs.isEmpty) {
    throw const FormatException('empty rich-text field');
  }
  return [
    for (final p in paragraphs)
      {
        '_type': 'block',
        '_key': _key('b'),
        'style': 'normal',
        'markDefs': const <Object?>[],
        'children': [
          {'_type': 'span', '_key': _key('s'), 'text': p, 'marks': const <Object?>[]},
        ],
      },
  ];
}

Map<String, Object?> questionToDoc(
  Map<Object?, Object?> q,
  QuestionMeta meta, {
  required DateTime updatedAt,
}) {
  final id = (q['id'] as String?)?.trim();
  if (id == null || id.isEmpty) {
    throw const FormatException('question is missing an id');
  }

  String requireText(String field) {
    final v = q[field];
    if (v is! String || v.trim().isEmpty) {
      throw FormatException('$id: missing or empty "$field"');
    }
    return v;
  }

  final stem = requireText('stem');
  final explanation = requireText('explanation');

  final rawChoices = q['choices'];
  if (rawChoices is! List || rawChoices.length < 2) {
    throw FormatException('$id: needs at least 2 choices');
  }
  final correctCount =
      rawChoices.where((c) => (c as Map)['correct'] == true).length;
  if (correctCount != 1) {
    throw FormatException(
        '$id: exactly one choice must be correct (found $correctCount)');
  }

  const labels = ['A', 'B', 'C', 'D', 'E', 'F'];
  final choices = <Map<String, Object?>>[];
  for (var i = 0; i < rawChoices.length; i++) {
    final c = rawChoices[i] as Map;
    final text = c['text'];
    if (text is! String || text.trim().isEmpty) {
      throw FormatException('$id: choice ${i + 1} has empty text');
    }
    choices.add({
      '_key': '$id-choice-${labels[i].toLowerCase()}',
      'label': labels[i],
      'text': text.trim(),
      'isCorrect': c['correct'] == true,
    });
  }

  final figure = q['figure'];
  final isFigurePending = figure is String && figure.trim().isNotEmpty;

  return {
    '_id': id,
    '_type': 'question',
    '_updatedAt': updatedAt.toUtc().toIso8601String(),
    'schemaVersion': 1,
    'isActive': !isFigurePending,
    'topic': {'_ref': topicId(meta.topicSlug)},
    'subtopic': {'_ref': lessonId(meta.topicSlug, meta.subtopicSlug)},
    'examIds': [for (final code in meta.examCodes) {'_ref': examId(code)}],
    'language': 'en',
    'stem': textToPortableText(stem),
    'explanation': textToPortableText(explanation),
    'version': 1,
    'choices': choices,
  };
}

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

/// The em dash is banned project-wide: use a colon or a comma.
///
/// Nothing enforced it until 4 August 2026, by which point 1,402 had reached
/// 81 question files and 418 more the lessons, one of them inside a grammar
/// explanation. The only tool that counted them printed a warning and failed
/// nothing, which is exactly how a rule becomes decorative.
///
/// The en dash is left alone: it is correct in a numeric range.
void rejectEmDash(String value, String id, String field) {
  if (value.contains('—')) {
    throw FormatException(
      '$id: $field contains an em dash. Use a colon or a comma.',
    );
  }
}

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
          {
            '_type': 'span',
            '_key': _key('s'),
            'text': p,
            'marks': const <Object?>[]
          },
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
    rejectEmDash(v, id, field);
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
    rejectEmDash(text, id, 'choice ${i + 1}');
    choices.add({
      '_key': '$id-choice-${labels[i].toLowerCase()}',
      'label': labels[i],
      'text': text.trim(),
      'isCorrect': c['correct'] == true,
    });
  }

  final figure = q['figure'];
  final isFigurePending = figure is String && figure.trim().isNotEmpty;
  final passageRef = q['passage'];
  final passageId = passageRef is String ? passageRef.trim() : null;

  return {
    '_id': id,
    '_type': 'question',
    '_updatedAt': updatedAt.toUtc().toIso8601String(),
    'schemaVersion': 1,
    'isActive': !isFigurePending,
    if (passageId != null && passageId.isNotEmpty)
      'passage': {'_ref': passageId},
    'topic': {'_ref': topicId(meta.topicSlug)},
    'subtopic': {'_ref': lessonId(meta.topicSlug, meta.subtopicSlug)},
    'examIds': [
      for (final code in meta.examCodes) {'_ref': examId(code)}
    ],
    'language': 'en',
    'stem': textToPortableText(stem),
    'explanation': textToPortableText(explanation),
    'version': 1,
    'choices': choices,
  };
}

Map<String, Object?> passageToDoc(
  Map<Object?, Object?> p,
  QuestionMeta meta, {
  required DateTime updatedAt,
}) {
  final id = (p['id'] as String?)?.trim();
  if (id == null || id.isEmpty) {
    throw const FormatException('passage is missing an id');
  }

  final title = p['title'];
  if (title is! String || title.trim().isEmpty) {
    throw FormatException('$id: missing or empty "title"');
  }

  rejectEmDash(title, id, 'title');

  final body = p['body'];
  if (body is! String || body.trim().isEmpty) {
    throw FormatException('$id: missing or empty "body"');
  }
  rejectEmDash(body, id, 'body');

  // Prose needs length to sustain a set of questions. A poem does not: density
  // does the work there that word count does in prose, and padding one out to
  // clear a prose floor dilutes the very devices its questions ask about.
  final form = p['form'] ?? 'prose';
  if (form != 'prose' && form != 'poetry') {
    throw FormatException(
      '$id: "form" must be prose or poetry (found $form)',
    );
  }
  final isPoetry = form == 'poetry';
  final minWords = isPoetry ? 40 : 150;
  final maxWords = isPoetry ? 120 : 400;

  final words = body.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  final wordCount = words.length;
  if (wordCount < minWords || wordCount > maxWords) {
    throw FormatException(
      '$id: passage body must be $minWords to $maxWords words '
      '(found $wordCount)',
    );
  }

  return {
    '_id': id,
    '_type': 'passage',
    '_updatedAt': updatedAt.toUtc().toIso8601String(),
    'schemaVersion': 1,
    'topic': {'_ref': topicId(meta.topicSlug)},
    'title': title.trim(),
    'body': body.trim(),
    'language': 'en',
    'wordCount': wordCount,
  };
}

class ParsedPassageFile {
  const ParsedPassageFile({
    required this.passages,
    required this.questions,
  });
  final List<Map<String, Object?>> passages;
  final List<Map<String, Object?>> questions;
}

ParsedPassageFile parsePassagesAndQuestions({
  required List<Object?> rawPassages,
  required List<Object?> rawQuestions,
  required QuestionMeta meta,
  required DateTime updatedAt,
}) {
  final passageDocs = <Map<String, Object?>>[];
  final passageIds = <String>{};
  final questionCountsByPassage = <String, int>{};

  for (final raw in rawPassages) {
    if (raw is! Map) continue;
    final p = Map<Object?, Object?>.from(raw);
    final built = passageToDoc(p, meta, updatedAt: updatedAt);
    final id = built['_id'] as String;
    passageIds.add(id);
    questionCountsByPassage[id] = 0;
    passageDocs.add(built);
  }

  final questionDocs = <Map<String, Object?>>[];
  for (final raw in rawQuestions) {
    if (raw is! Map) continue;
    final q = Map<Object?, Object?>.from(raw);
    final passageRef = q['passage'];
    if (passageRef is String && passageRef.trim().isNotEmpty) {
      final pid = passageRef.trim();
      final rawId = q['id'];
      final qid = (rawId is String ? rawId : null)?.trim() ?? 'question';
      if (!passageIds.contains(pid)) {
        throw FormatException('$qid: names missing passage "$pid"');
      }
      questionCountsByPassage[pid] = (questionCountsByPassage[pid] ?? 0) + 1;
    }
    final built = questionToDoc(q, meta, updatedAt: updatedAt);
    questionDocs.add(built);
  }

  for (final entry in questionCountsByPassage.entries) {
    final pid = entry.key;
    final count = entry.value;
    if (count == 0) {
      throw FormatException('$pid: passage has no questions');
    }
    if (count < 4 || count > 8) {
      throw FormatException(
        '$pid: passage must have 4 to 8 questions (found $count)',
      );
    }
  }

  return ParsedPassageFile(
    passages: passageDocs,
    questions: questionDocs,
  );
}

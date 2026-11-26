/// The part of the lesson the first run shows: Core Concept, Mnemonics and
/// Memory Aids, and Example 1 of Examples (plan ruling 4). The blocks run up
/// to the second example heading under Examples, or to the end.
List<Map<String, Object?>> firstRunLessonBlocks(
  List<Map<String, Object?>> body,
) {
  final kept = <Map<String, Object?>>[];
  var inExamples = false;
  var examples = 0;
  for (final block in body) {
    final style = block['style'];
    if (block['_type'] == 'block' && style == 'h2') {
      inExamples = _text(block).trim().toLowerCase() == 'examples';
      examples = 0;
      // Nothing after the Examples section is shown.
      if (!inExamples && kept.any(_isExamplesHeading)) break;
    } else if (inExamples && block['_type'] == 'block' && style == 'h3') {
      examples++;
      if (examples > 1) break;
    }
    kept.add(block);
  }
  return kept;
}

bool _isExamplesHeading(Map<String, Object?> block) =>
    block['style'] == 'h2' && _text(block).trim().toLowerCase() == 'examples';

String _text(Map<String, Object?> block) {
  final children = block['children'];
  if (children is! List<Object?>) return '';
  return [
    for (final run in children)
      if (run is Map<String, Object?> && run['text'] is String)
        run['text']! as String,
  ].join();
}

/// Flattens Portable Text to the words a student typed into search.
///
/// A `LIKE` over the stored JSON would match `_type`, `marks` and style names,
/// so "block" would hit every lesson. The SQL scan narrows; this decides.
///
/// The parts of a walk-through lesson count too: the words inside a Quick
/// Check, a Try, a Why?, a pair and a checklist, in the order a student reads
/// them.
String portableTextToPlain(List<Map<String, dynamic>> blocks) {
  final parts = <String>[];
  _collect(blocks, parts);
  return parts.join(' ');
}

/// Block fields that hold nested blocks, per walk-through block type, in
/// reading order.
const _walkBlockFields = {
  'walkCheck': ['question', 'answer'],
  'walkTry': ['prompt', 'answer'],
  'walkWhy': ['body'],
};

void _collect(List<dynamic> blocks, List<String> parts) {
  for (final block in blocks) {
    if (block is! Map) continue;
    final type = block['_type'];
    if (type == 'block') {
      final text = _spansText(block['children']);
      if (text.isNotEmpty) parts.add(text);
    } else if (_walkBlockFields[type] case final fields?) {
      for (final field in fields) {
        final nested = block[field];
        if (nested is List) _collect(nested, parts);
      }
    } else if (type == 'walkPair') {
      for (final field in const ['right', 'wrong']) {
        final text = _spansText(block[field]);
        if (text.isNotEmpty) parts.add(text);
      }
      final note = block['note'];
      if (note is List) _collect(note, parts);
    } else if (type == 'walkChecklist') {
      final items = block['items'];
      if (items is! List) continue;
      for (final item in items) {
        if (item is! Map) continue;
        final text = [_spansText(item['cue']), _spansText(item['move'])]
            .where((part) => part.isNotEmpty)
            .join(' ');
        if (text.isNotEmpty) parts.add(text);
      }
    }
  }
}

String _spansText(dynamic spans) {
  if (spans is! List) return '';
  final buffer = StringBuffer();
  for (final child in spans) {
    if (child is! Map) continue;
    final text = child['text'];
    if (text is String) buffer.write(text);
  }
  return buffer.toString();
}

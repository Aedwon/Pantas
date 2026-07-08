/// Flattens Portable Text to the words a student typed into search.
///
/// A `LIKE` over the stored JSON would match `_type`, `marks` and style names,
/// so "block" would hit every lesson. The SQL scan narrows; this decides.
String portableTextToPlain(List<Map<String, dynamic>> blocks) {
  final parts = <String>[];

  for (final block in blocks) {
    if (block['_type'] != 'block') continue;
    final children = block['children'];
    if (children is! List) continue;

    final buffer = StringBuffer();
    for (final child in children) {
      if (child is! Map) continue;
      final text = child['text'];
      if (text is String) buffer.write(text);
    }
    if (buffer.isNotEmpty) parts.add(buffer.toString());
  }

  return parts.join(' ');
}

/// A cut of matched text, and where the match sits inside it.
class SearchSnippet {
  const SearchSnippet({
    required this.text,
    required this.matchStart,
    required this.matchLength,
  });

  final String text;

  /// An index into [text], not into the source. The renderer weights exactly
  /// this range rather than searching the snippet again and finding a
  /// different occurrence.
  final int matchStart;
  final int matchLength;
}

const _ellipsis = '...';

/// Cuts [lead] characters before the first match and [trail] after it,
/// eliding each side only when it was actually truncated. Null when the query
/// is not in the source, which is how a caller tells a title match from a
/// body one.
SearchSnippet? buildSearchSnippet({
  required String source,
  required String query,
  int lead = 34,
  int trail = 46,
}) {
  if (query.isEmpty) return null;

  final at = source.toLowerCase().indexOf(query.toLowerCase());
  if (at < 0) return null;

  final start = at - lead < 0 ? 0 : at - lead;
  final endCandidate = at + query.length + trail;
  final end = endCandidate > source.length ? source.length : endCandidate;

  final elideLeft = start > 0;
  final elideRight = end < source.length;

  final body = source.substring(start, end);
  final text = '${elideLeft ? _ellipsis : ''}$body'
      '${elideRight ? _ellipsis : ''}';

  return SearchSnippet(
    text: text,
    matchStart: at - start + (elideLeft ? _ellipsis.length : 0),
    matchLength: query.length,
  );
}

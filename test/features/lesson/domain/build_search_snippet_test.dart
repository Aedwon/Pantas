import 'package:pantas/features/lesson/domain/use_cases/build_search_snippet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sentence =
      'When you divide or multiply by a negative number, less than means '
      'swap the plan and the sign turns around the other way entirely.';

  test('a query that is not there has no snippet', () {
    expect(buildSearchSnippet(source: sentence, query: 'isotope'), isNull);
  });

  test('matching is case insensitive', () {
    expect(buildSearchSnippet(source: sentence, query: 'SWAP'), isNotNull);
  });

  test('the snippet points at the match it found', () {
    final snippet = buildSearchSnippet(source: sentence, query: 'swap')!;

    expect(
      snippet.text.substring(
        snippet.matchStart,
        snippet.matchStart + snippet.matchLength,
      ),
      'swap',
    );
  });

  test('a truncated lead and trail are elided', () {
    final snippet = buildSearchSnippet(source: sentence, query: 'swap')!;

    expect(snippet.text.startsWith('...'), isTrue);
    expect(snippet.text.endsWith('...'), isTrue);
  });

  test('a match near the start is not elided on the left', () {
    final snippet = buildSearchSnippet(source: sentence, query: 'When')!;

    expect(snippet.text.startsWith('...'), isFalse);
    expect(snippet.matchStart, 0);
  });

  test('a match near the end is not elided on the right', () {
    final snippet = buildSearchSnippet(source: sentence, query: 'entirely')!;

    expect(snippet.text.endsWith('...'), isFalse);
  });

  test('a short source comes back whole', () {
    final snippet = buildSearchSnippet(source: 'Venn diagrams', query: 'venn')!;

    expect(snippet.text, 'Venn diagrams');
    expect(snippet.matchStart, 0);
    expect(snippet.matchLength, 4);
  });

  test('an empty query has no snippet', () {
    expect(buildSearchSnippet(source: sentence, query: ''), isNull);
  });
}

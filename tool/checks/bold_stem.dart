// A stem that asks about the word in bold must contain a bold word.
import 'check.dart';
import 'content_snapshot.dart';

final _mentionsBold = RegExp(
  r'\bin\s+bold(?:face)?\b'
  r'|\bbold(?:face|faced|ed)?\s+(?:word|term|phrase|expression|part|portion|text|letter)s?\b'
  r'|\b(?:word|term|phrase)s?\s+(?:is|are)\s+bold'
  r'|\bnaka-?\s?bold\b',
  caseSensitive: false,
);

final _hasBold =
    RegExp(r'\*\*[^*\n]+\*\*|<(?:b|strong)>', caseSensitive: false);

class BoldStemCheck extends Check {
  const BoldStemCheck();

  @override
  String get name => 'bold-stem';

  @override
  String get origin =>
      'Nov 5 2026 CSE: a word in bold could not be seen in a bold stem, so the '
      'question "the word in bold" had nothing to point at';

  @override
  List<Violation> run(String root) =>
      findStemsMissingBold(ContentSnapshot.load(root).questions);
}

List<Violation> findStemsMissingBold(Iterable<QuestionRow> questions) => [
      for (final question in questions)
        if (_mentionsBold.hasMatch(question.stem) &&
            !_hasBold.hasMatch(question.stem))
          Violation(question.id, 'stem mentions bold but has no bold word'),
    ];

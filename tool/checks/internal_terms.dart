// No internal lane word or ruling code in a string a screen can show.
//
// Nov 25 2026: the first-run board carried the manager's shorthand into
// on-screen text ("Taste finished"). Aedwon: "don't call it taste finished.
// why even call it that - that's an internal term". The process entry asked
// for a check on the app's own strings (process-improvement.md, "An internal
// term reached a board he reviews").
//
// Scope: string literals in presentation code, where user-visible text lives.
// Code identifiers, keys with underscores (`first_run_intro`), comments and
// data-layer keys are not text a learner reads, so they are not checked.
// "trial" is not on the list: the 7-day free trial is user language.
import 'check.dart';

/// Lane words used for the first run while it was being designed, and the
/// project's decision and task codes (E-179, D191, U46, T-12, R3-O04).
final _word = RegExp(
  r'\b(taste|tutorial|guided|starter|first[ -]run)\b',
  caseSensitive: false,
);

/// Codes are upper case, and never a `\u2013` style escape.
final _code =
    RegExp(r'(?<!\\)\b(E-\d{2,}|D\d{2,}|U\d{2,}|T-\d+|R\d-[AO]\d{2})\b');

/// A widget key names a widget for tests; nobody reads it.
final _keyBefore = RegExp(r'Key(<[^>]*>)?\(\s*$');

/// A single- or double-quoted Dart string literal on one line.
final _literal = RegExp(
  r"'(?:[^'\\\n]|\\.)*'"
  r'|"(?:[^"\\\n]|\\.)*"',
);

class InternalTermsCheck extends Check {
  const InternalTermsCheck();

  @override
  String get name => 'internal-terms';

  @override
  String get origin =>
      'Nov 25 2026 first-run board: "Taste finished", an internal lane word, '
      'reached on-screen text';

  @override
  List<Violation> run(String root) => [
        for (final entry in libSources(root).entries)
          ...findInternalTerms(entry.key, entry.value),
      ];
}

List<Violation> findInternalTerms(String path, String source) {
  if (!path.contains('/presentation/')) return const [];
  final code = withoutLineComments(source);
  final found = <Violation>[];
  for (final literal in _literal.allMatches(code)) {
    final text = literal.group(0)!;
    // Imports and parts are paths, not text.
    if (text.startsWith("'package:") || text.endsWith(".dart'")) continue;
    final from = literal.start < 40 ? 0 : literal.start - 40;
    if (_keyBefore.hasMatch(code.substring(from, literal.start))) continue;
    for (final term in [..._word.allMatches(text), ..._code.allMatches(text)]) {
      found.add(
        Violation(
          '$path:${lineAt(code, literal.start)}',
          'shows the internal term "${term.group(0)}"; use the words the '
              'learner sees on the board',
        ),
      );
    }
  }
  return found;
}

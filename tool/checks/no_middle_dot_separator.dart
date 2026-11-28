// No middle dot or bullet joining two text items in a string the app shows.
//
// Nov 28 2026: a lead offered a CSE part weight as "Verbal Ability · 30%".
// Aedwon: "please note to never do that bullet separation. it's an AI pattern
// i prefer not using", and approved a mechanical check ("can you do a
// mechanical check to save tokens?"). Rule: design/system/patterns.md,
// "Joining text items". Use parentheses, a colon, a comma or a line break.
//
// Scope: string literals in lib/. A bullet that starts a list line
// ("• Account: ...") or stands alone as a list marker is a list, not a
// separator, so it passes. Comments are not checked.
import 'check.dart';

/// A single- or double-quoted Dart string literal on one line.
final _literal = RegExp(
  r"'(?:[^'\\\n]|\\.)*'"
  r'|"(?:[^"\\\n]|\\.)*"',
);

/// Whether a bullet in [body] (a literal without its quotes) has text before
/// it on the same line of the string: then it joins two items.
bool _bulletBetween(String body) {
  for (var i = body.indexOf('•'); i >= 0; i = body.indexOf('•', i + 1)) {
    final lineStart = body.lastIndexOf(r'\n', i);
    final before = body.substring(lineStart < 0 ? 0 : lineStart + 2, i);
    if (before.trim().isNotEmpty) return true;
  }
  return false;
}

class NoMiddleDotSeparatorCheck extends Check {
  const NoMiddleDotSeparatorCheck();

  @override
  String get name => 'no-middle-dot-separator';

  @override
  String get origin =>
      'Nov 28 2026: "Verbal Ability · 30%"; Aedwon: never join text items '
      'with a middle dot or bullet';

  @override
  List<Violation> run(String root) => [
        for (final entry in libSources(root).entries)
          ...findMiddleDotSeparators(entry.key, entry.value),
      ];
}

List<Violation> findMiddleDotSeparators(String path, String source) {
  final code = withoutLineComments(source);
  const fix = 'use parentheses, a colon, a comma or a line break '
      '(patterns.md, "Joining text items")';
  final found = <Violation>[];
  // A middle dot is never code, so any line outside a comment that holds one
  // is text, even inside an interpolation the literal pattern cannot follow.
  final lines = code.split('\n');
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].contains('·')) {
      found.add(Violation('$path:${i + 1}', 'joins text with "·"; $fix'));
    }
  }
  for (final literal in _literal.allMatches(code)) {
    final text = literal.group(0)!;
    if (!_bulletBetween(text.substring(1, text.length - 1))) continue;
    found.add(
      Violation(
        '$path:${lineAt(code, literal.start)}',
        'joins text with "•"; $fix',
      ),
    );
  }
  return found;
}

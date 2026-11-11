// Design values come from the generated token classes, never from literals.
//
// Bans, in `lib/` outside `lib/core/ui/theme/` and `lib/core/ui/motion/`:
// `Color(0x`, `Color.fromRGBO` and `Color.fromARGB`, any `Colors.<name>` but
// `transparent`, a numeric `fontSize:`, a number inside `EdgeInsets.*(`, a
// numeric `SizedBox(width:` or `SizedBox(height:`, a numeric
// `BorderRadius.circular(` or `Radius.circular(`, and `Cubic(`.
//
// A folder that has not moved onto the tokens yet is listed in
// `tool/checks/design_token_allowlist.txt`. That file is empty and stays empty.
//
// Pure drawing geometry (arc radii, path math, logo and icon construction, a
// curve in a data file) is not a design value. A trailing comment
// `// ds-geometry: <reason>` exempts that one line from the radius and `Cubic`
// rules, and only when the reason is not empty. It never exempts a color, a
// font size, a size or a spacing.
import 'dart:io';

import 'check.dart';

const _allowlistPath = 'tool/checks/design_token_allowlist.txt';

/// Folders whose literals are the token definitions themselves.
const _exemptPrefixes = ['lib/core/ui/theme/', 'lib/core/ui/motion/'];

class _Rule {
  const _Rule(this.pattern, this.message, {this.geometry = false});
  final String pattern;
  final String message;

  /// Whether a `ds-geometry` marker on the line exempts this rule.
  final bool geometry;
}

const _rules = [
  _Rule(r'\bColor\(\s*0x', 'Color(0x...) literal: use a PantasColors role'),
  _Rule(
    r'\bColor\.from(?:RGBO|ARGB)\(',
    'Color.fromRGBO/fromARGB literal: use a PantasColors role',
  ),
  _Rule(
    r'\bColors\.(?!transparent\b)[A-Za-z]\w*',
    'Colors.<name>: use a PantasColors role (only transparent is allowed)',
  ),
  _Rule(
    r'\bfontSize:\s*-?\d',
    'numeric fontSize: use a PantasType style',
  ),
  _Rule(
    r'\bSizedBox\(\s*(?:width|height):\s*-?\d',
    'numeric SizedBox size: use PantasSpace or PantasSize',
  ),
  _Rule(
    r'\b(?:BorderRadius|Radius)\.circular\(\s*-?\d',
    'numeric radius: use PantasRadius',
    geometry: true,
  ),
  _Rule(
    r'\bCubic\(',
    'Cubic(...) literal: use PantasCurves',
    geometry: true,
  ),
];

final _geometryMarker = RegExp(r'//\s*ds-geometry:\s*\S');

final _edgeInsetsOpen = RegExp(r'\bEdgeInsets(?:Directional)?\.\w+\(');
final _number = RegExp(r'(?<![\w.])\d+(?:\.\d+)?');

class DesignTokenLiteralsCheck extends Check {
  const DesignTokenLiteralsCheck();

  @override
  String get name => 'design-token-literals';

  @override
  String get origin =>
      'Nov 8 2026 design system 4.0: colors, sizes, spacing, radii and curves '
      'typed by hand in two palettes drifted from the one system, so a '
      'screen could not follow a system change';

  @override
  List<Violation> run(String root) {
    final file = File('$root/$_allowlistPath');
    final allowlist = file.existsSync()
        ? parseAllowlist(file.readAsStringSync())
        : <String>{};
    return [
      ...findTokenLiterals(libSources(root), allowlist),
      for (final entry in allowlist)
        Violation(
          _allowlistPath,
          'lists $entry: the allowlist must stay empty; move the values onto '
          'the tokens',
        ),
    ];
  }
}

/// One path per line: a folder ends with `/`, anything else is one file.
/// Blank lines and `#` comments are ignored.
Set<String> parseAllowlist(String text) => {
      for (final line in text.split('\n'))
        if (line.trim().isNotEmpty && !line.trim().startsWith('#')) line.trim(),
    };

bool _allowed(String path, Set<String> allowlist) => allowlist.any(
      (entry) => entry.endsWith('/') ? path.startsWith(entry) : path == entry,
    );

/// Blanks a trailing `//` comment and the text inside string quotes, keeping
/// offsets, so only code is matched.
String _blankLine(String line) {
  final out = StringBuffer();
  var quote = '';
  for (var i = 0; i < line.length; i++) {
    final c = line[i];
    if (quote.isNotEmpty) {
      if (c == r'\' && i + 1 < line.length) {
        out.write('  ');
        i++;
      } else if (c == quote) {
        quote = '';
        out.write(c);
      } else {
        out.write(' ');
      }
    } else if (c == "'" || c == '"') {
      quote = c;
      out.write(c);
    } else if (c == '/' && i + 1 < line.length && line[i + 1] == '/') {
      out.write(' ' * (line.length - i));
      break;
    } else {
      out.write(c);
    }
  }
  return out.toString();
}

String _code(String source) =>
    withoutLineComments(source).split('\n').map(_blankLine).join(
          '\n',
        );

/// Findings for [sources] (project-relative path to text).
List<Violation> findTokenLiterals(
  Map<String, String> sources,
  Set<String> allowlist,
) {
  final found = <Violation>[];
  for (final entry in sources.entries) {
    final path = entry.key;
    if (_exemptPrefixes.any(path.startsWith) || _allowed(path, allowlist)) {
      continue;
    }
    final code = _code(entry.value);
    final rawLines = entry.value.split('\n');
    bool marked(int line) =>
        line <= rawLines.length && _geometryMarker.hasMatch(rawLines[line - 1]);
    for (final rule in _rules) {
      for (final match in RegExp(rule.pattern).allMatches(code)) {
        final line = lineAt(code, match.start);
        if (rule.geometry && marked(line)) continue;
        found.add(Violation('$path:$line', rule.message));
      }
    }
    for (final match in _edgeInsetsOpen.allMatches(code)) {
      final args = _balancedArgs(code, match.end);
      if (_number.hasMatch(args)) {
        found.add(
          Violation(
            '$path:${lineAt(code, match.start)}',
            'numeric EdgeInsets value: use PantasSpace',
          ),
        );
      }
    }
  }
  return found;
}

/// The text between the parenthesis opened just before [start] and its pair.
String _balancedArgs(String code, int start) {
  var depth = 1;
  var i = start;
  while (i < code.length && depth > 0) {
    if (code[i] == '(') depth++;
    if (code[i] == ')') depth--;
    i++;
  }
  return code.substring(start, i - 1);
}

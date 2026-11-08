// Design values come from the generated token classes, never from literals.
//
// Bans, in `lib/` outside `lib/core/ui/theme/` and `lib/core/ui/motion/`:
// `Color(0x`, `Color.fromRGBO` and `Color.fromARGB`, any `Colors.<name>` but
// `transparent`, a numeric `fontSize:`, a number inside `EdgeInsets.*(`, a
// numeric `SizedBox(width:` or `SizedBox(height:`, a numeric
// `BorderRadius.circular(` or `Radius.circular(`, and `Cubic(`.
//
// A folder that has not moved onto the tokens yet is listed in
// `tool/checks/design_token_allowlist.txt`. Each family of the design system
// build removes its folders from that file; it is empty at the end.
import 'dart:io';

import 'check.dart';

const _allowlistPath = 'tool/checks/design_token_allowlist.txt';

/// Folders whose literals are the token definitions themselves.
const _exemptPrefixes = ['lib/core/ui/theme/', 'lib/core/ui/motion/'];

class _Rule {
  const _Rule(this.pattern, this.message);
  final String pattern;
  final String message;
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
  ),
  _Rule(r'\bCubic\(', 'Cubic(...) literal: use PantasCurves'),
];

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
        if (!_entryExists(root, entry))
          Violation(_allowlistPath, 'lists $entry, which does not exist'),
    ];
  }
}

bool _entryExists(String root, String entry) => entry.endsWith('/')
    ? Directory('$root/$entry').existsSync()
    : File('$root/$entry').existsSync();

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
    for (final rule in _rules) {
      for (final match in RegExp(rule.pattern).allMatches(code)) {
        found.add(
          Violation('$path:${lineAt(code, match.start)}', rule.message),
        );
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

// A letter or digit key must be bound through LetterShortcuts.
//
// Settings > Accessibility > Keyboard Shortcuts turns off every single
// character shortcut (WCAG 2.1.4). That works only while all of them pass
// through LetterShortcuts in lib/core/ui/web/letter_shortcuts.dart. A binding
// written straight with LogicalKeyboardKey.keyF would keep firing with the
// switch off. Ctrl and Cmd shortcuts (Ctrl K) are not character keys.
import 'check.dart';

const _gateFile = 'lib/core/ui/web/letter_shortcuts.dart';

final _characterKey = RegExp(r'LogicalKeyboardKey\.(?:key[A-Z]|digit[0-9])\b');
final _modifier = RegExp(r'\b(?:control|meta)\s*:\s*true');

class LetterShortcutGateCheck extends Check {
  const LetterShortcutGateCheck();

  @override
  String get name => 'letter-shortcut-gate';

  @override
  String get origin =>
      'Nov 2026 design system 4.0 (decision 103, WCAG 2.1.4): single-letter '
      'shortcuts must all obey the Keyboard Shortcuts setting';

  @override
  List<Violation> run(String root) => findUngatedLetterKeys(libSources(root));
}

/// Every letter or digit key in [sources] that is not bound through the gate.
List<Violation> findUngatedLetterKeys(Map<String, String> sources) {
  final violations = <Violation>[];
  for (final entry in sources.entries) {
    if (entry.key == _gateFile) continue;
    final source = withoutLineComments(entry.value);
    for (final match in _characterKey.allMatches(source)) {
      final close = source.indexOf(')', match.end);
      final call = source.substring(
        match.end,
        close < 0 ? source.length : close,
      );
      if (_modifier.hasMatch(call)) continue;
      violations.add(
        Violation(
          '${entry.key}:${lineAt(source, match.start)}',
          '${match.group(0)} is bound outside LetterShortcuts, so the '
              'Keyboard Shortcuts setting cannot turn it off',
        ),
      );
    }
  }
  return violations;
}

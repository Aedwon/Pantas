// A letter or digit key must be bound through LetterShortcuts.
//
// Settings > Accessibility > Keyboard Shortcuts turns off every single
// character shortcut (WCAG 2.1.4). That works only while all of them pass
// through LetterShortcuts in lib/core/ui/web/letter_shortcuts.dart. A binding
// written straight with LogicalKeyboardKey.keyF would keep firing with the
// switch off. Ctrl and Cmd shortcuts (Ctrl K) are not character keys.
import 'check.dart';

const _gateFile = 'lib/core/ui/web/letter_shortcuts.dart';

/// Findings that are known. Key: path.
const _accepted = <String, String>{
  'lib/core/ui/components/typeahead_buffer.dart':
      'type-ahead in Select and Popover acts only while the open list has '
          'focus, which WCAG 2.1.4 exempts',
};

final _characterKey = RegExp(
  r'LogicalKeyboardKey\.(?:key[A-Z]|digit[0-9]|numpad[0-9])\b',
);
final _characterActivator = RegExp(r'\bCharacterActivator\(');
final _eventCharacter = RegExp(r'\.character\b');
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

/// Every character key in [sources] that is not bound through the gate: a
/// letter, digit or numpad key, a CharacterActivator, or an event's character.
List<Violation> findUngatedLetterKeys(Map<String, String> sources) {
  final violations = <Violation>[];
  for (final entry in sources.entries) {
    if (entry.key == _gateFile) continue;
    final source = withoutLineComments(entry.value);
    void add(RegExpMatch match, String what) => violations.add(
          Violation(
            '${entry.key}:${lineAt(source, match.start)}',
            '$what is handled outside LetterShortcuts, so the Keyboard '
                'Shortcuts setting cannot turn it off',
            acceptedBecause: _accepted[entry.key],
          ),
        );
    for (final match in _characterKey.allMatches(source)) {
      if (_inModifierActivator(source, match.start)) continue;
      add(match, match.group(0)!);
    }
    for (final match in _characterActivator.allMatches(source)) {
      add(match, 'CharacterActivator');
    }
    for (final match in _eventCharacter.allMatches(source)) {
      add(match, 'a key event character');
    }
  }
  return violations;
}

/// Whether [offset] sits inside a SingleActivator call that itself carries a
/// Ctrl or Cmd modifier. A modifier elsewhere in the file does not count.
bool _inModifierActivator(String source, int offset) {
  const open = 'SingleActivator(';
  final start = source.lastIndexOf(open, offset);
  if (start < 0) return false;
  var depth = 0;
  for (var i = start + open.length - 1; i < source.length; i++) {
    final char = source[i];
    if (char == '(') depth++;
    if (char == ')') depth--;
    if (depth == 0) {
      if (i < offset) return false;
      return _modifier.hasMatch(source.substring(start, i));
    }
  }
  return false;
}

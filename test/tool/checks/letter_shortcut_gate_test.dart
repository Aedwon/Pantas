import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/letter_shortcut_gate.dart';

void main() {
  test('a letter bound straight with SingleActivator fails', () {
    final found = findUngatedLetterKeys({
      'lib/features/quiz/page.dart': '''
final b = {
  const SingleActivator(LogicalKeyboardKey.keyF): flag,
};
''',
    });
    expect(found.single.where, 'lib/features/quiz/page.dart:2');
    expect(found.single.message, contains('keyF'));
  });

  test('so do a list of letter keys and a digit', () {
    final found = findUngatedLetterKeys({
      'lib/a.dart': '''
const keys = [LogicalKeyboardKey.keyA, LogicalKeyboardKey.keyB];
const d = SingleActivator(LogicalKeyboardKey.digit1);
''',
    });
    expect(found, hasLength(3));
  });

  test('Ctrl and Cmd shortcuts pass', () {
    expect(
      findUngatedLetterKeys({
        'lib/shell.dart': '''
const a = SingleActivator(LogicalKeyboardKey.keyK, control: true);
const b = SingleActivator(
  LogicalKeyboardKey.keyK,
  meta: true,
);
''',
      }),
      isEmpty,
    );
  });

  test('the gate file, comments, Esc and arrows pass', () {
    expect(
      findUngatedLetterKeys({
        'lib/core/ui/web/letter_shortcuts.dart':
            'const k = LogicalKeyboardKey.keyF;',
        'lib/b.dart': '''
// LogicalKeyboardKey.keyF is bound by LetterShortcuts.
const e = SingleActivator(LogicalKeyboardKey.escape);
const l = SingleActivator(LogicalKeyboardKey.arrowLeft);
''',
      }),
      isEmpty,
    );
  });
}

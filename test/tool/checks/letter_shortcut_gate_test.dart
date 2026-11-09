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

  test('a numpad digit fails', () {
    final found = findUngatedLetterKeys({
      'lib/a.dart': 'const d = SingleActivator(LogicalKeyboardKey.numpad3);',
    });
    expect(found.single.message, contains('numpad3'));
  });

  test('a CharacterActivator fails', () {
    final found = findUngatedLetterKeys({
      'lib/a.dart': "final c = {const CharacterActivator('f'): flag};",
    });
    expect(found.single.message, contains('CharacterActivator'));
  });

  test('reading an event character fails, except the shared type-ahead', () {
    const code = 'void k(KeyEvent e) { if (e.character == "f") flag(); }';
    final found = findUngatedLetterKeys({
      'lib/a.dart': code,
      'lib/core/ui/components/typeahead_buffer.dart': code,
    });
    expect(found, hasLength(2));
    expect(
      found.where((v) => v.acceptedBecause == null).single.where,
      'lib/a.dart:1',
    );
  });

  test('a modifier on a different call does not exempt a letter', () {
    final found = findUngatedLetterKeys({
      'lib/a.dart': '''
const keys = [LogicalKeyboardKey.keyA];
const k = SingleActivator(LogicalKeyboardKey.keyK, control: true);
''',
    });
    expect(found.single.where, 'lib/a.dart:1');
  });

  test('a letter and a modified key in one map: only the letter fails', () {
    final found = findUngatedLetterKeys({
      'lib/a.dart': '''
final m = {
  const SingleActivator(LogicalKeyboardKey.keyF): flag,
  const SingleActivator(LogicalKeyboardKey.keyK, meta: true): search,
};
''',
    });
    expect(found.single.where, 'lib/a.dart:2');
  });
}

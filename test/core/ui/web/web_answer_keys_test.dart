import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/web/letter_shortcuts.dart';
import 'package:pantas/core/ui/web/web_key_focus.dart';

void main() {
  final picks = <int>[];
  var flags = 0;

  Future<void> pump(WidgetTester tester, {int count = 5}) async {
    picks.clear();
    flags = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LetterShortcuts(
            bindings: {'f': () => flags++},
            once: answerKeyBindings(
              choiceCount: () => count,
              onPick: picks.add,
            ),
            child: KeyFocusKeeper(
              child: Column(
                children: [
                  const TextField(),
                  TextButton(onPressed: () {}, child: const Text('Go')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('A to E pick the first five choices in order', (tester) async {
    await pump(tester);
    for (final key in [
      LogicalKeyboardKey.keyA,
      LogicalKeyboardKey.keyB,
      LogicalKeyboardKey.keyC,
      LogicalKeyboardKey.keyD,
      LogicalKeyboardKey.keyE,
    ]) {
      await tester.sendKeyEvent(key);
    }
    expect(picks, [0, 1, 2, 3, 4]);
  });

  testWidgets('a letter past the last choice picks nothing', (tester) async {
    await pump(tester, count: 4);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
    expect(picks, isEmpty);
  });

  testWidgets('F is left to flagging and never picks', (tester) async {
    await pump(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    expect(picks, isEmpty);
    expect(flags, 1);
  });

  testWidgets('a held key picks once', (tester) async {
    await pump(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyB);
    await tester.sendKeyRepeatEvent(LogicalKeyboardKey.keyB);
    await tester.sendKeyRepeatEvent(LogicalKeyboardKey.keyB);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyB);
    expect(picks, [1]);
  });

  testWidgets('a key typed into a text field picks nothing', (tester) async {
    await pump(tester);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    expect(picks, isEmpty);
  });
}

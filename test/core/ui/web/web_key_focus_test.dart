import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/web/web_key_focus.dart';

void main() {
  var pressed = 0;
  final field = TextEditingController();

  Future<void> pump(WidgetTester tester, {bool keeper = true}) async {
    pressed = 0;
    final page = Column(
      children: [
        TextField(controller: field),
        TextButton(onPressed: () {}, child: const Text('Go')),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.keyG): () => pressed++,
            },
            child: keeper
                ? KeyFocusKeeper(child: page)
                : Focus(autofocus: true, child: page),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
  }

  testWidgets('a plain autofocus loses the keys when focus falls to the scope',
      (tester) async {
    await pump(tester, keeper: false);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
    expect(pressed, 1);
    FocusManager.instance.primaryFocus?.unfocus();
    await settle(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
    expect(pressed, 1, reason: 'the fault the keeper exists to close');
  });

  testWidgets('the keeper takes focus back when it falls to the scope',
      (tester) async {
    await pump(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
    expect(pressed, 1);
    FocusManager.instance.primaryFocus?.unfocus();
    await settle(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
    expect(pressed, 2);
    FocusManager.instance.rootScope.requestFocus();
    await settle(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
    expect(pressed, 3);
  });

  testWidgets('it takes focus back when a control inside stops taking it',
      (tester) async {
    var enabled = true;
    late StateSetter set;
    pressed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.keyG): () => pressed++,
            },
            child: KeyFocusKeeper(
              child: StatefulBuilder(
                builder: (context, setState) {
                  set = setState;
                  return TextButton(
                    onPressed: enabled ? () {} : null,
                    child: const Text('Check'),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    Focus.of(tester.element(find.text('Check'))).requestFocus();
    await tester.pump();
    set(() => enabled = false);
    await settle(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
    expect(pressed, 1);
  });

  testWidgets('it leaves a text field alone', (tester) async {
    await pump(tester);
    await tester.tap(find.byType(TextField));
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'g');
    await settle(tester);
    expect(field.text, 'g');
    final held = FocusManager.instance.primaryFocus?.context?.widget;
    expect(held, isA<Focus>());
    expect((held! as Focus).debugLabel, 'EditableText');
  });

  testWidgets('it leaves a dialog on top alone', (tester) async {
    await pump(tester);
    unawaited(
      showDialog<void>(
        context: tester.element(find.byType(Scaffold)),
        builder: (_) => const AlertDialog(content: TextField(autofocus: true)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
    await settle(tester);
    expect(pressed, 0);
    expect(find.byType(AlertDialog), findsOneWidget);
    Navigator.of(tester.element(find.byType(AlertDialog))).pop();
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
    expect(pressed, 1, reason: 'the page has its keys again once it is on top');
  });
}

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
  group('EnterShortcut', () {
    var page = 0;
    var button = 0;

    Future<void> pumpEnter(WidgetTester tester) async {
      page = 0;
      button = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnterShortcut(
              onEnter: () => page++,
              child: KeyFocusKeeper(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () => button++,
                      child: const Text('Go'),
                    ),
                    const TextButton(onPressed: null, child: Text('Off')),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('runs the page when no control holds focus', (tester) async {
      await pumpEnter(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(page, 1);
      expect(button, 0);
    });

    testWidgets('yields to the button that holds focus', (tester) async {
      await pumpEnter(tester);
      Focus.of(tester.element(find.text('Go'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(button, 1, reason: 'Enter presses the focused button');
      expect(page, 0, reason: 'the page action stays out of it');
    });

    testWidgets('runs again once focus is back on the page', (tester) async {
      await pumpEnter(tester);
      Focus.of(tester.element(find.text('Go'))).requestFocus();
      await tester.pump();
      FocusManager.instance.primaryFocus?.unfocus();
      await settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(page, 1);
      expect(button, 0);
    });

    testWidgets('a held key runs the page once', (tester) async {
      await pumpEnter(tester);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
      expect(page, 1);
    });

    testWidgets('Enter with a modifier is left alone', (tester) async {
      await pumpEnter(tester);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      expect(page, 0);
    });
  });
}

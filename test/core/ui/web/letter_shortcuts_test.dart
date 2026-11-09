import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/components/pantas_tooltip.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/letter_shortcuts.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_key_focus.dart';

void main() {
  var flags = 0;
  var closes = 0;
  var searches = 0;
  final picks = <int>[];

  Future<void> pump(WidgetTester tester, {bool? enabled}) async {
    flags = closes = searches = 0;
    picks.clear();
    Widget page = Scaffold(
      body: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
              searches++,
        },
        child: LetterShortcuts(
          bindings: {'f': () => flags++},
          once: answerKeyBindings(choiceCount: () => 5, onPick: picks.add),
          also: {
            const SingleActivator(LogicalKeyboardKey.escape): () => closes++,
          },
          child: const KeyFocusKeeper(child: SizedBox.expand()),
        ),
      ),
    );
    if (enabled != null) {
      page = LetterShortcutsScope(enabled: enabled, child: page);
    }
    await tester.pumpWidget(MaterialApp(home: page));
    await tester.pump();
  }

  testWidgets('with no scope the letters work', (tester) async {
    await pump(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
    expect(flags, 1);
    expect(picks, [1]);
  });

  testWidgets('with the setting on the letters work', (tester) async {
    await pump(tester, enabled: true);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    expect(flags, 1);
  });

  testWidgets('with the setting off no letter does anything', (tester) async {
    await pump(tester, enabled: false);
    for (final key in [
      LogicalKeyboardKey.keyA,
      LogicalKeyboardKey.keyE,
      LogicalKeyboardKey.keyF,
    ]) {
      await tester.sendKeyEvent(key);
    }
    expect(flags, 0);
    expect(picks, isEmpty);
  });

  testWidgets('with the setting off Esc and Ctrl K still work', (tester) async {
    await pump(tester, enabled: false);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    expect(closes, 1);
    expect(searches, 1);
  });

  testWidgets('turning the setting off at runtime stops the letters',
      (tester) async {
    Widget app({required bool on}) => MaterialApp(
          home: LetterShortcutsScope(
            enabled: on,
            child: Scaffold(
              body: LetterShortcuts(
                bindings: {'f': () => flags++},
                child: const KeyFocusKeeper(child: SizedBox.expand()),
              ),
            ),
          ),
        );
    flags = 0;
    await tester.pumpWidget(app(on: true));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.pumpWidget(app(on: false));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    expect(flags, 1);
  });

  group('hints', () {
    Widget hints({required bool on}) => MaterialApp(
          home: LetterShortcutsScope(
            enabled: on,
            child: const Scaffold(
              body: Column(
                children: [
                  WebKeyHint('F'),
                  WebKeyHint('2'),
                  WebKeyHint('Esc'),
                  WebKeyHint('Enter'),
                  WebKeyHint('Ctrl K'),
                ],
              ),
            ),
          ),
        );

    testWidgets('all hints show while the letters are on', (tester) async {
      await tester.pumpWidget(hints(on: true));
      for (final label in ['F', '2', 'Esc', 'Enter', 'Ctrl K']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('letter and digit hints hide when off; others stay',
        (tester) async {
      await tester.pumpWidget(hints(on: false));
      expect(find.text('F'), findsNothing);
      expect(find.text('2'), findsNothing);
      for (final label in ['Esc', 'Enter', 'Ctrl K']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });
  });

  group('buttons', () {
    Future<Size> sizeOf(
      WidgetTester tester, {
      required bool on,
      String? keyHint,
      PantasButtonKind kind = PantasButtonKind.tertiary,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: true),
          home: LetterShortcutsScope(
            enabled: on,
            child: Scaffold(
              body: Center(
                child: WebButton(
                  label: 'Flag',
                  kind: kind,
                  keyHint: keyHint,
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      return tester.getSize(find.byType(WebButton));
    }

    testWidgets('a letter hint takes no room while the letters are off',
        (tester) async {
      for (final kind in [
        PantasButtonKind.tertiary,
        PantasButtonKind.primary,
      ]) {
        final bare = await sizeOf(tester, on: false, kind: kind);
        final off = await sizeOf(tester, on: false, keyHint: 'F', kind: kind);
        expect(off, bare, reason: '$kind');
        final on = await sizeOf(tester, on: true, keyHint: 'F', kind: kind);
        expect(on.width, greaterThan(bare.width), reason: '$kind with hint');
      }
    });

    testWidgets('an Enter hint keeps its room while the letters are off',
        (tester) async {
      final bare = await sizeOf(tester, on: false);
      final enter = await sizeOf(tester, on: false, keyHint: 'Enter');
      expect(enter.width, greaterThan(bare.width));
    });
  });

  group('tooltips', () {
    test('a letter shortcut drops out when off, Esc stays', () {
      const flag = PantasTooltip(
        message: 'Flag',
        shortcut: 'F',
        child: SizedBox(),
      );
      const close = PantasTooltip(
        message: 'Close',
        shortcut: 'Esc',
        child: SizedBox(),
      );
      expect(flag.textFor(lettersOn: true), 'Flag (F)');
      expect(flag.textFor(lettersOn: false), 'Flag');
      expect(close.textFor(lettersOn: false), 'Close (Esc)');
    });

    testWidgets('withLetterKey follows the setting', (tester) async {
      late String on;
      late String off;
      await tester.pumpWidget(
        Column(
          children: [
            LetterShortcutsScope(
              enabled: true,
              child: Builder(
                builder: (context) {
                  on = withLetterKey(context, 'Bookmark', 'B');
                  return const SizedBox();
                },
              ),
            ),
            LetterShortcutsScope(
              enabled: false,
              child: Builder(
                builder: (context) {
                  off = withLetterKey(context, 'Bookmark', 'B');
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      );
      expect(on, 'Bookmark (B)');
      expect(off, 'Bookmark');
    });
  });
}

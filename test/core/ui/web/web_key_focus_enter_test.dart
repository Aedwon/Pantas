import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/web/web_key_focus.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';

/// 6T-3: Enter on a page whose main button shows the Enter hint.
void main() {
  setUp(resetWebKeyboardFocus);

  Future<({List<String> log, FocusNode chevron})> mount(
    WidgetTester tester,
  ) async {
    final log = <String>[];
    final chevron = FocusNode();
    addTearDown(chevron.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Focus(
            autofocus: true,
            onKeyEvent: enterKeyHandler(
              () => log.add('start'),
              keepsEnter: (_) => webFocusFromPointer,
            ),
            child: Center(
              child: TextButton(
                focusNode: chevron,
                onPressed: () => log.add('chevron'),
                child: const Text('Chevron'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    // A rule of the ring helper: nothing counts until it is listening.
    expect(webFocusFromPointer, isTrue);
    return (log: log, chevron: chevron);
  }

  testWidgets('Enter presses Start after a click leaves focus on a control',
      (tester) async {
    final page = await mount(tester);
    await tester.tap(find.text('Chevron'));
    // On the web a click focuses the control. A test tap does not.
    page.chevron.requestFocus();
    await tester.pump();
    expect(page.log, ['chevron']);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(page.log, ['chevron', 'start']);
  });

  testWidgets('Enter stays with a control the keyboard reached',
      (tester) async {
    final page = await mount(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(page.chevron.hasPrimaryFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(page.log, ['chevron']);
  });

  testWidgets('a second key after a click counts as the keyboard',
      (tester) async {
    final page = await mount(tester);
    await tester.tap(find.text('Chevron'));
    page.chevron.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    page.chevron.requestFocus();
    await tester.pump();
    page.log.clear();

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(page.log, ['chevron']);
  });
}

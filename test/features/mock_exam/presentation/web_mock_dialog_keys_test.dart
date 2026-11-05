import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/presentation/pause_page.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/web_mock_dialog.dart';

Future<void> _pumpWide(WidgetTester tester, Widget home) async {
  debugWebPlatformOverride = true;
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildDarkTheme(web: true),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: home,
    ),
  );
  await tester.pump();
}

void main() {
  tearDown(() => debugWebPlatformOverride = null);
  paused();

  testWidgets(
      'discard dialog on the paused page: Esc closes it and Enter is Keep It '
      'with no click first', (tester) async {
    var discarded = false;
    await _pumpWide(
      tester,
      PausePage(
        partNames: const [''],
        currentPartIndex: 0,
        remaining: const Duration(hours: 3),
        partLength: const Duration(hours: 3, minutes: 30),
        answeredCount: 4,
        onResume: () {},
        onDiscard: () => discarded = true,
      ),
    );
    await tester.tap(find.text('Discard This Mock'));
    await tester.pumpAndSettle();
    expect(find.text('Discard this mock?'), findsOneWidget);

    // Focus is inside the dialog, not on its route above the keys.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Discard this mock?'), findsNothing);

    await tester.tap(find.text('Discard This Mock'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Discard this mock?'), findsNothing);
    expect(discarded, isFalse);
  });

  testWidgets(
      'Tab goes straight into the dialog and Enter on a button '
      'presses that button', (tester) async {
    var confirmed = 0;
    var cancelled = 0;
    await _pumpWide(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => WebMockDialog(
                  title: 'Submit the exam?',
                  message: 'Sure?',
                  primaryLabel: 'Submit',
                  secondaryLabel: 'Keep Working',
                  onConfirm: () => confirmed++,
                  onCancel: () => cancelled++,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // The first Tab lands on a button, not on a hidden stop.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(confirmed, 1, reason: 'first Tab is Submit, Enter presses it');
    expect(cancelled, 0);

    // Enter with focus on the dialog, not on a button, is the safe choice.
    // A held key does it once: the repeats are ignored.
    Focus.of(tester.element(find.text('Sure?'))).requestFocus();
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyRepeatEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyRepeatEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(confirmed, 1);
    expect(cancelled, 1);
  });
}

// Board A of the paused one-block mock (Paused, v=A): the glass, 22 px, the
// title in a 60 px line, 2 px, the time in a 38 px line, "left", 32 px, then
// the buttons.
void paused() {
  testWidgets('4O-9: the paused page spaces its group as board A does',
      (tester) async {
    await _pumpWide(
      tester,
      PausePage(
        partNames: const [''],
        currentPartIndex: 0,
        remaining: const Duration(hours: 3, minutes: 8, seconds: 57),
        partLength: const Duration(hours: 3, minutes: 30),
        answeredCount: 12,
        onResume: () {},
        onDiscard: () {},
      ),
    );
    final glass = tester.getRect(find.byKey(const ValueKey('pause-hourglass')));
    final title = tester.getRect(find.text('Paused'));
    final time = tester.getRect(find.text('3:08:57'));
    final left = tester.getRect(find.text('left'));
    final buttons =
        tester.getRect(find.byKey(const ValueKey('web-pause-content')));
    // The title's line is 60 px and the words sit in the middle of it.
    expect(title.center.dy, closeTo(glass.bottom + 22 + 30, 1));
    expect(time.top, closeTo(glass.bottom + 22 + 60 + 2, 1));
    expect(time.height, closeTo(38, .5));
    expect(left.top, closeTo(time.bottom, 1));
    expect(buttons.top - left.bottom, closeTo(32, 1));
  });
}

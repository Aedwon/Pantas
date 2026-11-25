import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/presentation/session_end_screen.dart';

import '../../../helpers/button_placement.dart';
import 'session_end_screen_test.dart' show completedAttempt, completedSession;

void main() {
  tearDown(() => debugWebPlatformOverride = null);

  Future<void> pumpResults(
    WidgetTester tester, {
    required bool batch,
    int correct = 10,
  }) async {
    debugWebPlatformOverride = true;
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final session = completedSession(correct: correct, batch: batch);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(
                size: Size(1440, 900),
                disableAnimations: true,
              ),
              child: SessionEndBody(
                session: session,
                attempt: completedAttempt(session),
                subjectNames: const {'t': 'Science'},
                proIsActive: false,
                onDone: () {},
                onQuestion: (_) {},
                onAll: () {},
                onMistakes: () {},
                onNotes: () {},
                onNext: batch ? () async {} : null,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final batch in [true, false]) {
    testWidgets(
        'wide results: Done is top right, level with the title '
        '(next session: $batch)', (tester) async {
      await pumpResults(tester, batch: batch);
      expectWidePlacement(tester);
      final done = tester.getRect(find.widgetWithText(WebButton, 'Done'));
      final title = tester.getRect(find.text('Perfect!'));
      // Level with the title, right of it, at the content column's right end
      // (640 wide, centered on 1440).
      expect(done.center.dy, closeTo(title.center.dy, 1));
      expect(done.left, greaterThan(title.right));
      expect(done.right, closeTo(720 + 320, 1));
      // Natural width, and the title stays centered.
      expect(done.width, lessThan(260));
      expect(title.center.dx, closeTo(720, 1));
      final start = find.widgetWithText(WebButton, 'Start Session 2');
      if (batch) {
        final r = tester.getRect(start);
        expect(r.center.dx, closeTo(720, 1));
        expect(r.top, greaterThan(done.bottom));
      } else {
        expect(start, findsNothing);
      }
    });
  }

  testWidgets('wide results Tab order: Close, Done, Start Session',
      (tester) async {
    await pumpResults(tester, batch: true);
    final done = tester.getRect(find.widgetWithText(WebButton, 'Done'));
    final start =
        tester.getRect(find.widgetWithText(WebButton, 'Start Session 2'));
    final stops = <Offset>[];
    for (var i = 0; i < 40; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      stops.add(FocusManager.instance.primaryFocus!.rect.center);
    }
    // Close (top left), then Done (top right). The question circles sit
    // between Done and Start Session in the page, so Start Session comes
    // after them.
    expect(stops[0].dx, lessThan(100));
    expect(done.contains(stops[1]), isTrue, reason: '${stops[1]} vs $done');
    final at = stops.indexWhere(start.contains);
    expect(at, greaterThan(1), reason: 'Start Session is reached after Done');
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/presentation/quiz_tap_area.dart';
import 'package:pantas/features/quiz/presentation/session_end_screen.dart';

import 'session_end_screen_test.dart' show completedAttempt, completedSession;

void main() {
  var done = 0;
  var all = 0;
  var mistakes = 0;
  final questions = <int>[];
  final mistakeRows = <int>[];

  Future<void> pump(WidgetTester tester, {required bool wide}) async {
    done = all = mistakes = 0;
    questions.clear();
    mistakeRows.clear();
    debugWebPlatformOverride = wide;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view
      ..physicalSize = wide ? const Size(1440, 1400) : const Size(800, 1400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    // Seven right and three wrong: the three mistakes all sit in the preview.
    final session = completedSession();
    await tester.pumpWidget(
      MaterialApp(
        theme: wide ? buildLightTheme(web: true) : buildLightTheme(),
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(
              size: tester.view.physicalSize,
              disableAnimations: true,
            ),
            child: SessionEndBody(
              session: session,
              attempt: completedAttempt(session),
              subjectNames: const {'t': 'Science'},
              proIsActive: false,
              onDone: () => done++,
              onQuestion: questions.add,
              onMistake: mistakeRows.add,
              onAll: () => all++,
              onMistakes: () => mistakes++,
              onNotes: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('the end screen on wide web', () {
    testWidgets('Enter with no control focused is Done', (tester) async {
      await pump(tester, wide: true);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(done, 1);
    });

    testWidgets('the first Tab lands on Close, not on a hidden stop',
        (tester) async {
      await pump(tester, wide: true);
      // Focus lost to the page's scope, as it is after a reload.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final focused = FocusManager.instance.primaryFocus!;
      expect(
        focused.context!.findAncestorWidgetOfExactType<PantasIconButton>()?.key,
        const ValueKey('results-close'),
      );
    });

    testWidgets('Enter on "See all questions" opens the list, not Done',
        (tester) async {
      await pump(tester, wide: true);
      Focus.of(tester.element(find.text('See all 10 questions')))
          .requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(all, 1, reason: 'Enter pressed the row it was on');
      expect(done, 0, reason: 'the page action stays out of it');
    });
  });

  for (final wide in [true, false]) {
    testWidgets('a mistake row opens a mistake, wide=$wide', (tester) async {
      await pump(tester, wide: wide);
      // The first row is the first wrong answer: question 8 of 10.
      final row = find.text('Question 7');
      expect(row, findsOneWidget);
      await tester.tap(row);
      await tester.pump();
      expect(mistakeRows, [7]);
      expect(questions, isEmpty, reason: 'it must not open the whole session');
    });

    testWidgets('a numbered circle still opens that question, wide=$wide',
        (tester) async {
      await pump(tester, wide: wide);
      await tester.tap(
        find.widgetWithText(QuizTapArea, '3'),
      );
      await tester.pump();
      expect(questions, [2]);
      expect(mistakeRows, isEmpty);
    });
  }
}

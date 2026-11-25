import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/remote/content_limit.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/features/first_run/application/first_run_data.dart';
import 'package:pantas/features/first_run/domain/first_run_progress.dart';

import '../../../helpers/button_placement.dart';
import '../first_run_harness.dart';

void main() {
  errorAndPlacementTests();
  group('intro', () {
    testWidgets('phone shows the strings and a stacked pair of 52',
        (tester) async {
      await pumpFirstRun(tester);
      expect(find.text('Try Pantas first'), findsOneWidget);
      expect(find.text('Read a short lesson'), findsOneWidget);
      expect(find.text('Answer 3 questions'), findsOneWidget);
      expect(find.text('Each answer is explained.'), findsOneWidget);
      expect(
        find.text('Get your score from the assessment on Home'),
        findsOneWidget,
      );
      final start = tester.getRect(find.widgetWithText(InkWell, 'Start'));
      final skip = tester.getRect(find.widgetWithText(InkWell, 'Skip'));
      expect(start.height, 52);
      expect(skip.height, 52);
      expect(start.width, skip.width);
      expect(start.width, 390 - 40);
      expect(start.top, lessThan(skip.top));
    });

    testWidgets('the previews are not read by a screen reader', (tester) async {
      await pumpFirstRun(tester);
      expect(find.bySemanticsLabel(RegExp('3/8')), findsNothing);
    });

    testWidgets('wide puts Skip then Start at the right', (tester) async {
      await pumpFirstRun(tester, width: 1440);
      final skip = tester.getRect(find.text('Skip'));
      final start = tester.getRect(find.text('Start'));
      expect(skip.left, lessThan(start.left));
      expect(find.text('Esc'), findsOneWidget);
      expect(find.text('Enter'), findsOneWidget);
    });

    testWidgets('wide draws the Pantas logo and word above the column',
        (tester) async {
      await pumpFirstRun(tester, width: 1440);
      final logo = tester.getRect(find.byType(PantasLogo));
      final word = tester.getRect(find.text('Pantas'));
      final heading = tester.getRect(find.text('Try Pantas first'));
      // Frame W02: the 64 px header row of W01, 28 px logo, then the word.
      expect(logo.size, const Size.square(28));
      expect(logo.center.dy, 32);
      expect(word.left, greaterThan(logo.right));
      expect(word.center.dy, closeTo(32, 2));
      expect(heading.top, greaterThan(64));
    });

    testWidgets('the phone intro has no logo row', (tester) async {
      await pumpFirstRun(tester);
      expect(find.byType(PantasLogo), findsNothing);
    });

    testWidgets('Start opens the lesson', (tester) async {
      await pumpFirstRun(tester);
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      expect(find.text('Answer 3 Questions'), findsOneWidget);
    });
  });

  group('skip', () {
    testWidgets('Skip on the intro goes Home and ends the run', (tester) async {
      final rig = await pumpFirstRun(tester);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(rig.location, '/home');
      expect(await rig.stored(tester), isNull);
    });

    testWidgets('Esc on wide goes Home with no confirm', (tester) async {
      final rig = await pumpFirstRun(tester, width: 1440);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(rig.location, '/home');
      expect(await rig.stored(tester), isNull);
    });
  });

  group('lesson', () {
    Future<FirstRunRig> toLesson(
      WidgetTester tester, {
      double width = 390,
    }) async {
      final rig = await pumpFirstRun(
        tester,
        width: width,
        progressJson: '{"uid":"u1","examId":"exam_upcat","step":"lesson",'
            '"picks":{},"checked":[]}',
      );
      return rig;
    }

    testWidgets('shows the header, the eyebrow and Example 1 open',
        (tester) async {
      await toLesson(tester);
      expect(find.text('Try Pantas'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('MATHEMATICS · ARITHMETIC'), findsOneWidget);
      expect(find.text('Core Concept'), findsOneWidget);
      expect(find.text('Divide by 125.'), findsOneWidget);
      expect(find.text('Never shown.'), findsNothing);
      expect(find.text('Answer 3 Questions'), findsOneWidget);
      expect(find.text('Next in'), findsNothing);
    });

    testWidgets('the end button is full width 52 on a phone', (tester) async {
      await toLesson(tester);
      await tester.scrollUntilVisible(
        find.text('Answer 3 Questions'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      final r =
          tester.getRect(find.widgetWithText(InkWell, 'Answer 3 Questions'));
      expect(r.height, 52);
    });

    testWidgets('Answer 3 Questions opens question 1', (tester) async {
      await toLesson(tester);
      await tester.ensureVisible(find.text('Answer 3 Questions'));
      await tester.tap(find.text('Answer 3 Questions'));
      await tester.pumpAndSettle();
      expect(
        find.text('What is 3/8 expressed as a percentage?'),
        findsOneWidget,
      );
      expect(find.text('1 of 3'), findsOneWidget);
    });
  });

  group('questions', () {
    const q1 = '{"uid":"u1","examId":"exam_upcat","step":"question1",'
        '"picks":{},"checked":[]}';

    testWidgets('pick, Check, then the explanation', (tester) async {
      final rig = await pumpFirstRun(tester, progressJson: q1);
      expect(find.text('Divide 3 by 8.'), findsNothing);
      await tester.tap(find.text('37.5%'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();
      expect(find.text('Divide 3 by 8.'), findsOneWidget);
      expect(find.byTooltip('Next question'), findsOneWidget);
      expect(await rig.stored(tester), contains('"checked":["q1"]'));
    });

    // Frames P04 and W04. The wide eyebrow is the subject and the topic name
    // up to its "&" ("Arithmetic & Number Sense"), which is exact for the one
    // fixed lesson only.
    testWidgets('the phone question eyebrow is the subject alone',
        (tester) async {
      await pumpFirstRun(tester, progressJson: q1);
      expect(find.text('MATHEMATICS'), findsOneWidget);
      expect(find.text('MATHEMATICS · ARITHMETIC'), findsNothing);
    });

    testWidgets('the wide question eyebrow adds the topic', (tester) async {
      await pumpFirstRun(tester, width: 1440, progressJson: q1);
      expect(find.text('MATHEMATICS · ARITHMETIC'), findsOneWidget);
    });

    testWidgets('Check is off until a choice is picked', (tester) async {
      await pumpFirstRun(tester, progressJson: q1);
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();
      expect(find.text('Divide 3 by 8.'), findsNothing);
    });

    testWidgets('a wrong pick still shows the explanation only',
        (tester) async {
      await pumpFirstRun(tester, progressJson: q1);
      await tester.tap(find.text('3.75%'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();
      expect(find.text('Divide 3 by 8.'), findsOneWidget);
      expect(find.text('Your pick'), findsNothing);
    });

    testWidgets('no flag, report or leave controls', (tester) async {
      await pumpFirstRun(tester, progressJson: q1);
      expect(find.byTooltip('Report'), findsNothing);
      expect(find.byTooltip('Leave session'), findsNothing);
      expect(find.textContaining('Flag'), findsNothing);
    });

    testWidgets('the left arrow is off on question 1', (tester) async {
      await pumpFirstRun(tester, progressJson: q1);
      final arrow = tester.widget<PantasIconButton>(
        find.byWidgetPredicate(
          (w) => w is PantasIconButton && w.tooltip == 'Previous question',
        ),
      );
      expect(arrow.onPressed, isNull);
    });

    testWidgets('looking back shows the earlier question read only',
        (tester) async {
      await pumpFirstRun(
        tester,
        progressJson: '{"uid":"u1","examId":"exam_upcat","step":"question2",'
            '"picks":{"q1":"q1-c1"},"checked":["q1"]}',
      );
      await tester.tap(find.byTooltip('Previous question'));
      await tester.pumpAndSettle();
      expect(find.text('1 of 3'), findsOneWidget);
      expect(find.text('Divide 3 by 8.'), findsOneWidget);
      // Read only: a tap on a choice changes nothing.
      await tester.tap(find.text('3.75%'));
      await tester.pumpAndSettle();
      expect(find.text('Divide 3 by 8.'), findsOneWidget);
    });

    testWidgets('wide shows the count, the track and Next after Check',
        (tester) async {
      await pumpFirstRun(tester, width: 1440, progressJson: q1);
      expect(find.text('1 of 3'), findsOneWidget);
      expect(find.text('Check'), findsOneWidget);
      await tester.tap(find.text('37.5%'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('From the lesson'), findsOneWidget);
      expect(
        find.text('Fractions, Decimals, and Percentages'),
        findsOneWidget,
      );
    });

    testWidgets('wide wrong answer has no From the lesson link',
        (tester) async {
      await pumpFirstRun(tester, width: 1440, progressJson: q1);
      await tester.tap(find.text('3.75%'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();
      expect(find.text('From the lesson'), findsNothing);
    });
  });

  group('end', () {
    const endTwoOfThree =
        '{"uid":"u1","examId":"exam_upcat","step":"end","picks":'
        '{"q1":"q1-c1","q2":"q2-c1","q3":"q3-c1"},'
        '"checked":["q1","q2","q3"]}';

    testWidgets('shows the score, the line and the mistake', (tester) async {
      await pumpFirstRun(tester, progressJson: endTwoOfThree);
      await tester.pumpAndSettle(const Duration(seconds: 4));
      expect(find.text('You finished the lesson'), findsOneWidget);
      expect(find.text('2'), findsWidgets);
      expect(find.text('/3'), findsOneWidget);
      expect(find.text('correct'), findsOneWidget);
      expect(
        find.text('Take the assessment on Home for your score and study plan.'),
        findsOneWidget,
      );
      expect(find.text('YOUR MISTAKES'), findsOneWidget);
      expect(
        find.text('A wholesaler gives a 15% discount. What fraction is paid?'),
        findsOneWidget,
      );
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('a mistake opens read only and Back returns to the end',
        (tester) async {
      await pumpFirstRun(tester, progressJson: endTwoOfThree);
      await tester.pumpAndSettle(const Duration(seconds: 4));
      await tester.tap(
        find.text('A wholesaler gives a 15% discount. What fraction is paid?'),
      );
      await tester.pumpAndSettle();
      expect(find.text('2 of 3'), findsOneWidget);
      expect(find.text('Pay 85%.'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle(const Duration(seconds: 4));
      expect(find.text('You finished the lesson'), findsOneWidget);
    });

    testWidgets('a clean run shows no mistakes', (tester) async {
      await pumpFirstRun(
        tester,
        progressJson: '{"uid":"u1","examId":"exam_upcat","step":"end",'
            '"picks":{"q1":"q1-c1","q2":"q2-c0","q3":"q3-c1"},'
            '"checked":["q1","q2","q3"]}',
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));
      expect(find.text('YOUR MISTAKES'), findsNothing);
    });

    testWidgets('Done goes Home and ends the run', (tester) async {
      final rig = await pumpFirstRun(tester, progressJson: endTwoOfThree);
      await tester.pumpAndSettle(const Duration(seconds: 4));
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(rig.location, '/home');
      expect(await rig.stored(tester), isNull);
    });

    testWidgets('Reduce Motion shows the final state at once', (tester) async {
      await pumpFirstRun(tester, progressJson: endTwoOfThree);
      // No settle past the first frames: everything is already there.
      expect(find.text('2'), findsWidgets);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('YOUR MISTAKES'), findsOneWidget);
    });
  });

  group('resume and back', () {
    testWidgets('reopening resumes the same step with its answers',
        (tester) async {
      await pumpFirstRun(
        tester,
        progressJson: '{"uid":"u1","examId":"exam_upcat","step":"question2",'
            '"picks":{"q1":"q1-c1","q2":"q2-c1"},"checked":["q1"]}',
      );
      expect(find.text('2 of 3'), findsOneWidget);
      expect(find.text('Check'), findsOneWidget);
    });

    testWidgets('Back on question 1 returns to the lesson', (tester) async {
      await pumpFirstRun(
        tester,
        progressJson: '{"uid":"u1","examId":"exam_upcat","step":"question1",'
            '"picks":{},"checked":[]}',
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Answer 3 Questions'), findsOneWidget);
    });

    testWidgets('with no open run the page goes Home', (tester) async {
      final rig = await pumpFirstRun(tester, open: false);
      expect(rig.location, '/home');
    });

    test('the step order matches the board', () {
      expect(FirstRunStep.values.map((s) => s.name), [
        'intro',
        'lesson',
        'question1',
        'question2',
        'question3',
        'end',
      ]);
    });
  });
}

void errorAndPlacementTests() {
  group('errors', () {
    testWidgets('a lesson that will not load shows the connection state',
        (tester) async {
      await pumpFirstRun(
        tester,
        progressJson: '{"uid":"u1","examId":"exam_upcat","step":"lesson",'
            '"picks":{},"checked":[]}',
        extra: [
          firstRunDataProvider.overrideWith(
            (ref, examId) async => throw StateError('offline'),
          ),
        ],
      );
      expect(find.text('This needs a connection.'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('the daily limit shows its own message', (tester) async {
      await pumpFirstRun(
        tester,
        progressJson: '{"uid":"u1","examId":"exam_upcat","step":"lesson",'
            '"picks":{},"checked":[]}',
        extra: [
          contentLimitReachedProvider.overrideWith((ref) => true),
          firstRunDataProvider.overrideWith(
            (ref, examId) async => throw StateError('limit'),
          ),
        ],
      );
      expect(find.text(contentLimitMessage), findsOneWidget);
    });

    testWidgets('Skip works from the error state', (tester) async {
      final rig = await pumpFirstRun(
        tester,
        progressJson: '{"uid":"u1","examId":"exam_upcat","step":"lesson",'
            '"picks":{},"checked":[]}',
        extra: [
          firstRunDataProvider.overrideWith(
            (ref, examId) async => throw StateError('offline'),
          ),
        ],
      );
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(rig.location, '/home');
    });
  });

  group('wide placement', () {
    testWidgets('intro', (tester) async {
      await pumpFirstRun(tester, width: 1440);
      expectWidePlacement(tester);
    });

    testWidgets('end', (tester) async {
      await pumpFirstRun(
        tester,
        width: 1440,
        progressJson: '{"uid":"u1","examId":"exam_upcat","step":"end",'
            '"picks":{"q1":"q1-c1","q2":"q2-c1","q3":"q3-c1"},'
            '"checked":["q1","q2","q3"]}',
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));
      expectWidePlacement(tester);
    });
  });
}

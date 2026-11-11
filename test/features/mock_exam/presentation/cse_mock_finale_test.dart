import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_page.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/cse_mock_finale.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_finale.dart';

import '../../../helpers/pump_app.dart';

MockFinaleInput input() => MockFinaleInput(
      reason: MockSubmitReason.timeUp,
      currentPartIndex: 0,
      currentQuestionIndex: 154,
      parts: [
        MockFinalePart(
          name: 'CSE',
          questions: [
            for (var i = 0; i < 155; i++)
              MockFinaleQuestion(
                id: 'q$i',
                outcome: i < 106
                    ? MockFinaleOutcome.correct
                    : MockFinaleOutcome.blank,
              ),
          ],
        ),
      ],
    );

Widget finale(MockFinaleInput paper, {bool still = false}) => MediaQuery(
      data: MediaQueryData(disableAnimations: still),
      child: CseMockFinale(
        input: paper,
        blueprintName: 'CSE Professional simulation',
        resultsBuilder: (context, clock) => AnimatedBuilder(
          animation: clock,
          builder: (context, _) => Text('Results clock ${clock.value.round()}'),
        ),
      ),
    );

void main() {
  testWidgets('fresh CSE paints the real booklet then finishes once',
      (tester) async {
    final paper = input();
    await tester.pumpApp(finale(paper));
    expect(find.byKey(const ValueKey('cse-finale-scene')), findsOneWidget);
    expect(find.text('Results clock 0'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Results clock 4000'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
    expect(find.byKey(const ValueKey('cse-finale-scene')), findsNothing);
    expect(find.text('Results clock 9650'), findsOneWidget);
    await tester.pumpApp(finale(paper));
    expect(find.text('Results clock 9650'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('reduced motion goes straight to final results', (tester) async {
    await tester.pumpApp(finale(input(), still: true));
    expect(find.byKey(const ValueKey('cse-finale-scene')), findsNothing);
    expect(find.text('Results clock 9650'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('enabling reduced motion mid-flight finishes without replay',
      (tester) async {
    final paper = input();
    await tester.pumpApp(finale(paper));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpApp(finale(paper, still: true));
    expect(find.text('Results clock 9650'), findsOneWidget);
    await tester.pumpApp(finale(paper));
    expect(find.text('Results clock 9650'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.binding.transientCallbackCount, 0);
  });
  testWidgets('the original reveal clock controls results and usable Done',
      (tester) async {
    final paper = input();
    const results = MockResults(
      scoreRaw: 106,
      scoreTotal: 155,
      percent: 106 / 155 * 100,
      sections: [
        SectionResult(
          sectionId: 'cse',
          name: 'CSE',
          correct: 106,
          total: 155,
          wrong: 0,
          blank: 49,
          retiredCount: 0,
          timeSeconds: 100,
        ),
      ],
      topWeak: [],
      totalTimeSeconds: 100,
      wasStrict: false,
    );
    var done = 0;
    await tester.pumpApp(
      CseMockFinale(
        input: paper,
        blueprintName: 'CSE Professional simulation',
        dateFormatted: 'Wednesday, October 21',
        resultsBuilder: (context, clock) => MockResultsPage(
          results: results,
          proIsActive: false,
          blueprintName: 'CSE Professional simulation',
          dateFormatted: 'Wednesday, October 21',
          finaleClock: clock,
          onDone: () => done++,
        ),
      ),
    );
    expect(find.text('Done').hitTestable(), findsNothing);
    await tester.pump(const Duration(milliseconds: 6100));
    expect(find.text('Done').hitTestable(), findsNothing);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Done').hitTestable(), findsOneWidget);
    await tester.tap(find.text('Done'));
    expect(done, 1);
    await tester.pumpAndSettle();
    expect(find.text('68.4'), findsOneWidget);
  });
  testWidgets('phone widths, dark mode and large text render every phase',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final width in [320.0, 390.0, 430.0]) {
      for (final dark in [false, true]) {
        for (final scale in [1.0, 2.0]) {
          tester.view.physicalSize = Size(width, 844);
          const results = MockResults(
            scoreRaw: 106,
            scoreTotal: 155,
            percent: 106 / 155 * 100,
            sections: [
              SectionResult(
                sectionId: 'cse',
                name: 'CSE Professional',
                correct: 106,
                total: 155,
                wrong: 0,
                blank: 49,
                retiredCount: 0,
                timeSeconds: 100,
              ),
            ],
            topWeak: [],
            totalTimeSeconds: 100,
            wasStrict: false,
          );
          await tester.pumpWidget(
            MaterialApp(
              theme: dark ? buildDarkTheme() : buildLightTheme(),
              home: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 844),
                  textScaler: TextScaler.linear(scale),
                ),
                child: CseMockFinale(
                  key: ValueKey('$width-$dark-$scale'),
                  input: input(),
                  blueprintName: 'CSE Professional simulation',
                  dateFormatted: 'Wednesday, October 21',
                  resultsBuilder: (context, clock) => MockResultsPage(
                    results: results,
                    proIsActive: false,
                    blueprintName: 'CSE Professional simulation',
                    dateFormatted: 'Wednesday, October 21',
                    finaleClock: clock,
                    onDone: () {},
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          var previous = 0;
          for (final at in [0, 1500, 2800, 3700, 4600, 5900, 6500, 9650]) {
            await tester.pump(Duration(milliseconds: at - previous));
            previous = at;
            expect(
              tester.takeException(),
              isNull,
              reason: '$width/$dark/$scale at $at',
            );
          }
        }
      }
    }
    await tester.pumpWidget(const SizedBox());
  });
}

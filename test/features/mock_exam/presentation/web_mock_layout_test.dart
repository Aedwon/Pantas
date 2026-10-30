import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/components/review_list.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_debrief_loading.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';
import 'package:pantas/features/mock_exam/presentation/mock_hourglass.dart';

const blueprint = ParsedMockBlueprint(
  blueprint: MockBlueprint(
    id: 'cse',
    examId: 'exam_cse_pro',
    name: 'CSE Professional Practice Paper',
    durationMinutes: 90,
    sectionsJson: '[]',
    sectionalTiming: SectionalTiming.roamable,
    totalPublishedItems: 10,
  ),
  sections: [
    BlueprintSection(
      id: 's',
      name: 'General Information',
      questionCount: 10,
      suggestedMinutes: 12,
      topicIds: ['t'],
      topicWeights: {'t': 1},
    ),
  ],
);
const result = MockResults(
  scoreRaw: 7,
  scoreTotal: 10,
  percent: 70,
  sections: [
    SectionResult(
      sectionId: 's',
      name: 'General Information',
      correct: 7,
      total: 10,
      retiredCount: 0,
      timeSeconds: 60,
    ),
  ],
  topWeak: [],
  totalTimeSeconds: 60,
  wasStrict: false,
);

Future<void> pumpWide(
  WidgetTester tester,
  Widget child, {
  required bool dark,
}) async {
  debugWebPlatformOverride = true;
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: child,
    ),
  );
  await tester.pump();
}

const question = Question(
  id: 'q',
  version: 1,
  examIds: [],
  language: 'en',
  topicId: 't',
  stem: 'Which answer is correct?',
  choices: [
    Choice(id: 'a', label: 'A', text: 'First answer', isCorrect: true),
    Choice(id: 'b', label: 'B', text: 'Second answer', isCorrect: false),
  ],
  explanation: 'The first answer is correct.',
);

void main() {
  tearDown(() {
    debugWebPlatformOverride = null;
  });
  for (final dark in [false, true]) {
    testWidgets('wide loading shapes wait and strict setup can change ($dark)',
        (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pumpWide(
        tester,
        const Scaffold(body: WebDebriefLoading()),
        dark: dark,
      );
      expect(find.byType(SkeletonPulse), findsOneWidget);
      expect(
        find.byKey(const ValueKey('loading-shapes-opacity')),
        findsNothing,
      );
      await tester.pump(const Duration(milliseconds: 301));
      expect(
        find.byKey(const ValueKey('loading-shapes-opacity')),
        findsOneWidget,
      );
      bool? strict;
      await pumpWide(
        tester,
        MockSetupPage(
          parsedBlueprint: blueprint,
          initialStrictMode: true,
          onStart: (value) => strict = value,
        ),
        dark: dark,
      );
      expect(find.textContaining('No pausing'), findsOneWidget);
      await tester.tap(find.byType(PantasSwitch));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(strict, false);
    });
    testWidgets('wide wrong and correct review, Pro and Free ($dark)',
        (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final pro in [true, false]) {
        await pumpWide(
          tester,
          ProviderScope(
            key: ValueKey(pro),
            overrides: [
              mockReviewProvider.overrideWith(
                (ref, id) async => const [
                  ReviewEntry(
                    number: 1,
                    question: question,
                    isFlagged: false,
                    subjectName: 'Numerical Ability',
                    label: 'A wrong question',
                    labelIsStem: false,
                    chosenChoiceId: 'b',
                  ),
                ],
              ),
              mockMarkedQuestionIdsProvider
                  .overrideWith((ref, id) async => <String>{}),
              mockOfferHandledProvider.overrideWith((ref, id) async => true),
              mockSavedFlagIdsProvider.overrideWith((ref) async => <String>{}),
              mockReviewAnswersProvider
                  .overrideWith((ref, id) async => <String, MockAnswer>{}),
            ],
            child: MockReviewPage(attemptId: 'a', proIsActive: pro),
          ),
          dark: dark,
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Finish the Notes'),
          pro ? findsOneWidget : findsNothing,
        );
        await tester.tap(find.text('All 1'));
        await tester.pump();
        await tester.tap(find.text('A wrong question'));
        await tester.pumpAndSettle();
        expect(find.text('correct answer'), findsOneWidget);
        expect(
          tester.widget<WebBottomBar>(find.byType(WebBottomBar)).state,
          WebBarState.wrong,
        );
        if (pro) {
          await tester.tap(find.text('Not Now'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Add note'));
          await tester.pumpAndSettle();
          expect(find.text('Why did you miss it?'), findsOneWidget);
        }
        expect(
          find.text('Why did you miss it?'),
          pro ? findsOneWidget : findsNothing,
        );
        expect(
          find.text('I forgot'),
          pro ? findsOneWidget : findsNothing,
        );
        expect(tester.takeException(), isNull);
      }
    });
    testWidgets('wide result access, first result, record and forfeit ($dark)',
        (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final locked in [false, true]) {
        await pumpWide(
          tester,
          MockResultsPage(
            results: result,
            proIsActive: false,
            canReview: !locked,
            fromRecord: true,
            reviewUntil: DateTime(2026, 11),
            onDone: () {},
            onSeePro: () {},
          ),
          dark: dark,
        );
        expect(find.text('Your record'), findsOneWidget);
        expect(find.text('VERSUS PAST RESULTS'), findsNothing);
        expect(
          find.text('See all questions'),
          locked ? findsNothing : findsOneWidget,
        );
        expect(find.text('See Pro'), locked ? findsOneWidget : findsNothing);
        expect(find.text('General Information'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      await pumpWide(
        tester,
        const MockResultsPage(
          results: result,
          proIsActive: true,
          forfeited: true,
          forfeitedPart: 1,
          pastResults: [MockPastPoint(percent: 60, label: 'Oct 1')],
        ),
        dark: dark,
      );
      expect(find.text('Not finished'), findsOneWidget);
      expect(find.textContaining('Everything you answered'), findsOneWidget);
      expect(find.text('VERSUS PAST RESULTS'), findsNothing);
    });
    testWidgets('wide strict last question and clock warning ($dark)',
        (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Widget paper(Duration remaining) => ProviderScope(
            overrides: [
              hydratedMockQuestionProvider.overrideWith(
                (ref, id) async => const HydratedMockQuestion(question, null),
              ),
            ],
            child: MockSessionPage(
              state: const MockSessionInProgress(
                attemptId: 'a',
                durationSeconds: 5400,
                questionIds: ['q'],
                currentIndex: 0,
                elapsedSeconds: 0,
                answers: {},
                flags: {},
                strictMode: true,
              ),
              remainingInPart: remaining,
              partPosition: 1,
              partTotal: 1,
              canGoPrevious: false,
              canGoNext: false,
              onPrevious: () {},
              onNext: () {},
              onAnswer: (_) {},
              onToggleFlag: () {},
              onPause: () {},
              partName: 'Numerical Ability',
            ),
          );
      await pumpWide(tester, paper(const Duration(minutes: 11)), dark: dark);
      await tester.pumpAndSettle();
      expect(find.text('Pause'), findsNothing);
      expect(find.textContaining('Strict mode is on.'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is IconButton && widget.tooltip == 'End part',
              ),
            )
            .onPressed,
        isNull,
      );
      await pumpWide(tester, paper(const Duration(minutes: 10)), dark: dark);
      await tester.pump();
      expect(find.text('10 minutes left in this subject.'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 2501));
      expect(find.text('10 minutes left in this subject.'), findsNothing);
      expect(find.text('left in Part 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('wide paper panel, flag, keyboard and submit ($dark)',
        (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var flagged = 0;
      var next = 0;
      int? picked;
      await pumpWide(
        tester,
        ProviderScope(
          overrides: [
            hydratedMockQuestionProvider.overrideWith(
              (ref, id) async => const HydratedMockQuestion(question, null),
            ),
          ],
          child: MockSessionPage(
            state: const MockSessionInProgress(
              attemptId: 'a',
              durationSeconds: 5400,
              questionIds: ['q', 'q2'],
              currentIndex: 0,
              elapsedSeconds: 0,
              answers: {},
              flags: {},
              strictMode: false,
            ),
            remainingInPart: const Duration(minutes: 30),
            partPosition: 1,
            partTotal: 2,
            oneBlock: true,
            canGoPrevious: false,
            canGoNext: true,
            onPrevious: () {},
            onNext: () => next++,
            onAnswer: (value) => picked = value,
            onToggleFlag: () => flagged++,
            onPause: () {},
            onSubmitExam: () {},
          ),
        ),
        dark: dark,
      );
      await tester.pumpAndSettle();
      expect(find.text('WHOLE PAPER'), findsOneWidget);
      expect(find.text('Which answer is correct?'), findsOneWidget);
      await tester.tap(find.text('First answer'));
      expect(picked, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      expect(flagged, 1);
      expect(next, 1);
      await tester.tap(find.byTooltip('Hide the question list'));
      await tester.pump();
      expect(find.byKey(const ValueKey('web-mock-panel')), findsNothing);
      await tester.tap(find.byTooltip('Show the question list'));
      await tester.pump();
      expect(find.byKey(const ValueKey('web-mock-panel')), findsOneWidget);
      expect(
        tester
            .widget<WebButton>(
              find.widgetWithText(WebButton, 'Submit the Exam'),
            )
            .variant,
        WebButtonVariant.primary,
      );
      await tester.tap(find.text('Submit the Exam'));
      await tester.pumpAndSettle();
      expect(find.text('Submit the exam?'), findsOneWidget);
      expect(find.textContaining('2 questions blank'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('wide review filters, viewer, blank notes and Free ($dark)',
        (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pumpWide(
        tester,
        ProviderScope(
          overrides: [
            mockReviewProvider.overrideWith(
              (ref, id) async => const [
                ReviewEntry(
                  number: 1,
                  question: question,
                  isFlagged: true,
                  subjectName: 'General Information',
                  label: 'A blank question',
                  labelIsStem: false,
                ),
              ],
            ),
            mockMarkedQuestionIdsProvider
                .overrideWith((ref, id) async => {'q'}),
            mockOfferHandledProvider.overrideWith((ref, id) async => false),
            mockSavedFlagIdsProvider.overrideWith((ref) async => <String>{}),
            mockReviewAnswersProvider
                .overrideWith((ref, id) async => <String, MockAnswer>{}),
          ],
          child: const MockReviewPage(attemptId: 'a', proIsActive: true),
        ),
        dark: dark,
      );
      await tester.pumpAndSettle();
      expect(find.text('Finish the Notes'), findsOneWidget);
      expect(find.text('Left blank'), findsOneWidget);
      expect(tester.getSize(find.byType(WebSegmentedControl)).width, 460);
      expect(tester.getSize(find.byType(WebRow)).width, dark ? 758 : 760);
      await tester.tap(find.text('Flagged 1'));
      await tester.pump();
      expect(find.text('Save All 1'), findsOneWidget);
      final badge = tester.widget<Container>(
        find
            .ancestor(of: find.text('1'), matching: find.byType(Container))
            .first,
      );
      expect((badge.decoration! as BoxDecoration).shape, BoxShape.circle);
      expect(
        (badge.decoration! as BoxDecoration).color,
        dark ? const Color(0xFF33201F) : const Color(0xFFFDE8EA),
      );
      await tester.tap(find.text('A blank question'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('web-answer-column')), findsOneWidget);
      expect(find.text('Why did you leave it blank?'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'I skipped question 1234');
      await tester.pump();
      expect(find.text('Add Note'), findsOneWidget);
      await tester.tap(find.text('Not Now'));
      await tester.pump();
      expect(find.text('Why did you leave it blank?'), findsNothing);
      await tester.tap(find.byTooltip('Add note'));
      await tester.pumpAndSettle();
      expect(find.text('Why did you leave it blank?'), findsOneWidget);
      expect(
        tester.widget<WebBottomBar>(find.byType(WebBottomBar)).state,
        WebBarState.wrong,
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('All questions'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('wide between-part end state and Enter ($dark)',
        (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var started = false;
      await pumpWide(
        tester,
        PartTransitionPage(
          partNames: const ['Numerical Ability', 'General Information'],
          nextPartIndex: 1,
          answeredQuestions: const [true, false],
          endedEarly: true,
          onStartNext: () => started = true,
        ),
        dark: dark,
      );
      expect(find.text('Part 1 ended.'), findsOneWidget);
      expect(find.text('1 answered · 1 blank'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(started, true);
      expect(tester.takeException(), isNull);
    });
    testWidgets('wide setup has two columns, strict switch and Enter ($dark)',
        (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      bool? strict;
      await pumpWide(
        tester,
        MockSetupPage(
          parsedBlueprint: blueprint,
          onStart: (value) => strict = value,
        ),
        dark: dark,
      );
      expect(find.byKey(const ValueKey('web-mock-setup')), findsOneWidget);
      expect(find.text('CSE Professional simulation'), findsOneWidget);
      expect(find.text('The clock starts when you click.'), findsOneWidget);
      expect(find.byType(WebButton), findsWidgets);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(strict, false);
    });
    testWidgets(
        'wide results keep review in score card and Done at title ($dark)',
        (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pumpWide(
        tester,
        MockResultsPage(
          results: result,
          proIsActive: true,
          blueprintName: 'CSE Professional simulation',
          onDone: () {},
          onReviewTap: () {},
          pastResults: const [MockPastPoint(percent: 60, label: 'Oct 1')],
        ),
        dark: dark,
      );
      expect(find.byKey(const ValueKey('web-mock-score')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('web-mock-score')),
          matching: find.text('See all questions'),
        ),
        findsOneWidget,
      );
      expect(
        tester.getBottomLeft(find.text('Done')).dy,
        lessThan(
          tester.getTopLeft(find.byKey(const ValueKey('web-mock-score'))).dy,
        ),
      );
      expect(find.text('VERSUS PAST RESULTS'), findsOneWidget);
      final ringSide = find
          .ancestor(
            of: find.byType(HalfRingGauge),
            matching: find.byType(Expanded),
          )
          .first;
      final breakdownSide = find
          .ancestor(
            of: find.text('General Information'),
            matching: find.byWidgetPredicate(
              (widget) => widget is Expanded && widget.flex == 13,
            ),
          )
          .first;
      expect(
        tester.getCenter(ringSide).dy,
        closeTo(tester.getCenter(breakdownSide).dy, .01),
      );
      expect(tester.takeException(), isNull);
    });
    testWidgets('wide pause is static and resumes with Enter ($dark)',
        (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var resumed = false;
      await pumpWide(
        tester,
        PausePage(
          partNames: const ['Language', 'Math'],
          currentPartIndex: 0,
          remaining: const Duration(minutes: 21),
          partLength: const Duration(minutes: 90),
          answeredCount: 7,
          onResume: () => resumed = true,
          onDiscard: () {},
        ),
        dark: dark,
      );
      expect(find.byKey(const ValueKey('web-mock-paused')), findsOneWidget);
      expect(find.text('Paused'), findsOneWidget);
      final glass = tester.widget<MockHourglass>(find.byType(MockHourglass));
      expect(
        glass.outlineColor,
        dark ? const Color(0xFFF5F5F5) : const Color(0xFF1D1D1F),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('pause-hourglass'))),
        const Size(152, 200),
      );
      expect(
        tester.getTopLeft(find.text('Part 1 · Language')).dx,
        greaterThan(tester.getTopRight(find.text('Paused')).dx),
      );
      await tester.tap(find.text('Discard This Mock'));
      await tester.pumpAndSettle();
      expect(find.text('Discard this mock?'), findsOneWidget);
      final discard =
          tester.widget<WebButton>(find.widgetWithText(WebButton, 'Discard'));
      expect(discard.variant, WebButtonVariant.danger);
      await tester.tap(find.text('Keep It'));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(resumed, true);
    });
  }
}

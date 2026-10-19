import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/domain/custom_blueprint.dart';
import 'package:pantas/features/mock_exam/presentation/pages/custom_mock_setup_page.dart';

void main() {
  const subjects = [
    Subject(
      id: 'math',
      examId: 'exam_custom_1',
      name: 'Mathematics',
      ordering: 0,
    ),
    Subject(
      id: 'sci',
      examId: 'exam_custom_1',
      name: 'Science',
      ordering: 1,
    ),
  ];

  late List<CustomBlueprint> saved;
  late int ticked;

  setUp(() {
    saved = [];
    ticked = 0;
  });

  Widget harness({
    int available = 240,
    CustomBlueprint? initial,
    double textScale = 1,
    bool dark = false,
  }) =>
      MaterialApp(
        theme: dark ? buildDarkTheme() : buildLightTheme(),
        home: MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: true,
          ),
          child: CustomMockSetupPage(
            data: CustomMockSetupData(
              examId: 'exam_custom_1',
              subjects: subjects,
              topicsBySubject: const {},
              availableQuestions: available,
              saved: initial,
            ),
            onSave: (blueprint) async => saved.add(blueprint),
            onTickMoreSubjects: () => ticked++,
          ),
        ),
      );

  PantasButton saveButton(WidgetTester tester) =>
      tester.widget<PantasButton>(find.byType(PantasButton));

  testWidgets('it opens at CM_Setup', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();

    expect(find.text('Set up your mock'), findsOneWidget);
    expect(find.text("We'll build it from what you tell us."), findsOneWidget);
    expect(find.text('Questions'), findsOneWidget);
    expect(find.text('120'), findsOneWidget);
    expect(find.text('Time'), findsOneWidget);
    expect(find.text('2h 00m'), findsOneWidget);
    expect(find.text('I know the section breakdown'), findsOneWidget);
    expect(
      find.text("You'll be timed, so exam day feels familiar."),
      findsOneWidget,
    );
    expect(find.text('Quiz'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNotNull);
    expect(find.byType(ValueWheel), findsNothing);
  });

  testWidgets('Questions and Time open their wheel in place, never a sheet',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('custom-questions')));
    await tester.pump();
    expect(find.byType(ValueWheel), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    // CM_Wheel: five rows around the chosen value.
    for (final value in ['110', '115', '125', '130']) {
      expect(find.text(value, skipOffstage: false), findsOneWidget);
    }

    await tester.tap(find.byKey(const ValueKey('custom-time')));
    await tester.pump();
    expect(find.byType(ValueWheel), findsOneWidget);
    expect(find.text('1h 55m', skipOffstage: false), findsOneWidget);
  });

  testWidgets('turning the wheel changes the value', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('custom-questions')));
    await tester.pump();

    tester.widget<ValueWheel>(find.byType(ValueWheel)).onSelected(
          customQuestionValues.indexOf(130),
        );
    await tester.pump();
    expect(find.text('130', skipOffstage: false), findsWidgets);

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(saved.single.totalQuestions, 130);
  });

  testWidgets('reopening shows the saved values, not the defaults',
      (tester) async {
    await tester.pumpWidget(
      harness(
        initial: const CustomBlueprint(
          examId: 'exam_custom_1',
          totalQuestions: 90,
          totalMinutes: 135,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('90'), findsOneWidget);
    expect(find.text('2h 15m'), findsOneWidget);
    expect(find.text('120'), findsNothing);
  });

  testWidgets('reopening keeps a saved breakdown and its timing switch',
      (tester) async {
    await tester.pumpWidget(
      harness(
        initial: const CustomBlueprint(
          examId: 'exam_custom_1',
          totalQuestions: 80,
          totalMinutes: 80,
          sectionsTimedSeparately: true,
          sections: [
            CustomBlueprintSectionDraft(
              subjectId: 'math',
              name: 'Mathematics',
              questions: 40,
              minutes: 50,
            ),
            CustomBlueprintSectionDraft(
              subjectId: 'sci',
              name: 'Science',
              questions: 40,
              minutes: 40,
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    expect(find.text('SECTION BREAKDOWN'), findsOneWidget);
    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('50'), findsOneWidget);
    // The totals add the parts: 80 questions and 90 minutes.
    expect(find.text('80'), findsOneWidget);
    expect(find.text('1h 30m'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(saved.single.sectionsTimedSeparately, isTrue);
    expect(saved.single.sections, hasLength(2));
  });

  testWidgets('CM_Breakdown: one row per subject and the totals add up',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();
    await tester.tap(find.text('I know the section breakdown'));
    await tester.pump();

    expect(find.text('SECTION BREAKDOWN'), findsOneWidget);
    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('Science'), findsOneWidget);
    expect(find.text('items'), findsNWidgets(2));
    expect(find.text('min'), findsNWidgets(2));
    expect(find.text('Time each section separately'), findsOneWidget);
    expect(find.text('The totals above now add these up.'), findsOneWidget);
    // The footnote under the toggle goes while the breakdown is open.
    expect(
      find.text("You'll be timed, so exam day feels familiar."),
      findsNothing,
    );
    // The totals stop being editable once parts exist.
    expect(find.byKey(const ValueKey('custom-questions')), findsNothing);
  });

  testWidgets('a subject row opens a wheel in place and sets its value',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();
    await tester.tap(find.text('I know the section breakdown'));
    await tester.pump();

    // Rows start unset and block Save until every subject has both values.
    expect(saveButton(tester).onPressed, isNull);

    Future<void> setValue(String key, int value, List<int> values) async {
      await tester.ensureVisible(find.byKey(ValueKey(key)));
      await tester.pump();
      await tester.tap(find.byKey(ValueKey(key)));
      await tester.pump();
      tester.widget<ValueWheel>(find.byType(ValueWheel)).onSelected(
            values.indexOf(value),
          );
      await tester.pump();
    }

    await setValue('custom-items-math', 40, customQuestionValues);
    await setValue('custom-minutes-math', 50, customMinuteValues);
    expect(saveButton(tester).onPressed, isNull);
    await setValue('custom-items-sci', 40, customQuestionValues);
    await setValue('custom-minutes-sci', 40, customMinuteValues);
    expect(saveButton(tester).onPressed, isNotNull);

    expect(find.text('80'), findsOneWidget);
    expect(find.text('1h 30m'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(saved.single.effectiveQuestions, 80);
    expect(saved.single.effectiveMinutes, 90);
  });

  testWidgets('CM_Ceiling: asking for more than the track holds',
      (tester) async {
    await tester.pumpWidget(harness(available: 60));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('custom-questions')));
    await tester.pump();
    tester.widget<ValueWheel>(find.byType(ValueWheel)).onSelected(
          customQuestionValues.indexOf(150),
        );
    await tester.pump();

    final context = tester.element(find.byType(CustomMockSetupPage));
    expect(
      tester
          .widget<Text>(
            find.descendant(
              of: find.byKey(const ValueKey('custom-questions')),
              matching: find.byType(Text),
            ),
          )
          .style!
          .color,
      context.colors.wrongText,
    );
    expect(
      find.text(
        'Your subjects have 60 questions. A 150-question mock needs more.',
      ),
      findsOneWidget,
    );
    expect(saveButton(tester).onPressed, isNull);

    await tester.tap(find.text('Tick More Subjects'));
    await tester.pump();
    expect(ticked, 1);
  });

  testWidgets('the correction action is a named button of at least 44',
      (tester) async {
    await tester.pumpWidget(harness(available: 60));
    await tester.pump();
    final finder = find.bySemanticsLabel('Tick More Subjects');
    expect(tester.getSemantics(finder).flagsCollection.isButton, isTrue);
    expect(tester.getSize(finder).height, greaterThanOrEqualTo(44));
  });

  testWidgets('the copy has no em dashes', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();
    expect(find.textContaining('—'), findsNothing);
  });

  for (final dark in [false, true]) {
    testWidgets('fits a 320 wide screen at 200 percent, dark=$dark',
        (tester) async {
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.physicalSize = const Size(640, 1136);
      await tester.pumpWidget(harness(textScale: 2, dark: dark));
      await tester.pump();
      await tester.tap(find.text('I know the section breakdown'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}

import 'dart:async';

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
    Map<String, int> bySubject = const {'math': 120, 'sci': 120},
    List<Subject> shown = subjects,
    CustomBlueprint? initial,
    double textScale = 1,
    bool dark = false,
    Future<void> Function(CustomBlueprint blueprint)? onSave,
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
              subjects: shown,
              topicsBySubject: const {},
              availableQuestions: available,
              availableBySubject: bySubject,
              saved: initial,
            ),
            onSave: onSave ?? (blueprint) async => saved.add(blueprint),
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
    expect(
      find.text('Choose questions and minutes for every subject.'),
      findsOneWidget,
    );

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
    expect(
      find.text('Choose questions and minutes for every subject.'),
      findsNothing,
    );

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

    await tester.ensureVisible(find.text('Tick More Subjects'));
    await tester.pump();
    await tester.tap(find.text('Tick More Subjects'));
    await tester.pump();
    expect(ticked, 1);
  });

  CustomBlueprint paper(int mathItems, int sciItems, {bool timed = false}) =>
      CustomBlueprint(
        examId: 'exam_custom_1',
        totalQuestions: 120,
        totalMinutes: 120,
        sectionsTimedSeparately: timed,
        sections: [
          CustomBlueprintSectionDraft(
            subjectId: 'math',
            name: 'Mathematics',
            questions: mathItems,
            minutes: 60,
          ),
          CustomBlueprintSectionDraft(
            subjectId: 'sci',
            name: 'Science',
            questions: sciItems,
            minutes: 60,
          ),
        ],
      );

  Future<void> setItems(WidgetTester tester, String subject, int value) async {
    final key = find.byKey(ValueKey('custom-items-$subject'));
    await tester.ensureVisible(key);
    await tester.pump();
    await tester.tap(key);
    await tester.pump();
    tester.widget<ValueWheel>(find.byType(ValueWheel)).onSelected(
          customQuestionValues.indexOf(value),
        );
    await tester.pump();
  }

  Color? textColor(WidgetTester tester, Finder finder) => tester
      .widget<Text>(
        find.descendant(of: finder, matching: find.byType(Text)).first,
      )
      .style
      ?.color;

  const sectionLine = 'Your Science topics have 100 questions. '
      'A 150-question section needs more.';

  testWidgets(
      'a section above its subject: the number turns red, a red line sits '
      'under the card, and Save waits', (tester) async {
    await tester.pumpWidget(
      harness(
        bySubject: const {'math': 140, 'sci': 100},
        initial: paper(40, 150),
      ),
    );
    await tester.pump();
    final context = tester.element(find.byType(CustomMockSetupPage));
    final wrong = context.colors.wrongText;

    expect(find.text(sectionLine), findsOneWidget);
    expect(
      textColor(tester, find.byKey(const ValueKey('custom-items-sci'))),
      wrong,
    );
    expect(
      textColor(tester, find.byKey(const ValueKey('custom-items-math'))),
      isNot(wrong),
    );
    // The total is a sum of the parts and stays plain here.
    expect(
      tester.widget<Text>(find.text('190')).style?.color,
      isNot(wrong),
    );
    expect(find.textContaining('Your subjects have'), findsNothing);
    expect(saveButton(tester).onPressed, isNull);

    await tester.ensureVisible(find.text('Tick More Subjects'));
    await tester.tap(find.text('Tick More Subjects'));
    await tester.pump();
    expect(ticked, 1);

    await setItems(tester, 'sci', 100);
    expect(find.text(sectionLine), findsNothing);
    expect(find.text('Tick More Subjects'), findsNothing);
    expect(saveButton(tester).onPressed, isNotNull);
  });

  testWidgets(
      'a total above 300: the number stays red and a red line sits '
      'under the card, with no way to tick more', (tester) async {
    await tester.pumpWidget(
      harness(
        available: 400,
        bySubject: const {'math': 200, 'sci': 200},
        initial: paper(200, 150),
      ),
    );
    await tester.pump();
    final context = tester.element(find.byType(CustomMockSetupPage));

    expect(
      find.text('Mocks go up to 300 questions. This one adds up to 350.'),
      findsOneWidget,
    );
    expect(
      tester.widget<Text>(find.text('350')).style?.color,
      context.colors.wrongText,
    );
    expect(find.text('Tick More Subjects'), findsNothing);
    expect(find.textContaining('section needs more'), findsNothing);
    expect(saveButton(tester).onPressed, isNull);

    await setItems(tester, 'sci', 100);
    expect(find.textContaining('Mocks go up to 300'), findsNothing);
    expect(
      tester.widget<Text>(find.text('300')).style?.color,
      isNot(context.colors.wrongText),
    );
    expect(saveButton(tester).onPressed, isNotNull);
  });

  testWidgets('300 itself is allowed', (tester) async {
    await tester.pumpWidget(
      harness(
        available: 400,
        bySubject: const {'math': 200, 'sci': 200},
        initial: paper(200, 100),
      ),
    );
    await tester.pump();
    expect(find.textContaining('Mocks go up to 300'), findsNothing);
    expect(saveButton(tester).onPressed, isNotNull);
  });

  testWidgets('a subject with no questions cannot hold a section',
      (tester) async {
    await tester.pumpWidget(
      harness(bySubject: const {'math': 120}, initial: paper(40, 40)),
    );
    await tester.pump();
    expect(
      find.text(
        'Your Science topics have 0 questions. '
        'A 40-question section needs more.',
      ),
      findsOneWidget,
    );
    expect(saveButton(tester).onPressed, isNull);
  });

  const rule = 'This paper runs part by part. '
      "Once a part ends, you can't go back to it.";

  testWidgets('timing on adds the part by part line under the breakdown',
      (tester) async {
    await tester.pumpWidget(harness(initial: paper(40, 40, timed: true)));
    await tester.pump();
    expect(find.text(rule), findsOneWidget);
    expect(find.text('The totals above now add these up.'), findsOneWidget);

    await tester.ensureVisible(find.text('Time each section separately'));
    await tester.tap(find.text('Time each section separately'));
    await tester.pump();
    expect(find.text(rule), findsNothing);
  });

  testWidgets('timing off has no part by part line', (tester) async {
    await tester.pumpWidget(harness(initial: paper(40, 40)));
    await tester.pump();
    expect(find.text(rule), findsNothing);
  });

  testWidgets('one subject cannot run part by part, so the line stays away',
      (tester) async {
    await tester.pumpWidget(
      harness(
        shown: [subjects.first],
        initial: CustomBlueprint(
          examId: 'exam_custom_1',
          totalQuestions: 40,
          totalMinutes: 60,
          sectionsTimedSeparately: true,
          sections: [paper(40, 40).sections.first],
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Time each section separately'), findsOneWidget);
    expect(find.text(rule), findsNothing);
  });

  testWidgets('timing without a breakdown is not saved', (tester) async {
    await tester.pumpWidget(harness(initial: paper(40, 40, timed: true)));
    await tester.pump();
    // Closing the breakdown leaves a flag nobody can see.
    await tester.tap(find.text('I know the section breakdown'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(saved.single.sectionsTimedSeparately, isFalse);
    expect(saved.single.sections, isEmpty);
  });

  testWidgets('Save is off while the save runs and the page stays',
      (tester) async {
    final gate = Completer<void>();
    await tester.pumpWidget(harness(onSave: (_) => gate.future));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(saveButton(tester).onPressed, isNull);
    expect(find.text('Could not save. Please try again.'), findsNothing);

    gate.complete();
    await tester.pump();
    expect(saveButton(tester).onPressed, isNotNull);
    expect(find.text('Could not save. Please try again.'), findsNothing);
  });

  testWidgets(
      'a failed save keeps the page, shows the line and reactivates '
      'Save', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      harness(
        onSave: (_) async {
          calls++;
          if (calls == 1) throw StateError('offline');
        },
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Could not save. Please try again.'), findsOneWidget);
    expect(find.text('Set up your mock'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNotNull);

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(calls, 2);
    expect(find.text('Could not save. Please try again.'), findsNothing);
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
      await tester.ensureVisible(find.text('I know the section breakdown'));
      await tester.pump();
      await tester.tap(find.text('I know the section breakdown'));
      await tester.pump();
      expect(find.text('SECTION BREAKDOWN'), findsOneWidget);
      expect(
        find.text('Choose questions and minutes for every subject.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/domain/custom_blueprint.dart';
import 'package:pantas/features/mock_exam/presentation/pages/custom_mock_setup_page.dart';

void main() {
  var ticked = 0;
  setUp(() {
    debugWebPlatformOverride = true;
    ticked = 0;
  });
  tearDown(() => debugWebPlatformOverride = null);
  const subjects = [
    Subject(id: 'math', examId: 'custom', name: 'Mathematics', ordering: 0),
  ];
  const twoSubjects = [
    ...subjects,
    Subject(id: 'sci', examId: 'custom', name: 'Science', ordering: 1),
  ];
  for (final dark in [false, true]) {
    Future<void> pump(
      WidgetTester tester, {
      int available = 240,
      Map<String, int> bySubject = const {'math': 240, 'sci': 240},
      List<Subject> shown = subjects,
      CustomBlueprint? saved,
      ValueChanged<CustomBlueprint>? onSave,
      Future<void> Function(CustomBlueprint)? save,
      bool reduced = false,
    }) async {
      tester.view
        ..physicalSize = const Size(1440, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
            child: child!,
          ),
          home: CustomMockSetupPage(
            data: CustomMockSetupData(
              examId: 'custom',
              subjects: shown,
              topicsBySubject: const {},
              availableQuestions: available,
              availableBySubject: bySubject,
              saved: saved,
            ),
            onSave: save ?? (value) async => onSave?.call(value),
            onTickMoreSubjects: () => ticked++,
          ),
        ),
      );
    }

    testWidgets(
        'in the compact sidebar range the page ends 44 px above the bottom '
        'dark=$dark', (tester) async {
      await pump(tester);
      tester.view.physicalSize = const Size(1180, 500);
      await tester.pumpAndSettle();
      await tester.tap(find.text('I know the section breakdown').first);
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const ValueKey('web-custom-setup')),
        const Offset(0, -3000),
      );
      await tester.pumpAndSettle();
      final save = find.widgetWithText(WebButton, 'Save');
      // D136: from 1024 the sidebar is the navigation, so no floating bar
      // covers the bottom; the page keeps `layout-main-pad-bottom` (44).
      expect(tester.getBottomLeft(save).dy, lessThanOrEqualTo(500 - 44));
    });
    testWidgets(
        'the breakdown grows in and shrinks away over 300 ms '
        'dark=$dark', (tester) async {
      await pump(tester);
      final save = find.widgetWithText(WebButton, 'Save');
      final closedY = tester.getTopLeft(save).dy;
      await tester.tap(find.text('I know the section breakdown').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final mid = tester.getTopLeft(save).dy;
      expect(mid, greaterThan(closedY));
      await tester.pumpAndSettle();
      final openY = tester.getTopLeft(save).dy;
      expect(openY, greaterThan(mid));
      expect(find.text('SECTION BREAKDOWN'), findsOneWidget);
      await tester.tap(find.text('I know the section breakdown').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final back = tester.getTopLeft(save).dy;
      expect(back, lessThan(openY));
      expect(back, greaterThan(closedY));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(save).dy, closedY);
    });
    testWidgets('reduced motion shows the breakdown at once dark=$dark',
        (tester) async {
      await pump(tester, reduced: true);
      final save = find.widgetWithText(WebButton, 'Save');
      final closedY = tester.getTopLeft(save).dy;
      await tester.tap(find.text('I know the section breakdown').first);
      await tester.pump();
      expect(tester.getTopLeft(save).dy, greaterThan(closedY));
      expect(find.text('SECTION BREAKDOWN'), findsOneWidget);
      final openY = tester.getTopLeft(save).dy;
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.getTopLeft(save).dy, openY);
      // The switch track still fades 150 ms under reduced motion (Switch
      // README, Motion); the breakdown itself does not animate.
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.getTopLeft(save).dy, openY);
      expect(tester.hasRunningAnimations, isFalse);
    });
    testWidgets('CM_Setup and inline CM_Wheel dark=$dark', (tester) async {
      CustomBlueprint? saved;
      await pump(tester, onSave: (value) => saved = value);
      expect(find.byKey(const ValueKey('web-custom-setup')), findsOneWidget);
      expect(
        find.text("We'll build it from what you tell us."),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('web-custom-fields'))).width,
        640,
      );
      expect(
        tester.getSize(find.widgetWithText(WebButton, 'Save')).width,
        lessThan(200),
      );
      await tester.tap(find.text('Questions'));
      await tester.pumpAndSettle();
      expect(find.byType(ValueWheel), findsNothing);
      for (final tooltip in ['Decrease Questions', 'Increase Questions']) {
        expect(tester.getSize(find.byTooltip(tooltip)), const Size(32, 32));
      }
      for (final value in ['110', '115', '125', '130']) {
        expect(find.text(value), findsOneWidget);
      }
      expect(
        find.text('10 to 240, in fives. Arrow keys work too.'),
        findsOneWidget,
      );
      await tester.tap(find.text('130'));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.tap(find.text('Questions'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(saved?.effectiveQuestions, 135);
      expect(tester.takeException(), isNull);
    });
    testWidgets(
        'wide switch rows toggle from the label and the switch once '
        'dark=$dark', (tester) async {
      CustomBlueprint? saved;
      await pump(tester, onSave: (value) => saved = value);
      expect(find.text('SECTION BREAKDOWN'), findsNothing);
      await tester.tap(find.text('I know the section breakdown'));
      await tester.pump();
      expect(find.text('SECTION BREAKDOWN'), findsOneWidget);
      await tester.tap(find.byType(PantasSwitch).first);
      await tester.pump();
      expect(find.text('SECTION BREAKDOWN'), findsNothing);
      await tester.tap(find.byType(PantasSwitch).first);
      await tester.pump();
      expect(find.text('SECTION BREAKDOWN'), findsOneWidget);
      expect(find.byType(PantasSwitch), findsNWidgets(2));
      await tester.tap(find.byType(PantasSwitch).last);
      await tester.pump();
      await tester.tap(find.text('Time each section separately'));
      await tester.pump();
      await tester.tap(find.text('Time each section separately'));
      await tester.pump();
      await tester.tap(find.byType(PantasSwitch).last);
      await tester.pump();
      var timed =
          tester.widget<PantasSwitch>(find.byType(PantasSwitch).last).value;
      // Switch (on), label (off), label (on), switch (off) is four flips.
      expect(timed, isFalse);
      await tester.tap(find.text('Time each section separately'));
      await tester.pump();
      timed = tester.widget<PantasSwitch>(find.byType(PantasSwitch).last).value;
      expect(timed, isTrue);
      expect(saved, isNull);
    });
    testWidgets('CM_Ceiling retains requested count and blocks Save dark=$dark',
        (tester) async {
      await pump(
        tester,
        available: 60,
        saved: const CustomBlueprint(
          examId: 'custom',
          totalQuestions: 150,
          totalMinutes: 120,
        ),
      );
      expect(
        find.text(
          'Your subjects have 60 questions. A 150-question mock needs more.',
        ),
        findsOneWidget,
      );
      expect(find.text('Tick More Subjects'), findsOneWidget);
      expect(
        tester
            .widget<WebButton>(find.widgetWithText(WebButton, 'Save'))
            .onPressed,
        isNull,
      );
    });

    CustomBlueprint paper(
      int mathItems,
      int sciItems, {
      bool timed = false,
    }) =>
        CustomBlueprint(
          examId: 'custom',
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
    WebButton saveButton(WidgetTester tester) =>
        tester.widget<WebButton>(find.widgetWithText(WebButton, 'Save'));
    const sectionLine =
        'Your Science topics have 100 questions. A 150-question section '
        'needs more.';

    testWidgets(
        'a section above its subject: red field, red line under the card, '
        'Tick More Subjects, and Save waits dark=$dark', (tester) async {
      await pump(
        tester,
        shown: twoSubjects,
        bySubject: const {'math': 140, 'sci': 100},
        saved: paper(40, 150),
      );
      final context = tester.element(find.byType(CustomMockSetupPage));
      final wrong = context.colors.wrongText;
      expect(find.text(sectionLine), findsOneWidget);
      // Only the Science items field is bad: red text and a 1.5 px red edge.
      // The edge is drawn over the system button, so it is read from the
      // foreground decoration around the field.
      Border? edge(String value) {
        final box = tester.widget<DecoratedBox>(
          find
              .ancestor(
                of: find.widgetWithText(WebButton, value),
                matching: find.byWidgetPredicate(
                  (w) =>
                      w is DecoratedBox &&
                      w.position == DecorationPosition.foreground,
                ),
              )
              .first,
        );
        return (box.decoration as BoxDecoration).border as Border?;
      }

      final bad = edge('150');
      expect(bad!.top.color, wrong);
      expect(bad.top.width, 1.5);
      expect(edge('40'), isNull);
      expect(find.textContaining('Your subjects have'), findsNothing);
      expect(saveButton(tester).onPressed, isNull);
      // The line sits under the breakdown card, after its note.
      expect(
        tester.getTopLeft(find.text(sectionLine)).dy,
        greaterThan(
          tester.getTopLeft(find.text('The totals above now add these up.')).dy,
        ),
      );

      await tester.tap(find.text('Tick More Subjects'));
      expect(ticked, 1);

      await tester.tap(find.widgetWithText(WebButton, '150'));
      await tester.pumpAndSettle();
      for (var i = 0; i < 10; i++) {
        await tester.tap(find.byTooltip('Decrease Science items'));
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(find.text(sectionLine), findsNothing);
      expect(saveButton(tester).onPressed, isNotNull);
    });
    testWidgets(
        'a total above 300 keeps the number red with a line under the card '
        'dark=$dark', (tester) async {
      await pump(
        tester,
        shown: twoSubjects,
        available: 400,
        bySubject: const {'math': 200, 'sci': 200},
        saved: paper(200, 150),
      );
      final context = tester.element(find.byType(CustomMockSetupPage));
      expect(
        find.text('Mocks go up to 300 questions. This one adds up to 350.'),
        findsOneWidget,
      );
      expect(
        tester.widget<Text>(find.text('350')).style?.color,
        context.colors.wrongText,
      );
      // The breakdown row is not dimmed (the system dims with text color,
      // not opacity), so the red number above reads at full strength.
      expect(find.text('Tick More Subjects'), findsNothing);
      expect(saveButton(tester).onPressed, isNull);
    });
    testWidgets('timing on adds the part by part line dark=$dark',
        (tester) async {
      const rule = 'This paper runs part by part. '
          "Once a part ends, you can't go back to it.";
      await pump(tester, shown: twoSubjects, saved: paper(40, 40, timed: true));
      expect(find.text(rule), findsOneWidget);
      await tester.tap(find.text('Time each section separately'));
      await tester.pumpAndSettle();
      expect(find.text(rule), findsNothing);
    });
    testWidgets('one subject cannot run part by part dark=$dark',
        (tester) async {
      await pump(
        tester,
        saved: CustomBlueprint(
          examId: 'custom',
          totalQuestions: 40,
          totalMinutes: 60,
          sectionsTimedSeparately: true,
          sections: [paper(40, 40).sections.first],
        ),
      );
      expect(find.text('Time each section separately'), findsOneWidget);
      expect(find.textContaining('runs part by part'), findsNothing);
    });
    testWidgets('timing is saved only with a breakdown dark=$dark',
        (tester) async {
      CustomBlueprint? sent;
      await pump(
        tester,
        shown: twoSubjects,
        saved: paper(40, 40, timed: true),
        onSave: (value) => sent = value,
      );
      await tester.tap(find.text('I know the section breakdown'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(sent?.sectionsTimedSeparately, isFalse);
      expect(sent?.sections, isEmpty);
    });
    testWidgets(
        'Save waits while the save runs, then a failure shows its '
        'line and Save works again dark=$dark', (tester) async {
      final gate = Completer<void>();
      var calls = 0;
      await pump(
        tester,
        save: (_) {
          calls++;
          return gate.future;
        },
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(calls, 1);
      expect(saveButton(tester).onPressed, isNull);
      // Enter does nothing while the save is running.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(calls, 1);
      gate.completeError(StateError('offline'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Could not save. Please try again.'), findsOneWidget);
      expect(saveButton(tester).onPressed, isNotNull);
    });
    testWidgets('CM_Breakdown uses real sections and summed totals dark=$dark',
        (tester) async {
      CustomBlueprint? saved;
      await pump(
        tester,
        onSave: (value) => saved = value,
        saved: const CustomBlueprint(
          examId: 'custom',
          totalQuestions: 120,
          totalMinutes: 120,
          sectionsTimedSeparately: true,
          sections: [
            CustomBlueprintSectionDraft(
              subjectId: 'math',
              name: 'Mathematics',
              questions: 40,
              minutes: 50,
            ),
          ],
        ),
      );
      expect(find.text('SECTION BREAKDOWN'), findsOneWidget);
      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('0h 50m'), findsOneWidget);
      expect(find.byType(PantasSwitch), findsNWidgets(2));
      expect(find.text('The totals above now add these up.'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(saved?.effectiveQuestions, 40);
      expect(saved?.effectiveMinutes, 50);
      expect(saved?.sectionsTimedSeparately, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}

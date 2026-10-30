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
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);
  const subjects = [
    Subject(id: 'math', examId: 'custom', name: 'Mathematics', ordering: 0),
  ];
  for (final dark in [false, true]) {
    Future<void> pump(
      WidgetTester tester, {
      int available = 240,
      CustomBlueprint? saved,
      ValueChanged<CustomBlueprint>? onSave,
    }) async {
      tester.view
        ..physicalSize = const Size(1440, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: CustomMockSetupPage(
            data: CustomMockSetupData(
              examId: 'custom',
              subjects: subjects,
              topicsBySubject: const {},
              availableQuestions: available,
              saved: saved,
            ),
            onSave: (value) async => onSave?.call(value),
            onTickMoreSubjects: () {},
          ),
        ),
      );
    }

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
      await tester.pump();
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
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(saved?.effectiveQuestions, 135);
      expect(tester.takeException(), isNull);
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

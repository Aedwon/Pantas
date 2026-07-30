import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/application/mock_blueprint_providers.dart';
import 'package:pantas/features/mock_exam/data/blueprint_section.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_page.dart';

void main() {
  Widget harness({
    required SectionalTiming? timing,
    int? totalPublishedItems,
    List<BlueprintSection>? sections,
  }) {
    final parsed = ParsedMockBlueprint(
      blueprint: MockBlueprint(
        id: 'bp_1',
        examId: 'exam_upcat',
        name: 'Full length',
        durationMinutes: 180,
        sectionsJson: '[]',
        sectionalTiming: timing,
        totalPublishedItems: totalPublishedItems,
      ),
      sections: sections ??
          const [
            BlueprintSection(
              id: 'sec_1',
              name: 'Language Proficiency',
              questionCount: 40,
              suggestedMinutes: 30,
              topicIds: [],
              topicWeights: {},
              sectionalMinutes: 30,
            ),
          ],
    );

    return MaterialApp(
      theme: buildLightTheme(),
      home: MockSetupPage(parsedBlueprint: parsed, onStart: () {}),
    );
  }

  testWidgets('a sectional exam says you cannot go back', (tester) async {
    await tester.pumpWidget(harness(timing: SectionalTiming.sectional));

    expect(
      find.text(
        'This exam runs part by part. Once a part ends you cannot go back.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a roamable exam says you can move around', (tester) async {
    await tester.pumpWidget(harness(timing: SectionalTiming.roamable));

    expect(find.text('You can move around the whole exam.'), findsOneWidget);
  });

  testWidgets('an unknown exam says it does not know', (tester) async {
    await tester.pumpWidget(harness(timing: null));

    expect(find.textContaining('We do not know yet'), findsOneWidget);
    expect(
      find.textContaining('lets you move around the whole thing'),
      findsOneWidget,
    );
  });

  testWidgets('the rule is stated before the start control', (tester) async {
    await tester.pumpWidget(harness(timing: SectionalTiming.sectional));

    final ruleY = tester.getTopLeft(find.textContaining('part by part')).dy;
    final buttonY = tester.getTopLeft(find.byType(BoardButton)).dy;
    expect(ruleY, lessThan(buttonY));
  });

  testWidgets('a part carries its own limit when the exam is sectional',
      (tester) async {
    await tester.pumpWidget(harness(timing: SectionalTiming.sectional));

    expect(find.text('Language Proficiency'), findsOneWidget);
    expect(find.textContaining('30 min'), findsWidgets);
  });

  testWidgets('a roamable exam prints no per-part limit', (tester) async {
    await tester.pumpWidget(harness(timing: SectionalTiming.roamable));

    // The number exists in the blueprint, but it governs nothing here and
    // printing it would imply a rule the exam does not have.
    expect(find.text('30 min'), findsNothing);
  });

  testWidgets('it says what is not included when the exam holds more',
      (tester) async {
    await tester.pumpWidget(
      harness(timing: SectionalTiming.sectional, totalPublishedItems: 60),
    );

    expect(
      find.textContaining('The real exam has 60 items'),
      findsOneWidget,
    );
  });

  testWidgets('it stays quiet when the sections cover the whole exam',
      (tester) async {
    await tester.pumpWidget(
      harness(timing: SectionalTiming.sectional, totalPublishedItems: 40),
    );

    expect(find.textContaining('The real exam has'), findsNothing);
  });

  testWidgets('the copy never says paper or sit', (tester) async {
    for (final timing in [null, ...SectionalTiming.values]) {
      await tester.pumpWidget(harness(timing: timing));

      expect(find.textContaining('paper'), findsNothing);
      expect(find.textContaining('sit '), findsNothing);
      expect(find.textContaining('—'), findsNothing);
    }
  });
}

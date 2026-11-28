import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';

import '../../../helpers/pump_app.dart';

SectionResult _section(String name) => SectionResult(
      sectionId: name,
      name: name,
      correct: 4,
      wrong: 1,
      blank: 0,
      total: 5,
      retiredCount: 0,
      timeSeconds: 60,
    );

const _parts = [
  'Verbal Ability',
  'Analytical Ability',
  'Numerical Ability',
  'General Information',
];

void main() {
  tearDown(() => debugWebPlatformOverride = null);

  Future<void> showResults(
    WidgetTester tester,
    String examId,
    List<String> names, {
    required bool web,
  }) async {
    addTearDown(tester.view.reset);
    tester.view
      ..physicalSize = Size(web ? 1440 : 390, 2400)
      ..devicePixelRatio = 1;
    debugWebPlatformOverride = web;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: web),
        home: MockResultsPage(
          results: MockResults(
            scoreRaw: 4 * names.length,
            scoreTotal: 5 * names.length,
            percent: 80,
            sections: [for (final name in names) _section(name)],
            topWeak: const [],
            totalTimeSeconds: 60,
            wasStrict: false,
          ),
          examId: examId,
          proIsActive: true,
          blueprintName: 'Simulation',
          dateFormatted: 'Saturday, Oct 3',
          onDone: () {},
          onReviewTap: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final web in [false, true]) {
    testWidgets(
        'CSE Professional results list each part with its weight, '
        'web=$web', (tester) async {
      await showResults(tester, 'exam_cse_pro', _parts, web: web);
      expect(find.text('Verbal Ability (30%)'), findsOneWidget);
      expect(find.text('Analytical Ability (35%)'), findsOneWidget);
      expect(find.text('Numerical Ability (30%)'), findsOneWidget);
      expect(find.text('General Information (5%)'), findsOneWidget);
    });

    testWidgets(
        'an unmapped section and other exams show no weight, '
        'web=$web', (tester) async {
      await showResults(
        tester,
        'exam_cse_pro',
        ['Part 1', 'Verbal Ability'],
        web: web,
      );
      expect(find.text('Part 1'), findsOneWidget);
      expect(find.text('Verbal Ability (30%)'), findsOneWidget);
      await showResults(tester, 'exam_cse_sub', _parts, web: web);
      expect(find.text('Verbal Ability'), findsOneWidget);
      expect(find.textContaining('%)'), findsNothing);
      await showResults(tester, 'exam_upcat', _parts, web: web);
      expect(find.text('Verbal Ability'), findsOneWidget);
      expect(find.textContaining('%)'), findsNothing);
    });
  }

  for (final web in [false, true]) {
    testWidgets(
        'mock setup lists the parts with weights for CSE Professional '
        'only, web=$web', (tester) async {
      addTearDown(tester.view.reset);
      tester.view
        ..physicalSize = Size(web ? 1440 : 390, 2400)
        ..devicePixelRatio = 1;
      debugWebPlatformOverride = web;
      Widget setup(String examId) => MockSetupPage(
            parsedBlueprint: ParsedMockBlueprint(
              blueprint: MockBlueprint(
                id: 'bp',
                examId: examId,
                name: 'Paper',
                durationMinutes: 90,
                sectionsJson: '[]',
                sectionalTiming: SectionalTiming.roamable,
                totalPublishedItems: 20,
              ),
              sections: const [
                BlueprintSection(
                  id: 's1',
                  name: 'Analytical Ability',
                  questionCount: 10,
                  suggestedMinutes: 12,
                  topicIds: ['topic'],
                  topicWeights: {'topic': 1},
                ),
                BlueprintSection(
                  id: 's2',
                  name: 'Part 1',
                  questionCount: 10,
                  suggestedMinutes: 12,
                  topicIds: ['topic'],
                  topicWeights: {'topic': 1},
                ),
              ],
            ),
            onStart: (_) {},
          );
      await tester.pumpApp(setup('exam_cse_pro'));
      expect(find.text('Analytical Ability (35%)'), findsOneWidget);
      expect(find.text('Part 1'), findsOneWidget);
      await tester.pumpApp(setup('exam_cse_sub'));
      expect(find.text('Analytical Ability'), findsOneWidget);
      await tester.pumpApp(setup('exam_upcat'));
      expect(find.text('Analytical Ability'), findsOneWidget);
    });
  }
}

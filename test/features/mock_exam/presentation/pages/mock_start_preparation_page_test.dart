import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/application/mock_blueprint_providers.dart';
import 'package:pantas/features/mock_exam/data/blueprint_section.dart';
import 'package:pantas/features/mock_exam/domain/mock_sample.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_start_preparation_page.dart';

void main() {
  const parsed = ParsedMockBlueprint(
    blueprint: MockBlueprint(
      id: 'bp_upcat',
      examId: 'exam_upcat',
      name: 'UPCAT Practice Paper',
      durationMinutes: 230,
      sectionsJson: '[]',
      sectionalTiming: SectionalTiming.sectional,
      totalPublishedItems: 5,
    ),
    sections: [
      BlueprintSection(
        id: 'language',
        name: 'Language Proficiency',
        questionCount: 3,
        suggestedMinutes: 70,
        topicIds: [],
        topicWeights: {},
        sectionalMinutes: 70,
      ),
      BlueprintSection(
        id: 'math',
        name: 'Mathematics',
        questionCount: 2,
        suggestedMinutes: 75,
        topicIds: [],
        topicWeights: {},
        sectionalMinutes: 75,
      ),
    ],
  );

  const sample = MockSample(
    expectedQuestionCount: 5,
    sections: [
      SampledMockSection(
        sectionId: 'language',
        name: 'Language Proficiency',
        questionIds: ['q1', 'q2', 'q3'],
      ),
      SampledMockSection(
        sectionId: 'math',
        name: 'Mathematics',
        questionIds: ['q4', 'q5'],
      ),
    ],
  );

  testWidgets('ready paper lists sampled parts and starts only on explicit tap',
      (tester) async {
    var started = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: MockStartPreparationPage(
          parsedBlueprint: parsed,
          sample: sample,
          onStart: () => started = true,
        ),
      ),
    );

    expect(find.text('Setting out your paper'), findsOneWidget);
    expect(find.text('UPCAT Practice Paper · 5 questions'), findsOneWidget);
    expect(find.text('Language Proficiency'), findsOneWidget);
    expect(find.text('3 questions'), findsOneWidget);
    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('2 questions'), findsOneWidget);
    expect(
      find.text('Your paper is set. The clock starts when you tap.'),
      findsOneWidget,
    );
    expect(find.text('Start the Paper'), findsOneWidget);
    expect(started, isFalse);

    await tester.tap(find.text('Start the Paper'));
    expect(started, isTrue);
  });

  testWidgets('preparation state represents real work without exposing start',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: MockStartPreparationPage(
          parsedBlueprint: parsed,
          onStart: () {},
        ),
      ),
    );

    expect(find.text('Setting out your paper'), findsOneWidget);
    expect(find.byType(FaintBars), findsWidgets);
    expect(find.text('Start the Paper'), findsNothing);
  });

  testWidgets('dark 200 percent reduced-motion state remains usable',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: ThemeMode.dark,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(2),
            disableAnimations: true,
          ),
          child: child!,
        ),
        home: MockStartPreparationPage(
          parsedBlueprint: parsed,
          sample: sample,
          onStart: () {},
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('Start the Paper'), 300);
    expect(find.text('Start the Paper'), findsOneWidget);
  });
}

// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/components/placeholder_figure.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/application/mock_blueprint_providers.dart';
import 'package:pantas/features/mock_exam/data/blueprint_section.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_page.dart';

void main() {
  ParsedMockBlueprint blueprint({
    String examId = 'exam_upcat',
    String name = 'UPCAT Practice Paper',
    SectionalTiming? timing = SectionalTiming.sectional,
    int durationMinutes = 230,
    int? totalPublishedItems = 250,
    int? unscoredItems,
    List<BlueprintSection>? sections,
  }) =>
      ParsedMockBlueprint(
        blueprint: MockBlueprint(
          id: 'bp_1',
          examId: examId,
          name: name,
          durationMinutes: durationMinutes,
          sectionsJson: '[]',
          sectionalTiming: timing,
          totalPublishedItems: totalPublishedItems,
          unscoredItems: unscoredItems,
        ),
        sections: sections ??
            const [
              BlueprintSection(
                id: 'language',
                name: 'Language Proficiency',
                questionCount: 80,
                suggestedMinutes: 70,
                topicIds: [],
                topicWeights: {},
                sectionalMinutes: 70,
              ),
              BlueprintSection(
                id: 'reading',
                name: 'Reading Comprehension',
                questionCount: 50,
                suggestedMinutes: 35,
                topicIds: [],
                topicWeights: {},
                sectionalMinutes: 35,
              ),
              BlueprintSection(
                id: 'math',
                name: 'Mathematics',
                questionCount: 60,
                suggestedMinutes: 75,
                topicIds: [],
                topicWeights: {},
                sectionalMinutes: 75,
              ),
              BlueprintSection(
                id: 'science',
                name: 'Science',
                questionCount: 60,
                suggestedMinutes: 50,
                topicIds: [],
                topicWeights: {},
                sectionalMinutes: 50,
              ),
            ],
      );

  Future<void> pump(
    WidgetTester tester, {
    ParsedMockBlueprint? parsed,
    bool initialStrictMode = false,
    int? actualQuestionCount,
    ThemeMode themeMode = ThemeMode.light,
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: themeMode,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        ),
        home: MockSetupPage(
          parsedBlueprint: parsed ?? blueprint(),
          initialStrictMode: initialStrictMode,
          actualQuestionCount: actualQuestionCount,
          onStart: (_) {},
        ),
      ),
    );
  }

  testWidgets('says how many personal-information items the mock leaves out',
      (tester) async {
    const line = 'The real exam also has 15 personal-information items. '
        'They are not scored, so this mock leaves them out.';
    await pump(tester, parsed: blueprint(unscoredItems: 15));
    expect(find.text(line), findsOneWidget);

    await pump(tester, parsed: blueprint());
    expect(find.textContaining('personal-information'), findsNothing);
  });

  testWidgets('draws setup table, total row, rules, switch and start contract',
      (tester) async {
    bool? startedStrict;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: MockSetupPage(
          parsedBlueprint: blueprint(),
          onStart: (strict) => startedStrict = strict,
        ),
      ),
    );

    expect(find.text('UPCAT simulation'), findsOneWidget);
    expect(find.text('250 total items · 3 hr 50 min'), findsOneWidget);
    expect(find.text('SECTION'), findsOneWidget);
    expect(find.text('ITEMS'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('250'), findsWidgets);
    expect(
      find.text(
        "This paper runs part by part. Once a part ends, you can't go back to it.",
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Closest to the real exam. Turn it on when you can take the whole mock without interruptions.',
      ),
      findsOneWidget,
    );
    expect(find.byType(PantasSwitch), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Start the Mock Exam'), 300);
    expect(find.text('Start the Mock Exam'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('The clock starts when you tap.'),
      120,
    );
    expect(find.text('The clock starts when you tap.'), findsOneWidget);

    await tester.tap(find.byType(PantasSwitch));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'No pausing and no ending a section early. Leaving the app instantly ends and submits your answers, finished or not finished.',
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(find.text('Start the Mock Exam'), 300);
    await tester.tap(find.text('Start the Mock Exam'));
    expect(startedStrict, isTrue);
  });

  testWidgets('initial strict value is local state and reaches start',
      (tester) async {
    bool? startedStrict;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: MockSetupPage(
          parsedBlueprint: blueprint(),
          initialStrictMode: true,
          onStart: (strict) => startedStrict = strict,
        ),
      ),
    );

    expect(
      tester.widget<PantasSwitch>(find.byType(PantasSwitch)).value,
      isTrue,
    );
    await tester.scrollUntilVisible(find.text('Start the Mock Exam'), 300);
    await tester.tap(find.text('Start the Mock Exam'));
    expect(startedStrict, isTrue);
  });

  testWidgets('short paper states actual count instead of hiding the shortfall',
      (tester) async {
    await pump(tester, actualQuestionCount: 230);
    expect(
      find.text('This mock has 230 questions instead of 250.'),
      findsOneWidget,
    );
  });

  testWidgets('one-block CSE omits time column and renders placeholder figures',
      (tester) async {
    final cse = blueprint(
      examId: 'exam_cse_pro',
      name: 'CSE Professional Practice Paper',
      timing: SectionalTiming.roamable,
      durationMinutes: 190,
      totalPublishedItems: 170,
      sections: [
        const BlueprintSection(
          id: 'verbal',
          name: 'Verbal Ability',
          questionCount: 45,
          suggestedMinutes: 1,
          topicIds: [],
          topicWeights: {},
          questionCountFigure: BlueprintValue(
            value: 45,
            isPlaceholder: true,
            placeholderNote: 'Published per-subject item count is unresolved.',
          ),
        ),
      ],
    );
    await pump(tester, parsed: cse);

    expect(find.text('CSE Professional simulation'), findsOneWidget);
    expect(find.text('TIME'), findsNothing);
    expect(find.byType(PlaceholderFigure), findsOneWidget);
    expect(
      find.text(
        "This paper runs as one block. You can move around the whole paper and submit when you're done.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('DCAT names excluded essay and personality test', (tester) async {
    final dcat = blueprint(
      examId: 'exam_dlsucet',
      name: 'DCAT Practice Paper',
      totalPublishedItems: 245,
    );
    await pump(tester, parsed: dcat);
    expect(
      find.textContaining(
        'Not included: the essay and the personality test. This mock covers the multiple-choice parts only.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
      'dark theme and 200 percent text remain scrollable without overflow',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pump(
      tester,
      themeMode: ThemeMode.dark,
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollable), findsWidgets);
    await tester.scrollUntilVisible(find.text('Start the Mock Exam'), 300);
    expect(find.text('Start the Mock Exam'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/components/contents_glyph.dart';
import 'package:pantas/core/ui/components/exam_name_line.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/review_list.dart';

import '../../../helpers/accessibility.dart';

void main() {
  setUpAll(() async {
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });
  const sampleQuestion = Question(
    id: 'q1',
    version: 1,
    examIds: ['cse'],
    topicId: 't1',
    language: 'en',
    stem: 'Sample Question Stem text for testing text scaling in components',
    choices: [
      Choice(
        id: 'c_a',
        label: 'A',
        text: 'Option A long text description for choice',
        isCorrect: false,
      ),
      Choice(
        id: 'c_b',
        label: 'B',
        text: 'Option B long text description for choice',
        isCorrect: true,
        rationale: 'Long rationale text explaining correct choice',
      ),
    ],
    explanation: 'Detailed explanation text for the question review',
  );

  const sampleEntry = ReviewEntry(
    number: 1,
    question: sampleQuestion,
    isFlagged: false,
    subjectName: 'Numerical Ability',
    label: 'Word Problem on Age and Work Ratios',
    labelIsStem: false,
  );

  group('accessibility harness', () {
    testWidgets('configures viewport, theme, text scale, and reduced motion', (
      tester,
    ) async {
      await pumpAccessibilitySurface(
        tester,
        const SizedBox(),
        textScale: 2,
        viewportSize: const Size(320, 640),
        brightness: Brightness.dark,
        disableAnimations: true,
      );

      final context = tester.element(find.byType(Center));
      expect(MediaQuery.sizeOf(context), const Size(320, 640));
      expect(MediaQuery.textScalerOf(context).scale(10), 20);
      expect(MediaQuery.disableAnimationsOf(context), isTrue);
      expect(Theme.of(context).brightness, Brightness.dark);
    });
  });

  group('UI Kit components survival under text scale 2.0', () {
    testWidgets('ContentsGlyph survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const ContentsGlyph(),
      );
    });

    testWidgets('PantasPage content survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const PantasPage.content(
          body: Text('Page Content Body Text'),
        ),
      );
    });

    testWidgets('ReviewRow survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        SingleChildScrollView(
          child: ReviewRow(
            entry: sampleEntry,
            isExpanded: false,
            proIsActive: true,
            onToggleExpanded: () {},
            onToggleFlag: (_) {},
          ),
        ),
      );
    });

    testWidgets('ExamNameLine survives 200% text scale', (tester) async {
      await expectSurvivesTextScale(
        tester,
        const ExamNameLine('Civil Service Professional'),
      );
    });
  });
}

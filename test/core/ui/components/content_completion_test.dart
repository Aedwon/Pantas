import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/math_support.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/components/new_design/answer_reveal.dart';
import 'package:pantas/core/ui/components/new_design/passage_card.dart';
import 'package:pantas/core/ui/components/new_design/question_card.dart';

import '../../../helpers/accessibility.dart';
import 'w2_test_support.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('answer reveal uses the 70ms fade midpoint $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        const AnswerReveal(correctLetter: 'B', explanation: 'A note.'),
        brightness: brightness,
      );
      await tester.pump(const Duration(milliseconds: 70));
      expect(
        tester
            .widget<Opacity>(
              find.byKey(const ValueKey('answer-reveal-opacity')),
            )
            .opacity,
        closeTo(.5, .001),
      );
    });
    testWidgets('picked border halfway and math painted scale $brightness',
        (tester) async {
      var state = ChoiceRowState.plain;
      final choice = StatefulBuilder(
        builder: (context, setState) => ChoiceRow(
          letter: 'A',
          text: 'Pick',
          state: state,
          onTap: () => setState(() => state = ChoiceRowState.picked),
        ),
      );
      await pumpAccessibilitySurface(tester, choice, brightness: brightness);
      await tester.tap(find.text('Pick'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 90));
      final decorationFinder = find
          .descendant(
            of: find.byKey(const ValueKey('choice-surface')),
            matching: find.byWidgetPredicate(
              (w) =>
                  w is DecoratedBox &&
                  w.position == DecorationPosition.foreground,
            ),
          )
          .first;
      final border = (tester.widget<DecoratedBox>(decorationFinder).decoration
              as BoxDecoration)
          .border! as Border;
      expect(border.top.color.a, closeTo(.8024, .003));
      await pumpAccessibilitySurface(
        tester,
        const MathText(r'Use $1.02^4$ here.'),
        brightness: brightness,
      );
      final original = tester.getRect(find.byType(Math)).height;
      await pumpAccessibilitySurface(
        tester,
        const MathText(r'Use $1.02^4$ here.'),
        brightness: brightness,
        textScale: 2,
      );
      final grown = tester.getRect(find.byType(Math)).height;
      expect(grown / original, closeTo(2, .05));
    });
    testWidgets('renderer plain markdown and malformed blocks $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        const ContentRenderer(text: 'A **strong** word.'),
        brightness: brightness,
      );
      expect(find.text('A **strong** word.'), findsNothing);
      expect(find.text('A strong word.'), findsOneWidget);
      await pumpAccessibilitySurface(
        tester,
        const ContentRenderer(
          blocks: [
            {
              '_type': 'table',
              'rows': [
                ['one'],
                ['two', 'three'],
              ],
            },
            {'_type': 'image'},
          ],
        ),
        brightness: brightness,
      );
      expect(find.text('This part cannot be shown yet.'), findsOneWidget);
      expect(find.text('Image could not load.'), findsOneWidget);
    });
    testWidgets('question stem metrics and white figure backing $brightness',
        (tester) async {
      for (final figure in [false, true]) {
        final question = QuestionCard(
          subject: 'Math',
          stem: 'Which answer is correct?',
          figure: figure
              ? const SizedBox(height: 80, child: Text('Diagram'))
              : null,
        );
        await pumpAccessibilitySurface(
          tester,
          question,
          brightness: brightness,
        );
        final text = tester.widget<Text>(find.text('Which answer is correct?'));
        expect(text.style!.fontSize, figure ? 19 : 21);
        expect(text.style!.fontWeight, FontWeight.w600);
        expect(text.style!.height, 1.35);
        expect(text.style!.letterSpacing, figure ? -.228 : -.252);
        if (figure) {
          expect(
            Theme.of(tester.element(find.text('Diagram'))).brightness,
            Brightness.light,
          );
          expect(
            tester
                .widget<Container>(
                  find.byKey(const ValueKey('question-figure-frame')),
                )
                .color,
            Colors.white,
          );
        }
        await expectSurvivesTextScale(
          tester,
          question,
          brightness: brightness,
          viewportSize: const Size(390, 844),
          disableAnimations: true,
        );
      }
    });
    testWidgets(
        'choice all states, real insets/colors and keyboard $brightness',
        (tester) async {
      var picked = 0;
      for (final state in ChoiceRowState.values) {
        final row = ChoiceRow(
          letter: 'A',
          text: 'The answer',
          state: state,
          onTap: () => picked++,
        );
        await pumpAccessibilitySurface(tester, row, brightness: brightness);
        final letter =
            state == ChoiceRowState.right || state == ChoiceRowState.wrong
                ? find.byKey(const ValueKey('choice-mark'))
                : find.text('A');
        final outer = find.byType(ChoiceRow);
        expect(
          tester.getTopLeft(letter).dx - tester.getTopLeft(outer).dx,
          closeTo(
              state == ChoiceRowState.right || state == ChoiceRowState.wrong
                  ? 14
                  : 14 + (30 - 15) / 2,
              2,),
        );
        final body = tester.widget<Text>(find.text('The answer'));
        expect(body.style!.fontSize, 17);
        expect(body.style!.height, 1.35);
        final box = tester.widget<AnimatedContainer>(
          find.byKey(const ValueKey('choice-surface')),
        );
        final bg = (box.decoration! as BoxDecoration).color!;
        if (state != ChoiceRowState.dimmed) {
          expectContrast(body.style!.color!, bg);
        }
        if (state == ChoiceRowState.dimmed) {
          expect(
            tester
                .widget<Opacity>(find.byKey(const ValueKey('choice-opacity')))
                .opacity,
            .45,
          );
        }
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await expectSurvivesTextScale(
          tester,
          row,
          brightness: brightness,
          viewportSize: const Size(390, 844),
          disableAnimations: true,
        );
      }
      expect(picked, greaterThan(0));
    });
    testWidgets('answer notes and passage real metrics $brightness',
        (tester) async {
      const answer = AnswerReveal(
        correctLetter: 'B',
        explanation: 'The crust is the outer layer.',
        pickedLetter: 'A',
        wrongPick: 'The mantle sits under the crust.',
      );
      await pumpAccessibilitySurface(tester, answer, brightness: brightness);
      expect(find.text('correct answer'), findsOneWidget);
      expect(find.text('your pick'), findsOneWidget);
      final text =
          tester.widget<Text>(find.text('The crust is the outer layer.'));
      expect(text.style!.fontSize, 15);
      expect(text.style!.height, 1.5);
      await expectSurvivesTextScale(
        tester,
        answer,
        brightness: brightness,
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
      await pumpAccessibilitySurface(
        tester,
        const PassageCard(title: 'Read this', text: 'A short passage.'),
        brightness: brightness,
      );
      expect(
        tester.widget<Text>(find.text('A short passage.')).style!.height,
        1.55,
      );
    });
    testWidgets(
        'math promotion, speech, malformed fallback and large fit $brightness',
        (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        const sentence =
            MathText(r'The ratio is $\frac{1}{\frac{2}{3}}$ today.');
        await pumpAccessibilitySurface(
          tester,
          sentence,
          brightness: brightness,
        );
        expect(
          tester.widget<MathExpression>(find.byType(MathExpression)).latex,
          r'\dfrac{1}{\frac{2}{3}}',
        );
        expect(
          find.bySemanticsLabel(RegExp('The ratio is.*today.')),
          findsOneWidget,
        );
        expect(find.bySemanticsLabel(RegExp('^1 divided by')), findsNothing);
        await expectSurvivesTextScale(
          tester,
          const MathText(r'\frac{123456789}{987654321}', display: true),
          brightness: brightness,
          viewportSize: const Size(160, 300),
          disableAnimations: true,
        );
        await pumpAccessibilitySurface(
          tester,
          const MathText(r'\badcommand{{{', display: true),
          brightness: brightness,
        );
        expect(find.text(r'\badcommand{{{'), findsOneWidget);
      } finally {
        semantics.dispose();
      }
    });
    testWidgets('renderer block styles and safe fallback $brightness',
        (tester) async {
      const renderer = ContentRenderer(
        blocks: [
          {
            '_type': 'block',
            'style': 'h2',
            'children': [
              {'text': 'How fractions work'},
            ],
          },
          {
            '_type': 'block',
            'children': [
              {'text': 'A clear paragraph.'},
            ],
          },
          {
            '_type': 'example',
            'title': 'Example 1',
            'body': 'Add these numbers.',
            'solution': 'The answer is two.',
          },
          {
            '_type': 'block',
            'style': 'blockquote',
            'children': [
              {'text': 'A quoted line.'},
            ],
          },
          {
            '_type': 'block',
            'listItem': 'number',
            'children': [
              {'text': 'First step'},
            ],
          },
          {'_type': 'latex', 'body': 'x^2'},
          {
            '_type': 'block',
            'listItem': 'number',
            'children': [
              {'text': 'Second step'},
            ],
          },
          {
            '_type': 'table',
            'rows': [
              ['Name', 'Value'],
              ['Long table cell text', '2'],
            ],
          },
          {'_type': 'futureWidget', 'secret': 'Do not show this raw data'},
        ],
      );
      await pumpAccessibilitySurface(
        tester,
        const SingleChildScrollView(child: renderer),
        brightness: brightness,
        viewportSize: const Size(390, 844),
      );
      expect(find.text('SOLUTION'), findsOneWidget);
      expect(find.text('1.'), findsOneWidget);
      expect(find.text('2.'), findsOneWidget);
      expect(find.textContaining('Do not show'), findsNothing);
      expect(find.text('This part cannot be shown yet.'), findsOneWidget);
      final h = tester.widget<Text>(find.text('How fractions work'));
      expect(h.style!.fontSize, 22);
      expect(h.style!.fontWeight, FontWeight.w700);
      expect(h.style!.height, 1.25);
      expect(
        tester.widget<Text>(find.text('A clear paragraph.')).style!.height,
        1.55,
      );
      await expectSurvivesTextScale(
        tester,
        const SingleChildScrollView(child: renderer),
        brightness: brightness,
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
    });
    testWidgets(
        'framed figures expand, zoom, credit and close by keyboard $brightness',
        (tester) async {
      final renderer = ContentRenderer(
        blocks: const [
          {
            '_type': 'figureSpec',
            'spec': {'kind': 'test'},
            'semanticsLabel': 'A diagram',
            'credit': 'Artist, CC BY-SA',
          }
        ],
        figureBuilder: (context, spec) =>
            const SizedBox(height: 160, child: Text('Code figure')),
      );
      await pumpAccessibilitySurface(tester, renderer, brightness: brightness);
      expect(find.text('Artist, CC BY-SA'), findsOneWidget);
      await tester.tap(find.byTooltip('Expand figure'));
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsNothing);
    });
  }
}

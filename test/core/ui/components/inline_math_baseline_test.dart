// The test reads laid-out baselines, which the framework only exposes through
// the protected `computeDistanceToActualBaseline`.
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_overriding_member

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/math_support.dart';
import 'package:pantas/core/ui/components/new_design/question_card.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

const _katex = 'packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_';

Future<void> _loadFonts() async {
  final geist = FontLoader('Geist');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    geist.addFont(rootBundle.load('assets/fonts/Geist-$w.ttf'));
  }
  await geist.load();
  const families = {
    'Main': ['Regular', 'Italic', 'Bold', 'BoldItalic'],
    'Math': ['Italic', 'BoldItalic'],
    'AMS': ['Regular'],
    'Size1': ['Regular'],
    'Size2': ['Regular'],
    'Size3': ['Regular'],
    'Size4': ['Regular'],
  };
  for (final entry in families.entries) {
    final loader = FontLoader('packages/flutter_math_fork/KaTeX_${entry.key}');
    for (final face in entry.value) {
      loader.addFont(rootBundle.load('$_katex${entry.key}-$face.ttf'));
    }
    await loader.load();
  }
}

/// Where the baseline of [box] sits on screen.
double _baselineY(RenderBox box) {
  final distance = box.computeDistanceToActualBaseline(TextBaseline.alphabetic);
  return box.localToGlobal(Offset(0, distance ?? box.size.height)).dy;
}

void main() {
  setUpAll(_loadFonts);

  final surfaces = <String, Widget Function(String)>{
    'lesson': (text) => ContentRenderer(text: text),
    'question stem': (text) => QuestionCard(subject: 'Math', stem: text),
    'choice': (text) => ChoiceRow(letter: 'A', text: text),
  };
  // Each sentence fits one line at phone width, so the line's baseline is the
  // paragraph's first baseline.
  const sentences = [
    r'Next: $2,5,8$',
    r'Add $3$ now',
    r'Half: $\frac{1}{2}$ ok',
    r'Solve $x^2+5$ ok',
    r'Is $\sqrt{x}$ ok',
  ];

  for (final scale in [1.0, 1.5, 2.0]) {
    for (final surface in surfaces.entries) {
      for (final sentence in sentences) {
        testWidgets(
          'inline maths shares the baseline: ${surface.key} x$scale $sentence',
          (tester) async {
            tester.view
              ..physicalSize = const Size(358, 900)
              ..devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            await tester.pumpWidget(
              MaterialApp(
                theme: buildLightTheme(),
                home: MediaQuery(
                  data: MediaQueryData(
                    size: const Size(358, 900),
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: Scaffold(
                    body: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: surface.value(sentence),
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pump();

            final paragraph = tester.renderObject<RenderParagraph>(
              find.byWidgetPredicate(
                (w) => w is RichText && w.text.toPlainText().contains('\uFFFC'),
              ),
            );
            final textBaseline = paragraph.localToGlobal(Offset.zero).dy +
                paragraph.computeDistanceToActualBaseline(
                  TextBaseline.alphabetic,
                );
            final math = tester.renderObject<RenderBox>(find.byType(Math));
            expect(
              (_baselineY(math) - textBaseline).abs(),
              lessThan(1),
              reason: 'math baseline must sit within 1 logical pixel of the '
                  'sentence baseline',
            );
          },
        );
      }
    }
  }

  testWidgets('inline maths is sized to match the words around it',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const Scaffold(
          body: ContentRenderer(
            text: r'Add $3$ now',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
    final math = tester.widget<MathExpression>(find.byType(MathExpression));
    expect(math.textStyle!.fontSize, 20 * inlineMathSizeFactor);
  });

  testWidgets('a table cell with inline maths measures without an assertion',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const Scaffold(
          body: ContentRenderer(
            blocks: [
              {
                '_type': 'table',
                'rows': [
                  ['Pattern', 'Form'],
                  ['Combination', r'$A+B\rightarrow AB$'],
                ],
              },
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(Math), findsOneWidget);
  });
}

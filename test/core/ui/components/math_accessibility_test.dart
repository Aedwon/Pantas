import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/math_support.dart';
import 'package:pantas/core/ui/components/math_text.dart';

import '../../../helpers/accessibility.dart';

const _viewport = Size(320, 800);
const _readerPadding = EdgeInsets.symmetric(horizontal: 24);
const _compoundInterestLatex = 'A = P(1 + r)^t';
const _compoundInterestSpeech =
    'A equals P open parenthesis 1 plus r close parenthesis to the power of t';
const _compoundInterestSentence =
    'Use $_compoundInterestSpeech to find the amount after interest.';
const _inlineEstimateSpeech = '1.02 to the power of 4 approximately 1.0824';
final _inlineEstimateSentence = RegExp(
  r'^Use\s+1\.02 to the power of 4\s+approximately\s+1\.0824\s+to calculate the result\.$',
);

Widget _readerSurface(Widget child) {
  return SizedBox(
    width: _viewport.width,
    child: Padding(padding: _readerPadding, child: child),
  );
}

/// Reproduces the API 36 failure mode where migrated Flutter text consumes a
/// nonlinear [TextScaler], while flutter_math_fork 0.7.4 reads only the legacy
/// scalar estimate. The real device remains the authority for Android's curve;
/// this deliberately calibrated harness only preserves the observed mismatch.
class _Android200RegressionScaler extends TextScaler {
  const _Android200RegressionScaler();

  @override
  double scale(double fontSize) => fontSize * 1.6;

  @override
  double get textScaleFactor => 2;
}

Widget _lessonParagraph(String text, {String style = 'normal'}) {
  return ContentRenderer(
    blocks: [
      {
        '_type': 'block',
        'style': style,
        'children': [
          {'_type': 'span', 'text': text, 'marks': const <String>[]},
        ],
      },
    ],
  );
}

Future<double> _paragraphHeight(
  WidgetTester tester,
  String text,
  TextScaler scaler, {
  String style = 'normal',
}) async {
  await pumpAccessibilitySurface(
    tester,
    MediaQuery(
      data: MediaQueryData(size: _viewport, textScaler: scaler),
      child: _readerSurface(_lessonParagraph(text, style: style)),
    ),
    viewportSize: _viewport,
  );

  return tester.getSize(find.byType(RichText).first).height;
}

Future<double> _inlineMathSourceSizeRatio(
  WidgetTester tester, {
  String style = 'normal',
}) async {
  await _paragraphHeight(
    tester,
    r'Here $A$ is the amount.',
    TextScaler.noScaling,
    style: style,
  );
  final mathFinder = find.byType(Math);
  final math = tester.widget<Math>(mathFinder);
  final mathContext = tester.element(mathFinder);
  final mathStyle = math.textStyle ?? DefaultTextStyle.of(mathContext).style;

  final bodyRichText = tester.widget<RichText>(find.byType(RichText).first);
  final bodyFontSize = bodyRichText.text.style!.fontSize!;
  return mathStyle.fontSize! / bodyFontSize;
}

Future<double> _inlineExponentPaintedHeight(
  WidgetTester tester,
  TextScaler scaler,
) async {
  await _paragraphHeight(
    tester,
    r'Use $1.02^4$ here.',
    scaler,
  );
  final mathFinder = find.byType(Math);
  expect(mathFinder, findsOneWidget);
  final rect = tester.getRect(mathFinder);
  return rect.height;
}

void main() {
  group('lesson math at 200% text scale', () {
    testWidgets('inline exponent consumes the active text scaler exactly once',
        (tester) async {
      final unscaledHeight = await _inlineExponentPaintedHeight(
        tester,
        TextScaler.noScaling,
      );
      final scaledHeight = await _inlineExponentPaintedHeight(
        tester,
        const _Android200RegressionScaler(),
      );
      final ratio = scaledHeight / unscaledHeight;

      expect(
        ratio,
        inInclusiveRange(1.55, 1.65),
        reason: 'The outer Text.rich already scales WidgetSpan children. '
            'Inline math must therefore consume the active scaler once, not '
            'pre-scale and then be auto-scaled again. '
            'painted-height ratio=$ratio',
      );
    });

    testWidgets('short inline math keeps the same source size at default scale',
        (tester) async {
      final ratio = await _inlineMathSourceSizeRatio(tester);

      expect(
        ratio,
        inInclusiveRange(0.95, 1.05),
        reason: 'Default-scale math should start from the same type size as '
            'its surrounding body text. ratio=$ratio',
      );
    });

    testWidgets('heading inline math inherits heading typography',
        (tester) async {
      final ratio = await _inlineMathSourceSizeRatio(
        tester,
        style: 'h2',
      );

      expect(
        ratio,
        inInclusiveRange(0.95, 1.05),
        reason: 'Inline math in an h2 must inherit the h2 effective type size, '
            'not generic body sizing. ratio=$ratio',
      );
    });

    testWidgets(
      'inline compound-interest math survives a 320dp reader width',
      (tester) async {
        await expectSurvivesTextScale(
          tester,
          _readerSurface(
            const MathText(
              r'Use $A = P(1 + r)^t$ to find the amount after interest.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
          scales: const [2.0],
          viewportSize: _viewport,
        );
      },
    );

    testWidgets(
      'display compound-interest math survives a 320dp reader width',
      (tester) async {
        await expectSurvivesTextScale(
          tester,
          _readerSurface(
            const ContentRenderer(
              blocks: [
                {'_type': 'latex', 'body': _compoundInterestLatex},
              ],
            ),
          ),
          scales: const [2.0],
          viewportSize: _viewport,
        );
      },
    );

    testWidgets(
      'inline fraction and exponent remain usable at 320dp',
      (tester) async {
        await expectSurvivesTextScale(
          tester,
          _readerSurface(
            const MathText(
              r'Compare $\frac{1}{2}x^2 + \frac{3}{4}y^3 = z^4$ carefully.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
          scales: const [2.0],
          viewportSize: _viewport,
        );
      },
    );

    testWidgets(
      'display fraction and exponent remain usable at 320dp',
      (tester) async {
        await expectSurvivesTextScale(
          tester,
          _readerSurface(
            const ContentRenderer(
              blocks: [
                {
                  '_type': 'latex',
                  'body': r'\frac{1}{2}x^2 + \frac{3}{4}y^3 = z^4',
                },
              ],
            ),
          ),
          scales: const [2.0],
          viewportSize: _viewport,
        );
      },
    );
  });

  group('math screen-reader semantics', () {
    testWidgets(
      'MathText includes inline math in the surrounding sentence',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpAccessibilitySurface(
          tester,
          _readerSurface(
            const MathText(
              r'Use $1.02^4 \approx 1.0824$ to calculate the result.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
          textScale: 2,
          viewportSize: _viewport,
        );

        expect(
          find.bySemanticsLabel(_inlineEstimateSentence),
          findsOneWidget,
          reason: 'Continuous reading needs one semantic sentence containing '
              'both the prose and the spoken inline expression.',
        );
        expect(
          find.bySemanticsLabel(_inlineEstimateSpeech),
          findsNothing,
          reason: 'The formula must not remain as a duplicate focus node '
              'after it is included in the sentence.',
        );
        semantics.dispose();
      },
    );

    testWidgets(
      'ContentRenderer includes marked inline math in its sentence',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpAccessibilitySurface(
          tester,
          _readerSurface(
            const ContentRenderer(
              blocks: [
                {
                  '_type': 'block',
                  'style': 'normal',
                  'children': [
                    {
                      '_type': 'span',
                      'text': 'Use ',
                      'marks': <String>[],
                    },
                    {
                      '_type': 'span',
                      'text': r'1.02^4 \approx 1.0824',
                      'marks': <String>['latex'],
                    },
                    {
                      '_type': 'span',
                      'text': ' to calculate the result.',
                      'marks': <String>[],
                    },
                  ],
                },
              ],
            ),
          ),
          textScale: 2,
          viewportSize: _viewport,
        );

        expect(
          find.bySemanticsLabel(_inlineEstimateSentence),
          findsOneWidget,
          reason: 'Lesson prose must expose its inline formula as part of '
              'the containing accessibility sentence.',
        );
        expect(
          find.bySemanticsLabel(_inlineEstimateSpeech),
          findsNothing,
          reason: 'Lesson prose must not repeat the formula as a separate '
              'focus node after reading the complete sentence.',
        );
        semantics.dispose();
      },
    );

    testWidgets('plain MathText keeps sensible sentence semantics',
        (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await pumpAccessibilitySurface(
          tester,
          _readerSurface(
            const MathText(
              'Read this sentence normally.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
          textScale: 2,
          viewportSize: _viewport,
        );
        expect(
          find.bySemanticsLabel('Read this sentence normally.'),
          findsOneWidget,
        );
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('malformed inline math keeps the renderer fallback',
        (tester) async {
      const text = r'Use $\badcommand{{{$ carefully.';
      expect(inlineMathSemantics(text), isNull);
      await pumpAccessibilitySurface(
        tester,
        _readerSurface(
          const MathText(
            text,
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        textScale: 2,
        viewportSize: _viewport,
      );
      await tester.pumpAndSettle();
      expect(find.text(r'\badcommand{{{'), findsOneWidget);
    });

    testWidgets(
        'inline compound-interest math is part of one semantic sentence',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpAccessibilitySurface(
        tester,
        _readerSurface(
          const MathText(
            r'Use $A = P(1 + r)^t$ to find the amount after interest.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        textScale: 2,
        viewportSize: _viewport,
      );

      expect(find.bySemanticsLabel(_compoundInterestSentence), findsOneWidget);
      expect(find.bySemanticsLabel(_compoundInterestSpeech), findsNothing);
      expect(
        find.bySemanticsLabel(RegExp(r'^(A|=|P|\(|1|\+|r|\)|t)$')),
        findsNothing,
      );
      semantics.dispose();
    });

    testWidgets('display compound-interest math is one coherent expression',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpAccessibilitySurface(
        tester,
        _readerSurface(
          const ContentRenderer(
            blocks: [
              {'_type': 'latex', 'body': _compoundInterestLatex},
            ],
          ),
        ),
        textScale: 2,
        viewportSize: _viewport,
      );

      expect(find.bySemanticsLabel(_compoundInterestSpeech), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp(r'^(A|=|P|\(|1|\+|r|\)|t)$')),
        findsNothing,
      );
      semantics.dispose();
    });

    testWidgets(
        'display math uses an authored semantic description when present',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpAccessibilitySurface(
        tester,
        _readerSurface(
          const ContentRenderer(
            blocks: [
              {
                '_type': 'latex',
                'body': _compoundInterestLatex,
                'semanticsLabel':
                    'Total amount equals principal compounded over time',
              },
            ],
          ),
        ),
        textScale: 2,
        viewportSize: _viewport,
      );

      expect(
        find.bySemanticsLabel(
          'Total amount equals principal compounded over time',
        ),
        findsOneWidget,
      );
      semantics.dispose();
    });
  });
}

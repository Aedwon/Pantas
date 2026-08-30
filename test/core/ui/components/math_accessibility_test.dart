import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/inline_math_text.dart';
import 'package:pantas/core/ui/components/portable_text_renderer.dart';

import '../../../helpers/accessibility.dart';

const _viewport = Size(320, 800);
const _readerPadding = EdgeInsets.symmetric(horizontal: 24);
const _compoundInterestLatex = 'A = P(1 + r)^t';
const _compoundInterestSpeech =
    'A equals P open parenthesis 1 plus r close parenthesis to the power of t';

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
  double get textScaleFactor => 2.0;
}

Widget _lessonParagraph(String text, {String style = 'normal'}) {
  return PortableTextRenderer(
    blocks: [
      {
        '_type': 'block',
        'style': style,
        'children': [
          {'_type': 'span', 'text': text, 'marks': <String>[]},
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

Future<double> _mathHeightInParagraph(
  WidgetTester tester,
  String text,
  TextScaler scaler, {
  String style = 'normal',
}) async {
  await _paragraphHeight(tester, text, scaler, style: style);
  return tester.getSize(find.byType(Math)).height;
}

Future<double> _effectiveInlineMathSizeRatio(
  WidgetTester tester,
  TextScaler scaler,
) async {
  await _paragraphHeight(tester, r'Here $A$ is the amount.', scaler);
  final mathFinder = find.byType(Math);
  final math = tester.widget<Math>(mathFinder);
  final mathContext = tester.element(mathFinder);
  final mathStyle = math.textStyle ?? DefaultTextStyle.of(mathContext).style;
  final legacyScale =
      math.textScaleFactor ?? MediaQuery.textScaleFactorOf(mathContext);
  final effectiveMathSize = mathStyle.fontSize! * legacyScale;

  final bodyRichText = tester.widget<RichText>(find.byType(RichText).first);
  final bodyFontSize = bodyRichText.text.style!.fontSize!;
  final effectiveBodySize = scaler.scale(bodyFontSize);
  return effectiveMathSize / effectiveBodySize;
}

void main() {
  group('lesson math at 200% text scale', () {
    testWidgets('short inline math uses the same effective nonlinear scale',
        (tester) async {
      const scaler = _Android200RegressionScaler();
      final ratio = await _effectiveInlineMathSizeRatio(tester, scaler);

      expect(
        ratio,
        inInclusiveRange(0.95, 1.05),
        reason: 'Inline math and adjacent body text must consume the active '
            'text scaler exactly once. effective-size ratio=$ratio',
      );
    });

    testWidgets('short inline math keeps the same effective default scale',
        (tester) async {
      final ratio = await _effectiveInlineMathSizeRatio(
        tester,
        TextScaler.noScaling,
      );

      expect(
        ratio,
        inInclusiveRange(0.95, 1.05),
        reason: 'Default-scale math should keep the same effective type size '
            'as its surrounding body text. ratio=$ratio',
      );
    });

    testWidgets('heading inline math inherits heading typography',
        (tester) async {
      final plainHeadingHeight = await _paragraphHeight(
        tester,
        'A',
        TextScaler.noScaling,
        style: 'h2',
      );
      final mathHeight = await _mathHeightInParagraph(
        tester,
        r'$A$',
        TextScaler.noScaling,
        style: 'h2',
      );
      final ratio = mathHeight / plainHeadingHeight;

      expect(
        ratio,
        greaterThanOrEqualTo(0.65),
        reason: 'Inline math in an h2 must use the h2 typography, not generic '
            'body sizing. heading=$plainHeadingHeight math=$mathHeight '
            'ratio=$ratio',
      );
    });

    testWidgets(
      'inline compound-interest math survives a 320dp reader width',
      (tester) async {
        await expectSurvivesTextScale(
          tester,
          _readerSurface(
            const InlineMathText(
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
            const PortableTextRenderer(
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
            const InlineMathText(
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
            const PortableTextRenderer(
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
    testWidgets('inline compound-interest math is one coherent expression',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpAccessibilitySurface(
        tester,
        _readerSurface(
          const InlineMathText(
            r'Use $A = P(1 + r)^t$ to find the amount after interest.',
            style: TextStyle(fontSize: 14, height: 1.5),
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

    testWidgets('display compound-interest math is one coherent expression',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpAccessibilitySurface(
        tester,
        _readerSurface(
          const PortableTextRenderer(
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
          const PortableTextRenderer(
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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/inline_math_text.dart';
import 'package:pantas/core/ui/components/portable_text_renderer.dart';

import '../../../helpers/accessibility.dart';

const _viewport = Size(320, 800);
const _readerPadding = EdgeInsets.symmetric(horizontal: 24);
const _compoundInterestLatex = r'A = P(1 + r)^t';
const _compoundInterestSpeech =
    'A equals P open parenthesis 1 plus r close parenthesis to the power of t';

Widget _readerSurface(Widget child) {
  return SizedBox(
    width: _viewport.width,
    child: Padding(padding: _readerPadding, child: child),
  );
}

void main() {
  group('lesson math at 200% text scale', () {
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
      addTearDown(semantics.dispose);

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
    });

    testWidgets('display compound-interest math is one coherent expression',
        (tester) async {
      final semantics = tester.ensureSemantics();
      addTearDown(semantics.dispose);

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
    });

    testWidgets(
        'display math uses an authored semantic description when present',
        (tester) async {
      final semantics = tester.ensureSemantics();
      addTearDown(semantics.dispose);

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
    });
  });
}

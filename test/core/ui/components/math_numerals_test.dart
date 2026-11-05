import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/math_support.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

const _mathFamily = 'packages/flutter_math_fork/KaTeX_Math';
const _mainFamily = 'packages/flutter_math_fork/KaTeX_Main';

/// The font families the KaTeX glyphs under [root] were drawn with.
Set<String?> _families(WidgetTester tester, Finder root) => {
      for (final text in tester.widgetList<RichText>(
        find.descendant(of: root, matching: find.byType(RichText)),
      ))
        text.text.style?.fontFamily,
    };

void main() {
  group('a bare number is body text, not math (B-29)', () {
    bool isText(String latex) => inlineMathSpan(latex) is TextSpan;

    test('a plain counting list stays in the body font', () {
      expect(isText(r'1,2,3,\dots'), isTrue);
      expect(isText('0, 1, 2'), isTrue);
      expect(isText(r'-2,-1,0,\dots'), isFalse);
      final span = inlineMathSpan(r'1,2,3,\dots') as TextSpan;
      expect(span.text, '1, 2, 3, ...');
    });

    test('years, counts and decimals stay in the body font', () {
      expect(isText('1987'), isTrue);
      expect(isText('22'), isTrue);
      expect(isText(' 4 '), isTrue);
      expect(isText('3.14'), isTrue);
      expect(isText('85,000'), isTrue);
      expect(isText('1,250,000.50'), isTrue);
    });

    test('a number keeps its digits and the surrounding style', () {
      const style = TextStyle(fontSize: 17);
      final span = inlineMathSpan('22', style: style) as TextSpan;
      expect(span.text, '22');
      expect(span.style, style);
    });

    test('real expressions keep the math face', () {
      expect(isText('x+3'), isFalse);
      expect(isText('-5'), isFalse);
      expect(isText(r'\frac{1}{2}'), isFalse);
      expect(isText(r'5\%'), isFalse);
      expect(isText('2x'), isFalse);
    });

    test('a sentence with numbers in dollars has no math spans for them', () {
      final spans = inlineMathSpans(r'Ratified in $1987$ by $22$ votes.');
      expect(spans.whereType<WidgetSpan>(), isEmpty);
      expect(
        spans.whereType<TextSpan>().map((span) => span.text).join(),
        'Ratified in 1987 by 22 votes.',
      );
    });
  });

  group('thousands separators stay one number (B-23)', () {
    test('binds each comma of a grouped number', () {
      expect(groupedThousands('27,000'), '27{,}000');
      expect(groupedThousands('1,250,000'), '1{,}250{,}000');
      expect(
        groupedThousands(r'\dfrac{120,000}{10}=12,000'),
        r'\dfrac{120{,}000}{10}=12{,}000',
      );
      expect(
        groupedThousands(r'56 \times 1,000 = 56,000'),
        r'56 \times 1{,}000 = 56{,}000',
      );
    });

    test('leaves a list of numbers with its list spacing', () {
      expect(groupedThousands('2,5,8'), '2,5,8');
      expect(groupedThousands('20,22,25,26,300'), '20,22,25,26,300');
      expect(groupedThousands('(1,2)'), '(1,2)');
    });
  });

  group('math keeps its italics inside heavier text (B-13)', () {
    Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
          MaterialApp(theme: buildLightTheme(), home: Scaffold(body: child)),
        );

    for (final weight in [FontWeight.w400, FontWeight.w500, FontWeight.w600]) {
      testWidgets('a variable is italic at weight ${weight.value}',
          (tester) async {
        await pump(
          tester,
          MathText(
            r'$P \to Q$ is false',
            style: TextStyle(fontSize: 17, fontWeight: weight),
          ),
        );
        final families = _families(tester, find.byType(MathText));
        expect(families, contains(_mathFamily));
        // An upright serif letter would come from the main family.
        final letters = tester
            .widgetList<RichText>(
              find.descendant(
                of: find.byType(MathText),
                matching: find.byType(RichText),
              ),
            )
            .where((text) => text.text.toPlainText() == 'P');
        expect(letters.single.text.style?.fontFamily, _mathFamily);
        expect(letters.single.text.style?.fontFamily, isNot(_mainFamily));
      });
    }

    testWidgets('a bold reader callout draws P and Q italic', (tester) async {
      await pump(
        tester,
        const ContentRenderer(
          readerFigures: true,
          blocks: [
            {
              '_type': 'block',
              'style': 'blockquote',
              'children': [
                {
                  '_type': 'span',
                  'text': r'P \to Q',
                  'marks': ['latex', 'strong'],
                },
              ],
            },
          ],
        ),
      );
      final letters = tester
          .widgetList<RichText>(find.byType(RichText))
          .where((text) => text.text.toPlainText() == 'Q');
      expect(letters.single.text.style?.fontFamily, _mathFamily);
    });
  });
}

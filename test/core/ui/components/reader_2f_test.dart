import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/math_support.dart';
import 'package:pantas/core/ui/components/reader_blocks.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

// QA 2F: numbered lists that a paragraph interrupts, choices written one to a
// paragraph, notes, section numbers, and marks after a formula.

Map<String, Object?> _run(String text, [List<String> marks = const []]) =>
    {'_type': 'span', 'text': text, 'marks': marks};

Map<String, Object?> _block(
  Object text, {
  String style = 'normal',
  String? list,
  int? number,
}) =>
    {
      '_type': 'block',
      'style': style,
      'children': text is String ? [_run(text)] : text,
      if (list != null) 'listItem': list,
      if (list != null) 'level': 1,
      if (number != null) 'listNumber': number,
    };

Future<void> _pump(
  WidgetTester tester,
  List<Map<String, Object?>> blocks, {
  bool wide = true,
}) async {
  debugWebPlatformOverride = wide;
  addTearDown(() => debugWebPlatformOverride = null);
  tester.view
    ..physicalSize = wide ? const Size(1440, 900) : const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(() {
    tester.view
      ..resetPhysicalSize()
      ..resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: buildDarkTheme(web: wide),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ContentRenderer(blocks: blocks, readerFigures: true),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

List<Map<String, Object?>> _example(List<Map<String, Object?>> solution) => [
      _block('Examples', style: 'h2'),
      _block('#1: Composition', style: 'h3'),
      _block('Find both compositions.'),
      _block('Solution:'),
      ...solution,
    ];

Future<void> _reveal(WidgetTester tester) async {
  final button = find.byKey(const ValueKey('reader-solution-button')).first;
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => debugWebPlatformOverride = null);

  group('numbered lists a paragraph interrupts (2F-11, 2F-14)', () {
    testWidgets('keep the numbers the source gives them', (tester) async {
      await _pump(
        tester,
        _example([
          _block('For the first one:', list: 'number', number: 1),
          {'_type': 'latex', 'body': 'g(2)=1'},
          _block('So the first is 3.'),
          _block('For the second one:', list: 'number', number: 2),
          _block('So the second is 22.'),
          _block('Then the third:', list: 'number', number: 3),
        ]),
      );
      await _reveal(tester);
      expect(find.text('1.'), findsOneWidget);
      expect(find.text('2.'), findsOneWidget);
      expect(find.text('3.'), findsOneWidget);
    });

    testWidgets('a formula between items does not restart the count',
        (tester) async {
      await _pump(
        tester,
        _example([
          _block('Take two thirds of the House.', list: 'number', number: 1),
          {'_type': 'latex', 'body': r'\dfrac{2}{3}\times300=200'},
          _block('Take two thirds of the Senate.', list: 'number', number: 2),
          {'_type': 'latex', 'body': r'\dfrac{2}{3}\times24=16'},
          _block('Both are needed.', list: 'number', number: 3),
        ]),
      );
      await _reveal(tester);
      expect(find.text('2.'), findsOneWidget);
      expect(find.text('3.'), findsOneWidget);
    });

    testWidgets('a new list starts where its first item says', (tester) async {
      await _pump(
        tester,
        _example([
          _block('One.', list: 'number', number: 1),
          _block('Two.', list: 'number', number: 2),
          _block('A paragraph ends that list.'),
          _block('A new list.', list: 'number', number: 1),
        ]),
      );
      await _reveal(tester);
      expect(find.text('1.'), findsNWidgets(2));
      expect(find.text('2.'), findsOneWidget);
    });

    testWidgets('a block with no number still counts from 1', (tester) async {
      await _pump(
        tester,
        _example([
          _block('One.', list: 'number'),
          _block('Two.', list: 'number'),
          _block('A paragraph.'),
          _block('Again.', list: 'number'),
        ]),
      );
      await _reveal(tester);
      expect(find.text('1.'), findsNWidgets(2));
      expect(find.text('2.'), findsOneWidget);
    });
  });

  group('notes (2F-2)', () {
    for (final wide in [true, false]) {
      testWidgets('keep the body line height, ${wide ? 'wide' : 'phone'}',
          (tester) async {
        await _pump(
          tester,
          [
            _block('Mnemonics & Memory Aids', style: 'h2'),
            _block('Remember this.', style: 'blockquote'),
            _block('Body text.'),
          ],
          wide: wide,
        );
        double height(String text) => tester
            .widget<RichText>(
              find
                  .byWidgetPredicate(
                    (w) => w is RichText && w.text.toPlainText() == text,
                  )
                  .first,
            )
            .text
            .style!
            .height!;
        expect(height('Remember this.'), height('Body text.'));
        expect(height('Remember this.'), wide ? 1.7 : 1.55);
      });
    }
  });

  group('choices written one to a paragraph (2F-19)', () {
    List<Map<String, Object?>> stem(List<Map<String, Object?>> choices) => [
          _block('Examples', style: 'h2'),
          _block('#1: Choosing', style: 'h3'),
          _block('Choose the parallel sentence.'),
          ...choices,
          _block('Solution:'),
          _block('The answer is B.', list: 'number', number: 1),
        ];

    testWidgets('are drawn as choice rows like the others', (tester) async {
      await _pump(
        tester,
        stem([
          _block('(A) The manual explains how to install, updating it.'),
          _block('(B) The manual explains how to install and update it.'),
          _block('(C) The manual explains installing and to update it.'),
        ]),
      );
      for (final letter in ['A', 'B', 'C']) {
        expect(find.byKey(ValueKey('reader-choice-$letter')), findsOneWidget);
      }
      expect(find.text('A)'), findsOneWidget);
      expect(find.textContaining('(A)'), findsNothing);
      // The stem stays its own paragraph.
      expect(find.text('Choose the parallel sentence.'), findsOneWidget);
    });

    testWidgets('bullets that start with A) and B) are choices too',
        (tester) async {
      await _pump(
        tester,
        stem([
          _block('A) first', list: 'bullet'),
          _block('B) second', list: 'bullet'),
        ]),
      );
      expect(find.byKey(const ValueKey('reader-choice-B')), findsOneWidget);
    });

    testWidgets('one lettered paragraph alone, or lowercase, is not',
        (tester) async {
      await _pump(
        tester,
        stem([
          _block('(A) only one of them'),
          _block('(a) a sub part'),
          _block('(b) another sub part'),
        ]),
      );
      expect(find.byKey(const ValueKey('reader-choice-A')), findsNothing);
      expect(find.byKey(const ValueKey('reader-choice-B')), findsNothing);
    });

    test('the run needs A, then B, in order, and says how many it used', () {
      final run = splitReaderChoiceBlocks([
        _block('(A) one'),
        _block('(B) two'),
        _block('(D) skipped C'),
        _block('Solution:'),
      ]);
      expect(run, isNotNull);
      expect(run!.count, 2);
      expect([for (final c in run.choices.choices) c.letter], ['A', 'B']);
      expect(
        splitReaderChoiceBlocks([_block('(B) two'), _block('(C) three')]),
        isNull,
      );
    });
  });

  group('section numbers (2F-17)', () {
    testWidgets('are text in the sentence, not maths', (tester) async {
      await _pump(tester, [
        _block([
          _run('See Section '),
          _run('5(1)', ['latex']),
          _run(' and Section '),
          _run('3(b)', ['latex']),
          _run(', and Section '),
          _run('1(a)(2)', ['latex']),
          _run(' too.'),
        ]),
      ]);
      final text = tester
          .widget<RichText>(
            find.byWidgetPredicate(
              (w) => w is RichText && w.text.toPlainText().startsWith('See'),
            ),
          )
          .text;
      // A formula would leave an object marker in the plain text.
      expect(
        text.toPlainText(),
        'See Section 5(1) and Section 3(b), and Section 1(a)(2) too.',
      );
    });

    testWidgets('a real expression such as 2(x+1) is still maths',
        (tester) async {
      await _pump(tester, [
        _block([
          _run('Expand '),
          _run('2(x+1)', ['latex']),
          _run(' first.'),
        ]),
      ]);
      expect(
        tester
            .widget<RichText>(
              find.byWidgetPredicate(
                (w) =>
                    w is RichText && w.text.toPlainText().startsWith('Expand'),
              ),
            )
            .text
            .toPlainText(),
        contains('￼'),
      );
    });
  });

  group('a mark after a formula stays with it (2F-16)', () {
    test('a period joins the formula and the rest of the text stays', () {
      final spans = inlineMathSpans(r'Solve $x^2$. Then check $y$, and stop.');
      // text, formula and period, text, formula and comma, text
      expect(spans, hasLength(5));
      expect(spans[0], isA<TextSpan>());
      expect(spans[1], isA<WidgetSpan>());
      expect((spans[2] as TextSpan).text, ' Then check ');
      expect(spans[3], isA<WidgetSpan>());
      expect((spans[4] as TextSpan).text, ' and stop.');
    });

    test('a space before the mark keeps it as text', () {
      final spans = inlineMathSpans(r'Solve $x^2$ . Next');
      expect(spans, hasLength(3));
      expect((spans[2] as TextSpan).text, ' . Next');
    });

    testWidgets('the mark is drawn in the formula box, on its line',
        (tester) async {
      await _pump(tester, [
        _block([
          _run('Factor '),
          _run('x^2+5x+6', ['latex']),
          _run('. Then solve it.'),
        ]),
      ]);
      final paragraph = tester.widget<RichText>(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().startsWith('Factor'),
        ),
      );
      final plain = paragraph.text.toPlainText();
      // The mark is inside the formula's box, so the text holds none of it.
      expect(plain, 'Factor ￼ Then solve it.');
      final mark = find.descendant(
        of: find.byType(RichText).first,
        matching: find.text('.'),
      );
      expect(mark, findsOneWidget);
    });

    testWidgets('a formula wider than the line still scales down',
        (tester) async {
      await _pump(
        tester,
        [
          _block([
            _run('Now '),
            _run('a_1+a_2+a_3+a_4+a_5+a_6+a_7+a_8+a_9+a_{10}+a_{11}', [
              'latex',
            ]),
            _run('.'),
          ]),
        ],
        wide: false,
      );
      expect(tester.takeException(), isNull);
    });
  });
}

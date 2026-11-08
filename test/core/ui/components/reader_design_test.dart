import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

import 'w2_test_support.dart';

Map<String, Object?> _run(String text, [List<String> marks = const []]) =>
    {'_type': 'span', 'text': text, 'marks': marks};

Map<String, Object?> _block(
  Object text, {
  String style = 'normal',
  String? list,
}) =>
    {
      '_type': 'block',
      'style': style,
      'children': text is String ? [_run(text)] : text,
      if (list != null) 'listItem': list,
    };

Map<String, Object?> _step(String text) => _block(text, list: 'number');

const _solution = {
  '_type': 'block',
  'style': 'normal',
  'children': [
    {
      '_type': 'span',
      'text': 'Solution:',
      'marks': ['strong'],
    },
  ],
};

/// A small lesson with every kind of content the reader treats specially.
List<Map<String, Object?>> _lesson() => [
      _block('Core Concept', style: 'h2'),
      _block([
        _run('Plain text with '),
        _run('bold words', ['strong']),
        _run(' and math '),
        _run('x^2', ['latex']),
        _run('.'),
      ]),
      {'_type': 'latex', 'body': 'a^2 + b^2 = c^2'},
      _block('A subhead', style: 'h3'),
      _block('Under the subhead.'),
      _block('A quote in a plain section.', style: 'blockquote'),
      _block('Mnemonics & Memory Aids', style: 'h2'),
      _block('Powers of i repeat.', style: 'blockquote'),
      _block('Examples', style: 'h2'),
      _block('#1: Classifying Sets', style: 'h3'),
      _block(
        'Which statement is false? A) Every integer is rational. '
        'B) Zero is a natural number. C) Every irrational is real. '
        'D) A repeating decimal is rational.',
      ),
      _solution,
      _step('Integers are fractions over 1.'),
      _step('Natural numbers begin at 1.'),
      _block('#2: A Question With No Answer Given', style: 'h3'),
      _block('Only a question here.'),
      _block('Traps to Watch For', style: 'h2'),
      _block('#1: Square Roots of Negatives', style: 'h3'),
      _block('Rewrite using i first.', style: 'blockquote'),
      _block('Then multiply.'),
    ];

class _Config {
  const _Config({required this.wide, required this.dark});
  final bool wide;
  final bool dark;
  @override
  String toString() => '${wide ? 'wide' : 'phone'} ${dark ? 'dark' : 'light'}';
}

const _configs = [
  _Config(wide: true, dark: true),
  _Config(wide: true, dark: false),
  _Config(wide: false, dark: true),
  _Config(wide: false, dark: false),
];

PantasColors _colors(_Config c) =>
    c.dark ? PantasColors.dark : PantasColors.light;

Future<void> _pump(
  WidgetTester tester,
  List<Map<String, Object?>> blocks, {
  required _Config config,
  bool reduceMotion = false,
  bool reader = true,
  double textScale = 1,
  Key? rendererKey,
}) async {
  debugWebPlatformOverride = config.wide;
  addTearDown(() => debugWebPlatformOverride = null);
  tester.view
    ..physicalSize = config.wide ? const Size(1440, 900) : const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(() {
    tester.view
      ..resetPhysicalSize()
      ..resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: config.dark
            ? buildDarkTheme(web: config.wide)
            : buildLightTheme(web: config.wide),
        home: MediaQuery(
          data: MediaQueryData(
            size: tester.view.physicalSize,
            disableAnimations: reduceMotion,
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ContentRenderer(
                  key: rendererKey,
                  blocks: blocks,
                  readerFigures: reader,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

RichText _rich(WidgetTester tester, String text) => tester.widget<RichText>(
      find
          .byWidgetPredicate(
            (w) => w is RichText && w.text.toPlainText() == text,
          )
          .first,
    );

Finder _richAt(String text) => find
    .byWidgetPredicate((w) => w is RichText && w.text.toPlainText() == text)
    .first;

final _display = find.byWidgetPredicate((w) => w is MathText && w.display);

/// The reader's note cards: accent-tinted, or warn-tinted when [warn].
Finder _notes(PantasColors c, {bool warn = false}) => find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).color ==
              (warn ? c.readerWarnTint : c.accentTint) &&
          (w.decoration! as BoxDecoration).borderRadius ==
              BorderRadius.circular(14),
    );

/// Taps the first "Show solution" button, scrolling it into view first.
Future<void> _tapReveal(WidgetTester tester) async {
  final button = find.byKey(const ValueKey('reader-solution-button')).first;
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
}

double _contrast(Color a, Color b) {
  final l = [a.computeLuminance(), b.computeLuminance()]..sort();
  return (l.last + .05) / (l.first + .05);
}

void main() {
  tearDown(() => debugWebPlatformOverride = null);

  for (final config in _configs) {
    group('reader $config', () {
      final c = _colors(config);

      testWidgets('body is a step dimmer than bold and display maths',
          (tester) async {
        await _pump(tester, _lesson(), config: config);
        final body = _rich(tester, 'Under the subhead.').text.style!;
        expect(body.color, c.readerBody);
        expect(body.fontSize, config.wide ? 18 : 17);
        expect(body.height, config.wide ? 1.7 : 1.55);
        expect(body.fontWeight, FontWeight.w400);
        final paragraph = tester
            .widget<RichText>(
              find.byWidgetPredicate(
                (w) =>
                    w is RichText &&
                    w.text.toPlainText().startsWith('Plain text with'),
              ),
            )
            .text as TextSpan;
        final bold = _spanStyle(paragraph, 'bold words')!;
        expect(bold.fontWeight, FontWeight.w600);
        expect(bold.color, c.readerStrong);
        expect(c.readerBody, isNot(c.readerStrong));
        // The brighter tier is further from the page than the dimmer one.
        final page = c.background;
        expect(
          _contrast(c.readerStrong, page),
          greaterThan(_contrast(c.readerBody, page)),
        );
        expect(_contrast(c.readerBody, page), greaterThan(4.5));
        // Display maths takes the bold color.
        final display = tester.widget<MathText>(_display);
        expect(display.style!.color, c.readerStrong);
      });

      testWidgets('section headings separate by space alone', (tester) async {
        await _pump(tester, _lesson(), config: config);
        final h2 = _rich(tester, 'Mnemonics & Memory Aids').text.style!;
        expect(h2.fontSize, 26);
        expect(h2.fontWeight, FontWeight.w700);
        expect(h2.letterSpacing, PantasType.webH2.letterSpacing);
        expect(find.textContaining(' of 5'), findsNothing);
        // The first section has no space above it.
        expect(
          tester.getTopLeft(_richAt('Core Concept')).dy,
          tester.getTopLeft(find.byType(ContentRenderer)).dy,
        );
        // A later section: 40 above the heading, 12 below (ReaderLayout).
        final card = tester.getBottomLeft(
          _notes(c).first,
        );
        final head = tester.getTopLeft(_richAt('Mnemonics & Memory Aids'));
        expect(head.dy - card.dy, 40);
        final headBottom =
            tester.getBottomLeft(_richAt('Mnemonics & Memory Aids')).dy;
        final next = tester.getTopLeft(_notes(c).at(1)).dy;
        expect(next - headBottom, 12);
      });

      testWidgets('subheads sit 28 above and 8 below', (tester) async {
        await _pump(tester, _lesson(), config: config);
        final h3 = _rich(tester, 'A subhead').text.style!;
        expect(h3.fontSize, 20);
        expect(h3.fontWeight, FontWeight.w700);
        final maths = tester.getBottomLeft(_display).dy;
        final top = tester.getTopLeft(_richAt('A subhead')).dy;
        expect(top - maths, closeTo(28, .01));
        final bottom = tester.getBottomLeft(_richAt('A subhead')).dy;
        final under = tester.getTopLeft(_richAt('Under the subhead.')).dy;
        expect(under - bottom, 8);
      });

      testWidgets('notes: Remember, Watch out, and plain', (tester) async {
        await _pump(tester, _lesson(), config: config);
        // Plain section: accent tint, no label.
        final notes = _notes(c);
        final plain = tester.widget<Container>(notes.at(0));
        final plainBox = plain.decoration! as BoxDecoration;
        expect(plainBox.color, c.accentTint);
        expect(plainBox.borderRadius, BorderRadius.circular(14));
        expect(
          plain.padding,
          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        );
        expect(
          find.descendant(of: notes.at(0), matching: find.byType(Text)),
          findsOneWidget,
        );
        // Mnemonics: labelled Remember.
        expect(
          find.descendant(of: notes.at(1), matching: find.text('Remember')),
          findsOneWidget,
        );
        final text = tester.widget<RichText>(
          find.descendant(
            of: notes.at(1),
            matching: find.byWidgetPredicate(
              (w) =>
                  w is RichText &&
                  w.text.toPlainText() == 'Powers of i repeat.',
            ),
          ),
        );
        expect(text.text.style!.color, c.readerNoteText);
        // Traps: warn tint and Watch out.
        final warn = _notes(c, warn: true);
        expect(warn, findsOneWidget);
        expect(
          (tester.widget<Container>(warn).decoration! as BoxDecoration).color,
          c.readerWarnTint,
        );
        expect(
          find.descendant(of: warn, matching: find.text('Watch out')),
          findsOneWidget,
        );
        final label = tester.widget<Text>(find.text('Watch out'));
        expect(label.style!.color, c.readerMistakeText);
        final warnText = tester.widget<RichText>(
          find.descendant(
            of: warn,
            matching: find.byWidgetPredicate(
              (w) =>
                  w is RichText &&
                  w.text.toPlainText() == 'Rewrite using i first.',
            ),
          ),
        );
        expect(warnText.text.style!.color, c.readerWarnText);
      });

      testWidgets('examples become cards; traps keep their gutter number',
          (tester) async {
        await _pump(tester, _lesson(), config: config);
        final cards = find.byKey(const ValueKey('reader-example-card'));
        expect(cards, findsNWidgets(2));
        final card = tester.widget<Container>(cards.first);
        final box = card.decoration! as BoxDecoration;
        expect(box.color, c.surface);
        expect(box.borderRadius, BorderRadius.circular(18));
        expect((box.border! as Border).top.color, c.separator);
        expect(find.text('Example 1'), findsOneWidget);
        expect(find.text('Example 2'), findsOneWidget);
        expect(
          tester.widget<Text>(find.text('Example 1')).style!.color,
          c.accent,
        );
        // The "#1:" prefix is gone and no gutter "1" sits beside an example.
        expect(find.textContaining('#1:'), findsNothing);
        expect(
          find.descendant(of: cards.first, matching: find.text('1')),
          findsNothing,
        );
        expect(find.text('Classifying Sets'), findsOneWidget);
        // Trap keeps "1".
        expect(find.text('1'), findsOneWidget);
        expect(find.text('Square Roots of Negatives'), findsOneWidget);
        final inset = config.wide ? 24.0 : 16.0;
        final cardLeft = tester.getTopLeft(cards.first).dx;
        expect(
          tester.getTopLeft(find.text('Example 1')).dx - cardLeft,
          inset + 1,
        );
        expect(
          tester.getTopLeft(find.text('Example 1')).dy -
              tester.getTopLeft(cards.first).dy,
          (config.wide ? 20 : 18) + 1,
        );
      });

      testWidgets('choices split into rows with an accent letter',
          (tester) async {
        await _pump(tester, _lesson(), config: config);
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is RichText &&
                w.text.toPlainText() == 'Which statement is false?',
          ),
          findsOneWidget,
        );
        final rows = find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('reader-choice-'),
        );
        expect(rows, findsNWidgets(4));
        for (final letter in ['A)', 'B)', 'C)', 'D)']) {
          final text = tester.widget<Text>(find.text(letter));
          expect(text.style!.color, c.accent);
          expect(text.style!.fontWeight, FontWeight.w600);
        }
        final first = tester.widget<Container>(rows.first);
        expect(
          (first.decoration! as BoxDecoration).border,
          Border(top: BorderSide(color: c.separator)),
        );
        expect(first.padding, const EdgeInsets.symmetric(vertical: 8));
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is RichText &&
                w.text.toPlainText().contains('Zero is a natural number.'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('a solution starts hidden and opens on a tap',
          (tester) async {
        await _pump(tester, _lesson(), config: config);
        expect(find.text('Natural numbers begin at 1.'), findsNothing);
        final button = find.byKey(const ValueKey('reader-solution-button'));
        expect(button, findsOneWidget);
        // Only the example that has a solution has a button.
        expect(find.text('Show solution'), findsOneWidget);
        final size = tester.getSize(button);
        expect(size.height, greaterThanOrEqualTo(48));
        final cardBox = tester.getRect(
          find.byKey(const ValueKey('reader-example-card')).first,
        );
        final inset = config.wide ? 24.0 : 16.0;
        expect(size.width, cardBox.width - 2 - inset * 2);
        final style = tester.widget<TextButton>(button).style!;
        expect(style.backgroundColor!.resolve({}), c.accentTint);
        expect(style.foregroundColor!.resolve({}), c.accent);
        final shape = style.shape!.resolve({})! as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(12));

        await _tapReveal(tester);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        final half = tester.getSize(
          find.byKey(const ValueKey('reader-example-card')).first,
        );
        await tester.pump(const Duration(milliseconds: 200));
        final full = tester.getSize(
          find.byKey(const ValueKey('reader-example-card')).first,
        );
        // Size eases open rather than jumping.
        expect(half.height, lessThan(full.height));
        expect(find.text('Show solution'), findsNothing);
        expect(find.text('SOLUTION'), findsOneWidget);
        expect(find.text('Natural numbers begin at 1.'), findsOneWidget);

        // The panel is flush with the card's edges and deeper than the card.
        final panel = find.byKey(const ValueKey('reader-solution-panel'));
        final panelRect = tester.getRect(panel);
        final card = tester.getRect(
          find.byKey(const ValueKey('reader-example-card')).first,
        );
        expect(panelRect.left, card.left + 1);
        expect(panelRect.right, card.right - 1);
        final decoration =
            tester.widget<Container>(panel).decoration! as BoxDecoration;
        expect(decoration.color, c.readerDeep);
        expect((decoration.border! as Border).top.color, c.separator);

        // Step numbers share a 22 px column and align.
        final one = tester.getTopLeft(find.text('1.')).dx;
        final two = tester.getTopLeft(find.text('2.')).dx;
        expect(one, two);
        final column = tester.widget<ConstrainedBox>(
          find.ancestor(
            of: find.text('1.'),
            matching: find.byType(ConstrainedBox),
          ),
        );
        expect(column.constraints.minWidth, 22);
        final text = find.byWidgetPredicate(
          (w) =>
              w is RichText &&
              (w.text.toPlainText() == 'Integers are fractions over 1.' ||
                  w.text.toPlainText() == 'Natural numbers begin at 1.'),
        );
        expect(
          tester.getTopLeft(text.at(0)).dx,
          tester.getTopLeft(text.at(1)).dx,
        );
        final markers = tester.widget<Text>(find.text('1.'));
        expect(
          markers.style!.fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
      });

      testWidgets('an open solution stays open through rebuilds',
          (tester) async {
        await _pump(tester, _lesson(), config: config);
        await _tapReveal(tester);
        await tester.pumpAndSettle();
        expect(find.text('Natural numbers begin at 1.'), findsOneWidget);
        await _pump(tester, _lesson(), config: config);
        await tester.pumpAndSettle();
        expect(find.text('Natural numbers begin at 1.'), findsOneWidget);
        // A new visit starts closed again.
        await tester.pumpWidget(const SizedBox());
        await _pump(tester, _lesson(), config: config);
        expect(find.text('Natural numbers begin at 1.'), findsNothing);
        expect(find.text('Show solution'), findsOneWidget);
      });

      testWidgets('reduced motion opens the solution at once', (tester) async {
        await _pump(tester, _lesson(), config: config, reduceMotion: true);
        expect(find.byType(AnimatedSize), findsNothing);
        await _tapReveal(tester);
        await tester.pump();
        expect(find.text('Natural numbers begin at 1.'), findsOneWidget);
        expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
      });

      testWidgets('the reveal uses the phone 300 ms size animation',
          (tester) async {
        await _pump(tester, _lesson(), config: config);
        final sized = tester.widget<AnimatedSize>(find.byType(AnimatedSize));
        expect(sized.duration, const Duration(milliseconds: 300));
      });

      testWidgets('Enter and Space open it, and the button has semantics',
          (tester) async {
        final handle = tester.ensureSemantics();
        await _pump(tester, _lesson(), config: config);
        expect(
          tester.getSemantics(
            find.byKey(const ValueKey('reader-solution-button')),
          ),
          isSemantics(
            label: 'Show solution',
            isButton: true,
            isFocusable: true,
            isEnabled: true,
            hasTapAction: true,
            hasFocusAction: true,
          ),
        );
        for (final key in [
          LogicalKeyboardKey.enter,
          LogicalKeyboardKey.space,
        ]) {
          await tester.pumpWidget(const SizedBox());
          await _pump(tester, _lesson(), config: config);
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
          await tester.sendKeyEvent(key);
          await tester.pumpAndSettle();
          expect(
            find.text('Natural numbers begin at 1.'),
            findsOneWidget,
            reason: '$key',
          );
        }
        handle.dispose();
      });
    });
  }

  for (final config in [_configs[0], _configs[2]]) {
    testWidgets('the cards survive double text size, $config', (tester) async {
      await _pump(tester, _lesson(), config: config, textScale: 2);
      await _tapReveal(tester);
      await tester.pumpAndSettle();
      expect(find.text('Natural numbers begin at 1.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a reader with no Examples heading renders plainly',
      (tester) async {
    await _pump(
      tester,
      [
        _block('Anything Else', style: 'h2'),
        _block('#1: A numbered subhead', style: 'h3'),
        _block('Solution:'),
        _step('a step'),
        _block('A quote', style: 'blockquote'),
      ],
      config: _configs[0],
    );
    expect(find.byKey(const ValueKey('reader-example-card')), findsNothing);
    expect(find.text('Show solution'), findsNothing);
    // Outside an example, a solution keeps its open panel.
    expect(find.text('SOLUTION'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    // A quote in an unknown section is the unlabeled accent card.
    expect(_notes(PantasColors.dark), findsOneWidget);
    expect(find.text('REMEMBER'), findsNothing);
    expect(find.text('Watch out'), findsNothing);
  });

  testWidgets('worked-example headings and odd blocks never throw',
      (tester) async {
    await _pump(
      tester,
      [
        _block('Worked Examples', style: 'h2'),
        _block('Choose one', style: 'h3'),
        _block('Pick (A) red (B) green and the end.'),
        _block(r'With math: A) $x^2$ B) $y$ C) none'),
        {'_type': 'mystery'},
        _block('', style: 'h3'),
      ],
      config: _configs[2],
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Example 1'), findsOneWidget);
    expect(find.text('Example 2'), findsOneWidget);
  });

  testWidgets('the app outside the reader keeps its own look', (tester) async {
    await _pump(
      tester,
      [
        _block('Core Concept', style: 'h2'),
        _block('Body text.'),
        _block('A quote', style: 'blockquote'),
        _block('Examples', style: 'h2'),
        _block('#1: Not a card', style: 'h3'),
      ],
      config: _configs[2],
      reader: false,
    );
    expect(find.byKey(const ValueKey('reader-example-card')), findsNothing);
    expect(_notes(PantasColors.dark), findsNothing);
    final body = _rich(tester, 'Body text.').text.style!;
    expect(body.color, PantasColors.dark.label);
    expect(body.color, isNot(PantasColors.dark.readerBody));
    expect(_rich(tester, 'Core Concept').text.style!.fontSize, 22);
  });

  test('named reader colors keep the approved values', () {
    expect(PantasColors.dark.readerBody, const Color(0xFFC9C9CD));
    expect(PantasColors.dark.readerStrong, const Color(0xFFFFFFFF));
    expect(PantasColors.light.readerBody, const Color(0xFF3C3C43));
    expect(PantasColors.light.readerStrong, const Color(0xFF111114));
    for (final c in [PantasColors.dark, PantasColors.light]) {
      expectContrast(c.readerNoteText, c.accentTint);
      expectContrast(c.readerWarnText, c.readerWarnTint);
      expectContrast(c.readerWarn, c.readerWarnTint, minimum: 3);
      expectContrast(c.accent, c.accentTint, minimum: 3);
      expectContrast(c.readerBody, c.surface);
      expectContrast(c.readerBody, c.readerDeep);
    }
  });
}

TextStyle? _spanStyle(TextSpan root, String text) {
  TextStyle? found;
  root.visitChildren((span) {
    if (span is TextSpan && span.text == text) found = span.style;
    return true;
  });
  return found;
}

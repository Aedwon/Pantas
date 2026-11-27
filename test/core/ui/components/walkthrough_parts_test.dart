import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart' hide testWidgets;
import 'package:flutter_test/flutter_test.dart' as flutter_test
    show testWidgets;
import 'package:pantas/core/content/remote/lesson_markdown.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/math_support.dart';
import 'package:pantas/core/ui/components/reader_blocks.dart';
import 'package:pantas/core/ui/components/walkthrough_parts.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

import '../../../helpers/button_placement.dart';

// Walk-through parts in the reader (E-196), built from hand-made blocks that
// follow the Portable Text schema in
// docs/superpowers/specs/2026-11-26-walkthrough-renderer-build.md.

/// A widget test with semantics on, so a screen reader's words can be found.
void testWidgets(
  String description,
  Future<void> Function(WidgetTester tester) body,
) =>
    flutter_test.testWidgets(description, (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await body(tester);
      } finally {
        semantics.dispose();
      }
    });

Map<String, Object?> _run(String text, [List<String> marks = const []]) =>
    {'_type': 'span', 'text': text, 'marks': marks};

Map<String, Object?> _p(
  Object text, {
  String style = 'normal',
  String? list,
  int? number,
  String? anchor,
}) =>
    {
      '_type': 'block',
      'style': style,
      'children': text is String ? [_run(text)] : text,
      if (list != null) 'listItem': list,
      if (list != null) 'level': 1,
      if (number != null) 'listNumber': number,
      if (anchor != null) 'anchor': anchor,
    };

List<Map<String, Object?>> _spans(String text) => [_run(text)];

Map<String, Object?> _check(String question, String answer) => {
      '_type': 'walkCheck',
      'question': [_p(question)],
      'answer': [_p(answer)],
    };

Map<String, Object?> _try(String prompt, List<String> answer) => {
      '_type': 'walkTry',
      'prompt': [_p(prompt)],
      'answer': [for (final a in answer) _p(a)],
    };

Map<String, Object?> _why(String body) => {
      '_type': 'walkWhy',
      'body': [_p(body)],
    };

Map<String, Object?> _pair(
  String id, {
  String right = 'Right line',
  String wrong = 'Wrong line',
  String note = 'The note under both.',
}) =>
    {
      '_type': 'walkPair',
      'id': id,
      'right': _spans(right),
      'wrong': _spans(wrong),
      'note': [_p(note)],
    };

Map<String, Object?> _checklist(List<(String, String, String)> items) => {
      '_type': 'walkChecklist',
      'items': [
        for (final (cue, move, target) in items)
          {'cue': _spans(cue), 'move': _spans(move), 'target': target},
      ],
    };

final _solutionMarker = _p('Solution:')
  ..['children'] = [
    _run('Solution:', ['strong']),
  ];

/// An example with [steps] numbered steps. Each step is followed by a line of
/// work, so a step group is a step and its work. [inStep] puts extra blocks
/// right after the given step.
List<Map<String, Object?>> _example(
  int steps, {
  String title = '#1: Seven steps',
  String? anchor = 'seven-steps',
  Map<int, List<Map<String, Object?>>> inStep = const {},
  List<Map<String, Object?>> tail = const [],
}) =>
    [
      _p(title, style: 'h3', anchor: anchor),
      _p('Evaluate the expression.'),
      _solutionMarker,
      for (var i = 1; i <= steps; i++) ...[
        _p('Step $i text.', list: 'number', number: i),
        _p('Work for step $i.'),
        ...?inStep[i],
      ],
      ...tail,
    ];

/// A lesson long enough to scroll, with a target heading above the example, a
/// pair inside step 5 of seven, and the trap checklist at the end.
List<Map<String, Object?>> _flowLesson() => [
      _p('Core Concept', style: 'h2'),
      for (var i = 0; i < 20; i++) _p('Opening line $i.'),
      _p('A subhead', style: 'h3', anchor: 'core-notes'),
      for (var i = 0; i < 20; i++) _p('Middle line $i.'),
      _p('Examples', style: 'h2'),
      ..._example(
        7,
        inStep: {
          5: [_pair('minus-before-negative')],
        },
        tail: [
          _try('Finish the last step.', [
            'The answer is 1. It is small.',
            'Check: it fits.',
          ]),
        ],
      ),
      for (var i = 0; i < 30; i++) _p('Closing line $i.'),
      _p('Traps to Watch For', style: 'h2'),
      _checklist([
        (
          'A minus before a negative:',
          'change both signs.',
          'minus-before-negative',
        ),
        ('Read the subhead:', 'it sets the rule.', 'core-notes'),
        ('A missing target:', 'nothing happens.', 'no-such-slug'),
      ]),
      for (var i = 0; i < 12; i++) _p('Tail line $i.'),
    ];

Future<void> _pump(
  WidgetTester tester,
  List<Map<String, Object?>> blocks, {
  bool wide = false,
  bool dark = false,
  bool still = false,
  ScrollController? controller,
  double? width,
  void Function(ReaderResizedNotification)? onResized,
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
        theme: dark ? buildDarkTheme(web: wide) : buildLightTheme(web: wide),
        home: MediaQuery(
          data: MediaQueryData(
            size: tester.view.physicalSize,
            disableAnimations: still,
          ),
          child: Scaffold(
            body: NotificationListener<ReaderResizedNotification>(
              onNotification: (n) {
                onResized?.call(n);
                return true;
              },
              child: SingleChildScrollView(
                key: const ValueKey('scroll'),
                controller: controller,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: width == null
                      ? ContentRenderer(blocks: blocks, readerFigures: true)
                      : Align(
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            width: width,
                            child: ContentRenderer(
                              blocks: blocks,
                              readerFigures: true,
                            ),
                          ),
                        ),
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

Finder _rich(String text) => find.byWidgetPredicate(
      (w) => w is RichText && w.text.toPlainText() == text,
    );

RichText _richWidget(WidgetTester tester, String text) =>
    tester.widget<RichText>(_rich(text).first);

Finder _key(String key) => find.byKey(ValueKey(key));

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pump();
  await tester.tap(finder.first);
}

/// Pumps in 50 ms steps until [finder] matches, up to [limit].
Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration limit = const Duration(seconds: 3),
}) async {
  var spent = Duration.zero;
  while (finder.evaluate().isEmpty && spent < limit) {
    await tester.pump(const Duration(milliseconds: 50));
    spent += const Duration(milliseconds: 50);
  }
}

double _opacity(WidgetTester tester, Finder within) {
  final fade =
      find.descendant(of: within, matching: find.byType(FadeTransition));
  return tester.widget<FadeTransition>(fade.first).opacity.value;
}

PantasColors _c(bool dark) => dark ? PantasColors.dark : PantasColors.light;

void main() {
  tearDown(() => debugWebPlatformOverride = null);

  group('first sentence of an answer', () {
    test('is marked bold up to its full stop', () {
      final out = boldFirstSentence([
        _run('The answer is 6. Subtract 11 − 5.'),
      ]);
      expect(
        out.map((r) => r['text']).join(),
        'The answer is 6. Subtract 11 − 5.',
      );
      expect(out.first['text'], 'The answer is 6.');
      expect(out.first['marks'], contains('strong'));
      expect(out.last['marks'], isNot(contains('strong')));
    });

    test('runs through maths and the mark after it', () {
      final out = boldFirstSentence([
        _run('The answer is '),
        _run('-6', ['latex']),
        _run('. Subtract it.'),
      ]);
      expect(out[0]['marks'], contains('strong'));
      expect(out[1]['marks'], containsAll(['latex', 'strong']));
      expect(out[2]['text'], '.');
      expect(out[2]['marks'], contains('strong'));
      expect(out[3]['text'], ' Subtract it.');
      expect(out[3]['marks'], isNot(contains('strong')));
    });

    test('does not split a decimal point', () {
      final out = boldFirstSentence([_run('It is 3.5 metres. Next.')]);
      expect(out.first['text'], 'It is 3.5 metres.');
    });

    test('leaves a run with no sentence end alone', () {
      final out = boldFirstSentence([_run('No end here')]);
      expect(out.single['marks'], isNot(contains('strong')));
    });

    // A closing quote or bracket belongs to the sentence it closes (board
    // LB_Grammar, third `.wans`).
    for (final close in ['"', "'", '”', '’', ')']) {
      for (final stop in ['.', '!', '?']) {
        test('keeps a closing $close after $stop in the bold', () {
          final first = 'To agree, choose was$stop$close';
          final out = boldFirstSentence([_run('$first Then check.')]);
          expect(out.first['text'], first);
          expect(out.first['marks'], contains('strong'));
          expect(out.last['text'], ' Then check.');
          expect(out.last['marks'], isNot(contains('strong')));
        });
      }
    }

    test('a quote that opens after the stop does not join the bold', () {
      final out = boldFirstSentence([_run('It is 6. "Next" follows.')]);
      expect(out.first['text'], 'It is 6.');
    });
  });

  group('first sentence of a Why? panel', () {
    test('is bold when it is a question, maths and the mark included', () {
      final out = boldFirstQuestion([
        _run('Why does the exponent go first in '),
        _run('-3^2', ['latex']),
        _run('? Powers come first.'),
      ]);
      expect(out[0]['marks'], contains('strong'));
      expect(out[1]['marks'], containsAll(['latex', 'strong']));
      expect(out[2]['text'], '?');
      expect(out[2]['marks'], contains('strong'));
      expect(out[3]['text'], ' Powers come first.');
      expect(out[3]['marks'], isNot(contains('strong')));
    });

    test('stays plain when the first sentence is a statement', () {
      final runs = [_run('Look at the pattern. Why does it work?')];
      final out = boldFirstQuestion(runs);
      expect(out, runs);
      expect(out.single['marks'], isNot(contains('strong')));
    });

    test('a question that ends in a closing quote is bold', () {
      final out = boldFirstQuestion([_run('Why the "-s"? Because.')]);
      expect(out.first['text'], 'Why the "-s"?');
      expect(out.first['marks'], contains('strong'));
    });

    test('a panel with no sentence end stays plain', () {
      final out = boldFirstQuestion([_run('No end here')]);
      expect(out.single['marks'], isNot(contains('strong')));
    });
  });

  group('the real converter output', () {
    // The four sample lessons, converted as the app converts them, draw on a
    // phone and wide, in step with the schema the converters emit.
    final frontmatter = RegExp(r'^---\n(.*?)\n---\n', dotAll: true);
    for (final name in [
      'signed-integer-operations',
      'substituting-negative-numbers',
      'discounted-prices',
      'finding-subjects-and-matching-verbs',
    ]) {
      for (final wide in [false, true]) {
        testWidgets('$name, ${wide ? 'wide' : 'phone'}', (tester) async {
          final source =
              File('test/fixtures/walkthrough/$name.md').readAsStringSync();
          final blocks = lessonBlocksFromMarkdown(
            source.substring(frontmatter.firstMatch(source)!.end),
          );
          expect(lessonIsWalkthrough(blocks), isTrue);
          await _pump(tester, blocks, wide: wide);
          expect(tester.takeException(), isNull);
          // Solutions are open, so no "Show solution", and a stepped one
          // offers "Next step".
          expect(find.text('Show solution'), findsNothing);
          expect(_key('walk-checklist'), findsAny);
        });
      }

      testWidgets('$name: every checklist line reaches its target',
          (tester) async {
        final source =
            File('test/fixtures/walkthrough/$name.md').readAsStringSync();
        final blocks = lessonBlocksFromMarkdown(
          source.substring(frontmatter.firstMatch(source)!.end),
        );
        final targets = [
          for (final block in blocks)
            if (block['_type'] == 'walkChecklist')
              for (final item in block['items']! as List<Object?>)
                (item! as Map<String, Object?>)['target']! as String,
        ];
        await _pump(tester, blocks);
        for (var i = 0; i < targets.length; i++) {
          await Scrollable.ensureVisible(
            tester.element(_key('walk-checklist-row-$i')),
            alignment: .5,
          );
          await tester.pump();
          await tester.tap(_key('walk-checklist-row-$i'));
          await _pumpUntil(tester, _key('walk-tint-${targets[i]}'));
          expect(
            _key('walk-tint-${targets[i]}'),
            findsOneWidget,
            reason: 'line $i of $name points at ${targets[i]}',
          );
          await tester.pumpAndSettle();
        }
      });
    }
  });

  group('old-format lessons', () {
    testWidgets('keep "Show solution" and the closed solution', (tester) async {
      await _pump(tester, [
        _p('Examples', style: 'h2'),
        ..._example(7),
      ]);
      expect(find.text('Show solution'), findsOneWidget);
      expect(_rich('Step 1 text.'), findsNothing);
      expect(find.text('Next step'), findsNothing);
      await _tap(tester, find.text('Show solution'));
      await tester.pumpAndSettle();
      expect(_rich('Step 7 text.'), findsOneWidget);
      expect(find.text('Next step'), findsNothing);
    });
  });

  for (final wide in [false, true]) {
    final tier = wide ? 'wide' : 'phone';

    group('Quick Check, $tier', () {
      final lesson = [
        _p('Core Concept', style: 'h2'),
        _p('Before the card.'),
        _check(
          'Find the answer.',
          'The answer is 6. Subtract 11 − 5. It is positive.',
        ),
        _p('After the card.'),
      ];

      testWidgets('rests as a card with its label, question and button',
          (tester) async {
        await _pump(tester, lesson, wide: wide);
        final c = _c(false);
        expect(find.text('QUICK CHECK'), findsOneWidget);
        // One group that a screen reader opens with its name.
        expect(find.bySemanticsLabel(RegExp('^Quick Check')), findsOneWidget);
        expect(_rich('Find the answer.'), findsOneWidget);
        expect(find.text('Show answer'), findsOneWidget);
        expect(
          _rich('The answer is 6. Subtract 11 − 5. It is positive.'),
          findsNothing,
        );
        final card = tester.getRect(_key('walk-card'));
        final box = tester.widget<Container>(_key('walk-card')).decoration!
            as BoxDecoration;
        expect(box.color, c.surface);
        expect(box.borderRadius, BorderRadius.circular(16));
        final label = tester.widget<Text>(find.text('QUICK CHECK'));
        expect(label.style!.color, c.accent);
        expect(label.style!.fontSize, 12);
        expect(label.style!.fontWeight, FontWeight.w600);
        expect(label.style!.letterSpacing, .48);
        // The card keeps 16 on a phone and 20 on a wide screen inside its
        // 1 px border; the button is 44 high.
        final button = tester.getRect(_key('walk-answer-button'));
        expect(button.height, 44);
        final inset = wide ? 20.0 : 16.0;
        expect(button.right, card.right - 1 - inset);
        if (wide) {
          expect(button.width, lessThan(card.width / 2));
          expectWidePlacement(tester);
        } else {
          expect(button.left, card.left + 1 + inset);
        }
      });

      testWidgets('shows the answer, first sentence bold, and drops the button',
          (tester) async {
        await _pump(tester, lesson, wide: wide);
        await _tap(tester, _key('walk-answer-button'));
        await tester.pumpAndSettle();
        expect(find.text('Show answer'), findsNothing);
        final answer = tester
            .widgetList<RichText>(
              find.descendant(
                of: _key('walk-answer'),
                matching: find.byType(RichText),
              ),
            )
            .first;
        final spans = <TextSpan>[];
        answer.text.visitChildren((s) {
          if (s is TextSpan && s.text != null) spans.add(s);
          return true;
        });
        final bold = spans
            .where((s) => s.style?.fontWeight == FontWeight.w600)
            .map((s) => s.text)
            .join();
        expect(bold, 'The answer is 6.');
        final panel = tester.widget<Container>(_key('walk-answer'));
        final decoration = panel.decoration! as BoxDecoration;
        expect(decoration.color, _c(false).accentTint);
        expect(decoration.borderRadius, BorderRadius.circular(12));
        expect(_key('walk-answer-check'), findsOneWidget);
      });

      testWidgets('opens over 240 ms in height and 180 ms in opacity',
          (tester) async {
        await _pump(tester, lesson, wide: wide);
        await _tap(tester, _key('walk-answer-button'));
        await tester.pump();
        final reveal = _key('walk-answer-reveal');
        expect(tester.getSize(reveal).height, 0);
        await tester.pump(const Duration(milliseconds: 90));
        final early = tester.getSize(reveal).height;
        expect(early, greaterThan(0));
        expect(_opacity(tester, reveal), inExclusiveRange(0, 1));
        await tester.pump(const Duration(milliseconds: 110));
        // 200 ms: the fade is done, the height still has 40 ms to go.
        expect(_opacity(tester, reveal), 1);
        final mid = tester.getSize(reveal).height;
        await tester.pump(const Duration(milliseconds: 60));
        final end = tester.getSize(reveal).height;
        expect(mid, lessThanOrEqualTo(end));
        expect(end, greaterThan(early));
        await tester.pumpAndSettle();
        expect(tester.getSize(reveal).height, end);
      });

      testWidgets('with Reduce Motion the end state shows at once',
          (tester) async {
        await _pump(tester, lesson, wide: wide, still: true);
        await _tap(tester, _key('walk-answer-button'));
        await tester.pump();
        expect(
          _rich('The answer is 6. Subtract 11 − 5. It is positive.'),
          findsOneWidget,
        );
        expect(_key('walk-answer'), findsOneWidget);
        expect(
          tester.getSize(_key('walk-answer-reveal')).height,
          greaterThan(0),
        );
        expect(find.text('Show answer'), findsNothing);
      });

      testWidgets('sends a resize notice when the answer opens',
          (tester) async {
        var notices = 0;
        await _pump(
          tester,
          lesson,
          wide: wide,
          onResized: (_) => notices++,
        );
        await _tap(tester, _key('walk-answer-button'));
        await tester.pumpAndSettle();
        expect(notices, greaterThan(0));
      });

      testWidgets('sends it with Reduce Motion too', (tester) async {
        var notices = 0;
        await _pump(
          tester,
          lesson,
          wide: wide,
          still: true,
          onResized: (_) => notices++,
        );
        await _tap(tester, _key('walk-answer-button'));
        await tester.pump();
        await tester.pump();
        expect(notices, greaterThan(0));
      });
    });

    group('Why?, $tier', () {
      final lesson = [
        _p('Core Concept', style: 'h2'),
        _p('A rule of thumb.'),
        _why('Because the longer walk decides the side.'),
        _p('The next paragraph.'),
      ];

      testWidgets('is a teal button that opens a panel and becomes Hide',
          (tester) async {
        await _pump(tester, lesson, wide: wide);
        final c = _c(false);
        expect(find.text('Why?'), findsOneWidget);
        expect(find.text('Hide'), findsNothing);
        expect(
          _rich('Because the longer walk decides the side.'),
          findsNothing,
        );
        final rule = tester.getRect(_rich('A rule of thumb.'));
        final button = tester.getRect(_key('walk-why-button'));
        expect(button.height, 44);
        if (wide) expectWidePlacement(tester);
        // The board's 18 under a paragraph, less the 10 it pulls the button up
        // (`.why{margin:-10px 0 18px}`).
        expect(button.top - rule.bottom, closeTo(18 - 10, 0.5));
        await _tap(tester, _key('walk-why-button'));
        await tester.pumpAndSettle();
        expect(find.text('Hide'), findsOneWidget);
        expect(find.text('Why?'), findsNothing);
        final text = _rich('Because the longer walk decides the side.');
        expect(text, findsOneWidget);
        final panel = tester.widget<Container>(_key('walk-why-panel'));
        final decoration = panel.decoration! as BoxDecoration;
        expect(decoration.color, c.readerDeep);
        expect(decoration.borderRadius, BorderRadius.circular(12));
        expect(
          _richWidget(tester, 'Because the longer walk decides the side.')
              .text
              .style!
              .fontSize,
          wide ? 17 : 16,
        );
        await _tap(tester, _key('walk-why-button'));
        await tester.pumpAndSettle();
        expect(find.text('Why?'), findsOneWidget);
        expect(
          _rich('Because the longer walk decides the side.'),
          findsNothing,
        );
      });
    });

    group('answer line, $tier', () {
      List<Map<String, Object?>> lesson({required bool walk}) => [
            _p('Examples', style: 'h2'),
            if (walk) _why('A short reason.'),
            ..._example(2, tail: [_p('The answer is 12.')]),
          ];

      testWidgets('lines up with the step text in a walk-through lesson',
          (tester) async {
        await _pump(tester, lesson(walk: true), wide: wide);
        final answer = tester.getRect(_rich('The answer is 12.'));
        // Board `.note` padding-left 31: the 22 step column and the 9 gap,
        // where the step text starts. (The test font's number is wider than
        // the column, so the step text itself is not compared.)
        final work = tester.getRect(_rich('Work for step 2.'));
        expect(answer.left - work.left, 31);
      });

      testWidgets('stays flush in an old-format lesson', (tester) async {
        await _pump(tester, lesson(walk: false), wide: wide);
        await _tap(tester, find.text('Show solution'));
        await tester.pumpAndSettle();
        final work = tester.getRect(_rich('Work for step 2.'));
        final answer = tester.getRect(_rich('The answer is 12.'));
        expect(answer.left, work.left);
      });
    });

    group('right and wrong pair, $tier', () {
      final lesson = [
        _p('Core Concept', style: 'h2'),
        _pair('p1'),
        _p('After the pair.'),
      ];

      for (final dark in [false, true]) {
        final theme = dark ? 'dark' : 'light';
        testWidgets('is always open, stacked, Right in a card, $theme',
            (tester) async {
          await _pump(tester, lesson, wide: wide, dark: dark);
          final c = _c(dark);
          expect(
            find.bySemanticsLabel(RegExp('^Right and wrong')),
            findsOneWidget,
          );
          expect(find.text('RIGHT'), findsOneWidget);
          expect(find.text('WRONG'), findsOneWidget);
          final right = tester.getRect(_key('walk-pair-right'));
          final wrong = tester.getRect(_key('walk-pair-wrong'));
          final note = tester.getRect(_rich('The note under both.'));
          // Stacked at every width: Right above Wrong above the note.
          expect(wrong.top, greaterThanOrEqualTo(right.bottom));
          expect(note.top, greaterThanOrEqualTo(wrong.bottom));
          expect(wrong.left, greaterThanOrEqualTo(right.left));
          final card = tester.widget<Container>(_key('walk-pair-right'));
          final decoration = card.decoration! as BoxDecoration;
          expect(decoration.color, c.surface);
          expect(decoration.borderRadius, BorderRadius.circular(14));
          // Wrong has no card and no border.
          expect(
            find.descendant(
              of: _key('walk-pair-wrong'),
              matching: find.byWidgetPredicate(
                (w) =>
                    w is DecoratedBox &&
                    w.decoration is BoxDecoration &&
                    ((w.decoration as BoxDecoration).border != null ||
                        (w.decoration as BoxDecoration).color != null),
              ),
            ),
            findsNothing,
          );
          final rightStyle = _richWidget(tester, 'Right line').text.style!;
          final wrongStyle = _richWidget(tester, 'Wrong line').text.style!;
          expect(rightStyle.fontSize, wide ? 17 : 16);
          expect(wrongStyle.fontSize, wide ? 16 : 15);
          expect(wrongStyle.color, c.secondaryLabel);
          expect(wrongStyle.color, isNot(c.danger));
          expect(rightStyle.color, c.label);
          expect(
            tester.widget<Text>(find.text('RIGHT')).style!.color,
            c.accent,
          );
          expect(
            tester.widget<Text>(find.text('WRONG')).style!.color,
            c.secondaryLabel,
          );
          expect(_key('walk-pair-right-icon'), findsOneWidget);
          expect(_key('walk-pair-wrong-icon'), findsOneWidget);
        });
      }
    });

    group('trap checklist, $tier', () {
      final lesson = [
        _p('Traps to Watch For', style: 'h2'),
        _checklist([
          ('First cue:', 'do this.', 'a'),
          ('Second cue:', 'do that.', 'b'),
        ]),
        _pair('a'),
        _pair('b'),
      ];

      testWidgets('has rows of 44 or more with a bold cue and an up arrow',
          (tester) async {
        await _pump(tester, lesson, wide: wide);
        final c = _c(false);
        final list = tester.widget<Container>(_key('walk-checklist'));
        final decoration = list.decoration! as BoxDecoration;
        expect(decoration.color, c.surface);
        expect(decoration.borderRadius, BorderRadius.circular(16));
        for (var i = 0; i < 2; i++) {
          expect(
            tester.getSize(_key('walk-checklist-row-$i')).height,
            greaterThanOrEqualTo(44),
          );
          expect(_key('walk-checklist-arrow-$i'), findsOneWidget);
        }
        expect(
          find.bySemanticsLabel(RegExp('Go to its step')),
          findsNWidgets(2),
        );
        final row = tester.widget<RichText>(
          find
              .descendant(
                of: _key('walk-checklist-row-0'),
                matching: find.byType(RichText),
              )
              .first,
        );
        final cue = <TextSpan>[];
        row.text.visitChildren((s) {
          if (s is TextSpan && s.text != null) cue.add(s);
          return true;
        });
        expect(
          cue
              .where((s) => s.style?.fontWeight == FontWeight.w600)
              .map((s) => s.text)
              .join(),
          'First cue:',
        );
        expect(
          cue
              .where((s) => s.style?.fontWeight != FontWeight.w600)
              .map((s) => s.text)
              .join(),
          ' do this.',
        );
        expect(row.text.style!.fontSize, wide ? 17 : 16);
      });

      testWidgets('presses to the accent tint and hovers to the deep fill',
          (tester) async {
        await _pump(tester, lesson, wide: wide);
        final c = _c(false);
        Color? fill(int i) => (tester
                .widget<AnimatedContainer>(_key('walk-checklist-row-$i'))
                .decoration as BoxDecoration?)
            ?.color;
        expect(fill(0), isNot(c.accentTint));
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(tester.getCenter(_key('walk-checklist-row-0')));
        await tester.pump(const Duration(milliseconds: 200));
        expect(fill(0), c.readerDeep);
        await mouse.down(tester.getCenter(_key('walk-checklist-row-0')));
        await tester.pump(const Duration(milliseconds: 200));
        expect(fill(0), c.accentTint);
        await mouse.up();
        await mouse.removePointer();
        await tester.pumpAndSettle();
      });

      testWidgets('shows a focus ring inside the row for the keyboard',
          (tester) async {
        await _pump(tester, lesson, wide: wide);
        expect(_key('walk-checklist-ring-0'), findsNothing);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(_key('walk-checklist-ring-0'), findsOneWidget);
        final ring = tester.widget<DecoratedBox>(_key('walk-checklist-ring-0'));
        final border = (ring.decoration as BoxDecoration).border! as Border;
        expect(border.top.width, 2);
        expect(border.top.color, _c(false).accent);
      });
    });

    group('stepped examples, $tier', () {
      final steps7 = [
        _p('Examples', style: 'h2'),
        ..._example(7),
      ];

      testWidgets('open the solution and show only the first step',
          (tester) async {
        await _pump(tester, [..._flowLessonShort(), ...steps7], wide: wide);
        expect(find.text('Show solution'), findsNothing);
        expect(find.text('SOLUTION'), findsOneWidget);
        expect(_rich('Step 1 text.'), findsOneWidget);
        expect(_rich('Work for step 1.'), findsOneWidget);
        expect(_rich('Step 2 text.'), findsNothing);
        expect(find.text('Next step'), findsOneWidget);
        expect(find.text('Show all steps'), findsOneWidget);
      });

      testWidgets('Next step opens one group at a time', (tester) async {
        await _pump(tester, [..._flowLessonShort(), ...steps7], wide: wide);
        await _tap(tester, find.text('Next step'));
        await tester.pumpAndSettle();
        expect(_rich('Step 2 text.'), findsOneWidget);
        expect(_rich('Step 3 text.'), findsNothing);
        for (var i = 0; i < 5; i++) {
          await _tap(tester, find.text('Next step'));
          await tester.pumpAndSettle();
        }
        expect(_rich('Step 7 text.'), findsOneWidget);
        expect(find.text('Next step'), findsNothing);
        expect(find.text('Show all steps'), findsNothing);
      });

      testWidgets('Show all steps opens every group and the row goes',
          (tester) async {
        await _pump(tester, [..._flowLessonShort(), ...steps7], wide: wide);
        await _tap(tester, find.text('Show all steps'));
        await tester.pumpAndSettle();
        for (var i = 1; i <= 7; i++) {
          expect(_rich('Step $i text.'), findsOneWidget);
        }
        expect(find.text('Next step'), findsNothing);
        expect(find.text('Show all steps'), findsNothing);
      });

      testWidgets('three steps show at once with no row', (tester) async {
        await _pump(
          tester,
          [
            ..._flowLessonShort(),
            _p('Examples', style: 'h2'),
            ..._example(3),
          ],
          wide: wide,
        );
        for (var i = 1; i <= 3; i++) {
          expect(_rich('Step $i text.'), findsOneWidget);
        }
        expect(find.text('Next step'), findsNothing);
      });

      testWidgets('the row sits as the placement rule says', (tester) async {
        await _pump(tester, [..._flowLessonShort(), ...steps7], wide: wide);
        final all = tester.getRect(_key('walk-show-all-steps'));
        final next = tester.getRect(_key('walk-next-step'));
        expect(all.height, 44);
        expect(next.height, 44);
        if (wide) {
          // Secondary first, main last at the right end, natural width.
          expect(all.left, lessThan(next.left));
          expect(next.left - all.right, 8);
          expect(all.top, next.top);
          expectWidePlacement(tester);
        } else {
          // Stacked, Next step on top, the same width.
          expect(next.top, lessThan(all.top));
          expect(next.width, all.width);
          expect(next.left, all.left);
          expect(all.top - next.bottom, 8);
        }
      });
    });
  }

  group('tap-back', () {
    Future<void> toChecklist(WidgetTester tester) async {
      final scroll =
          tester.state<ScrollableState>(find.byType(Scrollable).first);
      scroll.position.jumpTo(scroll.position.maxScrollExtent);
      await tester.pump();
    }

    double centerGap(WidgetTester tester, String slug) =>
        (tester.getRect(_key('walk-target-$slug')).center.dy -
                tester.getRect(_key('scroll')).center.dy)
            .abs();

    testWidgets('opens the hidden steps, centers the target, then fades',
        (tester) async {
      await _pump(tester, _flowLesson());
      expect(_rich('Step 5 text.'), findsNothing);
      await toChecklist(tester);
      await tester.tap(_key('walk-checklist-row-0'));
      await tester.pump();
      await _pumpUntil(tester, _key('walk-tint-minus-before-negative'));
      // Every group of that example is open, the target is in the middle.
      for (var i = 1; i <= 7; i++) {
        expect(_rich('Step $i text.'), findsOneWidget);
      }
      expect(find.text('Next step'), findsNothing);
      expect(centerGap(tester, 'minus-before-negative'), lessThan(1.5));
      final tint = _key('walk-tint-minus-before-negative');
      expect(_opacity(tester, tint), 1);
      // The tint holds for 300 ms, then fades over 1200 ms.
      await tester.pump(const Duration(milliseconds: 250));
      expect(_opacity(tester, tint), 1);
      await tester.pump(const Duration(milliseconds: 700));
      expect(_opacity(tester, tint), inExclusiveRange(0, 1));
      await tester.pump(const Duration(milliseconds: 800));
      expect(_opacity(tester, tint), 0);
      await tester.pumpAndSettle();
      expect(_opacity(tester, tint), 0);
      expect(_key('walk-outline-minus-before-negative'), findsNothing);
    });

    testWidgets('the tint is the accent tint, inset 12 with radius 20',
        (tester) async {
      await _pump(tester, _flowLesson());
      await toChecklist(tester);
      await tester.tap(_key('walk-checklist-row-0'));
      await _pumpUntil(tester, _key('walk-tint-minus-before-negative'));
      final tint = _key('walk-tint-minus-before-negative');
      final target = tester.getRect(_key('walk-target-minus-before-negative'));
      expect(tester.getRect(tint), target.inflate(12));
      final box = tester
          .widget<DecoratedBox>(
            find
                .descendant(of: tint, matching: find.byType(DecoratedBox))
                .first,
          )
          .decoration as BoxDecoration;
      expect(box.color, _c(false).accentTint);
      expect(box.borderRadius, BorderRadius.circular(20));
      await tester.pumpAndSettle();
    });

    testWidgets('a heading target is inset 8 by 12 with radius 12',
        (tester) async {
      await _pump(tester, _flowLesson());
      await toChecklist(tester);
      await tester.tap(_key('walk-checklist-row-1'));
      await _pumpUntil(tester, _key('walk-tint-core-notes'));
      expect(centerGap(tester, 'core-notes'), lessThan(1.5));
      final tint = _key('walk-tint-core-notes');
      final target = tester.getRect(_key('walk-target-core-notes'));
      expect(
        tester.getRect(tint),
        Rect.fromLTRB(
          target.left - 12,
          target.top - 8,
          target.right + 12,
          target.bottom + 8,
        ),
      );
      final box = tester
          .widget<DecoratedBox>(
            find
                .descendant(of: tint, matching: find.byType(DecoratedBox))
                .first,
          )
          .decoration as BoxDecoration;
      expect(box.borderRadius, BorderRadius.circular(12));
      await tester.pumpAndSettle();
    });

    testWidgets(
        'the tint is not drawn while scrolling and is full when it lands',
        (tester) async {
      await _pump(tester, _flowLesson());
      await toChecklist(tester);
      final scroll =
          tester.state<ScrollableState>(find.byType(Scrollable).first);
      await tester.tap(_key('walk-checklist-row-0'));
      final tint = _key('walk-tint-minus-before-negative');
      var scrolled = false;
      var before = scroll.position.pixels;
      for (var i = 0; i < 80 && tint.evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 20));
        if (scroll.position.pixels != before) scrolled = true;
        before = scroll.position.pixels;
      }
      expect(scrolled, isTrue, reason: 'the page scrolls before the tint');
      expect(tint, findsOneWidget);
      // The page has stopped, and the tint is at full for its 300 ms hold.
      final landed = scroll.position.pixels;
      expect(scroll.position.isScrollingNotifier.value, isFalse);
      expect(_opacity(tester, tint), 1);
      await tester.pump(const Duration(milliseconds: 280));
      expect(scroll.position.pixels, landed);
      expect(_opacity(tester, tint), 1);
      await tester.pumpAndSettle();
    });

    testWidgets('a second tap moves the tint to the new target',
        (tester) async {
      await _pump(tester, _flowLesson());
      await toChecklist(tester);
      await tester.tap(_key('walk-checklist-row-1'));
      await _pumpUntil(tester, _key('walk-tint-core-notes'));
      await toChecklist(tester);
      await tester.tap(_key('walk-checklist-row-0'));
      await _pumpUntil(tester, _key('walk-tint-minus-before-negative'));
      expect(_key('walk-tint-core-notes'), findsNothing);
      await tester.pumpAndSettle();
    });

    testWidgets('a target that does not exist does nothing', (tester) async {
      await _pump(tester, _flowLesson());
      await toChecklist(tester);
      final before = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .pixels;
      await tester.tap(_key('walk-checklist-row-2'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .pixels,
        before,
      );
    });

    group('with Reduce Motion', () {
      testWidgets('jumps at once and leaves a static outline', (tester) async {
        await _pump(tester, _flowLesson(), still: true);
        await toChecklist(tester);
        await tester.tap(_key('walk-checklist-row-0'));
        await tester.pump();
        await tester.pump();
        expect(_key('walk-outline-minus-before-negative'), findsOneWidget);
        expect(_key('walk-tint-minus-before-negative'), findsNothing);
        for (var i = 1; i <= 7; i++) {
          expect(_rich('Step $i text.'), findsOneWidget);
        }
        expect(centerGap(tester, 'minus-before-negative'), lessThan(1.5));
        final outline = tester.widget<DecoratedBox>(
          _key('walk-outline-minus-before-negative'),
        );
        final box = outline.decoration as BoxDecoration;
        expect((box.border! as Border).top.width, 2);
        expect((box.border! as Border).top.color, _c(false).accent);
        expect(box.borderRadius, BorderRadius.circular(20));
        // It stays.
        await tester.pump(const Duration(seconds: 5));
        expect(_key('walk-outline-minus-before-negative'), findsOneWidget);
      });

      testWidgets('the outline moves with the next tap', (tester) async {
        await _pump(tester, _flowLesson(), still: true);
        await toChecklist(tester);
        await tester.tap(_key('walk-checklist-row-0'));
        await tester.pump();
        await tester.pump();
        await toChecklist(tester);
        await tester.tap(_key('walk-checklist-row-1'));
        await tester.pump();
        await tester.pump();
        expect(_key('walk-outline-core-notes'), findsOneWidget);
        expect(_key('walk-outline-minus-before-negative'), findsNothing);
      });
    });
  });

  group('review fixes', () {
    List<TextSpan> leaves(RichText rich) {
      final out = <TextSpan>[];
      rich.text.visitChildren((s) {
        if (s is TextSpan && s.text != null) out.add(s);
        return true;
      });
      return out;
    }

    String boldOf(RichText rich) => leaves(rich)
        .where((s) => s.style?.fontWeight == FontWeight.w600)
        .map((s) => s.text)
        .join();

    testWidgets('a Why? panel bolds a first sentence that is a question',
        (tester) async {
      await _pump(tester, [
        _p('Core Concept', style: 'h2'),
        {
          '_type': 'walkWhy',
          'body': [
            _p([
              _run('Why does the exponent go first in '),
              _run('-3^2', ['latex']),
              _run('? Powers come before multiplying.'),
            ]),
          ],
        },
        {
          '_type': 'walkWhy',
          'body': [_p('Look at the pattern. Why does it work?')],
        },
      ]);
      await _tap(tester, _key('walk-why-button').first);
      await tester.pumpAndSettle();
      final panel = find.descendant(
        of: _key('walk-why-panel').first,
        matching: find.byType(RichText),
      );
      // The mark after the maths travels inside the maths box.
      expect(
        boldOf(tester.widget<RichText>(panel.first)),
        startsWith('Why does the exponent go first in'),
      );
      expect(
        boldOf(tester.widget<RichText>(panel.first)),
        isNot(contains('Powers')),
      );
      await _tap(tester, _key('walk-why-button').last);
      await tester.pumpAndSettle();
      final plain = find.descendant(
        of: _key('walk-why-panel').last,
        matching: find.byType(RichText),
      );
      expect(boldOf(tester.widget<RichText>(plain.first)), isEmpty);
    });

    // A part under display maths sits 28 under the maths box, the same as the
    // space above the formula (Aedwon, Nov 27).
    final latex = {'_type': 'latex', 'body': r'x = \dfrac{1}{2}'};
    final parts = <String, (Map<String, Object?>, String)>{
      'Quick Check': (_check('Q?', 'A.'), 'walk-card'),
      'Try': (_try('Try it.', ['A.']), 'walk-card'),
      'Why?': (_why('Because.'), 'walk-why-button'),
      'pair': (_pair('p1'), 'walk-target-p1'),
      'checklist': (
        _checklist([('Cue:', 'move.', 'p1')]),
        'walk-checklist',
      ),
    };
    for (final MapEntry(key: name, value: (part, key)) in parts.entries) {
      testWidgets('a $name after display maths sits 28 under the maths box',
          (tester) async {
        await _pump(tester, [
          _p('Core Concept', style: 'h2'),
          _p('Intro.'),
          latex,
          part,
        ]);
        final math = tester.getRect(find.byType(MathExpression).last);
        final below = tester.getRect(_key(key).last);
        expect(below.top - math.bottom, closeTo(28, 0.5));
      });
    }

    // Aedwon picked option A for "Try the last step" (Nov 28): inside a
    // solution it is no card. A 1 px rule 16 under the work and 14 above the
    // label replaces the fill, border and radius.
    for (final dark in [false, true]) {
      testWidgets(
          'Try inside a solution is a ruled part, not a card in a card, '
          '${dark ? 'dark' : 'light'}', (tester) async {
        await _pump(
          tester,
          [
            _p('Examples', style: 'h2'),
            ..._example(
              2,
              tail: [
                _try('Finish the last step.', ['The answer is 1.']),
              ],
            ),
          ],
          dark: dark,
        );
        final panel = tester.element(_key('reader-solution-panel'));
        // (a) Nothing between the solution panel and the Try content draws a
        // fill, a border or a radius.
        final tryPart = tester.element(_key('walk-try'));
        final drawn = <Widget>[];
        void check(Widget w) {
          final d = switch (w) {
            Container(decoration: final BoxDecoration? d) => d,
            DecoratedBox(decoration: final BoxDecoration d) => d,
            _ => null,
          };
          if (d != null &&
              (d.color != null || d.border != null || d.borderRadius != null)) {
            drawn.add(w);
          }
          if (w is ColoredBox || w is Material || w is PhysicalModel) {
            drawn.add(w);
          }
        }

        check(tryPart.widget);
        tryPart.visitAncestorElements((e) {
          // The panel's own fill is the solution panel; stop there.
          final w = e.widget;
          if (w is DecoratedBox &&
              w.decoration == (panel.widget as Container).decoration) {
            return false;
          }
          check(e.widget);
          return true;
        });
        expect(drawn, isEmpty);
        // (b) The rule is 1 px in the separator color, 16 under the work and
        // 14 above the label.
        final rule = _key('walk-try-rule');
        final ruleBox = tester.widget<ColoredBox>(rule);
        expect(ruleBox.color, _c(dark).separator);
        final ruleRect = tester.getRect(rule);
        expect(ruleRect.height, 1);
        final work = tester.getRect(_rich('Work for step 2.'));
        expect(ruleRect.top - work.bottom, 16);
        final label = tester.getRect(find.text('TRY THE LAST STEP'));
        expect(label.top - ruleRect.bottom, 14);
        // The rule runs the width of the part.
        expect(ruleRect.width, tester.getRect(_key('walk-try')).width);
        // The group keeps its name for a screen reader.
        expect(
          find.bySemanticsLabel(RegExp('^Try the last step')),
          findsOneWidget,
        );
      });
    }

    // Aedwon on staging (Nov 27): the space after a Wrong line and after a
    // display formula looked smaller than the space before it. The gap below
    // must equal the gap above, measured between the rendered boxes.
    for (final dark in [false, true]) {
      testWidgets(
          'space after a display formula equals the space before it, '
          '${dark ? 'dark' : 'light'}', (tester) async {
        await _pump(
          tester,
          [
            _p('Core Concept', style: 'h2'),
            _p('Rearrange the rate formula to get the time.'),
            {'_type': 'latex', 'body': r't = \dfrac{1}{r}'},
            _p('Now put the rate in and divide.'),
          ],
          dark: dark,
        );
        final before = tester.getRect(
          _rich('Rearrange the rate formula to get the time.'),
        );
        final math = tester.getRect(find.byType(MathExpression).last);
        final after = tester.getRect(_rich('Now put the rate in and divide.'));
        final above = math.top - before.bottom;
        final below = after.top - math.bottom;
        expect(below, closeTo(above, 1));
      });

      testWidgets(
          'space after a Wrong line equals the space before it, '
          '${dark ? 'dark' : 'light'}', (tester) async {
        await _pump(
          tester,
          [
            _p('Core Concept', style: 'h2'),
            {
              '_type': 'walkPair',
              'id': 'p1',
              'right': [
                _run(r't = \dfrac{25}{60}', ['latex']),
                _run(' hour'),
              ],
              'wrong': [
                _run(r't = \dfrac{5}{24}', ['latex']),
                _run(' hour'),
              ],
              'note': [_p('The note under both.')],
            },
          ],
          dark: dark,
        );
        final card = tester.getRect(_key('walk-pair-right'));
        final label = tester.getRect(find.text('WRONG'));
        final line = tester.getRect(
          find
              .descendant(
                of: _key('walk-pair-wrong'),
                matching: find.byType(RichText),
              )
              .last,
        );
        final note = tester.getRect(_rich('The note under both.'));
        final above = label.top - card.bottom;
        final below = note.top - line.bottom;
        expect(below, closeTo(above, 1));
      });
    }

    testWidgets('spacing between ordinary blocks does not change',
        (tester) async {
      await _pump(tester, [
        _p('Core Concept', style: 'h2'),
        _p('A paragraph.'),
        _check('Q?', 'A.'),
        _p('Another paragraph.'),
        latex,
        _p('After the maths.'),
      ]);
      final paragraph = tester.getRect(_rich('A paragraph.'));
      final card = tester.getRect(_key('walk-card'));
      expect(card.top - paragraph.bottom, 16);
      final math = tester.getRect(find.byType(MathExpression).last);
      final after = tester.getRect(_rich('After the maths.'));
      expect(after.top - math.bottom, 28);
    });

    for (final wide in [false, true]) {
      testWidgets(
          'answer lines with fractions do not overlap, '
          '${wide ? 'wide' : 'phone'}', (tester) async {
        // A two-line answer with a fraction on each line, laid out at a run of
        // widths so some width puts the two fractions on lines that follow
        // one another.
        var adjacent = 0;
        for (var width = 260.0; width <= 420; width += 10) {
          await _pump(
            tester,
            [
              _p('Core Concept', style: 'h2'),
              _try('Find the amount.', [
                r'ab $\dfrac{81}{2}$ cd $27 \times \dfrac{3}{2}$ ef gh.',
              ]),
            ],
            wide: wide,
            width: width,
          );
          // The answer stays open from the first width on.
          if (_key('walk-answer-button').evaluate().isNotEmpty) {
            await _tap(tester, _key('walk-answer-button'));
          }
          await tester.pumpAndSettle();
          final boxes = find
              .descendant(
                of: _key('walk-answer'),
                matching: find.byType(MathExpression),
              )
              .evaluate()
              .map((e) => tester.getRect(find.byWidget(e.widget)))
              .toList()
            ..sort((a, b) => a.top.compareTo(b.top));
          expect(boxes.length, 2);
          if (boxes.last.top - boxes.first.top < boxes.first.height / 2) {
            continue; // Both on one line at this width.
          }
          adjacent++;
          // The second line's math starts below the first line's math.
          expect(
            boxes.last.top,
            greaterThan(boxes.first.bottom),
            reason: 'at width $width',
          );
        }
        expect(
          adjacent,
          greaterThan(0),
          reason: 'a width put them on two lines',
        );
      });
    }
  });
}

/// A short lead-in so an example is not the first block on the page. It holds
/// one walk-through part, which puts the lesson in walk-through mode.
List<Map<String, Object?>> _flowLessonShort() => [
      _p('Core Concept', style: 'h2'),
      _p('A line before the examples.'),
      _why('A short reason.'),
    ];

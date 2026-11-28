import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/first_run/presentation/widgets/first_run_intro.dart';
import 'package:yaml/yaml.dart';

import '../../../helpers/button_placement.dart';
import '../first_run_harness.dart';

// The side-by-side review fixes (E-179): sizes and positions against the
// board frames at 390 and 1440.

String _run(String step, {String picks = '', String checked = ''}) =>
    '{"uid":"u1","examId":"exam_upcat","step":"$step",'
    '"picks":{$picks},"checked":[$checked]}';

final _q1Right = _run('question1', picks: '"q1":"q1-c1"', checked: '"q1"');
final _q2Wrong = _run(
  'question2',
  picks: '"q1":"q1-c1","q2":"q2-c1"',
  checked: '"q1","q2"',
);
final _endOneMiss = _run(
  'end',
  picks: '"q1":"q1-c1","q2":"q2-c1","q3":"q3-c1"',
  checked: '"q1","q2","q3"',
);

Finder _button(String label) => find.widgetWithText(WebButton, label);

String _plain(String latex) => latex
    .replaceAllMapped(
      RegExp(r'\\dfrac\{(\d+)\}\{(\d+)\}'),
      (m) => '${m[1]}/${m[2]}',
    )
    .replaceAll(r'\%', '%')
    .replaceAll(r'$', '')
    .trim();

void main() {
  group('end, wide (W06)', () {
    testWidgets('Done is large, in the 1000 px column, level with the title',
        (tester) async {
      await pumpFirstRun(tester, width: 1440, progressJson: _endOneMiss);
      final done = tester.getRect(_button('Done'));
      expect(done.height, 50);
      expect(done.right, closeTo(1220, 2));
      expect(done.top, closeTo(56, 1));
      final title = tester.getRect(find.text('You finished the lesson'));
      expect(title.center.dy, closeTo(done.center.dy, 4));
      expect(find.text('Enter'), findsOneWidget);
    });

    testWidgets('the mistakes eyebrow counts after a dot; the card is 640',
        (tester) async {
      await pumpFirstRun(tester, width: 1440, progressJson: _endOneMiss);
      expect(find.text('YOUR MISTAKES · 1'), findsOneWidget);
      expect(find.text('YOUR MISTAKES'), findsNothing);
      expect(
        tester.getSize(find.byKey(const ValueKey('end-mistakes'))).width,
        640,
      );
    });

    testWidgets('placement', (tester) async {
      await pumpFirstRun(tester, width: 1440, progressJson: _endOneMiss);
      expectWidePlacement(tester);
    });
  });

  group('end, phone (P06)', () {
    testWidgets('the title is 30/700, left aligned', (tester) async {
      await pumpFirstRun(tester, progressJson: _endOneMiss);
      final finder = find.text('You finished the lesson');
      final rect = tester.getRect(finder);
      expect(rect.left, 16);
      final style = tester.widget<Text>(finder).style!;
      expect(style.fontSize, 30);
      expect(style.fontWeight, FontWeight.w700);
    });
  });

  group('intro', () {
    testWidgets('wide slides in 24 px sideways, not up', (tester) async {
      tester.view
        ..physicalSize = const Size(1440, 900)
        ..devicePixelRatio = 1;
      debugWebPlatformOverride = true;
      addTearDown(() {
        tester.view.reset();
        debugWebPlatformOverride = null;
      });
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1440, 900)),
          child: MaterialApp(
            theme: buildLightTheme(web: true),
            home: Scaffold(
              body: FirstRunIntro(onStart: () {}, onSkip: () {}),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      final shifts = tester
          .widgetList<Transform>(
            find.ancestor(
              of: find.text('Try Pantas first'),
              matching: find.byType(Transform),
            ),
          )
          .map((t) => t.transform.getTranslation());
      final slide = shifts.where((v) => v.x > 0);
      expect(slide, hasLength(1));
      expect(slide.single.x, lessThanOrEqualTo(24));
      expect(slide.single.y, 0);
      await tester.pumpAndSettle();
    });

    testWidgets('no Skip carries a key chip; Start keeps Enter',
        (tester) async {
      await pumpFirstRun(tester, width: 1440);
      expect(find.text('Esc'), findsNothing);
      expect(find.text('Enter'), findsOneWidget);
    });

    testWidgets('Enter still starts on wide', (tester) async {
      await pumpFirstRun(tester, width: 1440);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Answer 3 Questions'), findsOneWidget);
    });

    testWidgets('phone actions sit 34 px above the bottom, 6 apart',
        (tester) async {
      await pumpFirstRun(tester);
      final start = tester.getRect(find.widgetWithText(InkWell, 'Start'));
      final skip = tester.getRect(find.widgetWithText(InkWell, 'Skip'));
      expect(skip.bottom, 844 - 34);
      expect(start.top, 844 - 34 - 52 - 6 - 52);
    });

    testWidgets('the preview type is the board crop: 30 and 21 at .747',
        (tester) async {
      await pumpFirstRun(tester);
      Iterable<double> scalesOf(Finder f) => tester
          .widgetList<Transform>(
            find.ancestor(of: f, matching: find.byType(Transform)),
          )
          .map((t) => t.transform.entry(0, 0));
      final title = find.text(introPreviewLessonTitle).last;
      expect(tester.widget<Text>(title).style!.fontSize, 30);
      expect(scalesOf(title), contains(closeTo(.747, .001)));
      final stem = find.text(introPreviewStem);
      expect(tester.widget<Text>(stem).style!.fontSize, 21);
      expect(scalesOf(stem), contains(closeTo(.747, .001)));
    });
  });

  group('lesson', () {
    testWidgets('wide column is left aligned at 172, 640 wide, title 38',
        (tester) async {
      await pumpFirstRun(tester, width: 1440, progressJson: _run('lesson'));
      final title = find.text('Fractions, Decimals, and Percentages');
      expect(tester.getRect(title).left, closeTo(172, 1));
      expect(tester.widget<Text>(title).style!.fontSize, 38);
      expect(tester.widget<Text>(title).style!.fontWeight, FontWeight.w700);
      expect(tester.getRect(find.text('Core Concept')).left, closeTo(172, 1));
      final answer = tester.getRect(_button('Answer 3 Questions'));
      expect(answer.height, 44);
      expect(answer.right, closeTo(172 + 640, 1));
      expect(find.text('Enter'), findsNothing);
      expectWidePlacement(tester);
    });

    testWidgets('the Read chip shows at the left once the lesson is read',
        (tester) async {
      await pumpFirstRun(tester, width: 1440, progressJson: _run('lesson'));
      expect(find.text('Read'), findsNothing);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Read'), findsNothing);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -3000),
      );
      await tester.pump(const Duration(milliseconds: 50));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Read'), findsOneWidget);
      expect(tester.getRect(find.text('Read')).left, lessThan(300));
    });

    testWidgets('phone header is 58 px with a 1 px divider', (tester) async {
      await pumpFirstRun(tester, progressJson: _run('lesson'));
      final header = find
          .ancestor(
            of: find.text('Try Pantas'),
            matching: find.byType(Container),
          )
          .first;
      expect(tester.getSize(header).height, 58);
      final decoration =
          tester.widget<Container>(header).decoration! as BoxDecoration;
      expect((decoration.border! as Border).bottom.width, 1);
    });
  });

  group('question', () {
    testWidgets('unchosen options dim to .4 after Check, phone and wide',
        (tester) async {
      for (final width in [390.0, 1440.0]) {
        await pumpFirstRun(tester, width: width, progressJson: _q1Right);
        for (final text in ['3.75%', '375%']) {
          expect(
            tester
                .widget<AnimatedOpacity>(
                  find
                      .ancestor(
                        of: find.text(text),
                        matching: find.byType(AnimatedOpacity),
                      )
                      .first,
                )
                .opacity,
            .4,
          );
        }
        expect(
          tester
              .widget<AnimatedOpacity>(
                find
                    .ancestor(
                      of: find.text('37.5%'),
                      matching: find.byType(AnimatedOpacity),
                    )
                    .first,
              )
              .opacity,
          1,
        );
      }
    });

    testWidgets('wide rows hold the mark in the circle: no letter, no trailing',
        (tester) async {
      await pumpFirstRun(tester, width: 1440, progressJson: _q2Wrong);
      // Q2: the pick (B) is wrong and A is right; both rows show a mark in
      // the circle and neither shows its letter.
      final rows = find.byType(WebAnswerOption);
      expect(
        find.descendant(of: rows, matching: find.byType(Icon)),
        findsNWidgets(2),
      );
      expect(
        find.descendant(of: rows.at(0), matching: find.text('A')),
        findsNothing,
      );
      expect(
        find.descendant(of: rows.at(1), matching: find.text('B')),
        findsNothing,
      );
    });

    testWidgets('wide explanation card is 488 wide with a lesson row',
        (tester) async {
      await pumpFirstRun(tester, width: 1440, progressJson: _q1Right);
      final card = find
          .ancestor(
            of: find.text('Correct answer'),
            matching: find.byType(Container),
          )
          .last;
      expect(tester.getSize(card).width, 488);
      // No rule inside the card: the reveal draws no top border.
      expect(
        find.descendant(
          of: card,
          matching: find.byWidgetPredicate(
            (w) =>
                w is DecoratedBox &&
                w.decoration is BoxDecoration &&
                (w.decoration as BoxDecoration).border != null,
          ),
        ),
        findsNothing,
      );
      expect(find.byIcon(Icons.chevron_right), findsNothing);
      expect(find.text('From the lesson'), findsOneWidget);
    });

    testWidgets('wide bottom bar is the compact pill: count, track, Next',
        (tester) async {
      await pumpFirstRun(tester, width: 1440, progressJson: _q1Right);
      final bar = find
          .ancestor(
            of: find.text('1 of 3'),
            matching: find.byType(AnimatedContainer),
          )
          .first;
      final size = tester.getSize(bar);
      // The bar wraps its parts (it was 717 wide); the board's is 282.
      expect(size.width, lessThan(450));
      expect(size.height, 64);
      expect(tester.getCenter(bar).dx, closeTo(720, 1));
      expect(
        tester.getRect(_button('Next')).left,
        greaterThan(tester.getRect(find.text('1 of 3')).right),
      );
      expectWidePlacement(tester);
    });

    testWidgets('a new step takes the focus', (tester) async {
      await pumpFirstRun(tester, progressJson: _run('lesson'));
      final before = FocusManager.instance.primaryFocus;
      // The button closes the lesson; the taller heading spacing (Nov 28)
      // puts it below the first screen, so scroll to it as a student would.
      await tester.ensureVisible(find.text('Answer 3 Questions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Answer 3 Questions'));
      await tester.pumpAndSettle();
      final after = FocusManager.instance.primaryFocus!;
      expect(after, isNot(same(before)));
      expect(
        find.descendant(
          of: find.byElementPredicate((e) => e == after.context),
          matching: find.text('What is 3/8 expressed as a percentage?'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the phone right arrow is dark ink, not teal', (tester) async {
      await pumpFirstRun(tester, progressJson: _q1Right);
      final button = tester.widget<PantasIconButton>(
        find.byWidgetPredicate(
          (w) => w is PantasIconButton && w.tooltip == 'Next question',
        ),
      );
      expect((button.icon! as Icon).color, const Color(0xFF1D1D1F));
    });
  });

  test('the intro previews equal the content source', () {
    final lesson = File(
      'content/lessons/mathematics/arithmetic-number-sense/'
      'fractions-decimals-percentages.md',
    ).readAsStringSync();
    expect(lesson, contains('title: "$introPreviewLessonTitle"'));
    final core = lesson.split('## Core Concept')[1].trim().split('\n').first;
    expect(core, introPreviewLessonLine);
    final doc = loadYaml(
      File(
        'content/questions/mathematics/arithmetic-number-sense/'
        'fractions-decimals-percentages.yaml',
      ).readAsStringSync(),
    ) as YamlMap;
    final q = (doc['questions'] as YamlList).first as YamlMap;
    expect(q['id'], endsWith('-0001'));
    expect(_plain(q['stem'] as String), introPreviewStem);
    final choices = [
      for (final c in q['choices'] as YamlList)
        _plain((c as YamlMap)['text'] as String),
    ];
    expect(choices.take(2).toList(), introPreviewChoices);
  });
}

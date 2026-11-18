import 'dart:convert';
import 'dart:ui' show CheckedState, SemanticsAction, SemanticsRole, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/components/figure_choice_tiles.dart';
import 'package:pantas/core/ui/components/question_choices.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/web/letter_shortcuts.dart';
import 'package:pantas/core/ui/web/web_key_focus.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart'
    show resetWebKeyboardFocus;
import 'package:pantas/core/ui/web/web_layout.dart';

import 'figure_choice_fixtures.dart';

/// What the host page shows: nothing picked, a pick, or a checked answer.
class _Page {
  const _Page({this.chosen, this.checked = false});
  final String? chosen;
  final bool checked;
}

/// A page that renders a question's choices as a quiz does and records the
/// picks.
class _Host extends StatelessWidget {
  const _Host({
    required this.question,
    required this.page,
    required this.picks,
  });

  final Question question;
  final ValueNotifier<_Page> page;
  final List<String> picks;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<_Page>(
        valueListenable: page,
        builder: (context, p, _) {
          final correct = question.correctChoice;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: QuestionChoices.build(
              question,
              chosenId: p.chosen,
              stateOf: (choice) => !p.checked
                  ? choice.id == p.chosen
                      ? ChoiceRowState.picked
                      : ChoiceRowState.plain
                  : choice.id == correct.id
                      ? ChoiceRowState.right
                      : choice.id == p.chosen
                          ? ChoiceRowState.wrong
                          : ChoiceRowState.dimmed,
              onPick: p.checked
                  ? null
                  : (choice) {
                      picks.add(choice.id);
                      page.value = _Page(chosen: choice.id);
                    },
            ),
          );
        },
      );
}

void main() {
  late List<String> picks;
  late ValueNotifier<_Page> page;

  setUp(() {
    picks = [];
    page = ValueNotifier(const _Page());
    resetWebKeyboardFocus();
  });
  tearDown(() => debugWebPlatformOverride = null);

  Future<void> pumpHost(
    WidgetTester tester,
    Question question, {
    double width = 358,
    bool wide = false,
    Brightness brightness = Brightness.light,
    bool reduced = false,
    Widget Function(Widget host)? wrap,
  }) async {
    debugWebPlatformOverride = wide;
    tester.view
      ..physicalSize = Size(wide ? 1440 : 390, 900)
      ..devicePixelRatio = 1;
    Widget host = _Host(question: question, page: page, picks: picks);
    host = wrap == null ? host : wrap(host);
    await tester.pumpWidget(
      MaterialApp(
        theme: brightness == Brightness.dark
            ? buildDarkTheme(web: wide)
            : buildLightTheme(web: wide),
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(wide ? 1440 : 390, 900),
            disableAnimations: reduced,
          ),
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(width: width, child: host),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder tile(String letter) => find.byKey(ValueKey('figure-choice-$letter'));

  group('the switch', () {
    test('tiles when the question asks and every choice can be drawn', () {
      expect(QuestionChoices.tiles(arrowQuestion()), isTrue);
      expect(QuestionChoices.tiles(oddOneOutQuestion()), isTrue);
    });

    test('text choices keep the rows', () {
      expect(
        QuestionChoices.tiles(arrowQuestion(kind: ChoiceKind.text)),
        isFalse,
      );
    });

    test('mixed data keeps the rows', () {
      final mixed = arrowQuestion(
        figures: [
          jsonEncode({'form': 'square'}),
          null,
          jsonEncode({'form': 'circle'}),
          jsonEncode({'form': 'square'}),
        ],
      );
      expect(QuestionChoices.tiles(mixed), isFalse);
    });

    test('bad data keeps the rows', () {
      expect(
        QuestionChoices.tiles(
          arrowQuestion(
            figures: [
              jsonEncode({'form': 'square'}),
              'not json',
              jsonEncode({'form': 'hexagon-ish'}),
              jsonEncode({'form': 'square'}),
            ],
          ),
        ),
        isFalse,
      );
    });

    test('a figure kind with no single-item painter keeps the rows', () {
      for (final kind in ['paper-fold', 'cube-net']) {
        expect(
          QuestionChoices.tiles(
            arrowQuestion(figureSpecJson: jsonEncode({'kind': kind})),
          ),
          isFalse,
          reason: kind,
        );
      }
    });

    test('no question figure means no tiles', () {
      expect(
        QuestionChoices.tiles(arrowQuestion().copyWith(figureSpecJson: null)),
        isFalse,
      );
    });

    test('the question figure hides only when tiles replace it', () {
      expect(QuestionChoices.figure(arrowQuestion()), isNotNull);
      expect(QuestionChoices.figure(oddOneOutQuestion()), isNull);
      // Falls back to rows: the figure is the only picture, so it stays.
      expect(
        QuestionChoices.figure(
          oddOneOutQuestion().copyWith(choiceKind: ChoiceKind.text),
        ),
        isNotNull,
      );
    });

    test('existing content is unchanged: the new fields default', () {
      final old = Question.fromJson({
        'id': 'q',
        'version': 1,
        'examIds': ['e'],
        'topicId': 't',
        'language': 'en',
        'stem': 's',
        'explanation': 'x',
        'choices': [
          {'id': 'c', 'label': 'A', 'text': 'one', 'isCorrect': true},
        ],
      });
      expect(old.choiceKind, ChoiceKind.text);
      expect(old.showQuestionFigure, isTrue);
      expect(old.choices.single.figureJson, isNull);
      expect(QuestionChoices.tiles(old), isFalse);
    });

    test('an unknown choice kind reads as text', () {
      final q = Question.fromJson({
        ...arrowQuestion().toJson(),
        'choiceKind': 'hologram',
      });
      expect(q.choiceKind, ChoiceKind.text);
    });
  });

  group('layout', () {
    testWidgets('a figure question draws tiles, not rows', (tester) async {
      await pumpHost(tester, arrowQuestion());
      expect(find.byType(FigureChoiceTile), findsNWidgets(4));
      expect(find.byType(ChoiceRow), findsNothing);
    });

    testWidgets('a text question draws rows, not tiles', (tester) async {
      await pumpHost(tester, arrowQuestion(kind: ChoiceKind.text));
      expect(find.byType(ChoiceRow), findsNWidgets(4));
      expect(find.byType(FigureChoiceTile), findsNothing);
    });

    testWidgets('phone: two columns, tile 174 in 358, gap 10', (tester) async {
      await pumpHost(tester, arrowQuestion());
      final a = tester.getRect(tile('A'));
      final b = tester.getRect(tile('B'));
      final c = tester.getRect(tile('C'));
      expect(a.size, const Size(174, 174));
      expect(b.left - a.right, 10);
      expect(b.top, a.top);
      expect(c.top - a.bottom, 10);
      expect(c.left, a.left);
    });

    testWidgets('wide: four in one row, tile 171 in 720, gap 12',
        (tester) async {
      await pumpHost(tester, arrowQuestion(), width: 720, wide: true);
      final rects = [for (final l in 'ABCD'.split('')) tester.getRect(tile(l))];
      expect(rects.first.size, const Size(171, 171));
      for (var i = 1; i < 4; i++) {
        expect(rects[i].top, rects.first.top);
        expect(rects[i].left - rects[i - 1].right, 12);
      }
    });

    testWidgets('wide: five choices reflow to five across, tile 134',
        (tester) async {
      await pumpHost(
        tester,
        arrowQuestion(count: 5),
        width: 720,
        wide: true,
      );
      expect(tester.getRect(tile('A')).width, closeTo(134, 0.5));
      expect(
        tester.getRect(tile('E')).top,
        tester.getRect(tile('A')).top,
      );
    });

    testWidgets('phone: five choices leave E alone on a third row',
        (tester) async {
      await pumpHost(tester, arrowQuestion(count: 5));
      expect(tester.getRect(tile('E')).left, tester.getRect(tile('A')).left);
      expect(
        tester.getRect(tile('E')).top,
        greaterThan(tester.getRect(tile('C')).top),
      );
    });

    testWidgets('the badge sits at the top left, the figure card fills below',
        (tester) async {
      await pumpHost(tester, arrowQuestion());
      final box = tester.getRect(tile('A'));
      final badge = tester.getRect(
        find.descendant(
          of: tile('A'),
          matching: find.byKey(const ValueKey('figure-choice-badge')),
        ),
      );
      expect(badge.left - box.left, 12);
      expect(badge.top - box.top, 12);
      expect(badge.width, 30);
      final card = tester.getRect(
        find.descendant(
          of: tile('A'),
          matching: find.byKey(const ValueKey('figure-choice-card')),
        ),
      );
      expect(card.left - box.left, 12);
      expect(card.top - badge.bottom, 8);
      expect(box.bottom - card.bottom, 12);
    });

    testWidgets('the figure sits on white in dark too', (tester) async {
      await pumpHost(tester, arrowQuestion(), brightness: Brightness.dark);
      final card = tester.widget<DecoratedBox>(
        find.descendant(
          of: tile('A'),
          matching: find.byKey(const ValueKey('figure-choice-card')),
        ),
      );
      expect(
        (card.decoration as BoxDecoration).color,
        PantasColors.dark.figureBg,
      );
      expect(PantasColors.dark.figureBg, PantasColors.light.figureBg);
    });
  });

  group('names and roles', () {
    testWidgets('a radio group named by the stem, each tile a radio',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpHost(tester, arrowQuestion());
      final group = tester.getSemantics(find.byType(FigureChoiceGroup));
      expect(group.role, SemanticsRole.radioGroup);
      expect(group.label, 'Which figure comes next?');
      for (final (letter, text) in [
        ('A', 'arrow pointing lower-right'),
        ('B', 'arrow pointing down'),
        ('C', 'arrow pointing lower-left'),
        ('D', 'arrow pointing up'),
      ]) {
        final node = tester.getSemantics(tile(letter));
        expect(node.label, '$letter, $text');
        expect(node.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
        expect(node.flagsCollection.isChecked, CheckedState.isFalse);
      }
      handle.dispose();
    });

    testWidgets('a picked tile is checked', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpHost(tester, arrowQuestion());
      await tester.tap(tile('C'));
      await tester.pump();
      expect(picks, ['choice-2']);
      expect(
        tester.getSemantics(tile('C')).flagsCollection.isChecked,
        CheckedState.isTrue,
      );
      expect(
        tester.getSemantics(tile('A')).flagsCollection.isChecked,
        CheckedState.isFalse,
      );
      handle.dispose();
    });

    testWidgets('after the reveal the names carry the result', (tester) async {
      final handle = tester.ensureSemantics();
      page.value = const _Page(chosen: 'choice-0', checked: true);
      await pumpHost(tester, arrowQuestion());
      expect(
        tester.getSemantics(tile('A')).label,
        'A, arrow pointing lower-right, your answer, wrong',
      );
      expect(
        tester.getSemantics(tile('B')).label,
        'B, arrow pointing down, correct answer',
      );
      expect(
        tester.getSemantics(tile('C')).label,
        'C, arrow pointing lower-left',
      );
      expect(
        tester.getSemantics(tile('A')).flagsCollection.isChecked,
        CheckedState.isTrue,
      );
      expect(
        tester.getSemantics(tile('B')).flagsCollection.isChecked,
        CheckedState.isFalse,
      );
      handle.dispose();
    });

    testWidgets('a right pick reads as correct and checked', (tester) async {
      final handle = tester.ensureSemantics();
      page.value = const _Page(chosen: 'choice-1', checked: true);
      await pumpHost(tester, arrowQuestion());
      final b = tester.getSemantics(tile('B'));
      expect(b.label, 'B, arrow pointing down, correct answer');
      expect(b.flagsCollection.isChecked, CheckedState.isTrue);
      handle.dispose();
    });

    testWidgets('the figure inside a tile adds nothing to the semantics',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpHost(tester, arrowQuestion());
      final node = tester.getSemantics(tile('A'));
      var children = 0;
      node.visitChildren((_) {
        children++;
        return true;
      });
      expect(children, 0);
      handle.dispose();
    });

    testWidgets('after the reveal a tile is read only, never disabled',
        (tester) async {
      final handle = tester.ensureSemantics();
      page.value = const _Page(chosen: 'choice-0', checked: true);
      await pumpHost(tester, arrowQuestion());
      for (final letter in 'ABCD'.split('')) {
        final node = tester.getSemantics(tile(letter));
        expect(node.flagsCollection.isEnabled, Tristate.isTrue, reason: letter);
        expect(
          node.flagsCollection.isFocused,
          isNot(Tristate.none),
          reason: letter,
        );
        expect(
          node.getSemanticsData().hasAction(SemanticsAction.tap),
          isFalse,
          reason: letter,
        );
      }
      handle.dispose();
    });
  });

  group('keys', () {
    testWidgets('Tab reaches the first tile only', (tester) async {
      await pumpHost(tester, arrowQuestion(), wide: true, width: 720);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focusedLetter(tester), 'A');
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      // No other tile is a tab stop, so Tab comes back to the first.
      expect(_focusedLetter(tester), 'A');
    });

    testWidgets('Tab reaches the picked tile when one is picked',
        (tester) async {
      page.value = const _Page(chosen: 'choice-2');
      await pumpHost(tester, arrowQuestion(), wide: true, width: 720);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focusedLetter(tester), 'C');
    });

    testWidgets('before the reveal an arrow moves focus and picks',
        (tester) async {
      await pumpHost(tester, arrowQuestion(), wide: true, width: 720);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(_focusedLetter(tester), 'B');
      expect(picks, ['choice-1']);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(_focusedLetter(tester), 'C');
      expect(picks, ['choice-1', 'choice-2']);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(_focusedLetter(tester), 'B');
    });

    testWidgets('after the reveal an arrow moves focus and picks nothing',
        (tester) async {
      page.value = const _Page(chosen: 'choice-0', checked: true);
      await pumpHost(tester, arrowQuestion(), wide: true, width: 720);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focusedLetter(tester), 'A');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(_focusedLetter(tester), 'B');
      expect(picks, isEmpty);
    });

    testWidgets('after the reveal a tap picks nothing', (tester) async {
      page.value = const _Page(chosen: 'choice-0', checked: true);
      await pumpHost(tester, arrowQuestion());
      await tester.tap(tile('C'));
      await tester.pump();
      expect(picks, isEmpty);
    });

    testWidgets('Enter on a picked tile checks, on an unpicked tile picks',
        (tester) async {
      var checks = 0;
      await pumpHost(
        tester,
        arrowQuestion(),
        wide: true,
        width: 720,
        wrap: (host) => KeyFocusKeeper(
          onKeyEvent: enterKeyHandler(
            () => checks++,
            keepsEnter: focusedAnswerIsPicked,
          ),
          child: host,
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(picks, ['choice-0']);
      expect(checks, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(checks, 1);
    });

    testWidgets('after the reveal Enter on a focused tile goes to the page',
        (tester) async {
      var next = 0;
      page.value = const _Page(chosen: 'choice-0', checked: true);
      await pumpHost(
        tester,
        arrowQuestion(),
        wide: true,
        width: 720,
        wrap: (host) => KeyFocusKeeper(
          onKeyEvent: enterKeyHandler(
            () => next++,
            keepsEnter: focusedAnswerIsPicked,
          ),
          child: host,
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(next, 1);
      expect(picks, isEmpty);
    });

    Future<void> pumpWithLetters(
      WidgetTester tester, {
      bool? enabled,
    }) async {
      await pumpHost(
        tester,
        arrowQuestion(),
        wide: true,
        width: 720,
        wrap: (host) {
          Widget body = Column(
            children: [
              LetterShortcuts(
                once: {
                  for (final (i, key) in ['a', 'b', 'c', 'd'].indexed)
                    key: () => picks.add('letter-$i'),
                },
                child: KeyFocusKeeper(child: host),
              ),
              const TextField(key: ValueKey('outside')),
            ],
          );
          if (enabled != null) {
            body = LetterShortcutsScope(enabled: enabled, child: body);
          }
          return body;
        },
      );
    }

    testWidgets('a letter key picks with focus in the question region',
        (tester) async {
      await pumpWithLetters(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      expect(picks, ['letter-2']);
    });

    testWidgets('a letter key does nothing with the setting off',
        (tester) async {
      await pumpWithLetters(tester, enabled: false);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      expect(picks, isEmpty);
    });

    testWidgets('a letter key does nothing with focus outside the region',
        (tester) async {
      await pumpWithLetters(tester);
      await tester.tap(find.byKey(const ValueKey('outside')));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      expect(picks, isEmpty);
    });
  });

  group('states', () {
    testWidgets('every letter shows in every state', (tester) async {
      for (final p in const [
        _Page(),
        _Page(chosen: 'choice-2'),
        _Page(chosen: 'choice-1', checked: true),
        _Page(chosen: 'choice-0', checked: true),
      ]) {
        page.value = p;
        await pumpHost(tester, arrowQuestion());
        await tester.pump(const Duration(seconds: 1));
        for (final letter in 'ABCD'.split('')) {
          expect(
            find.descendant(of: tile(letter), matching: find.text(letter)),
            findsOneWidget,
            reason: '$letter in ${p.chosen} ${p.checked}',
          );
        }
      }
    });

    testWidgets('the marks sit at the top right: a check and a cross',
        (tester) async {
      page.value = const _Page(chosen: 'choice-0', checked: true);
      await pumpHost(tester, arrowQuestion(), reduced: true);
      await tester.pump();
      final a = tester.getRect(tile('A'));
      final cross = tester.getRect(
        find.descendant(
          of: tile('A'),
          matching: find.byIcon(PantasIcons.close),
        ),
      );
      expect(a.right - cross.right, 12);
      expect(cross.top - a.top, 12);
      expect(cross.size, const Size(22, 22));
      final b = tester.getRect(tile('B'));
      final check = tester.getRect(
        find.descendant(
          of: tile('B'),
          matching: find.byIcon(PantasIcons.check),
        ),
      );
      expect(b.right - check.right, 12);
      expect(check.top - b.top, 12);
      expect(
        find.descendant(of: tile('C'), matching: find.byType(Icon)),
        findsNothing,
      );
    });

    testWidgets('figures are never dimmed and tiles use no opacity',
        (tester) async {
      page.value = const _Page(chosen: 'choice-0', checked: true);
      await pumpHost(tester, arrowQuestion(), reduced: true);
      expect(
        find.descendant(
          of: find.byType(FigureChoiceGroup),
          matching: find.byWidgetPredicate(
            (w) => w is Opacity || w is AnimatedOpacity || w is FadeTransition,
          ),
        ),
        findsNothing,
      );
      const c = PantasColors.light;
      for (final letter in 'ABCD'.split('')) {
        final card = tester.widget<DecoratedBox>(
          find.descendant(
            of: tile(letter),
            matching: find.byKey(const ValueKey('figure-choice-card')),
          ),
        );
        expect((card.decoration as BoxDecoration).color, c.figureBg);
      }
    });

    testWidgets('a tile that is neither picked nor right keeps the rest look',
        (tester) async {
      page.value = const _Page(chosen: 'choice-0', checked: true);
      await pumpHost(tester, arrowQuestion(), reduced: true);
      const c = PantasColors.light;
      BoxDecoration surface(String letter) {
        final container = tester.widget<AnimatedContainer>(
          find
              .descendant(
                of: tile(letter),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        return container.decoration! as BoxDecoration;
      }

      expect(surface('C').color, c.surfaceCard);
      expect(surface('D').color, c.surfaceCard);
      expect(surface('A').color, c.dangerTint);
      expect(surface('B').color, c.accentTint);
      // Only the badge ring turns to divider.
      final badge = tester.widget<AnimatedContainer>(
        find.descendant(
          of: tile('C'),
          matching: find.byKey(const ValueKey('figure-choice-badge')),
        ),
      );
      final border = (badge.decoration! as BoxDecoration).border! as Border;
      expect(border.top.color, c.divider);
    });

    testWidgets('a wrong pick shows the right tile 150 ms later',
        (tester) async {
      await pumpHost(tester, arrowQuestion());
      page.value = const _Page(chosen: 'choice-0');
      await tester.pump();
      page.value = const _Page(chosen: 'choice-0', checked: true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      expect(
        find.descendant(
          of: tile('A'),
          matching: find.byIcon(PantasIcons.close),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: tile('B'),
          matching: find.byIcon(PantasIcons.check),
        ),
        findsNothing,
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        find.descendant(
          of: tile('B'),
          matching: find.byIcon(PantasIcons.check),
        ),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('reduced motion shows both end states at once', (tester) async {
      await pumpHost(tester, arrowQuestion(), reduced: true);
      page.value = const _Page(chosen: 'choice-0');
      await tester.pump();
      page.value = const _Page(chosen: 'choice-0', checked: true);
      await tester.pump();
      expect(
        find.descendant(
          of: tile('A'),
          matching: find.byIcon(PantasIcons.close),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: tile('B'),
          matching: find.byIcon(PantasIcons.check),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Transform>(
              find.descendant(
                of: tile('B'),
                matching: find.byKey(const ValueKey('figure-choice-mark')),
              ),
            )
            .transform
            .getMaxScaleOnAxis(),
        1,
      );
    });

    testWidgets('a revisit in review has no motion', (tester) async {
      page.value = const _Page(chosen: 'choice-2', checked: true);
      await pumpHost(tester, arrowQuestion());
      // No time passes: the marks are already at rest.
      expect(
        find.descendant(
          of: tile('B'),
          matching: find.byIcon(PantasIcons.check),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Transform>(
              find.descendant(
                of: tile('B'),
                matching: find.byKey(const ValueKey('figure-choice-mark')),
              ),
            )
            .transform
            .getMaxScaleOnAxis(),
        1,
      );
    });

    testWidgets('the odd-one-out tiles draw from shape-row shapes',
        (tester) async {
      await pumpHost(tester, oddOneOutQuestion());
      expect(find.byType(FigureChoiceTile), findsNWidgets(4));
    });

    testWidgets('keyboard focus draws an outline on wide only', (tester) async {
      await pumpHost(tester, arrowQuestion(), wide: true, width: 720);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(find.byKey(const ValueKey('figure-choice-focus')), findsOneWidget);
      resetWebKeyboardFocus();
      await pumpHost(tester, arrowQuestion());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(find.byKey(const ValueKey('figure-choice-focus')), findsNothing);
    });
  });
}

String? _focusedLetter(WidgetTester tester) {
  final context = FocusManager.instance.primaryFocus?.context;
  if (context == null) return null;
  final tile = context.findAncestorWidgetOfExactType<FigureChoiceTile>();
  return tile?.letter;
}

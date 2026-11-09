// QuestionNavigator (design system 4.0): six columns of 36 px chips, roving
// focus with two-dimensional arrows, grid semantics, hover scale, and no
// right or wrong tint.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/new_design/question_grid_sheet.dart';
import 'package:pantas/core/ui/components/question_navigator_chip.dart';
import 'package:pantas/core/ui/components/question_navigator_grid.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

import '../../../helpers/ds_matrix.dart';

String? _focused() => FocusManager.instance.primaryFocus?.debugLabel;

Future<void> _pump(
  WidgetTester tester,
  List<NavigatorQuestion> questions, {
  ValueChanged<int>? onSelected,
  double width = 390,
  double scale = 1,
  bool dark = false,
}) async {
  await pumpDs(
    tester,
    DsCell(width, scale, dark: dark),
    QuestionNavigatorGrid(
      questions: questions,
      onSelected: onSelected ?? (_) {},
    ),
    scroll: false,
  );
}

List<NavigatorQuestion> _fourteen({
  int current = 3,
  Set<int> locked = const {},
  Set<int> flagged = const {},
}) =>
    [
      for (var i = 1; i <= 14; i++)
        NavigatorQuestion(
          number: i,
          answered: i < current + 1,
          current: i == current + 1,
          flagged: flagged.contains(i),
          enabled: !locked.contains(i),
        ),
    ];

void main() {
  testWidgets('six columns of 36 px chips, 8 apart, each in a 44 px area',
      (tester) async {
    await _pump(tester, _fourteen());
    Offset at(int n) =>
        tester.getTopLeft(find.byType(QuestionNavigatorChip).at(n));
    for (var n = 1; n < 6; n++) {
      expect(at(n).dy, at(0).dy);
      expect(at(n).dx - at(n - 1).dx, closeTo(44, .01));
    }
    expect(at(6).dy - at(0).dy, closeTo(44, .01));
    expect(at(6).dx, at(0).dx);
    expect(
      tester.getSize(find.byType(QuestionNavigatorChip).first),
      const Size.square(36),
    );
    // The tap area around a chip is 44 square.
    expect(
      tester.getSize(find.byKey(const ValueKey('navigator-cell-0'))),
      const Size.square(44),
    );
    // A tap 4 px outside the chip, inside its area, opens it.
    final picked = <int>[];
    await _pump(tester, _fourteen(), onSelected: picked.add);
    final chip = tester.getTopLeft(find.byType(QuestionNavigatorChip).first);
    await tester.tapAt(chip + const Offset(-3, 18));
    expect(picked, [1]);
  });

  testWidgets('Tab reaches the current chip only; arrows move; Enter opens',
      (tester) async {
    final picked = <int>[];
    await _pump(tester, _fourteen(), onSelected: picked.add);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    expect(_focused(), 'Question 4');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    expect(_focused(), 'Question 5');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    expect(_focused(), 'Question 3');
    // Down and up move one row of six.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(_focused(), 'Question 9');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    expect(_focused(), 'Question 3');
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    expect(_focused(), 'Question 14');
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    expect(_focused(), 'Question 1');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(picked, [1]);
    // The grid is one Tab stop: Tab comes back to the current chip, not to
    // the next chip.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    expect(_focused(), 'Question 4');
  });

  testWidgets('arrows skip locked chips; Home and End take open chips',
      (tester) async {
    await _pump(
      tester,
      _fourteen(locked: {1, 2, 5, 6, 7, 12, 13, 14}),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    expect(_focused(), 'Question 4');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    expect(_focused(), 'Question 8');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    expect(_focused(), 'Question 3');
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    expect(_focused(), 'Question 3');
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    expect(_focused(), 'Question 11');
    // Past the last open chip the focus stays.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    expect(_focused(), 'Question 11');
    // There is no row below the last one.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(_focused(), 'Question 11');
  });

  testWidgets('grid semantics and chip names carry the state', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester, _fourteen(flagged: {2}, locked: {14}));
    expect(
      find.bySemanticsLabel('Question 2, answered, flagged'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Question 4, current, blank'), findsOneWidget);
    expect(find.bySemanticsLabel('Question 7, blank'), findsOneWidget);
    expect(find.bySemanticsLabel('Question 14, locked'), findsOneWidget);
    final roles = <SemanticsRole>{};
    void walk(SemanticsNode node) {
      roles.add(node.getSemanticsData().role);
      node.visitChildren((child) {
        walk(child);
        return true;
      });
    }

    walk(tester.getSemantics(find.byType(QuestionNavigatorGrid)));
    expect(
      roles,
      containsAll(
        [SemanticsRole.table, SemanticsRole.row, SemanticsRole.cell],
      ),
    );
    semantics.dispose();
  });

  testWidgets('hover scales an open chip to 1.08', (tester) async {
    await _pump(tester, _fourteen());
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    final chip = find.byType(QuestionNavigatorChip).at(1);
    await mouse.moveTo(tester.getCenter(chip));
    await tester.pump(const Duration(milliseconds: 400));
    final scale = tester.widget<AnimatedScale>(
      find.descendant(of: chip, matching: find.byType(AnimatedScale)),
    );
    expect(scale.scale, 1.08);
    await mouse.moveTo(const Offset(2, 2));
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      tester
          .widget<AnimatedScale>(
            find.descendant(of: chip, matching: find.byType(AnimatedScale)),
          )
          .scale,
      1,
    );
  });

  for (final dark in [false, true]) {
    testWidgets('a right and a wrong answer look the same (dark=$dark)',
        (tester) async {
      await pumpDs(
        tester,
        DsCell(390, 1, dark: dark),
        QuestionGridSheet(
          page: const Text('Page'),
          open: true,
          onDismiss: () {},
          onSelected: (_) {},
          parts: const [
            QuestionGridPart(
              title: '',
              questions: [
                GridQuestion(number: 1, state: GridQuestionState.right),
                GridQuestion(number: 2, state: GridQuestionState.wrong),
                GridQuestion(number: 3, state: GridQuestionState.answered),
                GridQuestion(
                  number: 4,
                  state: GridQuestionState.unreached,
                  current: true,
                ),
              ],
            ),
          ],
        ),
        scroll: false,
      );
      ShapeDecoration fill(int number) => tester
          .widget<DecoratedBox>(
            find.descendant(
              of: find.byKey(ValueKey('grid-question-0-$number')),
              matching: find.byKey(const ValueKey('question-chip-fill')),
            ),
          )
          .decoration as ShapeDecoration;
      expect(fill(1).color, fill(2).color);
      expect(fill(1).color, fill(3).color);
      expect(fill(1).shape, fill(2).shape);
      expect(
        fill(1).color,
        tester.element(find.byType(Scaffold)).colors.divider,
      );
    });
  }
}

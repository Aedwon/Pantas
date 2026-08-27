import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pennant_mark.dart';
import 'package:pantas/core/ui/components/question_grid_sheet.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

void main() {
  Widget harness({
    required List<GridCell> cells,
    int columns = 5,
    ValueChanged<int>? onTap,
  }) {
    return MaterialApp(
      theme: buildLightTheme(),
      home: Scaffold(
        body: QuestionGridSheet(
          cells: cells,
          columns: columns,
          onTap: onTap ?? (_) {},
        ),
      ),
    );
  }

  List<GridCell> plainCells(int count) => [
        for (var i = 1; i <= count; i += 1) GridCell(number: i),
      ];

  testWidgets('a quiz grid is five columns', (tester) async {
    await tester.pumpWidget(harness(cells: plainCells(10)));

    expect(find.byType(GridCellView), findsNWidgets(10));
    expect(find.byType(GridRow), findsNWidgets(2));
  });

  testWidgets('a mock grid is six columns', (tester) async {
    await tester.pumpWidget(harness(cells: plainCells(12), columns: 6));

    expect(find.byType(GridRow), findsNWidgets(2));
  });

  testWidgets('every cell reserves the caret slot', (tester) async {
    await tester.pumpWidget(
      harness(
        cells: [
          GridCell(number: 1, isCurrent: true),
          GridCell(number: 2),
        ],
      ),
    );

    final first = tester.getSize(find.byType(GridCellView).first);
    final second = tester.getSize(find.byType(GridCellView).last);
    expect(first.height, second.height);
  });

  testWidgets('a right answer marks board, a wrong one rust', (tester) async {
    await tester.pumpWidget(
      harness(
        cells: [
          GridCell(number: 1, mark: GridCellMark.correct),
          GridCell(number: 2, mark: GridCellMark.wrong),
        ],
      ),
    );

    expect(find.text('✓'), findsOneWidget);
    expect(find.text('✕'), findsOneWidget);
  });

  testWidgets('flags are not shown in a quiz grid', (tester) async {
    await tester.pumpWidget(
      harness(
        cells: [
          GridCell(number: 1, mark: GridCellMark.correct, isFlagged: true),
        ],
      ),
    );

    expect(find.byType(PennantMark), findsNothing);
  });

  testWidgets('a mock cell shows the dot and the pennant together',
      (tester) async {
    await tester.pumpWidget(
      harness(
        columns: 6,
        cells: [
          GridCell(number: 1, mark: GridCellMark.answered, isFlagged: true),
        ],
      ),
    );

    expect(find.byKey(const ValueKey('mock-cell-dot')), findsOneWidget);
    expect(find.byType(PennantMark), findsOneWidget);
  });

  testWidgets('a mock cell never shows an outcome', (tester) async {
    await tester.pumpWidget(
      harness(
        columns: 6,
        cells: [
          GridCell(number: 1, mark: GridCellMark.answered),
          GridCell(number: 2),
        ],
      ),
    );

    expect(find.text('✓'), findsNothing);
    expect(find.text('✕'), findsNothing);
  });

  testWidgets('tapping a cell reports its number', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(harness(cells: plainCells(10), onTap: taps.add));

    await tester.tap(find.text('7'));
    expect(taps, [7]);
  });

  testWidgets('cell semantics include progress, flags, and availability',
      (tester) async {
    await tester.pumpWidget(
      harness(
        columns: 6,
        cells: [
          GridCell(
            number: 1,
            mark: GridCellMark.answered,
            isFlagged: true,
            isCurrent: true,
          ),
          GridCell(number: 2, isEnabled: false),
        ],
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Question 1')),
      matchesSemantics(
        label: 'Question 1',
        value: 'Current, Answered, Flagged',
        hasSelectedState: true,
        isSelected: true,
        hasEnabledState: true,
        isEnabled: true,
        isButton: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Question 2')),
      matchesSemantics(
        label: 'Question 2',
        value: 'Unanswered, Unavailable',
        hasSelectedState: true,
        hasEnabledState: true,
      ),
    );
  });

  testWidgets('the grid has no vertical rules', (tester) async {
    await tester.pumpWidget(harness(cells: plainCells(10)));

    for (final container in tester.widgetList<Container>(
      find.descendant(
        of: find.byType(QuestionGridSheet),
        matching: find.byType(Container),
      ),
    )) {
      final decoration = container.decoration;
      if (decoration is! BoxDecoration) continue;
      final border = decoration.border;
      if (border is! Border) continue;
      expect(border.left, BorderSide.none);
      expect(border.right, BorderSide.none);
    }
  });
}

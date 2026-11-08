import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/data_table.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

import '../../../helpers/ds_matrix.dart';

void main() {
  const columns = [
    PantasTableColumn('Mock exam', sortable: true),
    PantasTableColumn('Date'),
    PantasTableColumn('Score', numeric: true, sortable: true),
    PantasTableColumn('Accuracy', numeric: true),
  ];
  final rows = <List<String?>>[
    ['Mock 3', 'Oct 14, 2026', '171', '68.5%'],
    ['Mock 2', 'Sep 30, 2026', '160', null],
    ['Mock 1', 'Sep 12, 2026', '142', '55%'],
  ];

  dsMatrix(
    'data table: caption, pinned first column, ink rows, no data',
    (context) => SizedBox(
      width: 358,
      child: PantasDataTable(
        caption: 'Past mocks',
        columns: columns,
        rows: rows,
        sortColumn: 2,
        sortAscending: false,
        onSort: (_) {},
      ),
    ),
    check: (tester, cell) async {
      final palette = cell.dark ? PantasColors.dark : PantasColors.light;
      expect(find.text('Past mocks'), findsOneWidget);
      expect(find.text('MOCK EXAM'), findsOneWidget);
      // A cell with no data reads "No data", never "0%".
      final empty = tester.widget<Text>(find.text('No data'));
      expect(empty.style!.color, palette.textSecondary);
      expect(find.text('0%'), findsNothing);
      // Body rows are at least 44 high.
      expect(tester.getSize(find.text('Mock 3')).height, greaterThan(0));
      final pinned = find.byKey(const ValueKey('data-table-pinned'));
      expect(pinned, findsOneWidget);
      final firstRow = tester.getRect(find.text('Mock 3'));
      final secondRow = tester.getRect(find.text('Mock 2'));
      expect(secondRow.top - firstRow.top, greaterThanOrEqualTo(44));
      // The card is surface-card with radius 18.
      final card = tester.widget<Container>(
        find.byKey(const ValueKey('data-table')),
      );
      expect((card.decoration! as BoxDecoration).color, palette.surfaceCard);
    },
  );

  testWidgets('a sort button reports its column', (tester) async {
    final sorted = <int>[];
    await pumpDs(
      tester,
      dsCells.first,
      SizedBox(
        width: 358,
        child: PantasDataTable(
          columns: columns,
          rows: rows,
          onSort: sorted.add,
        ),
      ),
      scroll: false,
    );
    await tester.tap(find.text('MOCK EXAM'));
    expect(sorted, [0]);
    // A plain header holds no sort button.
    await tester.tap(find.text('DATE'), warnIfMissed: false);
    expect(sorted, [0]);
  });

  testWidgets('the other columns scroll sideways under the pinned one',
      (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      SizedBox(
        width: 358,
        child: PantasDataTable(columns: columns, rows: rows),
      ),
    );
    final before = tester.getTopLeft(find.text('Mock 3')).dx;
    await tester.drag(
      find.descendant(
        of: find.byType(PantasDataTable),
        matching: find.byType(SingleChildScrollView),
      ),
      const Offset(-120, 0),
    );
    await tester.pump();
    expect(tester.getTopLeft(find.text('Mock 3')).dx, before);
  });
}

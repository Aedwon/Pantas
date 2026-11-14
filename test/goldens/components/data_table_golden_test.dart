import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/data_table.dart';

import '../golden_harness.dart';

const _columns = [
  PantasTableColumn('Mock', sortable: true),
  PantasTableColumn('Date', sortable: true),
  PantasTableColumn('Score', numeric: true, sortable: true),
];

const _rows = <List<Object?>>[
  ['Mock 1', 'Nov 2', '72%'],
  ['Mock 2', 'Nov 9', '81%'],
  ['Mock 3', 'Nov 16', null],
];

PantasDataTable _table({
  int? sortColumn,
  bool ascending = true,
  List<List<Object?>> rows = _rows,
}) =>
    PantasDataTable(
      caption: 'Past mocks',
      columns: _columns,
      rows: rows,
      sortColumn: sortColumn,
      sortAscending: ascending,
      onSort: (_) {},
    );

void main() {
  goldenSheet(
    'data_table',
    [
      GoldenState('Rest', (_) => _table(), width: 420),
      GoldenState(
        'Sorted ascending',
        (_) => _table(sortColumn: 2),
        width: 420,
      ),
      GoldenState(
        'Sorted descending',
        (_) => _table(sortColumn: 2, ascending: false),
        width: 420,
      ),
      GoldenState(
        'Row hover',
        (_) => PantasDataTable(
          caption: 'Past mocks',
          columns: _columns,
          rows: _rows,
          onRowTap: (_) {},
        ),
        action: GoldenAction.hover,
        at: const Alignment(0, 0.2),
        width: 420,
      ),
      GoldenState(
        'Selected row',
        (_) => PantasDataTable(
          caption: 'Past mocks',
          columns: _columns,
          rows: _rows,
          onRowTap: (_) {},
          selectedRow: 1,
        ),
        width: 420,
      ),
      GoldenState(
        'Focus',
        (_) => PantasDataTable(
          caption: 'Past mocks',
          columns: _columns,
          rows: _rows,
          onRowTap: (_) {},
        ),
        action: GoldenAction.focus,
        width: 420,
      ),
    ],
    cellWidth: 420,
    columns: 2,
    web: true,
  );
}

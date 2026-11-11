import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/data_table.dart';
import 'package:pantas/core/ui/components/pro_tag.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

import '../../../helpers/ds_matrix.dart';

void main() {
  widgetCellTests();
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

class _Sortable extends StatefulWidget {
  const _Sortable();
  @override
  State<_Sortable> createState() => _SortableState();
}

class _SortableState extends State<_Sortable> {
  bool _ascending = true;
  @override
  Widget build(BuildContext context) {
    final names = ['Beta', 'Alpha']
      ..sort((a, b) => _ascending ? a.compareTo(b) : b.compareTo(a));
    return SizedBox(
      width: 358,
      child: PantasDataTable(
        columns: const [
          PantasTableColumn('Name', sortable: true),
          PantasTableColumn('Plan'),
        ],
        rows: [
          for (final name in names)
            [
              name,
              const PantasTableCell.widget(
                ProMark(),
                width: 40,
                semanticLabel: 'Pro',
              ),
            ],
        ],
        sortColumn: 0,
        sortAscending: _ascending,
        onSort: (_) => setState(() => _ascending = !_ascending),
      ),
    );
  }
}

void widgetCellTests() {
  group('widget cells', () {
    testWidgets('a widget cell renders beside text cells', (tester) async {
      await pumpDs(
        tester,
        dsCells.first,
        SizedBox(
          width: 358,
          child: PantasDataTable(
            columns: const [
              PantasTableColumn('Name'),
              PantasTableColumn('Plan'),
            ],
            rows: const [
              [
                'Alpha',
                PantasTableCell.widget(
                  ProMark(),
                  width: 40,
                  semanticLabel: 'Pro',
                ),
              ],
              ['Beta', null],
            ],
          ),
        ),
      );
      expect(find.byType(ProMark), findsOneWidget);
      expect(find.text('Pro'), findsOneWidget);
      // The text cell with no data still reads "No data".
      expect(find.text('No data'), findsOneWidget);
    });

    dsMatrix(
      'a long first-column name wraps and leaves room for the other columns',
      (context) => SizedBox(
        width: 358,
        child: PantasDataTable(
          columns: const [
            PantasTableColumn('Section'),
            PantasTableColumn('Items', numeric: true),
          ],
          rows: const [
            ['Language Proficiency (English and Filipino)', '60'],
            ['Math', '40'],
          ],
        ),
      ),
      check: (tester, cell) async {
        final pinned = tester.getSize(
          find.byKey(const ValueKey('data-table-pinned')),
        );
        expect(pinned.width, lessThan(358 * .7));
        // The count stays inside the table (it scrolls at large text).
        if (cell.scale == 1) {
          expect(
            tester.getTopRight(find.text('60')).dx,
            lessThanOrEqualTo(358),
          );
        }
        // The wrapped row is taller than the 44 minimum.
        expect(
          tester.getTopLeft(find.text('Math')).dy -
              tester
                  .getTopLeft(
                    find.textContaining('Language Proficiency'),
                  )
                  .dy,
          greaterThan(44),
        );
      },
    );

    testWidgets('a text cell can be bold and indented', (tester) async {
      await pumpDs(
        tester,
        dsCells.first,
        SizedBox(
          width: 358,
          child: PantasDataTable(
            columns: const [PantasTableColumn('Name')],
            rows: const [
              [PantasTableCell.text('Mathematics', bold: true)],
              [PantasTableCell.text('Geometry', indent: 20)],
              ['Plain'],
            ],
          ),
        ),
      );
      expect(
        tester.widget<Text>(find.text('Mathematics')).style!.fontWeight,
        FontWeight.w600,
      );
      expect(
        tester.getTopLeft(find.text('Geometry')).dx -
            tester.getTopLeft(find.text('Plain')).dx,
        20,
      );
    });

    testWidgets('sorting reorders rows with widget cells', (tester) async {
      await pumpDs(tester, dsCells.first, const _Sortable());
      double top(String name) => tester.getTopLeft(find.text(name)).dy;
      expect(top('Alpha'), lessThan(top('Beta')));
      await tester.tap(find.text('NAME'));
      await tester.pumpAndSettle();
      expect(top('Beta'), lessThan(top('Alpha')));
      expect(find.byType(ProMark), findsNWidgets(2));
    });

    testWidgets('a row tap and Enter on the first cell report the row',
        (tester) async {
      final tapped = <int>[];
      await pumpDs(
        tester,
        dsCells.first,
        SizedBox(
          width: 358,
          child: PantasDataTable(
            columns: const [
              PantasTableColumn('Name'),
              PantasTableColumn('Score', numeric: true),
            ],
            rows: const [
              ['Alpha', '50%'],
              ['Beta', '60%'],
            ],
            onRowTap: tapped.add,
            selectedRow: 1,
          ),
        ),
      );
      await tester.tap(find.text('60%'));
      expect(tapped, [1]);
      await tester.tap(find.text('Alpha'));
      expect(tapped, [1, 0]);
      // Tab reaches the first cell of the first row; Enter activates it.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(tapped.last, 0);
    });

    group('expandable rows', () {
      Future<void> pumpGroup(
        WidgetTester tester, {
        required bool open,
        bool still = false,
      }) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildLightTheme(web: true),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: still),
              child: child!,
            ),
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 700,
                  child: PantasDataTable(
                    columns: const [
                      PantasTableColumn('Subject'),
                      PantasTableColumn('Score', numeric: true),
                    ],
                    rows: const [
                      [
                        PantasTableCell.text(
                          'Language Proficiency (English and Filipino) '
                          'with a very long name that must wrap',
                          subtitle: '2 topics',
                        ),
                        '60%',
                      ],
                      ['Math', '70%'],
                    ],
                    childRows: const {
                      0: [
                        [PantasTableCell.text('Grammar', indent: 20), '55%'],
                      ],
                    },
                    expandedRows: open ? {0} : {},
                    onRowTap: (_) {},
                    onChildTap: (_, __) {},
                  ),
                ),
              ),
            ),
          ),
        );
      }

      testWidgets('children open over 240 ms, not at once', (tester) async {
        await pumpGroup(tester, open: false);
        final box = find.byKey(const ValueKey('data-table-children-0'));
        expect(tester.getSize(box).height, 0);
        await pumpGroup(tester, open: true);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        final mid = tester.getSize(box).height;
        expect(mid, greaterThan(0));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
        final end = tester.getSize(box).height;
        expect(end, greaterThan(mid));
        expect(find.text('Grammar'), findsOneWidget);
        // Closing also takes time: the box is still open a moment later.
        await pumpGroup(tester, open: false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.getSize(box).height, greaterThan(0));
        await tester.pumpAndSettle();
        expect(tester.getSize(box).height, 0);
      });

      testWidgets('reduced motion opens at once', (tester) async {
        await pumpGroup(tester, open: false, still: true);
        await pumpGroup(tester, open: true, still: true);
        await tester.pump();
        expect(find.text('Grammar'), findsOneWidget);
        // The box is full height on the first frame.
        expect(
          tester
              .getSize(find.byKey(const ValueKey('data-table-children-0')))
              .height,
          greaterThan(0),
        );
        expect(find.byType(AnimatedSize), findsNothing);
      });

      testWidgets('a long first-column name wraps with its subtitle',
          (tester) async {
        await pumpGroup(tester, open: false);
        final name = tester.widget<Text>(
          find.textContaining('Language Proficiency'),
        );
        expect(name.maxLines, isNull);
        expect(name.softWrap, isTrue);
        expect(
          tester.getSize(find.textContaining('Language Proficiency')).height,
          greaterThan(24),
        );
        expect(find.text('2 topics'), findsOneWidget);
      });
    });
  });

  dsMatrix(
    'a body row heading uses the body cell style, not the column eyebrow',
    (context) => SizedBox(
      width: 358,
      child: PantasDataTable(
        columns: const [
          PantasTableColumn('Mock exam'),
          PantasTableColumn('Score', numeric: true),
        ],
        rows: const [
          ['Mock 3 of the Year', '68%'],
        ],
      ),
    ),
    check: (tester, cell) async {
      final palette = cell.dark ? PantasColors.dark : PantasColors.light;
      final heading = tester.widget<Text>(find.text('Mock 3 of the Year'));
      final style = heading.style!;
      // web-row-value: 15 / 400 / 1.3, in text-primary, as given (sentence
      // case, no uppercase transform).
      expect(style.fontSize, 15);
      expect(style.fontWeight, FontWeight.w400);
      expect(style.height, 1.3);
      expect(style.color, palette.textPrimary);
      expect(find.text('MOCK 3 OF THE YEAR'), findsNothing);
      // Only the header row is the eyebrow: 13 / 600 uppercase, secondary.
      final head = tester.widget<Text>(find.text('MOCK EXAM')).style!;
      expect(head.fontSize, 13);
      expect(head.fontWeight, FontWeight.w600);
      expect(head.color, palette.textSecondary);
      // The row is at least 44 high and the heading sits 20 from the edge.
      final row = tester.getRect(find.text('Mock 3 of the Year'));
      final table = tester.getRect(find.byKey(const ValueKey('data-table')));
      expect(row.left - table.left, 20);
      final pinned = tester.getSize(
        find.byKey(const ValueKey('data-table-pinned')),
      );
      expect(pinned.height, greaterThanOrEqualTo(44 * 2));
    },
  );
}

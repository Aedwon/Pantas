import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/progress/application/table_order_prefs.dart';
import 'package:cse_cet_reviewer/features/progress/presentation/widgets/table_head.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget harness({
    String rowNoun = 'Subject',
    bool showTime = false,
    TableSortKey sortKey = TableSortKey.score,
    TableSortDirection direction = TableSortDirection.ascending,
    ValueChanged<TableSortKey>? onSort,
  }) {
    return MaterialApp(
      theme: buildLightTheme(),
      home: Scaffold(
        body: TableHead(
          rowNoun: rowNoun,
          showTime: showTime,
          sortKey: sortKey,
          direction: direction,
          onSort: onSort ?? (_) {},
        ),
      ),
    );
  }

  testWidgets('names the rows and offers two sorts', (tester) async {
    await tester.pumpWidget(harness(rowNoun: 'Topic', showTime: true));

    expect(find.text('TOPIC'), findsOneWidget);
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
  });

  testWidgets('the caret appears only on the active head', (tester) async {
    await tester.pumpWidget(
      harness(showTime: true),
    );

    expect(find.byKey(const ValueKey('sort-caret')), findsOneWidget);
  });

  testWidgets('tapping the inactive head sorts by it', (tester) async {
    final sorts = <TableSortKey>[];
    await tester.pumpWidget(harness(showTime: true, onSort: sorts.add));

    await tester.tap(find.text('TIME'));
    expect(sorts, [TableSortKey.time]);
  });

  testWidgets('tapping the active head reverses it', (tester) async {
    final sorts = <TableSortKey>[];
    await tester.pumpWidget(harness(showTime: true, onSort: sorts.add));

    await tester.tap(find.text('SCORE'));
    expect(sorts, [TableSortKey.score]);
  });

  testWidgets('the row noun does not sort', (tester) async {
    final sorts = <TableSortKey>[];
    await tester.pumpWidget(
      harness(rowNoun: 'Topic', showTime: true, onSort: sorts.add),
    );

    await tester.tap(find.text('TOPIC'), warnIfMissed: false);
    expect(sorts, isEmpty);
  });

  testWidgets('with no time, the head is absent and not dimmed',
      (tester) async {
    await tester.pumpWidget(harness());

    expect(find.text('TIME'), findsNothing);
  });

  testWidgets('the caret follows the direction', (tester) async {
    await tester.pumpWidget(harness(showTime: true));
    final ascending = tester
        .widget<SortCaret>(find.byKey(const ValueKey('sort-caret')))
        .direction;
    expect(ascending, TableSortDirection.ascending);

    await tester.pumpWidget(
      harness(showTime: true, direction: TableSortDirection.descending),
    );
    expect(
      tester
          .widget<SortCaret>(find.byKey(const ValueKey('sort-caret')))
          .direction,
      TableSortDirection.descending,
    );
  });

  testWidgets('no separate sort widget exists', (tester) async {
    await tester.pumpWidget(harness(showTime: true));

    expect(find.byType(DropdownButton<Object>), findsNothing);
    expect(find.byType(PopupMenuButton<Object>), findsNothing);
    expect(find.byType(IconButton), findsNothing);
  });
}

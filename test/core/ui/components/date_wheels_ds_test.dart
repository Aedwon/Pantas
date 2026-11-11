import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../../../helpers/ds_matrix.dart';

const _full = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
const _short = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

Widget _group(double width) => SizedBox(
      width: width,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ValueWheel(
              values: _full,
              shortValues: _short,
              selectedIndex: 10,
              label: 'Month',
              onSelected: (_) {},
            ),
          ),
          Expanded(
            child: ValueWheel(
              values: [for (var d = 1; d <= 30; d++) '$d'],
              selectedIndex: 3,
              label: 'Day',
              onSelected: (_) {},
            ),
          ),
          Expanded(
            child: ValueWheel(
              values: const ['2026', '2027', '2028'],
              selectedIndex: 0,
              label: 'Year',
              onSelected: (_) {},
            ),
          ),
        ],
      ),
    );

void main() {
  dsMatrix(
    'wheel: row follows the scaled line, band in bg-page',
    (context) => _group(358),
    check: (tester, cell) async {
      final palette = cell.dark ? PantasColors.dark : PantasColors.light;
      // The larger of 36 and the 20 px line plus 16: 36 at default text and
      // 56 at 200%. Five rows are visible.
      final row = cell.scale == 2 ? 56.0 : 36.0;
      expect(tester.getSize(find.byType(ValueWheel).first).height, row * 5);
      final band = find.byKey(const ValueKey('wheel-selection'));
      expect(tester.getSize(band.first).height, row);
      expect(
        (tester.widget<Container>(band.first).decoration! as BoxDecoration)
            .color,
        palette.bgPage,
      );
      expect(
        (tester.widget<Container>(band.first).decoration! as BoxDecoration)
            .borderRadius,
        BorderRadius.circular(8),
      );
      final chosen = tester.widget<Text>(find.text('4'));
      expect(chosen.style!.fontSize, 20);
      expect(chosen.style!.fontWeight, FontWeight.w500);
      expect(chosen.style!.color, palette.textPrimary);
      final other = tester.widget<Text>(find.text('5'));
      expect(other.style!.fontWeight, FontWeight.w400);
      expect(other.style!.color, palette.textSecondary);
    },
  );

  testWidgets('the month wheel shows Jan under 21rem and keeps the full name',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpDs(tester, dsCells.first, _group(300));
    expect(find.text('Nov'), findsOneWidget);
    expect(find.text('November'), findsNothing);
    expect(
      tester.getSemantics(find.byType(ValueWheel).first).value,
      'November',
    );
    await pumpDs(tester, dsCells.first, _group(420));
    expect(find.text('November'), findsOneWidget);
    expect(find.text('Nov'), findsNothing);
    handle.dispose();
  });

  testWidgets('the wheel gets taller with the text at 200%', (tester) async {
    await pumpDs(tester, dsCells[2], _group(358));
    expect(tester.getSize(find.byType(ValueWheel).first).height, 280);
  });

  dsMatrix(
    'web picker column: rows follow the scaled line',
    (context) => WebPickerColumn(
      values: const ['1', '2', '3', '4', '5', '6'],
      selectedIndex: 2,
      label: 'Day',
      onSelected: (_) {},
    ),
    check: (tester, cell) async {
      // The larger of 36 and the 17 px line (1.3) plus 16, five rows 2 apart.
      final line = 17 * cell.scale * 1.3 + 16;
      final row = line > 36 ? line : 36.0;
      expect(
        tester.getSize(find.byType(WebPickerColumn)).height,
        closeTo(row * 5 + 8, .01),
      );
      expect(tester.getSize(find.byType(WebPickerColumn)).width, 120);
    },
  );

  dsMatrix(
    'month-first picker: accent-fill when chosen, past dimmed',
    (context) => MonthFirstDatePicker(
      value: const MonthFirstDate(year: 2026, month: 12, day: 11),
      today: DateTime(2026, 12, 5),
      onChanged: (_) {},
    ),
    check: (tester, cell) async {
      final palette = cell.dark ? PantasColors.dark : PantasColors.light;
      Text label(int day) => tester.widget<Text>(
            find.descendant(
              of: find.byKey(ValueKey('date-day-$day')),
              matching: find.byType(Text),
            ),
          );
      final chosen = label(11);
      expect(chosen.style!.color, palette.onAccent);
      expect(chosen.style!.fontWeight, FontWeight.w700);
      expect(chosen.style!.fontSize, 15);
      // A past day is disabled and readable: text-secondary, weight 400.
      final past = label(3);
      expect(past.style!.color, palette.textSecondary);
      expect(past.style!.fontWeight, FontWeight.w400);
      expect(
        tester
            .widget<TextButton>(find.byKey(const ValueKey('date-day-3')))
            .onPressed,
        isNull,
      );
      // Date cells are at least 46 high.
      expect(
        tester.getSize(find.byKey(const ValueKey('date-day-11'))).height,
        greaterThanOrEqualTo(46),
      );
      // The full date is the accessible name.
      expect(find.bySemanticsLabel('December 11, 2026'), findsOneWidget);
    },
  );
}

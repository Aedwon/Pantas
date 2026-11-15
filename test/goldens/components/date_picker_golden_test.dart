import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';

import '../golden_harness.dart';

Widget _picker(MonthFirstDate value) => MonthFirstDatePicker(
      value: value,
      today: DateTime(2026, 11, 9),
      onChanged: (_) {},
    );

void main() {
  goldenSheet(
    'date_picker',
    [
      GoldenState(
        'Empty',
        (_) => _picker(const MonthFirstDate(year: 2027)),
        width: 340,
      ),
      GoldenState(
        'Month picked',
        (_) => _picker(const MonthFirstDate(year: 2027, month: 3)),
        width: 340,
      ),
      GoldenState(
        'Date picked',
        (_) => _picker(const MonthFirstDate(year: 2027, month: 3, day: 14)),
        width: 340,
      ),
      GoldenState(
        'Focus',
        (_) => _picker(const MonthFirstDate(year: 2027, month: 3, day: 14)),
        action: GoldenAction.focus,
        width: 340,
      ),
    ],
    cellWidth: 340,
    columns: 2,
  );
}

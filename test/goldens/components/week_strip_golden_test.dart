import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/week_strip.dart';

import '../golden_harness.dart';

WeekStrip _strip({DateTime? selected}) => WeekStrip(
      today: DateTime(2026, 11, 9),
      states: const [
        WeekDayState.done,
        WeekDayState.partial,
        WeekDayState.today,
        WeekDayState.plain,
        WeekDayState.dayOff,
        WeekDayState.plain,
        WeekDayState.plain,
      ],
      todayFraction: .5,
      selectedDate: selected,
      onSelected: (_) {},
    );

void main() {
  goldenSheet(
    'week_strip',
    [
      GoldenState('Rest', (_) => _strip(), width: 358),
      GoldenState(
        'Selected day',
        (_) => _strip(selected: DateTime(2026, 11, 10)),
        width: 358,
      ),
      GoldenState(
        'Hover',
        (_) => _strip(),
        action: GoldenAction.hover,
        at: const Alignment(-0.5, 0),
        width: 358,
      ),
      GoldenState(
        'Pressed',
        (_) => _strip(),
        action: GoldenAction.pressed,
        at: const Alignment(-0.5, 0),
        width: 358,
      ),
      GoldenState(
        'Focus',
        (_) => _strip(),
        action: GoldenAction.focus,
        width: 358,
      ),
      GoldenState(
        'Missed day',
        (_) => WeekStrip(
          today: DateTime(2026, 11, 9),
          states: const [
            WeekDayState.missed,
            WeekDayState.missed,
            WeekDayState.today,
            WeekDayState.plain,
            WeekDayState.plain,
            WeekDayState.plain,
            WeekDayState.plain,
          ],
          onSelected: (_) {},
        ),
        width: 358,
      ),
    ],
    cellWidth: 358,
    columns: 2,
  );
}

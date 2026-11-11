import 'package:pantas/core/ui/components/selectable_tile.dart';

import '../golden_harness.dart';

SelectableTile _tile({required bool selected, bool enabled = true}) =>
    SelectableTile(
      name: 'Mathematics',
      sub: '12 lessons',
      selected: selected,
      onTap: enabled ? () {} : null,
    );

SelectableTile _day({required bool selected}) => SelectableTile.day(
      weekday: 'Mon',
      name: '12',
      selected: selected,
      onTap: () {},
    );

void main() {
  goldenSheet(
    'selectable_tile',
    [
      ...interactionStates('Off', (_) => _tile(selected: false), width: 200),
      ...interactionStates('On', (_) => _tile(selected: true), width: 200),
      GoldenState('Day off', (_) => _day(selected: false)),
      GoldenState('Day on', (_) => _day(selected: true)),
      GoldenState(
        'Day focus',
        (_) => _day(selected: false),
        action: GoldenAction.focus,
      ),
    ],
    cellWidth: 200,
    columns: 4,
  );
}

import 'package:pantas/core/ui/components/selection_row.dart';

import '../golden_harness.dart';

CheckboxRow _row({
  required bool selected,
  bool mixed = false,
  bool enabled = true,
}) =>
    CheckboxRow(
      title: 'Mathematics',
      selected: selected,
      mixed: mixed,
      onTap: enabled ? () {} : null,
    );

void main() {
  goldenSheet(
    'checkbox',
    [
      ...interactionStates(
        'Off',
        (_) => _row(selected: false),
        disabled: (_) => _row(selected: false, enabled: false),
      ),
      ...interactionStates(
        'On',
        (_) => _row(selected: true),
        disabled: (_) => _row(selected: true, enabled: false),
      ),
      GoldenState('Mixed', (_) => _row(selected: false, mixed: true)),
    ],
    cellWidth: 240,
    columns: 5,
  );
}

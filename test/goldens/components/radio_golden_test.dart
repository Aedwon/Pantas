import 'package:pantas/core/ui/components/selection_row.dart';

import '../golden_harness.dart';

RadioRow _row({required bool selected, bool enabled = true}) => RadioRow(
      title: 'Mathematics',
      selected: selected,
      onTap: enabled ? () {} : null,
    );

void main() {
  goldenSheet(
    'radio',
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
    ],
    cellWidth: 240,
    columns: 5,
  );
}

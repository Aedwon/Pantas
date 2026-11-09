import 'package:pantas/core/ui/components/list_row.dart';

import '../golden_harness.dart';

ListRow _row({
  bool selected = false,
  bool enabled = true,
  ListRowVariant variant = ListRowVariant.navigation,
  String? value,
  String? subtitle,
}) =>
    ListRow(
      title: 'Fractions, part 2',
      subtitle: subtitle,
      value: value,
      variant: variant,
      selected: selected,
      onTap: enabled ? () {} : null,
    );

void main() {
  goldenSheet(
    'list_row',
    [
      ...interactionStates(
        'Navigation',
        (_) => _row(subtitle: '15 min'),
        disabled: (_) => _row(subtitle: '15 min', enabled: false),
        width: 320,
      ),
      GoldenState(
        'Selected',
        (_) => _row(selected: true, subtitle: '15 min'),
        width: 320,
      ),
      GoldenState(
        'Value',
        (_) => _row(variant: ListRowVariant.value, value: 'English'),
        width: 320,
      ),
      GoldenState(
        'Destructive',
        (_) => _row(variant: ListRowVariant.destructive),
        width: 320,
      ),
      GoldenState(
        'Static',
        (_) => const ListRow(title: 'Fractions, part 2', subtitle: '15 min'),
        width: 320,
      ),
    ],
    cellWidth: 320,
  );
}

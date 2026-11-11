import 'package:pantas/core/ui/components/list_row.dart';

import '../golden_harness.dart';

ListRow _row({
  bool selected = false,
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
      onTap: () {},
    );

void main() {
  goldenSheet(
    'list_row',
    [
      ...interactionStates(
        'Navigation',
        (_) => _row(subtitle: '15 min'),
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
      // Disabled in the app is the "coming soon" exam row: `text-disabled`
      // for the title, subtitle and label, no press.
      GoldenState(
        'Disabled (coming soon)',
        (_) => ListRow.exam(
          title: 'CSE',
          subtitle: 'Civil Service Commission',
          selected: false,
          onTap: () {},
          comingSoon: true,
          settingsMode: true,
        ),
        web: false,
        width: 320,
      ),
      GoldenState(
        'Exam row, selected',
        (_) => ListRow.exam(
          title: 'UPCAT',
          subtitle: 'University of the Philippines',
          selected: true,
          onTap: () {},
          settingsMode: true,
        ),
        web: false,
        width: 320,
      ),
    ],
    cellWidth: 320,
  );
}

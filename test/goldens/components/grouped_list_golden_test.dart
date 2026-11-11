import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';

import '../golden_harness.dart';

/// Rows in a phone group: the separator starts at the text, so each row but
/// the last passes `divider` (the settings pages inset it past the icon).
List<ListRow> _rows() => [
      ListRow(title: 'Name', divider: true, onTap: () {}),
      ListRow(
        title: 'Exam date',
        value: '14 Aug',
        variant: ListRowVariant.value,
        onTap: () {},
      ),
    ];

void main() {
  goldenSheet(
    'grouped_list',
    [
      GoldenState(
        'Header, footer',
        (_) => GroupedSection(
          header: 'Account',
          footer: 'Changes save on this device.',
          children: _rows(),
        ),
        width: 340,
      ),
      GoldenState(
        'No header',
        (_) => GroupedSection(children: _rows()),
        width: 340,
      ),
      GoldenState(
        'Switch row',
        (_) => GroupedSection(
          header: 'Mock exams',
          children: [
            ListRow(
              title: 'Strict mode',
              variant: ListRowVariant.switchControl,
              selected: true,
              divider: true,
              onTap: () {},
            ),
            ListRow(
              title: 'Reminders',
              variant: ListRowVariant.switchControl,
              onTap: () {},
            ),
          ],
        ),
        width: 340,
      ),
      GoldenState(
        'Disabled row (coming soon)',
        (_) => GroupedSection(
          header: 'Exam',
          children: [
            ListRow.exam(
              title: 'UPCAT',
              subtitle: 'University of the Philippines',
              selected: true,
              divider: true,
              onTap: () {},
              settingsMode: true,
            ),
            ListRow.exam(
              title: 'CSE',
              subtitle: 'Civil Service Commission',
              selected: false,
              onTap: () {},
              comingSoon: true,
              settingsMode: true,
            ),
          ],
        ),
        width: 340,
      ),
      GoldenState(
        'Destructive row',
        (_) => GroupedSection(
          children: [
            ListRow(
              title: 'Sign Out',
              variant: ListRowVariant.destructive,
              onTap: () {},
            ),
          ],
        ),
        width: 340,
      ),
    ],
    cellWidth: 340,
  );
}

import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'grouped_list',
    [
      GoldenState(
        'Header, footer',
        (_) => GroupedSection(
          header: 'Account',
          footer: 'Changes save on this device.',
          children: [
            ListRow(title: 'Name', onTap: () {}),
            ListRow(title: 'Exam date', value: '14 Aug', onTap: () {}),
          ],
        ),
        width: 340,
      ),
      GoldenState(
        'No header',
        (_) => GroupedSection(
          children: [
            ListRow(title: 'Name', onTap: () {}),
            ListRow(title: 'Exam date', value: '14 Aug', onTap: () {}),
          ],
        ),
        width: 340,
      ),
    ],
    cellWidth: 340,
    columns: 2,
  );
}

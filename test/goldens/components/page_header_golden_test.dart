import 'package:pantas/core/ui/web/web_page_heading.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'page_header',
    [
      GoldenState(
        'Title and back link',
        (_) => WebPageHeading(title: 'Study plan', onBack: () {}),
        width: 420,
      ),
      GoldenState(
        'With a lead line',
        (_) => WebPageHeading(
          title: 'Study plan',
          subtitle: 'Your week, one step at a time.',
          onBack: () {},
        ),
        width: 420,
      ),
    ],
    cellWidth: 420,
    columns: 2,
    web: true,
  );
}

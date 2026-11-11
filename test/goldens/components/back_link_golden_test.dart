import 'package:pantas/core/ui/web/web_components.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'back_link',
    [
      ...interactionStates(
        'Default',
        (_) => WebBackLink(label: 'Home', onPressed: () {}, nudge: false),
      ),
    ],
    cellWidth: 160,
    columns: 4,
    web: true,
  );
}

import 'package:pantas/core/ui/web/web_components.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'text_link',
    [
      ...interactionStates(
        'With arrow',
        (_) => WebTextLink(label: 'See all lessons', onPressed: () {}),
        disabled: (_) =>
            const WebTextLink(label: 'See all lessons', onPressed: null),
      ),
      ...interactionStates(
        'Text only',
        (_) => WebTextLink(
          label: 'See all lessons',
          arrow: false,
          onPressed: () {},
        ),
      ),
    ],
    cellWidth: 200,
    columns: 5,
    web: true,
  );
}

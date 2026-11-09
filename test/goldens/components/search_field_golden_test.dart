import 'package:pantas/core/ui/components/search_field.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'search_field',
    [
      ...interactionStates(
        'Default',
        (_) => SearchField(onChanged: (_) {}, hint: 'Lessons, topics'),
        width: 300,
      ),
      GoldenState(
        'Outlined',
        (_) => SearchField(
          onChanged: (_) {},
          hint: 'Lessons, topics',
          outlined: true,
        ),
        width: 300,
      ),
    ],
    cellWidth: 300,
  );
}

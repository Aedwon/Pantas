import 'package:pantas/core/ui/components/pantas_tooltip.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'tooltip',
    [
      GoldenState(
        'Name only',
        (_) => const PantasTooltipBubble(message: 'Close'),
        width: 240,
      ),
      GoldenState(
        'With shortcut',
        (_) => const PantasTooltipBubble(message: 'Flag (F)'),
        width: 240,
      ),
      GoldenState(
        'Long text wraps',
        (_) => const PantasTooltipBubble(
          message: 'Mark this question to return to it before you finish '
              'the quiz',
        ),
        width: 240,
      ),
    ],
    cellWidth: 240,
    web: true,
  );
}

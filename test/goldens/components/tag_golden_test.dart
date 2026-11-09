import 'package:pantas/core/ui/components/pantas_tag.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet('tag', [
    GoldenState('Tint (default)', (_) => const PantasTag('Up next')),
    GoldenState(
      'Solid',
      (_) => const PantasTag('Recommended', tone: PantasTagTone.solid),
    ),
    GoldenState(
      'Gray',
      (_) => const PantasTag('Not started', tone: PantasTagTone.gray),
    ),
    GoldenState(
      'Warning',
      (_) => const PantasTag('Paused', tone: PantasTagTone.warning),
    ),
  ]);
}

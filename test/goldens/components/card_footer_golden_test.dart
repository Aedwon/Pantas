import 'package:pantas/core/ui/components/card_footer.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'card_footer',
    [
      GoldenState(
        'Caption and action',
        (_) => CardFooter(
          caption: 'About 15 min',
          action: WebButton(label: 'Continue Lesson', onPressed: () {}),
        ),
        width: 520,
      ),
      // On a narrow card the action drops under the caption.
      GoldenState(
        'Narrow card',
        (_) => CardFooter(
          caption: 'About 15 min',
          action: WebButton(label: 'Continue Lesson', onPressed: () {}),
        ),
        width: 320,
      ),
    ],
    cellWidth: 520,
    columns: 2,
    web: true,
  );
}

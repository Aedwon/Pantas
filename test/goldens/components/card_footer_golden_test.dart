import 'package:pantas/core/ui/components/card_footer.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'card_footer',
    [
      GoldenState(
        'Caption and action',
        (_) => CardFooter(
          caption: 'About 15 min',
          action: PantasButton(
            label: 'Start',
            kind: PantasButtonKind.primary,
            fullWidth: false,
            onPressed: () {},
          ),
        ),
        width: 360,
      ),
    ],
    cellWidth: 360,
  );
}

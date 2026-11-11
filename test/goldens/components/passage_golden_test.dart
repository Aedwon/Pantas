import 'package:pantas/core/ui/components/new_design/passage_card.dart';

import '../golden_harness.dart';

const _text = 'The river bent twice before it reached the town, and each '
    'time the water slowed, as if it were deciding whether to go on.';

void main() {
  goldenSheet(
    'passage',
    [
      const GoldenState('With a title', _titled, width: 360),
      const GoldenState('No title', _plain, width: 360),
    ],
    cellWidth: 360,
    columns: 2,
  );
}

PassageCard _titled(_) => const PassageCard(title: 'The river', text: _text);

PassageCard _plain(_) => const PassageCard(text: _text);

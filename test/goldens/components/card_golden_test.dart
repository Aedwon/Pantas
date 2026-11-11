import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../golden_harness.dart';

Widget _card({bool selected = false, bool floating = false}) => WebCard(
      selected: selected,
      floating: floating,
      padding: const EdgeInsets.all(PantasSpace.s20),
      child: const Text('Fractions, part 2'),
    );

void main() {
  goldenSheet(
    'card',
    [
      GoldenState('Rest', (_) => _card(), width: 260),
      GoldenState('Selected', (_) => _card(selected: true), width: 260),
      GoldenState('Floating', (_) => _card(floating: true), width: 260),
    ],
    cellWidth: 260,
    web: true,
  );
}

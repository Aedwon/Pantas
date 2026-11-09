import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';

import '../golden_harness.dart';

Widget _bar(FloatingBarState state) => FloatingBar(
      state: state,
      left: const Text('Back'),
      counter: '3 of 10',
      right: PantasButton(
        label: 'Check',
        kind: PantasButtonKind.primary,
        fullWidth: false,
        onPressed: () {},
      ),
    );

void main() {
  goldenSheet(
    'floating_bar',
    [
      for (final s in FloatingBarState.values)
        GoldenState(s.name, (_) => _bar(s), width: 360),
    ],
    cellWidth: 360,
  );
}

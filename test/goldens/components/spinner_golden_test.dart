import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_button_parts.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'spinner',
    [
      GoldenState('Page spinner', (_) => const PantasSpinner()),
      GoldenState(
        'Inline spinner',
        (context) => PantasSpinner.inline(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ],
    cellWidth: 60,
    settle: const Duration(milliseconds: 300),
  );
}

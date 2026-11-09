import 'package:flutter/material.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'key_hint',
    [
      const GoldenState('Standalone', _hint),
      GoldenState('Command K', (_) => const WebKeyHint('Cmd K')),
      GoldenState(
        'On a button',
        (_) => const ColoredBox(
          color: Color(0xFF0B7A66),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: WebKeyHint('Enter', onButton: true),
          ),
        ),
      ),
      GoldenState('Disabled', (_) => const WebKeyHint('Enter', enabled: false)),
      GoldenState(
        'Touch (hidden)',
        (_) => const WebKeyHint('Enter', keyboard: false),
      ),
    ],
    cellWidth: 140,
    columns: 5,
    web: true,
  );
}

Widget _hint(BuildContext _) => const WebKeyHint('Enter');

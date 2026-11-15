import 'package:flutter/material.dart';
import 'package:pantas/core/ui/web/web_side_drawer.dart';

import '../golden_harness.dart';

Widget _drawer() => WebSideDrawer(
      open: true,
      onDismiss: () {},
      title: 'Explanation',
      closeLabel: 'Close explanation',
      body: const Padding(
        padding: EdgeInsets.all(24),
        child:
            Text('Halves are larger than thirds, so 1/2 is larger than 1/3.'),
      ),
    );

void main() {
  goldenSheet(
    'drawer',
    [
      GoldenState('Open', (_) => _drawer(), window: const Size(900, 520)),
      GoldenState(
        'Close focus',
        (_) => _drawer(),
        action: GoldenAction.focus,
        window: const Size(900, 520),
      ),
    ],
    columns: 1,
    web: true,
  );
}

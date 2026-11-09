import 'package:flutter/material.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

import '../golden_harness.dart';

Widget _sidebar(int active) => SizedBox(
      height: 520,
      child: WebSidebar(
        activeIndex: active,
        person: 'Maria Santos',
        exam: 'UPCAT',
        plan: 'Free',
        onNavigate: (_) {},
        onSearch: () {},
      ),
    );

void main() {
  goldenSheet(
    'sidebar_nav',
    [
      for (var i = 0; i < 4; i++)
        GoldenState(
          'Active ${['Home', 'Study', 'Quiz', 'Settings'][i]}',
          (_) => _sidebar(i),
          width: 260,
        ),
      // The second item (Study) sits near the top of the list.
      GoldenState(
        'Item hover',
        (_) => _sidebar(0),
        action: GoldenAction.hover,
        at: const Alignment(-0.2, -0.55),
        width: 260,
      ),
      GoldenState(
        'Item pressed',
        (_) => _sidebar(0),
        action: GoldenAction.pressed,
        at: const Alignment(-0.2, -0.55),
        width: 260,
      ),
      GoldenState(
        'Focus',
        (_) => _sidebar(0),
        action: GoldenAction.focus,
        width: 260,
      ),
    ],
    cellWidth: 260,
    columns: 4,
    web: true,
  );
}

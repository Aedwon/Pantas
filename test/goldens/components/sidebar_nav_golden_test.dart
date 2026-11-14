import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
      // The pointer lands on the Study item, not between rows.
      GoldenState(
        'Item hover',
        (_) => _sidebar(0),
        action: GoldenAction.hover,
        target: () => find.text('Study'),
        width: 260,
      ),
      GoldenState(
        'Item pressed',
        (_) => _sidebar(0),
        action: GoldenAction.pressed,
        target: () => find.text('Study'),
        width: 260,
      ),
      GoldenState(
        'Search focus',
        (_) => _sidebar(0),
        action: GoldenAction.focus,
        width: 260,
      ),
      // Tab moves from the search field to the first item.
      GoldenState(
        'Item focus',
        (_) => _sidebar(1),
        action: GoldenAction.focus,
        tabs: 2,
        width: 260,
      ),
    ],
    cellWidth: 260,
    columns: 4,
    web: true,
  );
}

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
      GoldenState(
        'Focus',
        (_) => _sidebar(0),
        action: GoldenAction.focus,
        width: 260,
      ),
    ],
    cellWidth: 260,
    columns: 5,
    web: true,
  );
}

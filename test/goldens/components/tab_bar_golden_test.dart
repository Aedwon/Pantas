import 'package:pantas/features/shell/presentation/app_shell.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'tab_bar',
    [
      for (var i = 0; i < 4; i++)
        GoldenState(
          'Current ${['Home', 'Study', 'Quiz', 'Settings'][i]}',
          (_) => AppNavBar(currentIndex: i, onTap: (_) {}),
          width: 358,
        ),
      GoldenState(
        'Focus',
        (_) => AppNavBar(currentIndex: 0, onTap: (_) {}),
        action: GoldenAction.focus,
        width: 358,
      ),
      GoldenState(
        'Hover',
        (_) => AppNavBar(currentIndex: 0, onTap: (_) {}),
        action: GoldenAction.hover,
        width: 358,
      ),
    ],
    cellWidth: 358,
  );
}

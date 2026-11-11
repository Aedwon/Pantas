import 'package:pantas/core/ui/components/pantas_timer.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'timer',
    [
      GoldenState(
        'Running',
        (_) => const PantasTimer(timeText: '42:10', fractionLeft: 0.7),
      ),
      GoldenState(
        'Warning',
        (_) => const PantasTimer(
          timeText: '4:30',
          fractionLeft: 0.08,
          state: PantasTimerState.warning,
        ),
      ),
      GoldenState(
        'Paused',
        (_) => const PantasTimer(
          timeText: '42:10',
          fractionLeft: 0.7,
          state: PantasTimerState.paused,
        ),
      ),
      GoldenState(
        'Inline, running',
        (_) => const PantasTimer(
          timeText: '42:10',
          fractionLeft: 0.7,
          inline: true,
        ),
      ),
      GoldenState(
        'Inline, warning',
        (_) => const PantasTimer(
          timeText: '4:30',
          fractionLeft: 0.08,
          inline: true,
          state: PantasTimerState.warning,
        ),
      ),
    ],
  );
}

import 'package:pantas/core/ui/components/progress_bar.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'progress_bar',
    [
      GoldenState(
        'Empty',
        (_) => const PantasProgressBar(
          value: 0,
          label: 'Lessons',
          valueText: '0 of 10',
        ),
      ),
      GoldenState(
        'Half',
        (_) => const PantasProgressBar(
          value: 0.5,
          label: 'Lessons',
          valueText: '5 of 10',
        ),
      ),
      GoldenState(
        'Full',
        (_) => const PantasProgressBar(
          value: 1,
          label: 'Lessons',
          valueText: '10 of 10',
        ),
      ),
      GoldenState(
        'Warning',
        (_) => const PantasProgressBar(
          value: 0.8,
          label: 'Time',
          valueText: '8 of 10',
          warning: true,
        ),
      ),
      GoldenState('No label', (_) => const PantasProgressBar(value: 0.4)),
    ],
    cellWidth: 240,
  );
}

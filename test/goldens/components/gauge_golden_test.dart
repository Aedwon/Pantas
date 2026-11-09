import 'package:pantas/core/ui/components/half_ring_gauge.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'gauge',
    [
      for (final f in [0.0, 0.35, 0.72, 1.0])
        GoldenState(
          '${(f * 100).round()} percent',
          (_) => HalfRingGauge(fraction: f, label: 'Accuracy'),
          width: 200,
        ),
      GoldenState(
        'Web, 72 percent',
        (_) =>
            const HalfRingGauge(fraction: 0.72, label: 'Accuracy', web: true),
        width: 200,
      ),
    ],
    cellWidth: 200,
    columns: 5,
    settle: const Duration(milliseconds: 3000),
  );
}

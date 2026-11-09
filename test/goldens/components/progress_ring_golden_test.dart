import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'progress_ring',
    [
      GoldenState('Empty', (_) => const ProgressRing(fraction: 0, size: 72)),
      GoldenState(
        'Half',
        (_) => const ProgressRing(fraction: 0.5, size: 72, child: Text('50%')),
      ),
      GoldenState(
        'Full, check',
        (_) => const ProgressRing(fraction: 1, size: 72),
      ),
      GoldenState(
        'Study, 60 percent',
        (_) => const ProgressRing.study(fraction: 0.6, size: 72),
      ),
      GoldenState(
        'Pull, 30 percent',
        (_) => const ProgressRing.pull(fraction: 0.3),
      ),
    ],
    cellWidth: 100,
    columns: 5,
    settle: const Duration(milliseconds: 2500),
  );
}

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/skeleton.dart';

import '../golden_harness.dart';

Widget _pulse(Widget child) => SkeletonRevealScope(
      immediate: true,
      child: SkeletonPulse(still: true, child: child),
    );

void main() {
  goldenSheet(
    'skeleton',
    [
      GoldenState(
        'Line',
        (_) => _pulse(const SkeletonBlock(height: 16, width: 200)),
      ),
      GoldenState(
        'Block',
        (_) => _pulse(const SkeletonBlock(height: 96, width: 200)),
      ),
      GoldenState(
        'Card',
        (_) => _pulse(const SkeletonCard(height: 120, width: 200)),
      ),
      GoldenState(
        'Heading',
        (_) => _pulse(const SkeletonHeading()),
      ),
    ],
    columns: 4,
  );
}

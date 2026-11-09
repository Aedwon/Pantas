import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_slider.dart';

import '../golden_harness.dart';

Widget _slider({bool enabled = true, double value = 1.4}) => PantasSlider(
      value: value,
      onChanged: (_) {},
      valueText: '140%',
      label: 'Text size',
      enabled: enabled,
    );

void main() {
  goldenSheet(
    'slider',
    [
      GoldenState('Rest', (_) => _slider(), width: 300),
      GoldenState(
        'Focus',
        (_) => _slider(),
        action: GoldenAction.focus,
        width: 300,
      ),
      GoldenState('Minimum', (_) => _slider(value: 1), width: 300),
      GoldenState('Maximum', (_) => _slider(value: 2), width: 300),
      GoldenState('Disabled', (_) => _slider(enabled: false), width: 300),
    ],
    cellWidth: 300,
  );
}

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';

import '../golden_harness.dart';

Widget _switch(bool value, {bool enabled = true}) => PantasSwitch(
      value: value,
      label: 'Reminders',
      onChanged: enabled ? (_) {} : null,
    );

void main() {
  goldenSheet(
    'switch',
    [
      GoldenState('Off, rest', (_) => _switch(false)),
      GoldenState('On, rest', (_) => _switch(true)),
      GoldenState(
        'Off, hover',
        (_) => _switch(false),
        action: GoldenAction.hover,
      ),
      GoldenState(
        'On, hover',
        (_) => _switch(true),
        action: GoldenAction.hover,
      ),
      GoldenState(
        'Off, pressed',
        (_) => _switch(false),
        action: GoldenAction.pressed,
      ),
      GoldenState(
        'On, pressed',
        (_) => _switch(true),
        action: GoldenAction.pressed,
      ),
      GoldenState(
        'Off, focus',
        (_) => _switch(false),
        action: GoldenAction.focus,
      ),
      GoldenState(
        'On, focus',
        (_) => _switch(true),
        action: GoldenAction.focus,
      ),
      GoldenState('Off, disabled', (_) => _switch(false, enabled: false)),
      GoldenState('On, disabled', (_) => _switch(true, enabled: false)),
    ],
    cellWidth: 160,
    columns: 5,
  );
}

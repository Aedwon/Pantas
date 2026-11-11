import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';

import '../golden_harness.dart';

const _flag = IconData(0xe244, fontFamily: 'Phosphor');

Widget _button({
  bool enabled = true,
  bool? toggled,
  bool accent = false,
  PantasIconButtonSize size = PantasIconButtonSize.standard,
}) =>
    PantasIconButton(
      tooltip: 'Flag',
      glyph: _flag,
      toggled: toggled,
      accent: accent,
      size: size,
      onPressed: enabled ? () {} : null,
    );

void main() {
  goldenSheet(
    'icon_button',
    [
      ...interactionStates(
        'Default',
        (_) => _button(),
        disabled: (_) => _button(enabled: false),
      ),
      ...interactionStates(
        'Accent',
        (_) => _button(accent: true),
        disabled: (_) => _button(accent: true, enabled: false),
      ),
      GoldenState('Toggle off', (_) => _button(toggled: false)),
      GoldenState('Toggle on', (_) => _button(toggled: true)),
      GoldenState(
        'Toggle on, focus',
        (_) => _button(toggled: true),
        action: GoldenAction.focus,
      ),
      for (final size in PantasIconButtonSize.values)
        GoldenState('Size ${size.name}', (_) => _button(size: size)),
    ],
    cellWidth: 80,
    columns: 6,
  );
}

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';

import '../golden_harness.dart';

const _kinds = <(String, PantasButtonKind, PantasButtonTone?)>[
  ('Primary', PantasButtonKind.primary, null),
  ('Primary critical', PantasButtonKind.primary, PantasButtonTone.critical),
  ('Secondary', PantasButtonKind.secondary, null),
  ('Neutral', PantasButtonKind.neutral, null),
  ('Tertiary', PantasButtonKind.tertiary, null),
  ('Tertiary accent', PantasButtonKind.tertiary, PantasButtonTone.accent),
  ('Tertiary critical', PantasButtonKind.tertiary, PantasButtonTone.critical),
];

Widget _button(
  PantasButtonKind kind,
  PantasButtonTone? tone, {
  bool enabled = true,
  bool busy = false,
}) =>
    PantasButton(
      label: busy ? 'Saving' : 'Label',
      kind: kind,
      tone: tone,
      busy: busy,
      fullWidth: false,
      onPressed: enabled ? () {} : null,
    );

void main() {
  goldenSheet(
    'button',
    [
      for (final (name, kind, tone) in _kinds) ...[
        GoldenState('$name rest', (_) => _button(kind, tone)),
        GoldenState(
          '$name hover',
          (_) => _button(kind, tone),
          action: GoldenAction.hover,
        ),
        GoldenState(
          '$name pressed',
          (_) => _button(kind, tone),
          action: GoldenAction.pressed,
        ),
        GoldenState(
          '$name focus',
          (_) => _button(kind, tone),
          action: GoldenAction.focus,
        ),
        GoldenState(
          '$name disabled',
          (_) => _button(kind, tone, enabled: false),
        ),
      ],
      GoldenState(
        'Primary busy',
        (_) => _button(PantasButtonKind.primary, null, busy: true),
      ),
      GoldenState(
        'Secondary busy',
        (_) => _button(PantasButtonKind.secondary, null, busy: true),
      ),
    ],
    cellWidth: 130,
    columns: 5,
  );
}

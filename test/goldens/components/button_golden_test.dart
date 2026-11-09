import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../golden_harness.dart';

const _kinds = <(String, PantasButtonKind, PantasButtonTone?)>[
  ('Primary', PantasButtonKind.primary, null),
  ('Primary critical', PantasButtonKind.primary, PantasButtonTone.critical),
  ('Secondary', PantasButtonKind.secondary, null),
  ('Secondary critical', PantasButtonKind.secondary, PantasButtonTone.critical),
  ('Neutral', PantasButtonKind.neutral, null),
  ('White', PantasButtonKind.white, null),
  ('Tertiary', PantasButtonKind.tertiary, null),
  ('Tertiary accent', PantasButtonKind.tertiary, PantasButtonTone.accent),
  ('Tertiary critical', PantasButtonKind.tertiary, PantasButtonTone.critical),
];

/// A desktop button, as the screens draw it (WebButton).
Widget _button(
  PantasButtonKind kind,
  PantasButtonTone? tone, {
  bool enabled = true,
  bool busy = false,
  PantasButtonSize? size,
  String? keyHint,
}) =>
    WebButton(
      label: busy ? 'Saving' : 'Label',
      kind: kind,
      tone: tone,
      size: size,
      busy: busy,
      keyHint: keyHint,
      onPressed: enabled ? () {} : null,
    );

/// A white button needs a photo-like ground to show its own surface.
Widget _onTeal(Widget child) => ColoredBox(
      color: const Color(0xFF0B7A66),
      child: Padding(padding: const EdgeInsets.all(8), child: child),
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
      for (final (name, size) in [
        ('Extra small 36', PantasButtonSize.xs),
        ('Small 42', PantasButtonSize.sm),
        ('Large 50', PantasButtonSize.lg),
        ('Bar 46 (pill)', PantasButtonSize.bar),
        ('Dialog 46 (pill)', PantasButtonSize.dialog),
        ('Notice 44', PantasButtonSize.notice),
        ('Pill small 44 (pill)', PantasButtonSize.pillSm),
      ])
        GoldenState(
          name,
          (_) => _button(PantasButtonKind.primary, null, size: size),
        ),
      for (final (name, size) in [
        ('Secondary bar', PantasButtonSize.bar),
        ('Secondary pill small', PantasButtonSize.pillSm),
      ])
        GoldenState(
          name,
          (_) => _button(PantasButtonKind.secondary, null, size: size),
        ),
      GoldenState(
        'Key hint',
        (_) => _button(PantasButtonKind.primary, null, keyHint: 'Enter'),
        width: 200,
      ),
      GoldenState(
        'Bar with key hint',
        (_) => _button(
          PantasButtonKind.primary,
          null,
          size: PantasButtonSize.bar,
          keyHint: 'Enter',
        ),
        width: 200,
      ),
      GoldenState(
        'White on color',
        (_) => _onTeal(_button(PantasButtonKind.white, null)),
      ),
      GoldenState(
        'Block',
        (_) => const WebButton(label: 'Continue', expand: true),
        width: 200,
      ),
      GoldenState(
        'Phone primary',
        (_) => PantasButton(
          label: 'Continue',
          kind: PantasButtonKind.primary,
          onPressed: () {},
        ),
        web: false,
        width: 200,
      ),
      GoldenState(
        'Phone secondary',
        (_) => PantasButton(
          label: 'Not Now',
          kind: PantasButtonKind.secondary,
          onPressed: () {},
        ),
        web: false,
        width: 200,
      ),
    ],
    cellWidth: 130,
    columns: 5,
    web: true,
  );
}

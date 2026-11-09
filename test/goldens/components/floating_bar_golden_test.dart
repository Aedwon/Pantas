import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../golden_harness.dart';

/// The phone bar (mock exam).
Widget _phone(FloatingBarState state) => FloatingBar(
      state: state,
      left: const Text('Back'),
      counter: '3 of 10',
      right: PantasButton(
        label: 'Check',
        kind: PantasButtonKind.primary,
        fullWidth: false,
        onPressed: () {},
      ),
    );

/// The desktop bar as the quiz draws it: the counter with its chevron, the
/// hint, then the flag and the pill action with its Enter hint.
Widget _desktop({
  WebBarState state = WebBarState.neutral,
  String hint = 'Pick one answer',
  String action = 'Check',
  bool enabled = true,
  bool flagged = false,
}) =>
    WebBottomBar(
      counter: '3 of 10',
      counterChevron: true,
      counterLabel: 'Question 3 of 10. Open question navigator',
      onCounterPressed: () {},
      hint: hint,
      state: state,
      action: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PantasIconButton(
            tooltip: 'Flag question',
            onPressed: () {},
            icon: WebFlagIcon(flagged: flagged),
          ),
          const SizedBox(width: 6),
          WebButton(
            label: action,
            pill: true,
            keyHint: 'Enter',
            onPressed: enabled ? () {} : null,
          ),
        ],
      ),
    );

/// The counter sits at the left end of the bar.
const _counterSpot = Alignment(-0.9, 0);

void main() {
  goldenSheet(
    'floating_bar',
    [
      GoldenState(
        'Desktop, nothing picked',
        (_) => _desktop(enabled: false),
        width: 720,
      ),
      GoldenState(
        'Desktop, picked',
        (_) => _desktop(hint: 'Check when you are ready'),
        width: 720,
      ),
      GoldenState(
        'Desktop, right',
        (_) => _desktop(
          state: WebBarState.right,
          hint: 'Correct',
          action: 'Next',
        ),
        width: 720,
      ),
      GoldenState(
        'Desktop, wrong',
        (_) => _desktop(
          state: WebBarState.wrong,
          hint: 'Not this one',
          action: 'Next',
          flagged: true,
        ),
        width: 720,
      ),
      GoldenState(
        'Counter hover',
        (_) => _desktop(),
        action: GoldenAction.hover,
        at: _counterSpot,
        width: 720,
      ),
      GoldenState(
        'Counter pressed',
        (_) => _desktop(),
        action: GoldenAction.pressed,
        at: _counterSpot,
        width: 720,
      ),
      GoldenState(
        'Counter focus',
        (_) => _desktop(),
        action: GoldenAction.focus,
        width: 720,
      ),
      for (final s in FloatingBarState.values)
        GoldenState(
          'Phone, ${s.name}',
          (_) => _phone(s),
          web: false,
          width: 360,
        ),
    ],
    cellWidth: 720,
    columns: 2,
    web: true,
  );
}

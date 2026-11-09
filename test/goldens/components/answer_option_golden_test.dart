import 'package:flutter/material.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../golden_harness.dart';

Widget _option(WebOptionState state, {bool enabled = true}) => WebAnswerOption(
      letter: 'B',
      state: state,
      onPressed: enabled ? () {} : null,
      child: const Text('One half'),
    );

void main() {
  goldenSheet(
    'answer_option',
    [
      ...interactionStates(
        'Normal',
        (_) => _option(WebOptionState.normal),
        width: 300,
      ),
      for (final s in WebOptionState.values.skip(1))
        GoldenState(s.name, (_) => _option(s), width: 300),
      GoldenState(
        'Selected, focus',
        (_) => _option(WebOptionState.selected),
        action: GoldenAction.focus,
        width: 300,
      ),
    ],
    cellWidth: 300,
    columns: 4,
    web: true,
  );
}

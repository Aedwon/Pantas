import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'state_view',
    [
      const GoldenState('Empty', _empty, width: 340),
      GoldenState(
        'Empty with an action',
        (_) => StateView(
          message: 'No bookmarks yet',
          detail: 'Tap the flag on a question to keep it here.',
          icon: Icon(PantasIcons.bookmark),
          actionLabel: 'Browse Questions',
          onRetry: () {},
        ),
        width: 340,
      ),
      GoldenState(
        'Error, Try Again',
        (_) => StateView(
          message: 'Something went wrong.',
          detail: 'Check your connection.',
          onRetry: () {},
        ),
        width: 340,
      ),
      GoldenState(
        'Error, Try Again (desktop)',
        (_) => StateView(
          message: 'We could not load this',
          detail: 'Check your connection and try again.',
          onRetry: () {},
        ),
        web: true,
        width: 420,
      ),
      GoldenState(
        'Error, Try Again focus',
        (_) => StateView(
          message: 'Something went wrong.',
          detail: 'Check your connection.',
          onRetry: () {},
        ),
        action: GoldenAction.focus,
        width: 340,
      ),
    ],
    cellWidth: 340,
  );
}

StateView _empty(_) => StateView(
      message: 'No lessons yet.',
      detail: 'Pick a topic to begin.',
      icon: Icon(PantasIcons.studyTab),
    );

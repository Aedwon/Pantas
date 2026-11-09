import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/toast.dart';

import '../golden_harness.dart';

/// The Undo action sits at the right end of a desktop toast.
const _undoSpot = Alignment(0.82, 0);

Toast _undo({String? keyHint}) => Toast(
      message: 'Lesson removed',
      onUndo: () {},
      keyHint: keyHint,
      web: true,
    );

void main() {
  goldenSheet(
    'toast',
    [
      const GoldenState('Message', _message, width: 360),
      GoldenState('With Undo', (_) => _undo(), width: 360),
      GoldenState(
        'Undo hover',
        (_) => _undo(),
        action: GoldenAction.hover,
        at: _undoSpot,
        width: 360,
      ),
      GoldenState(
        'Undo pressed',
        (_) => _undo(),
        action: GoldenAction.pressed,
        at: _undoSpot,
        width: 360,
      ),
      GoldenState(
        'Undo focus',
        (_) => _undo(),
        action: GoldenAction.focus,
        width: 360,
      ),
      GoldenState('With key hint', (_) => _undo(keyHint: 'Z'), width: 360),
      GoldenState(
        'Phone',
        (_) => Toast(message: 'Lesson removed', onUndo: () {}),
        web: false,
        width: 340,
      ),
    ],
    cellWidth: 360,
    columns: 2,
    web: true,
  );
}

Toast _message(_) => const Toast(message: 'Saved', web: true);

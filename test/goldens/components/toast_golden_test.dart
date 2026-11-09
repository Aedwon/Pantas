import 'package:pantas/core/ui/components/toast.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'toast',
    [
      const GoldenState('Message', _message, width: 360),
      GoldenState(
        'With Undo',
        (_) => Toast(message: 'Lesson removed', onUndo: () {}),
        width: 360,
      ),
      GoldenState(
        'With Undo, focus',
        (_) => Toast(message: 'Lesson removed', onUndo: () {}),
        action: GoldenAction.focus,
        width: 360,
      ),
      GoldenState(
        'With key hint',
        (_) => Toast(message: 'Lesson removed', onUndo: () {}, keyHint: 'Z'),
        width: 360,
      ),
    ],
    cellWidth: 360,
    columns: 2,
  );
}

Toast _message(_) => const Toast(message: 'Saved');

import 'package:pantas/core/ui/components/centered_dialog.dart';

import '../golden_harness.dart';

CenteredDialog _dialog({bool destructive = false}) => CenteredDialog(
      title: destructive ? 'Delete this note?' : 'Leave the quiz?',
      message: destructive
          ? 'The note is removed from this device. You cannot undo this.'
          : 'Your answers so far are saved. You can pick up where you stopped.',
      primaryLabel: destructive ? 'Delete' : 'Leave',
      secondaryLabel: destructive ? 'Keep it' : 'Stay',
      destructive: destructive,
      onConfirm: () {},
      onCancel: () {},
    );

void main() {
  goldenSheet(
    'dialog',
    [
      GoldenState('Wide', (_) => _dialog(), width: 480),
      GoldenState(
        'Wide destructive',
        (_) => _dialog(destructive: true),
        width: 480,
      ),
      GoldenState(
        'Wide focus',
        (_) => _dialog(destructive: true),
        action: GoldenAction.focus,
        width: 480,
      ),
      GoldenState('Phone', (_) => _dialog(), web: false, width: 340),
      GoldenState(
        'Phone destructive',
        (_) => _dialog(destructive: true),
        web: false,
        width: 340,
      ),
    ],
    cellWidth: 480,
    columns: 2,
    web: true,
  );
}

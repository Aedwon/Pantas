import 'package:flutter/widgets.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';

/// Under-13 board 3A: the question over the exam picker when an adult or teen
/// account taps PSHS-NCE. Resolves true for Yes, false for No, and null when
/// the system closes it (Back). Esc and a tap outside do nothing: the two
/// buttons are the only answers.
Future<bool?> showChildQuestionDialog(BuildContext context) =>
    showPantasDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CenteredDialog(
        title: 'Is this for a child under 13?',
        message: 'A parent or guardian sets up PSHS-NCE accounts for children '
            'under 13.',
        primaryLabel: 'Yes',
        secondaryLabel: 'No',
        allowEscape: false,
        onConfirm: () => Navigator.of(dialogContext).pop(true),
        onCancel: () => Navigator.of(dialogContext).pop(false),
      ),
    );

/// Where "Yes" leads from Settings. The account already has study records, so
/// the server would refuse it as a parent's sign-in. Copy settled by the lead
/// under rule 4; no board.
Future<void> showUseAnotherEmailDialog(BuildContext context) =>
    showPantasDialog<void>(
      context: context,
      builder: (dialogContext) => CenteredDialog(
        title: 'Use another email',
        message: 'This account already has study records. To set up a child '
            'under 13, sign out, then sign in with another email.',
        primaryLabel: 'Got It',
        onConfirm: () => Navigator.of(dialogContext).pop(),
        onCancel: () => Navigator.of(dialogContext).pop(),
      ),
    );

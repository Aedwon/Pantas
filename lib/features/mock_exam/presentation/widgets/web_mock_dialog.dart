import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/web/web_key_focus.dart';

/// Confirmation surface for pause, submit, end-part and discard.
///
/// Focus starts inside the dialog, so its keys work as soon as it opens. Esc
/// and Enter both choose the safe button ([onCancel]): Keep Going, Keep
/// Working, Keep It. Tab reaches the other button. Without a focus of its own
/// the dialog opened with focus on its route, above the keys, and Esc and Tab
/// did nothing until the student clicked inside it.
class WebMockDialog extends StatelessWidget {
  const WebMockDialog({
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onConfirm,
    required this.onCancel,
    this.destructive = false,
    this.content,
    super.key,
  });
  final String title;
  final String message;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool destructive;
  final Widget? content;
  @override
  Widget build(BuildContext context) => EnterShortcut(
        onEnter: onCancel,
        // The surface is the system Dialog. This wrapper adds the mock's
        // keys: Esc and Enter with no button focused both keep the student
        // in the exam.
        child: CenteredDialog(
          title: title,
          message: message,
          primaryLabel: primaryLabel,
          secondaryLabel: secondaryLabel,
          onConfirm: onConfirm,
          onCancel: onCancel,
          destructive: destructive,
          content: content,
        ),
      );
}

Widget webMockConfirmation({
  required String title,
  required String message,
  required String primaryLabel,
  required String secondaryLabel,
  required VoidCallback onConfirm,
  required VoidCallback onCancel,
  bool destructive = false,
  bool inlineActions = false,
  Widget? content,
  bool allowEscape = true,
  // Phone dialog geometry; the web dialog ignores all three.
  double horizontalInset = 28,
  double actionGap = 8,
  double lift = 0,
  Key? key,
}) =>
    WebMockDialog(
      key: key,
      title: title,
      message: message,
      primaryLabel: primaryLabel,
      secondaryLabel: secondaryLabel,
      onConfirm: onConfirm,
      onCancel: onCancel,
      destructive: destructive,
      content: content,
    );

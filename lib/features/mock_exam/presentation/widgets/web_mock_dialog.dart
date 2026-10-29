import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// Confirmation surface for pause, submit, end-part and discard.
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
  Widget build(BuildContext context) => CallbackShortcuts(
        bindings: {const SingleActivator(LogicalKeyboardKey.escape): onCancel},
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: WebCard(
              radius: 22,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: context.webTokens.h3),
                    const SizedBox(height: 8),
                    Text(message, style: context.webTokens.sub),
                    if (content != null) content!,
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        WebButton(
                          label: primaryLabel,
                          variant: destructive
                              ? WebButtonVariant.danger
                              : WebButtonVariant.primary,
                          onPressed: onConfirm,
                        ),
                        WebButton(
                          label: secondaryLabel,
                          variant: WebButtonVariant.tertiary,
                          onPressed: onCancel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
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

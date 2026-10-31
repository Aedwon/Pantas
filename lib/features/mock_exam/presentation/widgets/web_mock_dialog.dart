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
              padding: const EdgeInsets.all(26),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: context.webTokens.h3),
                    const SizedBox(height: 18),
                    Text(
                      message,
                      style: context.webTokens.sub.copyWith(fontSize: 16),
                    ),
                    if (content != null) ...[
                      const SizedBox(height: 18),
                      content!,
                    ],
                    const SizedBox(height: 18),
                    // The boards right-align the pair. A destructive dialog
                    // puts the safe choice first and the red action last;
                    // every other dialog puts the action first, as plain
                    // text, and the safe choice last, in teal.
                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: destructive
                            ? [
                                WebButton(
                                  label: secondaryLabel,
                                  variant: WebButtonVariant.tertiary,
                                  onPressed: onCancel,
                                ),
                                WebButton(
                                  label: primaryLabel,
                                  variant: WebButtonVariant.danger,
                                  onPressed: onConfirm,
                                ),
                              ]
                            : [
                                WebButton(
                                  label: primaryLabel,
                                  variant: WebButtonVariant.tertiary,
                                  onPressed: onConfirm,
                                ),
                                WebButton(
                                  label: secondaryLabel,
                                  onPressed: onCancel,
                                ),
                              ],
                      ),
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

import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<void> showAppConfirmationDialog({
  required BuildContext context,
  required String title,
  required String body,
  required String cancelLabel,
  required String confirmLabel,
  required VoidCallback onCancel,
  required VoidCallback onConfirm,
  bool isDestructive = true,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ConfirmationDialog(
      title: title,
      body: body,
      cancelLabel: cancelLabel,
      confirmLabel: confirmLabel,
      onCancel: onCancel,
      onConfirm: onConfirm,
      isDestructive: isDestructive,
    ),
  );
}

class _ConfirmationDialog extends StatelessWidget {
  const _ConfirmationDialog({
    required this.title,
    required this.body,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
    required this.isDestructive,
  });

  final String title;
  final String body;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: styles.headlineMedium),
            const SizedBox(height: 6),
            Text(
              body,
              style: styles.bodyMedium.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: BoardButton(
                    label: cancelLabel,
                    secondary: true,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onCancel();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: isDestructive
                      ? _RustButton(
                          label: confirmLabel,
                          onPressed: () {
                            Navigator.of(context).pop();
                            onConfirm();
                          },
                        )
                      : BoardButton(
                          label: confirmLabel,
                          onPressed: () {
                            Navigator.of(context).pop();
                            onConfirm();
                          },
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RustButton extends StatelessWidget {
  const _RustButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
      child: Container(
        constraints:
            const BoxConstraints(minHeight: AppDimensions.minTapTarget),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: colors.rust,
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: styles.labelLarge.copyWith(color: colors.onBoard),
        ),
      ),
    );
  }
}

import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<void> showAppConfirmationDialog({
  required BuildContext context,
  required String icon,
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
      icon: icon,
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
    required this.icon,
    required this.title,
    required this.body,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
    required this.isDestructive,
  });

  final String icon;
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
    final textStyles = context.textStyles;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: textStyles.headlineSmall.copyWith(color: colors.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style:
                  textStyles.bodyMedium.copyWith(color: colors.onSurfaceMuted),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      onCancel();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMD),
                        border: Border.all(color: colors.border, width: 1.5),
                      ),
                      child: Text(
                        cancelLabel,
                        style: textStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isDestructive ? colors.error : colors.primary,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMD),
                      ),
                      child: Text(
                        confirmLabel,
                        style: textStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
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

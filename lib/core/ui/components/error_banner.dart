import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum ErrorBannerVariant { error, offline, success }

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    required this.variant,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    super.key,
  });

  final ErrorBannerVariant variant;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    final String icon;

    switch (variant) {
      case ErrorBannerVariant.error:
        bgColor = colors.errorContainer;
        borderColor = colors.error;
        textColor = colors.error;
        icon = '⚠️';
      case ErrorBannerVariant.offline:
        bgColor = colors.warningContainer;
        borderColor = colors.warning;
        textColor = colors.warning;
        icon = '📶';
      case ErrorBannerVariant.success:
        bgColor = colors.successContainer;
        borderColor = colors.success;
        textColor = colors.success;
        icon = '✅';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: textStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: textStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ),
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, size: 16, color: colors.onSurfaceMuted),
            ),
          ],
        ],
      ),
    );
  }
}

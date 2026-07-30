import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

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
    final styles = context.textStyles;

    final accent = switch (variant) {
      ErrorBannerVariant.error => colors.rust,
      ErrorBannerVariant.offline => colors.amber,
      ErrorBannerVariant.success => colors.board,
    };

    final side = BorderSide(
      color: colors.rule,
      // ignore: avoid_redundant_argument_values
      width: AppDimensions.hairline,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: Border(top: side, bottom: side)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            key: const Key('error-banner-accent'),
            width: 3,
            height: 30,
            color: accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: styles.bodySmall.copyWith(color: colors.ink),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: styles.labelLarge.copyWith(color: colors.board),
              ),
            ),
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, size: 16, color: colors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }
}

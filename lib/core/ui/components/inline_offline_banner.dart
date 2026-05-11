import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class InlineOfflineBanner extends StatelessWidget {
  const InlineOfflineBanner({required this.onDismiss, super.key});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.warningContainer,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border(left: BorderSide(color: colors.warning, width: 4)),
      ),
      child: Row(
        children: [
          const Text('📶', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline — your progress is still being saved',
              style: textStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: colors.warning,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close, size: 16, color: colors.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}

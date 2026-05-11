import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CoachMark extends StatelessWidget {
  const CoachMark({
    required this.headline,
    required this.body,
    required this.onDismiss,
    super.key,
  });

  final String headline;
  final String body;
  final VoidCallback onDismiss;

  static const _bgColor = Color(0xFF1E293B);
  static const _mutedColor = Color(0xFF94A3B8);
  static const _ctaColor = Color(0xFF4D8FFF);

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            headline,
            style: textStyles.labelLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: textStyles.bodySmall.copyWith(color: _mutedColor),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onDismiss,
              child: Text(
                'Got it →',
                style: textStyles.bodySmall.copyWith(
                  color: _ctaColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

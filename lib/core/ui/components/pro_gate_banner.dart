import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProGateBanner extends StatelessWidget {
  const ProGateBanner({
    required this.featureName,
    required this.valueProp,
    required this.ctaLabel,
    required this.featureEmoji,
    required this.onCta,
    required this.onDismiss,
    super.key,
  });

  final String featureName;
  final String valueProp;
  final String ctaLabel;
  final String featureEmoji;
  final VoidCallback onCta;
  final VoidCallback onDismiss;

  static const _bgStart = Color(0xFF1E293B);
  static const _bgEnd = Color(0xFF1F3A6E);
  static const _mutedColor = Color(0xFF94A3B8);
  static const _proBadgeColor = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_bgStart, _bgEnd],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _proBadgeColor,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    'PRO',
                    style: textStyles.labelSmall.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  featureName,
                  style: textStyles.headlineSmall.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  valueProp,
                  style: textStyles.bodySmall.copyWith(color: _mutedColor),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onCta,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusMD),
                          ),
                          child: Text(
                            ctaLabel,
                            style: textStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDismiss,
                      child: Text(
                        'Maybe later',
                        style:
                            textStyles.bodySmall.copyWith(color: _mutedColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(featureEmoji, style: const TextStyle(fontSize: 36)),
        ],
      ),
    );
  }
}

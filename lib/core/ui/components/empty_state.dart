import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.illustration,
    required this.headline,
    required this.body,
    required this.ctaLabel,
    required this.onCta,
    super.key,
  });

  final String illustration;
  final String headline;
  final String body;
  final String ctaLabel;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(illustration, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            headline,
            style: textStyles.headlineSmall.copyWith(color: colors.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: textStyles.bodyMedium.copyWith(color: colors.onSurfaceMuted),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          AppButton(label: ctaLabel, onPressed: onCta),
        ],
      ),
    );
  }
}

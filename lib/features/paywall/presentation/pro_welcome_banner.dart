import 'package:cse_cet_reviewer/core/ui/components/ruled_section.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProWelcomeBanner extends StatelessWidget {
  const ProWelcomeBanner({
    required this.onDismiss,
    required this.onPlanTap,
    super.key,
  });

  final VoidCallback onDismiss;
  final VoidCallback onPlanTap;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;
    return RuledSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text("You're in.", style: styles.headlineMedium),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: Icon(Icons.close, size: 16, color: colors.inkMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Pro adjusts your plan based on what you actually struggle with. '
            "Let's get to it.",
            style: styles.bodyMedium.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onPlanTap,
            child: Text(
              "Take me to today's plan",
              style: styles.labelLarge.copyWith(color: colors.board),
            ),
          ),
        ],
      ),
    );
  }
}

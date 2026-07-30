import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class OnboardingWelcomeStep extends StatelessWidget {
  const OnboardingWelcomeStep({required this.onAdvance, super.key});

  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Text('Build your study plan', style: styles.displaySmall),
            const SizedBox(height: 10),
            Text(
              "Pick your exam and we'll guide what to study first.",
              style: styles.bodyLarge.copyWith(color: colors.inkMuted),
            ),
            const Spacer(),
            BoardButton(label: 'Get started', onPressed: onAdvance),
          ],
        ),
      ),
    );
  }
}

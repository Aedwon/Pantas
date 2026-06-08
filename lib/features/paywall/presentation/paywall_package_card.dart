import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/paywall_package.dart';
import 'package:flutter/material.dart';

class PaywallPackageCard extends StatelessWidget {
  const PaywallPackageCard({
    required this.package,
    required this.isSelected,
    required this.isRecommended,
    required this.badgeCopy,
    required this.onTap,
    super.key,
  });

  final PaywallPackage package;
  final bool isSelected;
  final bool isRecommended;
  final String badgeCopy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final title = switch (package.sku) {
      PaywallSku.weekly => 'Weekly',
      PaywallSku.monthly => 'Monthly',
      PaywallSku.yearly => 'Yearly',
      PaywallSku.lifetime => 'Lifetime',
    };
    final subtitle = switch (package.sku) {
      // The ≈monthly equivalent keeps Weekly honest: nobody should read it
      // as the cheap long-term option.
      PaywallSku.weekly => '${package.priceString}/week · ≈₱126/month · '
          'Renews every week · Cancel anytime',
      PaywallSku.monthly => '${package.priceString}/month · Cancel anytime',
      PaywallSku.yearly => '${package.priceString}/year · ₱42/month',
      PaywallSku.lifetime => '${package.priceString} · Pay once',
    };

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: isSelected
            ? BoxDecoration(
                color: colors.boardTint,
                border: Border.all(color: colors.board),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusButton),
              )
            : BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colors.ruleFaint,
                    // ignore: avoid_redundant_argument_values
                    width: AppDimensions.hairline,
                  ),
                ),
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended)
              Text(
                badgeCopy,
                style: styles.labelSmall.copyWith(color: colors.board),
              ),
            Row(
              children: [
                Expanded(child: Text(title, style: styles.headlineSmall)),
                if (package.sku == PaywallSku.yearly)
                  Text(
                    '7 days free',
                    style: styles.labelSmall.copyWith(color: colors.board),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: styles.bodySmall.copyWith(color: colors.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}

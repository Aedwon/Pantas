import 'package:flutter/material.dart';

import '../domain/paywall_package.dart';

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
    final theme = Theme.of(context);
    final title = switch (package.sku) {
      PaywallSku.monthly => 'Monthly',
      PaywallSku.yearly => 'Yearly',
      PaywallSku.lifetime => 'Lifetime',
    };
    final subtitle = switch (package.sku) {
      PaywallSku.monthly => '${package.priceString}/month · Cancel anytime',
      PaywallSku.yearly => '${package.priceString}/year · ₱42/month',
      PaywallSku.lifetime => '${package.priceString} · Pay once',
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF16A34A) : Colors.black12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended)
              Text(
                badgeCopy,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF15803D),
                  fontWeight: FontWeight.w700,
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (package.sku == PaywallSku.yearly)
                  const _Pill(label: '7 days free'),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(label, style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
}

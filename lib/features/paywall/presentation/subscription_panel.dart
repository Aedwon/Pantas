import 'package:cse_cet_reviewer/features/paywall/domain/entitlement.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/trial_notice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubscriptionPanel extends StatelessWidget {
  const SubscriptionPanel({
    required this.entitlement,
    this.today,
    this.onTryPro,
    this.onRestore,
    this.onManage,
    super.key,
  });

  final Entitlement entitlement;
  final DateTime? today;
  final VoidCallback? onTryPro;
  final VoidCallback? onRestore;
  final VoidCallback? onManage;

  @override
  Widget build(BuildContext context) {
    final canManage = entitlement.proIsActive && !entitlement.isLifetime;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_statusText()),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                if (!entitlement.proIsActive)
                  TextButton(onPressed: onTryPro, child: const Text('Try Pro')),
                if (canManage)
                  TextButton(
                    onPressed: onManage,
                    child: const Text('Manage in Google Play'),
                  ),
                TextButton(
                  onPressed: onRestore,
                  child: const Text('Restore Purchases'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusText() {
    if (!entitlement.proIsActive) return "You're on Free.";
    if (entitlement.isLifetime) return 'Pro · Lifetime · yours forever.';

    final expiration = entitlement.expiresAt;
    final date =
        expiration == null ? null : DateFormat.MMMd().format(expiration);
    if (entitlement.isTrial && expiration != null) {
      final notice = TrialNotice.fromEntitlement(
        entitlement,
        today: today ?? DateTime.now(),
      );
      final days = notice?.daysRemaining ?? 0;
      return 'Pro trial · $days days left · then ₱499/year on $date';
    }

    final label = switch (entitlement.plan) {
      EntitlementPlan.monthly => 'Monthly',
      EntitlementPlan.yearly => 'Yearly',
      EntitlementPlan.lifetime => 'Lifetime',
      EntitlementPlan.free => 'Free',
    };

    if (!entitlement.willRenew && date != null) {
      return "Pro · $label · ends $date (won't renew)";
    }
    if (date != null) return 'Pro · $label · renews $date';
    return 'Pro · $label';
  }
}

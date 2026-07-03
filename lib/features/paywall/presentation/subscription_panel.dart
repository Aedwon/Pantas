import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/ruled_section.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
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
    final styles = context.textStyles;
    final colors = context.colors;
    final canManage = entitlement.proIsActive;

    Widget quietAction(String label, VoidCallback? onTap) => GestureDetector(
          onTap: onTap,
          child: Text(
            label,
            style: styles.labelLarge.copyWith(color: colors.board),
          ),
        );

    return RuledSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_statusText(), style: styles.bodyMedium),
          const SizedBox(height: 12),
          if (!entitlement.proIsActive) ...[
            BoardButton(label: 'Try Pro', onPressed: onTryPro),
            const SizedBox(height: 12),
          ],
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              if (canManage) quietAction('Manage in Google Play', onManage),
              quietAction('Restore purchases', onRestore),
            ],
          ),
        ],
      ),
    );
  }

  String _statusText() {
    if (!entitlement.proIsActive) return "You're on Free.";

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
      EntitlementPlan.weekly => 'Weekly',
      EntitlementPlan.monthly => 'Monthly',
      EntitlementPlan.yearly => 'Yearly',
      EntitlementPlan.free => 'Free',
    };

    if (!entitlement.willRenew && date != null) {
      return "Pro · $label · ends $date (won't renew)";
    }
    if (date != null) return 'Pro · $label · renews $date';
    return 'Pro · $label';
  }
}

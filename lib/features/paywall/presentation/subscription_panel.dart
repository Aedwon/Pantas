import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/ruled_section.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/trial_notice.dart';

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
    if (entitlement.isTrial) {
      final notice = expiration == null
          ? null
          : TrialNotice.fromEntitlement(
              entitlement,
              today: today ?? DateTime.now(),
            );
      final days = notice?.daysRemaining;
      final lead = days == null ? 'Pro trial' : 'Pro trial · $days days left';
      if (date == null) return lead;
      return entitlement.willRenew
          ? '$lead · charges $date'
          : '$lead · ends $date';
    }

    if (entitlement.isUnknownPlan) {
      if (date == null) return 'Pro';
      return entitlement.willRenew
          ? 'Pro · renews $date'
          : 'Pro · ends $date';
    }

    final label = switch (entitlement.plan) {
      EntitlementPlan.weekly => 'Weekly',
      EntitlementPlan.monthly => 'Monthly',
      EntitlementPlan.yearly => 'Yearly',
      EntitlementPlan.free => 'Pro',
    };
    if (date == null) return 'Pro · $label';
    return entitlement.willRenew
        ? 'Pro · $label · renews $date'
        : 'Pro · $label · ends $date';
  }
}

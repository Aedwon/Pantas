import 'package:cse_cet_reviewer/core/ui/components/page_scaffold.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_bar.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_group.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_value_row.dart';
import 'package:cse_cet_reviewer/features/paywall/application/paywall_providers.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/entitlement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ProPage extends ConsumerWidget {
  const ProPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitlement =
        ref.watch(entitlementProvider).valueOrNull ?? const Entitlement.free();

    final planName = switch (entitlement.plan) {
      EntitlementPlan.free => 'Free',
      EntitlementPlan.weekly => 'Weekly',
      EntitlementPlan.monthly => 'Monthly',
      EntitlementPlan.yearly => 'Yearly',
    };

    final String? renewsValue;
    if (entitlement.expiresAt != null) {
      renewsValue = DateFormat.yMMMd().format(entitlement.expiresAt!);
    } else {
      renewsValue = null;
    }

    return PageScaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SettingsBar(title: 'Pro'),
          SettingsGroup(
            title: 'Current plan',
            isFirst: true,
            children: [
              SettingsValueRow(
                title: 'Plan',
                value: planName,
              ),
              if (renewsValue != null)
                SettingsValueRow(
                  title: 'Renews',
                  value: renewsValue,
                ),
            ],
          ),
          SettingsGroup(
            title: 'Plans',
            children: const [
              SettingsValueRow(
                title: 'Weekly',
                value: '₱29 / week',
              ),
              SettingsValueRow(
                title: 'Monthly',
                value: '₱99 / month',
              ),
              SettingsValueRow(
                title: 'Yearly',
                value: '₱999 / year (7-day free trial)',
              ),
            ],
          ),
          SettingsGroup(
            title: 'Manage',
            children: [
              SettingsValueRow(
                title: 'Manage in Google Play',
                showChevron: true,
                onTap: () {},
              ),
              SettingsValueRow(
                title: 'Restore purchases',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

enum SettingsEntitlementPlan { free, weekly, monthly, yearly, lifetime }

@immutable
class SettingsEntitlementSnapshot {
  const SettingsEntitlementSnapshot({
    required this.plan,
    this.expiresAt,
    this.isTrial = false,
    this.willRenew = true,
  });

  const SettingsEntitlementSnapshot.free()
      : plan = SettingsEntitlementPlan.free,
        expiresAt = null,
        isTrial = false,
        willRenew = false;

  final SettingsEntitlementPlan plan;
  final DateTime? expiresAt;
  final bool isTrial;
  final bool willRenew;

  bool get isLifetime => plan == SettingsEntitlementPlan.lifetime;
  bool get isActivePaid => plan != SettingsEntitlementPlan.free;
}

String? deleteAccountBillingLine(SettingsEntitlementSnapshot entitlement) {
  if (!entitlement.isActivePaid) return null;
  if (entitlement.isTrial) {
    return 'Your free trial will end if you delete now. If you have already '
        'been charged, cancel in Google Play first to stop future billing.';
  }
  if (entitlement.isLifetime) {
    return 'You bought Pro Lifetime on this account. If you delete, you will '
        'lose Pro access. You can restore it on a new account with Restore '
        'Purchases.';
  }
  if (!entitlement.willRenew && entitlement.expiresAt != null) {
    final date = DateFormat.MMMd().format(entitlement.expiresAt!);
    return 'Your Pro access ends on $date. Deleting your account ends it '
        'sooner.';
  }
  return "If you pay for Pro, you'll still be charged. Cancel your "
      'subscription in Google Play first so the billing stops.';
}

String? anonymousDeleteWarning(SettingsEntitlementSnapshot entitlement) {
  if (!entitlement.isLifetime) return null;
  return "You haven't signed in. If you delete now, you will lose your "
      'Lifetime purchase on this device. Sign in first to keep it.';
}

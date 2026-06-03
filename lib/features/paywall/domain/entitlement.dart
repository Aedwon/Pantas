import 'package:meta/meta.dart';

enum EntitlementPlan { free, weekly, monthly, yearly, lifetime }

@immutable
class Entitlement {
  const Entitlement({
    required this.plan,
    this.productId,
    this.expiresAt,
    this.isTrial = false,
    this.willRenew = true,
  });

  const Entitlement.free()
      : plan = EntitlementPlan.free,
        productId = null,
        expiresAt = null,
        isTrial = false,
        willRenew = false;

  final EntitlementPlan plan;
  final String? productId;
  final DateTime? expiresAt;
  final bool isTrial;
  final bool willRenew;

  bool get proIsActive => plan != EntitlementPlan.free;
  bool get isLifetime => plan == EntitlementPlan.lifetime;

  @override
  bool operator ==(Object other) {
    return other is Entitlement &&
        other.plan == plan &&
        other.productId == productId &&
        other.expiresAt == expiresAt &&
        other.isTrial == isTrial &&
        other.willRenew == willRenew;
  }

  @override
  int get hashCode {
    return Object.hash(plan, productId, expiresAt, isTrial, willRenew);
  }
}

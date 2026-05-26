enum EntitlementPlan { free, monthly, yearly, lifetime }

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
}

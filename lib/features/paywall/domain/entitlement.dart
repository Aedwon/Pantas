import 'package:meta/meta.dart';

enum EntitlementPlan { free, weekly, monthly, yearly }

@immutable
class Entitlement {
  const Entitlement({
    required this.plan,
    this.productId,
    this.expiresAt,
    this.isTrial = false,
    this.willRenew = true,
    this.isUnknownPlan = false,
  });

  const Entitlement.free()
      : plan = EntitlementPlan.free,
        productId = null,
        expiresAt = null,
        isTrial = false,
        willRenew = false,
        isUnknownPlan = false;

  const Entitlement.activeUnknown({
    required String productId,
    DateTime? expiresAt,
    bool isTrial = false,
    bool willRenew = true,
  })  : plan = EntitlementPlan.free,
        productId = productId,
        expiresAt = expiresAt,
        isTrial = isTrial,
        willRenew = willRenew,
        isUnknownPlan = true;

  final EntitlementPlan plan;
  final String? productId;
  final DateTime? expiresAt;
  final bool isTrial;
  final bool willRenew;

  /// True when RevenueCat says Pro is active on a product this build does not
  /// recognize. The raw product id is retained and no known plan is guessed.
  final bool isUnknownPlan;

  bool get proIsActive => isUnknownPlan || plan != EntitlementPlan.free;

  @override
  bool operator ==(Object other) {
    return other is Entitlement &&
        other.plan == plan &&
        other.productId == productId &&
        other.expiresAt == expiresAt &&
        other.isTrial == isTrial &&
        other.willRenew == willRenew &&
        other.isUnknownPlan == isUnknownPlan;
  }

  @override
  int get hashCode {
    return Object.hash(
      plan,
      productId,
      expiresAt,
      isTrial,
      willRenew,
      isUnknownPlan,
    );
  }
}

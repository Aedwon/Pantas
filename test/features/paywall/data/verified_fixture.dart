import 'package:pantas/features/paywall/data/revenuecat_sdk.dart';

/// Old success cases now model signed server answers. Raw verification tests
/// bypass this fixture and return the exact untrusted answer under test.
RevenueCatCustomerInfoSnapshot verifiedFixture(
  RevenueCatCustomerInfoSnapshot info, {
  bool supplyInactiveDate = true,
}) {
  final at = info.requestDate ??
      (info.proIsActive || supplyInactiveDate ? DateTime.now().toUtc() : null);
  if (info.proIsActive) {
    return RevenueCatCustomerInfoSnapshot.active(
      productId: info.productId,
      expiresAt: info.expiresAt,
      isTrial: info.isTrial,
      willRenew: info.willRenew,
      requestDate: at,
      subscriptions: info.subscriptions,
      promotions: info.promotions,
      nonSubscriptionPurchases: info.nonSubscriptionPurchases,
      billingIssuesDetectedAt: info.billingIssuesDetectedAt,
      verification: VerificationResult.verified,
    );
  }
  return RevenueCatCustomerInfoSnapshot.inactive(
    requestDate: at,
    verification: VerificationResult.verified,
  );
}

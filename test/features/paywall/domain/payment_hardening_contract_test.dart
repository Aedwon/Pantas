import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/paywall_offering.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';

void main() {
  group('unknown active subscription', () {
    test('stays Pro without pretending to be Monthly', () {
      final entitlement = Entitlement.activeUnknown(
        productId: 'pantas_pro_future:future-base-plan',
        expiresAt: DateTime.utc(2027, 1, 2),
        willRenew: false,
      );

      expect(entitlement.proIsActive, isTrue);
      expect(entitlement.isUnknownPlan, isTrue);
      expect(entitlement.plan, isNot(EntitlementPlan.monthly));
      expect(entitlement.productId, 'pantas_pro_future:future-base-plan');
      expect(entitlement.willRenew, isFalse);
    });
  });

  group('money operation result', () {
    test('keeps operation outcome separate from entitlement truth', () {
      const cachedPro = Entitlement(plan: EntitlementPlan.yearly);
      const result = PaymentOperationResult.failure(
        status: PaymentOperationStatus.networkFailure,
      );

      expect(result.status, PaymentOperationStatus.networkFailure);
      expect(result.confirmedEntitlement, isNull);
      expect(cachedPro.proIsActive, isTrue);
    });

    test('restore can complete authoritatively with no active subscription',
        () {
      const result = PaymentOperationResult.authoritative(
        status: PaymentOperationStatus.noActiveSubscription,
        entitlement: Entitlement.free(),
      );

      expect(result.status, PaymentOperationStatus.noActiveSubscription);
      expect(result.confirmedEntitlement, const Entitlement.free());
    });
  });

  group('offering result', () {
    const monthly = PaywallPackage(
      sku: PaywallSku.monthly,
      productId: 'pantas_pro_monthly',
      priceString: '₱99',
      priceAmount: 99,
    );

    test('loading is an explicit typed state', () {
      expect(
        const PaywallOfferingResult.loading().status,
        PaywallOfferingStatus.loading,
      );
    });

    test('mixed products preserve recognized and unrecognized details', () {
      const result = PaywallOfferingResult(
        status: PaywallOfferingStatus.mixedProducts,
        recognizedPackages: [monthly],
        unrecognizedProductIds: ['pantas_pro_future'],
      );

      expect(result.status, PaywallOfferingStatus.mixedProducts);
      expect(result.recognizedPackages, [monthly]);
      expect(result.unrecognizedProductIds, ['pantas_pro_future']);
    });

    test('no offering and empty offering are different states', () {
      expect(
        const PaywallOfferingResult.noCurrentOffering().status,
        PaywallOfferingStatus.noCurrentOffering,
      );
      expect(
        const PaywallOfferingResult.emptyCurrentOffering().status,
        PaywallOfferingStatus.emptyCurrentOffering,
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/data/entitlement_snapshot_store.dart';
import 'package:pantas/features/paywall/data/live_revenuecat_gateway.dart';
import 'package:pantas/features/paywall/data/payment_entitlement_state.dart';
import 'package:pantas/features/paywall/data/revenuecat_sdk.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/paywall_offering.dart';

import 'verified_fixture.dart';

void main() {
  PaymentEntitlementState stateFor([Map<String, String>? values]) {
    final backing = values ?? <String, String>{};
    return PaymentEntitlementState(
      EntitlementSnapshotStore(
        readValue: (key) async => backing[key],
        writeValue: (key, value) async => backing[key] = value,
      ),
    );
  }

  group('entitlement mapping', () {
    test('maps Weekly, Monthly, and Yearly active products', () {
      final cases = {
        'pantas_pro_weekly': EntitlementPlan.weekly,
        'pantas_pro_monthly': EntitlementPlan.monthly,
        'pantas_pro_yearly': EntitlementPlan.yearly,
      };

      for (final entry in cases.entries) {
        final entitlement = entitlementFromCustomerInfo(
          RevenueCatCustomerInfoSnapshot.active(
            productId: entry.key,
          ),
        );
        expect(entitlement.plan, entry.value, reason: entry.key);
        expect(entitlement.proIsActive, isTrue, reason: entry.key);
      }
    });

    test('maps Yearly trial and canceled-but-active truthfully', () {
      final entitlement = entitlementFromCustomerInfo(
        RevenueCatCustomerInfoSnapshot.active(
          productId: 'pantas_pro_yearly',
          isTrial: true,
          willRenew: false,
          expiresAt: DateTime.utc(2026, 9, 4),
        ),
      );

      expect(entitlement.plan, EntitlementPlan.yearly);
      expect(entitlement.isTrial, isTrue);
      expect(entitlement.willRenew, isFalse);
      expect(entitlement.proIsActive, isTrue);
    });

    test('unknown active product remains Pro and preserves the raw product id',
        () {
      final entitlement = entitlementFromCustomerInfo(
        const RevenueCatCustomerInfoSnapshot.active(
          productId: 'pantas_pro_future:future-base-plan',
        ),
      );

      expect(entitlement.proIsActive, isTrue);
      expect(entitlement.isUnknownPlan, isTrue);
      expect(entitlement.plan, isNot(EntitlementPlan.monthly));
      expect(entitlement.productId, 'pantas_pro_future:future-base-plan');
    });

    test('Play base-plan suffix still maps to the recognized plan', () {
      final entitlement = entitlementFromCustomerInfo(
        const RevenueCatCustomerInfoSnapshot.active(
          productId: 'pantas_pro_monthly:monthly-autorenewing',
        ),
      );

      expect(entitlement.plan, EntitlementPlan.monthly);
      expect(entitlement.isUnknownPlan, isFalse);
    });
  });

  group('offering states', () {
    test('known pass is offered separately without being treated as unknown',
        () async {
      final gateway = LiveRevenueCatGateway(
        sdk: FakeRevenueCatSdk(
          offering: const RevenueCatOfferingSnapshot([
            RevenueCatProductSnapshot(
              productId: 'pantas_pass_civil_service',
              priceString: '₱499',
              priceAmount: 499,
            ),
          ]),
        ),
        entitlementState: stateFor(),
      );
      final result = await gateway.currentOffering();
      expect(result.status, PaywallOfferingStatus.available);
      expect(result.unrecognizedProductIds, isEmpty);
      expect(result.recognizedPackages, isEmpty);
      expect(result.passPackages.single.productId, 'pantas_pass_civil_service');
      expect(result.passPackages.single.priceString, '₱499');
      expect(result.passPackages.single.priceAmount, 499);
    });

    test('recognized packages are available', () async {
      final sdk = FakeRevenueCatSdk(
        offering: const RevenueCatOfferingSnapshot([
          RevenueCatProductSnapshot(
            productId: 'pantas_pro_weekly',
            priceString: '₱29',
            priceAmount: 29,
          ),
          RevenueCatProductSnapshot(
            productId: 'pantas_pro_monthly',
            priceString: '₱99',
            priceAmount: 99,
          ),
          RevenueCatProductSnapshot(
            productId: 'pantas_pro_yearly',
            priceString: '₱799',
            priceAmount: 799,
          ),
        ]),
      );
      final gateway =
          LiveRevenueCatGateway(sdk: sdk, entitlementState: stateFor());

      final result = await gateway.currentOffering();

      expect(result.status, PaywallOfferingStatus.available);
      expect(result.recognizedPackages, hasLength(3));
    });

    test('no current offering is distinct from an empty current offering',
        () async {
      final noCurrent = LiveRevenueCatGateway(
        sdk: FakeRevenueCatSdk(),
        entitlementState: stateFor(),
      );
      final empty = LiveRevenueCatGateway(
        sdk: FakeRevenueCatSdk(
          offering: const RevenueCatOfferingSnapshot([]),
        ),
        entitlementState: stateFor(),
      );

      expect(
        (await noCurrent.currentOffering()).status,
        PaywallOfferingStatus.noCurrentOffering,
      );
      expect(
        (await empty.currentOffering()).status,
        PaywallOfferingStatus.emptyCurrentOffering,
      );
    });

    test('mixed and all-unknown offerings preserve unknown product ids',
        () async {
      final mixed = LiveRevenueCatGateway(
        sdk: FakeRevenueCatSdk(
          offering: const RevenueCatOfferingSnapshot([
            RevenueCatProductSnapshot(
              productId: 'pantas_pro_monthly',
              priceString: '₱99',
              priceAmount: 99,
            ),
            RevenueCatProductSnapshot(
              productId: 'pantas_pro_future',
              priceString: '₱149',
              priceAmount: 149,
            ),
          ]),
        ),
        entitlementState: stateFor(),
      );
      final allUnknown = LiveRevenueCatGateway(
        sdk: FakeRevenueCatSdk(
          offering: const RevenueCatOfferingSnapshot([
            RevenueCatProductSnapshot(
              productId: 'pantas_pro_future',
              priceString: '₱149',
              priceAmount: 149,
            ),
          ]),
        ),
        entitlementState: stateFor(),
      );

      final mixedResult = await mixed.currentOffering();
      expect(mixedResult.status, PaywallOfferingStatus.mixedProducts);
      expect(mixedResult.recognizedPackages, hasLength(1));
      expect(mixedResult.unrecognizedProductIds, ['pantas_pro_future']);

      final unknownResult = await allUnknown.currentOffering();
      expect(
        unknownResult.status,
        PaywallOfferingStatus.allProductsUnrecognized,
      );
      expect(unknownResult.recognizedPackages, isEmpty);
      expect(unknownResult.unrecognizedProductIds, ['pantas_pro_future']);
    });

    test('offering request failures retain their typed cause', () async {
      final cases = {
        RevenueCatFailureKind.network: PaywallOfferingStatus.networkFailure,
        RevenueCatFailureKind.store: PaywallOfferingStatus.storeFailure,
        RevenueCatFailureKind.revenueCat:
            PaywallOfferingStatus.revenueCatFailure,
        RevenueCatFailureKind.configuration:
            PaywallOfferingStatus.configurationFailure,
        RevenueCatFailureKind.developer: PaywallOfferingStatus.developerFailure,
        RevenueCatFailureKind.unknown: PaywallOfferingStatus.unknownFailure,
      };

      for (final entry in cases.entries) {
        final gateway = LiveRevenueCatGateway(
          sdk: FakeRevenueCatSdk(offeringFailure: entry.key),
          entitlementState: stateFor(),
        );
        expect(
          (await gateway.currentOffering()).status,
          entry.value,
          reason: entry.key.name,
        );
      }
    });
  });

  group('purchase and restore outcomes', () {
    test('successful purchase publishes authoritative Pro before returning',
        () async {
      final sdk = FakeRevenueCatSdk(
        purchaseInfo: const RevenueCatCustomerInfoSnapshot.active(
          productId: 'pantas_pro_monthly',
        ),
      );
      final state = stateFor();
      final gateway = LiveRevenueCatGateway(sdk: sdk, entitlementState: state);
      await gateway.initialize();

      final result = await gateway.purchase(monthlyPackage);

      expect(result.status, PaymentOperationStatus.success);
      expect(result.confirmedEntitlement?.plan, EntitlementPlan.monthly);
      expect(gateway.cachedEntitlement?.plan, EntitlementPlan.monthly);
    });

    test('nominal purchase with no active Pro is not reported as success',
        () async {
      final gateway = LiveRevenueCatGateway(
        sdk: FakeRevenueCatSdk(),
        entitlementState: stateFor(),
      );
      await gateway.initialize();

      final result = await gateway.purchase(monthlyPackage);

      expect(result.status, PaymentOperationStatus.entitlementNotActive);
      expect(result.confirmedEntitlement?.plan, EntitlementPlan.free);
      expect(result.confirmedEntitlement?.verifiedAt, isNotNull);
      expect(gateway.cachedEntitlement?.plan, EntitlementPlan.free);
    });

    test('purchase failures are classified without changing cached Pro',
        () async {
      final cases = {
        RevenueCatFailureKind.userCancelled:
            PaymentOperationStatus.userCancelled,
        RevenueCatFailureKind.network: PaymentOperationStatus.networkFailure,
        RevenueCatFailureKind.store: PaymentOperationStatus.storeFailure,
        RevenueCatFailureKind.revenueCat:
            PaymentOperationStatus.revenueCatFailure,
        RevenueCatFailureKind.configuration:
            PaymentOperationStatus.configurationFailure,
        RevenueCatFailureKind.developer:
            PaymentOperationStatus.developerFailure,
        RevenueCatFailureKind.operationInProgress:
            PaymentOperationStatus.operationAlreadyInProgress,
        RevenueCatFailureKind.unknown: PaymentOperationStatus.unknownFailure,
      };

      for (final entry in cases.entries) {
        final state = stateFor();
        await state.acceptAuthoritative(
          const Entitlement(
            plan: EntitlementPlan.yearly,
            productId: 'pantas_pro_yearly',
          ),
        );
        final gateway = LiveRevenueCatGateway(
          sdk: FakeRevenueCatSdk(purchaseFailure: entry.key),
          entitlementState: state,
        );

        final result = await gateway.purchase(monthlyPackage);

        expect(result.status, entry.value, reason: entry.key.name);
        expect(gateway.cachedEntitlement?.plan, EntitlementPlan.yearly);
      }
    });

    test('restore distinguishes Pro from no active subscription', () async {
      final proGateway = LiveRevenueCatGateway(
        sdk: FakeRevenueCatSdk(
          restoreInfo: const RevenueCatCustomerInfoSnapshot.active(
            productId: 'pantas_pro_yearly',
          ),
        ),
        entitlementState: stateFor(),
      );
      final freeGateway = LiveRevenueCatGateway(
        sdk: FakeRevenueCatSdk(),
        entitlementState: stateFor(),
      );

      expect(
        (await proGateway.restorePurchases()).status,
        PaymentOperationStatus.success,
      );
      expect(
        (await freeGateway.restorePurchases()).status,
        PaymentOperationStatus.noActiveSubscription,
      );
    });

    test('restore failure keeps the failure classification', () async {
      final gateway = LiveRevenueCatGateway(
        sdk: FakeRevenueCatSdk(
          restoreFailure: RevenueCatFailureKind.network,
        ),
        entitlementState: stateFor(),
      );

      expect(
        (await gateway.restorePurchases()).status,
        PaymentOperationStatus.networkFailure,
      );
    });
  });

  group('durable last-confirmed entitlement', () {
    test('fresh gateway instance recovers persisted Pro', () async {
      final values = <String, String>{};
      final firstState = stateFor(values);
      final firstGateway = LiveRevenueCatGateway(
        sdk: FakeRevenueCatSdk(
          purchaseInfo: const RevenueCatCustomerInfoSnapshot.active(
            productId: 'pantas_pro_yearly',
          ),
        ),
        entitlementState: firstState,
      );
      await firstGateway.initialize();
      await firstGateway.purchase(yearlyPackage);

      final secondState = stateFor(values);
      final secondGateway = LiveRevenueCatGateway(
        sdk: FakeRevenueCatSdk(),
        entitlementState: secondState,
      );
      await secondGateway.initialize();

      expect(secondGateway.cachedEntitlement?.plan, EntitlementPlan.yearly);
    });

    test('refresh failure preserves Pro and fresh inactive data revokes it',
        () async {
      final values = <String, String>{};
      final seededState = stateFor(values);
      await seededState.acceptAuthoritative(
        const Entitlement(
          plan: EntitlementPlan.monthly,
          productId: 'pantas_pro_monthly',
        ),
      );

      final failedRefresh = LiveRevenueCatGateway(
        sdk: FakeRevenueCatSdk(
          customerInfoFailure: RevenueCatFailureKind.network,
        ),
        entitlementState: stateFor(values),
      );
      await failedRefresh.initialize();
      await expectLater(
        failedRefresh.configure(androidApiKey: 'rc_key'),
        throwsA(isA<RevenueCatSdkException>()),
      );
      expect(failedRefresh.cachedEntitlement?.plan, EntitlementPlan.monthly);

      final referenceTime = DateTime.utc(2026, 8, 28, 4, 30);
      final authoritativeFree = LiveRevenueCatGateway(
        sdk: FakeRevenueCatSdk(
          customerInfo: RevenueCatCustomerInfoSnapshot.inactive(
            requestDate: referenceTime.subtract(const Duration(minutes: 1)),
          ),
        ),
        entitlementState: stateFor(values),
        referenceTime: () => referenceTime,
      );
      await authoritativeFree.initialize();
      await authoritativeFree.configure(androidApiKey: 'rc_key');
      expect(authoritativeFree.cachedEntitlement?.plan, EntitlementPlan.free);

      final fresh = LiveRevenueCatGateway(
        sdk: FakeRevenueCatSdk(),
        entitlementState: stateFor(values),
      );
      await fresh.initialize();
      expect(fresh.cachedEntitlement?.plan, EntitlementPlan.free);
    });
  });
}

const monthlyPackage = PaywallPackage(
  sku: PaywallSku.monthly,
  productId: 'pantas_pro_monthly',
  priceString: '₱99',
  priceAmount: 99,
);

const yearlyPackage = PaywallPackage(
  sku: PaywallSku.yearly,
  productId: 'pantas_pro_yearly',
  priceString: '₱799',
  priceAmount: 799,
);

class FakeRevenueCatSdk implements RevenueCatSdk {
  FakeRevenueCatSdk({
    this.customerInfo = const RevenueCatCustomerInfoSnapshot.inactive(),
    this.offering,
    this.purchaseInfo = const RevenueCatCustomerInfoSnapshot.inactive(),
    this.restoreInfo = const RevenueCatCustomerInfoSnapshot.inactive(),
    this.customerInfoFailure,
    this.offeringFailure,
    this.purchaseFailure,
    this.restoreFailure,
  });

  RevenueCatCustomerInfoSnapshot customerInfo;
  RevenueCatOfferingSnapshot? offering;
  RevenueCatCustomerInfoSnapshot purchaseInfo;
  RevenueCatCustomerInfoSnapshot restoreInfo;
  RevenueCatFailureKind? customerInfoFailure;
  RevenueCatFailureKind? offeringFailure;
  RevenueCatFailureKind? purchaseFailure;
  RevenueCatFailureKind? restoreFailure;
  void Function(RevenueCatCustomerInfoSnapshot)? listener;

  @override
  void addCustomerInfoUpdateListener(
    void Function(RevenueCatCustomerInfoSnapshot) onUpdate,
  ) {
    listener = onUpdate;
  }

  void emit(RevenueCatCustomerInfoSnapshot info) {
    customerInfo = info;
    listener?.call(verifiedFixture(info));
  }

  @override
  Future<void> invalidateCustomerInfoCache() async {}

  @override
  Future<void> configure(String androidApiKey) async {}

  @override
  Future<RevenueCatCustomerInfoSnapshot> getCustomerInfo() async {
    final failure = customerInfoFailure;
    if (failure != null) throw RevenueCatSdkException(failure);
    return verifiedFixture(customerInfo);
  }

  @override
  Future<RevenueCatOfferingSnapshot?> getCurrentOffering() async {
    final failure = offeringFailure;
    if (failure != null) throw RevenueCatSdkException(failure);
    return offering;
  }

  @override
  Future<RevenueCatCustomerInfoSnapshot> logIn(String uid) async =>
      verifiedFixture(customerInfo);

  @override
  Future<RevenueCatCustomerInfoSnapshot> purchase(
    String productId, {
    String? oldProductId,
    bool allowTrial = true,
  }) async {
    final failure = purchaseFailure;
    if (failure != null) throw RevenueCatSdkException(failure);
    return verifiedFixture(purchaseInfo);
  }

  @override
  Future<RevenueCatCustomerInfoSnapshot> restorePurchases() async {
    final failure = restoreFailure;
    if (failure != null) throw RevenueCatSdkException(failure);
    return verifiedFixture(restoreInfo);
  }
}

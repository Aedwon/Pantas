import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/application/trusted_clock.dart';
import 'package:pantas/features/paywall/data/entitlement_snapshot_store.dart';
import 'package:pantas/features/paywall/data/live_revenuecat_gateway.dart';
import 'package:pantas/features/paywall/data/payment_entitlement_state.dart';
import 'package:pantas/features/paywall/data/revenuecat_sdk.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

import 'live_revenuecat_gateway_hardening_test.dart';

void main() {
  late DateTime wall;
  late Duration elapsed;
  late Map<String, String> values;
  late TrustedClock clock;
  setUp(() {
    wall = DateTime.utc(2026, 10, 10, 12);
    elapsed = const Duration(hours: 10);
    values = {};
    clock = TrustedClock(
      readValue: (key) async => values[key],
      writeValue: (key, value) async => values[key] = value,
      deviceNow: () => wall,
      elapsedNow: () async => elapsed,
    );
  });
  RevenueCatCustomerInfoSnapshot active(
    VerificationResult verification,
    DateTime requestDate,
    DateTime expiresAt,
  ) =>
      RevenueCatCustomerInfoSnapshot.active(
        productId: 'pantas_pro_monthly',
        expiresAt: expiresAt,
        requestDate: requestDate,
        verification: verification,
      );
  LiveRevenueCatGateway gateway(
    _RawSdk sdk, {
    PaymentEntitlementState? state,
  }) =>
      LiveRevenueCatGateway(
        sdk: sdk,
        trustedClock: clock,
        entitlementState: state,
        referenceTime: () => wall,
      );

  for (final verification in [
    VerificationResult.failed,
    VerificationResult.verifiedOnDevice,
    VerificationResult.notRequested,
  ]) {
    test('AC-6 $verification never grants or resets trusted time', () async {
      final sdk = _RawSdk()
        ..customerInfo = active(
          verification,
          wall,
          wall.add(const Duration(days: 30)),
        );
      final g = gateway(sdk);
      await g.logIn('test-account');
      await g.configure(androidApiKey: 'test-only-key');
      expect(g.cachedEntitlement!.proIsActive, isFalse);
      expect(clock.trustedTime, isNull);
    });
  }

  test('AC-6 unverified purchase and restore cannot report success', () async {
    final response = active(
      VerificationResult.failed,
      wall,
      wall.add(const Duration(days: 30)),
    );
    final sdk = _RawSdk()
      ..purchaseInfo = response
      ..restoreInfo = response;
    final g = gateway(sdk);
    await g.logIn('test-account');
    expect(
      (await g.purchase(monthlyPackage)).status,
      PaymentOperationStatus.entitlementNotActive,
    );
    expect(
      (await g.restorePurchases()).status,
      PaymentOperationStatus.entitlementNotActive,
    );
    expect(g.cachedEntitlement!.proIsActive, isFalse);
  });

  test('AC-1 cache cannot reset; one fresh check unpauses after a setback',
      () async {
    final trusted = wall;
    final sdk = _RawSdk()
      ..customerInfo = active(
        VerificationResult.verified,
        trusted,
        trusted.add(const Duration(days: 30)),
      );
    final g = gateway(sdk);
    await g.logIn('test-account');
    await g.configure(androidApiKey: 'test-only-key');
    wall = wall.subtract(const Duration(minutes: 11));
    elapsed += const Duration(seconds: 1);
    await clock.observe();
    await g.configure(androidApiKey: 'test-only-key');
    expect(g.cachedEntitlement!.state, EntitlementState.paused);
    expect(clock.windowConsumed, isTrue);
    expect(sdk.invalidations, greaterThan(0));
    wall = trusted.add(const Duration(minutes: 1));
    sdk.customerInfo = active(
      VerificationResult.verified,
      wall,
      trusted.add(const Duration(days: 30)),
    );
    await g.configure(androidApiKey: 'test-only-key');
    expect(clock.windowConsumed, isFalse);
    expect(
      g.cachedEntitlement!.coversExam(
        'exam_upcat',
        examTier: PriceTier.student,
      ),
      isTrue,
    );
  });

  test('AC-1 clearing SDK cache and failed fetch keeps the app snapshot',
      () async {
    final state = PaymentEntitlementState(EntitlementSnapshotStore.inMemory());
    await state.writeOwner('test-account');
    await state.acceptAuthoritative(
      Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_pro_monthly',
        expiresAt: wall.subtract(const Duration(days: 1)),
      ),
    );
    final sdk = _RawSdk()..customerInfoFailure = RevenueCatFailureKind.network;
    final g = gateway(sdk, state: state);
    await g.logIn('test-account');
    await expectLater(
      g.configure(androidApiKey: 'test-only-key'),
      throwsA(isA<RevenueCatSdkException>()),
    );
    expect(sdk.invalidations, greaterThan(0));
    expect(
      g.cachedEntitlement!.coversExam(
        'exam_upcat',
        examTier: PriceTier.student,
      ),
      isTrue,
    );
  });

  test('AC-1 older inactive evidence cannot revoke newer active evidence',
      () async {
    final sdk = _RawSdk()
      ..customerInfo = active(
        VerificationResult.verified,
        wall,
        wall.add(const Duration(days: 30)),
      );
    final g = gateway(sdk);
    await g.logIn('test-account');
    await g.configure(androidApiKey: 'test-only-key');
    sdk.customerInfo = RevenueCatCustomerInfoSnapshot.inactive(
      requestDate: wall.subtract(const Duration(minutes: 1)),
      verification: VerificationResult.verified,
    );
    await g.configure(androidApiKey: 'test-only-key');
    expect(g.cachedEntitlement!.proIsActive, isTrue);
  });
}

class _RawSdk extends FakeRevenueCatSdk {
  int invalidations = 0;
  @override
  Future<RevenueCatCustomerInfoSnapshot> logIn(String uid) async =>
      customerInfo;
  @override
  Future<RevenueCatCustomerInfoSnapshot> purchase(
    String productId, {
    String? oldProductId,
    bool allowTrial = true,
  }) async =>
      purchaseInfo;
  @override
  Future<RevenueCatCustomerInfoSnapshot> restorePurchases() async =>
      restoreInfo;
  @override
  Future<void> invalidateCustomerInfoCache() async {
    invalidations++;
  }

  @override
  Future<RevenueCatCustomerInfoSnapshot> getCustomerInfo() async {
    if (customerInfoFailure != null) {
      throw RevenueCatSdkException(customerInfoFailure!);
    }
    return customerInfo;
  }
}

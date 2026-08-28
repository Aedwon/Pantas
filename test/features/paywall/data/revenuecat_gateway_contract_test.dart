import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/paywall.dart';

void main() {
  test(
    'gateway contract exposes initialize configure offerings purchase restore and stream',
    () async {
      final gateway = RecordingRevenueCatGateway();
      const package = PaywallPackage(
        sku: PaywallSku.monthly,
        productId: 'pantas_pro_monthly',
        priceString: '₱99',
        priceAmount: 99,
      );

      await gateway.initialize();
      await gateway.configure(androidApiKey: 'key');
      await gateway.logIn('uid_1');
      final offering = await gateway.currentOffering();
      final purchased = await gateway.purchase(package);
      final restored = await gateway.restorePurchases();

      expect(gateway.initializeCount, 1);
      expect(gateway.configuredKey, 'key');
      expect(gateway.loggedInUid, 'uid_1');
      expect(offering.status, PaywallOfferingStatus.available);
      expect(offering.recognizedPackages.single.productId, 'pantas_pro_monthly');
      expect(purchased.status, PaymentOperationStatus.success);
      expect(purchased.confirmedEntitlement?.proIsActive, isTrue);
      expect(restored.status, PaymentOperationStatus.success);
      expect(restored.confirmedEntitlement?.proIsActive, isTrue);
    },
  );

  test('gateway stream emits authoritative entitlement updates', () async {
    final gateway = RecordingRevenueCatGateway();

    expect(gateway.cachedEntitlement, const Entitlement.free());
    final expectation = expectLater(
      gateway.customerInfoUpdates,
      emits(const Entitlement(plan: EntitlementPlan.yearly)),
    );
    gateway.emit(const Entitlement(plan: EntitlementPlan.yearly));
    await expectation;
  });
}

class RecordingRevenueCatGateway implements RevenueCatGateway {
  final _controller = StreamController<Entitlement>.broadcast();
  String? configuredKey;
  String? loggedInUid;
  int initializeCount = 0;

  @override
  Entitlement? cachedEntitlement = const Entitlement.free();

  @override
  Stream<Entitlement> get customerInfoUpdates => _controller.stream;

  void emit(Entitlement entitlement) {
    cachedEntitlement = entitlement;
    _controller.add(entitlement);
  }

  @override
  Future<void> initialize() async {
    initializeCount += 1;
  }

  @override
  Future<void> configure({required String androidApiKey}) async {
    configuredKey = androidApiKey;
  }

  @override
  Future<PaywallOfferingResult> currentOffering() async {
    return const PaywallOfferingResult(
      status: PaywallOfferingStatus.available,
      recognizedPackages: [
        PaywallPackage(
          sku: PaywallSku.monthly,
          productId: 'pantas_pro_monthly',
          priceString: '₱99',
          priceAmount: 99,
        ),
      ],
    );
  }

  @override
  Future<void> logIn(String uid) async {
    loggedInUid = uid;
  }

  @override
  Future<PaymentOperationResult> purchase(PaywallPackage package) async {
    return const PaymentOperationResult.authoritative(
      status: PaymentOperationStatus.success,
      entitlement: Entitlement(plan: EntitlementPlan.monthly),
    );
  }

  @override
  Future<PaymentOperationResult> restorePurchases() async {
    return const PaymentOperationResult.authoritative(
      status: PaymentOperationStatus.success,
      entitlement: Entitlement(plan: EntitlementPlan.monthly),
    );
  }
}

import 'dart:async';

import 'package:cse_cet_reviewer/features/paywall/paywall.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'gateway contract exposes configure offerings purchase restore and stream',
    () async {
      final gateway = RecordingRevenueCatGateway();
      const package = PaywallPackage(
        sku: PaywallSku.monthly,
        productId: 'pro_monthly',
        priceString: '₱99',
      );

      await gateway.configure(androidApiKey: 'key');
      await gateway.logIn('uid_1');
      final offerings = await gateway.currentOffering();
      final purchased = await gateway.purchase(package);
      final restored = await gateway.restorePurchases();

      expect(gateway.configuredKey, 'key');
      expect(gateway.loggedInUid, 'uid_1');
      expect(offerings.single.productId, 'pro_monthly');
      expect(purchased.proIsActive, isTrue);
      expect(restored.proIsActive, isTrue);
    },
  );

  test('gateway stream emits optimistic cached entitlement', () async {
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

  @override
  Entitlement? cachedEntitlement = const Entitlement.free();

  @override
  Stream<Entitlement> get customerInfoUpdates => _controller.stream;

  void emit(Entitlement entitlement) {
    cachedEntitlement = entitlement;
    _controller.add(entitlement);
  }

  @override
  Future<void> configure({required String androidApiKey}) async {
    configuredKey = androidApiKey;
  }

  @override
  Future<List<PaywallPackage>> currentOffering() async {
    return const [
      PaywallPackage(
        sku: PaywallSku.monthly,
        productId: 'pro_monthly',
        priceString: '₱99',
      ),
    ];
  }

  @override
  Future<void> logIn(String uid) async {
    loggedInUid = uid;
  }

  @override
  Future<Entitlement> purchase(PaywallPackage package) async {
    return const Entitlement(plan: EntitlementPlan.monthly);
  }

  @override
  Future<Entitlement> restorePurchases() async {
    return const Entitlement(plan: EntitlementPlan.monthly);
  }
}

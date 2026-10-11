import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/features/paywall/data/live_revenuecat_gateway.dart';
import 'package:pantas/features/paywall/data/pass_ledger_source.dart';
import 'package:pantas/features/paywall/data/revenuecat_sdk.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/pass_offering.dart';
import 'package:pantas/features/paywall/domain/paywall_offering.dart';

import 'live_revenuecat_gateway_hardening_test.dart';

final at = DateTime.utc(2026, 10, 10);
final end = DateTime.utc(2027, 3, 14, 15, 59, 59, 999);
const package = PaywallPassPackage(
  productId: 'pantas_pass_cse_pro',
  priceString: 'store price',
  priceAmount: 499,
);
ExamCatalogEntry exam(String id, {bool dates = true}) => ExamCatalogEntry(
      id: id,
      name: id,
      shortName: id,
      priceTier: 'Civil Service',
      group: 'Civil service',
      comingSoon: false,
      hasContent: true,
      publishedSittings: dates
          ? [
              PublishedExamSitting(
                firstDay: DateTime.utc(2027, 3, 14),
                lastDay: DateTime.utc(2027, 3, 14),
                sourceUrl: 'https://example.test/official',
              ),
            ]
          : [],
    );
RevenueCatCustomerInfoSnapshot answer(
  DateTime date, {
  VerificationResult verification = VerificationResult.verified,
}) =>
    RevenueCatCustomerInfoSnapshot.inactive(
      requestDate: date,
      verification: verification,
    );

void main() {
  test('AC-4 ledger reader rejects revoked, unknown and wrong-exam records',
      () {
    final rows = [
      {
        'product': 'pantas_pass_cse_pro',
        'examId': 'exam_cse_pro',
        'endsAt': end.millisecondsSinceEpoch,
        'state': 'active',
      },
      {
        'product': 'pantas_pass_cse_pro',
        'examId': 'exam_let',
        'endsAt': end.millisecondsSinceEpoch,
        'state': 'active',
      },
      {
        'product': 'pantas_pass_cse_sub',
        'examId': 'exam_cse_sub',
        'endsAt': end.millisecondsSinceEpoch,
        'state': 'revoked',
      },
      {
        'product': 'unknown',
        'examId': 'exam_cse_sub',
        'endsAt': end.millisecondsSinceEpoch,
        'state': 'active',
      },
    ];
    expect(passesFromLedger(rows), {'exam_cse_pro': end});
  });

  test(
      'AC-4 only the selected exam pass can be offered, '
      'with a published sitting', () {
    const offering = PaywallOfferingResult(
      status: PaywallOfferingStatus.available,
      passPackages: [
        package,
        PaywallPassPackage(
          productId: 'pantas_pass_cse_sub',
          priceString: 'store price',
          priceAmount: 499,
        ),
      ],
    );
    expect(
      passForExam(offering, exam('exam_cse_pro'), at: at)?.productId,
      'pantas_pass_cse_pro',
    );
    expect(
      passForExam(offering, exam('exam_cse_sub'), at: at)?.productId,
      'pantas_pass_cse_sub',
    );
    expect(
      passForExam(offering, exam('exam_cse_pro', dates: false), at: at),
      isNull,
    );
  });

  test(
      'AC-4 verified customer answer unions only the owner ledger; '
      'account switch clears it', () async {
    final ledger = FakePassLedger();
    final sdk = PassSdk()..customerInfo = answer(at);
    ledger.values['first'] = {'exam_cse_pro': end};
    final gateway = LiveRevenueCatGateway(
      sdk: sdk,
      passLedger: ledger,
      referenceTime: () => at,
    );
    await gateway.logIn('first');
    expect(gateway.cachedEntitlement!.coversExam('exam_cse_pro'), isTrue);
    expect(gateway.cachedEntitlement!.coversExam('exam_cse_sub'), isFalse);
    sdk.customerInfo = answer(at.add(const Duration(seconds: 1)));
    await gateway.logIn('second');
    expect(gateway.cachedEntitlement!.passes, isEmpty);
    ledger.send('first', {'exam_cse_pro': end});
    await pumpEventQueue();
    expect(gateway.cachedEntitlement!.passes, isEmpty);
    await gateway.clearIdentity();
    await ledger.close();
  });

  test(
      'AC-4 ledger changes refresh verification, revoke '
      'and never grant from a failed answer', () async {
    final ledger = FakePassLedger();
    final sdk = PassSdk()..customerInfo = answer(at);
    final gateway = LiveRevenueCatGateway(
      sdk: sdk,
      passLedger: ledger,
      referenceTime: () => at,
    );
    await gateway.logIn('ledger-change');
    sdk.customerInfo = answer(
      at.add(const Duration(seconds: 1)),
      verification: VerificationResult.failed,
    );
    ledger.send('ledger-change', {'exam_cse_pro': end});
    await pumpEventQueue();
    expect(gateway.cachedEntitlement!.passes, isEmpty);
    sdk.customerInfo = answer(at.add(const Duration(seconds: 2)));
    ledger.send('ledger-change', {'exam_cse_pro': end});
    await pumpEventQueue();
    expect(gateway.cachedEntitlement!.coversExam('exam_cse_pro'), isTrue);
    expect(sdk.invalidations, greaterThan(0));
    sdk.customerInfo = answer(at.add(const Duration(seconds: 3)));
    ledger.send('ledger-change', {});
    await pumpEventQueue();
    expect(gateway.cachedEntitlement!.passes, isEmpty);
    await gateway.clearIdentity();
    await ledger.close();
  });

  test(
      'AC-4 pass purchase sends its product only '
      'and rejects another exam before charging', () async {
    final ledger = FakePassLedger();
    final sdk = PassSdk()..customerInfo = answer(at);
    final gateway = LiveRevenueCatGateway(
      sdk: sdk,
      passLedger: ledger,
      referenceTime: () => at,
    );
    await gateway.logIn('pass-buyer');
    await gateway.purchasePass(package, exam: exam('exam_cse_sub'));
    expect(sdk.purchases, isEmpty);
    ledger.values['pass-buyer'] = {'exam_cse_pro': end};
    sdk.purchaseInfo = answer(at.add(const Duration(seconds: 1)));
    final result =
        await gateway.purchasePass(package, exam: exam('exam_cse_pro'));
    expect(sdk.purchases, ['pantas_pass_cse_pro']);
    expect(sdk.allowTrial, isFalse);
    expect(result.confirmedEntitlement!.coversExam('exam_cse_pro'), isTrue);
    await gateway.clearIdentity();
    await ledger.close();
  });

  test('AC-4 a fresh verified check excludes an expired ledger pass', () async {
    final ledger = FakePassLedger();
    ledger.values['expired-pass'] = {'exam_cse_pro': end};
    final date = end.add(const Duration(seconds: 1));
    final sdk = PassSdk()..customerInfo = answer(date);
    final gateway = LiveRevenueCatGateway(
      sdk: sdk,
      passLedger: ledger,
      referenceTime: () => date,
    );
    await gateway.logIn('expired-pass');
    expect(gateway.cachedEntitlement!.passes, isEmpty);
    expect(gateway.cachedEntitlement!.state, EntitlementState.free);
    await gateway.clearIdentity();
    await ledger.close();
  });
}

class FakePassLedger implements PassLedgerSource {
  final values = <String, Map<String, DateTime>>{};
  final controllers = <String, StreamController<Map<String, DateTime>>>{};
  @override
  Future<Map<String, DateTime>> read(String uid) async => values[uid] ?? {};
  @override
  Stream<Map<String, DateTime>> watch(String uid) =>
      (controllers[uid] ??= StreamController<Map<String, DateTime>>.broadcast())
          .stream;
  void send(String uid, Map<String, DateTime> passes) {
    values[uid] = passes;
    controllers[uid]?.add(passes);
  }

  Future<void> close() async {
    for (final controller in controllers.values) {
      await controller.close();
    }
  }
}

class PassSdk extends FakeRevenueCatSdk {
  final purchases = <String>[];
  bool? allowTrial;
  int invalidations = 0;
  @override
  Future<RevenueCatCustomerInfoSnapshot> logIn(String uid) async =>
      customerInfo;
  @override
  Future<RevenueCatCustomerInfoSnapshot> getCustomerInfo() async =>
      customerInfo;
  @override
  Future<void> invalidateCustomerInfoCache() async => invalidations++;
  @override
  Future<RevenueCatCustomerInfoSnapshot> purchase(
    String productId, {
    String? oldProductId,
    bool allowTrial = true,
  }) async {
    purchases.add(productId);
    this.allowTrial = allowTrial;
    return purchaseInfo;
  }
}

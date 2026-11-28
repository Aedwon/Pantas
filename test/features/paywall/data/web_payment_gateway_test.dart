import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_async/fake_async.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/legal/domain/legal_document.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/application/trusted_clock.dart';
import 'package:pantas/features/paywall/data/entitlement_snapshot_store.dart';
import 'package:pantas/features/paywall/data/live_revenuecat_gateway.dart';
import 'package:pantas/features/paywall/data/pending_purchase_store.dart';
import 'package:pantas/features/paywall/data/revenuecat_config.dart';
import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';
import 'package:pantas/features/paywall/domain/checkout_declaration.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/paywall_offering.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

import '../../../helpers/in_memory_database.dart';

final _now = DateTime.utc(2026, 11, 2, 4);
const _day = Duration(days: 1);

Map<String, dynamic> _grant(
  String product, {
  required DateTime ends,
  DateTime? starts,
  String state = 'active',
  String source = 'paymongo',
  String tier = 'civilService',
}) =>
    {
      'source': source,
      'product': product,
      'tier': tier,
      'startsAt': (starts ?? _now).millisecondsSinceEpoch,
      'endsAt': ends.millisecondsSinceEpoch,
      'state': state,
      'createdAt': _now.millisecondsSinceEpoch,
    };

Map<String, dynamic> _trial({
  required DateTime ends,
  String state = 'active',
}) =>
    _grant(
      'web_trial',
      ends: ends,
      state: state,
      source: 'trial',
    );

// The callable and the URL opener are function seams. These classes only give
// mocktail a method to record and stub.
// ignore: one_member_abstracts
abstract class _Callable {
  Future<Object?> call(String name, Map<String, Object?> data);
}

class _MockCallable extends Mock implements _Callable {}

// ignore: one_member_abstracts
abstract class _Opener {
  Future<bool> call(Uri uri);
}

class _MockOpener extends Mock implements _Opener {}

// ignore: one_member_abstracts
abstract class _Ledger {
  Future<List<Map<String, dynamic>>> call(String uid);
}

class _MockLedger extends Mock implements _Ledger {}

// ignore: one_member_abstracts
abstract class _Refresher {
  Future<void> call(String? uid);
}

class _MockRefresher extends Mock implements _Refresher {}

FirebaseFunctionsException _error(String code) =>
    FirebaseFunctionsException(message: 'server said $code', code: code);

const _weekly = PaywallPackage(
  sku: PaywallSku.weekly,
  productId: 'pantas_cs_weekly',
  priceString: 'shown by the caller',
  priceAmount: 0,
);
const _pass = PaywallPassPackage(
  productId: 'pantas_pass_cse_pro',
  priceString: 'shown by the caller',
  priceAmount: 0,
);

ExamCatalogEntry _exam({bool dates = true}) => ExamCatalogEntry(
      id: 'exam_cse_pro',
      name: 'CSE Professional',
      shortName: 'CSE Pro',
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

void main() {
  setUpAll(() => registerFallbackValue(Uri()));

  test(
      'grant history preserves expired and revoked real end dates '
      'without granting access', () async {
    final gateway = WebPaymentGateway(
      callable: (_, __) async => null,
      readGrants: (_) async => [
        _grant('pantas_cs_monthly', ends: DateTime.utc(2026)),
        _grant(
          'pantas_pass_cse_pro',
          ends: DateTime.utc(2027),
          state: 'revoked',
        ),
        _trial(ends: DateTime.utc(2026, 2)),
        {'product': 'pantas_cs_weekly', 'endsAt': 'unknown', 'state': 'active'},
        {'product': 'made_up', 'endsAt': 1, 'state': 'active'},
      ],
      refreshClaims: (_) async {},
      openUrl: (_) async => true,
      now: () => _now,
    );
    expect(await gateway.grantHistory(), isEmpty);
    await gateway.logIn('history-owner');
    final history = await gateway.grantHistory();
    expect(
        history
            .map((row) => (row.productId, row.endsAt, row.state, row.isTrial)),
        [
          ('pantas_pass_cse_pro', DateTime.utc(2027), 'revoked', false),
          ('web_trial', DateTime.utc(2026, 2), 'active', true),
          ('pantas_cs_monthly', DateTime.utc(2026), 'active', false),
        ]);
    expect(gateway.cachedEntitlement!.plan, EntitlementPlan.free);
    await gateway.clearIdentity();
    expect(await gateway.grantHistory(), isEmpty);
  });

  test('a history read cannot cross an account change', () async {
    final pending = Completer<List<Map<String, dynamic>>>();
    var delayed = false;
    final gateway = WebPaymentGateway(
      callable: (_, __) async => null,
      readGrants: (_) => delayed ? pending.future : Future.value([]),
      refreshClaims: (_) async {},
      openUrl: (_) async => true,
    );
    await gateway.logIn('first');
    delayed = true;
    final history = gateway.grantHistory();
    await gateway.clearIdentity();
    pending.complete([_grant('pantas_cs_monthly', ends: DateTime.utc(2027))]);
    expect(await history, isEmpty);
  });

  test('Play renewal warning trusts exact server flag and clears with identity',
      () async {
    Object? flag = true;
    final gateway = WebPaymentGateway(
      callable: (_, __) async =>
          {'plans': <Object?>[], 'googlePlayPlanRenews': flag},
      readGrants: (_) async => [],
      refreshClaims: (_) async {},
      openUrl: (_) async => true,
    );
    await gateway.logIn('renewal-owner');
    await gateway.currentOffering();
    expect(gateway.googlePlayPlanRenews, isTrue);
    for (final value in <Object?>[false, null, 'true', 1]) {
      flag = value;
      await gateway.currentOffering();
      expect(gateway.googlePlayPlanRenews, isFalse);
    }
    flag = true;
    await gateway.currentOffering();
    await gateway.clearIdentity();
    expect(gateway.googlePlayPlanRenews, isFalse);
  });

  test('an offering reply cannot cross logout and same-account login',
      () async {
    final pending = Completer<Object?>();
    final gateway = WebPaymentGateway(
      callable: (_, __) => pending.future,
      readGrants: (_) async => [],
      refreshClaims: (_) async {},
      openUrl: (_) async => true,
    );
    await gateway.logIn('same-owner');
    final offering = gateway.currentOffering();
    await gateway.clearIdentity();
    await gateway.logIn('same-owner');
    pending.complete({
      'plans': <Object?>[],
      'googlePlayPlanRenews': true,
      'trialEligible': true,
    });
    expect((await offering).status, PaywallOfferingStatus.configurationFailure);
    expect(gateway.googlePlayPlanRenews, isFalse);
  });

  group('checkout', () {
    late _MockCallable callable;
    late _MockOpener opener;
    late WebPaymentGateway gateway;
    final checkoutUrl = Uri.parse('https://checkout.example.test/cs_123');

    setUp(() {
      callable = _MockCallable();
      opener = _MockOpener();
      when(() => opener(any())).thenAnswer((_) async => true);
      when(() => callable('createPaymongoCheckout', any())).thenAnswer(
        (_) async => {'checkoutUrl': '$checkoutUrl', 'sessionId': 'cs_123'},
      );
      gateway = WebPaymentGateway(
        callable: callable.call,
        readGrants: (_) async => throw StateError('checkout reads no ledger'),
        refreshClaims: (_) async => throw StateError('checkout needs no token'),
        openUrl: opener.call,
        now: () => _now,
      );
    });

    test('purchase sends the product id and opens the checkout url', () async {
      final result = await gateway.purchase(_weekly);

      verify(
        () =>
            callable('createPaymongoCheckout', {'product': 'pantas_cs_weekly'}),
      ).called(1);
      verify(() => opener(checkoutUrl)).called(1);
      // The tab leaves for PayMongo. Nothing is confirmed until it returns.
      expect(result.status, PaymentOperationStatus.operationAlreadyInProgress);
      expect(result.confirmedEntitlement, isNull);
    });

    test('a declaration is sent with its kind, wording id and Terms version',
        () async {
      const adult = CheckoutDeclaration(DeclarationKind.adult);
      const guardian = CheckoutDeclaration(DeclarationKind.guardian);
      await gateway.purchase(_weekly, declaration: adult);
      await gateway.purchasePass(_pass, exam: _exam(), declaration: guardian);

      verify(
        () => callable('createPaymongoCheckout', {
          'product': 'pantas_cs_weekly',
          'declaration': {
            'kind': 'adult',
            'wordingVersion': 'checkout-adult-2026-11-23',
            'termsVersion': guardianDocumentVersions['terms'],
          },
        }),
      ).called(1);
      verify(
        () => callable('createPaymongoCheckout', {
          'product': 'pantas_pass_cse_pro',
          'declaration': {
            'kind': 'guardian',
            'wordingVersion': 'checkout-guardian-2026-11-23',
            'termsVersion': guardianDocumentVersions['terms'],
          },
        }),
      ).called(1);
    });

    test('an already-paid refusal comes back as its own status', () async {
      when(() => callable('createPaymongoCheckout', any())).thenThrow(
        FirebaseFunctionsException(
          message: 'Your payment was received. Pro will appear shortly.',
          code: 'already-exists',
          details: const {'reason': 'already-paid'},
        ),
      );
      final result = await gateway.purchase(
        _weekly,
        declaration: const CheckoutDeclaration(DeclarationKind.adult),
      );
      expect(result.status, PaymentOperationStatus.alreadyPaid);
    });

    test('the server naming the wording it wants comes back as the kind',
        () async {
      when(() => callable('createPaymongoCheckout', any())).thenThrow(
        FirebaseFunctionsException(
          message: 'Confirm the declaration to continue.',
          code: 'failed-precondition',
          details: const {'reason': 'declaration-required', 'kind': 'guardian'},
        ),
      );
      final result = await gateway.purchase(
        _weekly,
        declaration: const CheckoutDeclaration(DeclarationKind.adult),
      );
      expect(
        result.status,
        PaymentOperationStatus.guardianConfirmationRequired,
      );
      expect(result.declarationKind, DeclarationKind.guardian);
    });

    test('purchasePass sends the pass product id and opens the url', () async {
      final result = await gateway.purchasePass(_pass, exam: _exam());

      verify(
        () => callable(
          'createPaymongoCheckout',
          {'product': 'pantas_pass_cse_pro'},
        ),
      ).called(1);
      verify(() => opener(checkoutUrl)).called(1);
      expect(result.status, PaymentOperationStatus.operationAlreadyInProgress);
    });

    test('a pass the exam does not allow never reaches the server', () async {
      final result = await gateway.purchasePass(
        _pass,
        exam: _exam(dates: false),
      );

      verifyNever(() => callable(any(), any()));
      verifyNever(() => opener(any()));
      expect(result.status, PaymentOperationStatus.developerFailure);
    });

    const mapped = {
      'invalid-argument': PaymentOperationStatus.developerFailure,
      'failed-precondition': PaymentOperationStatus.developerFailure,
      'resource-exhausted': PaymentOperationStatus.storeFailure,
      'already-exists': PaymentOperationStatus.operationAlreadyInProgress,
      'unauthenticated': PaymentOperationStatus.configurationFailure,
      'permission-denied': PaymentOperationStatus.configurationFailure,
      'unavailable': PaymentOperationStatus.networkFailure,
      'deadline-exceeded': PaymentOperationStatus.networkFailure,
      'internal': PaymentOperationStatus.unknownFailure,
    };
    for (final entry in mapped.entries) {
      test('callable error ${entry.key} maps to ${entry.value.name}', () async {
        when(() => callable(any(), any())).thenThrow(_error(entry.key));

        final result = await gateway.purchase(_weekly);

        expect(result.status, entry.value);
        verifyNever(() => opener(any()));
      });
    }

    test('an error that is not a callable error is unknown', () async {
      when(() => callable(any(), any())).thenThrow(StateError('broken'));

      expect(
        (await gateway.purchase(_weekly)).status,
        PaymentOperationStatus.unknownFailure,
      );
    });

    test('a reply without a secure url opens nothing', () async {
      for (final reply in <Object?>[
        null,
        {'sessionId': 'cs_123'},
        {'checkoutUrl': 42},
        {'checkoutUrl': 'http://checkout.example.test/cs_123'},
        {'checkoutUrl': 'not a url'},
      ]) {
        when(() => callable(any(), any())).thenAnswer((_) async => reply);

        final result = await gateway.purchase(_weekly);

        expect(result.status, PaymentOperationStatus.unknownFailure);
      }
      verifyNever(() => opener(any()));
    });

    test('a blocked or failed tab open is a failure, not a pending checkout',
        () async {
      when(() => opener(any())).thenAnswer((_) async => false);
      expect(
        (await gateway.purchase(_weekly)).status,
        PaymentOperationStatus.storeFailure,
      );

      when(() => opener(any())).thenThrow(StateError('blocked'));
      expect(
        (await gateway.purchase(_weekly)).status,
        PaymentOperationStatus.unknownFailure,
      );
    });
  });

  group('restore and checkout return', () {
    late _MockCallable callable;
    late _MockLedger ledger;
    late _MockRefresher refresher;
    late _MockOpener opener;
    late WebPaymentGateway gateway;
    var rows = <Map<String, dynamic>>[];

    setUp(() {
      rows = [];
      callable = _MockCallable();
      ledger = _MockLedger();
      refresher = _MockRefresher();
      opener = _MockOpener();
      when(() => ledger('u1')).thenAnswer((_) async => rows);
      when(() => refresher('u1')).thenAnswer((_) async {});
      gateway = WebPaymentGateway(
        callable: callable.call,
        readGrants: ledger.call,
        refreshClaims: refresher.call,
        openUrl: opener.call,
        now: () => _now,
      );
    });

    final ends = _now.add(const Duration(days: 30));

    test('logIn reads the ledger and keeps the entitlement', () async {
      rows = [_grant('pantas_cs_monthly', ends: ends)];

      await gateway.logIn('u1');

      expect(gateway.cachedEntitlement?.proIsActive, isTrue);
      expect(gateway.cachedEntitlement?.endsAt, ends);
      verify(() => ledger('u1')).called(1);
    });

    test('logIn keeps what it had when the ledger cannot be read', () async {
      when(() => ledger('u1')).thenThrow(StateError('offline'));

      await gateway.logIn('u1');

      expect(gateway.cachedEntitlement, const Entitlement.free());
    });

    test('another account never inherits the previous entitlement', () async {
      rows = [_grant('pantas_cs_monthly', ends: ends)];
      await gateway.logIn('u1');
      when(() => ledger('u2')).thenAnswer((_) async => []);

      await gateway.logIn('u2');

      expect(gateway.cachedEntitlement, const Entitlement.free());
    });

    test('logOut clears the entitlement and forgets the account', () async {
      rows = [_grant('pantas_cs_monthly', ends: ends)];
      await gateway.logIn('u1');

      await gateway.logOut();

      expect(gateway.cachedEntitlement, const Entitlement.free());
      final result = await gateway.restorePurchases();
      expect(result.status, PaymentOperationStatus.configurationFailure);
      verify(() => ledger('u1')).called(1);
    });

    test('restore refreshes the token, then reads and emits the ledger',
        () async {
      await gateway.logIn('u1');
      clearInteractions(ledger);
      rows = [_grant('pantas_cs_monthly', ends: ends)];
      final updates = <Entitlement>[];
      final subscription = gateway.customerInfoUpdates.listen(updates.add);

      final result = await gateway.restorePurchases();
      await subscription.cancel();

      verifyInOrder([() => refresher('u1'), () => ledger('u1')]);
      expect(result.status, PaymentOperationStatus.success);
      expect(result.confirmedEntitlement?.proIsActive, isTrue);
      expect(result.confirmedEntitlement?.endsAt, ends);
      expect(updates.last, result.confirmedEntitlement);
      expect(gateway.cachedEntitlement, result.confirmedEntitlement);
    });

    test('restore with no grant says there is no active plan', () async {
      await gateway.logIn('u1');

      final result = await gateway.restorePurchases();

      expect(result.status, PaymentOperationStatus.noActiveSubscription);
      expect(result.confirmedEntitlement, const Entitlement.free());
    });

    test('restore reads the ledger even if the token refresh fails', () async {
      await gateway.logIn('u1');
      when(() => refresher('u1')).thenThrow(StateError('offline'));
      rows = [_grant('pantas_cs_weekly', ends: ends)];

      final result = await gateway.restorePurchases();

      expect(result.status, PaymentOperationStatus.success);
    });

    test('restore leaves the entitlement alone if the ledger fails', () async {
      rows = [_grant('pantas_cs_monthly', ends: ends)];
      await gateway.logIn('u1');
      final before = gateway.cachedEntitlement;
      when(() => ledger('u1')).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );

      final result = await gateway.restorePurchases();

      expect(result.status, PaymentOperationStatus.networkFailure);
      expect(result.confirmedEntitlement, isNull);
      expect(gateway.cachedEntitlement, before);
    });

    test('restore with nobody signed in touches nothing', () async {
      final result = await gateway.restorePurchases();

      expect(result.status, PaymentOperationStatus.configurationFailure);
      verifyNever(() => refresher(any()));
      verifyNever(() => ledger(any()));
    });

    test('return from a paid checkout reports Pro active', () async {
      await gateway.logIn('u1');
      rows = [_grant('pantas_cs_monthly', ends: ends)];

      final result = await gateway.handleCheckoutReturn(
        Uri.parse('https://pantas.study/pro?checkout=success'),
      );

      verify(() => refresher('u1')).called(1);
      expect(result?.status, PaymentOperationStatus.success);
      expect(result?.confirmedEntitlement?.proIsActive, isTrue);
    });

    test('return before the webhook has granted is pending, not failed',
        () async {
      await gateway.logIn('u1');
      clearInteractions(ledger);

      final result = await gateway.handleCheckoutReturn(
        Uri.parse('https://pantas.study/pro?checkout=success'),
      );

      // One refresh only. There is no polling loop.
      verify(() => ledger('u1')).called(1);
      expect(result?.status, PaymentOperationStatus.entitlementNotActive);
      expect(result?.result, PaymentResult.notConfirmedYet);
      expect(result?.confirmedEntitlement, const Entitlement.free());
    });

    test('a failed read on return is a failure, not pending', () async {
      await gateway.logIn('u1');
      when(() => ledger('u1')).thenThrow(StateError('boom'));

      final result = await gateway.handleCheckoutReturn(
        Uri.parse('https://pantas.study/pro?checkout=success'),
      );

      expect(result?.status, PaymentOperationStatus.unknownFailure);
    });

    test('a cancelled checkout changes nothing and calls nothing', () async {
      await gateway.logIn('u1');
      clearInteractions(ledger);
      clearInteractions(refresher);

      final result = await gateway.handleCheckoutReturn(
        Uri.parse('https://pantas.study/pro?checkout=cancelled'),
      );

      expect(result?.status, PaymentOperationStatus.userCancelled);
      verifyNever(() => refresher(any()));
      verifyNever(() => ledger(any()));
      verifyNever(() => callable(any(), any()));
    });

    test('an address that is not a checkout return is ignored', () async {
      for (final address in [
        'https://pantas.study/pro',
        'https://pantas.study/pro?checkout=other',
        'https://pantas.study/pro?other=success',
      ]) {
        expect(await gateway.handleCheckoutReturn(Uri.parse(address)), isNull);
      }
      verifyNever(() => refresher(any()));
      verifyNever(() => ledger(any()));
    });
  });

  group('offering from the server plan list', () {
    late _MockCallable callable;
    late WebPaymentGateway gateway;

    Map<String, Object?> plan(
      String product, {
      Object? cents = 14900,
      String price = 'server price',
      Object? examId,
      Map<String, Object?> prepaid = const {'unit': 'days', 'count': 7},
    }) =>
        {
          'product': product,
          'priceCentavos': cents,
          'priceString': price,
          'prepaid': prepaid,
          'examId': examId,
        };

    final allFive = <Object?>[
      plan('pantas_cs_weekly', cents: 4900, price: 'W'),
      plan('pantas_cs_monthly', price: 'M'),
      plan('pantas_cs_yearly', cents: 119900, price: 'Y'),
      plan(
        'pantas_pass_cse_pro',
        cents: 49900,
        price: 'P1',
        examId: 'exam_cse_pro',
        prepaid: const {'unit': 'sitting'},
      ),
      plan(
        'pantas_pass_cse_sub',
        cents: 49900,
        price: 'P2',
        examId: 'exam_cse_sub',
        prepaid: const {'unit': 'sitting'},
      ),
    ];

    void reply(Object? value) => when(() => callable('listWebPlans', any()))
        .thenAnswer((_) async => value);

    setUp(() {
      callable = _MockCallable();
      reply({'plans': allFive});
      gateway = WebPaymentGateway(
        callable: callable.call,
        readGrants: (_) async => const [],
        refreshClaims: (_) async {},
        openUrl: (_) async => true,
        now: () => _now,
      );
    });

    test('asks the server and shows its price strings and amounts', () async {
      final offering = await gateway.currentOffering();

      verify(() => callable('listWebPlans', {})).called(1);
      expect(offering.status, PaywallOfferingStatus.available);
      expect(
        offering.recognizedPackages.map(
          (p) => (p.sku, p.productId, p.priceString, p.priceAmount),
        ),
        [
          (PaywallSku.weekly, 'pantas_cs_weekly', 'W', 49.0),
          (PaywallSku.monthly, 'pantas_cs_monthly', 'M', 149.0),
          (PaywallSku.yearly, 'pantas_cs_yearly', 'Y', 1199.0),
        ],
      );
      expect(offering.recognizedPackages.any((p) => p.trialEligible), isFalse);
      expect(
        offering.passPackages.map(
          (p) => (p.productId, p.priceString, p.priceAmount),
        ),
        [
          ('pantas_pass_cse_pro', 'P1', 499.0),
          ('pantas_pass_cse_sub', 'P2', 499.0),
        ],
      );
      expect(offering.unrecognizedProductIds, isEmpty);
    });

    test('server eligibility enables only the Monthly web trial', () async {
      reply({'plans': allFive, 'trialEligible': true});
      final offering = await gateway.currentOffering();
      expect(
        offering.recognizedPackages
            .where((p) => p.trialEligible)
            .map((p) => p.sku),
        [PaywallSku.monthly],
      );
      for (final value in <Object?>[false, null, 'true', 1]) {
        reply({'plans': allFive, 'trialEligible': value});
        expect(
          (await gateway.currentOffering())
              .recognizedPackages
              .any((p) => p.trialEligible),
          isFalse,
        );
      }
    });

    test('an empty list is no current offering', () async {
      reply({'plans': <Object?>[]});

      expect(
        (await gateway.currentOffering()).status,
        PaywallOfferingStatus.noCurrentOffering,
      );
    });

    test('a product this build does not know is reported, not shown', () async {
      reply({
        'plans': [plan('pantas_cs_monthly'), plan('pantas_future_plan')],
      });
      final mixed = await gateway.currentOffering();

      expect(mixed.status, PaywallOfferingStatus.mixedProducts);
      expect(mixed.recognizedPackages, hasLength(1));
      expect(mixed.unrecognizedProductIds, ['pantas_future_plan']);

      reply({
        'plans': [plan('pantas_future_plan'), plan('promo_student')],
      });
      final none = await gateway.currentOffering();

      expect(none.status, PaywallOfferingStatus.allProductsUnrecognized);
      expect(none.recognizedPackages, isEmpty);
    });

    test('a row without a valid price or exam match is never shown', () async {
      reply({
        'plans': [
          plan('pantas_cs_weekly', cents: null),
          plan('pantas_cs_monthly', cents: -1),
          plan('pantas_cs_yearly', cents: '119900'),
          plan('pantas_pass_cse_pro', examId: 'exam_cse_sub'),
          plan('pantas_pass_cse_sub'),
          plan('pantas_cs_weekly', price: ''),
        ],
      });

      final offering = await gateway.currentOffering();

      expect(offering.recognizedPackages, isEmpty);
      expect(offering.passPackages, isEmpty);
      expect(offering.status, PaywallOfferingStatus.allProductsUnrecognized);
      expect(offering.unrecognizedProductIds, hasLength(6));
    });

    test('a reply that is not a plan list is an unknown failure', () async {
      for (final bad in <Object?>[
        null,
        'plans',
        {'plans': 'none'},
        {'other': <Object?>[]},
      ]) {
        reply(bad);

        expect(
          (await gateway.currentOffering()).status,
          PaywallOfferingStatus.unknownFailure,
        );
      }
    });

    const failures = {
      'unavailable': PaywallOfferingStatus.networkFailure,
      'deadline-exceeded': PaywallOfferingStatus.networkFailure,
      'resource-exhausted': PaywallOfferingStatus.storeFailure,
      'unauthenticated': PaywallOfferingStatus.configurationFailure,
      'permission-denied': PaywallOfferingStatus.configurationFailure,
      'invalid-argument': PaywallOfferingStatus.developerFailure,
      'internal': PaywallOfferingStatus.unknownFailure,
    };
    for (final entry in failures.entries) {
      test('server error ${entry.key} is ${entry.value.name}', () async {
        when(() => callable(any(), any())).thenThrow(_error(entry.key));

        final offering = await gateway.currentOffering();

        expect(offering.status, entry.value);
        expect(offering.recognizedPackages, isEmpty);
      });
    }

    test('an error that is not a callable error is unknown', () async {
      when(() => callable(any(), any())).thenThrow(StateError('broken'));

      expect(
        (await gateway.currentOffering()).status,
        PaywallOfferingStatus.unknownFailure,
      );
    });
  });

  group('web trial', () {
    late _MockCallable callable;
    late _MockLedger ledger;
    late _MockRefresher refresher;
    late WebPaymentGateway gateway;
    var rows = <Map<String, dynamic>>[];

    setUp(() {
      rows = [];
      callable = _MockCallable();
      ledger = _MockLedger();
      refresher = _MockRefresher();
      when(() => ledger('u1')).thenAnswer((_) async => rows);
      when(() => refresher('u1')).thenAnswer((_) async {});
      when(() => callable('startWebTrial', any())).thenAnswer((_) async {
        rows = [_trial(ends: _now.add(const Duration(days: 7)))];
        return {
          'startsAt': _now.millisecondsSinceEpoch,
          'endsAt': _now.add(const Duration(days: 7)).millisecondsSinceEpoch,
        };
      });
      gateway = WebPaymentGateway(
        callable: callable.call,
        readGrants: ledger.call,
        refreshClaims: refresher.call,
        openUrl: (_) async => true,
        now: () => _now,
      );
    });

    test('starting the trial calls the server, then reads the ledger',
        () async {
      await gateway.logIn('u1');
      clearInteractions(ledger);

      final result = await gateway.startTrial();

      verify(() => callable('startWebTrial', {})).called(1);
      verifyInOrder([() => refresher('u1'), () => ledger('u1')]);
      expect(result.status, WebTrialStatus.started);
      expect(result.operation.status, PaymentOperationStatus.success);
      expect(result.operation.confirmedEntitlement?.isTrial, isTrue);
      expect(gateway.cachedEntitlement?.state, EntitlementState.trial);
    });

    test('a trial that started stays started if the ledger read fails',
        () async {
      await gateway.logIn('u1');
      when(() => ledger('u1')).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );

      final result = await gateway.startTrial();

      expect(result.status, WebTrialStatus.started);
      expect(result.operation.status, PaymentOperationStatus.networkFailure);
    });

    test('a trial already used is not available', () async {
      await gateway.logIn('u1');
      clearInteractions(ledger);
      clearInteractions(refresher);
      when(() => callable('startWebTrial', any())).thenThrow(
        _error('failed-precondition'),
      );

      final result = await gateway.startTrial();

      expect(result.status, WebTrialStatus.notAvailable);
      verifyNever(() => refresher(any()));
      verifyNever(() => ledger(any()));
    });

    const failures = {
      'resource-exhausted': PaymentOperationStatus.storeFailure,
      'permission-denied': PaymentOperationStatus.configurationFailure,
      'unauthenticated': PaymentOperationStatus.configurationFailure,
      'unavailable': PaymentOperationStatus.networkFailure,
      'internal': PaymentOperationStatus.unknownFailure,
    };
    for (final entry in failures.entries) {
      test('server error ${entry.key} is a failure, not "not available"',
          () async {
        await gateway.logIn('u1');
        when(() => callable('startWebTrial', any())).thenThrow(
          _error(entry.key),
        );

        final result = await gateway.startTrial();

        expect(result.status, WebTrialStatus.failed);
        expect(result.operation.status, entry.value);
      });
    }

    test('with nobody signed in the server is never called', () async {
      final result = await gateway.startTrial();

      expect(result.status, WebTrialStatus.failed);
      expect(
        result.operation.status,
        PaymentOperationStatus.configurationFailure,
      );
      verifyNever(() => callable(any(), any()));
    });
  });

  group('gateway selection', () {
    ProviderContainer container({
      required bool web,
      String androidApiKey = '',
    }) {
      final created = ProviderContainer(
        overrides: [
          paymentsOnWebProvider.overrideWithValue(web),
          pendingPurchaseStoreProvider.overrideWithValue(
            PendingPurchaseStore.inMemory(),
          ),
          revenueCatConfigProvider.overrideWithValue(
            RevenueCatConfig.fromEnvironment(androidApiKey: androidApiKey),
          ),
          trustedClockProvider.overrideWithValue(
            TrustedClock(
              readValue: (_) async => null,
              writeValue: (_, __) async {},
              elapsedNow: () async => null,
            ),
          ),
          entitlementSnapshotStoreProvider.overrideWithValue(
            EntitlementSnapshotStore.inMemory(),
          ),
        ],
      );
      addTearDown(created.dispose);
      return created;
    }

    test('web builds the web gateway, with or without a store key', () {
      for (final key in ['', 'goog_test_key']) {
        expect(
          container(web: true, androidApiKey: key)
              .read(revenueCatGatewayProvider),
          isA<WebPaymentGateway>(),
        );
      }
    });

    test('the web gateway serves the paywall controller pass path', () {
      expect(
        container(web: true).read(revenueCatGatewayProvider),
        isA<RevenueCatPassGateway>(),
      );
    });

    test('mobile construction is unchanged', () {
      expect(
        container(web: false).read(revenueCatGatewayProvider),
        isA<DisabledRevenueCatGateway>(),
      );
      expect(
        container(web: false, androidApiKey: 'goog_test_key')
            .read(revenueCatGatewayProvider),
        isA<LiveRevenueCatGateway>(),
      );
    });
  });

  group('grant ledger mapping', () {
    test('an active subscription grant becomes a prepaid plan', () {
      final ends = _now.add(const Duration(days: 30));
      final entitlement = entitlementFromGrants(
        [_grant('pantas_cs_monthly', ends: ends)],
        at: _now,
      );

      expect(entitlement.proIsActive, isTrue);
      expect(entitlement.plan, EntitlementPlan.monthly);
      expect(entitlement.productId, 'pantas_cs_monthly');
      expect(entitlement.tier, PriceTier.civilService);
      expect(entitlement.isTrial, isFalse);
      expect(entitlement.expiresAt, ends);
      expect(entitlement.endsAt, ends);
      // Prepaid access never renews, so no renewal or charge date is shown.
      expect(entitlement.willRenew, isFalse);
      expect(entitlement.renewsAt, isNull);
      expect(entitlement.chargesAt, isNull);
      expect(
        entitlement.coversExam(
          'exam_cse_pro',
          examTier: PriceTier.civilService,
          at: _now,
        ),
        isTrue,
      );
      expect(
        entitlement.coversExam(
          'exam_lic',
          examTier: PriceTier.licensure,
          at: _now,
        ),
        isFalse,
      );
    });

    test('a trial grant is a trial that never charges', () {
      final ends = _now.add(const Duration(days: 7));
      final entitlement = entitlementFromGrants(
        [_trial(ends: ends)],
        at: _now,
      );

      expect(entitlement.proIsActive, isTrue);
      expect(entitlement.isTrial, isTrue);
      expect(entitlement.state, EntitlementState.trial);
      expect(entitlement.tier, PriceTier.civilService);
      expect(entitlement.endsAt, ends);
      expect(entitlement.chargesAt, isNull);
      expect(entitlement.renewsAt, isNull);
      expect(
        entitlement.coversExam(
          'exam_cse_sub',
          examTier: PriceTier.civilService,
          at: _now,
        ),
        isTrue,
      );
    });

    test('a pass grant covers only its own exam', () {
      final ends = _now.add(const Duration(days: 120));
      final entitlement = entitlementFromGrants(
        [_grant('pantas_pass_cse_pro', ends: ends)],
        at: _now,
      );

      expect(entitlement.proIsActive, isTrue);
      expect(entitlement.passes, {'exam_cse_pro': ends});
      expect(entitlement.subscriptions, isEmpty);
      expect(entitlement.coversExam('exam_cse_pro', at: _now), isTrue);
      expect(
        entitlement.coversExam(
          'exam_cse_sub',
          examTier: PriceTier.civilService,
          at: _now,
        ),
        isFalse,
      );
    });

    test('a revoked grant covers nothing', () {
      final entitlement = entitlementFromGrants(
        [
          _grant(
            'pantas_cs_yearly',
            ends: _now.add(const Duration(days: 300)),
            state: 'revoked',
          ),
          _trial(ends: _now.add(_day), state: 'revoked'),
        ],
        at: _now,
      );

      expect(entitlement, const Entitlement.free());
      expect(entitlement.proIsActive, isFalse);
    });

    test('an expired grant covers nothing', () {
      final entitlement = entitlementFromGrants(
        [
          _grant('pantas_cs_weekly', ends: _now.subtract(_day)),
          _grant('pantas_cs_monthly', ends: _now),
        ],
        at: _now,
      );

      expect(entitlement, const Entitlement.free());
    });

    test('stacked grants cover until the latest end', () {
      final first = _now.add(const Duration(days: 7));
      final second = _now.add(const Duration(days: 37));
      final entitlement = entitlementFromGrants(
        [
          _grant('pantas_cs_monthly', ends: second, starts: first),
          _grant('pantas_cs_weekly', ends: first),
        ],
        at: _now,
      );

      expect(entitlement.proIsActive, isTrue);
      expect(entitlement.subscriptions, hasLength(2));
      expect(entitlement.endsAt, second);
      expect(entitlement.plan, EntitlementPlan.monthly);
      expect(entitlement.expiresAt, second);
      // Both grants stay covered as time passes, with no second read.
      expect(
        entitlement.coversExam(
          'exam_cse_pro',
          examTier: PriceTier.civilService,
          at: first.add(_day),
        ),
        isTrue,
      );
    });

    test('rows that are not recognized grants are ignored', () {
      final ends = _now.add(const Duration(days: 30));
      final entitlement = entitlementFromGrants(
        [
          _grant('pantas_future_plan', ends: ends),
          _grant('promo_unknown', ends: ends),
          _trial(ends: ends)..['tier'] = 'licensure',
          {'product': 'pantas_cs_monthly', 'state': 'active'},
          {
            ..._grant('pantas_cs_monthly', ends: ends),
            'endsAt': 'soon',
          },
        ],
        at: _now,
      );

      expect(entitlement, const Entitlement.free());
    });
  });

  group('beta reward, queued plans and overlapping reads', () {
    Map<String, dynamic> reward(
      String examId, {
      required DateTime ends,
      DateTime? starts,
    }) =>
        {
          ..._grant('beta_reward', ends: ends, starts: starts),
          'source': 'beta_reward',
          'examId': examId,
        };

    test('a beta reward shows Pro for its exam until its end, then Free', () {
      final ends = _now.add(const Duration(days: 30));
      final rows = [reward('exam_cse_pro', ends: ends)];
      final during = entitlementFromGrants(rows, at: _now);

      expect(during.coverage(at: _now).hasKnownCoverage, isTrue);
      expect(
        during.coversExam(
          'exam_cse_pro',
          examTier: PriceTier.civilService,
          at: _now,
        ),
        isTrue,
      );
      expect(
        during.coversExam(
          'exam_cse_sub',
          examTier: PriceTier.civilService,
          at: _now,
        ),
        isFalse,
      );
      expect(
        during.coversExam(
          'exam_nce',
          examTier: PriceTier.civilService,
          at: _now,
        ),
        isFalse,
      );
      expect(
        entitlementFromGrants(rows, at: ends).proIsActive,
        isFalse,
      );
      expect(
        entitlementFromGrants(rows, at: ends.add(_day)),
        const Entitlement.free(),
      );
    });

    test('a beta reward without an exam or not yet started shows nothing', () {
      final ends = _now.add(const Duration(days: 30));
      final entitlement = entitlementFromGrants(
        [
          {...reward('exam_cse_pro', ends: ends)}..remove('examId'),
          reward('exam_cse_sub', ends: ends, starts: _now.add(_day)),
        ],
        at: _now,
      );

      expect(entitlement.proIsActive, isFalse);
    });

    test('a plan queued behind a pass is not active before it starts', () {
      final passEnds = _now.add(const Duration(days: 10));
      final entitlement = entitlementFromGrants(
        [
          _grant('pantas_pass_cse_pro', ends: passEnds),
          _grant(
            'pantas_cs_monthly',
            starts: passEnds,
            ends: passEnds.add(const Duration(days: 30)),
          ),
        ],
        at: _now,
      );

      expect(entitlement.plan, EntitlementPlan.free);
      expect(entitlement.subscriptions, isEmpty);
      expect(entitlement.passes.keys, ['exam_cse_pro']);
      expect(entitlement.proIsActive, isTrue);
    });

    test('an older reply that resolves last cannot replace a newer one',
        () async {
      final older = Completer<List<Map<String, dynamic>>>();
      final newer = Completer<List<Map<String, dynamic>>>();
      final replies = [
        Future.value(<Map<String, dynamic>>[]),
        older.future,
        newer.future,
      ];
      var call = 0;
      final gateway = WebPaymentGateway(
        callable: (_, __) async => null,
        readGrants: (_) => replies[call++],
        refreshClaims: (_) async {},
        openUrl: (_) async => true,
        now: () => _now,
      );
      await gateway.logIn('u1');

      final first = gateway.restorePurchases();
      final second = gateway.restorePurchases();
      newer.complete([
        _grant(
          'pantas_cs_monthly',
          ends: _now.add(const Duration(days: 30)),
        ),
      ]);
      await second;
      expect(gateway.cachedEntitlement?.proIsActive, isTrue);

      older.complete(<Map<String, dynamic>>[]);
      final stale = await first;

      expect(gateway.cachedEntitlement?.proIsActive, isTrue);
      // The dropped reply answers with the newer state it lost to.
      expect(stale.status, PaymentOperationStatus.success);
      expect(stale.confirmedEntitlement, gateway.cachedEntitlement);
    });

    test('a failed newer read never discards a valid older reply', () async {
      final older = Completer<List<Map<String, dynamic>>>();
      final newer = Completer<List<Map<String, dynamic>>>();
      final replies = [
        Future.value(<Map<String, dynamic>>[]),
        older.future,
        newer.future,
      ];
      var call = 0;
      final gateway = WebPaymentGateway(
        callable: (_, __) async => null,
        readGrants: (_) => replies[call++],
        refreshClaims: (_) async {},
        openUrl: (_) async => true,
        now: () => _now,
      );
      await gateway.logIn('u1');

      final first = gateway.restorePurchases();
      final second = gateway.restorePurchases();
      newer.completeError(StateError('offline'));
      await second;
      older.complete([
        _grant(
          'pantas_cs_monthly',
          ends: _now.add(const Duration(days: 30)),
        ),
      ]);
      final result = await first;

      expect(result.status, PaymentOperationStatus.success);
      expect(gateway.cachedEntitlement?.plan, EntitlementPlan.monthly);
    });

    test('an old restore cannot cancel the next account login read', () async {
      final refreshGate = Completer<void>();
      final readB = Completer<List<Map<String, dynamic>>>();
      final reads = <String>[];
      final gateway = WebPaymentGateway(
        callable: (_, __) async => null,
        readGrants: (uid) {
          reads.add(uid);
          return uid == 'b'
              ? readB.future
              : Future.value([
                  _grant(
                    'pantas_cs_monthly',
                    ends: _now.add(const Duration(days: 30)),
                  ),
                ]);
        },
        refreshClaims: (uid) =>
            uid == 'a' ? refreshGate.future : Future.value(),
        openUrl: (_) async => true,
        now: () => _now,
      );
      await gateway.logIn('a');
      final restore = gateway.restorePurchases();
      await gateway.clearIdentity();
      final loginB = gateway.logIn('b');
      await Future<void>.delayed(Duration.zero);

      refreshGate.complete();
      await restore;
      readB.complete([
        _grant(
          'pantas_cs_weekly',
          ends: _now.add(const Duration(days: 7)),
        ),
      ]);
      await loginB;

      expect(reads, ['a', 'b']);
      expect(gateway.cachedEntitlement?.productId, 'pantas_cs_weekly');
    });

    test('at a queued start the server is read again, not the kept rows', () {
      fakeAsync((async) {
        final start = DateTime.utc(2026, 11, 2, 4);
        DateTime clock() => start.add(async.elapsed);
        const hour = Duration(hours: 1);
        var reads = 0;
        final gateway = WebPaymentGateway(
          callable: (_, __) async => null,
          readGrants: (_) async {
            reads++;
            // The plan queued for hour one is refunded before it starts.
            return reads == 1
                ? [
                    _grant(
                      'pantas_cs_monthly',
                      starts: start.add(hour),
                      ends: start.add(hour * 2),
                    ),
                  ]
                : <Map<String, dynamic>>[];
          },
          refreshClaims: (_) async {},
          openUrl: (_) async => true,
          now: clock,
          followClock: true,
        );
        unawaited(gateway.logIn('u1'));
        async.flushMicrotasks();
        expect(reads, 1);

        async.elapse(hour);

        expect(reads, 2);
        expect(gateway.cachedEntitlement!.plan, EntitlementPlan.free);
        unawaited(gateway.clearIdentity());
        async.flushMicrotasks();
      });
    });

    test('a failed read at a boundary keeps the state and tries at the next',
        () {
      fakeAsync((async) {
        final start = DateTime.utc(2026, 11, 2, 4);
        DateTime clock() => start.add(async.elapsed);
        const hour = Duration(hours: 1);
        final rows = [
          _grant(
            'pantas_cs_monthly',
            starts: start.add(hour),
            ends: start.add(hour * 3),
          ),
          _grant(
            'pantas_cs_weekly',
            starts: start.add(hour * 2),
            ends: start.add(hour * 4),
          ),
        ];
        var reads = 0;
        final gateway = WebPaymentGateway(
          callable: (_, __) async => null,
          readGrants: (_) async {
            reads++;
            if (reads == 2) throw StateError('offline');
            return rows;
          },
          refreshClaims: (_) async {},
          openUrl: (_) async => true,
          now: clock,
          followClock: true,
        );
        unawaited(gateway.logIn('u1'));
        async
          ..flushMicrotasks()
          ..elapse(hour);
        expect(reads, 2);
        expect(gateway.cachedEntitlement!.plan, EntitlementPlan.free);

        async.elapse(hour);
        expect(reads, 3);
        expect(gateway.cachedEntitlement!.plan, isNot(EntitlementPlan.free));
        unawaited(gateway.clearIdentity());
        async.flushMicrotasks();
      });
    });

    test('one clock reading maps the rows and sets the wake-up', () {
      fakeAsync((async) {
        final start = DateTime.utc(2026, 11, 2, 4);
        // The clock reads 1 ms before the plan starts, then at its start.
        // A mapping and a wake-up that read it twice would see the start
        // pass between them and never wake.
        var readings = 0;
        DateTime clock() => start.add(
              Duration(milliseconds: readings++ == 0 ? 9 : 10) + async.elapsed,
            );
        final gateway = WebPaymentGateway(
          callable: (_, __) async => null,
          readGrants: (_) async => [
            _grant(
              'pantas_cs_monthly',
              starts: start.add(const Duration(milliseconds: 10)),
              ends: start.add(const Duration(hours: 1)),
            ),
          ],
          refreshClaims: (_) async {},
          openUrl: (_) async => true,
          now: clock,
          followClock: true,
        );
        unawaited(gateway.logIn('u1'));
        async.flushMicrotasks();
        expect(gateway.cachedEntitlement!.plan, EntitlementPlan.free);

        async.elapse(const Duration(milliseconds: 5));

        expect(gateway.cachedEntitlement!.plan, EntitlementPlan.monthly);
        unawaited(gateway.clearIdentity());
        async.flushMicrotasks();
      });
    });

    test('sign-out and an account change cancel the pending wake-up', () {
      fakeAsync((async) {
        final start = DateTime.utc(2026, 11, 2, 4);
        final gateway = WebPaymentGateway(
          callable: (_, __) async => null,
          readGrants: (_) async => [
            _grant(
              'pantas_cs_monthly',
              starts: start.add(const Duration(hours: 1)),
              ends: start.add(const Duration(hours: 2)),
            ),
          ],
          refreshClaims: (_) async {},
          openUrl: (_) async => true,
          now: () => start.add(async.elapsed),
          followClock: true,
        );
        unawaited(gateway.logIn('a'));
        async.flushMicrotasks();
        expect(async.nonPeriodicTimerCount, 1);

        unawaited(gateway.clearIdentity());
        async.flushMicrotasks();
        expect(async.nonPeriodicTimerCount, 0);

        unawaited(gateway.logIn('a'));
        async.flushMicrotasks();
        expect(async.nonPeriodicTimerCount, 1);
        unawaited(gateway.logOut());
        async.flushMicrotasks();
        expect(async.nonPeriodicTimerCount, 0);
      });
    });

    test('the app wires the web gateway to follow the clock', () {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          paymentsOnWebProvider.overrideWithValue(true),
        ],
      );
      addTearDown(container.dispose);

      final gateway = container.read(revenueCatGatewayProvider);

      expect(gateway, isA<WebPaymentGateway>());
      expect((gateway as WebPaymentGateway).followsClock, isTrue);
    });

    test('an open tab follows queued starts and ends on the clock', () {
      fakeAsync((async) {
        final start = DateTime.utc(2026, 11, 2, 4);
        DateTime clock() => start.add(async.elapsed);
        const hour = Duration(hours: 1);
        final gateway = WebPaymentGateway(
          callable: (_, __) async => null,
          readGrants: (_) async => [
            // A reward queued one hour out, for one exam.
            {
              ..._grant(
                'beta_reward',
                starts: start.add(hour),
                ends: start.add(hour * 2),
              ),
              'source': 'beta_reward',
              'examId': 'exam_cse_pro',
            },
            // A pass now, and a plan queued behind it.
            _grant('pantas_pass_cse_sub', ends: start.add(hour * 3)),
            _grant(
              'pantas_cs_monthly',
              starts: start.add(hour * 3),
              ends: start.add(hour * 4),
            ),
          ],
          refreshClaims: (_) async {},
          openUrl: (_) async => true,
          now: clock,
          followClock: true,
        );
        bool rewardCovers() =>
            gateway.cachedEntitlement!.coversExam(
              'exam_cse_pro',
              examTier: PriceTier.civilService,
              at: clock(),
            ) &&
            gateway.cachedEntitlement!.betaPasses.containsKey('exam_cse_pro');

        unawaited(gateway.logIn('u1'));
        async.flushMicrotasks();
        expect(gateway.cachedEntitlement!.betaPasses, isEmpty);
        expect(gateway.cachedEntitlement!.plan, EntitlementPlan.free);

        async.elapse(hour);
        expect(rewardCovers(), isTrue);

        async.elapse(hour);
        expect(gateway.cachedEntitlement!.betaPasses, isEmpty);

        async.elapse(hour);
        expect(gateway.cachedEntitlement!.plan, EntitlementPlan.monthly);

        async.elapse(hour);
        expect(gateway.cachedEntitlement!.plan, EntitlementPlan.free);
        unawaited(gateway.clearIdentity());
        async.flushMicrotasks();
      });
    });
  });

  test('a failed first read at sign-in is retried, so a paid account turns Pro',
      () {
    // Before the exam-switch fix, a preferences refresh rebuilt the gateway and
    // read again by accident; without it, a failed first read left Free.
    fakeAsync((async) {
      final start = DateTime.utc(2026, 11, 2, 4);
      DateTime clock() => start.add(async.elapsed);
      var reads = 0;
      final gateway = WebPaymentGateway(
        callable: (_, __) async => null,
        readGrants: (_) async {
          reads++;
          if (reads == 1) throw Exception('offline');
          return [
            _grant(
              'pantas_cs_monthly',
              ends: start.add(const Duration(days: 30)),
            ),
          ];
        },
        refreshClaims: (_) async {},
        openUrl: (_) async => true,
        now: clock,
        followClock: true,
      );
      unawaited(gateway.logIn('paid'));
      async.flushMicrotasks();
      expect(gateway.cachedEntitlement?.proIsActive ?? false, isFalse);

      async.elapse(const Duration(seconds: 6));

      expect(reads, 2);
      expect(gateway.cachedEntitlement?.proIsActive, isTrue);
      unawaited(gateway.clearIdentity());
      async.flushMicrotasks();
    });
  });
}

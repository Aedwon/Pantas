import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

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
          _grant('promo_civil_service', ends: ends),
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
}

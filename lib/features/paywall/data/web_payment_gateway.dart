import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/platform/callable_options.dart';
import 'package:pantas/features/paywall/data/entitlement_snapshot_store.dart';
import 'package:pantas/features/paywall/data/live_revenuecat_gateway.dart';
import 'package:pantas/features/paywall/data/payment_entitlement_state.dart';
import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';
import 'package:pantas/features/paywall/domain/coverage.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/pass_offering.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/paywall_offering.dart';
import 'package:pantas/features/paywall/domain/products.dart';
import 'package:url_launcher/url_launcher.dart';

/// The product id the server writes on a web trial grant.
const _webTrialProduct = 'web_trial';

/// A web trial is a Civil Service Monthly trial that never charges, so it
/// takes the shape the mobile Monthly trial already has.
const _trialAsProduct = 'pantas_cs_monthly';

/// Maps rows of the server grant ledger (`users/{uid}/grants`) into the
/// app's existing [Entitlement], so no model change is needed (ruling C1
/// item 2). A grant counts while its state is `active` and its end is after
/// [at]. Rows that are not a known grant are ignored, never guessed at.
Entitlement entitlementFromGrants(
  Iterable<Map<String, dynamic>> rows, {
  required DateTime at,
}) {
  final subscriptions = <_Held>[];
  final passes = <String, DateTime>{};
  final ordered = rows.where((row) => row['startsAt'] is int).toList()
    ..sort(
      (a, b) => (a['startsAt']! as int).compareTo(b['startsAt']! as int),
    );
  for (final row in ordered) {
    final starts = row['startsAt'];
    final productId = row['product'];
    final end = row['endsAt'];
    if (row['state'] != 'active' || productId is! String || end is! int) {
      continue;
    }
    if (starts is! int) continue;
    final startsAt = DateTime.fromMillisecondsSinceEpoch(starts, isUtc: true);
    if (startsAt.isAfter(at)) {
      final tier = productForId(productId)?.tier;
      if (productForId(productId)?.kind != ProductKind.subscription ||
          !subscriptions.any(
            (held) =>
                productForId(held.productId)!.tier == tier &&
                !startsAt.isAfter(held.endsAt),
          )) {
        continue;
      }
    }
    final endsAt = DateTime.fromMillisecondsSinceEpoch(end, isUtc: true);
    if (!endsAt.isAfter(at)) continue;
    if (productId == _webTrialProduct) {
      if (row['source'] == 'trial' && row['tier'] == 'civilService') {
        subscriptions.add(_Held(_trialAsProduct, endsAt, isTrial: true));
      }
      continue;
    }
    final product = productForId(productId);
    if (product?.kind == ProductKind.subscription) {
      subscriptions.add(_Held(productId, endsAt));
    } else if (product?.kind == ProductKind.pass) {
      final examId = product!.examId!;
      if (passes[examId] == null || endsAt.isAfter(passes[examId]!)) {
        passes[examId] = endsAt;
      }
    }
  }
  if (subscriptions.isEmpty) {
    return passes.isEmpty
        ? const Entitlement.free()
        : const Entitlement.free().withPasses(passes);
  }
  final selected = ([...subscriptions]..sort(_highestTierThenLatestEnd)).first;
  final product = productForId(selected.productId)!;
  return Entitlement(
    plan: planForSku(product.period!),
    productId: selected.productId,
    expiresAt: selected.endsAt,
    isTrial: selected.isTrial,
    // Prepaid web access ends on its date and never renews or charges.
    willRenew: false,
    tier: product.tier,
    passes: Map.unmodifiable(passes),
    subscriptions: [
      for (final held in subscriptions)
        CoveragePeriod(id: held.productId, endsAt: held.endsAt),
    ],
  );
}

int _highestTierThenLatestEnd(_Held a, _Held b) {
  final byTier = productForId(b.productId)!.tier.index.compareTo(
        productForId(a.productId)!.tier.index,
      );
  return byTier != 0 ? byTier : b.endsAt.compareTo(a.endsAt);
}

class _Held {
  const _Held(this.productId, this.endsAt, {this.isTrial = false});

  final String productId;
  final DateTime endsAt;
  final bool isTrial;
}

/// A known ledger entry, including access that has ended or was revoked.
class WebGrantHistory {
  const WebGrantHistory({
    required this.productId,
    required this.endsAt,
    required this.state,
    required this.isTrial,
  });

  final String productId;
  final DateTime endsAt;
  final String state;
  final bool isTrial;
}

/// Calls a Cloud Function by name. Throws `FirebaseFunctionsException`.
typedef WebCallable = Future<Object?> Function(
  String name,
  Map<String, Object?> data,
);

/// Opens a URL, in the same tab on web. Returns false when it could not.
typedef WebUrlOpener = Future<bool> Function(Uri uri);

/// Reads every row of `users/{uid}/grants` from the server.
typedef WebGrantReader = Future<List<Map<String, dynamic>>> Function(
  String uid,
);

enum WebTrialStatus { started, notAvailable, failed }

class WebTrialResult {
  const WebTrialResult({required this.status, required this.operation});

  final WebTrialStatus status;

  /// The same outcome in the shared payment vocabulary. When [status] is
  /// [WebTrialStatus.started] this is the ledger read that followed, so it
  /// carries the new entitlement unless that read failed.
  final PaymentOperationResult operation;
}

DateTime _utcNow() => DateTime.now().toUtc();

/// Payments on web: PayMongo checkout and the server grant ledger, in place
/// of RevenueCat and the stores. The server alone decides who has Pro; this
/// class opens checkout and reads back what the server granted.
class WebPaymentGateway implements RevenueCatPassGateway {
  WebPaymentGateway({
    required WebCallable callable,
    required WebGrantReader readGrants,
    required Future<void> Function(String? uid) refreshClaims,
    required WebUrlOpener openUrl,
    PaymentEntitlementState? entitlementState,
    DateTime Function()? now,
  })  : _callable = callable,
        _readGrants = readGrants,
        _refreshClaims = refreshClaims,
        _openUrl = openUrl,
        _state = entitlementState ??
            PaymentEntitlementState(EntitlementSnapshotStore.inMemory()),
        _now = now ?? _utcNow;

  final WebCallable _callable;
  final WebGrantReader _readGrants;
  final Future<void> Function(String? uid) _refreshClaims;
  final WebUrlOpener _openUrl;
  final PaymentEntitlementState _state;
  final DateTime Function() _now;
  String? _uid;
  int _identityRevision = 0;
  bool _googlePlayPlanRenews = false;

  /// True only after an owner-bound server reply confirms Play renewal.
  bool get googlePlayPlanRenews => _googlePlayPlanRenews;

  @override
  Entitlement? get cachedEntitlement => _state.current;

  @override
  Stream<Entitlement> get customerInfoUpdates => _state.updates;

  @override
  Future<void> initialize() => _state.initialize();

  @override
  Future<void> configure({required String androidApiKey}) => initialize();

  @override
  Future<void> logIn(String uid) async {
    await initialize();
    if (_uid != uid) {
      _identityRevision++;
      _googlePlayPlanRenews = false;
    }
    if ((_uid ?? await _state.readOwner()) != uid) await _state.clear();
    _uid = uid;
    await _state.writeOwner(uid);
    try {
      await _readEntitlement(uid);
    } catch (_) {
      // A failed read is no news. Keep what was confirmed before.
    }
  }

  @override
  Future<void> clearIdentity() async {
    _uid = null;
    _identityRevision++;
    _googlePlayPlanRenews = false;
    await _state.clear();
  }

  @override
  Future<void> logOut() => clearIdentity();

  /// Reads real end dates without turning past access into current coverage.
  Future<List<WebGrantHistory>> grantHistory() async {
    final uid = _uid;
    if (uid == null) return const [];
    final revision = _identityRevision;
    final rows = await _readGrants(uid);
    if (_uid != uid || _identityRevision != revision) return const [];
    final history = <WebGrantHistory>[];
    for (final row in rows) {
      final productId = row['product'];
      final end = row['endsAt'];
      final state = row['state'];
      if (productId is! String ||
          end is! int ||
          (state != 'active' && state != 'revoked')) {
        continue;
      }
      final isTrial = productId == _webTrialProduct &&
          row['source'] == 'trial' &&
          row['tier'] == 'civilService';
      if (!isTrial && productForId(productId) == null) continue;
      history.add(
        WebGrantHistory(
          productId: productId,
          endsAt: DateTime.fromMillisecondsSinceEpoch(end, isUtc: true),
          state: state! as String,
          isTrial: isTrial,
        ),
      );
    }
    history.sort((a, b) => b.endsAt.compareTo(a.endsAt));
    return List.unmodifiable(history);
  }

  /// The plans the server sells on the web. The server owns the prices: it
  /// lists them from the same file checkout charges, and the price string and
  /// amount here are shown as received, as the store's are on mobile.
  @override
  Future<PaywallOfferingResult> currentOffering() async {
    final uid = _uid;
    final revision = _identityRevision;
    try {
      final reply = await _callable(_plansCallable, {});
      if (_uid != uid || _identityRevision != revision) {
        return const PaywallOfferingResult(
          status: PaywallOfferingStatus.configurationFailure,
        );
      }
      _googlePlayPlanRenews =
          uid != null && reply is Map && reply['googlePlayPlanRenews'] == true;
      final rows = reply is Map ? reply['plans'] : null;
      if (rows is! List<Object?>) {
        return const PaywallOfferingResult(
          status: PaywallOfferingStatus.unknownFailure,
        );
      }
      return _offeringFromPlans(
        rows,
        trialEligible: reply is Map && reply['trialEligible'] == true,
      );
    } catch (error) {
      return PaywallOfferingResult(
        status: _offeringStatusForOperation(_statusForError(error)),
      );
    }
  }

  /// Refreshes the sign-in token, reads the grant ledger again and emits
  /// what the server granted.
  @override
  Future<PaymentOperationResult> restorePurchases() async {
    final uid = _uid;
    if (uid == null) {
      return const PaymentOperationResult.failure(
        status: PaymentOperationStatus.configurationFailure,
      );
    }
    try {
      await _refreshClaims(uid);
    } catch (_) {
      // The ledger is what this screen reads. The server repair job fixes
      // a token that stays behind.
    }
    try {
      final entitlement = await _readEntitlement(uid);
      if (entitlement == null) {
        return const PaymentOperationResult.failure(
          status: PaymentOperationStatus.operationAlreadyInProgress,
        );
      }
      return PaymentOperationResult.authoritative(
        status: entitlement.coverage(at: _now()).hasKnownCoverage
            ? PaymentOperationStatus.success
            : PaymentOperationStatus.noActiveSubscription,
        entitlement: entitlement,
      );
    } catch (error) {
      return PaymentOperationResult.failure(status: _statusForError(error));
    }
  }

  /// Call with the address the page was opened at. Returns null when the
  /// address is not a checkout return.
  ///
  /// After `checkout=success` this reads the ledger once. The webhook can
  /// lag, so no grant yet is `entitlementNotActive` (not confirmed yet), not
  /// a failure. There is no polling. After `checkout=cancelled` nothing
  /// changes.
  Future<PaymentOperationResult?> handleCheckoutReturn(Uri uri) async {
    switch (uri.queryParameters['checkout']) {
      case 'cancelled':
        return const PaymentOperationResult.failure(
          status: PaymentOperationStatus.userCancelled,
        );
      case 'success':
        final restored = await restorePurchases();
        if (restored.status != PaymentOperationStatus.noActiveSubscription) {
          return restored;
        }
        return PaymentOperationResult.authoritative(
          status: PaymentOperationStatus.entitlementNotActive,
          entitlement:
              restored.confirmedEntitlement ?? const Entitlement.free(),
        );
    }
    return null;
  }

  /// Starts the once-per-account web trial on the server, then reads the
  /// ledger. The server refuses a second trial and any account that ever had
  /// Pro with `failed-precondition`, which is [WebTrialStatus.notAvailable].
  Future<WebTrialResult> startTrial() async {
    if (_uid == null) {
      return const WebTrialResult(
        status: WebTrialStatus.failed,
        operation: PaymentOperationResult.failure(
          status: PaymentOperationStatus.configurationFailure,
        ),
      );
    }
    try {
      await _callable(_trialCallable, {});
    } catch (error) {
      if (error is FirebaseException && error.code == 'failed-precondition') {
        return const WebTrialResult(
          status: WebTrialStatus.notAvailable,
          operation: PaymentOperationResult.failure(
            status: PaymentOperationStatus.entitlementNotActive,
          ),
        );
      }
      return WebTrialResult(
        status: WebTrialStatus.failed,
        operation: PaymentOperationResult.failure(
          status: _statusForError(error),
        ),
      );
    }
    // The trial is committed on the server even if this read fails.
    return WebTrialResult(
      status: WebTrialStatus.started,
      operation: await restorePurchases(),
    );
  }

  /// Reads the ledger for [uid] and keeps it as the confirmed entitlement.
  /// Returns null when the signed-in account changed while reading.
  Future<Entitlement?> _readEntitlement(String uid) async {
    final rows = await _readGrants(uid);
    if (_uid != uid) return null;
    final entitlement = entitlementFromGrants(rows, at: _now());
    await _state.acceptAuthoritative(
      entitlement,
      shouldContinue: () => _uid == uid,
    );
    return _uid == uid ? entitlement : null;
  }

  @override
  Future<PaymentOperationResult> purchase(
    PaywallPackage package, {
    Future<void> Function(String sessionId, String reference)? beforeRedirect,
  }) =>
      _checkout(package.productId, beforeRedirect: beforeRedirect);

  @override
  Future<PaymentOperationResult> purchasePass(
    PaywallPassPackage package, {
    required ExamCatalogEntry exam,
    Future<void> Function(String sessionId, String reference)? beforeRedirect,
  }) {
    if (!passAllowedForExam(package.productId, exam, at: _now())) {
      return Future.value(
        const PaymentOperationResult.failure(
          status: PaymentOperationStatus.developerFailure,
        ),
      );
    }
    return _checkout(package.productId, beforeRedirect: beforeRedirect);
  }

  /// Asks the server for a PayMongo checkout and sends this tab to it.
  Future<PaymentOperationResult> _checkout(
    String productId, {
    Future<void> Function(String sessionId, String reference)? beforeRedirect,
  }) async {
    final uid = _uid;
    final revision = _identityRevision;
    try {
      final reply = await _callable(
        _checkoutCallable,
        {'product': productId},
      );
      if (_uid != uid || _identityRevision != revision) {
        return const PaymentOperationResult.failure(
          status: PaymentOperationStatus.configurationFailure,
        );
      }
      final sessionId = reply is Map ? reply['sessionId'] : null;
      final reference = reply is Map ? reply['reference'] : null;
      final url = reply is Map ? reply['checkoutUrl'] : null;
      final uri = url is String ? Uri.tryParse(url) : null;
      if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
        return const PaymentOperationResult.failure(
          status: PaymentOperationStatus.unknownFailure,
        );
      }
      if (beforeRedirect != null) {
        if (sessionId is! String ||
            sessionId.isEmpty ||
            reference is! String ||
            reference.isEmpty) {
          return const PaymentOperationResult.failure(
            status: PaymentOperationStatus.unknownFailure,
          );
        }
        await beforeRedirect(sessionId, reference);
        if (_uid != uid || _identityRevision != revision) {
          return const PaymentOperationResult.failure(
            status: PaymentOperationStatus.configurationFailure,
          );
        }
      }
      return PaymentOperationResult.failure(
        status: await _openUrl(uri)
            ? PaymentOperationStatus.operationAlreadyInProgress
            : PaymentOperationStatus.storeFailure,
      );
    } catch (error) {
      return PaymentOperationResult.failure(status: _statusForError(error));
    }
  }
}

const _checkoutCallable = 'createPaymongoCheckout';
const _trialCallable = 'startWebTrial';
const _plansCallable = 'listWebPlans';

/// Callable error codes the server sends, in the app's own vocabulary.
PaymentOperationStatus _statusForError(Object error) {
  if (error is! FirebaseException) {
    return PaymentOperationStatus.unknownFailure;
  }
  return switch (error.code) {
    'invalid-argument' ||
    'failed-precondition' =>
      PaymentOperationStatus.developerFailure,
    'resource-exhausted' => PaymentOperationStatus.storeFailure,
    'already-exists' => PaymentOperationStatus.operationAlreadyInProgress,
    'unauthenticated' ||
    'permission-denied' =>
      PaymentOperationStatus.configurationFailure,
    'unavailable' ||
    'deadline-exceeded' =>
      PaymentOperationStatus.networkFailure,
    _ => PaymentOperationStatus.unknownFailure,
  };
}

const _functionsRegion = 'asia-southeast1';

/// The real [WebCallable]: the project's Cloud Functions region.
Future<Object?> callFirebaseFunction(
  String name,
  Map<String, Object?> data,
) async {
  final result = await FirebaseFunctions.instanceFor(region: _functionsRegion)
      .httpsCallable(name, options: callableOptionsFor(name))
      .call<Object?>(data);
  return result.data;
}

/// The real [WebGrantReader] reads combined native and web coverage. The
/// caller keeps the last confirmed entitlement instead of reading "none".
Future<List<Map<String, dynamic>>> readGrantsFromFirestore(String uid) async {
  final reply = await callFirebaseFunction('getWebEntitlement', {'uid': uid});
  if (reply is! Map || reply['grants'] is! List) {
    throw StateError('The server returned no entitlement.');
  }
  return [
    for (final row in reply['grants']! as List)
      if (row is Map) Map<String, dynamic>.from(row),
  ];
}

/// The real [WebUrlOpener]: checkout replaces this tab, so the return URL
/// brings the student back to the same session.
Future<bool> openInThisTab(Uri uri) =>
    launchUrl(uri, webOnlyWindowName: '_self');

PaywallOfferingResult _offeringFromPlans(
  List<Object?> rows, {
  required bool trialEligible,
}) {
  if (rows.isEmpty) return const PaywallOfferingResult.noCurrentOffering();
  final recognized = <PaywallPackage>[];
  final passes = <PaywallPassPackage>[];
  final unrecognized = <String>[];
  for (final row in rows) {
    if (row is! Map || row['product'] is! String) continue;
    final productId = row['product']! as String;
    final cents = row['priceCentavos'];
    final price = row['priceString'];
    final product = productForId(productId);
    if (product == null ||
        cents is! int ||
        cents <= 0 ||
        price is! String ||
        price.isEmpty) {
      unrecognized.add(productId);
    } else if (product.kind == ProductKind.pass) {
      if (row['examId'] == product.examId) {
        passes.add(
          PaywallPassPackage(
            productId: productId,
            priceString: price,
            priceAmount: cents / 100,
          ),
        );
      } else {
        unrecognized.add(productId);
      }
    } else if (product.kind == ProductKind.subscription &&
        product.period != null) {
      recognized.add(
        PaywallPackage(
          sku: product.period!,
          trialEligible: trialEligible && product.period == PaywallSku.monthly,
          productId: productId,
          priceString: price,
          priceAmount: cents / 100,
        ),
      );
    } else {
      unrecognized.add(productId);
    }
  }
  return PaywallOfferingResult(
    status: recognized.isEmpty && passes.isEmpty
        ? PaywallOfferingStatus.allProductsUnrecognized
        : unrecognized.isEmpty
            ? PaywallOfferingStatus.available
            : PaywallOfferingStatus.mixedProducts,
    recognizedPackages: recognized,
    passPackages: passes,
    unrecognizedProductIds: unrecognized,
  );
}

PaywallOfferingStatus _offeringStatusForOperation(
  PaymentOperationStatus status,
) =>
    switch (status) {
      PaymentOperationStatus.networkFailure =>
        PaywallOfferingStatus.networkFailure,
      PaymentOperationStatus.storeFailure => PaywallOfferingStatus.storeFailure,
      PaymentOperationStatus.configurationFailure =>
        PaywallOfferingStatus.configurationFailure,
      PaymentOperationStatus.developerFailure =>
        PaywallOfferingStatus.developerFailure,
      _ => PaywallOfferingStatus.unknownFailure,
    };

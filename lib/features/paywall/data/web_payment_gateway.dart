import 'package:cloud_functions/cloud_functions.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/features/paywall/data/live_revenuecat_gateway.dart';
import 'package:pantas/features/paywall/domain/coverage.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/pass_offering.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';
import 'package:pantas/features/paywall/domain/products.dart';

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
  for (final row in rows) {
    final productId = row['product'];
    final end = row['endsAt'];
    if (row['state'] != 'active' || productId is! String || end is! int) {
      continue;
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

/// Calls a Cloud Function by name. Throws `FirebaseFunctionsException`.
typedef WebCallable = Future<Object?> Function(
  String name,
  Map<String, Object?> data,
);

/// Opens a URL, in the same tab on web. Returns false when it could not.
typedef WebUrlOpener = Future<bool> Function(Uri uri);

class WebPaymentGateway {
  WebPaymentGateway({
    required WebCallable callable,
    required WebUrlOpener openUrl,
    DateTime Function()? now,
  })  : _callable = callable,
        _openUrl = openUrl,
        _now = now ?? DateTime.now;

  final WebCallable _callable;
  final WebUrlOpener _openUrl;
  final DateTime Function() _now;

  Future<PaymentOperationResult> purchase(PaywallPackage package) =>
      _checkout(package.productId);

  Future<PaymentOperationResult> purchasePass(
    PaywallPassPackage package, {
    required ExamCatalogEntry exam,
  }) {
    if (!passAllowedForExam(package.productId, exam, at: _now())) {
      return Future.value(
        const PaymentOperationResult.failure(
          status: PaymentOperationStatus.developerFailure,
        ),
      );
    }
    return _checkout(package.productId);
  }

  /// Asks the server for a PayMongo checkout and sends this tab to it.
  Future<PaymentOperationResult> _checkout(String productId) async {
    try {
      final reply = await _callable(
        _checkoutCallable,
        {'product': productId},
      );
      final url = reply is Map ? reply['checkoutUrl'] : null;
      final uri = url is String ? Uri.tryParse(url) : null;
      if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
        return const PaymentOperationResult.failure(
          status: PaymentOperationStatus.unknownFailure,
        );
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

/// Callable error codes the server sends, in the app's own vocabulary.
PaymentOperationStatus _statusForError(Object error) {
  if (error is! FirebaseFunctionsException) {
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

import 'package:pantas/features/paywall/data/live_revenuecat_gateway.dart';
import 'package:pantas/features/paywall/domain/coverage.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
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

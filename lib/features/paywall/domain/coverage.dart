import 'dart:developer';

import 'package:meta/meta.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';
import 'package:pantas/features/paywall/domain/products.dart';

@immutable
class CoveragePeriod {
  const CoveragePeriod({
    required this.id,
    required this.endsAt,
    this.active = true,
  });

  final String id;
  final DateTime endsAt;
  final bool active;

  @override
  bool operator ==(Object other) =>
      other is CoveragePeriod &&
      other.id == id &&
      other.endsAt == endsAt &&
      other.active == active;

  @override
  int get hashCode => Object.hash(id, endsAt, active);
}

/// Only server-owned pass ledger records may construct these values.
class LedgerPass {
  const LedgerPass({
    required this.examId,
    required this.endsAt,
    this.active = true,
  });

  final String examId;
  final DateTime endsAt;
  final bool active;
}

bool tierCovers(PriceTier held, PriceTier requested) => switch (held) {
      PriceTier.student => requested == PriceTier.student,
      PriceTier.civilService =>
        requested == PriceTier.student || requested == PriceTier.civilService,
      PriceTier.licensure => requested != PriceTier.nce,
      PriceTier.nce => requested == PriceTier.nce,
    };

class Coverage {
  Coverage({
    required this.subscriptionTier,
    required this.grantTier,
    required Map<String, DateTime> passes,
    required this.endsAt,
    required this.isUnknown,
  }) : passes = Map.unmodifiable(passes);

  final PriceTier? subscriptionTier;
  final PriceTier? grantTier;
  final Map<String, DateTime> passes;
  final DateTime? endsAt;
  final bool isUnknown;

  PriceTier? get tier => _higherTier(subscriptionTier, grantTier);
  bool get hasKnownCoverage => tier != null || passes.isNotEmpty;

  bool coversExam(String examId, PriceTier examTier) =>
      passes.containsKey(examId) ||
      (subscriptionTier != null && tierCovers(subscriptionTier!, examTier)) ||
      (grantTier != null && tierCovers(grantTier!, examTier));
}

Coverage coverageAt({
  required DateTime at,
  Iterable<CoveragePeriod> subscriptions = const [],
  Iterable<LedgerPass> passes = const [],
  Iterable<CoveragePeriod> promotions = const [],
  Iterable<CoveragePeriod> nonSubscriptionPurchases = const [],
  void Function(String id)? onUnknown,
}) {
  PriceTier? subscriptionTier;
  PriceTier? grantTier;
  DateTime? endsAt;
  var hasUnknown = false;
  final activePasses = <String, DateTime>{};

  void includeEnd(DateTime end) {
    if (endsAt == null || end.isAfter(endsAt!)) endsAt = end;
  }

  void unknown(String id) {
    hasUnknown = true;
    if (onUnknown != null) {
      onUnknown(id);
    } else {
      log('Unknown payment item: $id', name: 'payments');
    }
  }

  for (final source in subscriptions) {
    if (!source.active || !source.endsAt.isAfter(at)) continue;
    final product = productForId(source.id);
    if (product == null) {
      unknown(source.id);
    } else if (product.kind == ProductKind.subscription) {
      subscriptionTier = _higherTier(subscriptionTier, product.tier);
      includeEnd(source.endsAt);
    }
  }
  for (final source in promotions) {
    if (!source.active || !source.endsAt.isAfter(at)) continue;
    final product = productForId(source.id);
    if (product == null) {
      unknown(source.id);
    } else if (product.kind == ProductKind.promotional) {
      grantTier = _higherTier(grantTier, product.tier);
      includeEnd(source.endsAt);
    }
  }
  for (final pass in passes) {
    if (!pass.active || !pass.endsAt.isAfter(at)) continue;
    final previous = activePasses[pass.examId];
    if (previous == null || pass.endsAt.isAfter(previous)) {
      activePasses[pass.examId] = pass.endsAt;
    }
    includeEnd(pass.endsAt);
  }
  // Purchase history is deliberately not an input to granting coverage.
  // Only an active server ledger record above grants one-time access.
  for (final purchase in nonSubscriptionPurchases) {
    if (productForId(purchase.id) == null) {
      if (onUnknown != null) {
        onUnknown(purchase.id);
      } else {
        log('Unknown payment item: ${purchase.id}', name: 'payments');
      }
    }
  }
  return Coverage(
    subscriptionTier: subscriptionTier,
    grantTier: grantTier,
    passes: activePasses,
    endsAt: endsAt,
    isUnknown: hasUnknown &&
        subscriptionTier == null &&
        grantTier == null &&
        activePasses.isEmpty,
  );
}

PriceTier? _higherTier(PriceTier? first, PriceTier? second) {
  if (first == null) return second;
  if (second == null) return first;
  return first.index >= second.index ? first : second;
}

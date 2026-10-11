import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:pantas/features/paywall/domain/coverage.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';
import 'package:pantas/features/paywall/domain/products.dart';

enum EntitlementPlan { free, weekly, monthly, yearly }

enum EntitlementState {
  free,
  trial,
  active,
  canceledActive,
  billingIssue,
  grant,
  unknown,
  paused,
}

class MockLimit {
  const MockLimit({required this.unlimited, this.nextMockOpensAt});

  final bool unlimited;
  final DateTime? nextMockOpensAt;
}

@immutable
class Entitlement {
  const Entitlement({
    required this.plan,
    this.productId,
    this.expiresAt,
    this.isTrial = false,
    this.willRenew = true,
    this.isUnknownPlan = false,
    PriceTier? tier,
    EntitlementState? state,
    this.passes = const {},
    this.subscriptions = const [],
    this.promotions = const [],
    this.examTiers = const {},
    DateTime? endsAt,
    DateTime? renewsAt,
    DateTime? chargesAt,
    this.verifiedAt,
    DateTime? effectiveAt,
    Duration offlineGrace = Duration.zero,
  })  : _tier = tier,
        _state = state,
        _endsAt = endsAt,
        _renewsAt = renewsAt,
        _chargesAt = chargesAt,
        _effectiveAt = effectiveAt,
        _offlineGrace = offlineGrace;

  const Entitlement.free() : this(plan: EntitlementPlan.free, willRenew: false);

  const Entitlement.activeUnknown({
    required String productId,
    DateTime? expiresAt,
    bool isTrial = false,
    bool willRenew = true,
  }) : this(
          plan: EntitlementPlan.free,
          productId: productId,
          expiresAt: expiresAt,
          isTrial: isTrial,
          willRenew: willRenew,
          isUnknownPlan: true,
        );

  final EntitlementPlan plan;
  final String? productId;
  final DateTime? expiresAt;
  final bool isTrial;
  final bool willRenew;
  final PriceTier? _tier;
  final EntitlementState? _state;
  final DateTime? _endsAt;
  final DateTime? _renewsAt;
  final DateTime? _chargesAt;
  final DateTime? verifiedAt;
  final DateTime? _effectiveAt;
  final Duration _offlineGrace;

  Entitlement withEvidence(DateTime at) => _copy(verifiedAt: at);

  Entitlement withPasses(Map<String, DateTime> records) => Entitlement(
        plan: plan,
        productId: productId,
        expiresAt: expiresAt,
        isTrial: isTrial,
        willRenew: willRenew,
        isUnknownPlan: isUnknownPlan && records.isEmpty,
        tier: tier,
        state: records.isNotEmpty &&
                (state == EntitlementState.free ||
                    state == EntitlementState.unknown)
            ? EntitlementState.active
            : state,
        passes: Map.unmodifiable(records),
        subscriptions: subscriptions,
        promotions: promotions,
        examTiers: examTiers,
        renewsAt: _renewsAt,
        chargesAt: _chargesAt,
        verifiedAt: verifiedAt,
        effectiveAt: _effectiveAt,
        offlineGrace: _offlineGrace,
      );

  Entitlement withOfflineWindow(DateTime at, {required bool paused}) => _copy(
        effectiveAt: at,
        offlineGrace: const Duration(days: 3),
        state: paused ? EntitlementState.paused : state,
      );

  Entitlement _copy({
    DateTime? verifiedAt,
    DateTime? effectiveAt,
    Duration? offlineGrace,
    EntitlementState? state,
  }) =>
      Entitlement(
        plan: plan,
        productId: productId,
        expiresAt: expiresAt,
        isTrial: isTrial,
        willRenew: willRenew,
        isUnknownPlan: isUnknownPlan,
        tier: tier,
        state: state ?? this.state,
        passes: passes,
        subscriptions: subscriptions,
        promotions: promotions,
        examTiers: examTiers,
        endsAt: endsAt,
        renewsAt: renewsAt,
        chargesAt: chargesAt,
        verifiedAt: verifiedAt ?? this.verifiedAt,
        effectiveAt: effectiveAt ?? _effectiveAt,
        offlineGrace: offlineGrace ?? _offlineGrace,
      );

  /// Active server-ledger pass records, never RevenueCat purchase history.
  final Map<String, DateTime> passes;
  final List<CoveragePeriod> subscriptions;
  final List<CoveragePeriod> promotions;
  final Map<String, PriceTier> examTiers;

  PriceTier? get tier {
    if (_tier != null) return _tier;
    final product = productId == null ? null : productForId(productId!);
    return product?.kind == ProductKind.subscription ? product?.tier : null;
  }

  EntitlementState get state {
    if (_state != null) return _state;
    if (isUnknownPlan) return EntitlementState.unknown;
    if (plan != EntitlementPlan.free) {
      if (isTrial) return EntitlementState.trial;
      return willRenew
          ? EntitlementState.active
          : EntitlementState.canceledActive;
    }
    if (promotions.isNotEmpty) return EntitlementState.grant;
    return passes.isEmpty ? EntitlementState.free : EntitlementState.active;
  }

  DateTime? get endsAt {
    if (_endsAt != null) return _endsAt;
    final ends = [
      if (expiresAt != null) expiresAt!,
      ...passes.values,
      ...subscriptions.map((source) => source.endsAt),
      ...promotions.map((source) => source.endsAt),
    ];
    return ends.isEmpty ? null : ends.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  DateTime? get renewsAt =>
      _renewsAt ?? (willRenew && !isTrial ? expiresAt : null);
  DateTime? get chargesAt =>
      _chargesAt ?? (willRenew && isTrial ? expiresAt : null);

  Coverage coverage({DateTime? at}) => coverageAt(
        at: (at ?? _effectiveAt ?? DateTime.now().toUtc())
            .subtract(_offlineGrace),
        subscriptions: subscriptions.isNotEmpty
            ? subscriptions
            : productId != null && expiresAt != null
                ? [CoveragePeriod(id: productId!, endsAt: expiresAt!)]
                : const [],
        passes: [
          for (final pass in passes.entries)
            LedgerPass(examId: pass.key, endsAt: pass.value),
        ],
        promotions: promotions,
      );

  bool coversExam(String examId, {PriceTier? examTier, DateTime? at}) {
    if (state == EntitlementState.paused) return false;
    final active = coverage(at: at);
    if (active.passes.containsKey(examId)) return true;
    final requested = examTier ?? examTiers[examId];
    return requested != null && active.coversExam(examId, requested);
  }

  MockLimit mockLimit(String examId, {DateTime? at, DateTime? lastMockAt}) {
    if (coversExam(examId, at: at)) return const MockLimit(unlimited: true);
    return MockLimit(
      unlimited: false,
      nextMockOpensAt: lastMockAt?.add(const Duration(days: 14)),
    );
  }

  /// True when RevenueCat says Pro is active on a product this build does not
  /// recognize. The raw product id is retained and no known plan is guessed.
  final bool isUnknownPlan;

  bool get proIsActive =>
      isUnknownPlan ||
      plan != EntitlementPlan.free ||
      passes.isNotEmpty ||
      promotions.isNotEmpty;

  @override
  bool operator ==(Object other) {
    return other is Entitlement &&
        other.plan == plan &&
        other.productId == productId &&
        other.expiresAt == expiresAt &&
        other.isTrial == isTrial &&
        other.willRenew == willRenew &&
        other.isUnknownPlan == isUnknownPlan &&
        other.verifiedAt == verifiedAt &&
        other._effectiveAt == _effectiveAt &&
        other._offlineGrace == _offlineGrace &&
        other.tier == tier &&
        other.state == state &&
        other.endsAt == endsAt &&
        other.renewsAt == renewsAt &&
        other.chargesAt == chargesAt &&
        const DeepCollectionEquality().equals(other.passes, passes) &&
        const DeepCollectionEquality().equals(other.examTiers, examTiers) &&
        const DeepCollectionEquality()
            .equals(other.subscriptions, subscriptions) &&
        const DeepCollectionEquality().equals(other.promotions, promotions);
  }

  @override
  int get hashCode {
    return Object.hash(
      plan,
      productId,
      expiresAt,
      isTrial,
      willRenew,
      isUnknownPlan,
      verifiedAt,
      _effectiveAt,
      _offlineGrace,
      tier,
      state,
      endsAt,
      renewsAt,
      chargesAt,
      const DeepCollectionEquality().hash(passes),
      const DeepCollectionEquality().hash(examTiers),
      const DeepCollectionEquality().hash(subscriptions),
      const DeepCollectionEquality().hash(promotions),
    );
  }
}

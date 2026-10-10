import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';
import 'package:pantas/features/paywall/domain/products.dart';

enum SwitchKind { keepsPro, upgradeOffer, passWarning, free }

class SwitchOutcome {
  const SwitchOutcome({
    required this.kind,
    this.plans = const [],
    this.allowTrial = false,
    this.switchOnFree = false,
    this.passExamId,
    this.studentPlanStillRenews = false,
  });

  final SwitchKind kind;
  final List<String> plans;
  final bool allowTrial;
  final bool switchOnFree;
  final String? passExamId;
  final bool studentPlanStillRenews;
}

SwitchOutcome switchOutcome(
  ExamCatalogEntry from,
  ExamCatalogEntry to,
  Entitlement entitlement, {
  DateTime? at,
}) {
  final now = (at ?? DateTime.now()).toUtc();
  final purchaseDay = DateTime.utc(now.year, now.month, now.day);
  final fromTier = PriceTier.fromCatalog(from.priceTier);
  final toTier = PriceTier.fromCatalog(to.priceTier);
  final coverage = entitlement.coverage(at: now);
  if (entitlement.state == EntitlementState.paused) {
    return const SwitchOutcome(kind: SwitchKind.free);
  }
  if (entitlement.coversExam(to.id, examTier: toTier, at: now)) {
    return SwitchOutcome(
      kind: SwitchKind.keepsPro,
      studentPlanStillRenews: coverage.subscriptionTier == PriceTier.student &&
          entitlement.willRenew &&
          coverage.passes.containsKey(to.id),
    );
  }
  if (coverage.passes.containsKey(from.id)) {
    return SwitchOutcome(kind: SwitchKind.passWarning, passExamId: from.id);
  }
  if (entitlement.coversExam(from.id, examTier: fromTier, at: now) &&
      !to.comingSoon) {
    final plans = [
      for (final product in products.entries)
        if (product.value.tier == toTier &&
            (product.value.kind == ProductKind.subscription ||
                (product.value.kind == ProductKind.pass &&
                    product.value.examId == to.id &&
                    to.publishedSittings.any(
                      (sitting) => !sitting.firstDay.isBefore(purchaseDay),
                    ))))
          product.key,
    ];
    if (plans.isNotEmpty) {
      return SwitchOutcome(
        kind: SwitchKind.upgradeOffer,
        plans: List.unmodifiable(plans),
        switchOnFree: true,
      );
    }
  }
  return const SwitchOutcome(kind: SwitchKind.free);
}

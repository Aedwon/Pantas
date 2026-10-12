import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/domain/coverage.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

void main() {
  final at = DateTime.utc(2026, 10, 7);
  final end = DateTime.utc(2026, 11, 7);
  const examTiers = {
    'exam_upcat': PriceTier.student,
    'exam_cse_pro': PriceTier.civilService,
    'exam_cse_sub': PriceTier.civilService,
  };

  test('Civil Service entitlement covers Civil Service and Student', () {
    final entitlement = Entitlement(
      plan: EntitlementPlan.monthly,
      productId: 'pantas_cs_monthly',
      expiresAt: end,
      examTiers: examTiers,
    );
    expect(entitlement.tier, PriceTier.civilService);
    expect(entitlement.coversExam('exam_upcat', at: at), isTrue);
    expect(entitlement.coversExam('exam_cse_pro', at: at), isTrue);
    expect(entitlement.coversExam('unknown_exam', at: at), isFalse);
  });

  test('AC-7 Student, grant, pass and unknown coverage stay scoped', () {
    final student = Entitlement(
      plan: EntitlementPlan.monthly,
      productId: 'pantas_pro_monthly',
      expiresAt: end,
      examTiers: examTiers,
    );
    expect(student.coversExam('exam_cse_pro', at: at), isFalse);
    final grant = Entitlement(
      plan: EntitlementPlan.free,
      promotions: [CoveragePeriod(id: 'promo_civil_service', endsAt: end)],
      examTiers: examTiers,
      state: EntitlementState.grant,
    );
    expect(grant.coversExam('exam_upcat', at: at), isTrue);
    expect(grant.coversExam('exam_cse_pro', at: at), isTrue);
    final pass = Entitlement(
      plan: EntitlementPlan.free,
      passes: {'exam_cse_pro': end},
      examTiers: examTiers,
    );
    expect(pass.coversExam('exam_cse_pro', at: at), isTrue);
    expect(pass.coversExam('exam_cse_sub', at: at), isFalse);
    expect(pass.coversExam('exam_cse_pro', at: end), isFalse);
    final unknown = Entitlement.activeUnknown(
      productId: 'pantas_future',
      expiresAt: end,
    );
    expect(unknown.state, EntitlementState.unknown);
    expect(unknown.coversExam('exam_upcat', at: at), isFalse);
  });

  test('mock limit uses the requested exam and its last measured mock date',
      () {
    final entitlement = Entitlement(
      plan: EntitlementPlan.monthly,
      productId: 'pantas_pro_monthly',
      expiresAt: end,
      examTiers: examTiers,
    );
    expect(entitlement.mockLimit('exam_upcat', at: at).unlimited, isTrue);
    final limit = entitlement.mockLimit(
      'exam_cse_pro',
      at: at,
      lastMockAt: at.subtract(const Duration(days: 3)),
    );
    expect(limit.unlimited, isFalse);
    expect(limit.nextMockOpensAt, at.add(const Duration(days: 11)));
  });

  test('trial, canceled and billing states retain their true dates', () {
    final trial = Entitlement(
      plan: EntitlementPlan.monthly,
      expiresAt: end,
      isTrial: true,
    );
    expect(trial.state, EntitlementState.trial);
    expect(trial.chargesAt, end);
    final canceled = Entitlement(
      plan: EntitlementPlan.monthly,
      expiresAt: end,
      willRenew: false,
    );
    expect(canceled.state, EntitlementState.canceledActive);
    expect(canceled.endsAt, end);
    expect(canceled.renewsAt, isNull);
    expect(canceled.chargesAt, isNull);
    final billing = Entitlement(
      plan: EntitlementPlan.monthly,
      expiresAt: end,
      state: EntitlementState.billingIssue,
    );
    expect(billing.state, EntitlementState.billingIssue);
    expect(billing.endsAt, end);
  });
}

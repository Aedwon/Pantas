import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';
import 'package:pantas/features/paywall/domain/switch_outcome.dart';

void main() {
  final at = DateTime.utc(2026, 10, 7);
  final end = DateTime.utc(2027, 3, 14);
  ExamCatalogEntry exam(String id, String tier, {bool sitting = false}) =>
      ExamCatalogEntry(
        id: id,
        name: id,
        shortName: id,
        priceTier: tier,
        group: tier,
        comingSoon: false,
        hasContent: true,
        publishedSittings: sitting
            ? [
                PublishedExamSitting(
                  firstDay: end,
                  lastDay: end,
                  sourceUrl: 'https://www.csc.gov.ph/announcement',
                ),
              ]
            : [],
      );
  final upcat = exam('exam_upcat', 'Student');
  final acet = exam('exam_acet', 'Student');
  final cse = exam('exam_cse_pro', 'Civil Service', sitting: true);
  final sub = exam('exam_cse_sub', 'Civil Service', sitting: true);
  Entitlement subscription(String id, {bool willRenew = true}) => Entitlement(
        plan: EntitlementPlan.monthly,
        productId: id,
        expiresAt: end,
        willRenew: willRenew,
      );

  test('same tier keeps Student Pro', () {
    final outcome = switchOutcome(
      upcat,
      acet,
      subscription('pantas_pro_monthly'),
      at: at,
    );
    expect(outcome.kind, SwitchKind.keepsPro);
  });

  test('lower tier keeps Civil Service Pro', () {
    final outcome = switchOutcome(
      cse,
      upcat,
      subscription('pantas_cs_monthly'),
      at: at,
    );
    expect(outcome.kind, SwitchKind.keepsPro);
  });

  test('ST_SwitchUpgrade offers all target plans with no trial and Free choice',
      () {
    final outcome = switchOutcome(
      upcat,
      cse,
      subscription('pantas_pro_monthly'),
      at: at,
    );
    expect(outcome.kind, SwitchKind.upgradeOffer);
    expect(outcome.plans, [
      'pantas_cs_weekly',
      'pantas_cs_monthly',
      'pantas_cs_yearly',
      'pantas_pass_civil_service',
    ]);
    expect(outcome.allowTrial, isFalse);
    expect(outcome.switchOnFree, isTrue);
  });

  test('Free student switches without an offer', () {
    expect(
      switchOutcome(upcat, cse, const Entitlement.free(), at: at).kind,
      SwitchKind.free,
    );
  });

  test('ST_SwitchPassWarn warns when leaving the pass exam', () {
    final entitlement = Entitlement(
      plan: EntitlementPlan.free,
      passes: {'exam_cse_pro': end},
    );
    final outcome = switchOutcome(cse, sub, entitlement, at: at);
    expect(outcome.kind, SwitchKind.passWarning);
    expect(outcome.passExamId, 'exam_cse_pro');
    expect(
      switchOutcome(cse, upcat, entitlement, at: at).kind,
      SwitchKind.passWarning,
    );
  });

  test('returning to a live pass keeps Pro for that exam', () {
    final entitlement = Entitlement(
      plan: EntitlementPlan.free,
      passes: {'exam_cse_pro': end},
    );
    expect(
      switchOutcome(upcat, cse, entitlement, at: at).kind,
      SwitchKind.keepsPro,
    );
    expect(
      switchOutcome(cse, upcat, entitlement, at: end).kind,
      SwitchKind.free,
    );
  });

  test('active Student subscriber with a pass retains its renewal warning', () {
    final entitlement = Entitlement(
      plan: EntitlementPlan.monthly,
      productId: 'pantas_pro_monthly',
      expiresAt: end,
      passes: {'exam_cse_pro': end},
    );
    final outcome = switchOutcome(upcat, cse, entitlement, at: at);
    expect(outcome.kind, SwitchKind.keepsPro);
    expect(outcome.studentPlanStillRenews, isTrue);
    expect(entitlement.tier, PriceTier.student);
    expect(
      File('docs/superpowers/plans/new-design/drafts/season-pass-student-renewal.md')
          .readAsStringSync(),
      contains('Your Student plan still renews.'),
    );
  });

  test('no published sitting means no pass in an upgrade offer', () {
    final outcome = switchOutcome(
      upcat,
      exam('exam_cse_pro', 'Civil Service'),
      subscription('pantas_pro_monthly'),
      at: at,
    );
    expect(outcome.plans, [
      'pantas_cs_weekly',
      'pantas_cs_monthly',
      'pantas_cs_yearly',
    ]);
  });

  test('a sitting on the purchase day remains available after midnight', () {
    final purchaseAt = DateTime.utc(2027, 3, 14, 12);
    final entitlement = Entitlement(
      plan: EntitlementPlan.monthly,
      productId: 'pantas_pro_monthly',
      expiresAt: DateTime.utc(2027, 4),
    );
    expect(
      switchOutcome(upcat, cse, entitlement, at: purchaseAt).plans,
      contains('pantas_pass_civil_service'),
    );
  });
}

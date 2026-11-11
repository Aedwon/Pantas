import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';
import 'package:pantas/features/paywall/domain/products.dart';

void main() {
  test('AC-7 each approved subscription maps to its tier and period', () {
    const cases = {
      'pantas_pro_weekly': (PriceTier.student, PaywallSku.weekly),
      'pantas_pro_monthly': (PriceTier.student, PaywallSku.monthly),
      'pantas_pro_yearly': (PriceTier.student, PaywallSku.yearly),
      'pantas_cs_weekly': (PriceTier.civilService, PaywallSku.weekly),
      'pantas_cs_monthly': (PriceTier.civilService, PaywallSku.monthly),
      'pantas_cs_yearly': (PriceTier.civilService, PaywallSku.yearly),
    };
    for (final entry in cases.entries) {
      final product = productForId(entry.key)!;
      expect(product.tier, entry.value.$1);
      expect(product.period, entry.value.$2);
      expect(product.kind, ProductKind.subscription);
    }
  });

  test('AC-7 pass and promotional grants are distinct from subscriptions', () {
    final pass = productForId('pantas_pass_cse_pro')!;
    expect(pass.tier, PriceTier.civilService);
    expect(pass.kind, ProductKind.pass);
    expect(pass.period, isNull);
    expect(pass.examId, 'exam_cse_pro');
    expect(productForId('pantas_pass_cse_sub')!.examId, 'exam_cse_sub');
    expect(productForId('pantas_pass_civil_service'), isNull);
    expect(productForId('promo_student')!.tier, PriceTier.student);
    expect(productForId('promo_civil_service')!.tier, PriceTier.civilService);
    expect(productForId('promo_student')!.kind, ProductKind.promotional);
    expect(productForId('promo_civil_service')!.kind, ProductKind.promotional);
  });

  test('AC-7 unknown products stay unknown including the retired lifetime', () {
    for (final id in ['', 'pro', 'pantas_pro_lifetime', 'promo_future']) {
      expect(productForId(id), isNull);
    }
    expect(
      productForId('pantas_cs_monthly:monthly')!.period,
      PaywallSku.monthly,
    );
    expect(productForId('promo_student:unknown'), isNull);
  });

  test('server product export matches the complete app table', () {
    final rows = (jsonDecode(
      File('functions/src/products.json').readAsStringSync(),
    ) as List<dynamic>)
        .cast<Map<String, dynamic>>();
    expect(rows, hasLength(10));
    expect(rows.map((row) => row['id']).toSet(), products.keys.toSet());
    for (final row in rows) {
      final product = productForId(row['id'] as String)!;
      expect(row['tier'], product.tier.name);
      expect(row['period'], product.period?.name);
      expect(row['kind'], product.kind.name);
      expect(row['examId'], product.examId);
    }
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/domain/coverage.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

void main() {
  final vectors = (jsonDecode(
    File('test/fixtures/coverage_vectors.json').readAsStringSync(),
  ) as List<dynamic>)
      .cast<Map<String, dynamic>>();
  for (final vector in vectors) {
    test(vector['name'] as String, () {
      List<CoveragePeriod> periods(String key) => (vector[key] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(
            (row) => CoveragePeriod(
              id: row['id'] as String,
              endsAt: DateTime.parse(row['endsAt'] as String),
              active: row['active'] as bool,
            ),
          )
          .toList();
      final ledger = (vector['passes'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(
            (row) => LedgerPass(
              examId: row['examId'] as String,
              endsAt: DateTime.parse(row['endsAt'] as String),
              active: row['state'] == 'active',
            ),
          )
          .toList();
      final logged = <String>[];
      final coverage = coverageAt(
        at: DateTime.parse(vector['now'] as String),
        subscriptions: periods('subscriptions'),
        passes: ledger,
        promotions: periods('promotions'),
        nonSubscriptionPurchases: periods('nonSubscriptionPurchases'),
        onUnknown: logged.add,
      );
      final expected = vector['expected'] as Map<String, dynamic>;
      expect(
        coverage.coversExam(
          vector['examId'] as String,
          PriceTier.values.byName(vector['examTier'] as String),
        ),
        expected['covered'],
      );
      expect(coverage.tier?.name, expected['tier']);
      expect(coverage.isUnknown, expected['unknown']);
      if (expected['unknown'] == true) expect(logged, isNotEmpty);
    });
  }

  test('AC-7 higher tiers include only the stated lower tiers', () {
    expect(tierCovers(PriceTier.licensure, PriceTier.civilService), isTrue);
    expect(tierCovers(PriceTier.licensure, PriceTier.student), isTrue);
    expect(tierCovers(PriceTier.licensure, PriceTier.nce), isFalse);
    expect(tierCovers(PriceTier.nce, PriceTier.student), isFalse);
  });
}

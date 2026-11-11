import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every bundled catalog entry resolves to its declared tier', () async {
    final database = ContentDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final catalog = ExamCatalogRepository(database);
    final rows = (jsonDecode(
      File('content/exams/catalog.json').readAsStringSync(),
    ) as List<dynamic>)
        .cast<Map<String, dynamic>>();
    const tiers = {
      'Student': PriceTier.student,
      'Civil Service': PriceTier.civilService,
      'Licensure': PriceTier.licensure,
      'PSHS-NCE': PriceTier.nce,
    };
    expect(rows, hasLength(18));
    for (final row in rows) {
      expect(
        await tierForExam(catalog, row['id'] as String),
        tiers[row['priceTier']],
        reason: row['id'] as String,
      );
    }
  });

  test('an unknown catalog tier never becomes a paying tier', () {
    for (final value in ['', 'student', 'Future']) {
      expect(() => PriceTier.fromCatalog(value), throwsArgumentError);
    }
  });
}

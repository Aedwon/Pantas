import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/lesson_credit.dart';

void main() {
  final cases = (jsonDecode(
    File('test/fixtures/content/lesson_credit_cases.json').readAsStringSync(),
  ) as List)
      .cast<Map<String, dynamic>>();
  for (final c in cases) {
    test(c['name'] as String, () {
      final retired = (c['retired'] as Map<String, dynamic>).map(
        (id, ids) => MapEntry(id, (ids as List).cast<String>()),
      );
      final active = (c['active'] as List).cast<String>();
      final reads = resolveLessonCredit<int>(
        retiredReplacements: retired,
        own: (c['reads'] as Map<String, dynamic>).cast<String, int>(),
        compare: (a, b) => a.compareTo(b),
      );
      expect(
        {
          for (final id in active)
            if (reads[id] != null) id: reads[id],
        },
        c['expectedReads'],
      );
      final excluded = resolveLessonCredit<bool>(
        retiredReplacements: retired,
        own: {for (final id in c['excluded'] as List) id as String: true},
        compare: (a, b) => 0,
      );
      expect(
        active.where(excluded.containsKey),
        unorderedEquals(c['expectedExcluded'] as List),
      );
    });
  }
}

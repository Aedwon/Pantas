import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/data/custom_subject_tiers.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

void main() {
  final sample = CustomSubjectTiers.fromJson(const {
    'version': 1,
    'subjects': [
      {
        'name': 'Mathematics',
        'tier': 'Student',
        'topicIds': ['m1', 'm2'],
      },
      {
        'name': 'General Information',
        'tier': 'Civil Service',
        'topicIds': ['g1', 'g2'],
      },
      {
        'name': 'Law',
        'tier': 'Licensure',
        'topicIds': ['l1'],
      },
    ],
    'topicTiers': {
      'm1': 'Student',
      'g1': 'Civil Service',
      'loose_cs': 'Civil Service',
      'loose_student': 'Student',
    },
  });

  test('a subject keeps its own tier', () {
    expect(sample.tierOf({'m1'}), PriceTier.student);
    expect(sample.tierOf({'g2'}), PriceTier.civilService);
    expect(sample.tierOf({'l1'}), PriceTier.licensure);
  });

  test('an exam takes the highest tier among the subjects it keeps', () {
    expect(sample.tierOf({'m1', 'm2'}), PriceTier.student);
    expect(sample.tierOf({'m1', 'g2'}), PriceTier.civilService);
    expect(sample.tierOf({'m1', 'g2', 'l1'}), PriceTier.licensure);
  });

  test('a topic outside every subject counts at its own tier', () {
    expect(sample.tierOf({'m1', 'loose_cs'}), PriceTier.civilService);
    expect(sample.tierOf({'m1', 'loose_student'}), PriceTier.student);
  });

  test('a kept topic missing from the table raises the tier to the top', () {
    // Fail closed: new content before a table rebuild cannot under-price.
    expect(sample.tierOf({'m1', 'never_heard_of_it'}), PriceTier.licensure);
    expect(sample.tierOf({'never_heard_of_it'}), PriceTier.licensure);
  });

  test('nothing kept is Student', () {
    expect(sample.tierOf(const <String>{}), PriceTier.student);
  });

  test('tier names read as the catalog spells them', () {
    expect(CustomSubjectTiers.levelName(PriceTier.student), 'Student');
    expect(
      CustomSubjectTiers.levelName(PriceTier.civilService),
      'Civil Service',
    );
    expect(CustomSubjectTiers.levelName(PriceTier.licensure), 'Licensure');
  });

  test('the shipped table puts General Information above Student', () {
    final shipped = CustomSubjectTiers.fromJson(
      jsonDecode(
        File('content/exams/custom_subject_tiers.json').readAsStringSync(),
      ) as Map<String, dynamic>,
    );
    final all = (jsonDecode(
      File('content/exams/custom_subject_tiers.json').readAsStringSync(),
    ) as Map<String, dynamic>)['subjects'] as List<dynamic>;
    for (final raw in all.cast<Map<String, dynamic>>()) {
      final topics = (raw['topicIds'] as List<dynamic>).cast<String>();
      final expected = raw['name'] == 'General Information'
          ? PriceTier.civilService
          : PriceTier.student;
      expect(shipped.tierOf(topics), expected, reason: raw['name'] as String);
    }
  });
}

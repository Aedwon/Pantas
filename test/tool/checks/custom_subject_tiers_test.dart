import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/custom_subject_tiers.dart';
import '../../../tools/custom_tiers/build_custom_tiers.dart';

const _outline = <String, dynamic>{
  'subjects': [
    {
      'name': 'Mathematics',
      'slug': 'mathematics',
      'topics': [
        {'name': 'Algebra', 'slug': 'algebra'},
        {'name': 'Data Interpretation', 'slug': 'data-interpretation'},
        {'name': 'Empty', 'slug': 'empty-topic'},
      ],
    },
    {
      'name': 'General Information',
      'slug': 'general-information',
      'topics': [
        {'name': 'Constitution', 'slug': 'philippine-constitution'},
      ],
    },
    {
      'name': 'PSHS Only',
      'slug': 'pshs-only',
      'topics': [
        {'name': 'Entry', 'slug': 'entry'},
      ],
    },
  ],
};
const _examTiers = <String, String>{
  'exam_upcat': 'Student',
  'exam_cse_pro': 'Civil Service',
  'exam_let': 'Licensure',
  'exam_pshs_nce': 'PSHS-NCE',
};

Map<String, Object?> build(List<TierSet> sets) => buildCustomTiers(
      sets: sets,
      outline: _outline,
      examTiers: _examTiers,
    );

void main() {
  group('generator', () {
    test('a subject takes the lowest tier and a topic the highest', () {
      final table = build(const [
        TierSet('mathematics', 'algebra', ['upcat', 'cse-pro']),
        TierSet('mathematics', 'data-interpretation', ['cse-pro']),
        TierSet('general-information', 'philippine-constitution', ['cse-pro']),
      ]);
      final subjects =
          (table['subjects']! as List).cast<Map<String, Object?>>();
      expect(subjects.map((s) => '${s['name']}=${s['tier']}'), [
        'Mathematics=Student',
        'General Information=Civil Service',
      ]);
      expect(subjects.first['topicIds'], [
        'topic_upcat_algebra',
        'topic_upcat_data_interpretation',
      ]);
      expect(table['topicTiers'], {
        'topic_upcat_algebra': 'Civil Service',
        'topic_upcat_data_interpretation': 'Civil Service',
        'topic_upcat_philippine_constitution': 'Civil Service',
      });
    });

    test('a topic outside the outline is recorded with its highest tier', () {
      final table = build(const [
        TierSet('mathematics', 'algebra', ['upcat']),
        TierSet('mathematics', 'new-topic', ['upcat', 'let']),
      ]);
      expect(
        (table['topicTiers']! as Map)['topic_upcat_new_topic'],
        'Licensure',
      );
      final math = (table['subjects']! as List).single as Map;
      expect(math['topicIds'], ['topic_upcat_algebra']);
    });

    test('PSHS-NCE never counts when another tier is present', () {
      final table = build(const [
        TierSet('mathematics', 'algebra', ['upcat', 'pshs-nce']),
      ]);
      final math = (table['subjects']! as List).single as Map;
      expect(math['tier'], 'Student');
    });

    test('a subject whose only tag is PSHS-NCE stops the build', () {
      expect(
        () => build(const [
          TierSet('pshs-only', 'entry', ['pshs-nce']),
        ]),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('check', () {
    final generated = build(const [
      TierSet('mathematics', 'algebra', ['upcat']),
      TierSet('general-information', 'philippine-constitution', ['cse-pro']),
    ]);

    test('a current table passes', () {
      expect(findStaleSubjectTiers(generated, generated), isEmpty);
    });

    test('a stale tier names the subject', () {
      final stale = build(const [
        TierSet('mathematics', 'algebra', ['upcat']),
        TierSet('general-information', 'philippine-constitution', ['upcat']),
      ]);
      final found = findStaleSubjectTiers(stale, generated);
      expect(found, hasLength(greaterThanOrEqualTo(1)));
      expect(found.first.where, 'General Information');
      expect(found.first.message, contains('Civil Service'));
    });

    test('a subject missing from the file is named', () {
      final stale = build(const [
        TierSet('mathematics', 'algebra', ['upcat']),
      ]);
      expect(
        findStaleSubjectTiers(stale, generated).map((v) => v.where),
        contains('General Information'),
      );
    });

    test('a missing file fails', () {
      expect(findStaleSubjectTiers(null, generated), isNotEmpty);
    });
  });
}

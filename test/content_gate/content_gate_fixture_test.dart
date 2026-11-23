// Proves the content gate can fail: one broken item per check, each caught
// and named. The good item must stay clean. The fixture is written as the
// documents the upload packages (catalog, question set), so the real mirror
// loads it the way a student's app does.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'content_gate.dart';

Map<String, Object?> _doc(String id, Map<String, Object?> fields) => {
      '_id': id,
      '_updatedAt': '2026-11-23T00:00:00.000Z',
      'schemaVersion': 1,
      'isActive': true,
      ...fields,
    };

Map<String, Object?> _question(
  String id,
  List<bool> correct, {
  String? passage,
}) =>
    {
      'id': id,
      if (passage != null) 'passage': passage,
      'stem': 'Stem of $id',
      'explanation': 'Because.',
      'choices': [
        for (var i = 0; i < correct.length; i++)
          {'text': 'Choice $i', 'correct': correct[i]},
      ],
    };

void _write(Directory root, String path, Map<String, Object?> doc) {
  File('${root.path}/$path')
    ..createSync(recursive: true)
    ..writeAsStringSync(jsonEncode(doc));
}

void main() {
  testWidgets('one broken item per check is caught', (tester) async {
    final longId = 'q-${'x' * 99}';
    expect(longId.length, 101);
    final dir = Directory.systemTemp.createTempSync('pantas_gate_fixture_');
    addTearDown(() => dir.deleteSync(recursive: true));

    _write(dir, 'catalog/index.json', {
      'id': 'index',
      'exams': [
        _doc('exam_fix', {
          'code': 'FIX',
          'name': 'Fixture',
          'shortName': 'Fix',
          'language': 'en',
          'ordering': 1,
        }),
      ],
      'subjects': [
        _doc('subj_fix', {
          'exam': {'_ref': 'exam_fix'},
          'name': 'Subject',
          'ordering': 1,
        }),
      ],
      'topics': [
        _doc('topic_upcat_fix', {
          'subject': {'_ref': 'subj_fix'},
          'name': 'Topic',
          'ordering': 1,
        }),
      ],
      'catalogs': ['exam_fix'],
    });
    final ids = [
      'q-good',
      'q-bad-key',
      'q-two-correct',
      'q-no-passage',
      longId,
    ];
    _write(dir, 'catalog/exam_fix.json', {
      'id': 'exam_fix',
      'sets': [
        {
          'id': 'qs-fix',
          'topic': 'topic_upcat_fix',
          'subtopic': 'subtopic_s',
          'exams': ['exam_fix'],
          'questions': [
            for (final id in ids)
              {'id': id, if (id == 'q-no-passage') 'passage': 'p-missing'},
          ],
        },
      ],
      'mockBlueprints': [
        _doc('mock_blueprint_fix', {
          'schemaVersion': 2,
          'exam': {'_ref': 'exam_fix'},
          'name': 'Fixture paper',
          'durationMinutes': 10,
          'sectionalTiming': 'roamable',
          'sections': [
            {
              'id': 'sec_fix',
              'name': 'Section',
              'questionCount': 50,
              'suggestedMinutes': 10,
              'topicIds': ['topic_upcat_fix'],
              'topicWeights': {'topic_upcat_fix': 1},
            },
          ],
        }),
      ],
      'parts': <String>[],
    });
    _write(dir, 'questions/qs-fix.json', {
      'id': 'qs-fix',
      'meta': {
        'topic': 'fix',
        'subtopic': 's',
        'exams': ['fix'],
      },
      'questions': [
        _question('q-good', [true, false, false]),
        _question('q-bad-key', [false, false, false]),
        _question('q-two-correct', [true, true, false]),
        _question('q-no-passage', [true, false], passage: 'p-missing'),
        _question(longId, [true, false, false]),
      ],
    });

    final report = await runContentGate(tester, dir);
    final found = {for (final f in report.failures) '${f.itemId}|${f.check}'};

    expect(found, contains('q-bad-key|shape'));
    expect(found, contains('q-two-correct|shape'));
    expect(found, contains('q-no-passage|passage'));
    expect(found, contains('$longId|analytics'));
    expect(found, contains('mock_blueprint_fix|mock'));
    expect(
      report.failures.where((f) => f.itemId == 'q-good'),
      isEmpty,
      reason: 'the good item must pass every check',
    );
  });
}

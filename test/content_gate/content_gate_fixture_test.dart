// Proves the content gate can fail: one broken item per check, each caught
// and named. The good item must stay clean.
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

List<Object?> _text(String t) => [
      {
        '_type': 'block',
        'style': 'normal',
        'children': [
          {'_type': 'span', 'text': t, 'marks': <String>[]},
        ],
      },
    ];

Map<String, Object?> _question(
  String id,
  List<bool> correct, {
  String? passage,
}) =>
    _doc(id, {
      'topic': {'_ref': 'topic_fix'},
      'examIds': [
        {'_ref': 'exam_fix'},
      ],
      'language': 'en',
      'stem': _text('Stem of $id'),
      'explanation': _text('Because.'),
      'version': 1,
      if (passage != null) 'passage': {'_ref': passage},
      'choices': [
        for (var i = 0; i < correct.length; i++)
          {
            '_key': '${id}_${'abcd'[i]}',
            'label': 'ABCD'[i],
            'text': 'Choice $i',
            'isCorrect': correct[i],
          },
      ],
    });

void main() {
  testWidgets('one broken item per check is caught', (tester) async {
    final longId = 'q-${'x' * 99}';
    expect(longId.length, 101);
    final export = {
      'exam': [
        _doc('exam_fix', {
          'code': 'FIX',
          'name': 'Fixture',
          'shortName': 'Fix',
          'language': 'en',
          'ordering': 1,
        }),
      ],
      'subject': [
        _doc('subj_fix', {
          'exam': {'_ref': 'exam_fix'},
          'name': 'Subject',
          'ordering': 1,
        }),
      ],
      'topic': [
        _doc('topic_fix', {
          'subject': {'_ref': 'subj_fix'},
          'name': 'Topic',
          'ordering': 1,
        }),
      ],
      'question': [
        _question('q-good', [true, false, false]),
        _question('q-bad-key', [false, false, false]),
        _question('q-two-correct', [true, true, false]),
        _question('q-no-passage', [true, false], passage: 'p-missing'),
        _question(longId, [true, false, false]),
      ],
      'mockBlueprint': [
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
              'topicIds': ['topic_fix'],
              'topicWeights': {'topic_fix': 1},
            },
          ],
        }),
      ],
    };
    final dir = Directory.systemTemp.createTempSync('pantas_gate_fixture_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/export.json')
      ..writeAsStringSync(jsonEncode(export));

    final report = await runContentGate(tester, file);
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

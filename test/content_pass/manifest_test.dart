// ignore_for_file: cascade_invocations, use_raw_strings, require_trailing_commas, unnecessary_raw_strings, lines_longer_than_80_chars
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tools/content_pass/server/manifest.dart';

const _qFile = '''
meta:
  subject: science
  topic: biology
  subtopic: cells
  exams: [cse-pro]
questions:
  - id: q-shown
    stem: |
      What is a cell?
    choices: []
  - id: q-no-figure
    stem: |
      Look at the picture.
    figure: a drawing of a cell
    choices: []
''';

const _upcatOnly = '''
meta:
  subject: science
  topic: biology
  subtopic: other
  exams: [upcat]
questions:
  - id: q-upcat
    stem: Not for CSE.
    choices: []
''';

String _lesson(String id, {String active = 'true', int markers = 1}) => '''
---
_id: "$id"
title: "Title of $id"
summary: "s"
subject: "subject-science"
topic: "topic-biology"
estimatedMinutes: 5
isActive: $active
---
## Core Concept

${List.generate(markers, (i) => '<!-- ILLUSTRATION: picture ${i + 1} -->').join('\n\n')}
''';

const _svg = '<svg xmlns="http://www.w3.org/2000/svg" width="1" height="1"/>';

String _mock(String exam, String id) => '''
_id: $id
isActive: true
exam: $exam
name: Mock for $exam
durationMinutes: 10
sections: []
''';

Map<String, Object?> _export() => {
      'subject': [
        {
          '_id': 'subj_science',
          'exam': {'_ref': 'exam_upcat'},
        },
      ],
      'topic': [
        {
          '_id': 'topic_upcat_biology',
          'subject': {'_ref': 'subj_science'},
        },
      ],
      'question': [
        {
          '_id': 'q-shown',
          'topic': {'_ref': 'topic_upcat_biology'},
          'examIds': [
            {'_ref': 'exam_cse_pro'},
          ],
          'isActive': true,
        },
      ],
      'lesson': [
        {
          '_id': 'lesson-biology-cells',
          'topic': {'_ref': 'topic_upcat_biology'},
          'isActive': true,
        },
      ],
    };

void main() {
  late Directory root;

  void write(String path, String text) {
    File('${root.path}/$path')
      ..createSync(recursive: true)
      ..writeAsStringSync(text);
  }

  setUp(() {
    root = Directory.systemTemp.createTempSync('manifest_test');
    write('content/questions/science/biology/cells.yaml', _qFile);
    write('content/questions/science/biology/other.yaml', _upcatOnly);
    write(
      'content/lessons/science/biology/cells.md',
      _lesson('lesson-biology-cells'),
    );
    write(
      'content/lessons/science/biology/off.md',
      _lesson('lesson-biology-off', active: 'false'),
    );
    write('content/illustrations/science/biology/cells/01-one.svg', _svg);
    write('content/illustrations/science/biology/cells/02-two.svg', _svg);
    write('content/mock/cse-pro.yaml', _mock('exam_cse_pro', 'mock_pro'));
    write('content/mock/upcat.yaml', _mock('exam_upcat', 'mock_upcat'));
  });

  tearDown(() => root.deleteSync(recursive: true));

  Map<String, Object?> item(Manifest m, String id) =>
      m.items.singleWhere((i) => i['id'] == id);

  test('only items for CSE Pro and CSE Subpro are listed', () {
    final m = buildManifest(root.path, _export());

    final ids = [for (final i in m.items) i['id']];
    expect(ids, containsAll(['q-shown', 'lesson-biology-cells', 'mock_pro']));
    expect(ids, isNot(contains('q-upcat')));
    expect(ids, isNot(contains('mock_upcat')));
  });

  test('a question the export left out says why', () {
    final m = buildManifest(root.path, _export());

    expect(item(m, 'q-shown')['cantShow'], isNull);
    expect(
      item(m, 'q-no-figure')['cantShow'],
      'The app leaves this question out: its figure is not drawn yet.',
    );
  });

  test('a switched-off lesson cannot be shown', () {
    final m = buildManifest(root.path, _export());

    expect(
      item(m, 'lesson-biology-off')['cantShow'],
      'Students do not see this: it is switched off.',
    );
    expect(item(m, 'lesson-biology-cells')['cantShow'], isNull);
  });

  test('a figure no lesson marker uses cannot be shown', () {
    final m = buildManifest(root.path, _export());

    final used = item(m, 'science/biology/cells/01-one.svg');
    final unused = item(m, 'science/biology/cells/02-two.svg');
    expect(used['cantShow'], isNull);
    expect(used['lessonId'], 'lesson-biology-cells');
    expect(unused['cantShow'], 'No lesson uses this figure.');
    expect(m.figureBlocks.keys, contains('science/biology/cells/01-one.svg'));
  });

  test('the hash changes with the question, the lesson and its figures', () {
    final before = buildManifest(root.path, _export());
    write(
      'content/illustrations/science/biology/cells/01-one.svg',
      '$_svg<!-- edited -->',
    );
    write(
      'content/questions/science/biology/cells.yaml',
      _qFile.replaceFirst('What is a cell?', 'What is a living cell?'),
    );
    final after = buildManifest(root.path, _export());

    String hash(Manifest m, String id) => item(m, id)['hash']! as String;
    expect(hash(after, 'q-shown'), isNot(hash(before, 'q-shown')));
    expect(hash(after, 'q-no-figure'), hash(before, 'q-no-figure'));
    expect(
      hash(after, 'lesson-biology-cells'),
      isNot(hash(before, 'lesson-biology-cells')),
    );
  });

  test('a question only the export carries is listed with its source', () {
    final export = _export();
    (export['question']! as List).add({
      '_id': 'q-old',
      'topic': {'_ref': 'topic_upcat_biology'},
      'examIds': [
        {'_ref': 'exam_cse_pro'},
      ],
      'stem': [
        {
          'children': [
            {'text': 'An old question'},
          ],
        },
      ],
      'isActive': true,
    });
    final m = buildManifest(root.path, export);

    expect(item(m, 'q-old')['file'],
        'tools/build_content_export/historical_v1.json');
    expect(item(m, 'q-old')['title'], 'An old question');
    expect(item(m, 'q-old')['cantShow'], isNull);
  });

  test('canonical hashing ignores key order', () {
    expect(
      canonicalHash({
        'a': 1,
        'b': [1, 2],
      }),
      canonicalHash({
        'b': [1, 2],
        'a': 1,
      }),
    );
  });
}

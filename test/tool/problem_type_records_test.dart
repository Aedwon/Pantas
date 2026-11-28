import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tools/build_content_export/problem_types.dart';

const _lesson = 'lesson-spatial-abstract-reasoning-matrix-keeping-all-features';
const _typeBase = 'content/types/reasoning/spatial-abstract-reasoning/'
    'matrix-keeping-all-features/'
    'qt-spatial-abstract-reasoning-matrix-ray-union';
const _typeId = 'qt-spatial-abstract-reasoning-matrix-ray-union';
const _source = 'q-spatial-abstract-reasoning-figure-matrices-0005';
const _topics = {'spatial-abstract-reasoning': 'topic_upcat_spatial'};

/// Builds a content root holding one copy of a real type and its sources.
Directory _fixture({
  bool enabled = true,
  String? stem,
  List<String> sourceExams = const ['acet', 'dost-sei'],
  bool pshsQuestion = false,
  String pshsLesson = _lesson,
  bool held = false,
}) {
  final root = Directory.systemTemp.createTempSync('problem-type-records');
  addTearDown(() => root.deleteSync(recursive: true));
  final type = jsonDecode(File('$_typeBase.yaml').readAsStringSync())
      as Map<String, Object?>;
  type['enabled'] = enabled;
  if (stem != null) type['stem'] = stem;
  final folder = held ? 'types-held' : 'types';
  final target = Directory(
    '${root.path}/content/$folder/reasoning/spatial-abstract-reasoning/'
    'matrix-keeping-all-features',
  )..createSync(recursive: true);
  File('${target.path}/$_typeId.yaml').writeAsStringSync(jsonEncode(type));
  File('${target.path}/$_typeId.variants.yaml').writeAsStringSync(
    File('$_typeBase.variants.yaml').readAsStringSync(),
  );
  final questions = Directory(
    '${root.path}/content/questions/reasoning/spatial-abstract-reasoning',
  )..createSync(recursive: true);
  File('${questions.path}/figure-matrices.yaml').writeAsStringSync('''
meta:
  topic: spatial-abstract-reasoning
  subtopic: figure-matrices
  exams: [${sourceExams.join(', ')}]
questions:
  - id: $_source
    lesson: $_lesson
''');
  if (pshsQuestion) {
    File('${questions.path}/figure-matrices-pshs.yaml').writeAsStringSync('''
meta:
  topic: spatial-abstract-reasoning
  subtopic: figure-matrices-pshs
  exams: [pshs-nce]
questions:
  - id: q-spatial-abstract-reasoning-figure-matrices-pshs-0001
    lesson: $pshsLesson
''');
  }
  return root;
}

void main() {
  test('a held type is never exported', () {
    final root = _fixture(held: true);
    final result = exportProblemTypes(root.path, _topics);
    expect(result.records, isEmpty);
    expect(result.mergedActivity, isEmpty);
  });

  test('each variant carries variantIndex, ruleKey and rendered text', () {
    final root = _fixture();
    final record = exportProblemTypes(root.path, _topics).records.single;
    final free = record['free']! as Map<String, Object?>;
    final variants =
        (free['variants']! as List<Object?>).cast<Map<String, Object?>>();
    expect(variants, isNotEmpty);
    for (var i = 0; i < variants.length; i++) {
      expect(variants[i]['variantIndex'], i);
      expect(variants[i], isNot(contains('index')));
      expect(variants[i]['ruleKey'], isA<String>());
      expect(variants[i]['stem'], isNot(contains('{')));
      expect(variants[i]['explanation'], isNot(contains('{')));
    }
    expect(
      (variants.first['choices']! as List<Object?>).first,
      containsPair('correct', true),
    );
  });

  test('Pro notes sit by variantIndex and choice position, never in Free', () {
    final root = _fixture();
    final record = exportProblemTypes(root.path, _topics).records.single;
    final free = record['free']! as Map<String, Object?>;
    final variants =
        (free['variants']! as List<Object?>).cast<Map<String, Object?>>();
    final rationales = (record['pro']! as Map<String, Object?>)['rationales']!
        as Map<String, Object?>;
    expect(rationales.keys, [for (var i = 0; i < variants.length; i++) '$i']);
    final notes = <String>[];
    for (final variant in variants) {
      final choices =
          (variant['choices']! as List<Object?>).cast<Map<String, Object?>>();
      final row = rationales['${variant['variantIndex']}']! as List<Object?>;
      expect(row, hasLength(choices.length));
      for (var i = 0; i < choices.length; i++) {
        if (choices[i]['correct'] == true) {
          expect(row[i], isNull);
        } else {
          expect(row[i], isA<String>());
          notes.add(row[i]! as String);
        }
      }
    }
    expect(notes, isNotEmpty);
    final freeText = jsonEncode(free);
    for (final note in notes.toSet()) {
      expect(freeText, isNot(contains(note)));
    }
    expect(freeText, isNot(contains('rationale')));
  });

  group('exam tags', () {
    test('come from the source files, never from the type file', () {
      final root = _fixture(sourceExams: ['acet', 'dost-sei', 'dlsucet']);
      final question = exportProblemTypes(root.path, _topics)
          .records
          .single['question']! as Map<String, Object?>;
      // The type file itself says acet, ustet, dost-sei, cse-pro.
      expect(question['exams'], ['acet', 'dost-sei', 'dlsucet']);
    });

    test('add pshs-nce when the type lesson has PSHS-NCE questions', () {
      final root = _fixture(pshsQuestion: true);
      final question = exportProblemTypes(root.path, _topics)
          .records
          .single['question']! as Map<String, Object?>;
      expect(question['exams'], ['acet', 'dost-sei', 'pshs-nce']);
    });

    test('leave out pshs-nce when only another lesson has PSHS-NCE questions',
        () {
      final root = _fixture(
        pshsQuestion: true,
        pshsLesson: 'lesson-spatial-abstract-reasoning-figure-counts-and-fills',
      );
      final question = exportProblemTypes(root.path, _topics)
          .records
          .single['question']! as Map<String, Object?>;
      expect(question['exams'], ['acet', 'dost-sei']);
    });

    test('on the real tree they follow the live source files', () {
      final record = exportProblemTypes('.', _topics).records.firstWhere(
            (row) =>
                (row['question']! as Map<String, Object?>)['id'] == _typeId,
          );
      final question = record['question']! as Map<String, Object?>;
      // figure-matrices.yaml on this tree tags acet, ustet, dost-sei, cse-pro.
      // The content/pshs-nce-r1 branch retags some files; the export follows
      // whatever the files say when they merge (see the fixture tests above).
      expect(question['exams'], ['acet', 'ustet', 'dost-sei', 'cse-pro']);
    });

    test('the Free variant document carries the same tags', () {
      final root = _fixture(pshsQuestion: true);
      final record = exportProblemTypes(root.path, _topics).records.single;
      expect(
        (record['free']! as Map<String, Object?>)['exams'],
        (record['question']! as Map<String, Object?>)['exams'],
      );
    });

    test('the mock flag keeps type rows out of a pshs-nce mock', () {
      final withPshs = _fixture(pshsQuestion: true);
      final tagged = exportProblemTypes(withPshs.path, _topics)
          .records
          .single['question']! as Map<String, Object?>;
      expect(tagged['exams'], contains('pshs-nce'));
      expect(tagged['mockExams'], ['acet', 'dost-sei']);
      final without = _fixture();
      final plain = exportProblemTypes(without.path, _topics)
          .records
          .single['question']! as Map<String, Object?>;
      expect(plain['mockExams'], plain['exams']);
    });
  });

  group('active state (L2)', () {
    test('an enabled type is active and its merged question is inactive', () {
      final root = _fixture();
      final result = exportProblemTypes(root.path, _topics);
      expect(
        (result.records.single['question']!
            as Map<String, Object?>)['isActive'],
        isTrue,
      );
      // mergedActivity holds the isActive value each source row must carry.
      expect(result.mergedActivity, {_source: false});
    });

    test('a disabled type is inactive and its merged question is active', () {
      final root = _fixture(enabled: false);
      final result = exportProblemTypes(root.path, _topics);
      expect(
        (result.records.single['question']!
            as Map<String, Object?>)['isActive'],
        isFalse,
      );
      expect(result.mergedActivity, {_source: true});
    });
  });

  group('size', () {
    test('a Free variant document of 200,000 bytes or more fails the export',
        () {
      final root = _fixture(stem: 'x' * 20000);
      expect(
        () => exportProblemTypes(root.path, _topics),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            allOf(contains(_typeId), contains('200,000')),
          ),
        ),
      );
    });

    test('the real types stay under the limit', () {
      final result = exportProblemTypes('.', _topics);
      expect(result.records, hasLength(28));
      var largest = 0;
      var largestId = '';
      for (final record in result.records) {
        final id =
            (record['question']! as Map<String, Object?>)['id']! as String;
        // The stored document is the wrapper around the payload string.
        final size = utf8
            .encode(
              jsonEncode({
                'kind': 'variants',
                'id': id,
                'version': '0000000000000000',
                'payload': jsonEncode(record['free']),
              }),
            )
            .length;
        expect(size, lessThan(200000));
        if (size > largest) {
          largest = size;
          largestId = id;
        }
      }
      // Recorded in FINDINGS-Export.md when the real corpus changes.
      // ignore: avoid_print
      print('largest Free variant document: $largest bytes ($largestId)');
    });
  });

  test('a type that cites a missing source question fails the export', () {
    final root = _fixture();
    File(
      '${root.path}/content/questions/reasoning/spatial-abstract-reasoning/'
      'figure-matrices.yaml',
    ).writeAsStringSync('''
meta:
  topic: spatial-abstract-reasoning
  subtopic: figure-matrices
  exams: [acet]
questions:
  - id: q-someone-else
    lesson: $_lesson
''');
    expect(
      () => exportProblemTypes(root.path, _topics),
      throwsA(isA<FormatException>()),
    );
  });
}

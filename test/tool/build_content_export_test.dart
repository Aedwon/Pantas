import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/remote/content_catalog.dart';
import 'package:pantas/core/content/sanity/parsers/exam_parser.dart';
import 'package:pantas/core/content/sanity/parsers/lesson_parser.dart';
import 'package:pantas/core/content/sanity/parsers/question_parser.dart';
import 'package:pantas/core/content/sanity/parsers/subject_parser.dart';
import 'package:pantas/core/content/sanity/parsers/topic_parser.dart';
import 'package:yaml/yaml.dart';

import '../../tool/content/ledger.dart';
import '../../tool/content/question_hash.dart';
import '../../tools/build_content_export/build_content_export.dart' as exporter;

void main() {
  group('bite-sized lesson metadata', () {
    late Directory root;
    setUp(() {
      root = Directory.systemTemp.createTempSync('lesson-metadata');
      Directory('${root.path}/content/lessons/s/test')
          .createSync(recursive: true);
      Directory('${root.path}/content/illustrations').createSync();
      File('${root.path}/content/illustrations/assets.json')
          .writeAsStringSync('{}');
    });
    tearDown(() => root.deleteSync(recursive: true));
    void lesson(
      String id, {
      String front = '',
      String body = '',
      String subject = 'subject-mathematics',
    }) {
      File('${root.path}/content/lessons/s/test/$id.md').writeAsStringSync(
        '---\n_id: lesson-test-$id\ntopic: topic-test\nsubject: $subject\n'
        'title: Test\nsummary: Test\nestimatedMinutes: 1\n$front---\n$body',
      );
    }

    List<Map<String, Object?>> build() =>
        exporter.buildLessons({'test': 'topic_test'}, root.path);
    for (final (name, keys, subject, expected) in [
      ('unsplit', 0, 'subject-mathematics', 5),
      ('floor', 1, 'subject-mathematics', 2),
      ('math examples', 4, 'subject-mathematics', 6),
      ('non-math examples', 3, 'subject-science', 3),
      ('example cap', 1, 'subject-mathematics', 3),
    ]) {
      test('quizSize $name', () {
        lesson(
          'one',
          front: keys == 0
              ? ''
              : 'keyPoints: '
                  '${jsonEncode(List.generate(keys, (i) => 'Point $i'))}\n'
                  'part: 1\npartCount: 2\n',
          subject: subject,
          body: name == 'floor'
              ? ''
              : '## Core Concept\n### Not an example\n'
                  '## Examples\n### First\nOne.\n### Second\nTwo.\n'
                  '${name == 'example cap' ? '### Third\nThree.\n' : ''}'
                  '## Traps\n### Not an example\n',
        );
        final row = build().single;
        expect(row['quizSize'], expected);
        expect(row['status'], 'active');
        if (keys > 0) {
          expect(row['keyPoints'], hasLength(keys));
          expect(row['part'], 1);
          expect(row['partCount'], 2);
        }
      });
    }
    test('ordering must be all or none within a topic', () {
      lesson('one', front: 'ordering: 2\n');
      lesson('two');
      expect(
        build,
        throwsA(
          isA<FormatException>()
              .having((e) => e.message, 'topic', contains('topic_test')),
        ),
      );
    });
    test('retired lessons without ordering do not fail export', () {
      lesson('one', front: 'ordering: 2\n');
      lesson(
        'original',
        front: 'status: retired\nreplacedBy: [lesson-test-one]\n',
      );
      final rows = build();
      expect(rows, hasLength(2));
      expect(
        rows.singleWhere((row) => row['status'] == 'active')['ordering'],
        2,
      );
    });
    test('retired ordering does not require active lesson ordering', () {
      lesson('one');
      lesson('original', front: 'status: retired\nordering: 2\n');
      expect(build(), hasLength(2));
    });
    test('ordering preserves explicit values and fallback', () {
      lesson('one');
      lesson('two');
      expect(build().map((l) => l['ordering']), [1, 2]);
      lesson('one', front: 'ordering: 7\n');
      lesson('two', front: 'ordering: 4\n');
      expect(build().map((l) => l['ordering']), [7, 4]);
    });
  });

  test('export refuses unapproved questions before writing output', () async {
    final root = Directory.systemTemp.createTempSync('export_gate');
    addTearDown(() => root.deleteSync(recursive: true));
    final questions = Directory('${root.path}/content/questions/math/algebra')
      ..createSync(recursive: true);
    File('${questions.path}/intro.yaml').writeAsStringSync('''
meta:
  subject: math
  topic: algebra
  subtopic: intro
  exams: [upcat]
questions:
  - id: q-unapproved
    stem: What is one plus one?
    explanation: One plus one is two.
    choices:
      - text: Two
        correct: true
      - text: Three
        correct: false
''');
    Directory('${root.path}/content/lessons').createSync();
    final illustrations = Directory('${root.path}/content/illustrations')
      ..createSync();
    File('${illustrations.path}/assets.json').writeAsStringSync('{}');
    final outline = File('${root.path}/tools/lesson_author/outline.json');
    outline.parent.createSync(recursive: true);
    outline.writeAsStringSync(
      jsonEncode({
        'subjects': [
          {
            'slug': 'math',
            'name': 'Math',
            'topics': [
              {'slug': 'algebra', 'name': 'Algebra'},
            ],
          },
        ],
      }),
    );
    final historical = File(
      '${root.path}/tools/build_content_export/historical_v1.json',
    );
    historical.parent.createSync(recursive: true);
    historical.writeAsStringSync(
      jsonEncode({
        'exams': <Object?>[],
        'topics': <Object?>[],
        'questions': <Object?>[],
        'lessons': <Object?>[],
      }),
    );
    final output = File('${root.path}/export.json');
    final assets = Directory('${root.path}/assets');
    final result = await Process.run('dart', [
      'run',
      'tools/build_content_export/build_content_export.dart',
      output.path,
      root.path,
      '--assets-out',
      assets.path,
    ]);
    expect(result.exitCode, isNot(0));
    expect(result.stderr, contains('q-unapproved: not approved'));
    expect(output.existsSync(), isFalse);
    expect(assets.existsSync(), isFalse);
  });

  test('YAML passage overrides historical text and keeps historical fallback',
      () async {
    final temp = Directory.systemTemp.createTempSync('passage_export');
    addTearDown(() => temp.deleteSync(recursive: true));
    void write(String path, String text) {
      final file = File('${temp.path}/$path');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(text);
    }

    write(
      'tools/build_content_export/historical_v1.json',
      jsonEncode({
        'exams': <Object?>[],
        'topics': <Object?>[],
        'questions': <Object?>[],
        'lessons': <Object?>[],
        'passages': [
          for (final id in ['shared-passage', 'historical-only'])
            {
              'id': id,
              'topicId': 'topic_upcat_algebra',
              'title': 'Old title',
              'body': 'Old body',
              'language': 'en',
              'wordCount': 2,
            },
        ],
      }),
    );
    write(
      'tools/lesson_author/outline.json',
      jsonEncode({
        'subjects': [
          {
            'slug': 'mathematics',
            'name': 'Mathematics',
            'topics': [
              {'slug': 'algebra', 'name': 'Algebra'},
            ],
          },
        ],
      }),
    );
    write('content/illustrations/assets.json', '{}');
    Directory('${temp.path}/content/lessons').createSync();
    write('content/questions/mathematics/algebra/test.yaml', '''
meta:
  topic: algebra
  subtopic: intro
  exams: [upcat]
passages:
  - id: shared-passage
    title: Updated heading
    body: |
      Updated passage with
      four more words.
questions: []
''');
    final path = '${temp.path}/export.json';
    final result = await Process.run('dart', [
      'run',
      'tools/build_content_export/build_content_export.dart',
      path,
      temp.path,
    ]);
    expect(result.exitCode, 0, reason: result.stderr.toString());
    final output =
        jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
    final passages = (output['passage'] as List).cast<Map<String, Object?>>();
    expect(
      passages.map((p) => p['_id']),
      ['shared-passage', 'historical-only'],
    );
    final updated = passages.first;
    expect(updated['title'], 'Updated heading');
    expect(updated['body'], 'Updated passage with\nfour more words.\n');
    expect(updated['wordCount'], 6);
    expect(updated['_updatedAt'], isNot(passages.last['_updatedAt']));
    expect(updated['topic'], {'_ref': 'topic_upcat_algebra'});
    expect(updated['language'], 'en');
    expect(passages.last['title'], 'Old title');
    expect(passages.last['body'], 'Old body');
    expect(passages.last['wordCount'], 2);
  });

  test('historical CSE samples stay inactive through export parsing', () async {
    final temp = Directory.systemTemp.createTempSync('retired_cse');
    addTearDown(() => temp.deleteSync(recursive: true));
    final path = '${temp.path}/export.json';
    final result = await Process.run('dart', [
      'run',
      'tools/build_content_export/build_content_export.dart',
      path,
    ]);
    expect(result.exitCode, 0, reason: result.stderr.toString());
    final output =
        jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
    Map<String, Object?> row(String kind, String id) =>
        (output[kind] as List).cast<Map<String, Object?>>().singleWhere(
              (doc) => doc['_id'] == id,
            );

    expect(
      parseSubject(row('subject', 'subj_cse_verbal')).isActive.value,
      isFalse,
    );
    expect(
      parseTopic(row('topic', 'topic_cse_vocab')).isActive.value,
      isFalse,
    );
    for (final id in [
      'les_vocab_intro',
      'les_vocab_synonyms',
      'les_vocab_context',
    ]) {
      expect(parseLesson(row('lesson', id)).isActive.value, isFalse);
    }
    for (final id in ['q_001', 'q_002']) {
      expect(
        parseQuestion(row('question', id)).question.isActive.value,
        isFalse,
      );
    }
    final index = parseCatalogIndex({
      'subjects': output['subject'],
      'topics': output['topic'],
    });
    expect(
      index.subjects
          .singleWhere((s) => s.id.value == 'subj_cse_verbal')
          .isActive
          .value,
      isFalse,
    );
    expect(
      index.topics
          .singleWhere((t) => t.id.value == 'topic_cse_vocab')
          .isActive
          .value,
      isFalse,
    );
    expect(row('topic', 'topic_upcat_vocabulary')['isActive'], isTrue);
    expect(row('exam', 'exam_cse_pro')['isActive'], isTrue);
    final vocabularyLessons =
        (output['lesson'] as List).cast<Map<String, Object?>>().where(
              (doc) =>
                  (doc['topic']! as Map<String, Object?>)['_ref'] ==
                  'topic_upcat_vocabulary',
            );
    expect(vocabularyLessons, isNotEmpty);
    expect(vocabularyLessons.every((doc) => doc['isActive'] == true), isTrue);
    final blueprints =
        (output['mockBlueprint'] as List).cast<Map<String, Object?>>();
    expect(
      blueprints.where(
        (doc) =>
            (doc['exam']! as Map<String, Object?>)['_ref'] == 'exam_cse_pro',
      ),
      isNotEmpty,
    );
  });

  test('build_content_export builds parseable Sanity documents', () async {
    final tempDir = Directory.systemTemp.createTempSync('content_export_test');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    // Setup the tool-owned historical source. It must never be a Flutter asset.
    final historicalDir = Directory(
      '${tempDir.path}/tools/build_content_export',
    )..createSync(recursive: true);
    File('${historicalDir.path}/historical_v1.json').writeAsStringSync(
      jsonEncode(<String, List<Object?>>{
        'exams': <Object?>[],
        'topics': <Object?>[],
        'questions': <Object?>[],
        'lessons': <Object?>[],
      }),
    );

    // Setup tools/lesson_author/outline.json
    final outlineDir = Directory('${tempDir.path}/tools/lesson_author')
      ..createSync(recursive: true);
    File('${outlineDir.path}/outline.json').writeAsStringSync(
      jsonEncode({
        'subjects': [
          {
            'slug': 'mathematics',
            'name': 'Mathematics',
            'topics': [
              {
                'slug': 'algebra',
                'name': 'Algebra',
              }
            ],
          }
        ],
      }),
    );

    // Setup content/illustrations/assets.json
    final illusDir = Directory('${tempDir.path}/content/illustrations')
      ..createSync(recursive: true);
    File('${illusDir.path}/assets.json').writeAsStringSync(
      jsonEncode({
        'mathematics/algebra/01-intro#1': {
          'url': 'https://cdn.sanity.io/images/demo.png',
          'alt': 'Coordinate axis diagram',
          'creditKey': 'coordinate-source',
        },
      }),
    );

    final sources = Directory('${illusDir.path}/sources')..createSync();
    File('${sources.path}/test.yaml').writeAsStringSync(
      'version: 1\nassets:\n  - key: coordinate-source\n    credit: Test artist / Public domain\n',
    );

    // Setup content/lessons
    final lessonsDir =
        Directory('${tempDir.path}/content/lessons/mathematics/algebra')
          ..createSync(recursive: true);
    File('${lessonsDir.path}/01-intro.md').writeAsStringSync('''
---
_id: lesson-algebra-intro
isActive: true
topic: topic-algebra
title: Intro to Algebra
summary: Basics
estimatedMinutes: 5
ordering: 1
---
# Hello
This is a lesson.

<!-- FIGURE: {"kind": "coordinate-graph", "formula": "y=x^2", "semanticsLabel": "Graph of y equals x squared"} -->

| x | y |
|---|---|
| 1 | 1 |
| 2 | 4 |

<!-- ILLUSTRATION: coordinate axis diagram -->
''');

    // Setup content/questions
    final questionsDir =
        Directory('${tempDir.path}/content/questions/mathematics/algebra')
          ..createSync(recursive: true);
    File('${questionsDir.path}/01-intro.yaml').writeAsStringSync('''
meta:
  subject: mathematics
  topic: algebra
  subtopic: intro
  exams: [UPCAT]
questions:
  - id: q001
    stem: "1 + 1 ="
    explanation: "2"
    choices:
      - text: "1"
        correct: false
      - text: "2"
        correct: true
  - id: q002
    stem: "2 + 2 ="
    explanation: "4"
    choices:
      - text: "4"
        correct: true
      - text: "3"
        correct: false
''');

    final doc = loadYaml(
      File('${questionsDir.path}/01-intro.yaml').readAsStringSync(),
    ) as YamlMap;
    writeLedger(
      File('${tempDir.path}/content/question-ledger/approved.json'),
      {
        for (final question in (doc['questions'] as YamlList).cast<YamlMap>())
          question['id'] as String: {
            'hash': questionHash(question, doc['meta'] as YamlMap),
            'evidence': 'test fixture',
          },
      },
    );
    final exportPath = '${tempDir.path}/export.json';

    // Run the export script
    final result = await Process.run('dart', [
      'run',
      'tools/build_content_export/build_content_export.dart',
      exportPath,
      tempDir.path,
    ]);

    expect(result.exitCode, 0, reason: result.stderr.toString());

    final output =
        jsonDecode(File(exportPath).readAsStringSync()) as Map<String, dynamic>;

    expect(output, containsPair('exam', isA<List<Object?>>()));
    expect(output, containsPair('subject', isA<List<Object?>>()));
    expect(output, containsPair('topic', isA<List<Object?>>()));
    expect(output, containsPair('question', isA<List<Object?>>()));
    expect(output, containsPair('lesson', isA<List<Object?>>()));

    for (final doc in output['exam'] as List) {
      final exam = doc as Map<String, Object?>;
      expect(
        exam['isActive'],
        isTrue,
        reason: '${exam['_id']} should be active',
      );
      parseExam(exam);
    }
    for (final doc in output['subject'] as List) {
      parseSubject(doc as Map<String, Object?>);
    }
    for (final doc in output['topic'] as List) {
      parseTopic(doc as Map<String, Object?>);
    }
    for (final doc in output['question'] as List) {
      parseQuestion(doc as Map<String, Object?>);
    }
    for (final doc in output['lesson'] as List) {
      final companion = parseLesson(doc as Map<String, Object?>);
      final bodyBlocks = (jsonDecode(companion.bodyJson.value) as List)
          .cast<Map<String, dynamic>>();
      expect(
        bodyBlocks.any((b) => b['_type'] == 'figureSpec'),
        isTrue,
        reason: 'figureSpec block should survive parseLesson and JSON encoding',
      );
      expect(
        bodyBlocks.any((b) => b['_type'] == 'table'),
        isTrue,
        reason: 'table block should survive parseLesson and JSON encoding',
      );
      expect(
        bodyBlocks.any((b) => b['_type'] == 'image'),
        isTrue,
        reason: 'image block should survive parseLesson and JSON encoding',
      );
    }
  });
}

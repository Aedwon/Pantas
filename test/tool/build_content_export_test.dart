import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/remote/content_catalog.dart';
import 'package:pantas/core/content/sanity/parsers/exam_parser.dart';
import 'package:pantas/core/content/sanity/parsers/lesson_parser.dart';
import 'package:pantas/core/content/sanity/parsers/question_parser.dart';
import 'package:pantas/core/content/sanity/parsers/subject_parser.dart';
import 'package:pantas/core/content/sanity/parsers/topic_parser.dart';

void main() {
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

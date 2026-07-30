import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/sanity/parsers/exam_parser.dart';
import 'package:pantas/core/content/sanity/parsers/lesson_parser.dart';
import 'package:pantas/core/content/sanity/parsers/question_parser.dart';
import 'package:pantas/core/content/sanity/parsers/subject_parser.dart';
import 'package:pantas/core/content/sanity/parsers/topic_parser.dart';

void main() {
  test('build_content_export builds parseable Sanity documents', () async {
    final tempDir = Directory.systemTemp.createTempSync('content_export_test');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    // Setup assets/seed/v1.json
    final seedDir = Directory('${tempDir.path}/assets/seed')
      ..createSync(recursive: true);
    File('${seedDir.path}/v1.json').writeAsStringSync(
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
      parseExam(doc as Map<String, Object?>);
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
      parseLesson(doc as Map<String, Object?>);
    }
  });
}

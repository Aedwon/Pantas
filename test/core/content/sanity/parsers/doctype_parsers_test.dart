import 'dart:convert';
import 'dart:io';

import 'package:cse_cet_reviewer/core/content/sanity/parser_exceptions.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/diagnostic_set_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/exam_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/lesson_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/mock_blueprint_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/mock_exam_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/question_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/subject_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/topic_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Map<String, dynamic> fixture;

  setUpAll(() {
    fixture = jsonDecode(
      File('test/fixtures/sanity/content_sample.json').readAsStringSync(),
    ) as Map<String, dynamic>;
  });

  test('each parser accepts the fixture happy path', () {
    expect(parseExam(fixture['exam'] as Map<String, Object?>).id.value,
        equals('exam_cse'));
    expect(
        parseSubject(fixture['subject'] as Map<String, Object?>).examId.value,
        equals('exam_cse'));
    expect(parseTopic(fixture['topic'] as Map<String, Object?>).subjectId.value,
        equals('subject_verbal'));
    expect(parseLesson(fixture['lesson'] as Map<String, Object?>).title.value,
        equals('Vocabulary Basics'));
    expect(
      parseMockBlueprint(fixture['mockBlueprint'] as Map<String, Object?>)
          .durationMinutes
          .value,
      equals(90),
    );
    expect(
        parseMockExam(fixture['mockExam'] as Map<String, Object?>).name.value,
        equals('Mock 1'));
    expect(
      parseDiagnosticSet(fixture['diagnosticSet'] as Map<String, Object?>)
          .questionIdsJson
          .value,
      equals(jsonEncode(['q_001', 'q_002'])),
    );
  });

  test('each parser rejects wrong schemaVersion', () {
    for (final entry in fixture.entries) {
      final doc = Map<String, Object?>.from(entry.value as Map);
      doc['schemaVersion'] = 999;
      expect(
        () => switch (entry.key) {
          'exam' => parseExam(doc),
          'subject' => parseSubject(doc),
          'topic' => parseTopic(doc),
          'question' => parseQuestion(doc),
          'lesson' => parseLesson(doc),
          'mockBlueprint' => parseMockBlueprint(doc),
          'mockExam' => parseMockExam(doc),
          'diagnosticSet' => parseDiagnosticSet(doc),
          _ => throw StateError(entry.key),
        },
        throwsA(isA<SchemaMismatchException>()),
        reason: entry.key,
      );
    }
  });

  test('question parser emits question row choices and exam junction rows', () {
    final parsed = parseQuestion(fixture['question'] as Map<String, Object?>);

    expect(parsed.question.id.value, equals('q_001'));
    expect(parsed.choices.map((choice) => choice.id.value),
        equals(['choice_a', 'choice_b']));
    expect(parsed.examLinks.map((link) => link.examId.value),
        equals(['exam_cse']));
  });

  test('lesson parser rejects malformed body Portable Text', () {
    final doc = Map<String, Object?>.from(fixture['lesson'] as Map);
    doc['body'] = [
      {
        '_type': 'block',
        'children': [
          {'_type': 'span'},
        ],
      },
    ];

    expect(() => parseLesson(doc), throwsA(isA<ParseException>()));
  });

  test('diagnostic parser preserves ordered question ids', () {
    final parsed =
        parseDiagnosticSet(fixture['diagnosticSet'] as Map<String, Object?>);

    expect(
        parsed.questionIdsJson.value, equals(jsonEncode(['q_001', 'q_002'])));
  });
}

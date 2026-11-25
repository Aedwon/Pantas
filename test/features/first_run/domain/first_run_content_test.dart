import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/first_run/domain/first_run_content.dart';
import 'package:yaml/yaml.dart';

// The run must never point at content that does not ship for the exam: a
// missing, unapproved or untagged item would show an error to a new learner.
void main() {
  const questions =
      'content/questions/mathematics/arithmetic-number-sense/fractions-decimals-percentages.yaml';
  const lesson =
      'content/lessons/mathematics/arithmetic-number-sense/fractions-decimals-percentages.md';

  test('every first-run exam gets the same three questions in order', () {
    for (final exam in firstRunExamIds) {
      final run = firstRunContentFor(exam)!;
      expect(run.questionIds, hasLength(3));
      expect(run.questionIds.first, endsWith('-0001'));
      expect(run.questionIds[1], endsWith('-0003'));
      expect(run.questionIds[2], endsWith('-0002'));
    }
  });

  test('exams with no fixed lesson get no run', () {
    for (final exam in ['exam_dost_sei', 'exam_sm_foundation', 'custom_x']) {
      expect(firstRunContentFor(exam), isNull);
    }
  });

  test('the lesson exists and is active', () {
    final text = File(lesson).readAsStringSync();
    final id = firstRunContentFor('exam_cse_pro')!.lessonId;
    expect(text, contains('_id: "$id"'));
    expect(text, contains('isActive: true'));
    for (final section in ['## Core Concept', '## Mnemonics', '## Examples']) {
      expect(text, contains(section));
    }
  });

  test('each question exists, is approved and is tagged for every run exam',
      () {
    final root = loadYaml(File(questions).readAsStringSync()) as YamlMap;
    final exams = ((root['meta'] as YamlMap)['exams'] as YamlList)
        .map((e) => 'exam_${(e as String).replaceAll('-', '_')}')
        .toSet();
    expect(exams, containsAll(firstRunExamIds));
    final byId = {
      for (final q in root['questions'] as YamlList)
        (q as YamlMap)['id'] as String: q,
    };
    for (final id in firstRunContentFor('exam_upcat')!.questionIds) {
      final q = byId[id];
      expect(q, isNotNull, reason: id);
      expect(q!['approved'], isNot(false), reason: '$id is not approved');
    }
  });
}

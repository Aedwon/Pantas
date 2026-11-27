import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/walkthrough_trap_pair_check.dart';
import '../../../tool/content/lesson_checks.dart';

void main() {
  late Directory root;

  void writeLesson(
    String relativePath,
    String id,
    String body, {
    String extraFrontmatter = '',
  }) {
    File('${root.path}/lessons/$relativePath')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(
        '---\n_id: $id\npart: 1\nkeyPoints: [One]\n'
        '$extraFrontmatter---\n$body',
      );
  }

  void writeQuestions(
    String relativePath,
    String topic,
    String subtopic,
    List<Map<String, Object?>> questions,
  ) {
    final file = File('${root.path}/questions/$relativePath')
      ..parent.createSync(recursive: true);
    final buffer = StringBuffer()
      ..writeln('meta:')
      ..writeln('  subject: general')
      ..writeln('  topic: $topic')
      ..writeln('  subtopic: $subtopic')
      ..writeln('  exams: [exam-a]')
      ..writeln('questions:');
    for (final q in questions) {
      buffer.writeln('  - id: ${q['id']}');
      if (q['lesson'] != null) {
        buffer.writeln('    lesson: ${q['lesson']}');
      }
      buffer
        ..writeln('    keyPoint: 1')
        ..writeln('    stem: ${jsonEncode(q['stem'])}')
        ..writeln('    choices:');
      for (final c in q['choices']! as List<Map<String, Object?>>) {
        buffer.writeln(
          '      - text: ${jsonEncode(c['text'])}\n'
          '        correct: ${c['correct']}',
        );
      }
    }
    file.writeAsStringSync(buffer.toString());
  }

  void writeEvidence(Object lessonsMap) {
    File('${root.path}/walkthrough-trap-evidence.json').writeAsStringSync(
      jsonEncode({'lessons': lessonsMap}),
    );
  }

  setUp(() {
    root = Directory.systemTemp.createTempSync('walkthrough-pair-');
    writeLesson(
      'general/topic/part.md',
      'lesson-topic-part',
      '## Core Concept\n\n'
          ':::pair #bad-sign\n'
          'Right: \$5 - (-2) = 7\$\n'
          'Wrong: \$5 - (-2) = 3\$\n'
          'Change both signs.\n'
          ':::\n',
    );
    writeQuestions(
      'general/topic/part.yaml',
      'topic',
      'part',
      [
        {
          'id': 'q-topic-0001',
          'stem': 'Find 5 - (-2).',
          'choices': [
            {'text': '7', 'correct': true},
            {'text': '  3  ', 'correct': false},
          ],
        },
      ],
    );
    writeEvidence({
      'lesson-topic-part': {
        'bad-sign': [
          {'questionId': 'q-topic-0001', 'wrongChoice': '3'},
        ],
      },
    });
  });

  tearDown(() => root.deleteSync(recursive: true));

  test('valid citation passes (with whitespace normalization)', () {
    expect(runWalkthroughTrapPairCheck(root.path), isEmpty);
  });

  test('single object citation format also passes', () {
    writeEvidence({
      'lesson-topic-part': {
        'bad-sign': {'questionId': 'q-topic-0001', 'wrongChoice': '3'},
      },
    });
    expect(runWalkthroughTrapPairCheck(root.path), isEmpty);
  });

  test('resolves question from retired parent via replacedBy', () {
    writeLesson(
      'general/topic/original.md',
      'lesson-topic-original',
      '## Core Concept\nOld text.\n',
      extraFrontmatter: 'status: retired\nreplacedBy: [lesson-topic-part]\n',
    );
    writeQuestions(
      'general/topic/part.yaml',
      'topic',
      'original',
      [
        {
          'id': 'q-topic-0001',
          'stem': 'Find 5 - (-2).',
          'choices': [
            {'text': '7', 'correct': true},
            {'text': '3', 'correct': false},
          ],
        },
      ],
    );
    expect(runWalkthroughTrapPairCheck(root.path), isEmpty);
  });

  test('passes when no active lesson uses :::pair blocks', () {
    File('${root.path}/walkthrough-trap-evidence.json').deleteSync();
    writeLesson(
      'general/topic/part.md',
      'lesson-topic-part',
      '## Core Concept\nNo pairs here.\n',
    );
    expect(runWalkthroughTrapPairCheck(root.path), isEmpty);
  });

  test('fails when walkthrough-trap-evidence.json is missing', () {
    File('${root.path}/walkthrough-trap-evidence.json').deleteSync();
    final findings = runWalkthroughTrapPairCheck(root.path);
    expect(findings, hasLength(1));
    expect(findings.single.where, 'lesson-topic-part');
    expect(findings.single.message, contains('walkthrough-trap-evidence.json'));
  });

  test('fails when slug entry is missing', () {
    writeEvidence({'lesson-topic-part': <String, Object?>{}});
    final findings = runWalkthroughTrapPairCheck(root.path);
    expect(findings, hasLength(1));
    expect(findings.single.message, contains('bad-sign'));
  });

  test('fails when cited questionId is unknown', () {
    writeEvidence({
      'lesson-topic-part': {
        'bad-sign': [
          {'questionId': 'q-missing-9999', 'wrongChoice': '3'},
        ],
      },
    });
    final findings = runWalkthroughTrapPairCheck(root.path);
    expect(findings, hasLength(1));
    expect(findings.single.message, contains('q-missing-9999'));
  });

  test('fails when cited questionId belongs to a different lesson', () {
    writeLesson(
      'general/topic/other.md',
      'lesson-topic-other',
      '## Core Concept\nOther lesson.\n',
    );
    writeQuestions(
      'general/topic/other.yaml',
      'topic',
      'other',
      [
        {
          'id': 'q-other-0001',
          'stem': 'Other question.',
          'choices': [
            {'text': 'A', 'correct': true},
            {'text': '3', 'correct': false},
          ],
        },
      ],
    );
    writeEvidence({
      'lesson-topic-part': {
        'bad-sign': [
          {'questionId': 'q-other-0001', 'wrongChoice': '3'},
        ],
      },
    });
    final findings = runWalkthroughTrapPairCheck(root.path);
    expect(findings, hasLength(1));
    expect(findings.single.message, contains('q-other-0001'));
  });

  test('fails when citation cites the correct choice', () {
    writeEvidence({
      'lesson-topic-part': {
        'bad-sign': [
          {'questionId': 'q-topic-0001', 'wrongChoice': '7'},
        ],
      },
    });
    final findings = runWalkthroughTrapPairCheck(root.path);
    expect(findings, hasLength(1));
    expect(findings.single.message, contains('correct'));
  });

  test('fails when citation text does not match any choice', () {
    writeEvidence({
      'lesson-topic-part': {
        'bad-sign': [
          {'questionId': 'q-topic-0001', 'wrongChoice': '999'},
        ],
      },
    });
    final findings = runWalkthroughTrapPairCheck(root.path);
    expect(findings, hasLength(1));
    expect(findings.single.message, contains('999'));
  });

  test('fails on duplicate :::pair #slug in the same lesson', () {
    writeLesson(
      'general/topic/part.md',
      'lesson-topic-part',
      '## Core Concept\n\n'
          ':::pair #bad-sign\nRight: a\nWrong: b\nNote.\n:::\n\n'
          ':::pair #bad-sign\nRight: c\nWrong: d\nNote.\n:::\n',
    );
    final findings = runWalkthroughTrapPairCheck(root.path);
    expect(
      findings.map((f) => f.message),
      contains(contains('duplicate')),
    );
  });

  test('registered in run_checks.dart and lesson_checks.dart', () {
    expect(
      File('tool/checks/run_checks.dart').readAsStringSync(),
      contains('WalkthroughTrapPairCheck(),'),
    );
    File('${root.path}/walkthrough-trap-evidence.json').deleteSync();
    expect(
      runLessonChecks(root.path).map((v) => v.message),
      contains(contains('walkthrough-trap-evidence.json')),
    );
  });
}

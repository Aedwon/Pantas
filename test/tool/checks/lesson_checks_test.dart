import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../../tool/checks/lesson_pool_check.dart';
import '../../../tool/checks/lesson_size_check.dart';
import '../../../tool/checks/lesson_split_coverage_check.dart';
import '../../../tool/content/ledger.dart';
import '../../../tool/content/question_hash.dart';
import '../../../tool/content/shipping_questions.dart';

void main() {
  late Directory root;
  late File part;
  void approve() {
    writeLedger(File('${root.path}/question-ledger/approved.json'), {
      for (final q in allQuestionsForApproval(root.path))
        q.id: {'hash': questionHash(q.question, q.meta)},
    });
  }

  setUp(() {
    root = Directory.systemTemp.createTempSync('lesson-checks-');
    final source = Directory('test/tool/checks/fixtures/lesson_checks');
    for (final file in source.listSync(recursive: true).whereType<File>()) {
      final target =
          File(p.join(root.path, p.relative(file.path, from: source.path)));
      target.parent.createSync(recursive: true);
      file.copySync(target.path);
    }
    part = File('${root.path}/lessons/general/topic/part.md');
    final questions = File('${root.path}/questions/general/topic/part.yaml');
    questions.parent.createSync(recursive: true);
    questions.writeAsStringSync('''
meta:
  subject: general
  topic: topic
  subtopic: part
  exams: [exam-a, exam-b]
questions:
  - id: q-one
    keyPoint: 1
    stem: One
  - id: q-two
    keyPoint: 1
    stem: Two
''');
    approve();
  });
  tearDown(() => root.deleteSync(recursive: true));

  test('clean split passes all checks', () {
    expect(runLessonSizeCheck(root.path), isEmpty);
    expect(runLessonSplitCoverageCheck(root.path), isEmpty);
    expect(runLessonPoolCheck(root.path), isEmpty);
  });
  test('Bill of Rights text marked as a part fails size', () {
    final slice = File(
      '${root.path}/lessons/general/topic/oversized.txt',
    ).readAsStringSync();
    part.writeAsStringSync('${part.readAsStringSync()}\n$slice');
    expect(
      runLessonSizeCheck(root.path).map((v) => v.message),
      contains(contains('words')),
    );
  });
  test('missing example fails with retired id and excerpt', () {
    part.writeAsStringSync(
      part
          .readAsStringSync()
          .replaceFirst('### Search\nA warrant names a place.', ''),
    );
    final finding = runLessonSplitCoverageCheck(root.path).single;
    expect(finding.where, 'lesson-topic-original');
    expect(finding.message, contains('Search'));
  });
  for (final changedBody in [false, true]) {
    test(
        'renumbered example '
        '${changedBody ? "with changed body fails" : "passes"}', () {
      final original = File('${root.path}/lessons/general/topic/original.md');
      original.writeAsStringSync(
        original
            .readAsStringSync()
            .replaceFirst('### Search', '### #3: Search'),
      );
      part.writeAsStringSync(
        part
            .readAsStringSync()
            .replaceFirst('### Search', '### #1: Search')
            .replaceFirst(
              'A warrant names a place.',
              changedBody ? 'A changed example.' : 'A warrant names a place.',
            ),
      );
      expect(
        runLessonSplitCoverageCheck(root.path),
        changedBody ? isNotEmpty : isEmpty,
      );
    });
  }
  test('renumbered example with appended body fails', () {
    final original = File('${root.path}/lessons/general/topic/original.md');
    original.writeAsStringSync(
      original.readAsStringSync().replaceFirst('### Search', '### #3: Search'),
    );
    part.writeAsStringSync(
      part
          .readAsStringSync()
          .replaceFirst('### Search', '### #1: Search')
          .replaceFirst(
            'A warrant names a place.',
            'A warrant names a place. Changed.',
          ),
    );
    expect(runLessonSplitCoverageCheck(root.path), isNotEmpty);
  });
  test('duplicated trap fails', () {
    part.writeAsStringSync(
      '${part.readAsStringSync()}\n## Traps to Watch For\n'
      '### Guessing\nRead the rule.\n**A rule**\n'
      r'$$x = 2$$'
      '\n<!-- FIGURE rights -->\n',
    );
    expect(
      runLessonSplitCoverageCheck(root.path).map((v) => v.message),
      contains(contains('duplicated')),
    );
  });
  for (final item in [
    '### Search\nA warrant names a place.',
    '### Guessing\nRead the rule.',
    '**A rule**',
    r'$$x = 2$$',
  ]) {
    test('commented preservation item fails: $item', () {
      part.writeAsStringSync(
        part.readAsStringSync().replaceFirst(item, '<!-- $item -->'),
      );
      expect(
        runLessonSplitCoverageCheck(root.path).map((v) => v.message),
        contains(contains('missing')),
      );
    });
  }
  test('comments in the original are not teaching content', () {
    final original = File('${root.path}/lessons/general/topic/original.md');
    original.writeAsStringSync('${original.readAsStringSync()}\n'
        '<!--\n## Examples\n### Hidden\n**Hidden rule** '
        r'$$hidden$$'
        '\n-->');
    expect(runLessonSplitCoverageCheck(root.path), isEmpty);
  });
  test('figure comments remain required separately from visible traps', () {
    part.writeAsStringSync(
      part.readAsStringSync().replaceFirst('<!-- FIGURE rights -->', ''),
    );
    final findings = runLessonSplitCoverageCheck(root.path);
    expect(findings, hasLength(1));
    expect(findings.single.message, contains('FIGURE rights'));
  });
  for (final check in ['size', 'coverage', 'pool']) {
    for (final target in ['export', 'upload']) {
      test('$target blocks $check findings before writing', () async {
        for (final file in Directory('${root.path}/lessons')
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.md'))) {
          file.writeAsStringSync(
            file
                .readAsStringSync()
                .replaceFirst(
                    '\n_id:',
                    '\ntopic: topic-topic\ntitle: Test\n'
                        'summary: Test\nestimatedMinutes: 1\n_id:')
                .replaceAll('<!-- FIGURE rights -->', ''),
          );
        }
        final source = File('${root.path}/questions/general/topic/part.yaml');
        source.writeAsStringSync(
          source.readAsStringSync().replaceAll(
              '    stem:',
              '    explanation: Test\n'
                  '    choices: [{text: Yes, correct: true}, '
                  '{text: No, correct: false}]\n    stem:'),
        );
        approve();
        if (check == 'size') {
          part.writeAsStringSync('${part.readAsStringSync()}\n'
              '${List.filled(500, 'word').join(' ')}');
        } else if (check == 'coverage') {
          part.writeAsStringSync(
            part.readAsStringSync().replaceFirst(
                  '### Search\nA warrant names a place.',
                  '',
                ),
          );
        } else {
          final questions =
              File('${root.path}/questions/general/topic/part.yaml');
          // keyPoint is excluded from the approval hash.
          questions.writeAsStringSync(
            questions.readAsStringSync().replaceAll('    keyPoint: 1', ''),
          );
        }
        final exportRoot = Directory('${root.path}/export-root')..createSync();
        final files = root.listSync(recursive: true).whereType<File>().toList();
        for (final file in files) {
          final target = File(
            p.join(
              exportRoot.path,
              'content',
              p.relative(file.path, from: root.path),
            ),
          );
          target.parent.createSync(recursive: true);
          file.copySync(target.path);
        }
        final history = File(
          '${exportRoot.path}/tools/build_content_export/historical_v1.json',
        );
        history.parent.createSync(recursive: true);
        history.writeAsStringSync(
          jsonEncode({
            'exams': <Object?>[],
            'topics': <Object?>[],
            'lessons': <Object?>[],
            'questions': <Object?>[],
          }),
        );
        final outline =
            File('${exportRoot.path}/tools/lesson_author/outline.json');
        outline.parent.createSync(recursive: true);
        outline.writeAsStringSync(
          jsonEncode({
            'subjects': [
              {
                'slug': 'general',
                'name': 'General',
                'topics': [
                  {'slug': 'topic', 'name': 'Topic'},
                ],
              },
            ],
          }),
        );
        final output = '${root.path}/blocked.json';
        if (target == 'export') {
          final result = await Process.run('dart', [
            'run',
            'tools/build_content_export/build_content_export.dart',
            output,
            exportRoot.path,
          ]);
          expect(result.exitCode, 1, reason: '${result.stderr}');
          expect(result.stderr, contains('lesson-topic-'));
          expect(File(output).existsSync(), isFalse);
        } else {
          File(output).writeAsStringSync(
            jsonEncode({
              'exam': <Object?>[],
              'subject': <Object?>[],
              'topic': <Object?>[],
              'mockBlueprint': <Object?>[],
              'diagnosticSet': <Object?>[],
            }),
          );
          final upload = await Process.run('node', [
            'tools/upload_content/upload_content.mjs',
            '--root',
            root.path,
            '--export',
            output,
            '--out-dir',
            '${root.path}/uploaded',
          ]);
          expect(upload.exitCode, 1, reason: '${upload.stderr}');
          expect(upload.stderr, contains('lesson-topic-'));
          expect(
            upload.stderr,
            contains('Nothing written: the lesson checks failed.'),
          );
          expect(Directory('${root.path}/uploaded').existsSync(), isFalse);
        }
      });
    }
  }
  test('key point missing for one exam fails pool', () {
    final questions = File('${root.path}/questions/general/topic/part.yaml');
    questions.writeAsStringSync(
      questions.readAsStringSync().replaceFirst('keyPoint: 1', 'keyPoint: 2'),
    );
    part.writeAsStringSync(
      part
          .readAsStringSync()
          .replaceFirst('[Know rights]', '[Know rights, Apply rights]'),
    );
    // Exam b gets only key point 1 from a separate file.
    questions.writeAsStringSync(
      questions.readAsStringSync().replaceFirst('[exam-a, exam-b]', '[exam-a]'),
    );
    File('${root.path}/questions/general/topic/other.yaml')
        .writeAsStringSync('''
meta:
  topic: topic
  subtopic: part
  exams: [exam-b]
questions:
  - id: q-three
    keyPoint: 1
  - id: q-four
    keyPoint: 1
''');
    approve();
    expect(
      runLessonPoolCheck(root.path).map((v) => v.message),
      ['exam-b: key point 2 has no shipping, gate-passing question'],
    );
  });
  test('retired prerequisite links fail size check', () {
    File('${root.path}/lesson-prerequisites.json').writeAsStringSync(
      jsonEncode({
        'version': 1,
        'lessons': {
          'lesson-topic-part': [
            {'lesson': 'lesson-topic-original', 'strength': 'required'},
          ],
        },
      }),
    );
    expect(
      runLessonSizeCheck(root.path).map((v) => v.message),
      contains(contains('retired prerequisite')),
    );
  });
  for (final field in ['isActive: false', 'figure: pending']) {
    test('pool excludes approved $field question', () {
      final file = File('${root.path}/questions/general/topic/part.yaml');
      file.writeAsStringSync(
        file
            .readAsStringSync()
            .replaceFirst('    stem: One', '    $field\n    stem: One'),
      );
      approve();
      expect(
        runLessonPoolCheck(root.path).map((v) => v.message),
        everyElement(contains('pool 1 is below quizSize 2')),
      );
      expect(runLessonPoolCheck(root.path), hasLength(2));
    });
  }
  test('split topic names active unsplit lesson', () {
    File('${root.path}/lessons/general/topic/unsplit.md')
        .writeAsStringSync('---\n_id: unsplit\n---\nText');
    expect(runLessonSizeCheck(root.path).single.where, 'unsplit');
  });
  test('split topic leaves neighboring lessons unsplit', () {
    final lesson = File('${root.path}/lessons/general/other/unsplit.md');
    lesson.parent.createSync(recursive: true);
    lesson.writeAsStringSync('---\n_id: unsplit\n---\nText');
    expect(runLessonSizeCheck(root.path), isEmpty);
  });
  test('comments do not count as teaching words', () {
    part.writeAsStringSync('---\n_id: part\npart: 1\nkeyPoints: [One]\n---\n'
        '<!-- ${List.filled(200, 'word').join(' ')} -->\nShort');
    expect(
      runLessonSizeCheck(root.path).map((v) => v.message),
      contains(contains('teaching words 1')),
    );
  });
  test('mathematics permits 550 words with at most two examples', () {
    part.writeAsStringSync('---\n_id: lesson-topic-part\npart: 1\n'
        'subject: subject-mathematics\nkeyPoints: [One]\n---\n'
        '${List.filled(490, 'word').join(' ')}\n## Examples\n### One\nWork');
    expect(runLessonSizeCheck(root.path), isEmpty);
    part.writeAsStringSync(
      '${part.readAsStringSync()}\n### Two\nWork\n### Three\nWork',
    );
    expect(
      runLessonSizeCheck(root.path).single.message,
      contains('2 worked examples'),
    );
  });
  test('formulas and bold rules may repeat', () {
    part.writeAsStringSync('${part.readAsStringSync()}\n## More\n'
        r'**A rule** $$x = 2$$');
    expect(runLessonSplitCoverageCheck(root.path), isEmpty);
  });
  test('combined CLI fails findings and accepts clean root', () async {
    Future<ProcessResult> run() => Process.run('dart', [
          'run',
          'tool/content/lesson_checks.dart',
          '--root',
          root.path,
        ]);
    expect((await run()).exitCode, 0);
    part.writeAsStringSync(
      part.readAsStringSync().replaceFirst('A warrant names a place.', ''),
    );
    final result = await run();
    expect(result.exitCode, 1);
    expect(result.stderr, contains('lesson-topic-original'));
  });
  test('current unsplit content passes all checks', () {
    expect(runLessonSizeCheck('content'), isEmpty);
    expect(runLessonSplitCoverageCheck('content'), isEmpty);
    expect(runLessonPoolCheck('content'), isEmpty);
  });
}

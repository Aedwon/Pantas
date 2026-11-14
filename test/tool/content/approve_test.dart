import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/content/ledger.dart';
import '../../../tool/content/question_hash.dart';
import '../../../tool/content/shipping_questions.dart';
import 'fixtures/fixture.dart';

void main() {
  late Directory root;
  late File yaml;
  late File ids;
  late File evidence;
  setUp(() {
    root = createContentFixture();
    Directory('${root.path}/.git').createSync();
    yaml = File('${root.path}/questions/math/numbers/addition.yaml');
    ids = File('${root.path}/ids.txt')..writeAsStringSync('q-one\n');
    evidence = File('${root.path}/solve.md')
      ..writeAsStringSync('Verified solve.');
  });
  tearDown(() => root.deleteSync(recursive: true));
  Future<ProcessResult> approve({bool moved = false}) => Process.run('dart', [
        'run',
        'tool/content/approve.dart',
        '--root',
        root.path,
        '--ids',
        ids.path,
        '--evidence',
        evidence.path,
        if (moved) '--moved',
      ]);
  for (final suffix in ['', ',', ',  # trailing comma\n    ']) {
    test('approves a flow mapping with suffix "$suffix"', () async {
      final before =
          'meta: {topic: numbers, subtopic: addition, exams: [cse-pro]}\n'
          'questions:\n'
          '  - {id: q-one, stem: One?, choices: [{text: Two, correct: true}]'
          '$suffix}\n';
      yaml.writeAsStringSync(before);
      final result = await approve();
      expect(result.exitCode, 0, reason: '${result.stderr}');
      final q = shippingQuestions(root.path).single;
      expect(q.question['approved'], true);
      expect(
        yaml.readAsStringSync().replaceFirst(
              ', approved: true',
              '',
            ),
        before,
      );
      expect(
        readLedger(File('${root.path}/question-ledger/approved.json'))
            .containsKey('q-one'),
        true,
      );
    });
  }
  test('approval changes only its value and records evidence and UTC date',
      () async {
    final before = yaml.readAsStringSync();
    final result = await approve();
    expect(result.exitCode, 0, reason: '${result.stderr}');
    expect(
      yaml.readAsStringSync(),
      before.replaceFirst('approved: false', 'approved: true'),
    );
    final q = shippingQuestions(root.path).first;
    final record = readLedger(
      File('${root.path}/question-ledger/approved.json'),
    )['q-one']!;
    expect(record['hash'], questionHash(q.question, q.meta));
    expect(record['lesson'], 'lesson-numbers-addition');
    expect(record['evidence'], 'solve.md');
    expect(
      record['approvedAt'],
      DateTime.now().toUtc().toIso8601String().substring(0, 10),
    );
  });
  test('adds absent approved at the question indentation preserving CRLF',
      () async {
    final before = yaml
        .readAsStringSync()
        .replaceFirst('    approved: false # display\n', '')
        .replaceAll('\n', '\r\n');
    yaml.writeAsStringSync(before);
    expect((await approve()).exitCode, 0);
    expect(
      yaml.readAsStringSync().replaceFirst('    approved: true\r\n', ''),
      before,
    );
  });
  test('inserts beside id when the first field is a block scalar', () async {
    final before = yaml
        .readAsStringSync()
        .replaceFirst(
          '  - id: q-one\n    stem: What is one plus one?',
          '  - stem: |\n      What is one plus one?\n    id: q-one',
        )
        .replaceFirst('    approved: false # display\n', '');
    yaml.writeAsStringSync(before);
    final result = await approve();
    expect(result.exitCode, 0, reason: '${result.stderr}');
    final q = shippingQuestions(root.path).first;
    expect(q.question['stem'], 'What is one plus one?\n');
    expect(q.question['approved'], true);
    expect(
      yaml.readAsStringSync().replaceFirst('    approved: true\n', ''),
      before,
    );
  });
  for (final ledgerName in ['legacy', 'approved']) {
    test('--moved accepts only a lesson change from $ledgerName', () async {
      final q = shippingQuestions(root.path).first;
      writeLedger(File('${root.path}/question-ledger/$ledgerName.json'), {
        q.id: {
          'hash': questionHash(q.question, q.meta),
          'lesson': questionLesson(q.question, q.meta),
        },
      });
      yaml.writeAsStringSync(
        yaml
            .readAsStringSync()
            .replaceFirst('    stem:', '    lesson: lesson-new\n    stem:'),
      );
      expect((await approve(moved: true)).exitCode, 0);
      yaml.writeAsStringSync(
        yaml.readAsStringSync().replaceFirst('What is', 'What was'),
      );
      final before = yaml.readAsStringSync();
      expect((await approve(moved: true)).exitCode, isNot(0));
      expect(yaml.readAsStringSync(), before);
    });
  }
  test('refuses unknown ids and missing evidence without writes', () async {
    ids.writeAsStringSync('unknown\n');
    expect((await approve()).exitCode, isNot(0));
    ids.writeAsStringSync('q-one\n');
    evidence.deleteSync();
    expect((await approve()).exitCode, isNot(0));
    expect(
      File('${root.path}/question-ledger/approved.json').existsSync(),
      false,
    );
  });
}

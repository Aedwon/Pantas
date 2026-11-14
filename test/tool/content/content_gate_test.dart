import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tool/content/content_gate.dart';
import '../../../tool/content/ledger.dart';
import '../../../tool/content/question_hash.dart';
import '../../../tool/content/shipping_questions.dart';
import 'fixtures/fixture.dart';

void main() {
  late Directory root;
  late File legacy;
  late Set<String> pins;
  setUp(() {
    root = createContentFixture();
    legacy = File('${root.path}/question-ledger/legacy.json');
    writeLedger(legacy, {
      for (final q in allQuestionsForApproval(root.path))
        q.id: {
          'hash': questionHash(q.question, q.meta),
          'lesson': questionLesson(q.question, q.meta),
        },
    });
    pins = {sha256.convert(legacy.readAsBytesSync()).toString()};
  });
  tearDown(() => root.deleteSync(recursive: true));
  List<GateFinding> gate() => runContentGate(root.path, legacyPins: pins);
  void edit(String from, String to) {
    final file = File('${root.path}/questions/math/numbers/addition.yaml');
    file.writeAsStringSync(file.readAsStringSync().replaceFirst(from, to));
  }

  test('shipping matches pending figure and inactive exclusions', () {
    expect(shippingQuestions(root.path).map((q) => q.id), ['q-one', 'q-two']);
    expect(gate(), isEmpty);
  });
  for (final field in ['isActive: false', 'figure: pending']) {
    test('gate checks unapproved $field questions', () {
      legacy.deleteSync();
      edit('    stem: What', '    $field\n    stem: What');
      expect(gate().map((f) => f.id), contains('q-one'));
    });
  }
  test('new question is not approved even when YAML approved', () {
    legacy.deleteSync();
    expect(gate().map((f) => f.reason), everyElement('not approved'));
  });
  test('edited legacy question fails', () {
    edit('What is one', 'What was one');
    expect(gate().single.reason, 'changed since frozen');
  });
  test('moved legacy question fails', () {
    edit('    stem: What', '    lesson: lesson-moved\n    stem: What');
    expect(gate().single.reason, 'changed since frozen');
  });
  test('edited approved question fails', () {
    File('${root.path}/question-ledger/approved.json')
        .writeAsStringSync(legacy.readAsStringSync());
    legacy.deleteSync();
    edit('What is one', 'What was one');
    expect(gate().single.reason, 'edited after approval');
  });
  test('unrecognized legacy bytes fail even if entries still match', () {
    legacy.writeAsStringSync('${legacy.readAsStringSync()}\n');
    expect(gate().map((f) => f.reason), contains('legacy list changed'));
  });
  test('split subject cannot ship by legacy; approved entry can', () {
    final lesson = File('${root.path}/lessons/math/numbers/part.md');
    lesson.parent.createSync(recursive: true);
    lesson.writeAsStringSync('---\ntitle: Part\npart: 1\n---\nText');
    expect(gate(), isNotEmpty);
    expect(
      gate().map((f) => f.reason),
      everyElement('split subject on legacy status'),
    );
    writeLedger(
      File('${root.path}/question-ledger/approved.json'),
      readLedger(legacy),
    );
    expect(gate(), isEmpty);
  });
  test('CLI distinguishes usage errors and findings', () async {
    final usage =
        await Process.run('dart', ['run', 'tool/content/content_gate.dart']);
    expect(usage.exitCode, 2);
    legacy.deleteSync();
    final result = await Process.run(
      'dart',
      ['run', 'tool/content/content_gate.dart', '--root', root.path],
    );
    expect(result.exitCode, 1);
    expect(result.stderr, contains('q-one: not approved'));
  });
}

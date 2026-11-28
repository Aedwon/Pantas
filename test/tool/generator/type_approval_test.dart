import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/content/content_gate.dart';
import '../../../tool/content/ledger.dart';

void main() {
  late Directory root;
  late File type;
  late File variants;
  late File evidence;
  setUp(() {
    root = Directory.systemTemp.createTempSync('type-approval-');
    Directory('${root.path}/.git').createSync();
    Directory('${root.path}/content/questions').createSync(recursive: true);
    type = File('${root.path}/content/types/math/lesson/qt-test.yaml');
    type.parent.createSync(recursive: true);
    type.writeAsStringSync('''
id: qt-test
lesson: lesson-test
rule: testRule
ruleVersion: 1
enabled: true
stem: Test?
''');
    variants = File(type.path.replaceFirst('.yaml', '.variants.yaml'))
      ..writeAsStringSync('''
problemType: qt-test
variants:
  - {index: 0, slots: {number: 1}}
  - {index: 1, slots: {number: 2}}
''');
    evidence = File('${root.path}/review.md')..writeAsStringSync('Review.');
  });
  tearDown(() => root.deleteSync(recursive: true));
  Future<ProcessResult> approve({String ids = 'qt-test'}) => Process.run(
        'dart',
        [
          'run',
          'tool/content/approve.dart',
          '--root',
          root.path,
          '--types',
          ids,
          '--evidence',
          evidence.path,
        ],
      );
  List<GateFinding> gate() => runContentGate('${root.path}/content');

  test('unapproved active type fails the content gate', () {
    expect(gate().map((f) => '$f'), ['qt-test: not approved']);
  });
  test('lead approval preserves source bytes and question ledger entries',
      () async {
    final ledger = File('${root.path}/content/question-ledger/approved.json');
    writeLedger(ledger, {
      'q-old': {'hash': 'preserve'},
    });
    final before = type.readAsBytesSync();
    final listBefore = variants.readAsBytesSync();
    final result = await approve();
    expect(result.exitCode, 0, reason: '${result.stderr}');
    expect(gate(), isEmpty);
    expect(type.readAsBytesSync(), before);
    expect(variants.readAsBytesSync(), listBefore);
    final entries = readLedger(ledger);
    expect(entries['q-old'], {'hash': 'preserve'});
    expect(entries['qt-test']!['evidence'], 'review.md');
    expect(entries['qt-test']!['hash'], matches(r'^[0-9a-f]{64}$'));
  });
  for (final change in ['variant', 'type bytes', 'rule', 'ruleVersion']) {
    test('$change edit cancels approval', () async {
      expect((await approve()).exitCode, 0);
      if (change == 'variant') {
        variants.writeAsStringSync(
          variants.readAsStringSync().replaceFirst('number: 2', 'number: 3'),
        );
      } else {
        final source = type.readAsStringSync();
        type.writeAsStringSync(
          switch (change) {
            'rule' => source.replaceFirst('testRule', 'otherRule'),
            'ruleVersion' =>
              source.replaceFirst('ruleVersion: 1', 'ruleVersion: 2'),
            _ => '$source# byte change\n',
          },
        );
      }
      expect(gate().map((f) => '$f'), ['qt-test: edited after approval']);
    });
  }
  test('held type without approval passes', () {
    final held = type.path.replaceFirst('/types/', '/types-held/');
    File(held).parent.createSync(recursive: true);
    type.renameSync(held);
    variants.renameSync(held.replaceFirst('.yaml', '.variants.yaml'));
    expect(gate(), isEmpty);
  });
  test('disabled type and type without list are not active', () {
    type.writeAsStringSync(
      type.readAsStringSync().replaceFirst('enabled: true', 'enabled: false'),
    );
    expect(gate(), isEmpty);
    type.writeAsStringSync(
      type.readAsStringSync().replaceFirst('enabled: false', 'enabled: true'),
    );
    variants.deleteSync();
    expect(gate(), isEmpty);
  });
  test('unknown type and missing evidence cannot create approval', () async {
    expect((await approve(ids: 'qt-missing')).exitCode, isNot(0));
    evidence.deleteSync();
    expect((await approve()).exitCode, isNot(0));
    expect(
      File('${root.path}/content/question-ledger/approved.json').existsSync(),
      false,
    );
  });
  test('comma-separated type IDs approve together', () async {
    final second = File('${type.parent.path}/qt-second.yaml')
      ..writeAsStringSync(
        type.readAsStringSync().replaceFirst('qt-test', 'qt-second'),
      );
    File(second.path.replaceFirst('.yaml', '.variants.yaml')).writeAsStringSync(
      variants.readAsStringSync().replaceFirst('qt-test', 'qt-second'),
    );
    final result = await approve(ids: 'qt-test,qt-second');
    expect(result.exitCode, 0, reason: '${result.stderr}');
    expect(gate(), isEmpty);
  });
}

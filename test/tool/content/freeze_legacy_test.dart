import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tool/content/ledger.dart';
import 'fixtures/fixture.dart';

void main() {
  test('freeze includes every shipping question and refuses to overwrite',
      () async {
    final root = createContentFixture();
    addTearDown(() => root.deleteSync(recursive: true));
    final args = [
      'run',
      'tool/content/freeze_legacy.dart',
      '--root',
      root.path,
    ];
    final result = await Process.run('dart', args);
    expect(result.exitCode, 0, reason: '${result.stderr}');
    final file = File('${root.path}/question-ledger/legacy.json');
    final entries = readLedger(file);
    expect(entries.keys, ['q-one', 'q-two']);
    expect(entries['q-one']!['yamlApproved'], false);
    expect(entries['q-two']!['yamlApproved'], true);
    expect(result.stdout, contains('total: 2, yamlApproved true: 1, false: 1'));
    expect(
      (result.stdout as String).trim().split('\n').last,
      sha256.convert(file.readAsBytesSync()).toString(),
    );
    final bytes = file.readAsBytesSync();
    expect((await Process.run('dart', args)).exitCode, isNot(0));
    expect(file.readAsBytesSync(), bytes);
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/content/ledger.dart';

void main() {
  test('missing ledger is empty; writes sorted keys and preserves entry data',
      () {
    final root = Directory.systemTemp.createTempSync('ledger-test-');
    addTearDown(() => root.deleteSync(recursive: true));
    final file = File('${root.path}/question-ledger/approved.json');
    expect(readLedger(file), isEmpty);
    final entries = <String, Map<String, Object?>>{
      'z': {'lesson': 'l', 'hash': 'h', 'evidence': 'solve.md'},
      'a': {'hash': 'a', 'yamlApproved': false},
    };
    writeLedger(file, entries);
    expect(readLedger(file), entries);
    expect(file.readAsStringSync(), startsWith('{\n  "a": {\n'));
    expect(file.readAsStringSync(), endsWith('\n'));
  });
}

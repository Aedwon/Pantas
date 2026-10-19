import 'dart:js_interop';

import 'package:pantas/core/storage/data/database_opener_web.dart';

@JS('pantasVerifyAtRest')
external JSPromise<JSAny?> _verifyAtRest();
@JS('pantasTamperData')
external JSPromise<JSAny?> _tamperData(JSBoolean restore);
@JS('pantasTamperKey')
external JSPromise<JSAny?> _tamperKey(JSBoolean restore);

@JS('pantasProbeFinished')
external void _finished();

Future<void> main() async {
  final first = await openEncryptedDatabase();
  await first.customStatement('CREATE TABLE web_probe (value TEXT)');
  await first
      .customStatement("INSERT INTO web_probe VALUES ('synthetic-study-data')");
  var refused = false;
  try {
    await openEncryptedDatabase();
  } on Exception {
    refused = true;
  }
  if (!refused) throw StateError('concurrent owner was accepted');
  await first.close();
  final second = await openEncryptedDatabase();
  final rows = await second.customSelect('SELECT value FROM web_probe').get();
  if (rows.single.read<String>('value') != 'synthetic-study-data') {
    throw StateError('encrypted reopen lost data');
  }
  await second.close();
  await _verifyAtRest().toDart;
  await _tamperKey(false.toJS).toDart;
  var tamperedRefused = false;
  try {
    await openEncryptedDatabase();
  } on Object {
    tamperedRefused = true;
  }
  if (!tamperedRefused) throw StateError('tampered key accepted');
  await _tamperKey(true.toJS).toDart;
  final restored = await openEncryptedDatabase();
  await restored.customSelect('SELECT value FROM web_probe').get();
  await restored.close();
  await _tamperData(false.toJS).toDart;
  var corruptedRefused = false;
  try {
    await openEncryptedDatabase();
  } on Object {
    corruptedRefused = true;
  }
  if (!corruptedRefused) throw StateError('corrupt database accepted');
  await _tamperData(true.toJS).toDart;
  final recovered = await openEncryptedDatabase();
  await recovered.customSelect('SELECT value FROM web_probe').get();
  await recovered.close();
  // ignore: avoid_print
  print(
    'PASS: ciphertext at rest, non-extractable wrapping key, '
    'key and database tamper refusal, recovery;',
  );
  // ignore: avoid_print
  print('PASS: schema, write, owner exclusion, close, encrypted reopen');
  _finished();
}

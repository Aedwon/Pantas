// coverage:ignore-file
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// The database key lives in flutter_secure_storage, which is on 10.x
// deliberately. **Version 11 removes the old Android ciphers and makes
// anything written by 9.x unreadable**, and its own changelog says to go
// through 10 first so the data migrates. Jumping to 11 would hand the app a
// fresh key, and a fresh key cannot open the database that already exists.
// Move to 11 only after a build on 10 has run once on every device that
// matters.
//
// Renamed from cse_cet_reviewer.db on 11 August 2026, with the key below.
// Safe only because the emulator was the only install: a rename abandons the
// old file rather than migrating it, so doing this after a beta would have
// silently reset every tester's progress.
const _dbFileName = 'pantas.db';
const _keyStorageKey = 'pantas_db_key';

Future<AppDatabase> openEncryptedDatabase({
  FlutterSecureStorage storage = const FlutterSecureStorage(),
}) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, _dbFileName));
  final key = await _readOrCreateKey(storage);

  return AppDatabase(
    NativeDatabase.createInBackground(
      file,
      setup: (db) {
        // The first two are what let SQLite3MultipleCiphers read a database
        // SQLCipher wrote, and they have to run before the key. There is one
        // such database: the test device's, with a day of real use in it.
        db
          ..execute("PRAGMA cipher = 'sqlcipher';")
          ..execute('PRAGMA legacy = 4;')
          ..execute("PRAGMA key = \"x'${_toHex(key)}'\";");
      },
    ),
  );
}

Future<Uint8List> _readOrCreateKey(FlutterSecureStorage storage) async {
  final existing = await storage.read(key: _keyStorageKey);
  if (existing != null) {
    return Uint8List.fromList(_fromHex(existing));
  }
  final rng = Random.secure();
  final bytes = Uint8List(32);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] = rng.nextInt(256);
  }
  await storage.write(key: _keyStorageKey, value: _toHex(bytes));
  return bytes;
}

String _toHex(Uint8List bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

List<int> _fromHex(String hex) => [
      for (var i = 0; i < hex.length; i += 2)
        int.parse(hex.substring(i, i + 2), radix: 16),
    ];

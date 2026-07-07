// coverage:ignore-file
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

const _dbFileName = 'cse_cet_reviewer.db';
const _keyStorageKey = 'cse_cet_db_key';

Future<AppDatabase> openEncryptedDatabase({
  FlutterSecureStorage storage = const FlutterSecureStorage(),
}) async {
  await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();

  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, _dbFileName));
  final key = await _readOrCreateKey(storage);

  return AppDatabase(
    NativeDatabase.createInBackground(
      file,
      // The database opens in a background isolate; the SQLCipher loader
      // override is per-isolate, so it must be applied there.
      isolateSetup: () {
        open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
      },
      setup: (db) {
        db.execute("PRAGMA key = \"x'${_toHex(key)}'\";");
        final cipherVersion = db.select('PRAGMA cipher_version;');
        if (cipherVersion.isEmpty) {
          throw StateError(
            'SQLCipher not loaded: cipher_version returned no rows.',
          );
        }
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

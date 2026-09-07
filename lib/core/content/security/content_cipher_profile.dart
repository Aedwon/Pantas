import 'dart:io';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

/// Centralized sqlite3mc profile for protected content databases.
///
/// Content encryption deliberately has its own format and key boundary. It
/// does not inherit the user database's legacy compatibility setting.
abstract final class ContentCipherProfile {
  static const id = 'pantas-sqlite3mc-content-v1';

  static Database open(File file, Uint8List key) {
    _requireKey(key);
    final db = sqlite3.open(file.path);
    try {
      db
        ..execute("PRAGMA cipher = 'sqlcipher';")
        ..execute('PRAGMA hmac_use = 1;')
        ..execute('PRAGMA hmac_check = 1;')
        ..execute('PRAGMA mc_legacy_wal = 0;')
        ..execute("PRAGMA key = \"x'${_toHex(key)}'\";")
        ..execute('PRAGMA journal_mode = DELETE;')
        ..execute('PRAGMA temp_store = MEMORY;');
      // Force sqlite3mc to authenticate/read the database before returning a
      // handle. Wrong or absent keys must fail here, not on a later feature
      // query.
      db.select('SELECT count(*) FROM sqlite_schema;');
      return db;
    } catch (_) {
      db.dispose();
      rethrow;
    }
  }

  /// Rekeys an existing plaintext SQLite file in place.
  ///
  /// The caller supplies a build-time temporary plaintext database. This
  /// operation never creates a plaintext secondary database.
  static void protectPlaintextFile(File file, Uint8List key) {
    _requireKey(key);
    final db = sqlite3.open(file.path);
    try {
      db
        ..execute('PRAGMA journal_mode = DELETE;')
        ..execute('PRAGMA temp_store = MEMORY;')
        ..execute("PRAGMA cipher = 'sqlcipher';")
        ..execute('PRAGMA hmac_use = 1;')
        ..execute('PRAGMA hmac_check = 1;')
        ..execute('PRAGMA mc_legacy_wal = 0;')
        ..execute("PRAGMA rekey = \"x'${_toHex(key)}'\";");
    } finally {
      db.dispose();
    }
  }

  static void rekey(Database db, Uint8List newKey) {
    _requireKey(newKey);
    db
      ..execute('PRAGMA journal_mode = DELETE;')
      ..execute('PRAGMA temp_store = MEMORY;')
      ..execute('PRAGMA hmac_use = 1;')
      ..execute('PRAGMA hmac_check = 1;')
      ..execute('PRAGMA mc_legacy_wal = 0;')
      ..execute("PRAGMA rekey = \"x'${_toHex(newKey)}'\";");
  }

  static void _requireKey(Uint8List key) {
    if (key.length != 32) {
      throw ArgumentError.value(key.length, 'key.length', 'must be 32 bytes');
    }
  }

  static String _toHex(Uint8List bytes) =>
      bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

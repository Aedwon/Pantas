// Runs in a headless browser:
//   flutter test --platform chrome test/core/storage/data/database_opener_web_test.dart
// test/web_assets links to the sqlite3.wasm and drift_worker.js in web/, which
// the test server then serves from its root.
@TestOn('browser')
library;

import 'dart:typed_data';

import 'package:drift/drift.dart' show Variable, driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/database_opener_web.dart';
import 'package:sqlite3/wasm.dart';

final _wasm = Uri.base.resolve('/web_assets/sqlite3.wasm');
final _worker = Uri.base.resolve('/web_assets/drift_worker.js');

Future<AppDatabase> _open(String name) => openEncryptedDatabase(
      databaseName: name,
      sqlite3Uri: _wasm,
      driftWorkerUri: _worker,
    );

Future<void> _put(AppDatabase db, String key, String value) =>
    db.customStatement('INSERT OR REPLACE INTO device_prefs VALUES (?, ?)', [
      key,
      value,
    ]);

Future<String?> _get(AppDatabase db, String key) async {
  final rows = await db.customSelect(
    'SELECT value FROM device_prefs WHERE key = ?',
    variables: [Variable<String>(key)],
  ).get();
  return rows.isEmpty ? null : rows.single.read<String>('value');
}

/// Writes bytes that are not a database into the browser file a study database
/// uses, the way a damaged or foreign file would look.
Future<void> _plantGarbage(String name) async {
  final fs = await IndexedDbFileSystem.open(dbName: name);
  final (:file, outFlags: _) = fs.xOpen(
    Sqlite3Filename('/database'),
    SqlFlag.SQLITE_OPEN_CREATE | SqlFlag.SQLITE_OPEN_READWRITE,
  );
  file
    ..xWrite(Uint8List.fromList(List<int>.filled(8192, 7)), 0)
    ..xClose();
  await fs.flush();
  await fs.close();
}

Future<Uint8List> _readFile(String name) async {
  final fs = await IndexedDbFileSystem.open(dbName: name);
  final (:file, outFlags: _) = fs.xOpen(
    Sqlite3Filename('/database'),
    SqlFlag.SQLITE_OPEN_READONLY,
  );
  final bytes = Uint8List(file.xFileSize());
  file
    ..xRead(bytes, 0)
    ..xClose();
  await fs.close();
  return bytes;
}

void main() {
  // Two connections in one page stand in for two tabs; drift warns about that.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final stamp = DateTime.now().microsecondsSinceEpoch;

  test('data written before close is present after reopen', () async {
    final name = 'pantas-test-reopen-$stamp';
    final first = await _open(name);
    await _put(first, 'k', 'written');
    await first.close();

    // The stored file is a plain SQLite database, not ciphertext.
    final stored = await _readFile(name);
    expect(String.fromCharCodes(stored.take(15)), 'SQLite format 3');

    final second = await _open(name);
    expect(await _get(second, 'k'), 'written');
    await second.close();
  });

  test('a second tab opens the same database and sees its data', () async {
    // Two connections to one name are what two tabs of one origin do: both
    // reach the same shared worker, or the second is refused by the guard.
    final name = 'pantas-test-tabs-$stamp';
    final tabA = await _open(name);
    await _put(tabA, 'k', 'from-a');
    final tabB = await _open(name);
    expect(await _get(tabB, 'k'), 'from-a');
    await _put(tabB, 'k2', 'from-b');
    expect(await _get(tabA, 'k2'), 'from-b');
    await tabA.close();
    await tabB.close();

    final again = await _open(name);
    expect(await _get(again, 'k'), 'from-a');
    expect(await _get(again, 'k2'), 'from-b');
    await again.close();
  });

  test('an unreadable database is replaced by a fresh one', () async {
    final name = 'pantas-test-damaged-$stamp';
    await _plantGarbage(name);

    final db = await _open(name);
    expect(await _get(db, 'k'), isNull);
    await _put(db, 'k', 'fresh');
    await db.close();

    final reopened = await _open(name);
    expect(await _get(reopened, 'k'), 'fresh');
    await reopened.close();
  });

  test('the shipped name never opens the earlier encrypted database', () async {
    const earlier = 'pantas-study-v1';
    await _plantGarbage(earlier);
    final before = await _readFile(earlier);

    final db = await openEncryptedDatabase(
      sqlite3Uri: _wasm,
      driftWorkerUri: _worker,
    );
    await _put(db, 'k', 'plain');
    expect(await _get(db, 'k'), 'plain');
    await db.close();

    expect(webStudyDatabaseName, isNot(earlier));
    expect(await _readFile(earlier), before);
  });

  test('only one tab at a time can claim a database that cannot be shared',
      () async {
    final name = 'pantas-test-claim-$stamp';
    final release = await claimSingleTab(name);
    await expectLater(claimSingleTab(name), throwsStateError);
    await release();
    final again = await claimSingleTab(name);
    await again();
  });
}

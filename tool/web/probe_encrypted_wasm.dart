import 'dart:js_interop';

import 'package:sqlite3/wasm.dart';

@JS('pantasWasmBytes')
external JSUint8Array get _wasmBytes;

@JS('pantasProbeFinished')
external void _finished();

Future<void> main() async {
  for (final kind in ['memory', 'indexeddb', 'opfs']) {
    for (final afterOpen in [false, true]) {
      for (final makeDefault in [false, true]) {
        final sqlite = await WasmSqlite3.load(_wasmBytes.toDart);
        if (afterOpen) {
          sqlite.registerVirtualFileSystem(
            InMemoryFileSystem(name: 'initial'),
            makeDefault: true,
          );
          sqlite.open(':memory:').close();
        }
        final label = '$kind afterOpen=$afterOpen default=$makeDefault';
        final VirtualFileSystem fs;
        try {
          fs = switch (kind) {
            'indexeddb' =>
              await IndexedDbFileSystem.open(dbName: 'pantas-probe'),
            'opfs' =>
              await SimpleOpfsFileSystem.loadFromStorage('pantas-probe'),
            _ => InMemoryFileSystem(),
          };
        } on Object catch (e) {
          // ignore: avoid_print
          print('$label: VFS setup failed: $e');
          continue;
        }
        sqlite.registerVirtualFileSystem(fs, makeDefault: makeDefault);
        for (final form in [
          'plain',
          'uri-direct',
          'uri-shim',
          'uri-default-flag',
          'argument-shim',
        ]) {
          CommonDatabase? db;
          try {
            final path = kind == 'opfs' ? '/database' : '/probe-$form';
            db = switch (form) {
              'uri-direct' =>
                sqlite.open('file:$path?vfs=${fs.name}', uri: true),
              'uri-shim' => sqlite
                  .open('file:$path?vfs=multipleciphers-${fs.name}', uri: true),
              'uri-default-flag' =>
                sqlite.open('file:$path?vfs=multipleciphers-${fs.name}'),
              'argument-shim' =>
                sqlite.open(path, vfs: 'multipleciphers-${fs.name}'),
              _ => sqlite.open(path, vfs: makeDefault ? null : fs.name),
            };
            final key = List.filled(32, 'ab').join();
            db
              ..execute("PRAGMA cipher = 'chacha20';")
              ..execute("PRAGMA key = \"x'$key'\";")
              ..execute('CREATE TABLE IF NOT EXISTS probe (value TEXT)')
              ..execute("INSERT INTO probe VALUES ('synthetic')");
            // ignore: avoid_print
            print(
              '$label $form: cipher=${db.select('PRAGMA cipher;')} '
              'key + write accepted '
              '${db.select('SELECT * FROM probe')}',
            );
            db.close();
            db = sqlite.open(path, vfs: 'multipleciphers-${fs.name}')
              ..execute("PRAGMA cipher = 'chacha20';")
              ..execute("PRAGMA key = 'wrong';");
            try {
              db.select('SELECT * FROM probe');
              throw StateError('WRONG KEY ACCEPTED');
            } on SqliteException catch (e) {
              // ignore: avoid_print
              print('$label $form: wrong key rejected: $e');
            }
            db.close();
            db = sqlite.open(path, vfs: 'multipleciphers-${fs.name}')
              ..execute("PRAGMA cipher = 'chacha20';")
              ..execute("PRAGMA key = \"x'$key'\";");
            // ignore: avoid_print
            print(
              '$label $form: correct key reopen '
              '${db.select('SELECT count(*) AS n FROM probe')}',
            );
          } on Object catch (e) {
            // ignore: avoid_print
            print('$label $form: $e');
          } finally {
            db?.close();
          }
        }
        if (fs is IndexedDbFileSystem) await fs.close();
        if (fs is SimpleOpfsFileSystem) fs.close();
      }
    }
  }
  _finished();
}

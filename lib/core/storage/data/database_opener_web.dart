import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:drift/wasm.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:sqlite3/wasm.dart';
// The browser API package is already locked through Flutter's web plugins.
// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

const _databaseName = 'pantas-study-v1';
const _vaultName = 'pantas-study-key-v1';

Future<AppDatabase> openEncryptedDatabase() async {
  final release = Completer<void>();
  final acquired = Completer<void>();
  // IndexedDbFileSystem caches pages in memory. Hold one origin-wide owner
  // until close to prevent stale caches overwriting another tab's progress.
  // Shared workers can replace this limit when multi-tab use is needed.
  final ownership = web.window.navigator.locks
      .request(
        _databaseName,
        web.LockOptions(ifAvailable: true),
        ((web.Lock? lock) {
          return (() async {
            if (lock == null) {
              acquired.completeError(
                Exception('study database is open in another tab'),
              );
              return null;
            }
            acquired.complete();
            await release.future;
            return null;
          })()
              .toJS;
        }).toJS,
      )
      .toDart
      .then<void>(
    (_) {},
    onError: (Object error, StackTrace stack) {
      if (!acquired.isCompleted) acquired.completeError(error, stack);
    },
  );
  await acquired.future;

  IndexedDbFileSystem? fs;
  try {
    final key = await _readOrCreateKey();
    final sqlite = await WasmSqlite3.loadFromUrlString(
      web.URL('sqlite3.wasm', web.document.baseURI).href,
    );
    fs = await IndexedDbFileSystem.open(
      dbName: _databaseName,
      writeAutomatically: false,
    );
    sqlite.registerVirtualFileSystem(fs);
    final executor = WasmDatabase(
      sqlite3: _CipherSqlite3(sqlite, 'multipleciphers-${fs.name}'),
      path: '/database',
      fileSystem: fs,
      setup: (db) {
        // Wrapping protects copied browser files, not code running on the site.
        // Web ChaCha20 and native SQLCipher use separate database files.
        final hex = key.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
        db.execute("PRAGMA cipher = 'chacha20';");
        final cipher = db.select('PRAGMA cipher;');
        if (cipher.length != 1 || cipher.single.values.single != 'chacha20') {
          throw StateError('encrypted SQLite module is required');
        }
        db
          ..execute("PRAGMA key = \"x'$hex'\";")
          ..execute('PRAGMA journal_mode = DELETE;')
          ..execute('PRAGMA temp_store = MEMORY;')
          ..select('SELECT count(*) FROM sqlite_schema;');
      },
    );
    final database = _WebAppDatabase(executor, fs, () async {
      release.complete();
      await ownership;
    });
    // Authenticate existing bytes before handing the database to callers.
    try {
      await database.customSelect('SELECT 1').get();
    } on Object {
      await database.close();
      rethrow;
    }
    return database;
  } on Object {
    try {
      await fs?.close();
    } finally {
      if (!release.isCompleted) release.complete();
      await ownership;
    }
    rethrow;
  }
}

Future<JSAny?> _request(web.IDBRequest request) {
  final result = Completer<JSAny?>();
  request
    ..onsuccess = ((web.Event _) => result.complete(request.result)).toJS
    ..onerror = ((web.Event _) => result.completeError(
          StateError(request.error?.message ?? 'key storage request failed'),
        )).toJS;
  return result.future;
}

Future<Uint8List> _readOrCreateKey() async {
  final opening = web.window.indexedDB.open(_vaultName, 1);
  opening.onupgradeneeded = ((web.IDBVersionChangeEvent _) {
    (opening.result! as web.IDBDatabase).createObjectStore('keys');
  }).toJS;
  final vault = (await _request(opening))! as web.IDBDatabase;
  try {
    final read = vault.transaction('keys'.toJS, 'readonly');
    final record =
        await _request(read.objectStore('keys').get('database'.toJS));
    final crypto = web.window.crypto;
    final subtle = crypto.subtle;
    if (record != null && !record.isUndefined) {
      final stored = record as _WrappedKey;
      if (stored.wrappingKey.extractable) {
        throw StateError('database wrapping key must be non-extractable');
      }
      final raw = await subtle
          .decrypt(
            _AesGcmParams(name: 'AES-GCM', iv: stored.iv),
            stored.wrappingKey,
            stored.wrapped,
          )
          .toDart;
      final bytes = (raw! as JSArrayBuffer).toDart.asUint8List();
      if (bytes.length != 32) throw StateError('invalid wrapped database key');
      return bytes;
    }

    final rawKey = crypto.getRandomValues(Uint8List(32).toJS) as JSUint8Array;
    final key = rawKey.toDart;
    final iv = crypto.getRandomValues(Uint8List(12).toJS) as JSUint8Array;
    final wrappingKey = (await subtle
        .generateKey(
          _AesKeyGenParams(name: 'AES-GCM', length: 256),
          false,
          ['encrypt'.toJS, 'decrypt'.toJS].toJS,
        )
        .toDart)! as web.CryptoKey;
    final wrapped = await subtle
        .encrypt(
          _AesGcmParams(name: 'AES-GCM', iv: iv),
          wrappingKey,
          key.toJS,
        )
        .toDart;
    final write = vault.transaction('keys'.toJS, 'readwrite');
    final completed = Completer<void>();
    write
      ..oncomplete = ((web.Event _) => completed.complete()).toJS
      ..onabort = ((web.Event _) {
        if (!completed.isCompleted) {
          completed.completeError(StateError('database key storage aborted'));
        }
      }).toJS
      ..onerror = ((web.Event _) {
        if (!completed.isCompleted) {
          completed.completeError(StateError('database key storage failed'));
        }
      }).toJS;
    write.objectStore('keys').add(
          _WrappedKey(
            wrappingKey: wrappingKey,
            iv: iv,
            wrapped: wrapped! as JSArrayBuffer,
          ),
          'database'.toJS,
        );
    await completed.future;
    return key;
  } finally {
    vault.close();
  }
}

extension type _WrappedKey._(JSObject _) implements JSObject {
  external factory _WrappedKey({
    required web.CryptoKey wrappingKey,
    required JSUint8Array iv,
    required JSArrayBuffer wrapped,
  });
  external web.CryptoKey get wrappingKey;
  external JSUint8Array get iv;
  external JSArrayBuffer get wrapped;
}

class _WebAppDatabase extends AppDatabase {
  _WebAppDatabase(super.executor, this._fs, this._release);

  final IndexedDbFileSystem _fs;
  final Future<void> Function() _release;
  Future<void>? _closing;

  @override
  Future<void> close() => _closing ??= _close();

  Future<void> _close() async {
    try {
      await super.close();
    } finally {
      try {
        await _fs.close();
      } finally {
        await _release();
      }
    }
  }
}

// Drift's constructor supplies no VFS argument. This adapter selects the
// upstream encryption shim while retaining Drift's IndexedDB flush behavior.
class _CipherSqlite3 implements CommonSqlite3 {
  _CipherSqlite3(this._sqlite, this._vfs);
  final WasmSqlite3 _sqlite;
  final String _vfs;

  @override
  CommonDatabase open(
    String filename, {
    String? vfs,
    OpenMode mode = OpenMode.readWriteCreate,
    bool uri = false,
    bool? mutex,
  }) =>
      _sqlite.open(filename, vfs: _vfs, mode: mode, uri: uri, mutex: mutex);

  @override
  CommonDatabase openInMemory({String? vfs}) => _sqlite.openInMemory(vfs: _vfs);

  @override
  Version get version => _sqlite.version;
  @override
  String? get tempDirectory => _sqlite.tempDirectory;
  @override
  set tempDirectory(String? value) => _sqlite.tempDirectory = value;
  @override
  void registerVirtualFileSystem(
    VirtualFileSystem vfs, {
    bool makeDefault = false,
  }) =>
      _sqlite.registerVirtualFileSystem(vfs, makeDefault: makeDefault);
  @override
  void unregisterVirtualFileSystem(VirtualFileSystem vfs) =>
      _sqlite.unregisterVirtualFileSystem(vfs);
}

extension type _AesGcmParams._(JSObject _) implements JSObject {
  external factory _AesGcmParams({
    required String name,
    required JSUint8Array iv,
  });
}
extension type _AesKeyGenParams._(JSObject _) implements JSObject {
  external factory _AesKeyGenParams({
    required String name,
    required int length,
  });
}

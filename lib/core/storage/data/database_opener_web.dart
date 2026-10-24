import 'dart:async';
import 'dart:js_interop';

import 'package:drift/wasm.dart';
import 'package:pantas/core/storage/data/app_database.dart';
// The browser API package is already locked through Flutter's web plugins.
// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

/// The study database name in browser storage.
///
/// The first test builds kept an encrypted database named `pantas-study-v1`
/// plus a key record named `pantas-study-key-v1`. Nothing was released with
/// them, so they are left in place and never opened. Opening an encrypted file
/// as a plain database would read as damaged and be replaced.
const webStudyDatabaseName = 'pantas-study-v2';

/// Opens the study database with Drift's standard web setup.
///
/// The name is shared with native, where this opens the SQLCipher database.
/// On web the database is not encrypted. Drift picks the best storage the
/// browser offers, in this order: OPFS in a shared worker, OPFS with locks
/// (needs cross-origin isolation), IndexedDB in a shared worker, IndexedDB in
/// a dedicated worker. The shared modes let several tabs use one database.
Future<AppDatabase> openEncryptedDatabase({
  String databaseName = webStudyDatabaseName,
  Uri? sqlite3Uri,
  Uri? driftWorkerUri,
}) async {
  final wasm = sqlite3Uri ?? Uri.base.resolve('sqlite3.wasm');
  final worker = driftWorkerUri ?? Uri.base.resolve('drift_worker.js');
  try {
    return await _openOnce(databaseName, wasm, worker);
  } on _UnreadableDatabase catch (unreadable) {
    // A damaged file cannot be repaired. The server holds the account's
    // content and finished sessions, so start again with an empty database.
    // Any other failure is shown to the student and never deletes data.
    final probe = await WasmDatabase.probe(
      sqlite3Uri: wasm,
      driftWorkerUri: worker,
      databaseName: databaseName,
    );
    await probe.deleteDatabase((unreadable.api, databaseName));
    return _openOnce(databaseName, wasm, worker);
  }
}

Future<AppDatabase> _openOnce(String name, Uri wasm, Uri worker) async {
  final opened = await WasmDatabase.open(
    databaseName: name,
    sqlite3Uri: wasm,
    driftWorkerUri: worker,
  );
  final storage = opened.chosenImplementation;
  Future<void> Function()? release;
  try {
    switch (storage) {
      case WasmStorageImplementation.inMemory:
        throw StateError(
          'this browser cannot keep the study database: '
          '${opened.missingFeatures}',
        );
      case WasmStorageImplementation.unsafeIndexedDb:
        // Each tab would cache its own copy and overwrite the other's
        // progress, so only one tab may use this mode at a time.
        release = await claimSingleTab(name);
      case WasmStorageImplementation.opfsShared:
      case WasmStorageImplementation.opfsLocks:
      case WasmStorageImplementation.sharedIndexedDb:
        break;
    }
  } on Object {
    await _closeQuietly(opened.resolvedExecutor.close);
    rethrow;
  }

  final database = _WebAppDatabase(opened.resolvedExecutor, release);
  try {
    // Read the file before handing it to callers, so damage shows up here.
    await database.customSelect('SELECT 1').get();
  } on Object catch (error) {
    await _closeQuietly(database.close);
    final api = storage.storageApi;
    if (api != null && _isDamaged(error)) throw _UnreadableDatabase(api, error);
    rethrow;
  }
  return database;
}

// SQLite reports these two failures for a file that is not a database or has
// broken pages. The error crosses from the worker as text, so match the text.
bool _isDamaged(Object error) {
  final text = error.toString().toLowerCase();
  return text.contains('file is not a database') || text.contains('malformed');
}

class _UnreadableDatabase implements Exception {
  _UnreadableDatabase(this.api, this.cause);
  final WebStorageApi api;
  final Object cause;

  @override
  String toString() => 'study database is unreadable: $cause';
}

Future<void> _closeQuietly(Future<void> Function() close) async {
  try {
    await close();
  } on Object {
    // The error that made the caller close is the one worth reporting.
  }
}

/// Takes the browser-wide owner lock for [name] and returns the function that
/// releases it. Throws a [StateError] if another tab holds it.
Future<Future<void> Function()> claimSingleTab(String name) async {
  final release = Completer<void>();
  final acquired = Completer<void>();
  final held = web.window.navigator.locks
      .request(
        name,
        web.LockOptions(ifAvailable: true),
        ((web.Lock? lock) {
          return (() async {
            if (lock == null) {
              acquired.completeError(
                StateError('study database is open in another tab'),
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
  return () async {
    if (!release.isCompleted) release.complete();
    await held;
  };
}

class _WebAppDatabase extends AppDatabase {
  _WebAppDatabase(super.executor, this._release);

  final Future<void> Function()? _release;
  Future<void>? _closing;

  @override
  Future<void> close() => _closing ??= _close();

  Future<void> _close() async {
    try {
      await super.close();
    } finally {
      await _release?.call();
    }
  }
}

import 'dart:typed_data';

import 'package:drift/wasm.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:sqlite3/wasm.dart';
// Already locked through Flutter's web plugins, and the in-memory file
// system stores its files in this buffer type.
// ignore: depend_on_referenced_packages
import 'package:typed_data/typed_buffers.dart';
// The browser API package is already locked through Flutter's web plugins.
// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

/// The databases the reviewer screens read.
///
/// The content database is the seed built from the content tree, opened the
/// way the app opens it. Study databases are the app's real schema, empty and
/// in memory. Each screen gets its own so nothing carries over between items.
class ReviewDatabases {
  ReviewDatabases._(this._sqlite, this._files, this.content);

  final WasmSqlite3 _sqlite;
  final InMemoryFileSystem _files;
  ContentDatabase content;
  var _opened = 0;

  /// Loads `sqlite3.wasm` from beside the page and opens [contentBytes].
  static Future<ReviewDatabases> open(Uint8List contentBytes) async {
    final sqlite = await WasmSqlite3.loadFromUrlString(
      web.URL('sqlite3.wasm', web.document.baseURI).href,
    );
    final files = InMemoryFileSystem();
    sqlite.registerVirtualFileSystem(files, makeDefault: true);
    final databases = ReviewDatabases._(
      sqlite,
      files,
      ContentDatabase(WasmDatabase.inMemory(sqlite)),
    );
    await databases.content.close();
    databases.content = databases._openContent(contentBytes);
    return databases;
  }

  ContentDatabase _openContent(Uint8List bytes) {
    final path = '/content-pass-seed-${_opened++}.db';
    _files.fileData[path] = Uint8Buffer()..addAll(bytes);
    return ContentDatabase(WasmDatabase(sqlite3: _sqlite, path: path));
  }

  /// Switches to a newly built seed. Screens must be rebuilt afterward.
  Future<void> replaceContent(Uint8List bytes) async {
    final old = content;
    content = _openContent(bytes);
    await old.close();
  }

  /// An empty study database with the app's real schema.
  AppDatabase newAppDatabase() => AppDatabase(WasmDatabase.inMemory(_sqlite));
}

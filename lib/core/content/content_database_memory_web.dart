import 'package:drift/wasm.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:sqlite3/wasm.dart';
// The browser API package is already locked through Flutter's web plugins.
// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

/// The web content database: the content tables in memory, no worker and no
/// storage. The content mirror fills it at each start. It uses the same
/// `sqlite3.wasm` file as the study database, which is plain SQLite when no
/// cipher is selected.
Future<ContentDatabase> openInMemoryContentDatabase() async {
  final sqlite = await WasmSqlite3.loadFromUrlString(
    web.URL('sqlite3.wasm', web.document.baseURI).href,
  );
  sqlite.registerVirtualFileSystem(InMemoryFileSystem(), makeDefault: true);
  return ContentDatabase(WasmDatabase.inMemory(sqlite));
}

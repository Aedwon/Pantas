import 'package:drift/wasm.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/storage/data/web_build_files_web.dart';
import 'package:sqlite3/wasm.dart';

/// The web content database: the content tables in memory, no worker and no
/// storage. The content mirror fills it at each start. It uses the same
/// `sqlite3.wasm` file as the study database, which is plain SQLite when no
/// cipher is selected.
Future<ContentDatabase> openInMemoryContentDatabase() async {
  final sqlite = await WasmSqlite3.loadFromUrlString(
    webBuildFile('sqlite3.wasm').toString(),
  );
  sqlite.registerVirtualFileSystem(InMemoryFileSystem(), makeDefault: true);
  return ContentDatabase(WasmDatabase.inMemory(sqlite));
}

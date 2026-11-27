import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/web_build_files.dart';

void main() {
  final documentBase = Uri.parse('https://app.test/');

  test('a stamped build finds sqlite3.wasm in its folder', () {
    expect(
      buildFileUri(documentBase, 'b/1-abc123/', 'sqlite3.wasm'),
      Uri.parse('https://app.test/b/1-abc123/sqlite3.wasm'),
    );
  });

  test('the database worker keeps one address for every build', () {
    // A shared worker is keyed by its address and name. The same address in
    // every build means a tab on the old build and a tab on the new one reach
    // the same worker instead of two that both think they own the database.
    expect(
      rootFileUri(documentBase, 'drift_worker.js'),
      Uri.parse('https://app.test/drift_worker.js'),
    );
    expect(
      rootFileUri(Uri.parse('https://app.test/app/'), 'drift_worker.js').path,
      '/app/drift_worker.js',
    );
  });

  test('a run with no build folder (dev, tests) uses the document base', () {
    expect(
      buildFileUri(documentBase, null, 'sqlite3.wasm'),
      Uri.parse('https://app.test/sqlite3.wasm'),
    );
    expect(
      buildFileUri(documentBase, '', 'sqlite3.wasm'),
      Uri.parse('https://app.test/sqlite3.wasm'),
    );
  });

  test('the folder is resolved against the document base, not the route', () {
    // The page's base href is "/", so a deep route does not move the folder.
    expect(
      buildFileUri(Uri.parse('https://app.test/'), 'b/x/', 'sqlite3.wasm').path,
      '/b/x/sqlite3.wasm',
    );
    expect(
      buildFileUri(Uri.parse('https://app.test/app/'), 'b/x/', 'a.js').path,
      '/app/b/x/a.js',
    );
  });
}

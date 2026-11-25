import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/web_build_files.dart';

void main() {
  final documentBase = Uri.parse('https://app.test/');

  test('a stamped build finds the database worker and wasm in its folder', () {
    expect(
      buildFileUri(documentBase, 'b/1-abc123/', 'drift_worker.js'),
      Uri.parse('https://app.test/b/1-abc123/drift_worker.js'),
    );
    expect(
      buildFileUri(documentBase, 'b/1-abc123/', 'sqlite3.wasm'),
      Uri.parse('https://app.test/b/1-abc123/sqlite3.wasm'),
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

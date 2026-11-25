/// The address of a file of the running web build.
///
/// A release build keeps every file the page loads in its own folder
/// (`b/<id>/`), and the page's bootstrap names that folder. The database worker
/// and `sqlite3.wasm` are loaded by this code rather than by the page, so they
/// must follow the folder: a root address could return another build's file.
/// With no folder (a dev run, a test server) the file is next to the page.
///
/// [documentBase] is the page's base URL and [buildBase] the folder relative to
/// it, such as `b/1-abc123/`.
Uri buildFileUri(Uri documentBase, String? buildBase, String name) =>
    documentBase.resolve(buildBase ?? '').resolve(name);

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

/// The address of a file that keeps one address in every build.
///
/// The database worker is the only one. A browser keys a shared worker by its
/// address and name, so a tab on the old build and a tab on the new one reach
/// the same worker only when both ask for the same address. The file's bytes
/// are pinned by the deploy guard.
Uri rootFileUri(Uri documentBase, String name) => documentBase.resolve(name);

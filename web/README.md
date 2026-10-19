# B2 and B3 web files

The Flutter web scaffold comes from `flutter create --platforms=web .`.
The generated icons and manifest remain scaffold assets. B5 and B6 own approved
launch presentation and installation. No app screen was changed.

## SQLite and Drift

`sqlite3.wasm` is the unmodified encrypted `sqlite3mc.wasm` asset from
[sqlite3 3.5.1](https://github.com/simolus3/sqlite3.dart/releases/tag/sqlite3-3.5.1):

https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-3.5.1/sqlite3mc.wasm

SHA-256: `62a34ec725631c0438e4255ce0c6059099bf8e7fb331e7d4d91a38e075f43a19`.
This matches `lib/src/hook/asset_hashes.dart` in the locked sqlite3 package.
Its wasm build enables only ChaCha20, not SQLCipher. The app opener selects the
upstream `multipleciphers-indexeddb` VFS shim. Direct VFS opens reject encryption;
the shim enables it without changing the wasm. A random database key is wrapped
with a non-extractable Web Crypto AES-GCM key. IndexedDB stores only the wrapped
key record and encrypted database pages. Native SQLCipher stays unchanged.

The app uses Drift's IndexedDB executor and awaits flushes after writes. Web Locks
allow one active database tab, preventing separate cached VFS instances from
overwriting progress. A second owner fails explicitly. Close releases ownership.
Missing required browser APIs fail closed. Wrapping protects copied browser
files, not code running on the site. Shared workers and OPFS are not integrated
into this opener; browser and phone acceptance remain pending.

`drift_worker.js` is compiled from `tool/web/drift_worker.dart` against locked
**drift 2.34.3** and **sqlite3 3.5.1**, with **Dart 3.12.2**. It uses Drift's
supported `WasmDatabase.workerMainForOpen` entrypoint, not a custom engine.
Rebuild after changing the locked packages or worker source:

```sh
dart compile js --no-source-maps -O2 tool/web/drift_worker.dart -o web/drift_worker.js
```

The `.deps` output is a compiler intermediate, not a runtime requirement.
The app opener uses the wasm directly. The standard worker remains shipped for
the planned content path, which is stopped.

## Blocked content path

The native signed seed uses SQLCipher and requires a pinned bootstrap secret to
decrypt and rekey before installation. That secret cannot be kept secret in a web
bundle. The user's stop condition applies. Web seed installation, protected
installation, and content opening explicitly throw. No package was regenerated,
no content key was read, and no signature verification was bypassed. First-run
initialization and version skip remain incomplete. See
`docs/superpowers/plans/pwa-launch/evidence/B3-encrypted-web-db.md`.

## Configuration

Each Firebase options file has named console placeholders and optional Dart
defines for web apiKey, appId, authDomain, and measurementId. Project ID, sender ID,
and bucket come from the existing matching project configuration. Console setup
and real sign-in remain unverified. Google sign-in 7 requires its rendered web
button. That visible change was stopped for lead review.

## Reproduce the encryption findings

These probes execute the shipped wasm and real Dart VFS classes. The second host
uses fake-indexeddb 6.2.4 and synthetic OPFS and Web Locks adapters under Node.
They do not establish real browser storage behavior. All keys and rows are
synthetic. The real app opener probe checks encrypted persistence, non-extractable
wrapping keys, tamper refusal, recovery, and owner exclusion.

```sh
PROBE_DIR=$(mktemp -d)
npm install --prefix "$PROBE_DIR" --no-audit --no-fund fake-indexeddb@6.2.4
export PANTAS_FAKE_IDB="$PROBE_DIR/node_modules/fake-indexeddb"
dart compile js tool/web/probe_encrypted_wasm.dart -o build/probe_encrypted_wasm.js
node tool/web/probe_encrypted_wasm.cjs
node tool/web/probe_browser_host.cjs
dart compile js tool/web/verify_web_database.dart -o build/verify_web_database.js
PANTAS_PROBE_SCRIPT=verify_web_database.js node tool/web/probe_browser_host.cjs
```

PANTAS_FAKE_IDB is required; the probe refuses to run without it.
Evidence, exact matrix output, maintainer sources, and content stop reasoning:
`docs/superpowers/plans/pwa-launch/evidence/B3-encrypted-web-db.md`.

## Staging hosting (B4, config only)

`firebase.json` has two Hosting targets: `site` (the existing `public/` site and the
`/wrapped/**` rewrite, unchanged) and `app` (`build/web`, single-page rewrite).
`.firebaserc` maps them for `pantas-staging`: `site` to `pantas-staging` and `app` to
`pantas-staging-app`. The `app` site id is a proposal and must exist first
(`firebase hosting:sites:create pantas-staging-app --project pantas-staging`).

Cache headers: files whose name carries an 8-character hash segment
(`name.<hash8>.js`, `.css`, `.wasm`, images, fonts) are
`public, max-age=31536000, immutable`; `index.html`, `flutter_service_worker.js`,
`manifest.json` and `version.json` are `no-cache`. Flutter's default output
(`main.dart.js`, CanvasKit, `sqlite3.wasm`, `drift_worker.js`) is not hashed by
filename, so none of it matches the immutable rule today. They revalidate by
default. Long-lived caching of them needs the B6 build step to hash their names.

Staging deploy command (do not run without the lead's approval):

```
flutter build web --release -t lib/main_staging.dart && \
  firebase deploy --only hosting:app --project pantas-staging
```

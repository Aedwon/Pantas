# B3 revision: standard (unencrypted) web study database

Date: October 24, 2026. Lead: Claude (Opus 5.5). Implementor: Sonnet 5.5, high effort.
Decision: main decision log `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md`,
"October 24: web study database encryption (D7) reversed". Aedwon: "okay then proceed, record
this decision and start the swap." Policy: `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md` from main.

## Goal

On web, open the study database with the standard drift web setup, without the
SQLite3MultipleCiphers ChaCha20 shim or the wrapped key. Native builds are unchanged (SQLCipher
study database and the protected native content package stay exactly as they are).

## Scope

In:
1. Replace the encrypted opener in `lib/core/storage/data/database_opener_web.dart` with drift's
   standard web opener (`WasmDatabase.open` or the existing drift web helper this codebase
   already uses), using the `web/sqlite3.wasm` and `web/drift_worker.js` already in the repo.
   No downloads: if the existing wasm cannot run unencrypted, or a different binary is required,
   stop and report.
2. Remove the key vault (`pantas-study-key-v1`), the cipher PRAGMAs and the one-tab owner lock if
   the standard setup handles several tabs (shared worker or OPFS locking). If drift selects a
   storage mode that cannot share between tabs in a browser, keep a one-tab guard and say which
   mode and why.
3. Existing encrypted browser databases from earlier test builds: nothing was released, so no
   migration. Use a new database name so an old encrypted file is never opened as plain, and
   delete the old IndexedDB entries only if drift gives a simple supported call; otherwise leave
   them and note it.
4. Remove web-only encryption tooling and docs that no longer apply: `tool/web/probe_encrypted_wasm.dart`,
   `tool/web/probe_browser_host.cjs` (if only used by that probe), the encryption parts of
   `web/README.md`. Keep native content-package files and tests (`content_cipher_profile.dart`,
   `content_package_manifest*`, `sqlite3mc_content_profile_test.dart`) untouched.
5. Recovery: if the web database cannot be opened (corrupt or cleared storage), the app must not
   crash. Follow the opener's existing failure behavior; if none exists, delete the web database
   and open a fresh one, since the server holds the authoritative copy (C7 content, C9 answers).
6. Report whether settings are synced to the server or held only locally on web (read only; do
   not change this).

Out: native code, content-package protection, C7/C9 behavior, any UI, new dependencies, server.

## Verification (paste actual output)

- Unit tests for the opener seams that the change touches (test first).
- A headless browser test if the repo already supports one (`flutter test --platform chrome` or
  the existing tool); do not operate a visible browser. Prove: write, reopen after close, data
  present. If headless browser tests cannot run here, say so.
- `flutter build web --release -t lib/main_staging.dart` (with the build defines the README
  documents; no secrets).
- `flutter test` on affected areas, `flutter analyze lib test`, format check, layering,
  attribution. The lead runs the full suite.

## Stop conditions

`SUBAGENTS.md` Part 6, plus: a new wasm binary or download is needed; the standard opener needs a
dependency not in `pubspec.yaml`; any native file would have to change.

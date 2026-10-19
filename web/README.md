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

## Content on web (C7 client)

Ruling: `docs/superpowers/plans/pwa-launch/C7-client-ruling.md`. The web build has no
bundled content database. `bootstrapWebContentOverrides` (in `lib/core/content/content.dart`)
opens a `ContentDatabase` in memory (drift on `sqlite3.wasm`, no worker, no storage) and
overrides `contentDatabaseProvider` with it, so every existing caller reads the same tables
it reads on native. `ContentMirror` (`lib/core/content/remote/content_mirror.dart`) fills it:

1. At start, from the encrypted `CachedContent` table: catalog documents first, then
   lessons and question sets.
2. From the server: the catalog is refreshed in the background (at once when nothing is
   cached, waiting up to 10 seconds), and again when a different account signs in.
3. From `ContentService.changes`: every changed item is upserted. A downgrade to Free is
   announced as changed items, so the Pro notes leave the in-memory rows too.

Lesson bodies and question text are filled when first needed. `LessonRepo`, `QuestionRepo`
and `ContentRepository` (which is what the W4 screens use) take an optional
`ContentFetchHook` (the mirror on web, null on native). Before they read text they ask it
to fetch the lesson or the question sets; questions whose text cannot be fetched are left
out and a lesson whose body cannot be fetched reads as missing. Listing lessons by topic
fetches nothing and returns empty bodies. Opening a lesson preloads the next three lessons
of its topic. Mock papers are not assembled from this database (C8b).

### Content catalog (`getContent`, kind `catalog`)

Same request and response as `lessons` and `questions`: auth, App Check, daily id budget,
`knownVersions`, and the `.f` or `.p` version suffix. The Dart reader is
`lib/core/content/remote/content_catalog.dart`; its tests are
`test/core/content/remote/content_catalog_test.dart`. Each `data` map below is the
`getContent` item `data`. Titles and ids are not protected, so Free and Pro get the same
catalog.

Rows named "export document" are exactly what `tools/build_content_export` writes for that
type (`_id`, `_updatedAt`, `schemaVersion`, `isActive`, `{ "_ref": id }` references and the
other columns), so the uploader can copy them. The reader accepts a plain id string wherever
the export has `{ "_ref": id }`.

`index`:

```
{ "id": "index",
  "exams":    [ export document, ... ],
  "subjects": [ export document, ... ],
  "topics":   [ export document, ... ],
  "catalogs": [ "exam_upcat" ] }      // ids of the exam catalogs that exist
```

`<examId>` (for example `exam_upcat`), and any id listed in `parts`:

```
{ "id": "exam_upcat",
  "subjects":       [ export document, ... ],            // optional
  "topics":         [ export document, ... ],            // optional
  "lessons": [ { "id": "lesson-biology-cells", "topic": "topic_upcat_biology",
                 "subtopic": "subtopic_cells", "title": "...", "summary": "...",
                 "estimatedMinutes": 12, "ordering": 3, "isActive": true } ],
  "sets": [ { "id": "qs-science__biology__cells",        // the id to request as kind questions
              "topic": "topic_upcat_biology", "subtopic": "subtopic_cells",
              "lesson": "lesson-biology-cells",           // optional
              "exams": [ "exam_upcat" ], "language": "en", // language optional, default en
              "questions": [ { "id": "bio-0001" },
                             { "id": "bio-0002", "passage": "rc-cs-ap-p1", "figure": true } ] } ],
  "passages":       [ export document, ... ],            // see open item 1
  "diagnosticSets": [ export document, ... ],
  "mockBlueprints": [ export document, ... ],
  "parts": [ "exam_upcat.science" ] }                    // only on the main document
```

Rules the server side must keep:

- No text in the catalog: lessons have no `body`; questions have no stem, choices,
  explanation or figure spec. `"figure": true` only says a figure spec exists, because quiz
  planning reads that before the set is fetched.
- Every question served in a set must be listed in a `sets[].questions` entry of the same
  `id`, with the topic, subtopic, lesson and exams the set's `meta` gives. The client maps a
  question to its set from this list; a question that is not listed cannot be fetched. Leave
  out questions the bundled build holds back (a figure that is not drawn yet).
- `lessons[].id` is the id to request as kind `lessons`. `topic` and `subtopic` use the ids
  the bundled build uses (`topic_upcat_<slug with underscores>`, `subtopic_<slug>`).
- A document must stay under the 1 MiB Firestore limit. Split a large exam by listing more
  catalog ids in `parts` on the main `<examId>` document; each part has the same shape
  without `parts`. Ids are limited to `[A-Za-z0-9_.-]`, so use `exam_upcat.science`.
- Rows are upserts. The client never deletes: a lesson or question removed from the catalog
  stays in memory until the next start, when the database is rebuilt from the cache.
- `lessons` items keep the shape `serveContent` sends today. The body is Markdown;
  `lib/core/content/remote/lesson_markdown.dart` converts it to the blocks the lesson
  screen reads, with the result the bundled build produces (a test compares all lessons).

Cost to keep in mind: each catalog request counts its ids against the daily 300. A start
refreshes `index` plus one document per exam in `catalogs` (and parts), so keep `catalogs`
to the exams that have content.

### Open items for the server side and the lead

1. Passages. 260 of 3,165 questions in the current export belong to one of 32 reading
   passages, and passage text is in no served document. The reader accepts a `passages`
   list (export documents, text included) on the exam catalog. Whether passage text may sit
   in the Free catalog or needs its own protected kind is a decision for the lead.
2. Illustrations. The bundled lesson build drops illustration markers while no asset map
   exists (none does today), and the web reader does the same.
3. Lesson search on web finds text only in lessons whose body was fetched.

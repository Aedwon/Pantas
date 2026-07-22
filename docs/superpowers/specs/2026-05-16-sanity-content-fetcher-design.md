# Spec 2 — Sanity Content Fetcher + Drift Cache

> **Superseded in sequence, 11 August 2026, not in intent.** This spec's goal,
> replacing `assets/seed/v1.json` with content served from the content
> database, is the plan of record and is now underway. **How it gets there
> changed**: `specs/2026-08-11-content-path-and-the-mock.md` migrates the
> corpus through `seed_writer` into a bundled database first, and leaves the
> live Sanity fetch for later. Nothing here is wrong; read the newer spec for
> the order, and this one for the client, the queries and the parsers, which
> exist and work.



**Date:** 2026-05-16
**Status:** Approved design, ready for implementation plan
**Critical-path position:** 2 of 11 (blocks Spec 3 Sync, informs Specs 4/5/6/10)
**Owner:** Aerol Balayon
**Target soft launch:** 2026-06-28 (Android-only)

---

## 1. Purpose

Replace the bundled-JSON seed (`assets/seed/v1.json`) with a Sanity-sourced content pipeline so content can be updated post-launch without an app release. Content lives in a separate, regenerable Drift database; user-data stays where it already is.

## 2. Scope

**In scope:**

- Fetching from Sanity CDN: doctypes `exam`, `subject`, `topic`, `question`, `lesson`, `mockExam`, `mockBlueprint`, `diagnosticSet`.
- Portable Text parsing into the shape `PortableTextRenderer` already expects.
- A new `content.db` Drift database, schema isolated from `app.db`.
- Cold-start: a `content.db` bundled in the APK as `assets/seed/content.db`, generated at build time by a CI pipeline driven by a Node script.
- Refresh strategy: throttled-on-launch (6h window) + manual "Refresh content" button surface exposed for Settings (Spec 8 wires the actual UI).
- Mutation policy: immutable-by-id. Content rows are never deleted; retiring is `isActive: false`.
- Schema discipline: each doctype carries a `schemaVersion` int; app pins expected version per doctype; mismatched docs are rejected and the prior cached row stays.
- Repository layer (`lib/core/content/`) exposing the same domain models existing features already consume — drop-in replacement for the current seed-based reads.

**Out of scope (deferred):**

- Full-text search (Drift FTS5) — v1.x. Current taxonomy-based browsing covers v1 content volume.
- Cloud Function proxy for Sanity — v1.x if/when abuse traffic materializes (see Section 12 Risks).
- Codegen pipeline from Sanity schema → Dart types — post-launch, when a second contributor is onboarded.
- Multi-language content. The `language` field is preserved in the schema (forward-compat) but the GROQ queries unconditionally filter `language == "en"` in v1.
- WorkManager background refresh — manual refresh covers the gap.
- Sanity Studio configuration itself — this spec consumes the schema. The Sanity-side schema lives in `sanity-studio/` and evolves under its own discipline.

## 3. Key Decisions (rationale)

The seven decisions locked during brainstorm. Each has a fallback path documented so future-you knows how to back out.

### D1. Direct CDN access (no proxy, no token)

App calls `apicdn.sanity.io` directly with the project's public read dataset. No token in the binary, no Cloud Function in the middle.

**Why:** Content is the product, not a secret. CDN edge caching means realistic users hit Sanity rarely (after first bundle, just deltas). Soft-launch traffic is too small for abuse to be a real cost.

**Mitigations against abuse:** Sanity dashboard spend cap + usage alerts at 50/80/100%.

**Fallback if abuse becomes real:** swap to a Cloud Function proxy. The base URL of `SanityClient` becomes the Function URL, the Function runs the same GROQ queries, App Check enforces app-origin requests. No app-side refactor beyond the URL.

### D2. Separate `content.db` next to `app.db`

Two Drift databases. `app.db` is unchanged (user-data, SQLCipher-encrypted, syncs to Firestore). `content.db` is new (Sanity-sourced, plaintext, never synced, regenerable).

**Why:** Sign-out/account-delete/wipe-local-data operations target a single file boundary. Content has a different lifecycle from user-data — it's *replaceable from the network*, user-data is *the user's actual work*. Mixing them creates careful-deletion bugs.

**Encryption:** none on `content.db`. No PII, no secrets, published content.

### D3. Bundle `content.db` in the APK

The APK ships with `assets/seed/content.db` pre-populated from Sanity at build time. On first launch the app copies it into `<appSupportDir>/content.db`. The app opens immediately to fully-usable content; sync runs in the background.

**Why:** PH bandwidth-constrained target hardware. A "Downloading content…" splash on first launch reads as broken on shaky networks. Bundling means the app *just works* offline at install. Sanity becomes "the way content gets updated," not "the way content arrives."

**APK size budget:** v1 content volume (single author hand-entering) is expected at 2–8 MB encoded. If bundle ever exceeds ~30 MB, fall back to bundling a "minimal" subset (exams + onboarding-critical questions); full content streams in afterward.

### D4. Throttled-on-launch sync + manual refresh

Incremental sync runs on every cold start, but is skipped if `lastSyncedAt < 6h ago`. A manual "Refresh content" button in Settings bypasses the throttle.

**Why:** Caps Sanity quota burn for heavy launchers without sacrificing freshness. Manual refresh gives both you (debugging) and users (force-pull) an escape hatch. Skips WorkManager — content doesn't change often enough to justify it in v1.

### D5. Immutable-by-id content, retire via `isActive: false`

Sanity authors do not edit a question's meaning in place. To "change" a question, mark the old one `isActive: false` and publish a new doc with a new `_id`. Typo fixes to non-correctness text (the stem wording, explanations) can edit in place — the correctness rule is whatever `choices[].isCorrect` says.

**Why:** Disciplined authoring is cheaper than building version-bump logic and reset-FSRS flows for v1. User FSRS state is bound to question `_id`; retire-and-republish naturally lets stale FSRS cards age out while the new card starts fresh. Past attempts stay readable (the retired question row is never deleted from `content.db`).

**Authoring contract** is documented in `CONTRIBUTING.md` — onboarding material for future content authors.

### D6. Hand-maintained schema sync with `schemaVersion` pinning

Each Sanity doctype carries an int `schemaVersion`. The app pins an expected version per doctype in `schema_versions.dart`. On parse, mismatched versions throw `SchemaMismatchException`; that doctype's prior cached row stays, and Crashlytics logs a non-fatal.

**Why:** One author for v1; the codegen alternative is 2–4 days of pipeline build + ongoing maintenance, with no second contributor yet to benefit from it. The failure mode (forgot-to-bump) is loud in your own testing because the fallback-to-cache is visible.

**Forward-compat:** the spec is structured so a future codegen swap (post-launch, when a hire arrives) replaces only `lib/core/content/sanity/parsers/` and `groq_queries.dart`. Consumer-facing API (repos) does not change.

### D7. No in-app search in v1

FTS5 index is not built. Study-tab taxonomy browsing (subject → topic → lesson/question) is the only discovery mechanism in v1.

**Why:** Content volume at launch is small (single author hand-entering), browsing is faster than searching, and no other spec on the critical path references search. Defer until content volume justifies it and a real user asks.

**Forward-compat:** Adding FTS5 later is additive — a new `content_fts` virtual table, populated on next sync, plus a search UI. No content schema changes needed.

## 4. Architecture

Two databases, one network path, one consumer-facing repo layer.

```
   ┌─────────────────────────────────────────────────────────────────┐
   │ App (Riverpod consumers)                                        │
   │   examRepoProvider  questionRepoProvider  lessonRepoProvider …  │
   └────────────────────────────┬────────────────────────────────────┘
                                │ reads typed Dart models
                                ▼
   ┌─────────────────────────────────────────────────────────────────┐
   │ lib/core/content/                                               │
   │   repos/   ← public API consumed by features                    │
   │   sanity/  ← client, GROQ queries, Portable Text parsers        │
   │   sync/    ← ContentSyncCoordinator (throttle, manual, errors)  │
   │   bundle/  ← cold-start: copy bundled content.db on first boot  │
   └────────────────────────────┬────────────────────────────────────┘
                                │
            ┌───────────────────┴──────────────────┐
            ▼                                      ▼
   ┌──────────────────┐                  ┌──────────────────────┐
   │  content.db      │  ◄── sync ───►   │ apicdn.sanity.io     │
   │  (Drift, plain)  │                  │ public CDN, no auth  │
   │  exams, topics,  │                  │ GROQ queries         │
   │  questions, …    │                  └──────────────────────┘
   └──────────────────┘
            ▲
            │ first-launch copy from assets
            │
   ┌──────────────────────────────┐
   │ assets/seed/content.db       │  ◄── built in CI from Sanity
   │ (shipped in APK)             │     by tools/build_content_seed/
   └──────────────────────────────┘
```

**Boundaries:**

- `app.db` (existing) — user-data only. Unchanged by this spec.
- `content.db` (new) — Sanity-sourced content only.
- Network layer is internal to `lib/core/content/`. Nothing outside this directory talks to Sanity directly. Consumers see typed Dart models from repos.

### 4.1 Module layout

```
lib/core/content/
  content.dart                    ← barrel export
  content_database.dart           ← @DriftDatabase, schemaVersion=1
  content_database.g.dart         ← generated
  tables/
    content_exams.dart
    content_subjects.dart
    content_topics.dart
    content_questions.dart
    content_choices.dart
    content_question_exams.dart   ← junction for M:M question.examIds
    content_lessons.dart
    content_mock_blueprints.dart
    content_mock_exams.dart
    content_diagnostic_sets.dart
    content_meta.dart             ← key/value: lastSyncedAt, bundleVersion
  sanity/
    sanity_client.dart            ← Dio wrapper, base URL = apicdn
    groq_queries.dart             ← const GROQ strings per doctype (full + delta)
    schema_versions.dart          ← per-doctype expected versions (single source)
    parsers/
      exam_parser.dart
      subject_parser.dart
      topic_parser.dart
      question_parser.dart
      lesson_parser.dart
      mock_blueprint_parser.dart
      mock_exam_parser.dart
      diagnostic_set_parser.dart
      portable_text_parser.dart   ← Sanity PT → renderer-shape JSON
  sync/
    content_sync_coordinator.dart
    sync_throttle.dart            ← lastSyncedAt + 6h window logic
    sync_status.dart              ← sealed: idle | syncing | ok | partialFailure | failure
  bundle/
    seed_installer.dart           ← copy assets/seed/content.db on first boot
  repos/
    exam_repo.dart
    subject_repo.dart
    topic_repo.dart
    question_repo.dart
    lesson_repo.dart
    mock_blueprint_repo.dart
    mock_exam_repo.dart
    diagnostic_set_repo.dart

tools/build_content_seed/         ← Node + Dart build-time pipeline
  package.json
  build.mjs                       ← @sanity/client → seed_data.json
  queries.mjs                     ← GROQ mirror of groq_queries.dart
  seed_writer.dart                ← reads JSON → writes assets/seed/content.db
```

## 5. Data model — `content.db` schema

All tables include: `id TEXT PRIMARY KEY`, `schemaVersion INTEGER NOT NULL`, `isActive INTEGER NOT NULL DEFAULT 1`, `updatedAt DATETIME NOT NULL` (from Sanity `_updatedAt`).

```
content_exams         (id, code, name, shortName, language, ordering)
content_subjects      (id, examId→content_exams, name, ordering)
content_topics        (id, subjectId→content_subjects, name, ordering)
content_questions     (id, topicId→content_topics, language,
                       stemJson TEXT,            -- Portable Text JSON
                       explanationJson TEXT,     -- Portable Text JSON
                       version INTEGER)          -- forensic only; see below
content_choices       (id, questionId→content_questions, label, text,
                       isCorrect, ordering)
content_question_exams(questionId, examId)       -- composite PK; M:M junction
content_lessons       (id, topicId→content_topics, title, summary,
                       estimatedMinutes, bodyJson TEXT)
content_mock_blueprints(id, examId→content_exams, name, durationMinutes,
                        sectionsJson TEXT)
content_mock_exams    (id, blueprintId→content_mock_blueprints, name,
                       publishedAt)
content_diagnostic_sets(id, examId→content_exams, name, questionIdsJson TEXT)
content_meta          (key TEXT PRIMARY KEY, value TEXT)
```

**Indexes:**

- `content_questions(topicId, isActive)` — hot path: drill-by-topic.
- `content_question_exams(examId)` — hot path: quiz-by-exam.

**Field notes:**

- `version` on questions: forensic only. App does not act on it in v1. Forward-compat for a future "did this question change in place?" detector.
- `stemJson`, `explanationJson`, `bodyJson`: Portable Text stored as JSON-encoded text. The existing `PortableTextRenderer` consumes the Sanity-native shape; storing as JSON avoids a lossy intermediate form. Parsers validate structure at fetch time; rendering happens on read.
- `sectionsJson` (mock blueprint), `questionIdsJson` (diagnostic set): JSON columns by design. Section structure is fluid; question lists are ordered. Modeling these as tables would create satellites that nothing else joins to.
- No `isPro` field. Pro-gating is decided at the consumer layer using RevenueCat entitlements (Spec 7).
- Drift migration baseline: `content.db` starts at Drift `schemaVersion = 1`. Future schema changes follow Drift's standard `MigrationStrategy`. A doctype-side `schemaVersion` bump (parse contract) does NOT imply a Drift migration unless table columns change.

## 6. Network layer

### 6.1 Sanity client

```dart
class SanityClient {
  SanityClient(this._dio, {required this.projectId, required this.dataset});
  final Dio _dio;
  final String projectId;
  final String dataset;
  // Base URL: https://{projectId}.apicdn.sanity.io/v2024-01-01/data/query/{dataset}

  Future<SanityResponse<T>> query<T>(
    String groq, {
    Map<String, Object?> params = const {},
    required T Function(Map<String, Object?>) parse,
  });
}

sealed class SanityResponse<T> {
  const factory SanityResponse.ok(List<T> docs, {required DateTime serverTime}) = _Ok;
  const factory SanityResponse.networkError(Object e) = _NetworkError;
  const factory SanityResponse.parseError(String doctype, Object e) = _ParseError;
  const factory SanityResponse.schemaVersionMismatch(
    String doctype, {required int got, required int expected}) = _SchemaMismatch;
}
```

- API version pinned to `v2024-01-01` — bumped deliberately during maintenance.
- Project ID + dataset via `--dart-define`: `SANITY_PROJECT_ID`, `SANITY_DATASET`. Same APP_ENV split as Spec 1: dev points at `development` dataset, prod points at `production`.
- No retry in the client; retry policy is centralized in the sync layer.

### 6.2 GROQ queries

One `full` and one `delta` per doctype, kept in `groq_queries.dart`:

```dart
const examsFull = r'''
  *[_type == "exam" && language == "en"]{
    _id, _updatedAt, schemaVersion, code, name, shortName, language, ordering,
    "isActive": coalesce(isActive, true)
  }
''';

const examsDelta = r'''
  *[_type == "exam" && language == "en" && _updatedAt > $since]{
    _id, _updatedAt, schemaVersion, code, name, shortName, language, ordering,
    "isActive": coalesce(isActive, true)
  }
''';
```

The `$since` param is `content_meta.lastSyncedAt`. First-ever sync (no lastSyncedAt) uses `full`; everything after uses `delta`.

### 6.3 Parsers

One file per doctype. Each parser is a pure function `Map<String, Object?> -> TableCompanion`. Behavior:

- Schema-version check at the top:
  ```dart
  final got = doc['schemaVersion'] as int? ?? -1;
  if (got != SchemaVersions.question) {
    throw SchemaMismatchException(doctype: 'question', got: got, expected: SchemaVersions.question);
  }
  ```
- Throws `ParseException` on missing required fields, wrong types, malformed Portable Text.
- Per-doctype isolation: a malformed `question` doc fails *its* parser only; `exam`/`lesson` fetches proceed independently.

`SchemaVersions` is a single const class — the only place to edit when bumping any doctype.

`portable_text_parser.dart` validates structure (blocks have `_type`, spans have text) and re-encodes as JSON for storage. `PortableTextRenderer` consumes the same shape on read.

## 7. Sync orchestration

Three entry points feed one coordinator.

```
       cold start              app launch              Settings refresh
            │                      │                        │
            ▼                      ▼                        ▼
   SeedInstaller.install    syncIfStale()           refreshNow()
            │                      │                        │
            └──────────────────────┴────────────────────────┘
                                   │
                                   ▼
                          runSync() — per-doctype, isolated
                                   │
                                   ▼
                         emit SyncStatus stream
```

### 7.1 Cold start — `SeedInstaller`

- Runs in `main.dart` before the first frame, parallelizable with `Firebase.initializeApp`.
- If `<appSupportDir>/content.db` does not exist → copy `assets/seed/content.db` to that path. The `content_meta.bundleVersion` row was already stamped into the bundled seed at build time (see Section 8), so the copied DB carries it forward — no re-stamp needed here.
- If it exists → no-op. Existing DB is the truth. (Reinstalling is the only path to a fresh seed.)
- Copy failure → fatal-error screen at startup. Without content, nothing works.
- On first successful copy, log `content_meta.bundleVersion` to Crashlytics as a custom key so user issues can be correlated with the bundle they installed.

### 7.2 Launch — `syncIfStale`

- Called once per cold start, fire-and-forget, after first frame.
- Read `content_meta.lastSyncedAt`. If `now - lastSyncedAt < 6h`, return.
- Otherwise call `runSync()`. Failures logged to Crashlytics, app stays usable on cached content.

### 7.3 Manual — `refreshNow`

- Exposed on `ContentSyncCoordinator`. The actual Settings UI ships with Spec 8; this spec exposes the method + `SyncStatus` stream.
- Bypasses the 6h throttle.
- Surfaces errors to the UI.

### 7.4 `SyncStatus` stream

```dart
sealed class SyncStatus {
  const factory SyncStatus.idle({DateTime? lastSyncedAt}) = _Idle;
  const factory SyncStatus.syncing() = _Syncing;
  const factory SyncStatus.ok({required DateTime at, required int updatedCount}) = _Ok;
  const factory SyncStatus.partialFailure({required List<String> failedDoctypes}) = _PartialFailure;
  const factory SyncStatus.failure({required String reason}) = _Failure;
}

final contentSyncStatusProvider = StreamProvider<SyncStatus>(...);
```

### 7.5 Per-doctype isolation

- Each doctype's fetch + parse + upsert runs inside its own try/catch.
- A network/parse/schema failure for one doctype does NOT abort others.
- Coordinator collects per-doctype results:
  - all succeed → `ok`
  - some succeed → `partialFailure` with the failed doctype names
  - all fail → `failure`
- A failing doctype's prior cached rows in `content.db` are left untouched.

### 7.6 Concurrency

- Coordinator holds an in-flight `Completer?`. A second call while one is running returns the same future. No parallel syncs.

### 7.7 Telemetry

- Crashlytics non-fatal `ContentSyncPartialFailure` (failed doctype list).
- Crashlytics non-fatal `ContentSyncSchemaMismatch` (doctype, got, expected).
- No PII; content sync is purely product-side.

## 8. Bundled seed generation (build-time)

Pipeline at `tools/build_content_seed/`. Runs in CI before `flutter build apk`.

```
Step 1: node tools/build_content_seed/build.mjs > seed_data.json
        — @sanity/client fetches all doctypes from `production` dataset.
        — Read token kept in CI secret (different from app; app uses CDN).

Step 2: dart run tools/build_content_seed/seed_writer.dart seed_data.json
        — Imports ContentDatabase.
        — Opens an in-memory DB; Drift runs schema migration.
        — For each doctype JSON: calls the *same* parser the app uses; inserts companion.
        — VACUUM INTO 'assets/seed/content.db'.
        — Stamps content_meta.bundleVersion = <CI build number>.

Step 3: flutter build apk --dart-define=...
        — Existing step; seed is now in assets/.
```

**Why a Dart helper instead of building SQLite by hand in JS:** schema must match `ContentDatabase` exactly. Hand-rolling DDL in JS is two sources of truth. The Dart helper lets Drift write the schema, so a future Drift migration is automatically reflected in the seed.

**Drift between Node `queries.mjs` and Dart `groq_queries.dart`:** the cost of choosing D6 over codegen. Caught manually during spec self-review + during the inevitable first end-to-end seed run when divergence breaks the build loudly.

**Bundle version tracking:** the build script stamps `content_meta.bundleVersion = <CI build number>` into the seed. App logs this on first launch as a Crashlytics custom key — lets you correlate user issues with "which bundle did they install."

**Local dev workflow:**

- Default: `assets/seed/content.db` is gitignored and missing on a fresh checkout.
- `make seed` (or `dart run tools/build_content_seed/`) regenerates it locally.
- If missing at `flutter build`: build fails with `Run \`make seed\` first`. No silent failure to empty content.

**Cleanup of old seed:** `assets/seed/v1.json` is deleted in this spec. `lib/core/storage/data/seeder.dart` is deleted (or stubbed to a no-op shim if other code still imports it — implementation plan resolves this).

## 9. Consumer API

The only surface the rest of the app sees.

### 9.1 Repos

One per doctype. Thin Drift query layers returning the existing Freezed domain models from `lib/core/storage/domain/` (`Exam`, `Subject`, `Topic`, `Question`, `Choice`, `Lesson`). Domain models do not change.

```dart
class ExamRepo {
  ExamRepo(this._db);
  final ContentDatabase _db;
  Future<List<Exam>> activeExams();
  Future<Exam?> findById(String id);
  Stream<List<Exam>> watchActive();
}

class QuestionRepo {
  Future<List<Question>> byTopic(String topicId, {int? limit});
  Future<List<Question>> byExam(String examId, {int? limit});  // via junction
  Future<Question?> findById(String id);
  Future<List<Question>> byIds(List<String> ids);
}

class LessonRepo {
  Future<List<Lesson>> byTopic(String topicId);
  Future<Lesson?> findById(String id);
}

class MockBlueprintRepo { Future<List<MockBlueprint>> byExam(String examId); /* ... */ }
class DiagnosticSetRepo { Future<DiagnosticSet?> forExam(String examId); /* ... */ }
```

All repo methods filter `isActive = true` by default. (Attempt-history rendering bypasses this via `findById` — historical reads should see retired content.)

### 9.2 Riverpod providers (`content.dart` barrel)

```dart
final contentDatabaseProvider = Provider<ContentDatabase>((ref) { /* ... */ });

final examRepoProvider          = Provider((ref) => ExamRepo(ref.watch(contentDatabaseProvider)));
final questionRepoProvider      = Provider((ref) => QuestionRepo(ref.watch(contentDatabaseProvider)));
final lessonRepoProvider        = Provider((ref) => LessonRepo(ref.watch(contentDatabaseProvider)));
final mockBlueprintRepoProvider = Provider((ref) => MockBlueprintRepo(ref.watch(contentDatabaseProvider)));
final diagnosticSetRepoProvider = Provider((ref) => DiagnosticSetRepo(ref.watch(contentDatabaseProvider)));

final activeExamsProvider       = StreamProvider<List<Exam>>(
  (ref) => ref.watch(examRepoProvider).watchActive(),
);
```

### 9.3 Existing feature integration

| Old (seed-backed) | New (content.db-backed) |
| --- | --- |
| `lib/core/storage/data/seeder.dart` reading `v1.json` | Deleted; `SeedInstaller` handles cold-start |
| Onboarding exam picker → existing repo | Repointed to `examRepoProvider` |
| Diagnostic flow loads question set from seed | `diagnosticSetRepoProvider` → `questionRepoProvider.byIds(...)` |
| Quiz tab reads selected-exam focus | Already reads `selectedExamFocus`; underlying exam data now from `examRepoProvider` |
| Lesson reader loads lessons | `lessonRepoProvider.byTopic` / `findById` |
| Mock exam (Spec 5, future) | `mockBlueprintRepoProvider` |

### 9.4 Migration concern — existing user-data references content IDs from the old seed

- The seed and Sanity both use the same IDs (`exam_cse_pro`, `topic_cse_vocab`, `q_001`, etc.). The Sanity `_id` is intentionally set to match seed IDs.
- Pre-launch test users' attempt history, FSRS state, and lesson progress survive the seed → Sanity swap. No data migration needed in `app.db`.
- Any seed ID that was typo'd or wrong gets fixed at Sanity. Affected user-data rows become orphaned (their `topicId`/`questionId` no longer joins). Spec 3 (sync) handles orphan tolerance — orphans are skipped in aggregations but not deleted.

### 9.5 No changes to `app.db` schema

This spec touches `content.db` only.

## 10. Testing strategy

Four layers. No e2e test against the real Sanity CDN in CI (brittle, requires live Sanity).

**1. Parser unit tests (`test/core/content/sanity/parsers/`):**

- Golden JSON fixtures (one per doctype) lifted from real Sanity responses, committed to `test/fixtures/sanity/`.
- For each parser: happy path, missing required field, wrong `schemaVersion`, wrong type, empty array, Portable Text edge cases (image blocks, math marks, nested lists).
- Per-doctype isolation: a malformed doc in a batch does not break the others.

**2. Sync coordinator tests (`test/core/content/sync/`):**

- Fake `SanityClient` returning scripted `SanityResponse`s.
- In-memory `ContentDatabase` via `NativeDatabase.memory()`.
- Cases: first-ever sync uses `full`; subsequent uses `delta` with `$since`; single-doctype failure produces `partialFailure`; all-fail produces `failure`; schema mismatch leaves prior cached row intact; throttle no-ops `syncIfStale` when fresh; concurrent calls share the same future.

**3. Seed installer test (`test/core/content/bundle/`):**

- Fixture `content.db` in `test/fixtures/`.
- Cases: file missing at destination → copied; file present → no-op; copy fails → throws.

**4. Repo tests (`test/core/content/repos/`):**

- In-memory `ContentDatabase` pre-seeded with rows.
- Per repo method: happy path, empty result, `isActive=false` filtered out, M:M join works for `QuestionRepo.byExam`.

**Build-time pipeline test:**

- CI smoke test runs `seed_writer.dart` against a small canned JSON input and asserts the resulting `.db` is non-empty and openable.
- The Node `build.mjs` step (real Sanity fetch) is not tested in CI — it's a deploy-time concern.

**Coverage targets:** parsers + sync coordinator ~90%+. Repos: cover every method used by features. Coordinator gets the most attention — it's the easy place to regress on.

## 11. Deliverables

- `lib/core/content/` module per Section 4.1.
- `ContentDatabase` at `<appSupportDir>/content.db`.
- `tools/build_content_seed/` (Node + Dart pipeline).
- CI step: run seed pipeline before `flutter build apk`.
- `assets/seed/content.db` — generated artifact in APK. `.gitignore` updated. `pubspec.yaml` `assets:` updated.
- `assets/seed/v1.json` — deleted.
- `lib/core/storage/data/seeder.dart` — deleted (or no-op shim if still imported; implementation plan resolves).
- Existing feature wiring (onboarding picker, diagnostic, quiz, lesson reader) repointed.
- `ContentSyncCoordinator.refreshNow()` + `contentSyncStatusProvider` exposed (UI lands in Spec 8).
- `--dart-define` keys: `SANITY_PROJECT_ID`, `SANITY_DATASET`. APP_ENV split per Spec 1.
- `CONTRIBUTING.md` — new "Content authoring discipline" section: immutable-by-id, retire-via-isActive, `schemaVersion` bump rules.
- Tests per Section 10.

## 12. Risks & mitigations

| Risk | Mitigation |
| --- | --- |
| Sanity quota abuse from a leaked APK | Sanity dashboard spend cap + alerts at 50/80/100%. Switch to Cloud Function proxy is additive (D1 fallback). |
| Schema drift between Sanity and app | `schemaVersion` pinning + fallback-to-cache + Crashlytics non-fatal on mismatch. |
| Seed missing in dev environment | `flutter build` fails loud with `Run \`make seed\` first`. |
| One bad publish bricks the app | Per-doctype isolation; only the failing doctype falls back to cache; users always have some content. |
| Bundled seed grows large | Single-author small-volume v1; if it exceeds ~30 MB, bundle drops to "minimal" subset (exams + onboarding-critical), full content streams in. |
| `queries.mjs` ↔ `groq_queries.dart` drift in build pipeline | Spec self-review catches; first end-to-end seed run after schema change breaks loudly. Cost accepted as part of D6. |
| Author forgets to bump `schemaVersion` | Loud parse rejection on the next sync; Crashlytics non-fatal surfaces it; cached version stays so users don't see a regression. |

## 13. Next step

Once approved, invoke `superpowers:writing-plans` to produce the implementation plan at `docs/superpowers/plans/2026-05-16-sanity-content-fetcher.md`.

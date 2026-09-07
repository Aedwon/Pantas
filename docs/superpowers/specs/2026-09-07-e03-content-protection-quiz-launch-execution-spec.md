# E03 Content Protection + Quiz Launch Execution Spec

**Status:** E03 design/security contract, documentation only.

**Exact source baseline:** `ba536e73dbda455b994291eb551c2d6b0bd5286d`.

**Scheduling authority:** Astra Google Drive Master SSOT revision 54; repository reconciliation in `docs/superpowers/2026-09-07-development-ssot-checkpoint.md`.

**Implements at E03:** CP-T0 + QLP-0 only. This spec defines later implementation work; it does not authorize E04.

## 1. Goals

### Content protection

Reduce casual bulk extraction of Pantas proprietary lessons/questions from release packages and ordinary device filesystem copies while preserving first-launch offline study, existing Free/Pro behavior, sign-in behavior, content identity, and user progress.

This is extraction resistance, not DRM. A device owner can recover any client-available bootstrap decryption material, hook decryption/rendering, inspect memory, or capture displayed content. No implementation or release claim may state otherwise.

### Quiz loading

Shorten the wait before Today’s recommendation/session and remove repeated preparation after Start without changing the learning policy, selected question identity/order, persisted history, Free/Pro behavior, offline study, or UI intent.

The old standalone local spec named by Drive revision 54, `docs/superpowers/specs/2026-09-06-quiz-loading-performance-design.md`, is absent from exact E02 repository state. The Drive-54 requirements are carried into this document so implementation has one repository source.

## 2. Non-goals

- No mandatory online activation, account-bound content license, remote revocation, watermarking, anti-hooking, screenshot blocking, or claim that the APK cannot reveal the full corpus.
- No redesign of Free/Pro entitlement or billing. Current weekly commercial pin is PHP 149/week, but pricing implementation is outside this spec.
- No restoration of `assets/seed/v1.json` as a Flutter asset or runtime reader.
- No user-data database rekey, schema redesign, or reuse of `pantas_db_key`.
- No silent Sanity/backend redesign. Actual serving exposure is audited at E07 and changes require separate authorization.
- No change to quiz bucket rules, ordering preference, new-card cap, anti-repeat semantics, choice order, saved-session identity/order, or historical outcomes merely to improve speed.
- No performance claim before E09 physical-device measurement.

## 3. Exact CP-T0 source map and findings

### Governance and prior execution evidence

- `AGENTS.md`
- `SUBAGENTS.md`
- `CLAUDE.md`
- `docs/superpowers/plans/2026-09-05-release-e2e-implementation.md`
- Pantas issue `#21` current root-orchestrator checkpoint
- Astra Master SSOT revision 54

### Authoring/build/package path

- `assets/seed/content.db` — the only declared Flutter corpus asset at E02. It is generated and gitignored, so it is absent from the fresh E03 worktree; accepted release-lane evidence records the E02 shipping bytes separately. Runtime install/open code treats the generated payload as ordinary SQLite on this baseline.
- `assets/seed/v1.json` — populated tracked legacy/build corpus, 9,679,883 bytes in the exact E02 Git tree; not declared as a Flutter asset. Historical/build inventory only, not an active runtime source. The private-repository copy is a corpus-copy inventory item for CP-T0/CP-T4, not evidence of a shipped JSON reader or a public endpoint.
- `tools/build_dev_seed/build_dev_seed.dart` — explicitly superseded JSON generator path.
- `tools/build_content_export/build_content_export.dart` — build-time export; still reads historical `v1.json`, so E04 must reconcile this stale dependency without reviving the runtime JSON reader.
- `tools/build_content_seed/seed_writer.dart` — creates an ordinary SQLite `ContentDatabase`; when output is `assets/seed/content.db`, derives `contentSeedVersion` from the database SHA-256 prefix.
- `lib/core/content/content_seed_version.dart` — E02 value `eb3a9da425b80a51`.
- `pubspec.yaml` / `pubspec.lock` — sqlite3mc hook is present through `sqlite3`; `crypto` is only a development dependency on E02; no current direct runtime Ed25519/AEAD package is declared.

### Device install/open path

- `lib/core/content/bundle/seed_installer.dart` — writes bundled content bytes verbatim into Application Support.
- `lib/core/content/content_database_opener.dart` — opens installed `content.db` unkeyed. The package/install/read chain does not consult paywall/entitlement code; content protection must not introduce an entitlement gate. On Android, `AndroidManifest.xml` sets `android:allowBackup="false"`, and both `backup_rules.xml` and `data_extraction_rules.xml` exclude root/file/database/shared-preference/external domains from backup and device transfer. E04 must preserve and verify those exclusions.
- `lib/core/content/content_database.dart` — content schema version 8.
- `lib/core/content/content.dart` — content provider/bootstrap override.
- `lib/app/bootstrap.dart` — currently opens content database before `_installContentSeed`; protected bootstrap must reverse that dependency.

### Separate user-data boundary

- `lib/core/storage/data/database_opener.dart` — `pantas.db`, secure-storage key `pantas_db_key`, random 32-byte key, sqlite3mc SQLCipher-compatible settings including `legacy=4`.
- `lib/core/storage/storage.dart` — separate AppDatabase and ContentDatabase providers.

Content protection must use its own key and profile. The `legacy=4` user-database setting exists for that database’s compatibility and is not automatically inherited by new content encryption.

### Remote/update/export surface

- `lib/core/content/sanity/sanity_client.dart` — constructs unauthenticated Sanity CDN query URLs.
- `lib/core/content/sanity/sanity_config.dart` — compile-time project/dataset configuration.
- `lib/core/content/sanity/groq_queries.dart` — full/delta queries for corpus doctypes.
- `lib/core/content/sync/content_sync_coordinator.dart` — database sync coordinator exists, but E03 did not find a production construction site outside tests.

Consequently, E03 proves source exposure capability but does **not** prove that a release build actively uses it or that the dataset is public/private. E07 must inspect the actual production build/configuration and direct endpoint behavior before the remote protection boundary can close.

## 4. CP threat model and frozen protection boundary

### In scope attackers

- a casual user unzipping an APK/AAB-derived APK and looking for readable JSON/SQLite;
- a user copying ordinary Application Support files from an accessible device backup/debug environment;
- accidental corpus/key leakage through logs, crash output, support exports, CI artifacts, or a publicly queryable content endpoint.

### Residual attacker capability explicitly accepted for design, not release

A determined device owner can reverse-engineer the compiled client, recover the bootstrap key, hook native SQLite/decryption/rendering calls, dump process memory, instrument the app, or capture displayed material. Offline access means bootstrap decryption capability must exist client-side. Balanced protection raises extraction cost; it does not make client content irrecoverable.

Aedwon’s explicit release-risk acceptance is still required at E14. E03 does not grant that acceptance.

## 5. Frozen release package contract — format version 1

The release corpus remains a single SQLite content asset path to minimize reader churn, but the bytes at that path become protected. E04 must not add a raw fallback copy.

### Required Flutter assets

- `assets/seed/content.db` — SQLCipher-compatible sqlite3mc-protected content database under the versioned bootstrap content key.
- `assets/seed/content.manifest.json` — deterministic UTF-8 JSON manifest.
- `assets/seed/content.manifest.sig` — detached Ed25519 signature over the exact manifest bytes.

`assets/seed/v1.json` remains absent from Flutter assets.

The three protected release files are generated companions, not source-controlled secret-dependent payloads. `content.db`, `content.manifest.json`, and `content.manifest.sig` travel as one immutable protected-package artifact. Stable source contracts and public verification keys may be committed; generated package bytes must remain outside normal source tracking. From package materialization onward, provenance records source Git SHA, `sourceContentSha256`, `contentSeedVersion`, `payloadSha256`, manifest SHA-256, detached-signature SHA-256, key IDs, cipher profile, and content/reader schema versions.

### Manifest v1 exact fields

```json
{
  "formatVersion": 1,
  "applicationId": "com.aedwon.pantas",
  "releaseChannel": "prod",
  "payloadPath": "assets/seed/content.db",
  "sourceContentSha256": "<64 lowercase hex>",
  "payloadSha256": "<64 lowercase hex>",
  "contentSeedVersion": "<first 16 lowercase hex of sourceContentSha256>",
  "contentSchemaVersion": 8,
  "readerSchemaMin": 8,
  "readerSchemaMax": 8,
  "cipherProfile": "pantas-sqlite3mc-content-v1",
  "bootstrapKeyId": "content-bootstrap-v1",
  "signingKeyId": "content-signing-v1"
}
```

The manifest has no generated timestamp. Build tooling writes keys in the order above, UTF-8 encoded, with one trailing newline; the detached signature covers those exact bytes, including both `sourceContentSha256`/`contentSeedVersion` and `payloadSha256`. Tests must reject reordered/reformatted bytes unless they are re-signed. This avoids an implicit JSON-canonicalization contract.

`sourceContentSha256` is the SHA-256 of the approved plaintext SQLite seed bytes immediately before protection and is the stable logical corpus revision. `contentSeedVersion` is its first 16 lowercase hexadecimal characters. `payloadSha256` identifies the exact protected `content.db` bytes. SQLCipher/sqlite3mc protection normally includes randomized salt/encryption state, so two protected builds from identical approved plaintext may have different payload bytes and `payloadSha256` values while retaining the same `sourceContentSha256` and `contentSeedVersion`. E04 must not choose or fix a deterministic SQLCipher salt merely to make ciphertext reproducible.

Production Android application ID is grounded in `android/app/build.gradle.kts` as `com.aedwon.pantas`. Test/dev fixtures may use explicitly test-owned manifests; production packaging must use the production ID/channel above.

### Cryptographic responsibilities

- **Confidentiality/integrity of bundled SQLite pages:** sqlite3mc’s SQLCipher-compatible content profile with page integrity/HMAC enabled by the selected profile. E04 must verify the exact native build and settings before claiming support. Do not call the page mode an AEAD algorithm unless exact project evidence supports that wording.
- **Publisher authenticity:** Ed25519 detached manifest signature. The signing private key never ships. The public verification key may ship.
- **Logical revision binding:** signed `sourceContentSha256` identifies the approved plaintext seed revision and drives `contentSeedVersion`.
- **Whole-payload binding:** signed `payloadSha256` binds the exact encrypted `content.db` artifact bytes. A checksum alone is not authenticity; the signature is required. The signature binds both logical/source identity and exact protected payload identity.

Preferred maintained Dart implementation for Ed25519 verification/signing support is `cryptography` 2.9.0. E04 must confirm project dependency resolution/platform compatibility before adding it; failure is a design-stop condition, not permission for a custom cipher/signature implementation.

## 6. Frozen key contract

### Bootstrap key

- Key ID: `content-bootstrap-v1`.
- Size: 32 random bytes.
- Build secret input: `PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64`.
- Production client compile-time input: `PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64`.
- Must not be committed to source, written to ordinary preferences, logged, attached to CI, or described as unrecoverable.
- Its presence in the compiled client is an acknowledged recoverability risk. Obfuscation may add friction but earns no security claim.

### Publisher signing key

- Key ID: `content-signing-v1`.
- Algorithm: Ed25519.
- Private build secret input: `PANTAS_CONTENT_SIGNING_PRIVATE_KEY_V1_B64`.
- Public verification key is committed/generated in a reviewable client keyring mapped to `content-signing-v1`.
- Signing private material must never be packaged or logged.

### Per-install content key

- Secure-storage identifier: `pantas_content_db_key_v1`.
- Size: 32 random bytes from `Random.secure`.
- Generated on device independently of `pantas_db_key`.
- Used only for installed protected `content.db`.
- Missing key with an existing encrypted database triggers recovery logic; it never triggers an unkeyed/plaintext fallback.

## 7. Frozen content cipher profile contract

Profile ID: `pantas-sqlite3mc-content-v1`.

E04 must centralize the native setup in one helper and use the same profile for package verification, rekey, installed open, tests, and tools. The intended profile is SQLCipher-compatible sqlite3mc with a 32-byte binary key and integrity/HMAC enabled. The exact PRAGMA sequence and native behavior must be proven against the project’s resolved sqlite3/sqlite3mc build before implementation proceeds.

Do **not** copy `legacy=4` from the user database merely because it already exists. The content database is a new protection format; compatibility settings must follow the exact verified content profile.

### CP-T0 dependent blocker: native rekey proof

Before CP-T1/CP-T2 implementation relies on rekey, E04 must create a focused test/tool that proves on the pinned build that it can:

1. create/open an ordinary test SQLite database;
2. encrypt it using the planned sqlite3mc key/rekey primitive without a plaintext secondary output;
3. reopen only with the correct bootstrap key;
4. reject an unkeyed/wrong-key ordinary SQLite read;
5. rekey the encrypted database to an independent per-install key;
6. reopen only with the new key;
7. execute the required operation in a journal mode that does not leave a plaintext WAL/journal copy;
8. inspect temporary/journal/WAL/SHM artifacts.

If the exact project build cannot do this safely, the E04 protected install path is **blocked** pending a new design. No plaintext staging fallback is authorized.

## 8. Frozen protected build/install interfaces

E04 may adjust names only through a documented spec amendment; cross-task implementors should target these contracts.

```dart
abstract interface class ContentKeyStore {
  Future<Uint8List?> read();
  Future<Uint8List> readOrCreate();
  Future<void> delete();
}

class VerifiedContentPackage {
  final ContentPackageManifest manifest;
  final Uint8List payloadBytes;
}

abstract interface class ContentPackageVerifier {
  Future<VerifiedContentPackage> verifyBundled();
}

sealed class ProtectedContentInstallResult {
  const ProtectedContentInstallResult();
}

Future<ProtectedContentInstallResult> ensureProtectedContentInstalled({
  required AppPreferencesRepository preferences,
  required ContentPackageVerifier verifier,
  required ContentKeyStore contentKeyStore,
});

Future<ContentDatabase> openProtectedContentDatabase({
  required ContentKeyStore contentKeyStore,
});
```

Test seams may inject asset bytes and destination files in the same spirit as the current `SeedInstaller` seams, but production defaults must load the exact three bundled assets and Application Support destination.

`bootstrapContentOverrides` must ultimately open through `openProtectedContentDatabase`. `lib/app/bootstrap.dart` must ensure package verification/install/migration **before** final content database open. A storage-only temporary provider scope may be used to access `AppPreferencesRepository`, but the final app must retain exactly one live user `AppDatabase` and one protected `ContentDatabase`.

## 9. Protected installation and atomic update state machine

### Fresh install

1. Load manifest/signature/encrypted payload.
2. Verify Ed25519 signature before trusting manifest-controlled fields.
3. Validate `formatVersion`, `applicationId`, release channel, schema compatibility, key IDs, and cipher profile.
4. Hash encrypted payload and require signed `payloadSha256`; require signed `sourceContentSha256` to be a full lowercase SHA-256 and `contentSeedVersion` to equal the first 16 lowercase hexadecimal characters of `sourceContentSha256`. Runtime package verification authenticates the publisher-signed logical revision; build-time package tests independently prove the source digest was computed from the approved plaintext seed before protection.
5. Copy encrypted payload to same-directory pending path `content.db.pending`. This copy remains encrypted under the bootstrap key.
6. Open/validate pending database with bootstrap key and exact content profile.
7. Read/create `pantas_content_db_key_v1`.
8. Rekey pending database directly to the per-install key through the verified native flow; no plaintext on-disk staging.
9. Close/reopen pending with per-install key and validate schema and required corpus invariants.
10. Promote atomically to `content.db`; update installed seed version only after successful promotion.

### Existing valid encrypted install

If installed protected content, secure key, manifest/version state, and schema are valid and current, open it directly. Do not rewrite/rekey on every launch.

### E02 legacy plaintext migration

The first supported plaintext migration is restricted to the exact accepted E02 shipping corpus: tracked `contentSeedVersion` `eb3a9da425b80a51` and accepted generated release-lane SHA-256 `eb3a9da425b80a51331cce74694ef014c3372392194bacbd60ba145db5ea2a45`. The generated `content.db` is gitignored and was not materialized/rehashed in the fresh E03 planning worktree, so this digest is carried from durable accepted E02/release evidence, not claimed as a new E03 hash. E04 must freshly obtain or regenerate and verify the approved payload before migration fixtures use it. The migration must preserve the source until an independently keyed destination has been validated.

A different plaintext installed database is not silently treated as the E02 seed. It may represent a newer/unproven content state. Surface an honest recoverable/update-required state and stop that migration path for evidence rather than replacing it with the bundled corpus.

### Key loss

If `pantas_content_db_key_v1` is missing but the installed database is encrypted, do not attempt plaintext open. Rebuild from the verified offline bundle when doing so cannot discard a known newer content revision. Preserve `pantas.db` and user progress. If the installed content revision is newer than the available bundle and cannot be reconstructed offline, report a recoverable content-refresh requirement instead of silently substituting older content.

### Interrupted update

Keep the last valid encrypted `content.db` until pending content passes signature, hash, schema, keyed-open, and corpus validation. Failure removes only incomplete protected pending state. No failure path opens plaintext or resets `pantas.db`. A previous valid protected version remains usable.

Filesystem deletion on flash storage is best-effort and is not forensic erasure.

## 10. CP-T1 through CP-T5 acceptance inherited from Drive 54

### CP-T1 packaging

- release package has no raw proprietary JSON or unprotected SQLite corpus;
- ordinary unzip/strings/plain SQLite cannot reveal the known protected fixture;
- correct bootstrap key opens protected fixture; wrong key fails;
- changed payload, changed manifest, or untrusted signature fails;
- no signing private key/server credential ships;
- recoverable bootstrap key is documented, not hidden.

### CP-T2 install/open

- first launch remains offline-capable;
- installed database rejects ordinary unkeyed/wrong-key reads;
- study/practice/mock reads preserve exact content IDs/semantics;
- process-death reopen works;
- journals/WAL/temp files are inspected;
- user database encryption/access unchanged.

### CP-T3 migration/recovery

Test E02 plaintext migration, insufficient disk, killed process at each boundary, missing content key, corrupt package, incompatible schema, replay/downgrade, interrupted update, and key rotation/version overlap. User progress and content references must survive. No plaintext fallback.

### CP-T4 leakage/serving path

Inspect logs, crash fixtures, analytics, support exports, CI artifacts, release output, Sanity/storage/CMS direct access, configured authorization/App Check where actually applicable, request bounds, and observable abuse signals. Do not credit App Check for bytes bundled offline.

### CP-T5 two phases

- E09: source/device path proof on the combined encrypted candidate.
- E13: exact signed AAB/APK extraction and secret/provenance proof.

Security closes only at E14 after explicit residual-risk acceptance.

## 11. Exact QLP-0 source map and verified findings

- `lib/features/quiz/application/quiz_providers.dart` — application wiring shared by Quiz and Home entry points.
- `lib/features/quiz/domain/models/quiz_preferences.dart` — session lengths 5/10/20/all-due; default 10; new-card cap default 10.
- `lib/features/quiz/domain/models/quiz_ordering.dart` — blocked/interleaved-tail/fully-mixed; default interleaved-tail; legacy true/false storage migration.
- `lib/features/quiz/data/repos/quiz_preferences_repository.dart` — authoritative stored preference keys.
- `lib/features/quiz/domain/use_cases/build_today_plan.dart` — one composition result currently carries fully hydrated `Question` objects and due/weak/fresh counts.
- `lib/features/quiz/domain/use_cases/start_today_session.dart` — persists the selected ordered IDs; fallback path loads all questions by exam/topic.
- `lib/core/storage/data/repos/content_repository.dart` — current full hydration and per-question choice/exam queries.
- `lib/features/quiz/data/repos/quiz_session_repository.dart` — persisted session identity/order and active/complete/quit fields.
- `lib/features/quiz/domain/use_cases/resume_session.dart` — sequential saved-ID hydration.
- `lib/features/quiz/domain/use_cases/restart_session.dart` — preserves saved question IDs/origin/topic but sequentially hydrates.
- `lib/features/quiz/domain/use_cases/complete_quiz.dart` and `lib/features/quiz/presentation/quiz_controller.dart` — terminal-session closure gap described above.
- Existing focused tests under `test/features/quiz/{application,data,domain,presentation}/`, `test/features/quiz/integration_test.dart`, `test/features/quiz/passage_regression_test.dart`, and release E2E quiz journey provide starting regression surfaces.

Verified QLP defects at E02:

1. selection can fully hydrate a large question bank before picking;
2. each hydrated question independently loads choices and exam membership;
3. resume/restart hydrate stored IDs sequentially;
4. Start can repeat work that a recommendation/preview already performed;
5. response timing currently begins when controller sets `questionShownAt`, not when all required passage/diagram content is demonstrably answerable;
6. terminal persisted quiz session is not marked complete on the normal completion path.

These are current-source findings, not device timing claims.

## 12. Frozen QLP learning-policy decisions

- Stored `QuizPreferencesRepository.read()` is authoritative for session length, ordering, and new-card cap.
- `QuizOrdering.interleavedTail` remains default. Legacy `true` maps to interleaved-tail; legacy `false` maps to blocked. No storage-history rewrite is required for optimization.
- Existing due/weakness/fresh bucket accounting and `BuildTodayPlan` composition semantics remain authoritative.
- Existing new-card cap semantics remain unchanged.
- Existing selected question identity/order and deterministic choice ordering remain unchanged.
- Resume uses the persisted session ID, origin, topic/subtopic/lesson metadata, current index, and saved question-ID order. Resume never creates a new Today/quick session.
- Restart/Retry preserves original mode/scope and, where current behavior is restart-from-same-set, the original question IDs/order. Performance work must not reinterpret Retry as a fresh recommendation.
- Historical attempt/review outcomes are not rewritten, reattributed, or dropped to improve speed.
- If E05 discovers an ambiguous historical owner/outcome migration that affects selection, stop that dependent path for a policy ruling; do not invent a migration.

## 13. QLP-1 frozen metadata/hydration contracts

Selection requires lightweight identity/scheduling fields, not stems, explanations, rationales, choices, or passage bodies.

```dart
class QuestionSelectionRow {
  final QuestionId id;
  final int version;
  final TopicId topicId;
  final LessonId? lessonId;
  final PassageId? passageId;
  final bool hasFigure;
}

abstract interface class QuizContentReader {
  Future<List<QuestionSelectionRow>> selectionRowsByExam(ExamId examId);
  Future<List<QuestionSelectionRow>> selectionRowsByTopic(TopicId topicId);
  Future<Map<QuestionId, Question>> hydrateSelectedQuestions(
    List<QuestionId> ids,
  );
}
```

The actual selector may adapt `QuestionSelectionRow` into a lightweight selection model, but it must not load stem/explanation/choice/passage-body payloads until after IDs are selected.

`hydrateSelectedQuestions` must batch question rows, active choices, exam memberships, and distinct passages in bounded SQL chunks, then reconstruct the final `Question` objects in the exact caller-supplied ID order. Choice ordering remains the existing deterministic `orderChoicesFor(questionId, ...)` behavior.

E05 must add indexes covering the verified topic/active, question/active/order, question-exam membership, and other query-plan predicates actually used. Index creation must be present for both new schema creation and upgrades from schema 8. The schema version increment is owned by E05 only after E04 finishes shared content-schema work.

## 14. QLP-2 frozen prepared-launch contracts

Prepared recommendation data is immutable and in-memory only. It is not a second persistent source of truth.

```dart
class QuizPreparationStamp {
  final String contentRevision;
  final DateTime localDay;
  final QuizPreferences preferences;
  final int sessionStateRevision;
}

class PreparedTodaySession {
  final TodaySessionPlan plan;
  final List<QuestionId> orderedQuestionIds;
  final QuizPreparationStamp stamp;
  final DateTime preparedAt;
}

abstract interface class TodayQuizPreparer {
  Future<PreparedTodaySession> prepare({
    required String userId,
    required ExamId examId,
    TopicId? topicId,
  });
}

abstract interface class QuizLaunchCoordinator {
  Future<StartTodaySessionResult> launchPreparedToday({
    required String userId,
    required ExamId examId,
    required PreparedTodaySession prepared,
  });

  Future<QuizSession?> resumeToday({
    required String userId,
    required ExamId examId,
  });
}
```

`sessionStateRevision` is a logical freshness token, not permission for a broad persisted-history migration. E06 should derive it from a minimal authoritative session/review mutation signal. If no cheap existing signal can cover sync-driven mutations correctly, add one narrowly and increment it only where authoritative quiz/review state changes. Do not hash or decode full history just to compute freshness.

Both Quiz and Home/Study-first nudge Start paths consume the same `PreparedTodaySession`. Preview/recommendation creates no persisted `quizSessions` row. `launchPreparedToday` revalidates freshness and persists exactly one session. Rapid taps/rebuilds must coalesce to one launch owner.

## 15. QLP freshness, cancellation, and memory contract

A prepared Today result is stale when any of these changes:

- installed protected content revision/manifest version;
- local calendar day relevant to Today selection;
- exam/topic scope;
- session length, ordering, or new-card cap;
- authoritative session/review mutation revision;
- an active-session change that makes Resume/Start semantics different.

Prepared content is discarded on stale detection and recomputed. It does not survive process death. Background/foreground return must revalidate before launch. Content upgrade invalidates immediately.

Cancellation semantics:

- leaving before session persistence cancels preparation/launch and must not create a late session or navigate later;
- after the single session commit succeeds, leaving the route does not delete it; it remains one resumable session;
- a failed replacement preserves the prior resumable session;
- long all-due preparation may be cancelled, but never silently shortened.

Memory must remain bounded to the prepared selected set plus bounded query chunks; no unbounded full-bank object cache.

## 16. QLP-3 readiness and timing contract

A question becomes answerable only when all required presentation content is ready:

- stem;
- active choices;
- required passage, if any;
- required figure/diagram payload and its render-ready state, if any.

Response timing starts at the first complete answerable presentation, not at database preparation start, route creation, or a partial frame. Rebuilds do not reset the timer. Optional telemetry, sync, average-duration panels, or unrelated UI must not delay readiness.

Next on an already prepared session does not perform another selection/database hydration cycle. Retry preserves the source intent and does not create duplicate persistence. Empty pools remain distinct from load errors.

## 17. Terminal-session completion decision

E02 has a concrete correctness gap: `QuizSessionRepository.complete` exists but the normal terminal controller path does not call it. E06 must make attempt persistence and persisted-session terminalization part of one completion transaction/owner.

Frozen outcome:

- once the final answer has been accepted and the attempt is successfully persisted, the corresponding persisted quiz session is marked `completedAt`;
- a completed session must no longer be returned by `activeFor`;
- failure before the completion commit must not falsely mark the session complete;
- retry after completion starts according to the explicit Retry/restart intent, not by resuming the terminal row;
- attempt ID/session ID relationships already used by debrief/provenance are preserved.

Implementation may move this responsibility into `CompleteQuiz` or a new completion coordinator, but there must be one transactional application-layer owner and regression tests.

## 18. QLP-5 proposed performance acceptance targets

These values are inherited from Drive revision 54 and remain **proposed review targets** until E09 measurement:

- Start/Retry feedback: ≤100 ms.
- First recommendation p95: ≤1,000 ms including scope resolution after databases are available.
- Unchanged recommendation: next usable frame with no preparation.
- Warm Start p95: ≤500 ms.
- Cold daily route after bootstrap p95: ≤1,500 ms.
- Normal 5/10/20-question Resume p95: ≤1,000 ms.
- Prepared Next p95: ≤100 ms.
- On 60 Hz hardware, p95 build and raster durations target ≤16.7 ms; missed frames must be reported.

## 19. QLP-5 measurement method

Use a physical lower-end Android device, preferably 3–4 GB RAM and 60 Hz, plus a mainstream comparison device. Record exact hardware, OS, build mode, source SHA, content manifest/version, and history fixture.

For ordinary scenarios collect at least 30 observations; report median, p95, and maximum, separating cold and warm runs. Instrument scope resolution, metadata read, history decode/query, selection, selected hydration, session persistence, route transition, first complete-answerable frame, query count, and memory. Diagnostics stay local and contain no question bodies, correct answers, or personal identifiers.

Exercise UPCAT, CSE Professional, custom tracks, empty/mixed/substantial history, 5/10/20/all-due, long 75/100-question attempt-like fixtures where applicable, plain/math/passage/diagram first questions, offline use, background return, day rollover, and content upgrade. Measure installation/bootstrap separately and also report launch-to-answerable total so work cannot be hidden outside the timer.

## 20. E03 unresolved dependencies / blockers

### CP-T0 dependent blocker

**Exact-build sqlite3mc rekey/profile support is unproven.** Upstream capability does not prove this Flutter hook build. E04 must prove it before code depends on the design. Failure blocks CP-T1/CP-T2 and requires a new no-plaintext-staging design.

### CP-T4 open dependency

**Actual production Sanity/content-serving exposure is unproven.** Source has an unauthenticated CDN client, but E03 did not evidence production construction/configuration. E07 must inspect release configuration/direct access.

### QLP-0 resolved dependency

**Ordering preference authority is resolved:** `QuizPreferencesRepository` + `QuizOrdering.fromStorage` are controlling; preserve them.

### QLP-0 implementation dependency

**Terminal session closure is not resolved in E02 source:** E06 must implement the frozen completion contract above before QLP launch work can be called complete.

### QLP-0 conditional policy blocker

If E05/E06 discovers historical review/outcome ownership records whose semantics cannot be preserved by the frozen metadata model, stop only that dependent selection path for a policy ruling. No history rewrite is pre-authorized.

## 21. Verification obligations for later stages

At the stage that changes code, use test-driven implementation and record exact RED/GREEN evidence. Minimum program-level commands include focused tests, `flutter test`, `flutter analyze`, changed-Dart formatting checks, `git diff --check`, `dart run tool/check_no_ai_attribution.dart`, project layering/content validators, and any build-runner regeneration required by schema/codegen changes.

CP-T5 adds physical-device and artifact-specific evidence. QLP-5 requires real lower-end device measurements; unit tests alone cannot close performance. E10 adds three complete isolated Release E2E passes.

## 22. E03 exit

This document freezes the CP-T0/QLP-0 contracts on exact E02 baseline `ba536e73dbda455b994291eb551c2d6b0bd5286d`. E03 ends after docs-only verification/commit/push and durable handback. It does not create or dispatch an E04 worker.

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

The old standalone local spec named by Drive revision 54, `docs/superpowers/specs/2026-09-06-quiz-loading-performance-design.md`, is absent from exact E02 repository state. Complete September 6 text survives in relay result issues `Aedwon/chatgpt-terminal-relay#6042`, `#6044`, `#6045`, `#6046`, and `#6047` in line order. Those relay comments prove the complete textual sequence but not the byte-for-byte identity of the original untracked file through their wrapper/escaping layer, so this correction lane does not fabricate a reconstructed source file. The September 6 requirements are reconciled into this governing document rather than replaced.

## 2. Non-goals

- No mandatory online activation, account-bound content license, remote revocation, watermarking, anti-hooking, screenshot blocking, or claim that the APK cannot reveal the full corpus.
- No redesign of Free/Pro entitlement or billing. Current planning references conflict on pricing; no price is re-frozen here and no Play/RevenueCat/store-pricing mutation is authorized.
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

## 5. Frozen release package contract — format version 2 (September 8 successor)

The September 7 **manifest v1** contract remains historical evidence for the recovery-r2 partial implementation. It is not the production-accepted wire format. Adding signed chronology changes the exact signed manifest bytes and required fields, so the September 8 successor is **manifest v2**. Production E04 must migrate the builder, verifier, fixtures, and release preflight to v2; a v1 package may be retained only as an explicit historical/rejection fixture and must not pass production package acceptance.

The release corpus remains a single SQLite content asset path to minimize reader churn, but the bytes at that path become protected. E04 must not add a raw fallback copy.

### Required Flutter assets

- `assets/seed/content.db` — SQLCipher-compatible sqlite3mc-protected content database under the versioned bootstrap content key.
- `assets/seed/content.manifest.json` — deterministic UTF-8 JSON manifest.
- `assets/seed/content.manifest.sig` — detached Ed25519 signature over the exact manifest bytes.

`assets/seed/v1.json` remains absent from Flutter assets.

The three protected release files are generated companions, not source-controlled secret-dependent payloads. `content.db`, `content.manifest.json`, and `content.manifest.sig` travel as one immutable protected-package artifact. Stable source contracts and public verification keys may be committed; generated package bytes must remain outside normal source tracking. From package materialization onward, provenance records source Git SHA, `sourceContentSha256`, `contentSeedVersion`, `payloadSha256`, manifest SHA-256, detached-signature SHA-256, key IDs, cipher profile, and content/reader schema versions.

### Manifest v2 exact fields

```json
{
  "formatVersion": 2,
  "applicationId": "com.aedwon.pantas",
  "releaseChannel": "prod",
  "releaseSequence": 1,
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

### September 8 amendment: package chronology is signed, not hash-derived

`releaseSequence` is required in signed **manifest v2**. It is a positive integer that increases monotonically for every publisher-authorized protected package. A publisher-authorized rollback of logical content is emitted as a new package with a higher `releaseSequence`; accepting a lower sequence is never the rollback mechanism. `sourceContentSha256`, `contentSeedVersion`, `payloadSha256`, manifest SHA-256, and detached-signature SHA-256 remain identity/provenance fields only. Implementations must never compare hashes lexically or numerically to decide which package is newer.

The recovery-r2 E04.2 implementation predates this v2 amendment and remains reviewed partial work, not a production-accepted manifest implementation. E04 must migrate the builder/verifier/release checks to `formatVersion = 2`, add and sign `releaseSequence`, reject v1 on the production acceptance path, and preserve only explicit v1 historical/rejection fixtures where useful.

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

### September 8 amendment: versioned trust-key lookup and rotation

Signing and bootstrap identifiers remain versioned IDs (`content-signing-v1`, `content-bootstrap-v1` for the current partial implementation), but production verification uses key-ID lookup metadata rather than one permanently hard-coded key. Each accepted key entry declares an inclusive `minReleaseSequence` and optional inclusive `maxReleaseSequence`. Overlap is permitted during planned rotation so two public signing keys or two authorized bootstrap-key IDs can be valid for the same bounded sequence window. Once a key is retired for a sequence, a manifest naming it fails closed even if its bytes/signature would otherwise verify. Unknown key IDs fail closed.

Public Ed25519 verification keys may coexist in the client trust keyring. Signing private keys and bootstrap secret material must never enter repository docs, issues, chat, ordinary preferences, logs, or artifacts. This contract does not invent production key bytes. The production signing trust keyring is currently empty, so E04.2 remains reviewed partial work until an explicitly authorized exact 32-byte Ed25519 public verification key corresponding to the release signing process is supplied through the authorized release/security lane. Safe fixture-key installer/migration work may proceed after these contracts are accepted; production protected-package acceptance may not.

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

### September 8 amendment: persistent accepted-package state and promotion recovery

The accepted-package record and any in-flight promotion intent are **device-local protected-content installation metadata**. Store them alongside the protected content installation in Application Support (or an equivalent content-owned device-local store), not in `pantas.db`, account-scoped `AppPreferencesRepository`, synced user state, or any account-reset/deletion payload. Sign-out, account switch, user reset, and account deletion must not clear anti-replay chronology. Only removal of the app's local data or an explicit protected-content installation-state reset may clear it, and such a reset returns the device to the no-accepted-package state rather than silently authorizing an older package.

Runtime acceptance persists a non-secret accepted-package state containing the accepted `releaseSequence` plus the exact signed/package identity needed to distinguish replays and forks: `sourceContentSha256`, `contentSeedVersion`, `payloadSha256`, manifest SHA-256, detached-signature SHA-256, `signingKeyId`, `bootstrapKeyId`, `cipherProfile`, `contentSchemaVersion`, `readerSchemaMin`, and `readerSchemaMax`. With no accepted state, a fully verified compatible package with a positive sequence may become the first accepted package. With accepted state present:

- candidate sequence lower than accepted: reject as downgrade/replay;
- candidate sequence equal to accepted and exact package identity equal: idempotent reopen/no-op is allowed;
- candidate sequence equal to accepted but any bound package identity differs: reject as same-sequence fork/replay;
- candidate sequence higher than accepted: continue only after signature, key-window, payload/source identity, schema, keyed-open, and corpus validation pass.

Promotion is two-phase and recoverable across filesystem/database crash boundaries. Before file replacement, persist a promotion intent binding the candidate identity/sequence and, when one exists, the complete previous accepted identity. Preserve the previous installed encrypted `content.db` in `content.db.previous` (or an equivalent same-directory previous-valid slot) together with the previous accepted-state metadata until the new active file and accepted state are both finalized. Required recovery behavior is:

1. crash before candidate validation or promotion intent: an existing previous active package remains authoritative; on first install there is still no accepted package; incomplete pending state may be deleted;
2. crash after promotion intent but before active-file replacement: the same rule holds; startup may resume or discard the candidate only after revalidation against the exact intent;
3. crash after moving active to previous and/or pending to active but before accepted-state finalization: startup validates the candidate against the persisted intent. If valid, finalize candidate + accepted state. If invalid and a previous accepted package exists, atomically restore its encrypted database and accepted-state metadata. If this was first install, remove/unpublish the unaccepted active candidate and return to no accepted package;
4. crash after accepted-state finalization but before cleanup: the new accepted identity is authoritative; the previous-valid slot and stale intent are cleanup-only and may be removed only after successful reopen.

At no boundary may failure delete both valid copies when a previous accepted package exists, mark an unvalidated first-install candidate accepted, open plaintext, reset `pantas.db`, or infer chronology from a digest.

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

## 12. Frozen QLP learning-policy authority, amended September 8

The September 7 statement that `QuizPreferencesRepository.read()` is authoritative for ordering is superseded. It remains authoritative for quiz-owned session length and new-card-cap data where that repository is still the current source, but Today ordering is owned by Settings.

- `settings.session_ordering`, exposed as Settings `SessionOrdering`, is the authoritative ordering preference used by Today recommendation/preparation and Start.
- The semantic adapter maps `SessionOrdering.blocked`, `interleavedTail`, and `fullyMixed` to the corresponding quiz-domain cases explicitly. It must not compare persisted storage strings because Settings uses camel-case enum names while the quiz compatibility enum uses snake-case values for two cases.
- `quiz_today_interleaved` is compatibility/migration input only when no current Settings ordering state exists. If legacy and current Settings values disagree, current Settings wins.
- The shipped legacy boolean mapping is frozen for compatibility: `true -> interleavedTail`; `false -> blocked`. This mapping never overrides explicit current Settings state.
- The three ordering behaviors are distinct and already decided: `blocked` keeps the selected topic; a 10-question `interleavedTail` session uses 7 from the selected topic and 3 from other topics' due cards; `fullyMixed` permits cross-topic selection while prohibiting two consecutive questions from the same topic. Only deterministic scaling of the approved 7/3 rule to other requested lengths remains a product decision.
- The new-card cap is one shared local-day allowance across all quiz surfaces combined for the active exam pool. Topic allocation consumes that same remaining allowance; it must never multiply the cap by the number of participating topics.
- A regression must start from a real Settings write, then run Today recommendation/preparation and Start, proving the same ordering reaches the persisted launched session. It must deliberately set a disagreeing `quiz_today_interleaved` value and prove Settings wins. Constructing `QuizPreferences` directly does not satisfy this gate.
- Existing selected question identity/order, deterministic choice ordering, Resume identity/order, Retry/restart intent, and historical attempt/review records are preserved unless an explicit historical-repair decision below applies.
- Mechanical batching/performance work must not freeze a documented selector bug as intended learning behavior.

The default remains `interleavedTail` only for genuinely absent current Settings state; defaulting must not overwrite or hide a stored explicit Settings choice.

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

### September 8 amendment: custom-track metadata/count path

E05 owns removal of full-question hydration performed only to resolve custom-track scope or question counts. Custom-track recommendation/count preparation must use lightweight metadata/count queries and preserve exact current custom-track exam/topic membership and exclusion semantics. The regression must prove that stems, explanations, choices, rationales, and passage bodies are not hydrated merely to determine scope/counts, while eligible IDs/counts match the pre-optimization scope fixture.

### September 8 amendment: E04/E05 schema transition

E04 manifest validation and protected-package reading must not make an E05 schema increment impossible. Before E05 increments `contentSchemaVersion` for indexes or selection metadata, E04 and E05 jointly freeze compatible `contentSchemaVersion`, `readerSchemaMin`, and `readerSchemaMax` values for the new package. The reader rejects packages outside its declared bounds. A fresh database at the E05 schema and an upgrade from the accepted E04 schema must produce equivalent tables/indexes and query semantics. E05 must not increment schema until fresh-versus-upgraded equivalence and package-reader compatibility are tested. Any package regenerated for a new schema is a new protected package with a higher `releaseSequence`.

## 14. QLP-2 frozen prepared-launch contracts, amended September 8

Prepared recommendation data is immutable and in-memory only. The preparation stamp covers the authoritative user-data lifetime, scope, ordering, topic exclusions, history/session state, content revision, local day, and the next time eligibility can change within that day. A day stamp alone is insufficient.

```dart
class QuizPreparationStamp {
  final String contentRevision;
  final DateTime localDay;
  final DateTime? nextDueExpiry;
  final String accountLifetimeToken;
  final String scopeToken;
  final String topicExclusionToken;
  final SessionOrdering ordering;
  final QuizPreferences nonOrderingPreferences;
  final int historyRevision;
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

The token names are conceptual contract names; E06 may adapt them to existing project types only if the same invalidation coverage is proven. `nextDueExpiry` is the earliest known future instant at which any relevant review/question can cross a due boundary for the prepared scope; it may be null when no such boundary exists. Revalidation compares the current clock against it, including after background return.

Quiz and Home/Study-first nudge Start paths consume the same `PreparedTodaySession`. Preview/recommendation creates no persisted session. Start revalidates the full stamp and persists exactly one session through one owner. Rapid taps/rebuilds coalesce. Late async preparation results carry their originating generation and may not overwrite newer preparation.

## 15. QLP freshness, cancellation, Resume, and memory contract, amended September 8

An unpersisted prepared Today result is stale and must be discarded/recomputed or fail revalidation before Start when any of these changes:

- authoritative Settings `sessionOrdering`;
- session length or new-card cap;
- exam, topic, custom-track scope, or topic exclusions;
- relevant attempt/review/history state, including sync/imported history;
- session completion, discard, or another active-session change affecting Start/Resume semantics;
- installed protected content revision or compatible content schema/package identity;
- account switch or any reset/deletion event that begins a new user-data lifetime;
- local calendar day;
- the clock reaches/passes `nextDueExpiry`, including a due boundary later within the same day.

Preparation does not survive process death. Background/foreground return revalidates day, lifetime, state revisions, and `nextDueExpiry`. Late async results from an older generation cannot replace newer preparation even if they complete last.

An already persisted active quiz session is stable: freshness changes whether a new Today session may be prepared/launched, but never silently reselects/reorders an active session. Resume uses its saved IDs/order.

**Forward Resume correctness is not optional product policy.** Each answer must be durably persisted before advancing far enough that a crash can lose its outcome. Resume must reconstruct the saved current index and already-answered outcome state so a question the student already answered does not reappear as unanswered. If the current persisted schema cannot represent that exactly for newly created sessions, E06 must add the smallest reviewed persistence needed to make it exact. The only remaining decision is how to treat historical sessions whose old rows genuinely lack enough data for exact reconstruction.

Cancellation remains pre/post-persistence: leaving before the single session commit cancels late creation/navigation; after commit, leaving does not delete the one resumable session. A failed replacement preserves the prior valid session. Long all-due preparation may be cancelled but never silently shortened. Memory stays bounded to selected data plus bounded query chunks.

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

## 20. E03/E04 recovery dependencies and blockers, amended September 8

### Production key gate

E04.2 is reviewed partial work while the production signing trust keyring is empty. Production acceptance remains blocked on an explicitly authorized exact 32-byte Ed25519 public verification key corresponding to the release signing-key process. Never request, expose, or record the signing private key or bootstrap secret. Safe fixture-key installer/migration work may proceed after this contract correction is accepted.

### E04 analyzer debt

September 8 review distinguishes 22 information-level findings introduced by E04 from one unrelated older bookmarks finding. E04 acceptance must close or explicitly disposition the 22 E04 findings. They may not be relabeled as globally pre-existing merely because they predate a later worker parent. The older bookmarks finding is reported separately.

### Other dependencies

Actual production Sanity/content-serving exposure remains an E07 evidence question. E06 must close terminal persisted-session completion. E05/E06 must not silently decide the unresolved non-10/all-due 7/3 scaling rule, fallback accounting, historical owner/outcome migration, historical Resume repair, or commercial-pricing item below. Distinct ordering semantics, the shipped legacy boolean mapping, and the shared local-day new-card allowance are already frozen above. No physical Android interruption/migration/performance evidence is claimed by this correction; E09 and later device gates remain required.

## 21. Verification obligations for later stages

At the stage that changes code, use test-driven implementation and record exact RED/GREEN evidence. Minimum program-level commands include focused tests, `flutter test`, `flutter analyze`, changed-Dart formatting checks, `git diff --check`, `dart run tool/check_no_ai_attribution.dart`, project layering/content validators, and any build-runner regeneration required by schema/codegen changes.

CP-T5 adds physical-device and artifact-specific evidence. QLP-5 requires real lower-end device measurements; unit tests alone cannot close performance. E10 adds three complete isolated Release E2E passes.

## 22. September 8 contract-correction exit

September 7 planning history remains historical rationale except where this document explicitly marks a September 8 amendment. The recovery-r2 implementation head at the start of this correction is `3c686756ac31748f4acad0291e464fc45b1266cb`; E04.2 is reviewed partial work and not production-accepted.

This correction lane is documentation-only. It does not resume E04.3/E04.4, E05, or E06, mutate implementation files, build protected package bytes/AABs, or mutate Play. Its reviewed diff is intentionally left uncommitted and unpushed for root-orchestrator review/publication.

## 23. September 8 release/provenance acceptance contract

E10/E11 produce one non-secret accepted-package record binding exact source Git SHA, `formatVersion` (v2 for the September 8 successor), `releaseSequence`, `sourceContentSha256`, `contentSeedVersion`, `payloadSha256`, manifest SHA-256, detached-signature SHA-256, `signingKeyId`, `bootstrapKeyId`, `cipherProfile`, `contentSchemaVersion`, `readerSchemaMin`, and `readerSchemaMax`. E11 accepts that exact source/package pair, not merely any package that passes signature verification.

E12 preflight verifies the actual clean source and exact protected-package files against this accepted record in addition to signature/key-window/schema checks. E12 consumes the exact accepted E10/E11 package and must not silently regenerate randomized ciphertext. A negative test supplies a different internally valid package signed by a currently trusted key and proves E12 rejects it because it is not the accepted package.

E08 explicitly owns protected-package Release E2E runner migration: remove the obsolete ciphertext-SHA-prefix assumption, supply the bootstrap define through the existing secret-safe build path, preserve exact source/package provenance and content-integrity checks, and do not broadly relax production-diff allowlists.

## 24. DECISION REQUIRED product-policy register

Only the items below remain non-normative until Aedwon chooses. The following boundaries are already resolved and are **not** product decisions for E05/E06: the three ordering modes are distinct; 10-question `interleavedTail` is 7 selected-topic + 3 other-topic due cards; `fullyMixed` forbids adjacent same-topic questions; legacy `true -> interleavedTail` and `false -> blocked` applies only when current Settings ordering is absent; and the new-card cap is one shared local-day allowance across all quiz surfaces combined.

### DECISION REQUIRED: scaling the approved 7/3 `interleavedTail` rule beyond 10 questions

1. **Nearest 70/30 scaling:** round the selected-topic share to the nearest whole question, with half values rounding upward; the remainder is elsewhere (5 -> 4/1, 20 -> 14/6, and the same rule for all-due N). Availability shortfalls use the separately decided fallback contract.
2. **Floor the 70% selected-topic share:** selected-topic count is `floor(0.7 * N)` and the remainder is elsewhere (5 -> 3/2, 20 -> 14/6). This gives small sessions slightly more breadth.
3. **Keep 7/3 special to length 10:** non-10 lengths derive cross-topic allocation from eligible due/weak/new supply. This is the largest semantic departure because `interleavedTail` composition becomes history-dependent outside the default length.

**Recommendation:** option 1. It preserves the already-approved 7/3 intent most directly across supported lengths without changing the 10-question behavior.

### DECISION REQUIRED: fallback selection outside counted buckets

1. Disallow unclassified fallback; allow shorter sessions so counts remain strictly predictive.
2. Classify every fallback candidate into its real eligible bucket and charge the correct count/cap before use. Preserves fuller sessions without relabeling unknown items as new.
3. Keep the current escape hatch. Preview counts/caps can diverge from served questions.

**Recommendation:** option 2.

### DECISION REQUIRED: historical owner/outcome migration

1. Read historical aliases while writing only the current canonical identity. Preserves provenance without rewriting old rows.
2. One-time rewrite. Simplifies reads but mutates history and needs rollback/idempotence proof.
3. Ignore historical variants. Simplest but can drop real learning history.

**Recommendation:** option 1.

### DECISION REQUIRED: historical Resume repair when legacy rows are insufficient

Forward sessions must persist enough per-answer state for exact Resume; this decision applies only to already-existing legacy sessions that cannot be reconstructed exactly from authoritative attempt/review data.

1. Reconstruct only when exact mapping to the saved session/question IDs is provable; if proof is impossible, retire that legacy session from Resume while preserving its attempt/review history.
2. Apply best-effort inference to restore an approximate answered state. This preserves more legacy Resume entries but risks showing an answer/state the student did not actually produce.
3. Drop all legacy active-session Resume state at migration regardless of whether exact reconstruction is possible. Simplest, but unnecessarily loses valid resumable sessions.

**Recommendation:** option 1. Never invent an answer merely to keep an old session resumable.

### DECISION REQUIRED: commercial pricing source of truth

Planning references conflict. Options are to re-freeze the repository-carried weekly figure, adopt the conflicting current commercial checkpoint figures, or defer until the authorized founder/Play lane reconciles live commercial state.

**Recommendation:** defer. No Play/RevenueCat/store-pricing change is authorized here.

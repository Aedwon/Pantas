# E03 Content Protection + Quiz Launch Decision Log

**Date:** 2026-09-07

**Exact E02 baseline:** `ba536e73dbda455b994291eb551c2d6b0bd5286d`

**Scheduling authority:** Astra Google Drive Master SSOT revision 54, reconciled through the current root-orchestrator checkpoints in `Aedwon/Pantas#21`.

This log records the decisions that freeze E03 = CP-T0 + QLP-0. It is chronological. It preserves earlier assumptions that were corrected by exact-source inspection instead of rewriting the history to make the final design look obvious.

## 2026-09-07 - Revision 54 changed the release order

### Evidence

The root-orchestrator reconciliation in Pantas issue #21 established that Drive SSOT revision 54 supersedes the repository's older Release-E2E-first order. The accepted Release E2E/provenance head `ba536e73dbda455b994291eb551c2d6b0bd5286d` remains the E02 baseline, but plaintext-baseline E2E runs cannot satisfy final E10 after content protection and quiz-loading work changes the candidate.

### Decision

Freeze the program order as E01 through E14:

- E01 baseline/evidence inventory
- E02 accepted repair/provenance integration
- E03 CP-T0 + QLP-0
- E04 CP-T1 + CP-T2 + CP-T3
- E05 QLP-1
- E06 QLP-2 + QLP-3 + QLP-4
- E07 CP-T4
- E08 combined integration
- E09 CP-T5 source/device + QLP-5 + QLP-6
- E10 three isolated complete Release E2E passes on the unchanged E09 candidate
- E11 independent final source/E2E review
- E12 signed AAB
- E13 CP-T5 signed-artifact/AAB/APK inspection
- E14 upload-eligibility freeze

E14 also requires legal Play release-history identity and Aedwon's explicit acceptance of the documented recoverable-client-bootstrap-key residual risk.

### Cost / consequence

This invalidates the old schedule, not the accepted E02 evidence. Final E2E and artifact work move later. Any old full-runner success remains useful baseline evidence only.

### Non-decision

E03 does not dispatch E04, build an AAB, mutate Play, run Android/Firebase E2E, or move `main`.

## 2026-09-07 - The assumed two-runtime-content-path model was corrected

### Earlier assumption

Older repository guidance described two shipped runtime paths: `assets/seed/v1.json` into user/AppDatabase storage and `assets/seed/content.db` into ContentDatabase. That description was useful historical context, but it was stale at E02.

### Exact-source evidence

At `ba536e73...`:

- `pubspec.yaml` packages only `assets/seed/content.db`.
- The root-orchestrator checkpoint described `assets/seed/v1.json` as empty and not declared as a Flutter asset. Exact Git-tree verification later in E03 corrected the first part of that statement; the correction is preserved below.
- `tools/build_dev_seed/build_dev_seed.dart` marks the old JSON generator path as superseded.
- `tools/build_content_export/build_content_export.dart` still references `v1.json` as build-time historical input, so the stale dependency still needs reconciliation.
- `tools/build_content_seed/seed_writer.dart` creates the shipping SQLite seed.
- `lib/core/content/bundle/seed_installer.dart` copies the bundled database into Application Support.
- `lib/core/content/content_database_opener.dart` opens that installed database without a content key.

### Decision

Inventory the JSON path as historical/build-pipeline debt only. Do not restore a JSON Flutter asset, `Seeder`, or retired runtime reader. The protected release design stays on one SQLite corpus path.

### Cost / consequence

E04 must fix any stale build-tool dependency on the historical `v1.json` path without bringing back a second runtime source of truth.

## 2026-09-07 - Exact Git-tree verification corrected the empty-JSON checkpoint sentence

### New evidence

A fresh exact-base worktree check showed `assets/seed/v1.json` is tracked at blob `869e3055d3c685436994092cb9b7a77f1d7fd6e5` and is 9,679,883 bytes. GitHub exact-base content confirms it contains the historical generated corpus. `assets/seed/content.db` is not tracked; `.gitignore` explicitly excludes it, and a fresh E03 worktree does not contain it. `pubspec.yaml` still declares only `assets/seed/content.db` as the Flutter corpus asset. `tools/build_dev_seed/build_dev_seed.dart` still marks the JSON generator/asset as superseded and not shipped.

### Correction

The earlier root-orchestrator sentence saying tracked `v1.json` was empty is factually stale for exact Git SHA `ba536e73dbda455b994291eb551c2d6b0bd5286d`. The controlling architectural intent remains valid: the JSON runtime path is retired and must not be restored. E03 distinguishes the populated tracked historical/build corpus from the generated gitignored runtime shipping asset.

### Consequence

CP-T0 inventories the private-repository `v1.json` copy as a corpus copy. CP-T1 must keep it out of Flutter/release assets. E04 must reconcile any build-tool dependency on it without reviving a runtime JSON reader. The accepted generated `content.db` digest remains prior durable release evidence until E04 obtains/regenerates and freshly verifies the exact payload.

## 2026-09-07 - The current content database is plaintext; user data remains a separate encrypted boundary

### Evidence

`SeedInstaller` writes the bundled `content.db` bytes to Application Support, and `content_database_opener.dart` uses an ordinary content database open. `lib/core/content/content_database.dart` is schema version 8.

Separately, `lib/core/storage/data/database_opener.dart` protects `pantas.db` through sqlite3mc/SQLCipher-compatible settings with a random per-install 32-byte key held in `flutter_secure_storage` under `pantas_db_key`.

### Decision

Protect content independently. Never reuse, migrate, expose, or couple `pantas_db_key` to content protection. Freeze a separate secure-storage identifier `pantas_content_db_key_v1` for a separate 32-byte per-install content key.

### Cost / consequence

The app carries two distinct local security boundaries. E04 must prove content protection without changing user-data encryption behavior.

## 2026-09-07 - Protection goal is extraction resistance, not DRM

### Evidence / constraint

First-launch offline study is a product requirement. Therefore any bootstrap decryption capability needed to open the bundled corpus must exist on the client. A device owner can reverse engineer that material, hook native decryption/rendering, inspect memory, instrument the client, or capture displayed content.

### Options considered

1. Claim strong client-side confidentiality. Cost: false security claim because the device must possess the capability to decrypt offline. Rejected.
2. Require an online license/server key before study. Cost: breaks first-launch offline study and changes product behavior. Rejected at E03.
3. Use balanced client-side protection to stop casual unzip/plain-SQLite extraction while documenting the recoverable-key limit. Cost: determined extraction remains possible. Chosen.

### Decision

Security claims are limited to raising extraction resistance and reducing accidental/public corpus leakage. Do not describe the design as DRM, perfect confidentiality, an unrecoverable client key, or protection against a determined device owner. Aedwon must explicitly accept this residual risk at E14.

## 2026-09-07 - Freeze protected package format v1

### Decision

The release corpus remains at `assets/seed/content.db`, but its bytes become sqlite3mc/SQLCipher-compatible protected bytes. Add:

- `assets/seed/content.manifest.json`
- `assets/seed/content.manifest.sig`

Manifest v1 fields are frozen as:

- `formatVersion` = 1
- `applicationId` = `com.aedwon.pantas`
- `releaseChannel` = `prod`
- `payloadPath` = `assets/seed/content.db`
- `sourceContentSha256` = 64 lowercase hex of the approved plaintext seed immediately before protection
- `payloadSha256` = 64 lowercase hex of the exact protected payload
- `contentSeedVersion` = first 16 lowercase hex characters of `sourceContentSha256`
- `contentSchemaVersion` = 8 for the E03 baseline
- `readerSchemaMin` = 8
- `readerSchemaMax` = 8
- `cipherProfile` = `pantas-sqlite3mc-content-v1`
- `bootstrapKeyId` = `content-bootstrap-v1`
- `signingKeyId` = `content-signing-v1`

The manifest is deterministic UTF-8 with the field order above and one trailing newline. The detached Ed25519 signature covers those exact bytes and therefore binds both the stable logical/source identity and the exact encrypted payload identity. `sourceContentSha256` drives logical revision; `payloadSha256` identifies the generated protected artifact. The signature is the authenticity boundary.

### Algorithm/library ruling

Ed25519 is the frozen signature algorithm. A maintained Dart package such as `cryptography` 2.9.0 is the preferred implementation path, but E04 must confirm actual dependency/platform compatibility before adding it. No custom cryptography is authorized.

The SQLite confidentiality/integrity profile is intended to use sqlite3mc's SQLCipher-compatible protection with page integrity/HMAC. E03 does not call that mode AEAD because exact project evidence has not established that wording.

### Open blocker

Exact-build sqlite3mc profile and rekey support is not yet proven. E04 must prove plaintext test DB -> protected DB -> independent per-install rekey, wrong/unkeyed rejection, and journal/WAL/temp behavior without plaintext secondary staging. If the pinned project build cannot do that, CP-T1/CP-T2 are blocked pending a revised design. No plaintext fallback is authorized.

## 2026-09-07 - Freeze key boundaries and secret handling

### Decision

- Bootstrap key ID: `content-bootstrap-v1`; 32 random bytes; build/client input name `PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64`.
- Publisher signing key ID: `content-signing-v1`; Ed25519 private build secret `PANTAS_CONTENT_SIGNING_PRIVATE_KEY_V1_B64`; only the public verification key ships.
- Per-install content key: `pantas_content_db_key_v1`; 32 random bytes from a secure RNG; generated independently from user DB key.

Secrets must not be committed, logged, written to ordinary preferences, or attached to CI artifacts. Obfuscating the bootstrap key may add friction but earns no additional confidentiality claim.

### Non-decision

No remote key escrow, account-bound content license, online revocation, watermarking, anti-hooking, screenshot blocking, or hardware-backed DRM design is authorized by E03.

## 2026-09-07 - Freeze protected install/update/migration behavior

### Exact baseline identity

The accepted E02 shipping content is tracked as `contentSeedVersion` `eb3a9da425b80a51`; durable accepted release-lane evidence records generated `content.db` SHA-256 `eb3a9da425b80a51331cce74694ef014c3372392194bacbd60ba145db5ea2a45`. The generated asset is gitignored and is not present in this fresh E03 worktree, so E03 carries that prior accepted digest without claiming a fresh local hash.

### Decision

Fresh install/update must verify manifest signature, manifest constraints, encrypted payload SHA, content version/schema/key IDs/profile, and keyed database validity before promotion. The bundled encrypted payload may be copied to `content.db.pending`, opened with the bootstrap key, rekeyed directly to the per-install key, reopened/validated, then atomically promoted. No plaintext on-disk staging is allowed.

Migration support is intentionally narrow at first: only the exact E02 plaintext shipping corpus above is known safe to classify as the legacy baseline. An unknown/newer plaintext database cannot be silently replaced by the bundled baseline.

Key loss never triggers an unkeyed/plaintext open. Rebuild from the verified bundle is allowed only when it cannot silently discard a known newer content revision. Interrupted updates keep the last valid encrypted database until the replacement passes validation. Deletion of old plaintext bytes is best effort and is not described as forensic erasure.

### Required bootstrap correction

`lib/app/bootstrap.dart` currently establishes content storage before installing the seed. Protected bootstrap must complete package verification/install/migration before the final keyed ContentDatabase opens.

## 2026-09-07 - Remote content exposure remains an evidence question

### Evidence

The source contains `SanityClient`, GROQ queries, config parsing, and `ContentSyncCoordinator`. The client constructs Sanity CDN URLs. E03 did not establish a production construction path for the coordinator or prove the release dataset's direct access state.

### Decision

Do not claim that Sanity is protected, public, private, active, or inactive in production based on source capability alone. E07/CP-T4 must inspect the actual release configuration and direct serving behavior before the remote exposure boundary can close. App Check/auth can only receive credit where they are actually enforced in the content-serving path.

### Open dependency

If an equivalent proprietary corpus is directly/publicly queryable through an active release serving endpoint, that exposure blocks the claimed content-protection boundary until remediated or explicitly accepted.

## 2026-09-07 - Quiz preference and selection policy remain authoritative

### Evidence

`QuizPreferencesRepository` owns stored session length, ordering, and new-card-cap preferences. `QuizOrdering.fromStorage` retains legacy boolean compatibility and maps current values to `blocked`, `interleavedTail`, and `fullyMixed`; default remains `interleavedTail`. Existing Today composition code owns due/weak/fresh behavior and selected order.

### Decision

QLP work is a loading/launch optimization, not a policy rewrite. Preserve stored preference interpretation, bucket composition, new-card-cap behavior, selected question identity/order, deterministic choice ordering, historical attempt/review outcomes, Resume identity/order, and Retry/restart intent.

### Conditional blocker

If E05/E06 discovers ambiguous historical outcome ownership that cannot be represented by the frozen lightweight metadata model without changing learning semantics, stop that dependent path for a product-policy ruling. Do not rewrite history to make optimization easier.

## 2026-09-07 - Freeze QLP-1 lightweight selection and batched hydration boundary

### Evidence

At E02, Start fallback can load all exam/topic questions before selecting. `ContentRepository` fully hydrates selected questions, with separate active-choice and exam-membership reads per question. `ResumeSession` and restart flows reload saved IDs sequentially.

### Decision

Selection must operate on lightweight identity/scheduling metadata only. Freeze `QuestionSelectionRow`-style fields for ID, version, topic, optional lesson/passage references, and figure presence. Stems, explanations, rationales, choices, and passage bodies are excluded from the selection layer.

After IDs are selected, hydration must batch question rows, active choices, exam memberships, and distinct passages in bounded chunks, then reconstruct the exact caller-supplied order and existing deterministic choice order. Shipping and upgrade indexes must be proven by actual query plans instead of guessed.

### Cost / consequence

E05 owns the content-schema/index change after E04 finishes shared content-schema work. This sequencing avoids two workers changing installer/opener/schema contracts concurrently.

## 2026-09-07 - Freeze one prepared Today result and one launch owner

### Evidence

The current path can prepare/recommend and then repeat scope/selection/hydration at Start. Quiz and Home entry points share application wiring but do not yet own one immutable preparation object.

### Decision

Freeze these conceptual interfaces for E06:

- `QuizPreparationStamp`
- `PreparedTodaySession`
- `TodayQuizPreparer.prepare(...)`
- `QuizLaunchCoordinator.launchPreparedToday(...)`
- `QuizLaunchCoordinator.resumeToday(...)`

A prepared Today result is in-memory only and creates no persisted session. Start revalidates its freshness and persists exactly one session through one application owner. Rapid taps/rebuilds coalesce. Resume uses the existing saved session and never creates a replacement.

Freshness inputs are frozen as content revision, local day, exam/topic scope, QuizPreferences, authoritative session/review mutation revision, and active-session state. Prepared data is discarded after process death and revalidated after background return.

### Non-decision

E03 does not require a broad persisted-history migration for freshness. E06 may add only the smallest authoritative mutation signal if current state cannot cover sync-driven invalidation correctly.

## 2026-09-07 - Terminal persisted session closure is a correctness dependency

### Evidence

`QuizSessionRepository.complete` exists, but the normal terminal `QuizController.next` -> `CompleteQuiz` path saves the attempt without proving that the corresponding persisted quiz session is marked complete. That can leave an answered terminal session logically active/resumable.

### Decision

E06 must place attempt persistence and session terminalization under one transactional application-layer owner. After the final answer/attempt is successfully persisted, the session gets `completedAt` and can no longer be returned by `activeFor`. Failure before the completion commit must not falsely terminalize it. Attempt/session identity already used by debrief/provenance must remain stable.

### Cost / consequence

This is a correctness fix required for a coherent launch/resume model, not an optional speed optimization.

## 2026-09-07 - Freeze complete-answerable readiness and response timing

### Evidence

Current timing begins when controller state sets a shown timestamp. E03 source inspection did not prove that this corresponds to the first frame where a required passage or figure is fully ready.

### Decision

A question becomes answerable only when stem, active choices, any required passage, and any required figure/diagram render-ready state are ready. Response timing begins at that first complete answerable presentation. Preparation time, route construction, and partial frames do not count. Rebuilds do not reset the timer.

Prepared Next does not rerun selection/hydration. Retry preserves source mode/scope and does not create duplicate persistence.

## 2026-09-07 - Freeze measurement harness and proposed review targets before optimization

### Decision

E09 measurement must cover UPCAT, CSE Professional, and custom tracks; empty/mixed/substantial history; ordinary/all-due lengths; long 75/100-question attempt-like history where applicable; cold/warm paths; plain/math/passage/diagram first questions; offline/background/day-rollover/content-upgrade behavior.

Measure first recommendation, Start/Retry feedback, warm Start, cold daily route, normal 5/10/20 Resume, prepared Next, database query count, memory, complete-answerable-frame, build/raster time, and missed frames. Use a physical lower-end Android device, preferably 3-4 GB RAM and 60 Hz, plus a mainstream comparison device. Ordinary scenarios require at least 30 observations. Report median, p95, and maximum with cold/warm separated.

Proposed Drive-54 review targets are:

- Start/Retry feedback <=100 ms
- first recommendation p95 <=1,000 ms after databases are available
- unchanged recommendation on the next usable frame with no preparation
- warm Start p95 <=500 ms
- cold daily route after bootstrap p95 <=1,500 ms
- normal 5/10/20 Resume p95 <=1,000 ms
- prepared Next p95 <=100 ms
- on 60 Hz hardware, build and raster p95 <=16.7 ms, with missed frames reported

### Security/performance claim rule

These are proposed acceptance targets. They are not claims about current E02 or future E09 performance until measured.

## 2026-09-07 - Freeze evidence invalidation and final acceptance rules

### Decision

E09 source/device security and performance evidence must exercise the combined protected-content + optimized-quiz candidate. E10 must run three isolated complete six-journey Release E2E passes on that unchanged E09 candidate, with the required emulator reset/restart discipline. Any relevant source/content change invalidates affected E09/E10 evidence.

E11 independently reviews one exact source candidate. E12 builds a signed AAB only after E11 acceptance. E13 verifies the exact AAB/APKs and protected packaging. A source/content change after E12 invalidates that artifact. E14 freezes upload eligibility only after engineering/artifact acceptance, legal Play version identity, and explicit residual-key-risk acceptance.

### Commercial pin

The pricing carried into this planning checkpoint is **PHP 149/week**. E03 does not change billing implementation or authorize Play/RevenueCat mutation.

## 2026-09-07 - Root review corrected ciphertext-derived logical revision and frozen generated-package provenance

### Defect found after the first docs commit

The first E03 docs commit `b2569484` incorrectly derived `contentSeedVersion` from encrypted `payloadSha256` and treated protected package materialization too much like a tracked source-file change. SQLCipher/sqlite3mc normally uses randomized salt/encryption state, so identical logical content can legitimately produce different ciphertext bytes and payload hashes.

### Corrected decision

`sourceContentSha256` is computed from the approved plaintext seed immediately before protection and is the stable logical content digest. `contentSeedVersion` is its first 16 lowercase hexadecimal characters. `payloadSha256` identifies the exact encrypted payload. The signed manifest contains and authenticates both. E04 tests must prove two protected builds from identical source retain the same logical digest/version even when their exact payload hashes differ. Choosing or fixing a deterministic SQLCipher salt solely for reproducible ciphertext is not authorized.

`content.db`, `content.manifest.json`, and `content.manifest.sig` are generated companions that travel as one immutable protected-package artifact rather than secret-dependent source-controlled bytes. Package provenance records source Git SHA, logical digest/version, payload SHA-256, manifest SHA-256, detached-signature SHA-256, key IDs, cipher profile, and schema versions. `tools/release/android/release.sh` is explicitly E04-owned because its plaintext-era hash/version-prefix gate must be replaced by fail-closed signed-package verification.

E10 must use one unchanged package identity for all three isolated passes. E12 must package that exact accepted package; regeneration is allowed only through an explicit earlier-stage return that invalidates and reruns affected evidence. The rejected `b2569484` history is preserved rather than force-rewritten.

## Open dependencies at E03 handoff

1. **CP-T0 / E04 hard blocker:** prove exact pinned sqlite3mc content profile and no-plaintext rekey flow.
2. **CP-T4 / E07 dependency:** determine actual production Sanity/content-serving exposure and enforcement.
3. **QLP correctness dependency:** implement terminal session closure under the single launch/completion ownership contract in E06.
4. **QLP conditional policy dependency:** stop for a ruling if historical outcome semantics cannot be preserved by lightweight selection metadata.
5. **E09 evidence dependency:** lower-end physical Android hardware/profile must be available for real performance/security measurement.
6. **E14 human/Play dependency:** legal Play version identity and Aedwon's explicit recoverable-client-key residual-risk acceptance remain external final gates.

## Explicit E03 non-decisions

E03 does not choose or authorize:

- an online-only key service or DRM system;
- a custom cipher or custom signature implementation;
- restored runtime JSON content loading;
- changes to Free/Pro entitlement, billing, prices beyond carrying the PHP 149/week pin, or RevenueCat behavior;
- a Sanity/backend remediation before E07 proves a real exposure;
- a new quiz learning policy, bucket formula, ordering mode, history rewrite, or silent all-due cap;
- a claim that the current app already meets the proposed latency/frame targets;
- a claim that packaged client content is perfectly confidential;
- E04 implementation ownership or dispatch;
- AAB construction, Play publication, or final release acceptance.

## 2026-09-08 - Contract correction after recovery-r2 review

### Evidence and status correction

The recovery-r2 implementation head advanced to `3c686756ac31748f4acad0291e464fc45b1266cb`. Relay histories `Aedwon/chatgpt-terminal-relay#5885` and `#5990` remain terminally blocked on the missing authorized production Ed25519 public verification key. `#5990` corrected only two stale plaintext-era tests and reported 40 focused tests green; it did not complete E04 production acceptance. September 8 reviews `#6040` and `#6041`, the complete originating September 6 quiz-loading text preserved in `#6042/#6044/#6045/#6046/#6047`, and SSOT excerpts `#6049/#6050` exposed contract gaps in the September 7 planning documents.

The original September 6 text is complete as line-ordered relay evidence, but the relay wrapper does not prove exact original untracked-file bytes. This lane therefore records the evidence and reconciles it into the governing contracts without fabricating `docs/superpowers/specs/2026-09-06-quiz-loading-performance-design.md`.

### Amendment: Settings owns Today ordering

The September 7 decision naming `QuizPreferencesRepository` as ordering authority is superseded. August Settings decisions and Plan 06 explicitly replaced the unwritten legacy boolean UI path with `settings.session_ordering`. Settings `SessionOrdering` is authoritative for recommendation/preparation and Start. `quiz_today_interleaved` is compatibility input only when current Settings ordering is absent, and current Settings wins disagreements. A real Settings-write through preparation to Start regression is mandatory. Root review freezes the shipped compatibility mapping `true -> interleavedTail`, `false -> blocked`; it never overrides explicit current Settings state. Root review also confirms the three modes are distinct, the 10-question `interleavedTail` case is 7 selected-topic + 3 other-topic due cards, `fullyMixed` prevents adjacent same-topic questions, and the new-card cap is one shared local-day allowance across all quiz surfaces.

### Amendment: preparation freshness is time-bound and lifetime-bound

A local-day stamp alone is insufficient. Preparation also covers authoritative ordering/scope/topic exclusions/history/session completion/content revision/account lifetime and an explicit `nextDueExpiry` or equivalent earliest due-boundary instant. Account switch/reset/deletion, sync/import history, local-day rollover, and crossing a due boundary later within the same day invalidate. Late older async work cannot overwrite newer preparation. An active persisted session retains its saved IDs/order.

### Amendment: protected-package chronology, rotation, and promotion

Hashes are identities, never chronology. The September 8 production successor is manifest **format v2**: `formatVersion = 2` plus positive monotonic signed `releaseSequence`; v1 remains historical/rejection-fixture evidence and is not production-acceptable. Publisher rollback is a new v2 package with a higher sequence. Runtime persists accepted format/sequence plus exact identity as device-local protected-content installation metadata outside account/user data; sign-out, account switch, reset, and account deletion do not clear anti-replay chronology. Lower sequences and equal-sequence/different-identity forks are rejected. Promotion uses persisted intent plus pending/previous/active recovery state so each crash boundary either finalizes a fully validated candidate or restores the previous valid package. Lexical hash comparison is forbidden.

Signing/bootstrap IDs are versioned lookup keys with sequence validity windows and permitted overlap for rotation. Unknown or retired IDs fail closed. Public signing verification keys may overlap; signing private/bootstrap secret material never enters docs/issues/chat. No production key bytes are invented.

### Amendment: schema and downstream provenance

E04 reader/manifest schema bounds and E05 index/schema migration must be coordinated before E05 increments schema, with fresh-versus-upgraded equivalence. E10/E11 accept a non-secret exact package/source record; E12 validates source and package against that record as well as signature validity and consumes the exact accepted package instead of silently regenerating randomized ciphertext. A trusted-key but different internally valid package must be rejected.

E08 owns protected-package Release E2E runner migration: remove the ciphertext-SHA-prefix assumption, pass the bootstrap define only through the existing secret-safe build path, preserve exact provenance/integrity checks, and do not broadly relax production-diff allowlists.

### Amendment: E04 acceptance state

E04.2 remains reviewed partial work while the production trust keyring is empty. Production acceptance is blocked on an explicitly authorized exact 32-byte Ed25519 public verification key tied to the release signing process. Safe fixture-key installer/migration work may proceed after this contract correction is accepted. The 22 E04-introduced analyzer information findings must be closed or explicitly dispositioned; the unrelated older bookmarks finding is reported separately. No physical Android interruption/migration/device evidence is claimed yet.

### Amendment: E05 custom-track scope

E05 owns removal of full-question hydration used only to resolve custom-track metadata/count scope. Lightweight queries must preserve exact scope/exclusion semantics and prove equivalent IDs/counts.

### RESOLVED September 8: ordering semantics, legacy mapping, and daily new-card allowance

Root review closes three items that were incorrectly left open in the first correction draft:

- `interleavedTail` and `fullyMixed` remain distinct. The 10-question `interleavedTail` case is the documented 7 selected-topic + 3 other-topic due-card composition; `fullyMixed` prohibits adjacent same-topic questions.
- Legacy compatibility remains `true -> interleavedTail` and `false -> blocked` only when current Settings ordering is absent. Explicit Settings always wins.
- The new-card cap is one shared local-day allowance across all quiz surfaces combined and across topic allocations. It is not a per-topic allowance.

The only remaining composition decision is how the already-approved 7/3 intent scales deterministically beyond the 10-question case, plus the independent fallback-accounting question below.

### DECISION REQUIRED: scaling the approved 7/3 `interleavedTail` rule beyond 10 questions

Options: (1) nearest 70/30 scaling with a documented deterministic rounding rule; (2) floor the selected-topic 70% share and give the remainder to elsewhere; (3) keep 7/3 special to length 10 and derive non-10 composition from eligible supply. **Recommendation: option 1**, because it preserves the approved 7/3 intent most directly without changing the existing 10-question behavior.

### DECISION REQUIRED: fallback outside counted buckets

Options: (1) disallow unclassified fallback and allow a shorter session; (2) classify fallback candidates into their real eligible bucket and charge the correct count/cap before use; (3) keep the current escape hatch even when preview counts/caps diverge. **Recommendation: option 2.**

### DECISION REQUIRED: historical owner/outcome migration

Options: (1) read historical aliases while writing only the current canonical identity; (2) one-time rewrite; (3) ignore historical variants. Rewriting mutates history; ignoring can drop real learning evidence. **Recommendation: option 1.**

### DECISION REQUIRED: historical Resume repair when legacy rows are insufficient

Forward sessions must persist enough per-answer state for exact Resume; this decision applies only to already-existing legacy sessions that cannot be reconstructed exactly from authoritative attempt/review data. Options: (1) reconstruct only when exact mapping to the saved session/question IDs is provable; if proof is impossible, retire that legacy session from Resume while preserving its attempt/review history; (2) use best-effort inference to restore an approximate answered state, risking an answer/state the student did not actually produce; (3) drop all legacy active-session Resume state regardless of whether exact reconstruction is possible. **Recommendation: option 1. Never invent an answer merely to keep an old session resumable.**

### DECISION REQUIRED: commercial pricing source of truth

Current planning references conflict. Options: re-freeze the repository-carried weekly figure, adopt the conflicting current commercial checkpoint figures, or defer until the authorized founder/Play lane reconciles live commercial state. **Recommendation: defer.** No Play/RevenueCat/store-pricing change is authorized here.

### Consequence

E04.3/E04.4 and E05/E06 must not resume under superseded September 7 rules. The E04 -> E05 -> E06 -> E07 -> E08 -> E09 -> E10 -> E11 -> E12 -> E13 -> E14 sequence remains, including emulator restart before E10 pass 3 and later Play-installed Firebase/billing/accessibility/device gates. Security claims remain limited to extraction resistance.

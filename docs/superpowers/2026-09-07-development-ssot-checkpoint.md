# Pantas development SSOT checkpoint — 2026-09-07

> Repository execution checkpoint reconciled to Astra Google Drive Master SSOT revision 54 and the current root-orchestrator state in `Aedwon/Pantas#21`. Scheduling in this file supersedes the older Release-E2E-first repository checkpoint. Domain requirements remain governed by the accompanying E03 spec, E04–E14 implementation plan, and chronological decision log.

## Authority and exact baseline

- Repository: `Aedwon/Pantas`.
- E02 accepted baseline and parent for E03 planning: `ba536e73dbda455b994291eb551c2d6b0bd5286d`.
- E03 documentation branch: `web/e03-cp-t0-qlp0-plan-r1`.
- E03 worktree: `Pantas-wt-web-e03-cp-t0-qlp0-plan-r1`.
- `main` is read-only for this program. Remote `main` was observed at `b642e2d169e0a03120d4f71cc6e10a6148cc5ef0` during E03 preflight.
- `web/release-e2e-r1` is read-only during E03 and is the accepted E02 baseline source.
- Astra Google Drive Master SSOT revision **54** is the scheduling authority for the security/content-protection and quiz-loading program.
- Cancelled relay registry issue `Aedwon/chatgpt-terminal-relay#5482` is historical scope input only. Current worker registry issue `#5488`, Pantas issue `#21`, this repository handoff, and Drive revision 54 control execution.
- Commercial pin carried into this checkpoint: **PHP 149/week**. Older repository/Drive pricing text is stale and is not an execution authority. No other price is re-frozen here.

## E02 status preserved, not overstated

E02 is accepted as the baseline integration/provenance step. Its Firestore-reset, anonymous local-data deletion, review-log wiring, runner/harness, and provenance evidence remain historical inputs to the current candidate. This checkpoint does not reopen or discard that evidence.

E02 is **not** final Release E2E acceptance. Any complete Release E2E passes made before content protection and quiz-loading work are plaintext-baseline evidence only. They do not satisfy E10 because E04–E09 will change the source/content path that E10 must exercise.

## Exact E03 baseline reconciliation

### Content packaging and storage

At `ba536e73dbda455b994291eb551c2d6b0bd5286d`:

- `pubspec.yaml` declares only `assets/seed/content.db` under Flutter assets.
- `assets/seed/v1.json` is a populated tracked legacy/build corpus (9,679,883 bytes in the exact Git tree) but is not declared as a Flutter asset. It remains historical/build-tool inventory, not a runtime reader to restore.
- `tools/build_dev_seed/build_dev_seed.dart` explicitly marks the JSON generator and `v1.json` path as superseded by the `content.db` pipeline.
- `tools/build_content_export/build_content_export.dart` still reads `assets/seed/v1.json` as a build-time historical input. E04 must treat that tracked legacy corpus dependency as build-pipeline debt and must not infer that the retired JSON runtime path is active.
- `tools/build_content_seed/seed_writer.dart` writes generated `assets/seed/content.db` as an ordinary SQLite `ContentDatabase` and derives `contentSeedVersion` from the first 16 hexadecimal characters of the database SHA-256. `content.db` is gitignored and is not materialized in this fresh E03 worktree. Durable accepted release-lane evidence records the E02 shipping payload as 8,683,520 bytes with SHA-256 `eb3a9da425b80a51331cce74694ef014c3372392194bacbd60ba145db5ea2a45`; the tracked `contentSeedVersion` is `eb3a9da425b80a51`. E03 does not misstate that digest as a fresh local hash.
- `lib/core/content/bundle/seed_installer.dart` loads the bundled `content.db` and writes its bytes verbatim to Application Support when the installed version is absent/stale.
- `lib/core/content/content_database_opener.dart` opens the installed `content.db` with an ordinary `NativeDatabase` connection. The installed content database is therefore plaintext on this baseline. The content package/install/open path has no paywall or entitlement dependency, so E03 must preserve that baseline access boundary while leaving Free/Pro feature policy unchanged. Android also has `android:allowBackup="false"`; `backup_rules.xml` and `data_extraction_rules.xml` exclude all app domains from cloud backup and device transfer.
- `lib/core/content/content_database.dart` reports content schema version 8.
- `lib/app/bootstrap.dart` currently opens content storage before `_installContentSeed`, then installs the bundled seed later in bootstrap. E04 must reorder the protected-content bootstrap so verification/migration/install completes before the final keyed content database is opened.
- User state remains a separate boundary: `lib/core/storage/data/database_opener.dart` opens `pantas.db` through sqlite3mc/SQLCipher compatibility, using `PRAGMA cipher = 'sqlcipher'`, `PRAGMA legacy = 4`, and a random 32-byte per-install key stored under secure-storage key `pantas_db_key`. Content protection must not reuse or migrate that user-data key.

### Remote/content update surface

- Source contains `SanityClient`, GROQ queries, schema parsers, and `ContentSyncCoordinator`.
- `SanityClient` constructs unauthenticated requests to `<project>.apicdn.sanity.io`; production runtime construction of `ContentSyncCoordinator` was not evidenced during E03 discovery.
- Therefore E03 makes no claim that Sanity is either protected or actively serving release content. E07/CP-T4 must inspect release configuration, dataset exposure, direct queryability, and any real content-serving path before crediting authorization/App Check or declaring a remote exposure gap closed.

### Quiz loading and persistence

- `QuizPreferencesRepository` is the authoritative stored preference reader/writer for session length, ordering, and new-card cap. `QuizOrdering.fromStorage` preserves historical boolean values and maps current values to `blocked`, `interleavedTail`, or `fullyMixed`; default remains `interleavedTail`. The ordering-authority dependency is resolved at E03.
- `StartTodaySession` falls back to loading all questions for an exam/topic before building a plan.
- `ContentRepository.questionsByTopic` fully hydrates questions; each hydration separately reads active choices and exam membership. `questionsByIds` batches question rows but still performs per-question choice/exam hydration. This is the verified QLP-1 data-path bottleneck.
- `ResumeSession` reloads the saved ordered question IDs sequentially through `questionById`. QLP optimization must preserve stored identity and order while batching hydration.
- `QuizSessionRepository.create` closes prior open sessions for the same user/exam and persists the ordered IDs.
- A terminal-session gap remains: `QuizSessionRepository.complete` exists, but the normal `QuizController.next` → `CompleteQuiz` path saves the attempt without calling it. An answered terminal session can therefore remain logically open. E06 must close this correctness gap as part of the single launch/completion ownership contract; E03 does not pretend it is already fixed.

## Frozen program order — E01 through E14

| Stage | Work | CP / QLP mapping | Exit gate |
| --- | --- | --- | --- |
| E01 | Pin paused candidate, inventory accepted/unintegrated repairs, preserve evidence | governance | one exact candidate and evidence inventory |
| E02 | Integrate already-completed Firestore-reset and anonymous-deletion/provenance repairs | baseline | accepted baseline `ba536e73...`; baseline verification only |
| **E03** | **Security/content preflight and quiz-loading design preflight** | **CP-T0 + QLP-0** | exact source/test map, frozen contracts, explicit blockers/risks; docs-only |
| E04 | Protected packaging/manifest, protected install/open, migration/recovery | CP-T1 + CP-T2 + CP-T3 | negative/tamper/offline/migration/key-loss gates green |
| E05 | Lightweight selection metadata, batched hydration, shipping/upgrade indexes | QLP-1 | data/order equivalence + bounded queries + query-plan proof |
| E06 | Prepared Today flow, one launch owner, readiness/timing/retry, freshness/cancellation/memory; terminal-session closure | QLP-2 + QLP-3 + QLP-4 | real Start/nudge/resume/retry routes preserve behavior and persist exactly once |
| E07 | Secret/log/export/CI and real serving-path audit | CP-T4 | no protected corpus/key leakage; remote exposure characterized and gated |
| E08 | Integrate accepted E04–E07 work on one candidate | integration | combined source/content candidate identified; no unresolved ownership conflict |
| E09 | Physical-device source/path security and lower-end performance verification | CP-T5 source/device phase + QLP-5 + QLP-6 | encrypted-path device evidence and focused/full verification accepted |
| E10 | Three isolated complete Release E2E passes | Release E2E | all six journeys pass three times on unchanged E09 candidate |
| E11 | Independent final source/E2E review | independent review | exact source candidate accepted |
| E12 | Build signed production AAB from exact E11 source | artifact build | signed artifact produced; version identity remains provisional if Play history unavailable |
| E13 | Inspect exact AAB/generated APKs for protected packaging, extraction, secrets, signing/provenance | CP-T5 signed-artifact phase | artifact accepted against exact source + hashes |
| E14 | Freeze upload-eligible release | CP closure / release | legal Play version identity resolved and Aedwon explicitly accepts recoverable-client-bootstrap-key residual risk |

No stage may count evidence from a different source/content digest as if it were evidence for the current stage. A source or content change after E09 invalidates affected E09/E10/E11 evidence; a source change after E12 invalidates the signed artifact and requires rebuild/reverification.

## Root acceptance correction — protected package logical versus artifact identity

The E02 statement above remains historical evidence: its plaintext seed writer derived `contentSeedVersion` from the generated plaintext DB hash. The future protected-package contract is different. E04 must compute `sourceContentSha256` from the approved plaintext seed immediately before protection and derive `contentSeedVersion` from that stable logical/source digest. The exact encrypted artifact gets a separate `payloadSha256`; manifest and detached-signature SHA-256 values identify the generated companions. The signed manifest binds both logical and exact payload identities.

SQLCipher/sqlite3mc protection may produce different ciphertext/payload hashes for identical source because of randomized salt/encryption state. The program must not fix a deterministic salt merely to make ciphertext reproducible. Generated `content.db`, `content.manifest.json`, and `content.manifest.sig` travel as one immutable non-source-controlled package. E10 pins one exact package for all three isolated runs, and E12 packages that same accepted package; any authorized regeneration invalidates affected E09/E10/E11 evidence before a signed AAB may be accepted.

## Parallel founder / Play / human lane

The engineering order above does not block independent founder preparation that does not mutate the candidate:

- complete Google Play developer identity/account/device verification when available;
- obtain legal release-history information before final `versionCode` / `versionName` freeze;
- prepare Internal tester roster and later closed-test buffer;
- configure/verify Play subscription and RevenueCat production objects only in the authorized Play lane, using the current commercial SSOT rather than stale repository pricing;
- prepare RTDN, tester/license-tester configuration, physical Android devices, feedback collection, privacy declarations, and human acceptance logistics;
- after E13/E14 and required Play/account gates, upload only the exact frozen artifact, then perform Play-installed Firebase/Auth/sync, App Check/Play Integrity, billing lifecycle, product smoke, accessibility, notifications/runtime, and privacy/account-data acceptance.

These founder/Play actions are not part of E03. E03 grants no Google Play mutation, credential use, AAB build, upload, or device acceptance authority.

## E03 deliverables and stop condition

E03 is documentation plus read-only source discovery only. Its repository output is limited to `docs/superpowers/**` and consists of this checkpoint, the authoritative ordered plan, an exact E03 security/quiz execution spec, the E04–E14 implementation plan, and a chronological decision log.

E03 does **not** implement or dispatch E04. E04 may start only after the orchestrator accepts this handoff and provides a new assignment with explicit branch/worktree ownership.

## Residual release gates after E03

- Balanced content protection reduces casual bulk extraction; it does not create DRM or prevent a determined device owner from recovering client-side bootstrap material, hooking decryption/rendering, or capturing displayed content.
- The exact sqlite3mc content rekey/encryption flow must be proven on the pinned Flutter/native build before E04 depends on it. Upstream capability is not enough to claim project support.
- The old standalone quiz-loading spec referenced by Drive revision 54 (`docs/superpowers/specs/2026-09-06-quiz-loading-performance-design.md`) is absent from exact E02 repository state. The E03 execution spec carries its authoritative Drive-54 requirements forward and becomes the repository implementation source.
- Lower-end Android performance targets remain proposed engineering acceptance targets until measured at E09; they are not claims about current performance.
- Final Release E2E is E10, after security/performance integration.
- Final signed-artifact content-protection proof is E13, not E09.
- Upload eligibility is not frozen until E14, including explicit acceptance of the recoverable bootstrap-key residual risk.

# Pantas E04–E14 Content Protection + Quiz Launch Release Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: use `superpowers:subagent-driven-development` or `superpowers:executing-plans` only after the root orchestrator creates an explicit task/branch/worktree. Do not infer authorization from this plan.

**Goal:** implement the E03 content-protection and quiz-loading contracts in dependency order, verify them on the final encrypted content path, then complete final Release E2E, independent review, signed-artifact proof, and upload-eligibility freeze.

**Architecture:** protect the bundled SQLite corpus with a versioned sqlite3mc/SQLCipher-compatible content profile, detached signed manifest, and a distinct per-install secure-storage key; preserve user `pantas.db` as a separate boundary. Then move Today selection to lightweight metadata + batched hydration, prepare the selected session once, launch/persist through one application owner, and invalidate preparation on authoritative state changes.

**Tech stack:** Flutter/Dart, Riverpod, Drift, sqlite3/sqlite3mc, `flutter_secure_storage`, SHA-256, Ed25519 via a maintained Dart library after E04 dependency proof, existing Release E2E runner/harness, Android physical-device profiling.

**Spec:** `docs/superpowers/specs/2026-09-07-e03-content-protection-quiz-launch-execution-spec.md`.

## Global constraints

- Exact starting source for E04: accepted E02/E03 parent lineage rooted at `ba536e73dbda455b994291eb551c2d6b0bd5286d`; the orchestrator must pin the actual E04 parent after the E03 docs commit is accepted.
- `main` is read-only. Never implement in another worker’s worktree.
- E04–E07 are sequential where shared files overlap; do not parallel-edit content schema, installer/opener, `ContentRepository`, quiz providers, or controller.
- Preserve first-launch offline study, Free/Pro behavior, user progress, sign-in behavior, selected IDs/order, choice order, Today composition, and Retry/Resume intent.
- Never reuse `pantas_db_key` for content. Content secure-storage key is `pantas_content_db_key_v1`.
- Never restore `assets/seed/v1.json` as a runtime Flutter asset/reader.
- No custom cryptography. If the selected maintained library/native profile cannot satisfy the frozen contract, stop for a design ruling.
- No plaintext on-device staging or plaintext fallback.
- Security claim is extraction resistance, not DRM/perfect confidentiality.
- E09 performance targets are targets until measured, never current-performance claims.
- E10 requires three isolated full Release E2E passes on an unchanged E09 candidate.
- No final signed AAB before E11 acceptance.
- E14 requires explicit Aedwon residual-risk acceptance and legal Play version identity.

---

## Planned branch / ownership map

These names reserve ownership in this plan only. **Do not create or dispatch them from E03.** The root orchestrator must issue each assignment explicitly.

| Stage | Planned branch | Exclusive primary ownership | Depends on |
| --- | --- | --- | --- |
| E04 | `web/e04-content-protection-r1` | protected content package/install/open/migration + focused tests | accepted E03 |
| E05 | `web/e05-quiz-selection-performance-r1` | lightweight selection metadata, batched hydration, content indexes | accepted E04 |
| E06 | `web/e06-quiz-prepared-launch-r1` | prepared Today flow, launch/completion owner, readiness/freshness | accepted E05 |
| E07 | `web/e07-content-protection-audit-r1` | leakage/serving-path fixes/evidence only | accepted E04–E06 |
| E08 | `web/e08-security-quiz-integration-r1` | guarded integration of accepted E04–E07 heads | accepted E04–E07 |
| E09 | `web/e09-security-performance-verification-r1` | verification/evidence docs and only bounded verifier instrumentation if explicitly assigned | accepted E08 |
| E10 | `web/e10-release-e2e-final-r1` | final Release E2E evidence; runner corrections only if a concrete harness defect is assigned | accepted E09 |
| E11 | `web/e11-final-source-review-r1` | read-only independent review/evidence docs | accepted E10 |
| E12 | `web/e12-signed-aab-r1` | authorized artifact build/evidence only | accepted E11 |
| E13 | `web/e13-artifact-security-verification-r1` | signed-artifact inspection/evidence only | exact E12 artifact |
| E14 | `web/e14-upload-eligibility-freeze-r1` | final freeze decision/evidence docs only | accepted E13 + human/Play gates |

## E04 — CP-T1 / CP-T2 / CP-T3

### Task E04.1: prove exact sqlite3mc content profile before depending on it

**Files:**
- Create: `test/core/content/security/sqlite3mc_content_profile_test.dart`
- Create: `lib/core/content/security/content_cipher_profile.dart` only after the RED/probe proves the required behavior.

**Interfaces:**
- Produces one content-specific helper used by build tooling and runtime open/rekey.
- Must not import/reuse the user database’s `pantas_db_key` or blindly reuse its `legacy=4` compatibility setting.

**Steps:**
1. Write a focused temporary-database test proving plaintext → protected rekey, correct-key reopen, wrong/unkeyed failure, protected → independent-key rekey, and journal/temp behavior.
2. Run only that test and require a meaningful RED if the profile/helper is not yet implemented.
3. Implement the minimal centralized sqlite3mc profile with a 32-byte binary key and verified page-integrity/HMAC behavior.
4. Re-run and inspect files created beside the database.
5. If exact project sqlite3mc cannot satisfy the no-plaintext-staging flow, stop E04 with `content-rekey-unsupported`; do not continue to CP-T1/CP-T2.

**Gate:** exact native project build, not upstream documentation, proves the content profile.

### Task E04.2: build protected package and signed manifest

**Files:**
- Create: `lib/core/content/security/content_package_manifest.dart`
- Create: `lib/core/content/security/content_signing_keys.dart` (public key/key-id map only)
- Create: `tools/build_content_package/build_content_package.dart`
- Create: `test/tool/content_package_builder_test.dart`
- Create: `test/core/content/security/content_package_manifest_test.dart`
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`
- Modify: `tools/build_content_seed/seed_writer.dart`
- Modify: `tools/build_content_export/build_content_export.dart` only to remove/reconcile the tracked historical `v1.json` build dependency; never add a runtime JSON path.
- Generate (gitignored artifact): `assets/seed/content.db` protected bytes; do not `git add -f`.
- Generate companion artifact: `assets/seed/content.manifest.json`; keep it with the protected package rather than treating secret-dependent bytes as source.
- Generate companion artifact: `assets/seed/content.manifest.sig`; keep it with the same immutable protected package.
- Modify: `.gitignore` only as required to make all generated protected-package companions explicitly non-source-controlled.
- Modify: `tools/release/android/release.sh` so release preflight validates the signed protected-package contract instead of the plaintext-era content hash/version-prefix contract.
- Create/modify: focused release-script contract tests under `test/tools/release/`.
- Modify: `lib/core/content/content_seed_version.dart` through the package builder, never by hand.
- Modify: `pubspec.yaml` asset list to include manifest/signature and still exclude `v1.json`.

**Exact package contract:** use manifest v1 and key IDs from the E03 spec; production `applicationId` is `com.aedwon.pantas`, channel `prod`. The builder computes stable `sourceContentSha256` from the approved plaintext seed immediately before protection, derives `contentSeedVersion` from that source digest, computes `payloadSha256` from the exact encrypted bytes, and signs a manifest containing both identities. Random SQLCipher/sqlite3mc salt/encryption state may make payload hashes differ across builds of identical source; tests must prove logical revision stability without fixing a deterministic salt.

**Steps:**
1. Add fixture text that is easily detectable in raw JSON/plain SQLite.
2. Write failing tests for raw release asset, missing/invalid signature, changed manifest, changed payload, wrong key, untrusted key ID, schema/channel/application mismatch, and accidental signing-private-key inclusion.
3. Add maintained Ed25519 support only after dependency resolution passes. Do not implement a custom signature primitive.
4. Make `build_content_package.dart` create the plaintext SQLite only in a controlled build-temp location, protect it with `content-bootstrap-v1`, write deterministic manifest bytes, sign them with `content-signing-v1`, validate the keyed database, then emit only protected release assets.
5. Require build secrets from `PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64` and `PANTAS_CONTENT_SIGNING_PRIVATE_KEY_V1_B64`; fail closed when missing/malformed.
6. Remove the stale historical JSON contribution from the current export path without restoring a reader.
7. Scan all Flutter assets/release package fixture entries for raw fixture text/plain SQLite.
8. Update `tools/release/android/release.sh` and focused tests to fail closed unless the exact generated payload + manifest + detached signature pass the new source-digest/payload-digest/signature checks; the old plaintext `APPROVED_CONTENT_DB_SHA256` + `contentSeedVersion`-prefix relationship must not authorize a protected release package.
9. Record protected-package identity as source Git SHA, `sourceContentSha256`, `contentSeedVersion`, `payloadSha256`, manifest SHA-256, detached-signature SHA-256, key IDs, cipher profile, and schema versions.

**Gate:** ordinary unzip/strings/JSON/plain SQLite cannot recover fixture corpus; correct key opens it; wrong/tampered inputs fail; no signing private key/server credential ships.

### Task E04.3: verify package and install protected content before open

**Files:**
- Create: `lib/core/content/security/content_package_verifier.dart`
- Create: `lib/core/content/security/content_key_store.dart`
- Create: `lib/core/content/bundle/protected_content_installer.dart`
- Modify: `lib/core/content/content_database_opener.dart`
- Modify: `lib/core/content/content.dart`
- Modify: `lib/app/bootstrap.dart`
- Retire/replace production use of: `lib/core/content/bundle/seed_installer.dart` while preserving its test seams only if still useful.
- Create/modify focused tests under `test/core/content/security/`, `test/core/content/bundle/`, `test/core/content/content_providers_test.dart`, and bootstrap tests.

**Frozen interfaces:** `ContentKeyStore`, `ContentPackageVerifier`, `ensureProtectedContentInstalled`, `openProtectedContentDatabase` from the E03 spec.

**Steps:**
1. RED: fresh offline install verifies signature/hash/schema/key IDs, copies only encrypted bytes to `content.db.pending`, rekeys to `pantas_content_db_key_v1`, promotes atomically, and opens only with that key.
2. RED: wrong manifest/signature/hash/bootstrap key, missing secure-storage key, and unkeyed open all fail closed.
3. Reorder bootstrap so protected verification/install/migration completes before final content database open; retain one user AppDatabase and one protected ContentDatabase.
4. Reopen after simulated process death and prove ordinary SQLite cannot read installed content.
5. Verify lesson/question/mock identifiers and corpus counts/semantics equal the accepted source corpus.

**Gate:** first launch offline works and installed content is not plaintext; `pantas.db` behavior is unchanged.

### Task E04.4: migrate E02 plaintext and make recovery atomic

**Files:**
- Modify: `lib/core/content/bundle/protected_content_installer.dart`
- Modify: `lib/core/content/security/content_key_store.dart` as required by recovery/rotation semantics.
- Create/modify focused migration tests under `test/core/content/bundle/` and `test/core/content/security/`.

**Supported legacy input:** exact E02 shipping `contentSeedVersion` `eb3a9da425b80a51` plus accepted generated release-lane SHA-256 `eb3a9da425b80a51331cce74694ef014c3372392194bacbd60ba145db5ea2a45`. The generated asset is gitignored and is not present in a fresh checkout, so E04 must obtain/regenerate the exact approved payload and reverify its digest before migration fixtures use it. Any other plaintext installed DB is an explicit unsupported/newer-content state, not a generic legacy seed.

**Steps:**
1. Test E02 plaintext upgrade while preserving original until the independently keyed result validates.
2. Test interrupted boundaries, insufficient disk, incompatible schema, corrupt package, missing key, wrong key, replay/downgrade, version/key rotation, and failed promotion.
3. On key loss, rebuild from signed offline bundle only when that cannot silently discard a known newer content revision.
4. Preserve previous valid encrypted content until the replacement passes all checks.
5. Audit `-wal`, `-shm`, `-journal`, pending/previous files; document best-effort deletion without forensic-erasure claims.

**E04 verification gate:** focused RED/GREEN tests; relevant existing content tests; `flutter test` if feasible/required by repository policy; `flutter analyze`; build-runner/codegen if schema-facing code changes; content validators; no-AI-attribution check; changed-Dart formatting; `git diff --check`; protected user-data regression tests. Commit/push only after exact branch ownership verification.

## E05 — QLP-1 metadata selection + batched hydration

### Task E05.1: introduce lightweight selection rows

**Files:**
- Create: `lib/core/storage/domain/question_selection_row.dart`
- Modify: `lib/core/storage/data/repos/content_repository.dart`
- Create: `test/core/storage/data/repos/content_repository_selection_test.dart`

**Interfaces:**
- `selectionRowsByExam(ExamId)`
- `selectionRowsByTopic(TopicId)`
- `hydrateSelectedQuestions(List<QuestionId>)`

**Steps:**
1. RED: selection rows expose only ID/version/topic/lesson/passage/figure metadata and never stem/explanation/choices/rationales/passage body.
2. RED: selected hydration returns full `Question` objects in caller-supplied order with existing deterministic choice order.
3. Implement metadata queries without per-question hydration.
4. Implement bounded batch reads for selected question rows, choices, exam memberships, and distinct passages; reconstruct in memory by ID.
5. Preserve missing/withdrawn question behavior explicitly and test it.

### Task E05.2: adapt Today backlog/selection without changing policy

**Files:**
- Modify: `lib/features/quiz/presentation/today_providers.dart`
- Modify only where required under `lib/features/quiz/domain/picker/`, `domain/selectors/`, `domain/use_cases/build_today_plan.dart`. Prefer adapters over rewriting selector rules.
- Modify: `lib/features/quiz/domain/use_cases/start_today_session.dart` fallback path so it uses metadata selection then selected hydration.
- Modify: `lib/features/quiz/domain/use_cases/resume_session.dart` and `restart_session.dart` to batch hydrate saved IDs.
- Tests under `test/features/quiz/domain/`, `test/features/quiz/presentation/`, and repository tests.

**Gate:** due/weak/fresh counts, recommended topic, session length, ordering mode, new-card cap, IDs/order, origin/topic labels, resume/restart ID order all match pre-optimization fixtures.

### Task E05.3: add/verify indexes for new and upgraded protected DBs

**Files:**
- Modify: `lib/core/content/content_database.dart` and generated file via build_runner.
- Add migration/query-plan tests under `test/core/content/`.

**Steps:**
1. Capture `EXPLAIN QUERY PLAN` for selection/hydration queries before index changes.
2. Add only indexes proven necessary by those predicates/joins.
3. Increment content schema exactly once in E05 if required; migration from E04 schema must create identical indexes to a fresh DB.
4. Run generated-schema/migration tests and compare fresh-vs-upgraded index sets.

**E05 verification gate:** bounded query count, query-plan proof, policy/data equivalence, full focused quiz/content suite, analyze/format/diff/content/layering gates.

## E06 — QLP-2 / QLP-3 / QLP-4

### Task E06.1: prepare Today once and share it across panel/Start

**Files:**
- Create: `lib/features/quiz/application/today_quiz_preparer.dart`
- Create: `lib/features/quiz/application/quiz_preparation_stamp.dart`
- Modify: `lib/features/quiz/application/quiz_providers.dart`
- Modify: `lib/features/quiz/presentation/today_providers.dart`
- Modify: `lib/features/quiz/presentation/widgets/session_panel.dart`
- Modify: `lib/features/quiz/presentation/quiz_tab_home.dart`
- Add tests under `test/features/quiz/application/` and `test/features/quiz/presentation/`.

**Frozen result:** `PreparedTodaySession` carries the already-built plan, ordered IDs, content/day/preferences/session-state stamp, and preparation time. Preview creates no DB session.

**Steps:**
1. RED: panel preparation happens once and Start consumes the same immutable prepared object.
2. RED: the study-first nudge “Start anyway” consumes the same prepared object instead of rebuilding after the modal.
3. RED: unchanged panel rebuild does not repeat preparation.
4. Implement preparer/provider ownership above presentation widgets.

### Task E06.2: one launch owner and exactly one persisted session

**Files:**
- Create: `lib/features/quiz/application/quiz_launch_coordinator.dart`
- Modify: `lib/features/quiz/presentation/quiz_controller.dart`
- Modify: `lib/features/quiz/presentation/quiz_page.dart`
- Modify: `lib/features/quiz/domain/use_cases/start_today_session.dart` to accept/revalidate prepared data without reselecting.
- Modify providers/tests accordingly.

**Steps:**
1. RED: rapid/repeated Start calls coalesce to one persistence owner/one `quizSessions` row.
2. RED: stale preparation is rejected/recomputed before persistence.
3. RED: Resume reads saved session and never creates a replacement.
4. RED: navigation away before persistence prevents late session creation/navigation; navigation after commit leaves one resumable session.
5. Implement coordinator and route all Today Start surfaces through it.

### Task E06.3: close terminal persisted sessions transactionally

**Files:**
- Modify: `lib/features/quiz/domain/use_cases/complete_quiz.dart` or create one application completion coordinator.
- Modify: `lib/features/quiz/data/repos/quiz_session_repository.dart` only as needed for transactional completion.
- Modify: `lib/features/quiz/presentation/quiz_controller.dart`.
- Focused tests under `test/features/quiz/domain/`, `data/`, `presentation/`, plus release E2E quiz regression.

**Gate:** once the final answer/attempt completes, the session has `completedAt` and cannot be returned by `activeFor`; failure before commit does not falsely terminalize it; attempt/session identity used by debrief remains stable.

### Task E06.4: complete-answerable readiness + response timing + Retry intent

**Files:**
- Modify: `lib/features/quiz/presentation/quiz_page.dart` and the exact question/passage/figure presentation components discovered at E06 preflight.
- Modify: `quiz_controller.dart` timing state only as needed.
- Tests: existing `quiz_page_test.dart`, passage/figure tests, controller tests, retry/route tests.

**Steps:**
1. RED: timer does not start until stem + active choices + required passage + required figure are complete and answer controls are enabled.
2. RED: rebuild does not reset timer.
3. RED: prepared Next requires no selection/hydration cycle.
4. RED: Retry preserves source mode/scope and does not create duplicate persistence.
5. Implement one readiness signal and use it as timing origin.

### Task E06.5: freshness, cancellation, lifecycle, bounded memory

**Files:**
- Modify: `today_quiz_preparer.dart`, `quiz_preparation_stamp.dart`, providers/coordinator.
- Add narrowly scoped authoritative session/review revision storage only if existing state cannot correctly invalidate sync-driven mutations. If a persisted field/table is required, E06 alone owns that user-schema change and its migration/tests.

**Freshness inputs:** protected content revision, local day, exam/topic scope, QuizPreferences, session/review mutation signal, active-session state.

**Gate:** day rollover/content update/preferences/history/session change invalidates; process death does not pretend preparation survives; background return revalidates; all-due stays full rather than being silently capped; selected-object memory is bounded.

**E06 verification gate:** real Quiz tab panel, study-first nudge, direct Today route, Resume, Retry, passage/figure readiness, and terminal-session tests; focused full quiz suite; analyze/format/diff/layering.

## E07 — CP-T4 leakage and serving-path audit

**Planned write ownership:** security-related fixes only after evidence proves a concrete issue. Do not refactor unrelated content/quiz code.

**Inspect at minimum:**
- `lib/core/content/sanity/sanity_client.dart`, `sanity_config.dart`, `groq_queries.dart`, sync construction sites;
- release `--dart-define` inputs and `tools/release/android/release.sh`;
- logging/telemetry/crash/support/export paths;
- `tools/build_content_*`, generated artifacts, ignored/unignored build outputs;
- CI/workflow artifact publication only if present/relevant; workflow edits require explicit E07 ownership;
- direct Sanity/CDN/storage/CMS behavior using non-secret public probes where authorized.

**Tests/evidence:** static scans for fixture bodies/answers/private keys/bootstrap key in disallowed outputs; release logs with redaction; direct endpoint evidence; configuration evidence showing whether App Check/auth is actually in-path.

**Stop:** if equivalent corpus is publicly queryable through an active release serving path, do not claim CP closure. Publish exact exposure and remediation/acceptance requirement.

## E08 — guarded combined integration

**Ownership:** integration branch only. No new feature work unless a merge exposes a concrete integration defect.

**Steps:**
1. Pin accepted E04/E05/E06/E07 heads and parent relationships.
2. Guarded fast-forward/cherry-pick only according to orchestrator policy; no reimplementation.
3. Resolve shared-file conflicts by reconciling against E03 spec, not by choosing the newest text blindly.
4. Run focused protected-content + quiz suites, codegen/migrations, analyze, format, content/layering checks, `git diff --check`.
5. Record exact combined source SHA and protected `content.db`/manifest digest.

**Gate:** one clean combined candidate with no unresolved semantic conflict.

## E09 — CP-T5 source/device + QLP-5/QLP-6

**Ownership:** evidence and bounded instrumentation only. Product fixes return to the correct earlier stage and invalidate affected evidence.

### Security scenarios

Fresh offline install; exact E02 plaintext migration; ordinary protected reopen; wrong/missing key; altered package/manifest/signature; interrupted install/update; process death; key-loss recovery; downgrade/replay; journals/WAL/temp; backup/restore behavior; user `pantas.db` preservation.

### Performance scenarios/method

Physical lower-end Android preferably 3–4 GB RAM/60 Hz plus mainstream comparison; ≥30 observations per ordinary scenario; median/p95/max; cold/warm split; exact source/content/device/build provenance. Capture recommendation, Start, cold route, 5/10/20 Resume, prepared Next, first answerable frame, query counts, memory, build/raster/missed frames. Include UPCAT/CSE Pro/custom, history sizes, all-due/75/100-like long fixtures, plain/math/passage/diagram, offline/background/day rollover/content upgrade.

**Targets:** use the exact proposed targets in the E03 spec. Failure means evidence-backed optimization/fix returns to E05/E06, then E08/E09 rerun.

### QLP-6 final source verification

Run focused regressions plus full `flutter test`, `flutter analyze`, formatting, `git diff --check`, no-AI-attribution check, content/layering validators, migration/codegen checks. Record exact failures, never summarize a skipped suite as passed.

**Gate:** unchanged source/content candidate accepted for E10.

## E10 — three isolated final Release E2E passes

**Source:** exact accepted E09 candidate plus one already-materialized, unchanged protected-package identity: exact payload bytes, manifest bytes, detached-signature bytes, `sourceContentSha256`/`contentSeedVersion`, recorded package digests, key/profile/schema metadata, and source Git SHA.

**Runner contract:** reuse the accepted Release E2E runner/harness and six journeys from `docs/superpowers/plans/2026-09-05-release-e2e-implementation.md`, with provenance companion hardening preserved.

**Steps:**
1. Verify candidate/toolchain/device/emulator provenance and exact protected-package identity before Run 1, including `sourceContentSha256`, `contentSeedVersion`, `payloadSha256`, manifest SHA-256, detached-signature SHA-256, key IDs/profile/schema, and source Git SHA.
2. Run complete six-journey suite from isolated state.
3. Reset only through the approved deterministic isolation path.
4. Repeat complete suite for Runs 2 and 3 without source modification or protected-package regeneration. All three runs use the same payload + manifest + detached-signature bytes.
5. Compare provenance and per-scenario results across all three; any protected-package identity drift invalidates the three-pass set.

**Gate:** 3/3 complete passes. Any source/content fix returns to the appropriate earlier stage; no “two plus one old plaintext run” substitution.

## E11 — independent final source/E2E review

**Read-only ownership.**

Review exact E03 spec/decisions, E04–E09 implementation/evidence, E10 logs, source/content hashes, git history, protected package, migration, quiz policy equivalence, terminal session fix, performance methodology/results, unsupported-claim scan, and all residual risks.

**Gate:** independent reviewer explicitly accepts one exact source SHA for production artifact build. Findings that require code send the program back; reviewer does not self-fix.

## E12 — signed production AAB

**Authorized release-builder ownership only.**

1. Verify exact E11 source, clean worktree, and exact protected-package identity accepted by E10/E11.
2. Resolve production signing inputs and required content bootstrap key build input without exposing them.
3. Resolve legal version identity if Play history is available; otherwise mark local identity provisional and not upload-eligible.
4. Build exactly one production signed AAB with the pinned toolchain, packaging the exact accepted protected package without regenerating ciphertext, manifest, or detached signature.
5. Record AAB SHA-256, source SHA, `sourceContentSha256`, `contentSeedVersion`, `payloadSha256`, manifest SHA-256, detached-signature SHA-256, key/profile/schema metadata, version identity, and signing provenance.

**Gate:** artifact exists from exact E11 source and exact E10/E11 protected package; no code/content/protected-package regeneration afterward. Any explicitly authorized regeneration creates a new package identity and requires affected E09/E10/E11 evidence to be rerun before AAB acceptance.

## E13 — CP-T5 signed-artifact inspection

**Read-only artifact verifier.**

Inspect exact AAB and APKs derived from it:
- package entry inventory;
- manifest/signature/protected SQLite assets;
- ordinary unzip/strings/plain SQLite attempts against known fixture/corpus markers;
- no raw `v1.json`/alternate corpus;
- no signing private key/server credential/plain per-install key;
- bootstrap key residual risk explicitly recorded;
- source/content/artifact provenance equality;
- signing/version metadata.

**Gate:** exact artifact accepted. If artifact generation/source/content changes, rerun E12/E13.

## E14 — upload-eligibility freeze

**Owners:** root orchestrator for evidence; Aedwon for explicit residual-risk decision.

Required inputs:
- accepted E13 artifact SHA;
- legal Play release history and final `versionCode`/`versionName`;
- all engineering blockers closed;
- current commercial/Play configuration reconciled in the authorized human/Play lane;
- explicit Aedwon acceptance of the recoverable `content-bootstrap-v1` client-key residual risk.

**Output:** one frozen upload-eligible artifact identity. No upload is performed unless a separately authorized release task explicitly includes Google Play mutation.

## Cross-stage verification discipline

Every implementation worker must record:
- exact parent/base SHA and final head;
- changed-file list and ownership proof;
- focused RED/GREEN tests actually run;
- required full/static/content/layering checks actually run;
- `git diff --check`;
- clean worktree;
- guarded push and remote equality;
- explicit blockers/residual risks.

Every downstream verifier must reject evidence if source SHA, content digest/manifest, device/build mode, or artifact hash differs from the candidate whose result is being claimed.

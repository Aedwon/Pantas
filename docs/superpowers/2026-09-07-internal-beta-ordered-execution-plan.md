# Pantas internal-beta ordered execution plan — authoritative E01–E14

> This file replaces the stale Release-E2E-first ordering. Astra Google Drive Master SSOT revision 54 is the scheduling authority. The exact engineering baseline for E03 is `ba536e73dbda455b994291eb551c2d6b0bd5286d`. Domain details live in the E03 execution spec and E04–E14 implementation plan.

## Non-negotiable sequencing rules

1. `main` remains read-only. Work proceeds on explicitly assigned branches/worktrees only.
2. E02 baseline evidence is preserved, but earlier plaintext-baseline E2E passes do not count as E10.
3. E03 is documentation/read-only discovery only: CP-T0 + QLP-0. It does not dispatch or implement E04.
4. Content/security foundation precedes data/performance implementation: E04 before E05; E05 before E06.
5. CP-T4 follows implementation so it can inspect the real protected path; combined integration follows at E08.
6. Performance and source/device security evidence at E09 must exercise the final encrypted content path.
7. Full Release E2E is E10, after E09, three isolated passes on an unchanged candidate **and one unchanged protected package identity** (payload + manifest + detached signature).
8. Independent review precedes the final signed AAB.
9. Signed-artifact extraction proof happens after the artifact exists, at E13.
10. Upload eligibility is E14 and requires both legal Play release identity and explicit founder acceptance of the documented recoverable bootstrap-key residual risk.

## Engineering lane

### E01 — baseline pin and evidence inventory

**Owner:** root orchestrator.

**Purpose:** identify the exact paused candidate, preserve accepted/unintegrated repairs, and stop stale documentation from becoming execution authority.

**Required evidence:** exact repository/branch/SHA, worktree ownership, accepted repair SHAs, Release E2E runner/harness state, open defects, current Drive scheduling revision, current Pantas `#21` checkpoint.

**Exit:** one exact candidate and one accepted evidence inventory. No source integration beyond the work explicitly assigned to E01/E02.

### E02 — accepted repair/provenance integration

**Owner:** one integration owner.

**Purpose:** integrate the already-completed Firestore reset, anonymous deletion, review-log/provenance companion hardening, and required baseline repair evidence into the candidate.

**Accepted exit for this program:** `web/release-e2e-r1@ba536e73dbda455b994291eb551c2d6b0bd5286d`.

**Important:** this is baseline verification. It is not final Release E2E acceptance and it does not prove protected content packaging.

### E03 — CP-T0 + QLP-0 design/security preflight

**Owner:** design/security planning owner.

**Branch/worktree:** `web/e03-cp-t0-qlp0-plan-r1` / `Pantas-wt-web-e03-cp-t0-qlp0-plan-r1`.

**Allowed changes:** `docs/superpowers/**` only.

**CP-T0:** trace actual content authoring/build/package/install/open/update/export/remote surfaces; freeze manifest, key, migration, bootstrap-order, function/test, and residual-risk contracts. Verify that the retired JSON runtime reader remains retired.

**QLP-0:** verify historical quiz-loading findings against E02; freeze current preference/selection/history/session semantics, preparation/launch interfaces, freshness invalidation, batching/index boundaries, readiness/timing semantics, and E09 measurement method.

**Exit:** exact file/test map and implementation contracts, plus explicit dependent blockers. No code worker dispatch.

### E04 — CP-T1 + CP-T2 + CP-T3 protected content foundation

**Owner:** one storage/content implementor under one integration owner.

**Depends on:** accepted E03 docs.

**Order inside E04:**
1. CP-T1 release packaging + signed manifest;
2. CP-T2 protected install/open;
3. CP-T3 migration, interruption, key-loss, update/recovery.

**Hard preflight:** prove the exact project sqlite3mc build supports the planned content encryption/rekey flow and that it does not require plaintext on-disk staging. Upstream documentation alone is not acceptance. If this fails, stop the dependent content path for a design ruling rather than silently falling back to plaintext.

**Exit:** authenticated protected release seed, separate per-install content key, keyed content opener, atomic migration/update, negative/tamper tests, offline first launch, process-death/reopen, key-loss and rollback/replay handling; user `pantas.db` behavior unchanged.

### E05 — QLP-1 lightweight selection and bounded hydration

**Owner:** content/data implementor.

**Depends on:** accepted E04 protected content database interfaces.

**Purpose:** remove full question-body/choice hydration from selection and eliminate per-question choice/exam round trips. Add the required indexes to both freshly created and upgraded content databases.

**Exit:** selection metadata contains no stem/explanation/choice payload; selected hydration preserves exact ID/order/version/choice order/passages/figures; query count grows by bounded chunks, not O(selected questions) hydration calls; `EXPLAIN QUERY PLAN` validates shipping/upgrade indexes.

### E06 — QLP-2 + QLP-3 + QLP-4 prepared launch and readiness

**Owner:** one quiz application/presentation implementor.

**Depends on:** E05 and E03 policy/terminal rulings.

**Order inside E06:**
1. QLP-2 immutable prepared Today result and one launch owner shared by Quiz/Home/Start/nudges;
2. terminal-session completion correctness, so completed sessions cannot remain resumable;
3. QLP-3 complete-question readiness, response timing, and intent-preserving Retry;
4. QLP-4 freshness, cancellation, lifecycle, and bounded-memory behavior.

**Exit:** preview creates no session; Start persists exactly once; warm Start does not reselect/reload scope; Resume uses saved IDs/order and creates no replacement; Retry preserves source intent; required passage/diagram readiness gates answers; day/content/preferences/history changes invalidate stale prepared results; navigation cancellation has deterministic pre/post-persistence behavior.

### E07 — CP-T4 leakage and serving-path audit

**Owner:** security implementor/reviewer with read access to the integrated content path; backend mutation requires separate authorization.

**Depends on:** E04–E06 implementation.

**Purpose:** verify that content bodies, answer keys, decrypted payloads, content keys, signing private material, and content download credentials do not leak through logs, crash fixtures, analytics, support exports, or public CI artifacts. Audit actual Sanity/storage/CMS serving exposure and release configuration.

**Exit:** local and remote exposure is evidenced, not assumed. App Check/auth may be credited only on a serving path where they are actually enforced. Any publicly queryable equivalent corpus is a release blocker for the claimed protection boundary until explicitly accepted/remediated.

### E08 — combined integration

**Owner:** one integration owner.

**Depends on:** independently accepted E04, E05, E06, E07 branches.

**Purpose:** integrate the protected content foundation, optimized selection/hydration, prepared launch, and leakage fixes without concurrent edits to shared schema/installer/opener/repository files.

**Exit:** one exact combined SHA and content digest; focused content/quiz/security tests plus repository-required static/content/layering gates green; no unresolved merge semantics.

### E09 — CP-T5 source/device phase + QLP-5 + QLP-6

**Owner:** independent performance/security verifier and final orchestrator.

**Depends on:** unchanged E08 candidate.

**Security evidence:** fresh install offline, legacy plaintext upgrade, process death, key loss, failed/altered package, update rejection, backup/restore behavior, encrypted content reads, journal/temp-file inspection.

**Performance evidence:** physical lower-end Android, preferably 3–4 GB RAM and 60 Hz, plus a mainstream comparison device. At least 30 observations per ordinary scenario; report median, p95, maximum, cold/warm separately, query counts, memory, complete-answerable-frame, and missed frames.

**Proposed review targets:** Start/Retry feedback ≤100 ms; first recommendation p95 ≤1,000 ms after databases are available; unchanged recommendation next usable frame with no preparation; warm Start p95 ≤500 ms; cold daily route after bootstrap p95 ≤1,500 ms; ordinary 5/10/20 Resume p95 ≤1,000 ms; prepared Next p95 ≤100 ms; on 60 Hz hardware p95 build/raster within 16.7 ms with missed frames reported. These are acceptance targets to measure, not claims about E02 speed.

**Scenario coverage:** UPCAT, CSE Professional, custom tracks; empty/mixed/substantial history; ordinary/all-due lengths; plain/math/passage/diagram first questions; offline use; background return; day rollover; content upgrade; long fixtures including 75/100-question attempt-like history where applicable.

**Exit:** source/device CP-T5 evidence plus QLP-5 measurements and QLP-6 focused/full verification are accepted on one unchanged source/content pair.

### E10 — final Release E2E acceptance

**Owner:** Release E2E verifier/orchestrator.

**Depends on:** accepted E09 candidate, unchanged source/content digest.

**Run:** the approved six-journey Release E2E program from `docs/superpowers/plans/2026-09-05-release-e2e-implementation.md` through the hardened runner/harness, from isolated state, **three complete times**.

**Exit:** all required journeys pass all three runs with exact candidate/content/toolchain/device/Firebase-emulator provenance. Earlier plaintext-baseline runs remain historical only.

### E11 — independent final source and E2E review

**Owner:** independent reviewer with no implementation ownership.

**Depends on:** unchanged E10 source candidate.

**Review:** E03 contracts, E04–E09 evidence, E10 three-pass logs/provenance, residual risks, protected diff, test/static gates, and absence of unsupported security/performance claims.

**Exit:** exact source SHA accepted for production artifact build, or a concrete defect sends the program back to the appropriate earlier stage.

### E12 — signed production AAB

**Owner:** authorized release builder.

**Depends on:** accepted E11 source.

**Purpose:** build one signed production AAB from the exact accepted source using the verified release toolchain and the exact protected package accepted by E10/E11. Do not rebuild/regenerate corpus or protected-package bytes during artifact generation; authorized regeneration invalidates affected downstream evidence and requires rerun.

**Version identity rule:** if Play release history is not yet available, the local artifact identity is provisional evidence only and is not an upload-eligibility freeze.

**Exit:** exact source SHA, AAB path, signing/build configuration, version identity, and SHA-256 recorded.

### E13 — CP-T5 signed-artifact phase

**Owner:** independent artifact/security verifier.

**Depends on:** exact E12 AAB and generated APKs derived from it.

**Inspect:** package entries, encrypted seed/manifest/signature, ordinary unzip/strings/SQLite extraction resistance, wrong/tampered manifest/payload behavior where testable, secret/key leakage, signing/provenance, and source/artifact equality. Explicitly document the recoverable client bootstrap key instead of hiding it.

**Exit:** exact artifact passes CP-T1–CP-T4 artifact assertions and provenance checks. Any source/content change requires a new E12/E13 cycle.

### E14 — upload-eligibility freeze and security closure

**Owner:** final orchestrator + Aedwon for explicit residual-risk acceptance.

**Depends on:** accepted E13.

**Must resolve:** legal Play `versionCode`/`versionName` against actual release history; exact upload artifact identity; all engineering blockers; explicit founder decision on the recoverable-client-bootstrap-key residual risk.

**Exit:** one upload-eligible frozen artifact. E14 authorizes no upload by itself unless the assigned release task explicitly includes Play mutation.

## Parallel founder / Play / human lane

These tasks may proceed independently when they do not mutate the engineering candidate or consume credentials in an unauthorized worker:

1. **Play account readiness:** developer identity, payments profile/device verification, release-history access, account policy status.
2. **Tester readiness:** Internal testing roster; later closed-test cohort and buffer; license testers; feedback/issue intake.
3. **Commercial configuration:** current product/subscription/RevenueCat production setup using the live commercial SSOT. The current weekly pin is PHP 149/week; stale historical price tables are not authoritative.
4. **RTDN and backend operations:** prepare endpoint/project/topic/service-account requirements, but production mutation requires an explicitly authorized task.
5. **Physical devices:** lower-end performance phone for E09, mainstream comparison phone, Play-installed acceptance device, OEM/notification/accessibility coverage.
6. **Store/legal/privacy:** listings, declarations, privacy/account-data flows, release notes, policy forms, support channel.
7. **Post-freeze Play-installed acceptance:** after engineering/artifact gates and appropriate Play authorization, verify install/update, Firebase/Auth/sync, App Check/Play Integrity, billing/RevenueCat lifecycle, product smoke, accessibility, notifications/runtime, privacy and account-data behavior on the Play-delivered build.

## Protected package provenance rule

The protected package has two identities: stable logical/source identity (`sourceContentSha256` + `contentSeedVersion`) and exact generated artifact identity (`payloadSha256` + manifest SHA-256 + detached-signature SHA-256, plus key/profile/schema metadata and source Git SHA). Randomized SQLCipher/sqlite3mc protection may change exact payload bytes across builds without changing logical content. E10 therefore pins one already-materialized protected package for all three passes, and E12 must package that exact accepted package. A new protected-package generation invalidates affected evidence even when the logical source revision is unchanged. No deterministic/fixed SQLCipher salt is authorized merely to force reproducible ciphertext.

## Evidence invalidation rules

- Any modification to content source, generated protected content, manifest, bootstrap/signing key ID, schema, installer/opener, selection/hydration, launch/readiness, or relevant release configuration invalidates affected downstream evidence.
- E09 measurements cannot be reused after a performance-relevant or encrypted-path change.
- E10 cannot use E02 plaintext-baseline E2E runs.
- E11 acceptance is source-specific.
- E12/E13 are artifact-specific.
- A new source commit after E12 invalidates that artifact even if the change appears documentation-only when provenance rules include source SHA.

## Current position

E01 and E02 are historical/accepted inputs. **E03 is the current stage.** No E04 branch, worker, implementation, build, Play action, Android/Firebase E2E run, or AAB action is authorized by this document.

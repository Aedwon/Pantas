# E04 Protected Install/Migration R3 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. TDD is mandatory for behavior changes.

**Goal:** Complete E04.3/E04.4 protected-content install/open/migration/recovery against the approved September 8 manifest-v2 and quiz-policy contracts without touching E05+, production secrets, `main`, deployment, AABs, or Play.

**Architecture:** Build on the accepted recovery-r2 E04.1/E04.2 implementation lineage plus the September 8 contract amendments. Production package verification stays fail-closed while the production Ed25519 public key is absent; all installer/migration TDD uses test-owned ephemeral signing/bootstrap keys. The runtime path verifies the bundled v2 package, installs/rekeys encrypted content under a per-install key, persists device-local anti-replay/promotion metadata, opens only keyed content, and recovers atomically across interruption/key-loss/legacy migration boundaries.

**Tech Stack:** Flutter/Dart, sqlite3/sqlite3mc, `cryptography` 2.9.0, secure storage, Riverpod/bootstrap wiring, existing repository test tooling.

**Spec:** `docs/superpowers/specs/2026-09-07-e03-content-protection-quiz-launch-execution-spec.md`

## Global Constraints

- Production manifest wire format is v2 with signed positive monotonic `releaseSequence`; production rejects v1.
- Hashes identify revisions/artifacts and never order releases.
- No plaintext on-device staging or plaintext fallback.
- Do not reuse `pantas_db_key`; installed content uses `pantas_content_db_key_v1`.
- Runtime anti-replay accepted-package state and promotion intent are device-local protected-content metadata outside account/user reset lifetimes.
- Signing/bootstrap IDs honor sequence validity windows; unknown/retired IDs fail closed.
- Production signing/bootstrap private material is never generated, inspected, logged, committed, or requested. Tests use only ephemeral fixture-owned keys.
- Missing authorized production `content-signing-v1` public verification key remains a production-acceptance blocker, not a blocker to fixture-key E04.3/E04.4 work.
- E02 plaintext migration accepts only `contentSeedVersion=eb3a9da425b80a51` and SHA-256 `eb3a9da425b80a51331cce74694ef014c3372392194bacbd60ba145db5ea2a45` after fresh verification.
- Preserve user `pantas.db`, progress, IDs/order/semantics, offline first launch, and one user AppDatabase + one protected ContentDatabase.
- Do not implement E05+, alter pricing, touch `main`, deploy, build/publish final AABs, or use Play.

---

### Task 1: Manifest-v2 runtime verifier migration

**Files:**
- Modify: `lib/core/content/security/content_package_manifest.dart`
- Modify: `lib/core/content/security/content_signing_keys.dart`
- Modify/Create: `lib/core/content/security/content_package_verifier.dart`
- Modify: protected package builder/release verifier only where v2 runtime parity requires it
- Test: focused manifest/verifier/key-window tests under `test/core/content/security/` and `test/tool/`

**Interfaces:**
- Consume the spec's v2 manifest exact fields and key-window rules.
- Produce `ContentPackageVerifier.verifyBundled()` returning only fully authenticated `VerifiedContentPackage` instances.

- [ ] Write focused RED tests for v1 production rejection, missing/nonpositive `releaseSequence`, lower-sequence replay, equal-sequence different-identity fork, unknown/retired/out-of-window signing/bootstrap IDs, and valid overlap windows using ephemeral fixtures.
- [ ] Run focused tests and record expected REDs proving missing behavior.
- [ ] Implement the minimal v2 parser/verifier/key-window behavior without custom crypto or production key invention.
- [ ] Re-run focused tests to GREEN; preserve earlier E04.2 tamper/source/payload/bootstrap/profile/schema checks.
- [ ] Commit this independently reviewable slice.

### Task 2: Per-install key store and protected first install/open

**Files:**
- Create/Modify: `lib/core/content/security/content_key_store.dart`
- Create/Modify: `lib/core/content/bundle/protected_content_installer.dart`
- Modify: `lib/core/content/content_database_opener.dart`
- Modify: `lib/core/content/content.dart`
- Test: focused key-store/install/open tests under `test/core/content/security/` and `test/core/content/bundle/`

**Interfaces:**
- Produce the frozen `ContentKeyStore`, `ensureProtectedContentInstalled(...)`, and `openProtectedContentDatabase(...)` contracts.

- [ ] RED: fresh offline install authenticates package, writes only encrypted pending bytes, rekeys pending directly from bootstrap key to independent per-install key, validates/reopens keyed DB, and atomically promotes.
- [ ] RED: missing/wrong bootstrap key, wrong secure-storage key, unkeyed open, tampered pending payload, and schema/corpus mismatch fail closed without touching user DB.
- [ ] Implement minimal key-store/install/open behavior using the already-proven sqlite3mc content profile; no plaintext secondary output.
- [ ] GREEN: prove ordinary SQLite cannot read the installed DB and keyed reopen preserves accepted corpus IDs/counts/semantics.
- [ ] Commit this independently reviewable slice.

### Task 3: Device-local accepted-package state and crash-safe promotion

**Files:**
- Modify: `lib/core/content/bundle/protected_content_installer.dart`
- Create/Modify: focused device-local metadata helper under the content installation layer if needed
- Test: `test/core/content/bundle/` promotion/recovery tests

**Interfaces:**
- Persist accepted `formatVersion`, `releaseSequence`, exact package identity, previous accepted identity, and in-flight promotion intent beside protected content—not in `pantas.db` or account preferences.

- [ ] RED each required crash boundary: before intent, after intent/before replacement, after active/previous moves but before accepted-state finalization, and after finalization/before cleanup.
- [ ] RED downgrade/equal-fork semantics and account reset/sign-out invariance of anti-replay state.
- [ ] Implement minimal pending/previous/active + intent recovery state machine from the approved spec.
- [ ] GREEN: prove previous valid encrypted content is never simultaneously lost, unaccepted first-install candidates are never marked accepted, and digest ordering is never used.
- [ ] Commit this independently reviewable slice.

### Task 4: E02 plaintext migration and key-loss recovery

**Files:**
- Modify: `lib/core/content/bundle/protected_content_installer.dart`
- Modify: `lib/core/content/security/content_key_store.dart` only where recovery requires it
- Test: migration/key-loss tests under `test/core/content/bundle/` and `test/core/content/security/`

**Interfaces:**
- Accept only the exact freshly verified E02 plaintext corpus identity.
- Preserve unknown/newer plaintext or encrypted states rather than silently replacing them.

- [ ] RED exact E02 plaintext migration preserving source until independently keyed destination validates.
- [ ] RED unsupported plaintext identity, missing key with known newer accepted sequence, incompatible schema, corrupt candidate, insufficient-disk/failure seams, and stale journal/pending/previous cleanup behavior.
- [ ] Implement minimal exact-E02 migration and key-loss recovery rules; offline bundle rebuild is allowed only when it cannot discard known newer accepted content.
- [ ] GREEN: user `pantas.db` and progress remain untouched; unsupported/newer states surface recoverably rather than downgrading.
- [ ] Commit this independently reviewable slice.

### Task 5: Bootstrap/provider integration

**Files:**
- Modify: `lib/app/bootstrap.dart`
- Modify: `lib/core/content/content.dart`
- Modify: relevant content provider/bootstrap tests
- Retire production use of `lib/core/content/bundle/seed_installer.dart` where superseded, preserving useful test seams only.

**Interfaces:**
- Final app retains exactly one live user `AppDatabase` and one protected `ContentDatabase`.
- `bootstrapContentOverrides` ultimately opens through `openProtectedContentDatabase` only after protected verification/install/migration completes.

- [ ] RED: bootstrap cannot open final content DB before protected install/recovery succeeds; Retry/reopen after simulated process death is safe.
- [ ] Implement minimal ordering/provider changes.
- [ ] GREEN: offline first launch, reopen, lesson/question/mock IDs, and one-user/one-content DB ownership contracts pass.
- [ ] Commit this independently reviewable slice.

### Task 6: Close E04-owned analyzer debt and run full E04 gate

**Files:**
- Modify only E04-owned files required to resolve the 22 attributed info-level analyzer findings.
- Do not fold the older bookmarks finding into E04; report it separately.

- [ ] Reproduce the 22 E04-owned analyzer findings on the assigned base/head and categorize them without weakening lint rules.
- [ ] For each real E04-owned finding, make the smallest behavior-preserving cleanup with tests remaining green.
- [ ] Run focused E04.1–E04.4 suites, relevant existing content/storage/bootstrap/release tests, protected user-data regressions, changed-Dart formatting, `flutter analyze`, content validators, `dart run tool/check_layering.dart`, `dart run tool/check_no_ai_attribution.dart`, and `git diff --check`.
- [ ] Audit tracked/untracked files: generated protected package companions remain ignored; no secret/private key material is tracked or printed.
- [ ] Reconfirm historical export SHA-256 `51349cfe24049a282b8dc053c3a01df65d5636e7808b055d3008cead2504ff67` and counts exam 7, lesson 161, mockBlueprint 1, passage 32, question 2357, subject 7, topic 26.
- [ ] If all fixture-backed work is green but the production public key is still absent, commit/push the safe implementation and terminal-handback as `BLOCKED` only on that minimal non-secret public-key gate; do not call E04 production-accepted.

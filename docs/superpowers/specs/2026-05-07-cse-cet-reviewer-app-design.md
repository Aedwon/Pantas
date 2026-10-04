# CSE/CET Reviewer App — Design Document

> **Pricing superseded (4 October 2026).** Prices, plans, and products in this file are historical. The only current prices are in `docs/pricing.md`. Do not quote or implement a price from this file.

**Date:** 2026-05-07
**Status:** Approved, ready for implementation planning
**Target soft launch:** 2026-06-28
**Owner:** Aerol Balayon

---

## 1. Overview

A gamified, learning-focused Flutter mobile reviewer for Philippine-market exam preparation.

### 1.1 Mission

Help Filipino students and CSE candidates pass their exams through evidence-based learning techniques (spaced repetition, deliberate practice, weakness-targeted drills) — not by being yet another test bank.

### 1.2 Launch scope

**Two exams at simultaneous launch:**
- Civil Service Examination — Professional level (CSE Pro)
- University of the Philippines College Admission Test (UPCAT)

**Architecture supports unlimited additional exams via content-only changes** (no code release required). Post-launch expansion order:
1. ACET (Ateneo)
2. DLSUCET (De La Salle)
3. USTET (UST)
4. PUPCET (PUP)
5. CSE Subprofessional

### 1.3 Business model

Freemium with three Pro tiers:

| SKU | Price (PHP) | Notes |
|---|---|---|
| Monthly | ₱99 | Standard subscription |
| Yearly | ₱499 | 7-day free trial |
| Lifetime | ₱1,499 | One-time purchase |

**Ad-free in v1.** Pro unlocks: unlimited mock exams, deep progress analytics, all post-mock analysis features, study plan generator.

### 1.4 Differentiator

vs PH-market competitors (test-bank apps): the FSRS-driven spaced-repetition engine + lessons + score-impact-narrative weakness analysis. Retention and learning effectiveness over short-term engagement metrics.

### 1.5 Constraints driving design

- **PH bandwidth-constrained users** → offline-first architecture mandatory
- **Prepaid payment culture** → low-friction purchase flow, restore-purchase prominent
- **Peso-pricing pressure** → tight unit economics, server costs matter
- **Low ad CPMs in PH** → ad-free with paid tiers (no ad-supported revenue model)
- **Anonymous-first onboarding** → no signup wall before first value

---

## 2. Tech stack (locked)

| Concern | Choice | Rationale |
|---|---|---|
| Mobile framework | Flutter (latest stable, 3.27+) | Single codebase iOS+Android, strong offline-first ecosystem |
| State management | Riverpod 2.x | Compile-safe, testable, fits feature-folder architecture |
| Routing | go_router | Declarative, deep-link friendly, integrates with Riverpod |
| Local DB | Drift (typed SQLite) | Type-safe queries, FTS5 support, codegen reduces bugs |
| At-rest encryption | SQLCipher (via `sqlcipher_flutter_libs`) | Industry-standard local encryption |
| Models | Freezed + json_serializable | Immutable, exhaustive switch, easy serialization |
| HTTP | dio | Interceptors (App Check, retry, logging) |
| Lint | very_good_analysis + custom layering rule | Strict baseline + enforce architecture |
| Testing | flutter_test, mocktail, integration_test, @firebase/rules-unit-testing | Standard Flutter + Firebase rules |
| Content CMS | Sanity | Managed, Portable Text, schema-as-code, role-based access |
| Backend-as-a-Service | Firebase | Auth, Firestore, FCM, Crashlytics, Analytics, Remote Config, Functions, App Check, Hosting (region: `asia-southeast1`) |
| In-app purchase | RevenueCat (purchases_flutter) | Cross-platform unification, webhook → entitlement claim |
| Auth | firebase_auth + google_sign_in + sign_in_with_apple | Anonymous-first, OAuth-only (no email/password) |
| Spaced repetition | FSRS-4.5 (pure Dart port) | Best-in-class algorithm, reproducible from paper |
| CI/CD | GitHub Actions + Codemagic/Fastlane | Standard mobile pipeline |

---

## 3. Data layer

### 3.1 Sanity content schema

Content store. Editorial workflow with status lifecycle. App fetches `status: 'published'` only.

**Document types:** `exam`, `subject`, `topic`, `question`, `lesson`, `mockExam`, `mockBlueprint`, `diagnosticSet`, `person`, `glossaryTerm` (post-launch).

**Key design decisions:**

- **`question.examIds` is M:M** — one question can belong to multiple exams (e.g., vocabulary question reused across UPCAT, ACET, DLSUCET). Reduces authoring duplication.
- **Per-choice `isCorrect: bool`** with validation rule: `≥1 isCorrect:true` required for `published` single/multi-choice questions.
- **Status lifecycle:** `draft → in_review → published → retired`. App reads `published` only. Editorial workflow is the QA mechanism.
- **`question.supersedes`** field for versioning. When v2 is published, in-flight attempts complete with v1; new attempts use v2. Both versions retained for audit.
- **`question.flagCount`, `question.needsReview`** — server-mutated quality signals. User-flagged questions surface to editorial dashboard.
- **`mockBlueprint.topicWeights` and `difficultyDistribution`** — both must sum to 1.0 per section (Sanity validation rule).
- **`question.language`** — `'en' | 'fil'`. UPCAT Language Proficiency content includes Filipino questions.
- **`question.provenance`** — `author`, `reviewers[]`, `sourceReference`. Audit trail for content origin.

**Maintainability:**
- Adding a new exam = create `exam` doc + tag relevant questions/topics with `examIds`. Zero code changes.
- Sanity Studio auto-generates the editor UI from schema. No custom CMS to maintain.
- Validation rules catch authoring bugs at write time (e.g., a question with no correct choice cannot be marked `published`).

**Security posture:**
- 2FA mandatory on all editor accounts.
- Role-based access: `editor` (drafts only), `reviewer` (can mark `in_review`), `publisher` (can publish; only owner + designated reviewers).
- Read-only API token shipped to app via Cloud Function proxy (token never embedded in app binary).
- Editorial workflow itself is defense — compromised editor account can only push drafts; app never fetches drafts.
- Zero PII in Sanity. Worst-case content breach = question bank leak (annoying, recoverable, no RA 10173 violation).

**Residual risks:**
- Insider threat (publisher with hostile intent) → dual-control on `publish` for high-stakes content (mock exams).
- Token theft via app decompilation → App Check is the actual defense, not token secrecy. Quarterly rotation as belt-and-suspenders.
- Question scraping by determined attackers → mitigations make this expensive but not impossible. Acknowledged as a known limitation.

### 3.2 Firestore user-data schema

User-state store. Region: `asia-southeast1`. Per-user scoped, security-rules-enforced, offline-persistent.

**Top-level layout:**

```
/users/{uid}
  profile          { displayName, locale, createdAt, lastSeenAt, timezone }
  preferences      { theme, notifications, languagePref, examFocus[] }
  entitlement      { tier, source, expiresAt, lastValidatedAt }    // mirror of JWT claim
  streak           { current, longest, lastActiveDate, freezesRemaining }

  /attempts/{attemptId}                   // every quiz/lesson/mock attempt (immutable)
  /reviewState/{questionId}               // FSRS per-question state
  /goals/{goalId}                         // study plan items
  /events/{eventId}                       // server-authoritative audit log
  /devices/{deviceId}                     // FCM tokens, App Check device IDs

/leaderboards/{period}/entries/{uid}      // optional, post-launch
```

**Key design decisions:**

- **`entitlement` is a mirror, not source of truth.** The Firebase **JWT custom claim** is authoritative. Firestore doc is read-friendly mirror written only by Cloud Function processing RevenueCat webhooks.
- **FSRS state per question, not per user-doc.** Sub-collection writes are cheap; avoids read-rewriting a giant user blob on every review.
- **`qVersion` denormalized** into every attempt and reviewState. User history records what they actually saw, even if Sanity content was later updated/retired.
- **`events` is append-only, server-timestamped.** Streak validation, entitlement changes, suspicious activity flags. Server timestamps prevent clock-manipulation streak abuse.
- **`attempts` stores full question list embedded** (~1-3KB per attempt). Result review renders without N+1 lookups; resilient if Sanity content retired.
- **Attempts older than 18 months archived to BigQuery** via scheduled Cloud Function. Summaries `{date, examId, score, band}` retained in Firestore for trend graphs. Cuts active sub-collection size ~70%.

**Security rules (sketch):**

```
match /users/{uid}/{document=**} {
  allow read: if request.auth.uid == uid;
  allow write: if request.auth.uid == uid && !affectsRestrictedFields(request);
}
match /users/{uid}/entitlement { allow write: if false; }
match /users/{uid}/events/{e}  { allow write: if false; }
match /leaderboards/**          { allow read: if hasProEntitlement(); allow write: if false; }
```

Plus: App Check enforced project-wide; Cloud Function rate-limits on attempt submissions (1/sec/user).

**Cost shape (PH-relevant):**
- Estimate ~$80/mo Firestore at 100k MAU before optimization.
- Mitigations: aggressive Drift caching of user's own data; server-side aggregation for leaderboards.
- `asia-southeast1` region keeps latency ~30ms in PH and avoids cross-region egress fees.

### 3.3 Local Drift cache schema

On-device cache. Encrypted at rest with SQLCipher (AES-256). Key in iOS Keychain / Android Keystore (Strongbox if available).

**Tables:**

```
-- Content (mirrored from Sanity, refreshed via ETag)
exams, subjects, topics, questions, lessons, mock_blueprints

-- FTS5 virtual tables for in-app search
questions_fts, lessons_fts

-- User state (mirrored from Firestore for offline; queue for sync)
attempts_local       (sync_state ENUM('pending','synced','failed'))
review_state_local   (dirty BOOL flag for FSRS sync)
streak_local         (singleton, last_server_reconcile_at)

-- App-internal
sync_log, crash_breadcrumbs
```

**Key design decisions:**

- **JSON blobs for tree-shaped content** (`stem_pt_json`, `choices_json`). Portable Text doesn't normalize cleanly. SQLite JSON1 functions handle queries.
- **FTS5 virtual tables for search** at <50ms even on 50k questions. Enables Retake Mistakes + custom drills.
- **Sync via ETag** — `GET /sync?since=<etag>` returns deltas only. Cuts bandwidth ~95% vs full refresh.
- **`dirty` flag on `review_state_local`** — FSRS updates locally on every review. Background isolate flushes dirty rows on debounced schedule (30s or app background).
- **`attempts_local.sync_state` is a queue** — offline quiz writes locally, background worker promotes to `synced` on Firestore confirmation. Failed pushes retry with exponential backoff up to 5 times.

**Security:**
- SQLCipher encrypts the entire DB file at rest.
- Key derived once and stored in Keychain (iOS) / Keystore Strongbox (Android). Never on disk in plaintext.
- DB file in app sandbox (iOS Documents, Android `getFilesDir()`).
- On root/jailbreak detection: warn user + disable Pro premium-content cache (warn-only — false positives common with PH custom ROMs).
- Crash breadcrumbs pre-redacted: no question content, no answers — only `{screen, action_type, ts}`.
- **No PII in Drift.** `displayName`/`email` lives in Firestore only.

**Storage budget:**
- Content cache: ~50MB compressed (text-heavy Portable Text + LaTeX).
- Image assets via `flutter_cache_manager` with 200MB cap, fetched from Sanity CDN.
- 5 years of attempts at 1.5MB/year, capped ~3MB local after archival.
- **Total app footprint: ~80MB after first full sync.**

**Pre-bundled starter pack:** ~10MB shipped with app binary — ~500 highest-priority questions per launch exam + ~20 lessons. First-launch experience works immediately offline; full library downloads progressively in background.

### 3.4 Cross-cutting principles

#### FSRS state shape

Every `reviewState` doc holds FSRS-4.5 fields:

```
{
  qId, qVersion,
  state: 'new'|'learning'|'review'|'relearning',
  stability: float,            // memory retention strength (days)
  difficulty: float,           // 1.0–10.0, per-user per-card
  due: timestamp,
  lastReview: timestamp,
  reps: int, lapses: int,
  elapsedDays: float, scheduledDays: float
}
```

Pure function `next(prev, rating, now)` where rating ∈ `{Again, Hard, Good, Easy}`. Rating mapped from quiz correctness + response time heuristically. Pure Dart, deterministic, identical on all devices, fully unit-testable.

Reference: FSRS-4.5 (Ye et al., 2023). Default 17-parameter weight vector at launch. Per-user optimization deferred to v2.

#### Data classification (the boundary contract)

| Class | Examples | Where it lives | Encrypted at rest? |
|---|---|---|---|
| Public content | Questions, lessons, exam structure | Sanity → Drift | Drift: yes; Sanity: TLS in transit |
| User progress | Attempts, FSRS state, streak | Firestore + Drift | Both: yes |
| PII | displayName, email, language pref | Firestore only | Yes |
| Entitlement | tier, expiresAt | JWT claim + Firestore mirror | Cryptographically signed |
| Secrets | SQLCipher key, FCM token | Keychain/Keystore | Hardware-backed |
| Telemetry | Crash breadcrumbs (redacted) | Crashlytics | TLS in transit; redacted pre-send |

A field that doesn't fit cleanly is a design smell — reclassify before adding.

#### "No client trust" rule

Three things the client must never compute authoritatively:

1. **Entitlement** — JWT claim, validated server-side on every Cloud Function call.
2. **Streak validity** — local tick is optimistic; server reconciliation with `serverTimestamp()` is truth.
3. **Mock exam scores** — client submits raw answers; Cloud Function computes score using canonical question version. Prevents tampering for leaderboards.

Everything else (FSRS scheduling, UI state, local search) is fine on-device.

---

## 4. Data flow & sync architecture

### 4.1 Content read flow (Sanity → Drift → UI)

- **First launch:** starter pack (~10MB pre-bundled SQLite seed) → background isolate full sync (~50MB over 4G).
- **Subsequent launches:** UI reads Drift directly; background isolate fetches deltas via ETag (~10-100KB).
- **App never blocks on network.** Sync isolate is the only path that touches Sanity.
- **Sync proxy:** Cloud Function `/api/content/sync` — enforces `status == 'published'`, applies App Check, rate-limits. Read token never leaves the server.

### 4.2 User-state write flow (UI → Drift → Firestore)

```
User answers a question:
  1. UI calls reviewService.submitAnswer(qId, choice, timeMs)
  2. Drift: write attempts_local (sync_state='pending')
            update review_state_local (dirty=true), recompute FSRS
  3. UI updates immediately (optimistic) — next question loads
  4. Background sync (debounced 30s OR on app background):
     - Push pending attempts to Firestore
     - Push dirty review_states
     - Clear flags on success; exponential backoff on failure
```

**Conflict resolution** per §3.3 matrix. Attempts are append-only. FSRS uses last-write-wins on `lastReview`.

### 4.3 Entitlement gate flow (RevenueCat → Firebase Auth → app)

```
Purchase on iOS:
  1. App: purchases_flutter.purchase(productId)
  2. Apple → RevenueCat (server-side receipt validation)
  3. RevenueCat webhook → Cloud Function onPurchase()
  4. Cloud Function: setCustomUserClaims(uid, {tier:'yearly', exp:...})
  5. Cloud Function: write /users/{uid}/entitlement mirror
  6. App: getIdToken(forceRefresh:true) → new JWT with claim
  7. UI re-reads, unlocks Pro features
```

Cross-platform purchase recognition via RevenueCat `identifyUser(uid)`. Refunds/chargebacks flow through same webhook → claim auto-clears within ~1hr.

### 4.4 Failure modes

| Failure | Detection | Behavior |
|---|---|---|
| Sanity sync fails | HTTP error in isolate | Silent retry; UI uses cached content |
| Firestore write fails (offline) | Network error | Local queue; no UI interruption |
| Firestore write fails (rule rejection) | Permission error | Surface in "Sync issues" screen; log to Crashlytics |
| RevenueCat webhook fails | RC retry | "Confirming purchase..." spinner ≤10s, then "We'll unlock shortly" |
| App Check rejection | 403 | Full-screen error; no retry |
| JWT claim stale | Detected on launch | Force token refresh on cold start + entitlement screen open |

### 4.5 Observability

- **Crashlytics:** crashes + non-fatals with breadcrumb context.
- **Performance Monitoring:** sync duration, Firestore latency, Cloud Function p95.
- **Custom analytics:** `sync_completed`, `sync_failed`, `entitlement_mismatch`, `clock_skew_detected`. Powers attack-detection dashboards.
- **Cloud Function logs:** all webhook events, claim writes, suspicious flags. 30-day retention.
- **No PII in any telemetry.** Question content, user names — never logged.

### 4.6 User-facing sync controls

- **Manual sync button** in Settings (low cost, useful for impatient users + support).
- **Sync diagnostics screen** behind 7-tap gesture for support escalations. Shows: last sync timestamps per resource, pending queue depth, recent errors, Firebase project ID, app version.

---

## 5. Feature modules

### 5.1 Layout

```
lib/
  app/                          # bootstrap, routing, theme, DI
  core/
    auth/, sync/, content/, storage/, network/, telemetry/,
    entitlement/, fsrs/, error/, l10n/

  features/
    onboarding/                 # 10-question diagnostic, exam selection, goals
    home/                       # dashboard, daily plan, streak surface
    quiz/                       # quick quiz, drill, retake mistakes
    lesson/                     # Portable Text reader, in-line LaTeX, glossary popovers
    review/                     # FSRS-driven daily review queue
    mock_exam/                  # full-length timed mocks, post-mock analysis
    progress/                   # stats, trends, weakness map (free + Pro)
    paywall/                    # pricing, RevenueCat purchase flow
    settings/                   # preferences, sync button, diagnostics, account
    auth_flow/                  # OAuth sign-in, anon→named migration
    notifications/              # FCM permission, prefs
    legal/                      # privacy, ToS, RA10173 export/delete
```

### 5.2 Layering rules (lint-enforced)

Per feature: `data/` (repos, sources) → `domain/` (entities, use cases — pure Dart) → `presentation/` (Riverpod controllers + widgets).

**Hard rules:**
- `domain/` imports nothing from Flutter, Firebase, Drift, Sanity. Pure Dart only.
- `presentation/` reaches `data/` only through `domain/` use cases.
- `features/X/` cannot import from `features/Y/` — only via `core/`.
- `core/` cannot import from `features/`.

Custom `dart_code_metrics` rule blocks violations at CI.

### 5.3 Module specs (non-obvious shapes)

**`core/sync/`** — single `SyncCoordinator` class, background isolate. Exposes `Stream<SyncStatus>` consumed by sync indicator + diagnostics. Triggers: launch, foreground after >5min background, manual button, post-purchase, post-attempt-completion (debounced).

**`core/fsrs/`** — pure-Dart FSRS-4.5. Single function `next(prev, rating, now)`. 17 weights as `const`. **100% test coverage non-negotiable** — golden vectors from FSRS paper.

**`features/onboarding/`** — 10-question adaptive diagnostic. Difficulty adjusts by previous answers (3 buckets). Output: initial FSRS seed + recommended exam focus + study plan. Skip button after Q3. No paywall in this flow.

**`features/mock_exam/`** — state persisted every 30s + on every answer (Drift). Crash recovery: "Resume mock?" prompt on relaunch. Pause allowed but pauses timer (warned: real exam doesn't pause). Strict mode option in settings disables pause. Free tier: 1 mock per exam; Pro: unlimited.

**`features/paywall/`** — three SKUs. Yearly highlighted as recommended; lifetime second-prominent. Restore Purchases mandatory (App Store requirement). Locale-aware price display via RevenueCat `priceString`.

**`features/legal/`** — RA 10173 compliance:
- In-app data export → Cloud Function compiles JSON → email download link.
- In-app account deletion → Cloud Function recursively deletes `/users/{uid}/**` → revokes tokens.
- Privacy Policy + ToS rendered from Sanity (legal can update without app release).
- DPO contact prominently displayed.

### 5.4 Routing (go_router)

```
/                              → onboarding if first launch, else /home
/onboarding/*                  → unauthenticated allowed
/home, /quiz, /lesson, /review → anonymous OR authenticated
/progress/deep, /mock-exam     → Pro-gated (entitlement claim required)
/settings/account              → authenticated only (anon → forced sign-in)
/legal/*                       → always accessible
```

Pro-gated routes redirect to paywall with "this is Pro" banner, never 404.

### 5.5 Feature flags (Firebase Remote Config)

- Per-exam launch toggles.
- Pricing experiments.
- Paywall variants.
- Kill switches for buggy features.

Cached client-side; refreshed on launch + every 12hr.

### 5.6 Deferred to v2

- `features/community/` (peer leaderboards, study groups)
- `features/widgets/` (iOS/Android home-screen streak widgets)
- Per-user FSRS optimization
- Offline editor for Sanity content collaborators

---

## 6. Error handling

### 6.1 Taxonomy

Single sealed hierarchy in `core/error/`:

```dart
sealed class AppException {
  final String code;          // e.g. 'auth/expired'
  final String? technical;    // dev-facing, never user-visible
  final Object? cause;
  final StackTrace? stack;
}

class NetworkException     extends AppException
class AuthException        extends AppException
class EntitlementException extends AppException
class SyncException        extends AppException
class StorageException     extends AppException
class ContentException     extends AppException
class ValidationException  extends AppException
class IntegrityException   extends AppException
```

Raw `FirebaseException`/`DioException`/`DriftException` never bubble past `data/` layer.

### 6.2 Three-layer flow

- **Layer 1 (`data/`):** catch and translate to `AppException`.
- **Layer 2 (`domain/`):** decide fate (retry, surface, swallow, recover) → return `Result<T, AppException>`.
- **Layer 3 (`presentation/`):** map `code` → localized user-friendly copy via ARB files.

### 6.3 UI error patterns

| Pattern | When | Visual |
|---|---|---|
| Inline banner | Recoverable, action-required | Top banner with action button |
| Empty/error state | Whole screen | Illustration + message + retry CTA |
| Toast | Transient non-blocking | 3-second snackbar |

Loading: skeleton screens (shimmer), not spinners. Empty (no-data, no-error): friendly illustrations + suggested action.

### 6.4 Specific scenarios

| Scenario | Response |
|---|---|
| Offline, mid-quiz | No interruption; banner: "Offline — your progress is saved" |
| Auth token expired during quiz | Silent refresh; if fails, finish quiz then prompt sign-in |
| Purchase claim not yet propagated | Spinner ≤10s → "Almost there" with auto-retry every 15s → after 2min, support email with transaction ID |
| App Check rejection | Full-screen "couldn't verify device, please reinstall" |
| Root/jailbreak detected | Warning dialog; Pro disabled; user can dismiss + use free features |
| Drift DB corruption | Auto-wipe + re-sync flow with progress UI |
| Sanity content has invalid LaTeX | Placeholder + "Report this" button; Crashlytics non-fatal + Sanity flag |
| Cloud Function timeout | Default Firebase retry; UI "Working on it..." up to 30s |
| Refund processed | Claim cleared by webhook → next refresh disables Pro → friendly dialog with re-subscribe option |
| Two devices, simultaneous mock | Both persist; server picks higher score (favor user) |
| Localized content missing | Fall back to English with subtle indicator; flag for content team |

### 6.5 Reporting & privacy

- **Crashlytics:** all `IntegrityException`, `StorageException`, unexpected. **No PII, no question content** — sanitization pre-send via custom `RecordError` wrapper.
- **Analytics:** `error_shown` keyed by `code`. Powers "which errors hit users most" dashboard.
- **Cloud Function logs:** 30-day retention. Tokens, claims redacted at log time.
- **User-initiated bug reports:** "Report a problem" → email composer with anonymized session info.

### 6.6 Operational alerting

- Crashlytics → Slack webhook for crash-free rate <99% on any release.
- Cloud Function log-based alert: `entitlement_mismatch` spike (>10/hr) → investigate abuse.
- Performance alert: sync p95 >5s.

---

## 7. Testing strategy

### 7.1 Test pyramid

```
~30 E2E integration tests       (~10min, real Firestore emulator)
~150 widget tests               (~2min, key UI + golden tests)
~600+ unit tests                (~30s, domain + core/fsrs + core/sync)
```

### 7.2 Coverage gates (CI fails below)

- `core/fsrs/` — **100%**
- `core/sync/` — **90%**
- `core/entitlement/` — **95%**
- `domain/` (all features) — **80%**
- Overall — **70%**

Coverage is necessary, not sufficient. PR review checks tests assert behavior, not just execute lines.

### 7.3 TDD modules

**Test-first mandatory** for `core/fsrs/` and `core/sync/`. Both are pure logic with high blast radius if wrong; both have clear pre/post-conditions translating well to tests.

Test-after fine for UI-heavy work.

### 7.4 Critical integration tests (block release if failing)

1. First-launch full path
2. Anonymous → authenticated migration
3. Purchase flow (sandbox)
4. Offline quiz → online sync
5. Mock exam crash recovery
6. Refund flow
7. App Check rejection
8. Account deletion (RA 10173)
9. Data export (RA 10173)

### 7.5 Security testing

**Firestore Rules (`@firebase/rules-unit-testing`, separate Node suite):**
- User A cannot read User B.
- Authenticated user cannot write `entitlement`.
- Anonymous cannot write `events`.
- Pro-gated reads reject when claim absent.
- **100% rules path coverage.**

**Static analysis:** `dart analyze` zero warnings, `very_good_analysis`, custom layering rule, `gitleaks` pre-commit, `Semgrep SAST` in CI.

**Dependency scanning:** `dart pub outdated` weekly, `osv-scanner` blocking on Critical/High CVE.

**Penetration testing:** one-time external pentest pre-launch (~₱30-60k for PH-based 1-week scoped engagement on auth, payment, data exposure). Annually thereafter.

### 7.6 Performance

- Cold start <2.5s on Galaxy A15.
- Quiz interaction <100ms tap-to-render.
- Sync p95 <5s (alert threshold).

### 7.7 Manual QA (release gate)

Real devices: oldest+latest iOS, low-end Android (Galaxy A15), flagship Android. Matrix: golden path × {logged-out, anon, signed-in, Pro}. Localization spot-check en + fil.

### 7.8 CI structure

```
on: [pull_request]                           ~5min total
  ├─ lint, unit, widget, rules, sast, secrets

on: [push to main]
  └─ above + integration suite (~10min) + build artifact

on: [release tag]
  └─ above + sign + upload to TestFlight/Internal Track
```

---

## 8. Security posture (summary)

**Six-layer defense:**

1. **App binary obfuscation** (Flutter `--obfuscate --split-debug-info`).
2. **TLS** (Flutter default; certificate pinning optional, considered for v2).
3. **App Check** (DeviceCheck/App Attest iOS, Play Integrity Android) — gates Auth, Firestore, Storage, Functions.
4. **Firestore Security Rules** — per-user scoping, server-only fields locked, 100% test coverage.
5. **Cloud Functions** — auth + rate limits + canonical computation (mock scores, streak validation).
6. **SQLCipher** at rest with hardware-backed key.

**Auth posture:**
- OAuth-only (Apple + Google), no email/password.
- Anonymous-first; sign-in only when user wants sync or to purchase.
- Anon → named migration via Cloud Function transaction.

**Operational security:**
- Sanity 2FA mandatory.
- Firebase admin access on hardware security keys (YubiKey).
- gitleaks pre-commit + full-history scan pre-launch.
- No hardcoded secrets verified via decompilation + grep pre-launch.
- Quarterly read-token rotation (Sanity).

**Compliance:**
- RA 10173 (PH Data Privacy Act 2012):
  - DPO designated (owner for v1, contact in-app)
  - NPC registration filed
  - Data export + deletion flows in-app
  - 72-hour breach notification process documented
  - Privacy Policy compliant + accessible
- App Store Privacy "nutrition labels" filled accurately.
- Children's policy: not for under 13; birth-year age gate on onboarding.

**Known limitations (transparent in launch notes):**
- Question scraping by determined attacker with rooted device. Mitigations make it expensive, not impossible.
- Default FSRS weights at launch; per-user optimization v2.
- No community/social features v1.
- No home-screen widgets v1.

---

## 9. Edge cases captured

The 24 explicit cases identified during design:

1. Anonymous → authenticated migration without data loss
2. Mock exam crash mid-attempt → resume to exact question + remaining time
3. Server-side streak validation (anti-clock manipulation)
4. Refund / chargeback → entitlement auto-clears
5. Cross-platform purchase recognition (iOS purchase visible on Android)
6. Two-device simultaneous mock (server picks higher score)
7. Drift DB corruption → auto-wipe + re-sync
8. SQLCipher key loss → wipe + re-sync (rare; <30s pending data loss window)
9. JWT claim stale on entitlement change → force refresh on cold start
10. App Check rejection → full-screen error, no retry
11. Root/jailbreak detection → warn-only with Pro features disabled
12. Question retired post-attempt → user history retains qVersion
13. Question content updated post-attempt → in-flight finishes with v1
14. Localized content missing → English fallback with subtle indicator
15. Sanity invalid LaTeX → placeholder + report button
16. Cloud Function timeout → retry then friendly error
17. RevenueCat webhook delay → spinner with auto-retry then support contact
18. Offline at first launch → starter pack + queued sync
19. Offline mid-quiz → optimistic local + queue
20. App reinstall with anonymous user → upfront "save progress?" prompt
21. Schema migration (Drift version bump) → CI tests every migration
22. Account deletion (RA 10173) → recursive Firestore delete + Sanity has no PII
23. Data export (RA 10173) → emailed JSON with all user data
24. Insider threat (hostile publisher) → dual-control on high-stakes content

---

## 10. Launch plan — June 2026 soft launch

**Today: 2026-05-07. Target soft launch: 2026-06-28.**

### 10.1 Phased timeline (8 weeks)

```
Week 1 (May 7-13): START EVERYTHING IN PARALLEL
  ⚠️ NPC registration filed (today — long pole, 4-8 weeks)
  ⚠️ Apple Developer + Google Play accounts (today)
  ⚠️ External pentester engaged for week 6 slot
  • Firebase, Sanity, RevenueCat projects set up
  • App scaffolding: core/, auth, sync engine
  • Privacy Policy + ToS drafted (legal review in parallel)

Week 2-3 (May 14-27): CODE + CONTENT IN PARALLEL
  • Build features: quiz, lesson, mock, paywall, FSRS, onboarding
  • Content: enter + QA existing question bank into Sanity
  • Daily integration tests passing as features land
  ✋ END-WEEK-2 GATE: core architecture working end-to-end (auth, one
     feature flow, Firestore sync, Drift cache). If not, revisit timeline.

Week 4 (May 28 - June 3): CLOSED BETA
  • Build beta version (free, no IAP) → TestFlight + Play Internal
  • 30-50 invited testers
  • Daily bug fixes, telemetry watching
  • IAP products created in App Store Connect + Play Console (review begins)

Week 5 (June 4-10): PENTEST + IAP REVIEW
  • Pentest engagement runs
  • Continue beta iteration
  • RevenueCat product mappings finalized

Week 6 (June 11-17): REMEDIATION + STORE PREP
  • Fix Critical/High pentest findings
  • Build production candidate
  • Screenshots, store copy, age ratings, listing assets
  • Submit to App Store + Play Store review

Week 7 (June 18-24): STORE REVIEW + FINAL PREP
  • Address review feedback (often 1 round)
  • NPC registration follow-up
  • Launch readiness final checklist

Week 8 (June 25-30): SOFT LAUNCH (target: 2026-06-28)
  • Public, unannounced
  • Watch crash-free rate, support volume
  • If stable → marketing push starts week of July 1
```

### 10.2 Conditions that must hold

1. Content is "input, not author" — existing material is QA-ready.
2. Full-time effort for 8 weeks.
3. NPC registration starts week 1 (the long pole).
4. Accept 2-4 week slip if pentest, store review, or NPC slips.
5. Compressed beta (2-3 weeks) acceptable instead of canonical 4-6.
6. Three SKUs ship at launch; v1.0.1 acceptable for IAP edge-case patches.

### 10.3 Items held firm (not compressed)

- **Pentest happens.** Even if compressed to 5 days.
- **NPC registration filed.** No paid PH app collecting PII without it.
- **`core/fsrs/` 100% test coverage.**
- **Real-device testing on Galaxy A15.**

### 10.4 Items cut to fit June

- Beta length: 2-3 weeks instead of 4-6.
- App Store Preview videos: defer to v1.1.
- Status page: defer to v1.1.
- Glossary docs in lessons: defer.
- Filipino content: ship UPCAT Language Proficiency core (~200 questions); expand post-launch.
- Mock blueprint count: 1 per exam (Standard difficulty); Easy + Hard variants in v1.1.

### 10.5 Post-launch expansion (content-only, no app release)

Phase 4: roll in ACET, DLSUCET, USTET, PUPCET, CSE Subprofessional via Remote Config flags + Sanity content. No app updates required.

---

## 11. Success metrics (post-launch tracking)

**Engagement:**
- DAU / MAU ratio (target: ≥30% by month 3)
- Streak retention (D1, D7, D30)
- Session length, sessions per active day

**Learning effectiveness:**
- FSRS retention rate (proxy for actual learning)
- Mock exam score progression per user
- Topic mastery distribution (% of users showing ≥80% on weak-area drills)

**Business:**
- Free → Pro conversion rate (target: 3-5% by month 3)
- Pro tier mix (monthly vs yearly vs lifetime)
- Refund rate (alert threshold: >5%)
- LTV / CAC ratio

**Quality:**
- Crash-free rate ≥99.5%
- Sync success rate ≥99.9%
- Support ticket volume / DAU ratio

---

## 12. Open questions / decisions deferred

- Per-user FSRS weight optimization → v2.
- Community / social features → v2.
- Home-screen widgets → v2.
- Status page → v1.1.
- App Store Preview videos → v1.1.
- Certificate pinning evaluation → v2.

---

## 13. Branding constraints

- All artifacts (commits, contributor lists, code comments, READMEs, PR descriptions) contain no AI/Claude/Anthropic attribution.
- Work product reads as the owner's.

---

**End of design document.**

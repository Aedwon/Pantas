# MVP Roadmap — Remaining Specs to Soft Launch

**Date:** 2026-05-16
**Status:** Approved, drives subsequent brainstorming sessions
**Target soft launch:** 2026-06-28 (matches original launch plan)
**Owner:** Aerol Balayon

---

## 1. Purpose

This document enumerates the remaining design specs needed to take the app from its current state (onboarding + diagnostic + home dashboard + quiz + lesson reader shipped) to a paid public launch with the full feature set described in `2026-05-07-cse-cet-reviewer-app-design.md`.

It is a **plan-of-plans**, not an implementation plan itself. Each spec listed below will be brainstormed and written separately, then implemented one at a time.

---

## 2. Scope decisions locked in this session

- **All features ship in v1.** No deferrals to v1.0.1.
- **Pentest is cut.** Solo-founder risk acceptance documented here.
- **Study Plan is core to v1**, full D-hybrid form (exam-date pacing + adaptive reshuffle + multi-week curriculum view + daily action plan). It is a marketing pillar.
- **NPC registration is already complete.** No regulatory blocker for paid launch with PII.
- **Apple Developer enrollment must start today** — it is the longest external dependency.
- **No closed beta longer than 3-5 days.** TestFlight + Play Internal to invited testers only.

---

## 3. State at start of this roadmap

**Already shipped (plan + code merged):**
- Foundation & ops (Drift database, lint, CI, app shell)
- Frontend foundation (theme, components, routing scaffold)
- Local data layer (Drift schema, repositories)
- FSRS engine (100% test coverage)
- Quiz feature (quick quiz + drill UI)
- Lesson reader (Portable Text, math rendering)
- Assessment / diagnostic (10-question adaptive)
- Lesson progress tracking
- Home dashboard (selected-exam focus, phase 1)
- Onboarding (welcome + age gate + exam picker, with router redirect)

**Empty feature stubs (no plan or code):**
- `auth_flow/`, `legal/`, `mock_exam/`, `notifications/`, `paywall/`, `progress/`, `review/`, `settings/`

**Cross-cutting infrastructure not started in code:**
- Firebase wiring (`Firebase.initializeApp` never called; no `firebase_options.dart`)
- Sanity content fetcher (package not even in `pubspec.yaml`)
- `core/sync/` SyncCoordinator
- RevenueCat integration (package present, no code)
- Cloud Functions (none deployed)
- Entitlement gate (no provider exists)
- Study Plan generator (no domain model exists)

**External account state:**
- ✅ NPC registration: done
- ✅ Google Play Developer account: active
- ✅ Sanity project: created (questions not yet entered)
- ❌ Apple Developer account: not enrolled
- ❌ Firebase project: not created
- ❌ App Store Connect record: not created (blocked on Apple enrollment)
- ❌ App Store Connect IAP products: not created
- ❌ Google Play Console IAP products: not created
- ❌ RevenueCat dashboard project: not created

---

## 4. The 11 remaining specs

Each spec below will be brainstormed in its own session via the `superpowers:brainstorming` skill, then implemented via `superpowers:writing-plans` → `superpowers:executing-plans` (or `superpowers:subagent-driven-development`).

### Spec 1 — Firebase + Auth (size: L)

**Scope:** `flutterfire configure` to generate `firebase_options.dart`. `Firebase.initializeApp` in `main.dart` before runApp. App Check enforcement (Play Integrity on Android, DeviceCheck + App Attest on iOS). Anonymous sign-in on first launch. Apple Sign In + Google Sign In flows. `currentUserProvider` (Riverpod) exposing `User?`. Anonymous-to-named migration on first OAuth sign-in (merge anon UID's data into the named account, then `linkWithCredential`). Sign-out flow returns user to anonymous state. Crashlytics enabled.

**Dependencies:** External — Firebase project created; Apple Developer enrollment cleared (for Apple Sign In capability).

**Open questions to resolve during brainstorm:**
- What happens when an anonymous user tries to sign in with a Google/Apple account that already has data in Firestore? Merge, replace, or refuse?
- Should sign-out wipe local Drift data, or retain it for the next anonymous session?
- Where does the API-key-restriction guidance live (runbook? OPERATIONS.md?)
- Which Firebase products to initialize at boot vs. lazily?

### Spec 2 — Sanity content fetcher + Drift cache (size: L)

**Scope:** Add a Sanity client (Dio-based, no third-party Sanity SDK to keep dependency surface small). Fetch document types `exam`, `subject`, `topic`, `question`, `lesson`, `mockExam`, `mockBlueprint`, `diagnosticSet`. Parse Portable Text into the existing `PortableTextRenderer`'s expected shape. Persist to Drift content tables (separate from user-data tables). Refresh strategy: full sync on first launch; incremental refresh on subsequent launches via `_updatedAt` query; manual refresh from settings. Replace bundled `assets/seed/v1.json` with Sanity-sourced data.

**Dependencies:** Spec 1 (App Check enforcement so Sanity-to-app communication is via authenticated path or open CDN with rate-limit guard).

**Open questions:**
- Sanity CDN vs API endpoint — CDN is cheaper and faster but content lags by a few seconds after publish.
- Full-text search index (Drift FTS5) built on fetch, or build/refresh lazily?
- How is the M:M `question.examIds` relationship stored in Drift (junction table vs JSON column)?
- What does the app do when content fails to fetch on cold start (no cache yet)?

### Spec 3 — User-data SyncCoordinator (size: L)

**Scope:** Background-isolate sync engine that pushes user-data writes from Drift to Firestore. Tables to sync: quiz attempts, assessment results, FSRS state, lesson progress, settings preferences, mock exam state, study plan state. Triggers: app launch, foreground after >5 min background, post-attempt-completion (debounced 5s), post-purchase, manual button. Conflict policy: last-writer-wins by server timestamp. Offline queue (writes accumulate in a `pending_sync` table; flushed when online). `Stream<SyncStatus>` exposed via Riverpod for the sync indicator. Anonymous users sync to `/users/{anonUid}/**` like named users; merge happens on anon→named transition.

**Dependencies:** Spec 1 (auth state), Spec 2 (Sanity reads use the same network layer).

**Open questions:**
- Per-row sync (one Firestore write per attempt) vs batched (one write per session)? Cost vs latency tradeoff.
- What's the failure handling for a sync that has been failing for 24 hours? Surface to user, retry forever, or give up?
- Does the queue persist across reinstalls (Drift, yes) or only across launches (memory)?

### Spec 4 — Review queue (size: M)

**Scope:** Computes the daily FSRS-driven review queue from `next_due` state. UI: queue overview screen + session UI (reuses the existing quiz session widget). Streak update on session completion. Daily cap configurable in settings (default: no cap on free tier — this is the engagement driver).

**Dependencies:** None new (FSRS + quiz UI shipped).

**Open questions:**
- Streak rules: does a 1-card review count as "studied today" or is there a minimum? What about timezone changes / travel?
- If the queue is empty (no cards due), what does the screen show? "Add new cards" CTA?
- Does the review queue feed into the Study Plan's daily target, or is the Study Plan the source of truth?

### Spec 5 — Mock exam (size: L)

**Scope:** Blueprint-driven mock generation from `mockBlueprint` Sanity docs. Timed session with countdown header. State persisted to Drift every 30 seconds + on every answer change (crash recovery). Pause allowed (warning shown that real exam doesn't pause); strict mode toggle in settings disables pause. Resume prompt on relaunch if a mock is in-progress. Post-mock analysis screen: score, time-per-section, weak topics surfaced, score-impact-narrative. Free tier: 1 mock per exam; Pro: unlimited.

**Dependencies:** Spec 2 (blueprints come from Sanity).

**Open questions:**
- Does mock exam attempt data feed into FSRS for review queue, or is it tracked separately (mocks are summative, not learning sessions)?
- Time limit handling: hard cutoff at 0:00, or soft warning with grace period?
- Does the resume prompt fire if the user crashed >1 hour ago, or always?

### Spec 6 — Study Plan (full D-hybrid, size: L)

**Scope:** Extends onboarding with an exam-date step (added after the existing exam-picker step). Pacing algorithm computes weekly subject/topic targets from exam date + topic mastery + content volume. Daily plan generator composes today's actions: review queue size, recommended lesson, weakness-targeted drill, optional mock (if mock-week). Adaptive reshuffle: triggered on session completion if user surges (finishes early) or falls behind (cumulative gap). Multi-week calendar view in a new "Plan" tab or section. "X weeks to exam / on pace / behind / ahead" indicator on home dashboard.

**Dependencies:** Spec 2 (topic/lesson universe), Spec 4 (review queue is a Study Plan input), Spec 5 (mock exam is a Study Plan output).

**Open questions:**
- Where does the multi-week calendar view live — a tab in the bottom nav, a section in home, or a route off home?
- Onboarding modification: is the exam date a hard requirement (block onboarding if not set) or can it be deferred ("set it later in settings")?
- What happens if the exam date is in the past? Warning + reprompt, or auto-extend?
- Algorithm openness: do we expose "you should do 14 reviews and 1 lesson today" as fixed, or as a range the user can dial up/down?

### Spec 7 — Paywall + RevenueCat + entitlement gate (size: L)

**Scope:** RevenueCat SDK init at boot with API key from `--dart-define`. Paywall screen showing 3 SKUs (Monthly ₱99 / Yearly ₱499 with 7-day free trial / Lifetime ₱1499). Yearly is the visually-recommended option; Lifetime is second-prominent. Purchase flow with platform-native confirmation sheets. Restore Purchases button (mandatory for App Store). `entitlementProvider` (Riverpod) reading from RevenueCat's `CustomerInfo`. Pro-route redirect in `router.dart` → paywall instead of 404. Cloud Function webhook receiver: RevenueCat → Firebase Auth custom claim `pro=true`. Locale-aware price display via RevenueCat's `priceString`.

**Dependencies:** Spec 1 (auth state for entitlement claims), Spec 5 (Pro features exist to gate).

**Open questions:**
- Promo offer support in v1 (e.g., first month half off) or v1.1?
- Anonymous purchase allowed (RevenueCat supports it) or force sign-in before purchase?
- What's the UX when entitlement check fails because of network (let the user in optimistically, or block?)
- Where does the receipt validation actually happen — RevenueCat handles it, but do we verify the custom claim server-side on Pro-gated reads?

### Spec 8 — Settings + account (size: M)

**Scope:** Preferences section (reminder time picker, language toggle if multilingual, dark mode if any, strict mock mode toggle). Account section (sign-in/sign-out, anon→named CTA, account deletion entry point that routes to Legal flow). Sync diagnostics (last sync timestamp, manual sync button, pending queue size, network status). About section (version, build, legal links, contact DPO). Exam-date editing (changes propagate to Study Plan).

**Dependencies:** Spec 1, Spec 3, Spec 6 (exam-date editing).

**Open questions:**
- Where does the "delete account" entry live — in Legal directly, or in Settings → Account with a confirm dialog?
- Notification reminder time picker lives here or in Notifications spec?
- Does settings provide a "wipe local data" option for debugging, or is that hidden behind a dev flag?

### Spec 9 — Notifications (FCM) (size: M)

**Scope:** Permission request flow (iOS APNs prompt + Android 13+ POST_NOTIFICATIONS). FCM token registration on sign-in / anon-user-creation, deregistration on sign-out. Daily review reminder scheduled via local notifications (not server push — fires offline, doesn't burn FCM quota). Reminder time configured in settings. Reminder text tied to Study Plan's daily target ("14 reviews + 1 lesson today"). Permission re-request flow if user denied initially.

**Dependencies:** Spec 1 (FCM init via Firebase), Spec 6 (Study Plan's daily target), Spec 8 (settings UI for time picker).

**Open questions:**
- Server-driven push for re-engagement (e.g., "you haven't studied in 3 days") — v1 or v1.1?
- What's the notification copy strategy — fixed templates or generated from study plan state?
- Quiet hours (no notifications between 10pm-7am)?

### Spec 10 — Legal + RA10173 Cloud Functions (size: M)

**Scope:** Privacy Policy + Terms of Service pages rendered from Sanity (legal can update without app release). DPO contact card with email and physical address. In-app data export request → Cloud Function compiles the user's Firestore documents into JSON → emails a download link valid for 24 hours. In-app account deletion → Cloud Function recursively deletes `/users/{uid}/**` → revokes Firebase Auth tokens → signs out the app. Both flows show progress UI and confirmation. Cloud Functions in `asia-southeast1`.

**Dependencies:** Spec 1 (Cloud Functions auth context), Spec 2 (legal pages from Sanity).

**Open questions:**
- Does the export include Sanity content the user has interacted with, or only user-data?
- Account deletion: is there a grace period (e.g., "we'll delete in 30 days, cancel anytime") or immediate?
- What about RevenueCat purchase history — included in export? Required by RA10173 (it's PII).

### Spec 11 — Progress (size: M)

**Scope:** Aggregations computed locally from Drift attempt data — no server aggregation. Free-tier surface: per-subject accuracy, per-topic mastery levels (from FSRS state), study streak, total cards reviewed, "X weeks to exam, on pace / behind / ahead" indicator (driven by Study Plan). Pro-tier surface: trend lines (accuracy over time), weakness narrative ("your Reading Comprehension accuracy on inference questions dropped 12% last week"), score-impact analysis (projected mock score change if you fix weakest 3 topics), per-mock comparison. Pro views show a paywall teaser when free user opens them.

**Dependencies:** Spec 3 (synced data so progress survives reinstalls), Spec 6 (Study Plan provides the exam-pace indicator), Spec 7 (entitlement gate for Pro views).

**Open questions:**
- Aggregation strategy: compute on-demand when viewing, or pre-compute on every attempt-completion into a `progress_cache` table?
- How far back does the trend view go (all-time, last 90 days, last 30 days)?
- Score-impact narrative: rule-based templates from topic mastery, or richer model?

---

## 5. Critical-path schedule (~6 weeks)

```
Week 1 (May 16-22): Spec 1, Spec 2
  External (parallel): Apple Developer enrollment, Firebase project,
                       Sanity content authoring begins (~10 questions
                       first, validate schema, then bulk-enter)

Week 2 (May 23-29): Spec 3, Spec 4, Spec 5
  External: RevenueCat dashboard project, App Store Connect app record
            (once Apple enrollment clears)

Week 3 (May 30 - Jun 5): Spec 6 (Study Plan — the big one), Spec 7 (Paywall)
  External: App Store Connect + Play Console IAP products created and
            submitted, RevenueCat product mappings finalized

Week 4 (Jun 6-12): Spec 8, Spec 9, Spec 10, Spec 11

Week 5 (Jun 13-19): Closed TestFlight + Play Internal beta
                    (3-5 days, invited testers only, daily bug fixes)
                    Submit to App Store + Play Store

Week 6 (Jun 20-28): Address store review feedback
                    Final QA on Galaxy A15 + recent iPhone
                    Soft launch: 2026-06-28
```

### 5.1 Items that must hold

- Apple Developer enrollment started **today (May 16)**. Slipping this slips everything.
- Sanity content for the first ~10 questions entered by end of Week 1 to validate Spec 2's schema assumptions.
- IAP products created in both stores by end of Week 3 so they're reviewed alongside the app submission in Week 5.
- `core/fsrs/` 100% test coverage maintained as Study Plan touches it.
- Real-device QA on Galaxy A15 (PH bandwidth-constrained target hardware) in Week 5.

### 5.2 Acceptable slip

- 1-2 week slip into early July if any of: Apple review rejects twice, Sanity content authoring runs long, Study Plan algorithm needs a second design pass.
- Pentest is cut (solo-founder risk acceptance).

### 5.3 Not acceptable for launch

- Open Firestore rules.
- App Check not enforced.
- Privacy/ToS pages broken or missing.
- RA10173 export/delete Cloud Functions absent.
- Paywall purchase flow not tested end-to-end on both platforms with sandbox accounts.

---

## 6. External setup tasks (run parallel to coding)

These do not need their own brainstorm sessions — they are operational checklists. The Firebase + Auth spec (#1) will reference the Firebase setup checklist; the Paywall spec (#7) will reference the App Store Connect + Play Console + RevenueCat checklists.

**Today (May 16):**
- Apple Developer Program enrollment ($99/year, expect 1-7 day wait)
- Firebase project `cse-cet-reviewer-prod` in `asia-southeast1`, Blaze plan, all products enabled with security configured
- Sanity: enter 5-10 representative questions to validate schema in upcoming Spec 2 brainstorm

**Week 2:**
- RevenueCat dashboard project created (Android side configurable immediately; iOS side blocked on Apple enrollment)
- Once Apple clears: App Store Connect app record + APNs auth key

**Week 3:**
- IAP products created in both stores (`pro_monthly`, `pro_yearly`, `pro_lifetime`)
- RevenueCat product mappings + Entitlements + Offerings

**Week 5:**
- Store listing assets (screenshots, copy, privacy labels, age ratings)
- TestFlight + Play Internal builds uploaded
- Production builds submitted to both stores

---

## 7. What this roadmap does NOT cover

- Detailed implementation plans for each spec — those are produced by `superpowers:writing-plans` after each brainstorm.
- v1.1 features: server-driven push notifications, peer leaderboards, study groups, home-screen widgets, per-user FSRS optimization, offline Sanity editor.
- Marketing, content authoring strategy, App Store Optimization (separate workstreams).
- Post-launch monitoring playbook (lives in `docs/OPERATIONS.md`).

---

## 8. Next step

Brainstorm **Spec 1 — Firebase + Auth** via `superpowers:brainstorming`. This is the critical-path head and unblocks Specs 2, 3, 7, 9, 10. While brainstorming, the user starts Apple Developer enrollment and creates the Firebase project in parallel.

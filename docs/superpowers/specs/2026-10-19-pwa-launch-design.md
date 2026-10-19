# PWA launch: design

Date: October 19, 2026. Status: Part A approved by Aedwon on October 19, 2026, at balanced
complexity. Freeze lifted for this scope. Answers to the open decisions are in the decision record
and summarized below.
Policy revision read: origin/main 7e6acb4e.
Decision record: `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md`.
Related: `docs/superpowers/2026-10-05-engineering-restart-strategy.md`,
`docs/superpowers/plans/new-design/STATUS.md`, `docs/superpowers/specs/2026-10-06-tier-pricing-design.md`,
`docs/pricing.md`.

Approved answers (October 19): Firebase on Blaze; the PWA ships on the finished, integrated new
design; prepaid access instead of renewing subscriptions; no reminders at first launch. The
implementation plan goes in `docs/superpowers/plans/`.

---

## Part A. Plain-language summary for approval

### What changes

Pantas launches first as a web app that students can add to their phone's Home Screen (a PWA).
Google Play and the App Store wait until there is money for them. The first launch covers only
CSE Professional and Subprofessional. Payments go through PayMongo. The app is hosted on Firebase,
which the backend already uses.

### How it works for a student

1. The student opens the Pantas link in a phone browser. A Pantas loading screen shows at once.
2. The first visit downloads the app and all CSE lessons and quizzes, estimated at 5 to 8 MB.
3. After that, the app opens from the phone in about 1 to 2 seconds and works offline.
4. Pantas asks the student to add it to the Home Screen. On iPhone, this also stops Safari from
   clearing the saved lessons after 7 days without use.
5. Progress syncs to the student's account, so nothing is lost if the browser clears storage.
6. Paying for Pro opens a PayMongo checkout (GCash, Maya or card). Pro unlocks when PayMongo
   confirms the payment.

Only the phone layout ships first. The desktop layout follows later.

### Plan and timing (estimate: 2 to 3 weeks)

| Phase | Days | Who | Work |
|---|---|---|---|
| 0. Clean-up and records | 0 | Claude | Reconcile local work; record decisions; check new-design progress |
| 1. Web foundation | 1 to 3 | Claude, Haiku for tests | Web build; web handling for phone-only features; content into browser storage; staging deploy; measure size |
| 2. Speed and experience | 3 to 7 | Claude | Instant loading screen; offline caching; background content load; Home Screen prompt; keep-storage request; cut non-CSE content; trim fonts |
| 3. Payments | 1 to 7 | Aedwon, then Claude | Aedwon starts PayMongo verification now; Claude builds checkout and payment confirmation, tested in PayMongo test mode |
| 4. CSE content audit | 1 to 10 | ChatGPT, Claude reviews | Audit CSE Professional and Subprofessional content only |
| 5. Launch | 10 to 14 | Claude | Lock down database access; bot protection; budget alert; production deploy |

Phases 1, 3 and 4 run at the same time.

### What needs your decision

1. **Approve this Part A.**
2. **Complexity.** Recommended: balanced. It adds only what the launch needs and no new
   infrastructure.
3. **Lift the app-code freeze** for the PWA launch scope.
4. **Hosting.** Recommended: Firebase, not the MacBook. Payment confirmation must always be
   reachable, and home power cuts or restarts would break it. Firebase needs a card on the Blaze
   plan; the expected bill is about $0 to $5 a month. Without a card, a free Cloudflare Worker
   handles payment confirmation instead.
5. **New-design work in progress.** The new design (W4 screen families) is not finished or
   integrated. Choose one:
   - Ship the PWA on the new design when the needed screens are done. Better product, later
     launch. Timing depends on W4 progress, which Phase 0 will measure.
   - Ship the PWA on the current main screens now, and switch to the new design later. Faster
     launch, but the work is done twice.
   Recommendation after Phase 0 measures W4.
6. **Subscriptions versus prepaid passes.** The approved Civil Service prices (₱49 weekly, ₱149
   monthly, ₱1,199 yearly, ₱499 pass, 7-day trial on Monthly) assume Google Play renewals and
   credits. GCash and Maya generally do not support automatic renewal (not verified for PayMongo).
   Option: sell weekly, monthly and yearly as prepaid access that the student renews by hand.
   This needs your decision before Phase 3 builds checkout.
7. **Notifications.** Web reminders work differently and only on installed PWAs. Recommended:
   no reminders at first launch.

### Cost and risk

- **Money:** Firebase about $0 to $5 a month at thousands of users (estimate). PayMongo fees apply
  per payment. No store fees.
- **First-open speed:** about 3 to 6 seconds on mobile data (estimate). Measured in Phase 1.
- **iPhone storage clearing:** handled by the Home Screen prompt and synced progress.
- **PayMongo verification time:** outside our control; start now.
- **Usage limits:** Claude weekly usage was 76% used on October 19. Content goes to ChatGPT.

---

## Part B. Agent section

### B1. Current facts (origin/main 7e6acb4e)

- No `web/` platform folder exists.
- Backend: Firebase projects `pantas-dev-090126`, `pantas-staging`, `pantas-prod`. `firebase.json`
  already defines Hosting (`public/`, rewrite `/wrapped/**` to `renderWrappedPage`) and Functions
  (Node.js 20).
- Content: `assets/seed/content.db` (9,019,392 bytes; 1,602,925 bytes gzip), installed by
  `lib/core/content/bundle/seed_installer.dart`, which uses `dart:io` `File` and
  `getApplicationSupportDirectory()`. Neither exists on web.
- Plugins with no or partial web support that need web handling: `flutter_local_notifications`,
  `firebase_crashlytics`, `purchases_flutter` (RevenueCat), `flutter_secure_storage`,
  `path_provider`, `in_app_review`, `app_settings`, `sign_in_with_apple` (web needs a Services ID).
- Firebase quotas (pricing page dated October 14, 2026): see the decision log.

### B2. Web content database

Use drift's web support (sqlite3 WASM with OPFS, falling back to IndexedDB). On first run, fetch the
seed database asset and import it into browser storage; skip it when the stored content version
matches. Call `navigator.storage.persist()` after install. Keep the file system path on Android and
iOS unchanged.

### B3. Performance

- HTML loading screen in `web/index.html`, removed on the first Flutter frame.
- Flutter service worker caching for app files; cache-busting through build hashes.
- Defer the content import until after the first screen renders.
- Build a CSE-only seed database for the web bundle.
- Subset fonts; check whether to self-host CanvasKit or use the CDN after measuring.
- Measure with Lighthouse on a throttled mobile profile in Phase 1 and Phase 2.

### B4. Payments

- PayMongo Checkout Session created by a callable Cloud Function; the client never holds the
  secret key.
- Webhook Cloud Function verifies the PayMongo signature, makes processing idempotent by event ID,
  and writes the entitlement to Firestore. The client reads the entitlement; it never writes one.
- RevenueCat stays for later store builds; web uses the PayMongo entitlement path. Reconcile with
  the W3 entitlement model before coding.
- Decision 6 (October 19): prepaid access, renewed by hand. Trial handling for prepaid access is settled in the plan.

### B5. Launch hardening

Firestore and Storage rules review for web clients; App Check with reCAPTCHA Enterprise for web;
Blaze budget alert; authorized domains for Auth; privacy and terms pages reachable on the web.

### B6. Constraints

- W4c source after `7223e931` stays local until the whole-family audit (restart log, October 18).
  Do not push it as part of this work.
- `STATUS.md` lock rules apply; take the lock before editing it.
- Verification follows `AGENTS.md` and `SUBAGENTS.md` Part 5.

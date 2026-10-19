# PWA launch: implementation plan

Date: October 19, 2026. Lead author: Claude (Opus 5.5).
Controlling spec: `docs/superpowers/specs/2026-10-19-pwa-launch-design.md` (Part A approved October
19, balanced complexity). Decision record: `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md`.
Policy read: origin/main 183cde8c. Code base for this plan: `integration/new-design-r1` (5e6cda45
when read); main does not yet contain the new design.
Facts gathered October 19 (read-only crawl, Haiku 5.5): W4 state from `plans/new-design/STATUS.md`,
audit state from branch `docs/content-coverage-audit-r1` at 775a9bb2, payments and web blockers.

Guiding principle (Aedwon, October 19): be cost-effective and deliver as early as possible.

---

## Part A. For Aedwon: what this plan needs from you

The plan below assumes the recommendation for each item. Items marked **(blocks)** stop the named
lane until answered.

| # | Decision | Recommendation | Cost of the alternative |
|---|---|---|---|
| D1 | Run the web and payments lanes alongside W4 instead of after it. Your October 16 rule is one branch at a time. **(blocks Lanes B and C)** | Allow. The web and payments work touches different files from the W4 screens, apart from W4f, which is ordered below. | Strict serial adds about 2 weeks. |
| D2 | Run the remaining W4 families in up to 3 parallel lanes, with one engineering audit per family at the end instead of repeated audits. **(blocks the timeline below)** | Allow. The L3 parallel map already gives the order between families. | Serial W4 at the W4c pace is about 5 to 6 weeks (estimate). |
| D3 | W4g (Wrapped and sharing) after launch. | Defer. It is not needed to study or pay. | About 1 week more before launch. |
| D4 | Audit Level 4 for CSE: one reading chat per lesson instead of two plus a deciding chat. | One chat. Your QA pass comes after the rewrite anyway. | About 2.2 times the pastes (about 160 instead of 71). |
| D5 | Authorize audit Level 5 for CSE questions now, running at the same time as Level 4. The audit spec requires each level to finish and be approved first. **(blocks Lane E3)** | Authorize and run in parallel. | About 1 to 2 weeks more. |
| D6 | Free trial on web. Prepaid access cannot renew, so the Monthly trial rule does not carry over. | No trial at launch. The free tier is the trial. | A server-granted 7-day pass is about 1 day of work, plus abuse handling. |
| D7 | The study database on the phone is encrypted on Android. Browsers do not offer the same encryption. | Accept an unencrypted database on web. Browser storage is private to the site, and progress also syncs to the account. | Encrypting on web means building a custom database engine, about 3 to 5 days. |
| D8 | Web address. | Buy a domain (about $10 a year) before PayMongo verification, which may ask for a website. Until then, use the free `web.app` address. | A `web.app` address looks less trustworthy at checkout. |
| D9 | Weekly price. PayMongo charges a fee per payment (rates not verified here). A fixed fee on a card payment would take a large share of ₱49. | Check PayMongo's fee table. If a fixed card fee applies, keep Weekly on GCash and Maya only, or drop Weekly on web. | Pricing is your call; `docs/pricing.md` stays the source. |

Things only you can do, with no blocker on our side:

- Start PayMongo merchant verification now.
- Put a card on Firebase Blaze for `pantas-staging` and `pantas-prod`, and set a budget alert.
- Paste Level 4 prompts into ChatGPT web chat (about 71 if D4 holds).
- QA the rewritten CSE lessons and illustrations (Lane E7).
- Accept the finished app on your phone before production.

### Answers so far (October 19)

D1 approved. D2: 2 parallel W4 lanes, may extend to 3. D3 approved: W4g after launch. D4
approved: one chat per lesson. D5 authorized: Level 5 runs alongside Level 4, through web chat pasted by Aedwon. D6 approved: free trial
(Lane C6). D7: encrypted web database (Lane B3). D8: `pantas.study`. D9: cards stay on every plan, Weekly included.

### Timeline (estimates, assuming D1, D2, D3, D5 as recommended)

| Week | Engineering | Content |
|---|---|---|
| 1 | W4c audit and integration. Web foundation (Lane B1 to B4). Payments design (C1). | Audit scope reset. Level 4 and Level 5 start. |
| 2 | W4b, W4d, W4e in parallel. Web speed work (B5 to B8). Payments build (C2 to C4). | Levels 4 and 5 finish. Rewrite starts per subject. |
| 3 | W4a and W4f (adjusted for web). W4h Task 4, W2 Task 9. | Rewrite and illustrations. Your QA. |
| 4 | W6 Tasks 6 to 8. Launch hardening (L1 to L4). Phone acceptance. | CSE content build. Launch. |

Biggest risk: W4 speed. October 19 additions (server-enforced Pro, C7 to C10, and the encrypted
web database) add about 1 to 1.5 weeks to the payments lane; the launch estimate is now about 4 to
5 weeks with 2 W4 lanes.

---

## Part B. Agent section

### B0. Roles and model routing

Roles follow `SUBAGENTS.md` Part 7b. Models (Aedwon, October 19):

| Role | Model |
|---|---|
| Lead (planning, rulings, escalation, engineering audit, integration) | Opus 5.5 medium, or GPT Astra |
| Engineering implementor | Sonnet 5.5 medium, or GPT 6.1 Sol |
| Mechanical work (crawls, test runs, gates, figure data, inventories) | Haiku 5.5, GPT 6 Luna, or ChatGPT web chat pasted by Aedwon |
| Content rewrite (lessons, questions) | ChatGPT: Codex with GPT 6.1 Sol where it can write files, web chat otherwise |

Routing rules:

- Anything touching money, entitlements or student data goes to the lead for review (Part 7b).
- Content audits are not lead work. Audit reading uses ChatGPT (Level 4) and the Codex
  orchestrator (Level 5).
- Agent verification of content applies to questions only. Rewritten lessons and illustrations get
  the format gates, then Aedwon's QA.
- Prefer ChatGPT quota for high-volume work. Claude weekly usage was 76% used on October 19.

Integration ownership: the Codex lead keeps `integration/new-design-r1`, the `STATUS.md` lock and
the W4 sequence. The Claude lead runs Lanes B, C and L and makes the content rulings in Lane E on their own branches and hands each finished,
verified branch to the integration owner. If the Codex lead is unavailable, the Claude lead takes
the lock under the stale-lock rule and records it in `STATUS.md`.

Status tracking: add a "PWA launch" section to `docs/superpowers/plans/new-design/STATUS.md` (one
row per lane task below) the first time the lock is free or handed over. Do not create a separate
status file.

### Lane A. Finish the new design (W4), adjusted for the PWA

Owner: Codex lead. Implementors: Sol or Sonnet. Order follows `L3-parallel-map.md` waves, in 2 parallel lanes (D2; may extend to 3).

| Task | Work | PWA adjustment |
|---|---|---|
| A1 | W4c Astra audit, fixes, integration | Push the post-`7223e931` source only in this sequence |
| A2 | W4b Tasks 2 to 10 | None |
| A3 | W4d Tasks 2, 4 to 9 (Task 4 caller wiring, Task 5 end screen) | None |
| A4 | W4e Tasks 3 to 9 | None |
| A5 | W4a Tasks 1 to 11 | Task 8 (reminders step): leave out on web. Task 5 exam picker: only the two CSE exams are selectable at launch; others show "Coming soon" as in the tier spec. |
| A6 | W4f Tasks 2 to 9 | Task 1 (reminder service, 29-file draft in `Pantas-wt-new-design-w4f-r1`): park on its branch, not integrated for launch; record the park. Task 4: hide the Reminders screen on web. Task 6 (Pro page): web shows the PayMongo plans from Lane C; hide "Manage in Google Play" and pending-purchase copy on web. Lane C3 provides the purchase interface Task 6 calls. |
| A7 | W4h Task 4, W2 Task 9 | After all included families |
| A8 | W6 Tasks 6 to 8 | Task 7 deploys include the PayMongo functions (Lane C) and Hosting (Lane L) |
| A9 | W3 Task 15 | RevenueCat webhook deploy stays for later store builds; not on the launch path |
| A10 | W4g | After launch if D3 holds |

Verification per family: as in its L3 plan and `SUBAGENTS.md` Part 5, plus `flutter build web`
succeeding on the integrated branch from Lane B onward.

### Lane B. Web foundation and speed

Owner: Claude lead. Implementor: Sonnet 5.5 medium. Branch `web/pwa-foundation-r1` from
`integration/new-design-r1`, own worktree `../Pantas-wt-pwa-foundation-r1`.

B1. **Inventory (Haiku).** Re-run the web blocker inventory on the integration branch (the
October 19 inventory was on main). List every import of `dart:io`, `path_provider`,
`flutter_local_notifications`, `firebase_crashlytics`, `purchases_flutter`,
`flutter_secure_storage`, `in_app_review`, `app_settings`, `google_sign_in`, `sqlite3`. Output a
table; no edits.

B2. **Web platform.** `flutter create --platforms=web .` on the branch; keep generated files only
under `web/`. Add Firebase web app config to the three `firebase_options_*.dart` files with
`flutterfire configure` (web only, existing projects). Done when `flutter build web --release -t
lib/main_staging.dart` compiles; failures from B1 items are expected until B3.

B3. **Platform seams.** One conditional import per blocker, at the existing gateway boundary:
- Content database (`lib/core/content/content_database_opener.dart`,
  `bundle/seed_installer.dart`): on web, `WasmDatabase.open` with `initializeDatabase` returning
  the seed asset bytes on first run; skip when the stored content version matches. Ship
  `sqlite3.wasm` and `drift_worker.js` in `web/`.
- App database (`lib/core/storage/data/database_opener.dart`): on web, an encrypted
  `WasmDatabase` (D7, Aedwon: "it should be encrypted"). First check whether the `sqlite3` package
  offers a SQLite3MultipleCiphers WebAssembly build matching the native `sqlite3mc` source; if not,
  build one in the repository's tooling. Key handling: generate a random database key, wrap it with
  a non-extractable Web Crypto key, and store only the wrapped key in IndexedDB. Limit to record in
  a code comment: this protects copied browser files, not code running on the site. Estimate 3 to
  5 days (not verified); report the actual approach to the lead before building a custom engine.
- Telemetry (`lib/core/telemetry/firebase_telemetry.dart`): Crashlytics not used on web; keep
  Analytics.
- Notifications gateway: web no-op (no reminders).
- In-app review, app settings: web no-op.
- RevenueCat SDK: not constructed on web; Lane C supplies the web purchase gateway.
- Google sign-in: use the web button flow that `google_sign_in` 7 requires on web. Check the
  sign-in screen still matches the approved board; any visible change goes to Aedwon with the
  visual companion before it ships.
Done when the staging web build runs in Chrome: onboarding, a lesson, a quiz and sign-in work
against `pantas-staging`.

B4. **Staging deploy and size.** Add a second Hosting site for the app (`firebase.json` targets),
keeping the existing `public/` site and the `/wrapped/**` rewrite unchanged. Deploy to staging.
Record transfer size of the first load and of a repeat load (Chrome devtools, mobile throttling)
in the evidence file.

B5. **Instant loading screen.** Static HTML and CSS splash in `web/index.html` using the approved
launch screen; removed on the first Flutter frame. Visual check against the board.

B6. **Caching and install.** Flutter service worker for app files. Web manifest with name, icons
and theme colors from the design tokens. Home Screen prompt on Android (`beforeinstallprompt`) and
an instruction sheet on iPhone, shown after the first completed lesson, not at first open. Copy
follows the voice rules in `AGENTS.md`; any new screen goes to Aedwon with the visual companion.
Call `navigator.storage.persist()` after install.

B7. **Content load after first screen.** Start the content import after the first frame; show the
W4h loading pattern only where content is needed and not yet ready.

B7a. **HTML Welcome screen (October 19, Aedwon).** Build the first onboarding screen (Welcome)
as plain HTML and CSS in `web/index.html`, replacing the bare splash for first-time visitors. The
Flutter engine and app code download while it shows. Tapping Start hands off to the Flutter
onboarding at the next step without a visible jump; if Flutter is not ready yet, the button shows
the W4h loading pattern until it is. Returning visitors skip it and go straight to the app.
It must match the approved Welcome board exactly, in light and dark themes: check it with the
visual companion and get Aedwon's acceptance before it ships. Copy comes from the existing Welcome
screen strings, not new wording. Estimate: about 1 day.

B7c. **Load later screens on demand (October 19, Aedwon).** Split rarely first-used features
into deferred Dart libraries (`import ... deferred as`) so they leave the first download:
start with the mock exam (W4e), settings and account (W4f), and the Pro page. Each split route
loads its library on first open and shows the W4h loading pattern while it loads; offline after
the first visit, the service worker serves it. Measure the first-load size before and after in
the B4 evidence. Do not split features on the first-session path (onboarding, Home, a lesson, a
quiz). Estimate: about 1 day.

B7b. **Phone layout only.** At launch the web app uses the phone layout at every width, centered
with a maximum width on large screens. The desktop layout from Claude Design comes after launch
(spec Part A). Any visible framing on wide screens goes to Aedwon with the visual companion.

B8. **Size cuts.** (After C7 the seed database carries no lesson or question content; B3 and B7
then apply to the cached content store.) Web seed database with CSE content only (built by the content tool, Lane E7).
Font subsetting for the three Source Sans 3 weights. Decide CanvasKit from CDN versus self-hosted
from the B4 measurement. Target: first load under 6 MB transferred, and the Welcome screen visible within 1 second on
a throttled mobile profile (estimate-based targets; report the actuals).

Verification for Lane B: `flutter analyze` clean; `flutter test` full pass (Haiku runs it,
returns counts and failures); staging web smoke on a real phone (Android Chrome and iPhone Safari)
by Aedwon; Lighthouse mobile run recorded. Engineering audit by the lead before hand-off.

### Lane C. Payments with PayMongo

Owner: Claude lead (tier-1 review on every task: money and entitlements). Implementor: Sonnet 5.5
medium. Branch `web/paymongo-r1` from `integration/new-design-r1`.

C1. **Design ruling (lead).** Read the integrated W3 entitlement model (`functions/src/
revenuecatWebhook.ts`, `revenuecatClaims.ts`, `revenuecatPasses.ts`, `repairEntitlementClaims`,
the client `paywall` feature) and write a one-page ruling in this plan's evidence folder:
- How a PayMongo payment becomes the same entitlement W3 grants (the `pro` claim and any expiry
  record W3 defines), with the source marked `paymongo`.
- Prepaid rules: a purchase extends access from the later of now or the current end. Pass: ends
  after the next published CSE date, reusing W3's pass end logic.
- Expiry: scheduled function clears access after the end, following the W6 cleanup pattern.
- Products: Civil Service weekly, monthly, yearly, pass at `docs/pricing.md` prices; every payment
  method on every plan (D9).
Verify the PayMongo API details against PayMongo's current documentation (Checkout Sessions,
webhook event for a paid checkout, signature header format). Do not rely on memory.

C2. **Checkout function.** Callable Cloud Function creates a PayMongo Checkout Session for a signed-in
user and product id; returns the checkout URL. Secret key in Functions secrets only. Per-account
rate limit using the W6 pattern. Tests in the Functions test runner and emulator.

C3. **Web purchase gateway (client).** Implements the purchase interface the Pro page uses: start
checkout (open URL), handle return, refresh the token to pick up the claim. Mobile keeps
RevenueCat. Provides what W4f Task 6 calls (Lane A6).

C4. **Webhook function.** Verifies the PayMongo signature, de-duplicates by event id (reuse the
`webhookEvents` pattern), grants or extends access, logs the event. Idempotent on retries. Tests:
valid, replayed, bad signature, unknown product, extension of an active grant, pass end date.

C5. **Test-mode run.** PayMongo test keys on `pantas-staging`: pay with a test GCash and card
payment; access appears; replayed webhook changes nothing; expiry clears access (use a shortened
test period through the emulator, not production code paths).

C6. **Free trial (D6).** A server-granted 7-day Pro grant, once per account, through the same
entitlement path as C4 with source `trial`. The trial check reuses W3's trial-eligibility record so
an account that ever had a trial or paid access gets none. Started from the Pro page; ends without
charge. New Google accounts are an accepted risk, as in the tier spec.

C7 to C10 replace the earlier C7 (October 19, decision log "server-enforced Pro, option B").
Principle: the app never decides Pro. Every lesson, question, Pro-only item, mock paper, mock
allowance, roadmap and Pro insight comes from Cloud Functions after the server checks the signed
account (App Check, sign-in or anonymous account, `pro` grant, tier). Firestore rules deny direct
client reads of content and computed results. Each function has a per-account limit (W6 pattern),
set by the lead from real study use.

C7. **Content per request.** The content build (E7) uploads lessons and question sets to a
server-only Firestore collection, one document per lesson or set, Pro-only fields (wrong-choice
notes) in a separate document. A callable returns a lesson or set; it returns Pro-only fields only
to Pro accounts. The client stores opened items in the encrypted app database, shows the stored
copy at once, requests the latest in the background, and updates on arrival (content version per
document). It preloads the next items on the student's roadmap. The bundled seed database holds no
lesson or question content; the web bundle shrinks accordingly. W4 screens keep reading through the
existing content repository; the repository fetches and caches. Lead checks W4c, W4d and W4e
callers for local-only assumptions first and orders changes with the integration owner.

C8. **Mock allowance and papers on the server.** Starting a mock requires a real (non-anonymous)
account. A callable checks the allowance (Free: one per rolling 30 days after the last mock; Pro:
unlimited; later grants by code or account ID are a post-launch item) and returns the paper. The
submission is recorded on the server. Mock answers and explanations follow the approved Free rule
(visible until the next mock opens), enforced by the server.

C8b. **Mock paper on the server (October 19 rules).** Assemble the paper on the server with the
plain Dart mock sampler compiled to JavaScript (as C10). Pin the paper per account until
submitted; server-held clock; strict-mode time-out ends and scores; non-strict discard keeps the
same paper; Free allowance counts at submission; next Free mock 30 days after it. Rules: decision
log "mock allowance and resume rules".

C9. **Answer sync.** Every account (anonymous included) syncs answers and session results to the
server in one batch per session. Reuse the existing sync generation design; check the W6 cleanup
jobs cover anonymous accounts that never sign up.

C10. **Roadmap and Pro insights on the server.** First task, by the lead: confirm the existing Dart
roadmap and insights logic (W4b, `web/roadmap-engine-r1` lineage) can be compiled for a Cloud
Function (dart2js or a Dart Cloud Run service) without rewriting, and give a revised estimate
before building; plan estimate about 1 week. The function computes the roadmap from synced answers
when a session syncs and stores the result server-side; a callable returns only the parts the
account's tier allows (Free: Today; Pro: Coming up, History and insights, per
`docs/design/DECISIONS.md`). The client never receives the Pro parts for a Free account. The device
keeps showing the last received roadmap while offline.

Tests for C7 to C10: Free account refused Pro fields; anonymous account refused a mock; allowance
refuses a second mock inside 30 days; rules deny direct reads; limit reached; stale cache updated
on fetch; roadmap response for Free contains no Pro sections; sync batch replay is idempotent.
Estimate for C7 to C10: about 2.5 weeks (C1 and C10 ruling, `pwa-launch/C1-C10-ruling.md`).
The ruling governs C1 to C10 design details where it is more specific than this plan.

Verification: Functions plain and emulator suites full pass; lead reviews the diff line by line;
`firestore.rules` unchanged or reviewed; Aedwon completes one test-mode purchase on staging.

### Lane E. Content: audit, rewrite and QA for CSE

Owner of rulings: Claude lead. Audit execution: ChatGPT (Level 4 web chat; Level 5 Codex
orchestrator). Work happens on `docs/content-coverage-audit-r1` (audit) and a content branch for
rewrites.

E1. **Scope reset (lead, Haiku for lists).** Scope = union of lessons tagged
`cse-professional` or `cse-subprofessional` in `lesson-exam-tags.json` (64 and 62, 71 unique) and
question sets tagged `cse-pro` or `cse-sub` in question files (53 and 44 sets). Haiku lists the
union and the disagreements. Record the CSE-only scope in the audit plan and `status.md` on the
audit branch, and reconcile its stale "BLOCKED" first line with the October 11 paste decision.

E1b. **Copy-prompt page (Haiku or Sonnet, small).** A local page listing each scope prompt with
a one-click Copy button, a done mark, and a box to paste the chat's answer back, saved to the
audit branch's inbox in the format the existing hand-in checks read. Serves Level 4 now and
Level 5 if authorized. Reuse `level4/server.py` safety rules (local-only, host and origin
checks).

E2. **Level 4, CSE lessons.** One web chat per lesson if D4 holds, using the existing
packets for scope lessons only. Hand-in and checks as in the Level 4 spec.

E3. **Level 5, CSE questions** (D5 authorized). ChatGPT web chat pasted by Aedwon from the E1b
page, following the roles in `ORCHESTRATOR.md`:
Luna mechanical rules and a blind solve of every scope question; Sol confirms every blind answer
that differs from the key; calibration sample first. Practice-against-teaching check per plan
Task 6.

E4. **Rewrite lessons.** ChatGPT (Codex Sol) per finding, one subject at a time, following
the lesson authoring runbook and style guide. Gate: `python3 tools/audit/run_all.py` and the
content import. No agent review; goes to Aedwon's QA.

E5. **Rewrite questions.** ChatGPT (Codex Sol) per finding. Gates: the content gate
command in `SUBAGENTS.md` Part 4 (expected: validator 0, emdash 0, approved 0, noexams 0). Answer
check: Luna blind solve of every changed question; Sol confirms mismatches; Mathematics sets also
get the tier-2 five-item re-solve. Fix the gate's id count to include unindented `- id:` lines
(28 files) before relying on it.

E6. **Illustrations.** For each figure the audit calls for: Haiku writes the figure data
for an existing type in `lib/core/ui/figures/figure_registry.dart`. If no type fits, the lead
decides whether a new type is worth building (Sonnet) or the figure is dropped. Render all CSE
figures on one contact-sheet page in light and dark themes (debug route or the W2 gallery; lead
picks the cheaper). Aedwon QAs from the contact sheet.

E7. **Aedwon QA and content build.** Aedwon reviews rewritten lessons in the staging web
app and figures on the contact sheet; findings go back to E4 or E6. Build the seed content database
(full for mobile, CSE-only for web) with the existing content tools.

### Lane L. Launch hardening and release

Owner: Claude lead, with the integration owner.

L1. Firestore and Storage rules reviewed for web clients (W6 Task 6 snapshot first).
L2. App Check for web with reCAPTCHA Enterprise; enforce on callable functions used by web.
L3. Connect `pantas.study` to production Hosting (DNS records from the Firebase console); add it to
Auth authorized domains and App Check; budget alerts on Blaze.
L4. Privacy and terms pages reachable from the web app; payment terms added for prepaid access.
    Refund policy (decision log, October 19): refunds only for a duplicate charge or a payment that
    did not unlock Pro, refunded in full; no partial refunds on request; passes not refunded after
    their exam date. Published on pantas.study before PayMongo verification.
L5. Phone acceptance by Aedwon on staging (Android Chrome, iPhone Safari installed to Home Screen).
L6. Production deploy (functions, rules, hosting) after Aedwon's explicit release approval.
Publication is a separate decision under `WORKFLOW.md`.

### Failure and stop rules

- Any departure from an approved board, copy or behavior: stop, ask Aedwon with the visual
  companion.
- Any change to payment, entitlement or rules code outside Lanes C and L: stop, lead review.
- W4 conflicts with Lane B or C files: the integration owner decides the order; do not resolve by
  overwriting.
- A failing gate is reported with its output; no skipped or weakened check.

## After launch

- W4g Wrapped and sharing (D3).
- Desktop layout from Claude Design.
- Admin lookup tool: by email or PayMongo payment id, list payments, grants and audit rows; flag
  duplicate charges and payments that did not unlock Pro (about half a day; parked October 19).
- Redemption codes and account-ID grants for extra mocks and Pro (marketing campaigns).
- Android and iOS store releases.

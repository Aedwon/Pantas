# Founder app: Owner Inputs, Support, Numbers and Inbox (Nov 10, 2026)

Status: written for Aedwon's approval. Not built. Complexity: Balanced (Aedwon, Nov 2 and Nov 9).
Build order: Owner Inputs first, then Support, Numbers and Inbox (Aedwon, Nov 9).
Decision record: `docs/superpowers/decisions/2026-11-02-founder-app-log.md` (every choice, the
options offered, his exact words and the lead rulings of Nov 9).
Policy: main at b2621b64e. Code facts: `web/design-system-4` at 89559a2e2.
Boards: Claude Design canvas "Pantas Founder App", page "DS4" (link in Part 1, "What you approve").

---

## Part 1: Plain language

### What it is

A private app on your Mac, opened from Spotlight like Content Pass. You sign in with Google each
time you open it. It has four tabs:

1. **Owner Inputs** (built first). The things only you can give, each with a field or a switch.
   Sessions on this Mac read this list, so you no longer tell each session when something is ready.
2. **Support.** Find a student by email, public ID or account ID. See what needs you, their Pro
   time, their payments, and act: grant Pro, end Pro, record a refund, delete their data.
3. **Numbers.** Sign-ups, payments, failed payments, refunds, server errors and web app errors for
   today, 7 days or 30 days.
4. **Inbox.** Questions students reported from the app, to dismiss or mark for fixing.

Posts and Content Pass are not tabs in this build (your Nov 9 choice; Content Pass stays its own app).

### The look

The app follows design system 4.0, like the student app. This replaces the Green frame you picked on
Nov 2: its green window frame, card shadows and red status marks break the system's rules. What you
chose in it stays: the page that says what needs you, the student page with the Pro time bar,
confirmations in a side panel, and Delete Data set apart from everyday actions.

### Owner Inputs

Thirteen items, in five groups:

- Business registration: BIR registration (COR), DTI business name, business phone, invoice or
  receipt method.
- Payments: the PayMongo sole proprietor upgrade.
- Website: your footer facts (your own copy).
- Privacy: NPC registration, the signed child privacy assessment, the dpo@pantas.study inbox, and the
  sender address for privacy emails.
- Keys: the guardian mail key, the RevenueCat secret key and the RevenueCat webhook secret.

Each item says what it unblocks and shows Not Yet or Ready. A value item becomes Ready when you save
a value. A done item has a switch. A key is pasted once and goes straight into Google's secret store
for the project you pick. The app never keeps it or shows it again; it shows only the date you set it.
After a key changes, a session must redeploy before the live app uses it.

Values stay on your Mac, never in the public repository. Sessions that run on another computer
cannot see them.

### Support

- **Needs you.** The Support page lists what needs you: double payments, passes paid after their
  exam date, and refunds PayMongo has not confirmed. With nothing waiting it says "All clear." The
  Support tab shows how many items wait.
- **Student page.** Pro end date, exam and level, every source of Pro on one time bar (payments,
  trials, beta grants, the beta reward, your grants), and each payment with its refund state.
- **Grant Pro.** Pick a level, a length (1 week, 2 weeks, 1 month or 3 months) and a reason. Grants
  are recorded in the Pantas records, not RevenueCat, so each can be removed alone. Guest accounts
  with no email cannot get one.
- **Remove Pro.** Ends free time (grants, trials). It can also end paid time, but only for a Terms
  breach, with a warning that no money goes back.
- **Refunds.** Card payments: the app checks the refund is allowed, copies the payment ID and opens
  PayMongo; the refund is logged when PayMongo reports it. QR Ph payments: PayMongo cannot refund
  them, so you send a bank transfer and record it in the app with the amount and bank reference. The
  app then ends the paid time that money covered.
- **Delete Data.** The same full deletion students get. You type the student's email and pick a
  reason. It is refused while a refund or dispute is open. The log keeps the account ID, not the email.
- **Log.** Every grant, removal, recorded refund and deletion is saved with the time and reason, and
  shown on the Log page.
- **Staging.** A switch moves the app to the staging project to rehearse. A banner says real students
  are not touched there.

### Inbox and the report sender

Students can already report a question, but reports stay on their device. This build sends them to
the server, with daily limits, and changes "Saved on this device." to say the report was sent. The
Inbox lists them as New, To Fix or Done. "Needs Fix" puts a report on a list content sessions read.
Beta feedback stays in the Firebase console; it ends with the beta.

### Numbers

Sign-ups, payments and refunds come from the Pantas records. Failed payments need one more PayMongo
event on the payment webhook. Web app errors come from the speed and error reports the web app
already sends; they are kept 30 days. Firebase cost is a link to the billing page.

### What it costs

- **Time (estimates of agent work):** Owner Inputs with the app shell and sign-in, about 1 to 2
  days. Support, Numbers and Inbox, about 5 to 7 days more. The outside Codex audit and fixes, about
  a day.
- **Your time:** a few one-time Google Cloud setup steps for sign-in (an agent prepares exact steps or
  does what its access allows); the visual check on staging data; approving the production deploys.
- **Server changes on production,** each deployed only with your go: the founder grant type, the
  deletion path for a named account, the failed-payment event, the report sender, and the founder
  log. The student app changes once: the report wording.
- **Risk:** this app can end Pro and delete accounts on production. Limits: only your Google account
  can sign in; access lasts one hour and is never saved on disk; deletion needs the typed email; every
  action is logged; Codex audits the money and deletion code before it reaches production.
- **Upkeep:** when payment rules change in the server code, the app follows, because it uses the same
  code rather than a copy.

### What needs you

- Approve this section and the boards.
- Later, at deploy time: your go for each production deploy.
- Over time: fill in Owner Inputs as each item becomes available.

### What you approve

- This Part 1.
- The DS4 boards on the "DS4" page of the founder app canvas, version stated in Part 2. The built app
  must match them on the screens they show. Screens or states not drawn follow DS4's own patterns.
  Canvas: https://claude.ai/artifact/8TwdfQP8rcvMrD6uopYC3k

### How completion is judged

- Owner Inputs: every item can be set; a key reaches Google's secret store on the chosen project and
  is not stored on the Mac; a session can read which items are ready from the file.
- Support: on staging, each action works on test accounts and shows in the log and on the time bar.
  A QR Ph refund recorded in the app shortens or ends the pass exactly as the manual runbook did.
- Deletion removes the same records as student self-deletion (a test compares them).
- Numbers match counts taken directly from Firestore and the error log for the same period.
- A report sent from the staging web app appears in the Inbox.
- Codex's outside audit of money and deletion has no open finding.
- Your visual check matches the boards.

### Not in this build

Posts, Content Pass as a tab, email in the Inbox, refunds sent from inside the app, a real Firebase
cost figure, an export before each deletion, and alerts while the app is closed (Hardened).

---

## Part 2: For agents

### Facts this design rests on

Read on `web/design-system-4` at 89559a2e2 unless stated.

- **Grants.** `users/{uid}/grants/{id}` (`functions/src/grants.ts`): `source` (`paymongo`, `trial`,
  `beta`, `beta_reward`), `product`, `tier` (`student`, `civilService`, `licensure`, `nce`),
  `startsAt`, `endsAt`, `paymentId`, `paidAt`, `examId`, `sitting`, `paidAmount`, `refunds` (refund
  id to centavos), `fullEndsAt`, `state` (`active` or `revoked`), `revokedReason`, `disputeId`,
  `createdAt`. RevenueCat passes: `users/{uid}/passes`. Entitlement: `users/{uid}/server/entitlement`
  (`pro`, `proUntil`, `version`, `claimsPending`, `facts.sources`), computed by
  `entitlementInputs.ts` `claimsFromInputs` from store sources, passes and `ledgerGrants`.
- **PayMongo.** `paymongoWebhook.ts` handles `checkout_session.payment.paid` and
  `dispute.resolved`, and revokes on `refund.succeeded`, `payment.refunded`,
  `payment.refund.updated`, `dispute.created`. `payment.failed` is not handled. Refund follow-ups:
  `paymongoFollowUps/{id}` with `reason` `unusedDuplicatePass` or `paidAfterSitting`, `status`,
  `refundRequired`. `revokePaymongoPayment` records a refund, shortens `endsAt` by the refunded share,
  revokes on a full refund, replans later grants and rewrites the entitlement. Early refunds wait in
  `paymongoRevocations`. Other collections: `paymongoPayments`, `paymongoOrders`,
  `paymongoCheckouts`, `webhookEvents`, `audit_logs`.
- **QR Ph.** PayMongo's refund API refuses QR Ph (test mode, Nov 9). The manual runbook
  (`docs/OPERATIONS.md`, "Manual QR Ph refund") sends a signed `payment.refunded` event with refund id
  `manual_<label>`; a repeated label is a no-op. Refunds above the PayMongo balance are refused (D8).
- **Deletion.** `deleteAccount.ts` (callable, App Check, named user, sign-in within 5 minutes):
  recursive delete of `users/{uid}`, guardian records, `retirePublicId`, pass ownership, `paymongo*`
  docs for the uid, `wrapped_shares`, Storage `wrapped/{uid}/`, then the Auth user. Trial identity
  hashes stay.
- **Public ID.** `functions/src/publicId.ts` (`isValidPublicId`, `ensurePublicId`, `retirePublicId`).
- **Reports.** `lib/core/storage/data/report_queue.dart` stores `{questionId, message, createdAt}`
  under `quiz_question_reports` in `devicePrefs`; limits 3 per question and 20 per day; "Saved on
  this device." in `report_form.dart`, `quiz_page.dart`, `quiz_question_viewer.dart`. No server
  sender exists. The abuse review (`docs/superpowers/plans/new-design/gates/abuse-review-1.md`) asks
  for server-side limits and bounded text before one is enabled.
- **Telemetry.** `reportClientTelemetry` writes `kind: 'client_telemetry'` lines (web errors grouped
  by type and first frame) and `_timed.ts` writes `kind: 'fn_timing'` per callable, to Cloud Logging,
  kept 30 days. Reader: `tools/telemetry/report.mjs`.
- **Secrets.** `GUARDIAN_MAIL_API_KEY`, `REVENUECAT_SECRET_API_KEY`, `REVENUECAT_WEBHOOK_SECRET`
  (among others) via `defineSecret`. Functions read the version bound at deploy, so a new version
  needs a redeploy.
- **Projects.** `pantas-staging` and `pantas-prod`, region `asia-southeast1`. Prod still runs
  PayMongo test keys.
- **Content Pass** (`claude/content-pass-r1-4eb59e` at c1b94901f, unmerged): Flutter web UI, Dart
  server on 127.0.0.1 with a random port and `--parent-pid`, native AppKit window with WKWebView,
  installed by `make_app.sh` into `~/Applications`, Spotlight-indexed. No request token check.

### Design choices settled by the lead (D191; log, Nov 9)

1. **Stack.**
   - `tools/founder_app/` in the repo, outside `lib/`. A check fails if anything in `lib/` or
     `functions/src` imports it.
   - UI: plain HTML and TypeScript pages that load DS4's generated `tokens.css` and
     `components/bundle.css` (from `design/system/`), with no UI framework. Markup copies the DS4
     README markup, so the app matches the boards. Behavior uses small vanilla modules.
   - Local server: Node and TypeScript. It imports the needed modules from `functions/src` (grants,
     entitlement, refund, deletion, public ID) through a thin adapter that supplies a Firestore and
     Auth handle built from the founder credentials. No business logic is copied. Where a function
     body is tied to a callable wrapper, extract the core into an exported function in
     `functions/src` first, with the callable calling it, so both paths share one implementation.
   - Window: a native AppKit app with WKWebView, modeled on Content Pass (`mac/`, `make_app.sh`,
     single instance, starts and stops the server). Installs to `~/Applications/Pantas Founder.app`.
   - The server binds 127.0.0.1 on a random port. The window generates a random 32-byte launch
     secret, passes it to the server on stdin, and sends it on every request as a header. The server
     rejects requests without it, rejects any `Origin` other than its own, and serves no CORS.
2. **Sign-in and access.**
   - Google OAuth for installed apps (loopback redirect, PKCE) in the local server. The token stays in
     server memory only; nothing is written to disk. The app accepts only Aedwon's Google account
     (configured email, checked on the ID token).
   - With that identity, the server calls IAM Credentials `generateAccessToken` for a founder service
     account in the chosen project (`founder-app@pantas-prod`, `founder-app@pantas-staging`), lifetime
     1 hour. Aedwon's account holds Service Account Token Creator on those accounts only.
   - Founder service account roles: Firestore read and write (`roles/datastore.user`), Firebase Auth
     user read and delete (`roles/firebaseauth.admin`), Storage object delete on the default bucket,
     Logging read (`roles/logging.viewer`), Secret Manager version add on the three named secrets only
     (`roles/secretmanager.secretVersionAdder` bound per secret). No other roles. The plan lists the
     exact grants; an agent applies staging, Aedwon approves prod.
   - After an hour the next request fails; the UI shows the "Sign in again" dialog.
3. **Owner Inputs storage.** `~/Library/Application Support/Pantas Founder/owner-inputs.json`, mode
   0600: `{version, items: [{id, state: 'notYet'|'ready', value?, setAt?, project?}]}`. Keys never
   appear in the file; key items store only `setAt` and `project`. Item definitions (id, group, label,
   kind, unblocks) live in the app's code. Writes are atomic (write then rename). `docs/OPERATIONS.md`
   gets an "Owner inputs" section: a session blocked on an input reads the file; a missing file means
   nothing is ready. Item ids: `bir_cor`, `dti_name`, `business_phone`, `invoice_method`,
   `paymongo_sole_prop`, `website_footer`, `npc_registration`, `child_privacy_assessment`,
   `dpo_inbox`, `privacy_sender`, `guardian_mail_key`, `revenuecat_secret_key`,
   `revenuecat_webhook_secret`. The whole app opens behind sign-in (Nov 2 choice); saving a key uses
   the chosen project's founder service account.
4. **Lookup.** One field: an email (Auth lookup), a public ID (`isValidPublicId` then the public ID
   index), or an account ID. No partial search.
5. **Needs-you list.** Pending `paymongoFollowUps`, plus refunds recorded in the log as "waiting for
   PayMongo" with no matching refund on the grant after 3 days ("A refund couldn't be confirmed").
   The Support nav item shows the count, with the heads-up mark when any item is a refund not
   confirmed.
6. **Founder grants.** New grant `source: 'founder'`, written through the same ledger and
   entitlement path as other grants, with `tier`, `startsAt` (now, or the end of current Pro of that
   tier so time stacks), `endsAt`, `reason`, `note`. Lengths: 7, 14 days, 1 or 3 calendar months.
   Refused for anonymous accounts. Removal sets `state: 'revoked'`, `revokedReason: 'founder'`, then
   replans. `docs/pricing.md`'s giveaway line changes to point at the founder app.
7. **Ending paid time.** Only with reason "Broke the Terms" (Terms section 6 refunds unused prepaid
   time in every other case). It revokes the PayMongo grant with `revokedReason: 'termsBreach'` and
   moves no money. Other cases use refunds.
8. **Refunds.**
   - Card: eligibility from the grant and payment (card refunds within 60 days of payment, not
     already refunded, unused or a follow-up case). "Copy Payment ID" and "Open PayMongo". The log
     records "waiting for PayMongo"; the webhook's refund event completes it.
   - QR Ph: "Record Bank Refund" with amount (centavos, at most the unrefunded paid amount) and bank
     reference. The server calls the same refund core as the webhook (`revokePaymongoPayment`) with
     refund id `manual_<label>`, label derived from the log entry id so a retry is a no-op. The
     PayMongo webhook signing secret is never on the Mac.
9. **Deletion.** Extract the body of `deleteAccount` into an exported `deleteUserData(db, auth,
   storage, uid)`; the callable keeps its checks and calls it. The founder path calls the same
   function after: typed email equals the account's email; no pending follow-up, no grant with an
   open dispute, no "waiting for PayMongo" log entry for the uid. The log entry keeps uid, reason and
   time, never the email.
10. **Founder log.** Firestore `founderLog/{id}` on each project: `at`, `action`, `uid`, `email`
    (absent for deletions), `reason`, `note`, `details`. Rules deny all client access. Written before
    an action as `pending` and updated to `done` or `failed`, so a crash leaves a trace.
11. **Numbers.** Sign-ups from Auth creation times (listUsers paged, counted per period); payments and
    refunds from `paymongoPayments` and grant `refunds`; failed payments from a new
    `payment.failed` webhook case writing `paymongoFailures/{eventId}` (no grant change); server
    errors from `fn_timing` lines with `outcome: 'error'`; web app errors from `client_telemetry`
    error entries; "See Errors" opens a list grouped like `report.mjs`. Firebase cost is a link.
12. **Report sender.** Callable `sendQuestionReport` (App Check, signed-in user including guests):
    `questionId` validated against the content index, `message` 1 to 500 characters, server limits 3
    per question per user and 20 per user per day. Writes `questionReports/{id}` with `uid`,
    `questionId`, `examId`, `message`, `createdAt`, `status: 'new'`. The client sends queued reports
    and new ones, removes each from `quiz_question_reports` after success, and keeps it on failure.
    Wording (lead's copy call, written rule 4): "Report sent. Thank you." and, when offline, "Saved.
    It will send when you are back online." Rules deny client reads.
13. **Inbox.** Lists `questionReports` by `status` (New, To Fix, Done). "Needs Fix" sets `toFix` and
    appends the report to `~/Library/Application Support/Pantas Founder/content-fixes.json`, which
    content sessions read (pointer in `docs/OPERATIONS.md`). "Dismiss" sets `dismissed`. Marking fixed
    is done by the content session through the app's local file and later by Aedwon in the Inbox.
14. **Staging switch.** Account block popover with Production and Staging. Switching signs in to the
    other project's service account. Staging shows a Notice on every page.
15. **Navigation counts.** DS4 SidebarNav has no count slot. The founder app adds one (board gap
    G1), drawn from existing tokens. It is recorded as a founder-app extension in DS4 governance, not
    a student app change.

### Boards

Canvas "Pantas Founder App", page "DS4", boards prefixed `D4`. The approved version is the canvas
version recorded in the decision log at approval. Board gaps and their rulings are listed on the
canvas notes and in the log. The earlier Green frame boards stay on their pages as history.

### Tests at the seams

- Shared server core: unit and emulator tests in `functions` for `deleteUserData` (same document set
  as the callable before extraction), founder grant stacking and removal, termsBreach revoke,
  manual refund idempotence, `payment.failed` recording, and `sendQuestionReport` limits.
- Local server: request without the launch secret or with a foreign Origin is refused; wrong Google
  account is refused; actions write `pending` then `done`; the deletion preconditions refuse each case.
- Owner Inputs: file round trip, atomic write, key never written to the file (test reads the file
  after a key save).
- UI: a rendered capture per screen compared once with its board at the planned visual audit.
- Live staging run before any prod deploy: each Support action on a test account, one QR Ph manual
  refund matching the runbook result, one report from the staging web app reaching the Inbox.

### Order

1. **Owner Inputs release:** app shell, window, local server with the launch secret, Google sign-in
   and token exchange, Owner Inputs tab with the file and key saving, the `docs/OPERATIONS.md`
   pointer. Own worktree and branch.
2. **Support, Numbers, Inbox:** shared core extractions in `functions/src`, founder grant type,
   deletion path, founder log, refund flows, Numbers, report sender and Inbox, staging switch.
3. **Outside audit:** Codex GPT 6 Astra through `codex-pick`, on money and deletion paths, before any
   prod deploy. Findings fixed and re-checked.
4. **Deploys:** staging first; prod only with Aedwon's go.

Each step needs one local build at a time and one subagent at a time while the Mac is under load.

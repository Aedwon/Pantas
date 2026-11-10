# Founder app: Support, Growth, Content and Owner Inputs (Nov 10, 2026)

Status: written for Aedwon's approval. Not built. Complexity: Balanced (Aedwon, Nov 2 and Nov 9).
Build order: Part 1, "Build order". Posts and Content Pass are in (Aedwon, Nov 10). Source tracking is in (Aedwon, Nov 10).
Decision record: `docs/superpowers/decisions/2026-11-02-founder-app-log.md` (every choice, the
options offered, his exact words and the lead rulings of Nov 9).
Policy: main at b2621b64e. Code facts: `web/design-system-4` at 89559a2e2.
Boards: Claude Design canvas "Pantas Founder App", page "DS4" (link in Part 1, "What you approve").

---

## Part 1: Plain language

### What it is

A private app on your Mac, opened from Spotlight like Content Pass. You sign in with Google each
time you open it. Design system 4.0 allows four menu items, so the app has four, each holding what
you asked for:

1. **Support.** Find a student by email, public ID or account ID. See what needs you, their Pro
   time and payments, and act: grant Pro, end Pro, record a refund, delete their data.
2. **Growth.** Numbers that answer your decisions (the question list below), where students come
   from, your links and QR codes, campaign codes, and what you spend per channel. Posts joins this
   tab after its own short brainstorm.
3. **Content.** Questions students reported, to dismiss or mark for fixing, and Review: Content
   Pass, moved inside this app.
4. **Owner Inputs.** The things only you can give, each with a field or a switch. Sessions on this
   Mac read this list, so you no longer tell each session when something is ready.

Posts and Content Pass are in the founder app, as you decided on Nov 10. Content Pass is fully moved
in. Posts needs about 30 minutes with you first, to settle two or three post templates and one
channel; it gets its own boards after that.

### The look

The app follows design system 4.0, like the student app. This replaces the Green frame you picked on
Nov 2: its green window frame, card shadows and red status marks break the system's rules. What you
chose in it stays: the page that says what needs you, the student page with the Pro time bar,
confirmations in a side panel, and Delete Data set apart from everyday actions. Remove Pro and Delete
Data confirm in a center dialog, because the system confirms actions that destroy something in a
dialog. Grant Pro and refunds keep the side panel.

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
After a key changes, a session must redeploy before the live app uses it. Values stay on your Mac,
never in the public repository.

### Support

- **Needs you.** Double payments, passes paid after their exam date, and refunds PayMongo has not
  confirmed. With nothing waiting it says "All clear." The Support menu item shows how many wait.
- **Student page.** Pro end date, exam and level, every source of Pro on one time bar (payments,
  trials, beta grants, the beta reward, your grants), and each payment with its refund state.
- **Grant Pro.** Pick a level, a length (1 week, 2 weeks, 1 month or 3 months) and a reason. Grants
  are recorded in the Pantas records, so each can be removed alone. Guest accounts cannot get one.
- **Remove Pro.** Ends free time. It can end paid time only for a Terms breach, with a warning that
  no money goes back.
- **Card refunds.** One button, "Refund in PayMongo": it copies the payment ID and opens PayMongo.
  The payment ID also shows in the panel with a copy button. The refund is logged when PayMongo
  reports it. (Your comment: the two numbered buttons are gone.)
- **QR Ph refunds.** PayMongo cannot refund them, so you send a bank transfer, then drop or paste the
  bank's screenshot. The Mac's built-in text reading fills in the reference number; you check it and
  save. The image is shrunk to about 150 KB and kept with the log entry where only you can see it.
  The app then ends the paid time that money covered. Before this is promised, the reading is tested
  on five real screenshots from GCash, Maya, BPI and BDO, which need to come from you.
- **Delete Data.** The same full deletion students get. You type the student's email and pick a
  reason. It is refused while a refund or dispute is open. The log keeps the account ID, not the email.
- **Log** of every action, and a **Staging** switch to rehearse without touching real students.

### Where students come from (marketing attribution)

Goal: know which channels, campaigns and posts bring students who study and pay, and what each costs.

- **Tagged links for every channel.** Growth makes a link per channel and campaign (Facebook page, a
  Facebook group, TikTok, a school talk) with standard tags (UTM). Each link also gets a short link
  (pantas.study/go/...) and a QR code for posters and talks. [pantas-web]
- **First and last source.** Each account keeps the first source that brought the person and the
  last one before sign-up. Example: first saw a Facebook post, signed up after a TikTok video.
- **Kept across the hand-off.** A visitor who lands on pantas.study and signs up on app.pantas.study
  keeps their source. [pantas-web and the app]
- **"How did you hear about us?"** One optional question at sign-up, for sources links cannot see:
  Messenger, Facebook groups, friends, school. Skippable. [app]
- **Referral and campaign codes.** Each student's public ID works as a referral code
  (app.pantas.study/?ref=...). You create campaign codes in Growth, for example one per giveaway, so
  winners and entrants are counted by campaign. Codes give no discount: prices stay as in the pricing
  record. Paid gift codes stay deferred.
- **The funnel, per source:** visit, sign-up, first study session, first Today plan done, trial
  started, paid, renewed. Visits are counted on the website; every later step comes from records the
  app already keeps. [pantas-web for visits]
- **Retention and money per source:** how many come back after one and four weeks, and revenue and
  refunds by source.
- **Spend per channel.** You type what you spent per channel and month (boosted posts, printing). The
  app shows the cost per sign-up and per paying student.
- **Privacy, including minors.** Sources appear only as totals, never as one student's trail. No
  advertising pixels from Facebook, TikTok or Google, so no ad network sees our visitors. No IP
  addresses are kept. An agent drafts the privacy notice line, Codex critiques it, and you only check
  it (the standing rule for legal text). [pantas-web privacy page and the app]
- **Website copy stays yours.** The website changes are invisible scripts and the short links. Any
  wording a visitor sees on pantas.study goes to you for approval first.

Things you may not have listed, now included: search and direct visits (counted from where the
visit came from); students sharing the app (a shared link carries their referral code); sign-ups by
week, so you can compare campaigns over time; junk sign-ups left out of totals. Not included: Facebook
and TikTok post reach, which only those sites know. You can type it into Growth, or a later build
can read it from them.

### Growth: the questions the numbers answer

You confirm or change this list; the screens are then drawn to answer it.

1. Which channels bring sign-ups, and which bring paying students? Decides where to spend effort.
2. What does one paying student cost per channel? Decides which channel to keep or cut.
3. Which campaigns, links, codes and QR codes work? Decides which to repeat.
4. Where do people drop off between visit and payment? Decides which step to fix first.
5. How many people study each day, week and month, and is it growing? Shows if the product is
   healthy.
6. Do students come back after one week and after four, by sign-up week and source? Shows if
   onboarding and reminders work.
7. Which exams do students choose, and how close are their exam dates? Decides which exam's content
   to improve or add next, and when to run campaigns.
8. Which parts of the app do students use: lessons, quizzes, mocks? Decides where to build next.
9. Does Pro sell: trials started, trials that pay, sales by plan and level, refunds? Decides pricing
   and the Pro page.
10. Do paying students renew, and how much money comes in each month, by source? Shows if revenue
    holds.
11. Is anything broken: server errors, web app errors, failed payments? Decides what to fix before
    spending on marketing.
12. Which questions get reported most? Decides which content to fix first.

### Content: reports and Content Pass

- **Reports.** Students can already report a question, but reports stay on their device. This build
  sends them to the server, with daily limits, and the app says the report was sent. Content lists
  them as New, Needs Fix or Done, most reported first. "Needs Fix" puts a report on a list content
  sessions read. Beta feedback stays in the Firebase console; it ends with the beta.
- **Review (Content Pass, moved in).** Everything you approved for Content Pass carries over: the
  queue with exam and status filters, the four device sizes, light and dark, Free and Pro, Question,
  Correct and Wrong, the five tags with keys 1 to 5, comments, Looks Good and Next, and notes that
  survive restarts. The controls are redrawn on design system 4.0 to match the rest of the app. The
  screen in the middle is still the real app screen, so what you review is what students see. The
  separate Content Pass app is retired once the move is done. While the move runs, changes you want
  in Content Pass go into the new version.
- One open look question: you chose green for the selected option in Content Pass. Design system 4.0
  shows the selected option in neutral white. The board shows the system's version; tell me if you
  want green back.

### Build order

1. Owner Inputs, with the app shell, sign-in and the Content Pass tile.
2. Source capture on the website and in the app, so no sign-up is lost before launch. It ships with
   the next app release.
3. Support, with your comment fixes.
4. Content: reports, the report sender, and Content Pass moved in.
5. Growth: numbers, links, codes and spend, after you confirm the question list.
6. Posts, after its brainstorm.
7. The outside Codex audit of money and deletion, then production deploys with your go.

### What it costs

- **Time (estimates of agent work):** Owner Inputs, about 1 to 2 days. Source capture, about 2 days.
  Support, about 4 days. Content with the Content Pass move, about 4 to 6 days. Growth, about 3 to 4 days. Audit and fixes, about a
  day. Posts is estimated after its brainstorm.
- **Your time:** confirm the question list (about 15 minutes); the Posts brainstorm (about 30
  minutes); five bank screenshots; a few one-time Google Cloud sign-in steps; approving website
  wording and production deploys; checking the privacy line.
- **Changes outside the founder app,** each deployed only with your go: on pantas.study, a
  first-party script, a visit counter and short links; in the student app, the optional question,
  source capture and the report wording; on the server, the founder grant type, the deletion path,
  the failed-payment event, the report sender, the source records and the founder log.
- **Risk:** this app can end Pro and delete accounts. Limits: only your Google account can sign in;
  access lasts one hour and is never saved on disk; deletion needs the typed email; every action is
  logged; Codex audits money and deletion before production. Source data is kept as totals only.
- **Checks first, cheaply:** a half-day trial that the server code works inside the Mac app; a script
  that confirms daily and monthly active students can be counted from today's records; the five
  screenshot test.

### What needs you

1. Confirm or change the Growth question list.
2. A 30-minute Posts brainstorm, when you have time.
3. Five real bank transfer screenshots for the reading test.
4. Approve this section, then the revised boards.
5. Later: website wording, the privacy line, and each production deploy.

### What you approve

- This Part 1.
- The DS4 boards. Version 13 on the founder app canvas covers Owner Inputs and Support. Revised
  boards follow for your three comments, the four-item menu, Growth and Content, each reviewed and
  rendered before you see them. The built app must match the approved boards.
  Canvas: https://claude.ai/artifact/8TwdfQP8rcvMrD6uopYC3k

### How completion is judged

- Owner Inputs: every item can be set; a key reaches Google's secret store and is not stored on the
  Mac; a session can read which items are ready.
- Support: on staging, each action works on test accounts and shows in the log and on the time bar.
  A QR Ph refund recorded in the app matches the manual runbook's result.
- Deletion removes the same records as student self-deletion.
- Attribution: a test visit through a tagged link, a short link and a QR code, from pantas.study to
  sign-up on staging, shows the right first and last source in Growth.
- Growth numbers match counts taken directly from the records for the same period.
- A report sent from the staging web app appears in Content.
- Codex's outside audit has no open finding. Your visual check matches the boards.

### Not in this build

Email in the app, refunds sent from inside the app, a real Firebase cost
figure, Facebook and TikTok reach read from those sites, advertising pixels, paid gift codes,
discount codes, an export before each deletion, and alerts while the app is closed.

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
11. **Growth numbers (health part).** Sign-ups from Auth creation times (listUsers paged, counted per period); payments and
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
13. **Content reports (formerly Inbox).** Lists `questionReports` by `status` (New, Needs Fix, Done). "Needs Fix" sets `toFix` and
    appends the report to `~/Library/Application Support/Pantas Founder/content-fixes.json`, which
    content sessions read (pointer in `docs/OPERATIONS.md`). "Dismiss" sets `dismissed`. Marking fixed
    is done by the content session through the app's local file and later by Aedwon in the Inbox.
14. **Confirmations.** Grant Pro and both refund flows use the DS4 Drawer (Aedwon's Nov 2 side-sheet
    choice). Remove Pro and Delete Data use the DS4 Dialog, because `patterns.md` confirms
    destructive actions in a Dialog (lead ruling, Nov 10). Choice lists with six or fewer options
    are Radio groups or a SegmentedControl, per the Select README.
15. **Staging switch.** The account block opens a menu Popover with "Switch to Staging" (or
    Production) and "Sign Out". Switching signs in to the other project's service account. Staging
    shows a Notice on every page.
16. **Parts DS4 lacks (board gaps).** Each is drawn from existing DS4 tokens and classes, marked on
    its board, and recorded as a founder-app extension in DS4 governance, not a student app change:
    G1 a count at the end of a nav item (warning color and icon when an urgent item waits); G2 the
    account block as a menu trigger; G3 the Pro coverage timeline (ProgressBar segments with dates);
    G4 the sign-in layout; G5 big-number tiles on Numbers.

17. **Menu.** Four destinations (DS4 SidebarNav limit): Support, Growth, Content, Owner Inputs.
    Growth holds Numbers, Sources, Links and Codes, Spend, and later Posts, as sections or a
    SegmentedControl view switch. Content holds Reports (formerly Inbox) and Review (Content Pass,
    ported; item 24).
18. **Card refund (Nov 10 comment).** One primary "Refund in PayMongo" copies the payment ID to the
    clipboard, opens the PayMongo payment page, and shows a Toast "Payment ID copied". The body shows
    the payment ID in a row with a copy IconButton. Footer: tertiary Cancel and the one primary.
19. **QR Ph screenshot (Nov 10 comment).** Drop, paste or pick an image in the QR Ph drawer. The native
    shell runs Apple Vision text recognition (`VNRecognizeTextRequest`, accurate level) on device and
    returns lines to the page through a `WKScriptMessageHandler`. The page proposes the reference
    number from labeled lines ("Ref No.", "Reference", "Transaction ID") and long digit runs; the
    field stays editable and must be confirmed. The shell re-encodes the image (ImageIO) to WebP or
    JPEG, longest side 1600 px, about 150 KB, strips metadata, and the server stores it at Storage
    `founderReceipts/{logId}` with no client access. Kept 5 years with the business records, then
    deleted. A five-screenshot test (GCash, Maya, BPI, BDO) gates the spec's promise; if recognition
    fails it, the field is typed by hand and the upload still works.
20. **Attribution capture on pantas.study** (pantas-web repository, its own branch and review):
    - A small first-party script on every page reads UTM tags, `ref`, `code`, the referrer host and
      the landing path. It writes one cookie `pantas_src` on `Domain=.pantas.study` (so
      app.pantas.study can read it), `SameSite=Lax`, `Secure`, 90 days: `{first, last}` touches, each
      `{source, medium, campaign, content, ref, code, referrerHost, landing, at}`. First touch is set
      once; last touch is replaced on each tagged visit or external referrer. No fingerprinting, no IP.
    - The Cloudflare worker counts visits per day by source, medium, campaign and landing path in its
      D1 database, totals only, skipping known bots. Short links `/go/{slug}` redirect (302) to a
      tagged target and count the click. Link definitions are edited from the founder app through a
      worker admin endpoint authenticated by a token in Google Secret Manager (the founder service
      account may read that one secret).
    - Any visible wording on the site goes to Aedwon first. The privacy page line is agent-drafted,
      Codex-critiqued (written rule 5), and published with the app change.
21. **Attribution in the app and server.** On account creation the client reads `pantas_src` and any
    `ref` or `code` URL parameter on app.pantas.study and calls `recordAttribution` once (App Check,
    signed-in). The server validates fields (lengths, allowed characters), resolves `ref` through the
    public ID index and `code` through `campaignCodes/{code}`, and writes
    `users/{uid}/server/attribution` `{first, last, heardFrom?, referrerUid?, campaignCode?, at}`. It
    is deleted with the account. "How did you hear about us?" is one optional, skippable question
    after sign-up with fixed choices (Facebook page, Facebook group, Messenger or a friend, TikTok,
    School or review center, Search, Other) stored as `heardFrom`. Students' shared links carry
    `ref=<publicId>`. Funnel steps come from existing records: Auth creation (sign-up), first
    `ingestSession` (first session), first full Today plan (first plan done), `server/trial` (trial),
    PayMongo grants (paid), a later paid grant of the same tier starting at the previous end
    (renewed). Junk sign-ups (no session within 7 days and a disposable email domain) are excluded
    from totals and counted separately.
22. **Aggregation.** A scheduled function writes daily totals to `founderStats/{date}` (by source,
    campaign, code, exam, cohort week). The founder app reads only these totals; no screen shows one
    student's source. Totals below 3 show as "fewer than 3". Daily, weekly and monthly active
    students count distinct accounts with a study session in the window. Spend: `founderSpend/{month}_
    {channel}` in centavos with a note; cost per sign-up and per paying student divide spend by first-
    touch totals for the month. Campaign codes: `campaignCodes/{code}` `{channel, campaign, startsAt,
    endsAt}`; codes never change prices. Before the Growth build, a one-off staging script confirms
    each of the 12 questions can be computed from these records; a question that cannot is reported
    back to Aedwon, never filled with an estimate.
23. **Minors.** Attribution for accounts in the minor age group is recorded like any other but only
    ever shown inside totals. No third-party pixels or ad SDKs on the site or the app. The privacy
    notice line covers the purpose (understanding which channels bring students) and its basis; the
    drafter and Codex decide whether minors need the guardian's choice before attribution is kept,
    and the build follows that result.

24. **Content Pass port** (Aedwon, Nov 10: "full port"; rulings in the log the same day). Source:
    `claude/content-pass-r1-4eb59e` at c1b94901f, spec `docs/superpowers/specs/2026-11-02-content-pass.md`
    and its log on that branch. The real screens must stay Flutter, so: the reviewer chrome (queue,
    filters, device, theme, plan, outcome switch, tags, comment, actions, keys) is rebuilt on DS4 in
    the founder app; the Flutter web entry is reduced to the screen host only and is served by the
    founder server into a frame in the Review view, driven by `postMessage` (item, size, theme, plan,
    outcome); the Dart export and seed server becomes a helper process the founder server starts on
    127.0.0.1 with the same launch secret rule. The notes file keeps its path and format, so existing
    notes survive. `tools/content_pass/` moves under `tools/founder_app/content_review/`; the
    no-leak test and layering rule carry over. The old app bundle is removed by `make_app.sh` after
    the founder app installs. The port waits for Content Pass to be merged or its branch frozen; the
    plan names the commit it ports.

### Boards

Canvas "Pantas Founder App" (https://claude.ai/artifact/8TwdfQP8rcvMrD6uopYC3k), page "DS4", 20
boards prefixed `D4`, version 13 (id 1794241164-6272). Before Aedwon saw them: an independent DS4
review (14 findings, all fixed) and one headless render per board. DS4 bug B1: the bundle styles
`.dtable tbody th` like a column header, so boards use `td` for row headings until DS4 fixes it; the
build follows whichever the bundle supports at build time. Board gaps and their rulings are listed on the
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

As Part 1, "Build order". Step 1 runs in its own worktree and branch. Steps 2 (pantas-web and app
source capture) and 6 (Posts) get their own plans; step 6 also its own brainstorm and boards. The
outside audit (Codex GPT 6 Astra through `codex-pick`) covers money, deletion and the attribution
endpoints before any production deploy. One local build and one subagent at a time while the Mac is
under load.

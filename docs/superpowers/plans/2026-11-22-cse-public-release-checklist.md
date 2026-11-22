# CSE public release checklist, 22 November 2026

**Purpose.** Defines "done" for the operations manager: everything that must be true before
Pantas opens to the public for the Civil Service Exam (CSE), Free and Pro, on the web PWA. The
beta closes 23 Nov 2026 00:00 Manila. Native store releases are out of scope.

**Status of this file.** Research only. Nothing was fixed. Written 22 Nov 2026 (Manila) from
`origin/main` at `ecfeaf0d1`, plus open PR #82 and PR #76 as seen on GitHub that day. Where a
source could not confirm a state, the cell says "unknown, check". Items marked **HIS** need
Aedwon alone: a prod "ship it", legal sign-off, billing, a physical step, or his PayMongo, BIR
or DTI account. Every prod ship is HIS by standing rule (`docs/superpowers/plans/2026-11-21-manager-handoff.md:87`).

**Public repo.** No tester names, emails or account ids. Tester data appears as counts only.

## Standards applied

- `WORKFLOW.md` and `AGENTS.md` (pricing, never invent a figure, voice).
- Process-improvement rules, `docs/workflow/process-improvement.md`: rule 5 (never ask him to
  write legal text, line 61), rule 6 (emails to him first, line 69), rule 7 (only real users may
  cost money, line 80), rule 8 (email shape, line 96), rule 9 (privacy changes emailed after
  opening, line 110).
- `docs/pricing.md` is the only price source.
- Sources swept: `docs/superpowers/backlog.md`, launch log from Nov 9, `docs/deploy-prod.md`,
  `docs/OPERATIONS.md`, `docs/payments/`, `docs/legal/`, `docs/legal-drafts/`, Nov 21 handoff,
  Nov 17 backlog rulings (`docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md`).
- Not used as gates: `docs/superpowers/2026-08-03-launch-checklist.md` (native-era inventory,
  banner says superseded; backlog line 163), `docs/release-e2e.md` (Android emulator suite, not the
  PWA), and the unchecked boxes in `docs/OPERATIONS.md` (last updated 7 May; backlog line 162).
  Their live obligations are carried below (NPC registration, pentest, lawyer review).

Launch log is abbreviated `LL` (`docs/superpowers/decisions/2026-10-19-pwa-launch-log.md`);
backlog is `BL`.

---

## 1. Product quality

| # | Gate | State and evidence | Owner | HIS? |
|---|---|---|---|---|
| P1 | Every answer saves. No question id can block a save. | **Open.** On prod, answers to 261 of 4,427 questions fail ("Could not save your progress"); cause is an analytics check on ids over 64 characters (`LL:4103-4108`). Fix is PR #82 (open, CI running on head `1a1ffc2b8` when checked); not merged, not on prod. | CSE QA lead (per the request). Fix lane: security and billing lead r2 | Prod "ship it" is HIS |
| P2 | A student's "report a question" reaches someone who can read it, or the control is removed or reworded. | **Open.** The report queue has no backend; no report has ever reached the server (`LL:4108`; `lib/core/storage/data/report_queue.dart:87-88`). Not new. Whether it is in launch scope: unknown, check. | Unassigned | No |
| P3 | CSE UI passes the QA lead's review (Free and Pro, phone and desktop web). | Unknown, check. No QA report is on main. | CSE QA lead | No |
| P4 | Prod real-device proof: a stuck Reviews session resumes, a quiz finishes, feedback with a screenshot sends. | **Unproven.** `BL:51` (A18) says the beta monitor reads prod counts; no closure is logged. The Nov 22 save failure on his own phone shows quiz finish was not clean for long ids. Unknown, check after P1. | Beta monitor, then CSE QA lead | Physical phone step only if logs show none (`BL:36,51`) |
| P5 | No open tester issue rated medium or higher. | Digest (`Pantas-private/beta/digest.md`, last pass 23 on Nov 18 14:47 PHT, 4 days old): **5 distinct medium issues, 0 high or critical, 0 confirmed closed by a fresh tester session.** Titles: "Study owner changed" error on Home; "Reviews batch is unavailable"; stale sign-in on reopen; old build served after a deploy; birth-year wheel one year per swipe. Each has a shipped fix (`LL:3727`, `LL:3420`, age stepper in DS4), none re-observed. Two low-to-medium notes remain (Home read bursts, exam date picker). Only 2 feedback documents exist in total. Passes after Nov 18: unknown, check. | Beta monitor | No |
| P6 | A student who turns 18 stops being marked a minor. | **Not started.** Ruled "first release after Nov 22, before public launch" (`BL:124`, E17). | Unassigned (integrator route) | No |
| P7 | A fresh device first sync no longer makes one call per read lesson. | **Not started.** Ruled "before the beta gate drops for public launch" (`BL:97`, D15). | Unassigned | No |
| P8 | Phone reader bar keyboard Tab stop, hover and focus defect is fixed. | Ruled "fix before the next prod release" (`BL:118`, E11); a "keyboard and hover fix" shipped Nov 14 (`LL:3576`). Whether it is closed: unknown, check. | DS4 completion lane (idle) | No |
| P9 | Load time on phones stays under 10 seconds. | Latest reading 5.7 s; reopen only above 10 s (`BL:120`, E13). No post-beta reading: unknown, check. | Beta monitor | No |
| P10 | Every number shown on CSE screens is measured, published or from a named algorithm. | Unknown, check. Subprofessional mock section counts are an even-split placeholder (`BL:50`, A17, ruled DO LATER). Whether the placeholder is labeled to students: unknown, check. | CSE QA lead | No |

## 2. Content

| # | Gate | State and evidence | Owner | HIS? |
|---|---|---|---|---|
| C1 | CSE Professional and Subprofessional content is live and fills every mock slot. | **Met on prod, Nov 21 (Manila).** Prod serves `content/cet-bite-r1` d97de9415 plus three main files; CSE Pro mock fills 155, CSE Sub 145; exam summaries hold 1,751 and 1,523 questions (`LL:4044-4056`, `LL:4092-4100`). | Integrator | No |
| C2 | CSE content is bite-sized and approved. | **Met per handoff.** All CSE lessons split and live (`BL:64`, B7; handoff line 46). Content edits stay behind the approval gate. | Content lanes | No |
| C3 | The content audit sweep runs clean on the content prod serves. | **Open, not ruled.** `tools/audit/run_all.py` stops with 182 illustration-marker errors on the prod content root and crashes on an index error (`BL:78-79`, C9 and C10). Whether this blocks launch: unknown, check. | Unassigned | Ruling is a call for the manager or him |
| C4 | No unapproved question is served to the public. | Unknown, check. 968 unapproved questions were still exported "until their subject is split" (`BL:170`; `LL:2398,3253`). | Content lanes | No |
| C5 | Only CSE is open to the public. Other exams stay "Coming soon" or hidden. | **Met on prod.** CET exams stay "Coming soon" (`LL:4046`); custom exams row and reminders hidden (`BL:113`, E6). The CET-account proof (C5) is a gate for opening any CET exam, not for CSE (`BL:74`). | Integrator | Opening any other exam is HIS |
| C6 | Subprofessional mock counts. | Placeholder accepted by ruling until a taker reports real counts (`BL:50`). Listed so launch copy does not claim official counts. | Beta monitor watches feedback | No |

## 3. Payments

Prod runs PayMongo **test** keys (Nov 21 handoff, line 50). The five-step path is in
`LL:2779-2790`: staging test run, live activation, live keys plus one real small payment, public
Terms, drop the beta gate. The tracker is `docs/payments/2026-11-18-paymongo-support-request.md`.

| # | Gate | State and evidence | Owner | HIS? |
|---|---|---|---|---|
| M1 | PayMongo live activation: BIR COR, DTI business name, Sole Proprietor upgrade. | Upgrade **done** Nov 18 (tracker row 1). BIR COR and DTI name: unknown, check. On Nov 9 he had no COR (`LL:2835-2841`). | Aedwon | **HIS** |
| M2 | GCash, Maya, Visa and Mastercard are enabled for one-time payments. Checkout defaults to card and QR Ph (`functions/src/paymongoCheckout.ts`). | **Requested** Nov 18; no reply logged (tracker rows 2 and 3). | Aedwon | **HIS** (his PayMongo account) |
| M3 | Live secret key and live webhook secret are in the prod payment secret. The live webhook is registered for the paid and refund events. One real small payment is confirmed. | **Not started.** Prod is on test keys. Staging payment runs must disable the prod test webhook first (`LL:2831`). | Security and billing lead r2, with Aedwon | **HIS** (live keys, real charge) |
| M4 | One security pass before live keys: narrower function permissions, security headers, Pro sync quotas. S-12 checkout fix already shipped. | S-12 shipped to prod Nov 19 (`LL:3996-4003`). The other three: **not started** (`BL:100`, D18, "trigger: before live PayMongo keys"). A Codex audit of the money path is also named (tracker "Item 7 answer", point 6); its status: unknown, check. | Security and billing lead r2 | No |
| M5 | Plan copy says "prepaid period", not "renews". | **Met for web Terms and paywall** (`LL:4012`). Pro page wording: unknown, check (`BL:52`, A19). | Integrator | No |
| M6 | A refund path works at live: QR Ph by bank transfer plus the signed refund command. | Runbook exists and passed on staging in test mode (`docs/OPERATIONS.md`, "Manual QR Ph refund"). Live mode is untested. PayMongo's reply on QR Ph refunds: **Sent** Nov 19, no reply (tracker row 6). | Aedwon runs refunds; security lead owns runbook | **HIS** (bank transfers) |
| M7 | A way to find a payer, refund and grant by hand exists at live. | Founder app holds this (`BL:92`, D10 merged into A5); spec **not approved**, no build (`BL:31`). The manual refund command covers refunds only. Whether launch can run without it: unknown, check. | Founder app lead | Board approvals HIS |
| M8 | Registered invoices or receipts can be issued. | Not started; waits on BIR registration (`LL:2841`; `BL:28`, A6). | Aedwon | **HIS** |
| M9 | CSE products and web prices match `docs/pricing.md`: Weekly ₱49, Monthly ₱149, Yearly ₱1,199, pass ₱499. | **Met in code**: `functions/src/products.json` carries `pantas_cs_weekly/monthly/yearly` and both CSE passes at those prices. The 7-day trial is on Monthly only. Pass expiry date set to the 14 Mar 2027 sitting: unknown, check (`BL:142`). | Security and billing lead r2 | No |
| M10 | Payment record retention matches the published text. | **Open.** The Nov 9 note says account deletion can erase payment source records before the published five-year period; no protected archive is built (`docs/legal/2026-11-09-publication-dependencies.md`). The interim text was reworded to say deletion removes Pantas's payment records (`LL:2853`). What the live text says versus the system: unknown, check. | Under-13 and legal lanes, manager | Sign-off HIS |

## 4. Legal and privacy

| # | Gate | State and evidence | Owner | HIS? |
|---|---|---|---|---|
| L1 | Public Terms, Privacy Policy and Teen Notice are published, match what the app does, and carry live-payments and refund text. | In-app texts are live on prod from the Nov 10 interim set and the Nov 12 teen notice approval (`LL:3138-3143`, `LL:3189`). The payments and refunds Terms is still a draft with brackets for operator name, DTI number and address (`docs/legal-drafts/2026-10-30-terms-payments-refunds-draft.md:3`). Public pages on pantas.study: unknown, check. | Legal lane; agent drafts under rule 5, Codex Sol High critiques | **Sign-off HIS** |
| L2 | Public-launch legal package, including the teen notice "Age check" basis (NPC Opinion 2017-049). | **Not started.** "Trigger: the public launch legal package. An agent drafts under rule 5" (`BL:99`, D17). The minor-label flow stays as built (option A, `LL:3131-3136`; manager advised option D before live payments). | Unassigned (manager launches a lane) | **HIS** (legal sign-off) |
| L3 | Operator facts exist for the footer and Terms: business phone, name, DTI number, BIR details. | Phone **supplied** Nov 18 (`BL:28`). BIR, DTI number, footer facts: waiting. No postal address by design (`docs/OPERATIONS.md`). | Aedwon | **HIS** (facts about him) |
| L4 | NPC registration filed and confirmed. | Unconfirmed: box unchecked (`docs/OPERATIONS.md:246`, last updated 7 May), and listed as waiting on him (`BL:28`). Whether it is required before opening: unknown, check. | Aedwon | **HIS** |
| L5 | dpo@, contact@ and support@ mailboxes are monitored. | support@ proven Nov 18 (sign-in code sent and verified). dpo@ and contact@: unconfirmed (`BL:158`, `BL:28`). | Aedwon | **HIS** (his mailboxes) |
| L6 | Rule 9 is ready: from the moment of opening, any change to what is collected goes out by email first (guardian too for under 18). | Rule is written (`process-improvement.md:110`). The build lead flags such a change; the manager holds the prod "ship it". Gate: nothing collection-changing is queued after opening without its email. Mail capacity limit applies (see S4). | Operations manager | Every email goes to him first (rule 6) |
| L7 | Legal version stamps equal the publish date, and a Terms version bump prompt is acceptable. | Stamps read 2026-11-12 on main; confirm that is the day the documents went live (`BL:71`, C2). Replacing the interim Terms with final Terms will ask existing students to accept again (his Nov 11 "okay proceed", `LL:3122`). | Integrator | No |
| L8 | Lawyer review. | **Not a gate by his decision**: "no way, no money" (Nov 9, `LL:2755`). Recorded so no agent asks again. | None | Decided |
| L9 | Under-13 stays closed. CSE is 13+. | Draft PR #76 is in progress and must not deploy. The signed child privacy assessment is needed only before child accounts open (`BL:34`). | Under-13 build lead | Assessment HIS |

## 5. Security and cost

| # | Gate | State and evidence | Owner | HIS? |
|---|---|---|---|---|
| S1 | Prod Firestore App Check stays enforced with no real client refused. | **Enforced** Nov 21 12:37 UTC; the refused Mac browser was agents (`LL:4060-4066`). The watch ran to Nov 22 12:40 UTC; its final result is not logged: unknown, check. | Security and billing lead r2 | No |
| S2 | The CI free-tier gate passes at and after Nov 24 00:00 Manila. | Simulated pass before, at and after the date; warm-up stops in code at Nov 23 16:00 UTC (`LL:4068`). Live check had 1 OVER (staging reads, Nov 20) that ages out of the 7-day window about Nov 27; the Nov 22 gate check result is unknown, check. | Security and billing lead r2 | No |
| S3 | Spend caps and cutoffs are sized for public traffic so launch day cannot cut the app off for everyone. | **Unscheduled.** Today: Cloud Run spend cap $5 a month per project, prod budget cutoff $15 (Aedwon raises as users grow), reCAPTCHA 300 a day, Worker script limit 100,000 requests a day for sign-in paths (`docs/deploy-prod.md:286,297-300,392`). Prod usage alarms now cut billing (`LL:4058`). No plan to re-size at launch is on main: unknown, check. | Security and billing lead r2 | Raising a budget or cap is **HIS** (billing) |
| S4 | Email capacity covers launch. Sign-in code mail is capped at 20 a day for non-beta addresses; Resend Free allows 100 a day shared with guardian mail and the website (`docs/deploy-prod.md:191-199`). Held-back sends look normal to the user but no mail goes out. | **Open.** Cap is raised "only after moving Resend off Free". Google sign-in is unaffected. | Security and billing lead r2 | Moving Resend to a paid plan is **HIS** (billing) |
| S5 | Cloudflare sign-in rate limit is in place. | Ruled DO NOW: test existing access first (`BL:40`, A1). Result: unknown, check. | Security and billing lead r2 | Console click only if access tests fail |
| S6 | The old Firebase address no longer serves the full app. | Tiny page waits on 48 clean hours plus one real Google sign-in in prod logs (`docs/deploy-prod.md:390`; `BL:41`, A2). Result: unknown, check. Firebase Hosting bills every byte (rule 7). | Integrator | Phone step only if logs show none |
| S7 | Security audit findings are closed or accepted. | Internal audit Nov 14 merged with independent validation (`LL:3212-3227`); secrets down to 4 active versions, old ones destroyed Nov 18 (`LL:4005`); main protected (`LL:3916`). The remaining pass is M4. | Security and billing lead r2 | No |
| S8 | External penetration test. | None on record; the May plan boxes are unchecked and stale (`docs/OPERATIONS.md:253-259`). Whether launch needs one: unknown, check. | Aedwon decides | **HIS** |
| S9 | DMARC moves from report-only to quarantine. | Report-only; trigger Nov 28 and every report aligned (`BL:98`, D16). Helps sign-in mail delivery. | Security and billing lead r2 | No |
| S10 | Rule 7 holds after launch: only real users cost money. | Prod billing cutoff and alarms live; weekly live check; monthly cost check Dec 1 02:00 UTC (`BL:138`). | Operations manager | No |

## 6. Operations

| # | Gate | State and evidence | Owner | HIS? |
|---|---|---|---|---|
| O1 | Post-launch monitoring has a named owner and cadence (errors, 401 spikes, payment webhook failures, cutoff alarms, user counts). | The manager's daily sweep (01:00 Manila) and the 12-hour beta monitor exist (`docs/workflow/operations-manager.md`); the monitor is beta-specific. No public-launch monitoring plan is on main: unknown, check. | Operations manager | No |
| O2 | A support inbox has an owner and a reply promise. In-app feedback has a home after the beta. | Settings "Feedback (Beta)" stores reports in prod Firestore; he reads them in the console, no admin screen (`docs/OPERATIONS.md:84-90`). The Facebook group was the non-beta channel from Aug 11; whether it is still intended: unknown, check. | Aedwon | **HIS** (his inbox and group) |
| O3 | Rollback is ready for the opening ship. | Per-ship rollbacks are logged (latest web `1275724943`, previous Hosting `6f90dad0745de33e`; functions revisions saved in `Pantas-private/releases/`; `LL:4055`). Re-gating means redeploying a build with the gate on, or detaching the Worker domain (about a minute, `docs/deploy-prod.md:386-389`). A rehearsal of the gate-off build's rollback: unknown, check. | Integrator | Ship is **HIS** |
| O4 | A staging proof of the gate-off build covers: new visitor, sign-up, onboarding, Free CSE study, mock, paywall, test-mode purchase and refund. | Browser journeys run in CI (`LL:3703`); whether any journey runs without the gate: unknown, check. | Integrator | No |
| O5 | Beta wrap-up is finished: reward list, Pro end, survey. | Credited days close Nov 22; reward list due Nov 22 (5 days plus a sent survey); beta Pro ends Nov 23 00:00 Manila; survey closes Nov 24 00:00; appeal window to Nov 30; activation deadline 31 Dec 2027 (`BL:134-143`). As of the Nov 18 digest, at most 1 tester could still reach 5 days. | Beta monitor | Every email goes to him first (rule 6) |
| O6 | Every email to users follows rules 6 and 8, including any launch announcement. | Standing rules. Resend capacity limit applies (S4). | Operations manager | **HIS** (he checks the self-test) |
| O7 | The Nov 21 handoff's open decisions are cleared. | Under-13 notice wording and PSHS-NCE partials are not CSE gates. The prod Firestore App Check question is answered (S1). Disk is housekeeping. | Operations manager | Disk cleanup needs his word |

## 7. Turning off the beta gate

The gate is client code with no end date. It is on for any web build made with `BETA_GATE=true`
and every prod build so far uses it (`lib/app/beta_gate.dart:14-22,36-39`; `LL:3703`, `LL:4052`).

| # | Gate | State and evidence | Owner | HIS? |
|---|---|---|---|---|
| G1 | All items above that this file marks required are met, and he names the opening day and hour. | No opening date is recorded on main: unknown, check. | Aedwon | **HIS** |
| G2 | Order: live payments (M1 to M4) first, then public Terms (L1), then the gate-off build. Opening with test keys would let the public "buy" nothing. | Path steps 3 to 5 (`LL:2786-2790`; `BL:111`, E4 merged into A7). | Operations manager | **HIS** |
| G3 | A prod build made without `BETA_GATE=true` is proven on staging, then shipped. | Not built. The integrator ships, with rollback ready and a 30-minute watch. | Integrator | Prod "ship it" is **HIS** |
| G4 | Beta-only surfaces are removed or reworded for the public: the beta sign-in page, Home beta notice, Settings "Feedback (Beta)", guide page, and the beta Pro switch in functions env. | The Home notice ends Nov 24 00:00 Manila (`LL:3727`); `BETA_PRO_UNTIL` and `BETA_CUTOFF` are Nov 23 00:00 (`LL:3693-3702`); the deploy guide says to remove the switch after the beta (`docs/deploy-prod.md:41-43`). Other surfaces: unknown, check. | Integrator, DS4 lane | No |
| G5 | Installed copies still carrying the gate update. | Open apps take the new build at their next safe point; a copy that stays offline keeps its own gate (`LL:3710`). Not a blocker; expect stragglers. | Integrator | No |
| G6 | First-hour watch after opening: sign-up, onboarding, quiz save, mock, one live checkout, alarm emails, 401 rate. | Pattern exists in every ship entry (for example `LL:4056`). | Integrator, then manager | Live checkout is **HIS** (real money) |
| G7 | Rule 9 applies from the moment of opening. | See L6. | Operations manager | **HIS** |

## Not gates for CSE (so nobody widens scope)

Question generator (gates PSHS-NCE and academy exams only, `docs/pricing.md`), PSHS-NCE content
and its partials, under-13 build, CET opening, founder app boards (except M7 if launch needs
it), Wrapped and desktop layout (`BL:94`), flashcards, native store releases (`BL:108`),
redemption codes, scroll work (stopped), renewals through PayMongo Subscriptions (deferred after
launch, `LL:3988`).

## Counts

| Group | Items | HIS alone (fully or in part) |
|---|---|---|
| 1 Product quality | 10 | P1 ship step; P4 phone step if logs show none |
| 2 Content | 6 | C5 opening other exams |
| 3 Payments | 10 | M1, M2, M3, M6, M8; M7 boards; M10 sign-off |
| 4 Legal and privacy | 9 | L1 sign-off, L2, L3, L4, L5, L9 assessment |
| 5 Security and cost | 10 | S3 and S4 billing; S8 decision; S5 and S6 only on failure |
| 6 Operations | 7 | O2, O3 ship, O6 |
| 7 Beta gate off | 7 | G1, G2, G3 ship, G6 live checkout, G7 |
| **Total** | **59** | |

## What Aedwon alone must do, in one list

1. Prod "ship it" for each release: P1 fix, the opening build, any security pass.
2. Live payments: BIR COR and DTI name, PayMongo methods and live keys, one real payment, bank refunds.
3. Legal sign-off on the public package, and his facts for the footer and Terms.
4. NPC registration and monitored dpo, contact and support mailboxes.
5. Billing: raise budget or caps if needed, move Resend off Free.
6. Decide: whether an external pentest is required, the opening date, and the support channel after the beta.
7. A phone check only if the prod logs show no real quiz finish, Google sign-in, or feedback send.

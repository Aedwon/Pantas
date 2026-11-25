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
| P1 | Every answer saves. No question id can block a save. | **Fixed on main, not on prod.** Two causes: the analytics check on ids over 64 characters (PR #82, merged fc6dc7063) and the passage-order save failure in Retake, Today, the in-lesson quiz, Drill and Restart (PR #83, merged 47ac60058). Checks `analytics-never-blocks`, `question-id-limits`, `session-stored-order`. Prod web build 2026318751-32e9b98f07ec from 47ac60058 is ready; waits for his "ship it" (`docs/superpowers/plans/2026-11-22-cse-release-qa-phase1-report.md`). | CSE QA lead (per the request). Fix lane: security and billing lead r2 | Prod "ship it" is HIS |
| P2 | A student's "report a question" reaches someone who can read it, or the control is removed or reworded. | **Open, decision for him.** Confirmed: reports are kept on the device only; no endpoint exists. Options: build a protected endpoint plus the bar morph (about 1 day, about 2 writes per report), or hide the control (about 1 hour). Lead recommends building it (`docs/superpowers/plans/2026-11-22-cse-release-qa-phase1-report.md`, Part A decision 1). | Unassigned | No |
| P3 | CSE UI passes the QA lead's review (Free and Pro, phone and desktop web). | **Not passed** (Nov 22). 125 findings after removing duplicates: 1 conditional blocker (beta gate), 1 split blocker or major, 42 major, 5 major or minor, 76 minor. List: `docs/superpowers/verification/2026-11-22-cse-qa/consolidated.md`; fix plan in `docs/superpowers/plans/2026-11-22-cse-release-qa-phase1-report.md`. Scope chosen Nov 23: hardened ("go hardened. i do not want any risks when I release this app."); every finding is in the Phase 2 plan. | CSE QA lead | No |
| P4 | Prod real-device proof: a stuck Reviews session resumes, a quiz finishes, feedback with a screenshot sends. | **Unproven.** `BL:51` (A18) says the beta monitor reads prod counts; no closure is logged. The Nov 22 save failure on his own phone shows quiz finish was not clean for long ids. Unknown, check after P1. | Beta monitor, then CSE QA lead | Physical phone step only if logs show none (`BL:36,51`) |
| P5 | No open tester issue rated medium or higher. | Digest (`Pantas-private/beta/digest.md`, last pass 23 on Nov 18 14:47 PHT, 4 days old): **5 distinct medium issues, 0 high or critical, 0 confirmed closed by a fresh tester session.** Titles: "Study owner changed" error on Home; "Reviews batch is unavailable"; stale sign-in on reopen; old build served after a deploy; birth-year wheel one year per swipe. Each has a shipped fix (`LL:3727`, `LL:3420`, age stepper in DS4), none re-observed. Two low-to-medium notes remain (Home read bursts, exam date picker). Only 2 feedback documents exist in total. Passes after Nov 18: unknown, check. | Beta monitor | No |
| P6 | A student who turns 18 stops being marked a minor. | **Not started.** Ruled "first release after Nov 22, before public launch" (`BL:124`, E17). | Unassigned (integrator route) | No |
| P7 | A fresh device first sync no longer makes one call per read lesson. | **Built, merged (PR #138, 3eb958f5b); function on staging.** Prod functions with #109 (security lead, after the integrator go); web with the opening. Batch path proven in P12. | Unassigned | No |
| P8 | Phone reader bar keyboard Tab stop, hover and focus defect is fixed. | **Closed.** 48812779c is on main; tests cover Tab order, focus ring, Enter, Space and hover (`docs/superpowers/verification/2026-11-22-cse-qa/ui-1-findings.md`, P8). | DS4 completion lane (idle) | No |
| P9 | Load time on phones stays under 10 seconds. | Latest reading 5.7 s; reopen only above 10 s (`BL:120`, E13). No post-beta reading: unknown, check. | Beta monitor | No |
| P10 | Every number shown on CSE screens is measured, published or from a named algorithm. | **Built, merged (PR #137, ae437d8bb); mock content on staging.** Prod with the opening web ship and content upload. U59 note citation open (No. 19 vs No. 10). | CSE QA lead | No |
| P11 | Content gate: every shipped question, quiz, mock and lesson part passes the app's real logic with no UI (loads, renders its parts, one gradable key, right grade for a right and a wrong choice, valid save, progress and analytics records, results, review and resume), as a permanent CI check. | **Met (main).** The content gate (`test/content_gate`, PR #87, main 8c3b5ed65) runs in CI on every push touching content, lib or tools: every served question set (Free and Pro copies), lesson part and mock blueprint through the upload packaging and the real app code. Prod tree d97de9415: 0 failures, 4,326 questions, 1,271 lesson parts. Main: 0 failures; 2 accepted stale lessons and 2 accepted ACET mock sections. | CSE release lead | No |
| P12 | Every loop verified: one browser run per distinct loop for each open exam (CSE Pro, CSE Sub) and mode: study, quiz, mock (timed, submit, results, review), resume after reload, report, offline, sync. Reads counted first (rule 7). | **Open.** Added Nov 23 with P11. Task T13 of the Phase 2 plan. | CSE release lead | No |

## 2. Content

| # | Gate | State and evidence | Owner | HIS? |
|---|---|---|---|---|
| C1 | CSE Professional and Subprofessional content is live and fills every mock slot. | **Met on prod, Nov 21 (Manila).** Prod serves `content/cet-bite-r1` d97de9415 plus three main files; CSE Pro mock fills 155, CSE Sub 145; exam summaries hold 1,751 and 1,523 questions (`LL:4044-4056`, `LL:4092-4100`). | Integrator | No |
| C2 | CSE content is bite-sized and approved. | **Met per handoff.** All CSE lessons split and live (`BL:64`, B7; handoff line 46). Content edits stay behind the approval gate. | Content lanes | No |
| C3 | The content audit sweep runs clean on the content prod serves. | **Open in tooling only.** `tools/audit/run_all.py` stops at sweep 3 on prod content (618 illustration-strategy errors, up from 182) and skips sweeps 4 to 11; it crashes with an IndexError on main. 0 broken visuals reach a CSE student: all 52 CSE-active illustration markers embed a valid SVG and all 6 figure markers use registered painters (`docs/superpowers/verification/2026-11-22-cse-qa/content-findings.md`, C3-1 and C3-2). Ruling still needed on whether the tool must pass before launch. | Unassigned | Ruling is a call for the manager or him |
| C4 | No unapproved question is served to the public. | **Met.** The content gate (`tool/content/content_gate.dart`) finds 0 findings on prod's content tree d97de9415; `question-ledger/approved.json` covers all 4,427 prod questions, including all CSE-tagged ones. Rerun by the lead Nov 22. | Content lanes | No |
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
| M4 | One security pass before live keys: narrower function permissions, security headers, Pro sync quotas. S-12 checkout fix already shipped. | S-12 shipped to prod Nov 19 (`LL:3996-4003`). **Not started**, plan and estimate below ("Security pass before live keys (M4)"). No full money-path audit is on record: only the S-12 change had a Codex review (E-119). Today the app sends only HSTS of the usual security headers. | Security and billing lead r2 | No |
| M4b | Pro sync cannot be used to cut billing for everyone: per-account sync write quotas (rows and bytes a day, a counter checked in rules) and a server-owned entitlement version, so a refund ends sync at once. | **Not started.** Added Nov 22 by the manager ("A and B. One paid account cutting billing for the whole app is a public-launch risk"). Today one Pro account writing 100,000 rows in an hour trips the prod writes alarm, which cuts billing for the whole app; a refund keeps sync for up to an hour (private audit S-15). About 3 days; needs app code and the Flutter slot. Part A (typed and sized sync fields, rules only) is being built first under M4. | Security and billing lead r2 | No |
| M5 | Plan copy says "prepaid period", not "renews". | **Met for web Terms and paywall** (`LL:4012`). Pro page wording: unknown, check (`BL:52`, A19). | Integrator | No |
| M6 | A refund path works at live: QR Ph by bank transfer plus the signed refund command. | Runbook exists and passed on staging in test mode (`docs/OPERATIONS.md`, "Manual QR Ph refund"). Live mode is untested. PayMongo's reply on QR Ph refunds: **Sent** Nov 19, no reply (tracker row 6). | Aedwon runs refunds; security lead owns runbook | **HIS** (bank transfers) |
| M7 | A way to find a payer, refund and grant by hand exists at live. | Founder app holds this (`BL:92`, D10 merged into A5); spec **not approved**, no build (`BL:31`). The manual refund command covers refunds only. Whether launch can run without it: unknown, check. | Founder app lead | Board approvals HIS |
| M8 | Registered invoices or receipts can be issued. | Not started; waits on BIR registration (`LL:2841`; `BL:28`, A6). | Aedwon | **HIS** |
| M9 | CSE products and web prices match `docs/pricing.md`: Weekly ₱49, Monthly ₱149, Yearly ₱1,199, pass ₱499. | **Met in code**: `functions/src/products.json` carries `pantas_cs_weekly/monthly/yearly` and both CSE passes at those prices. The 7-day trial is on Monthly only. **Pass expiry: met** (lead, Nov 22): a pass binds to the next published sitting at purchase (`sittingFor`, `revenuecatPasses.ts:28`; used by `paymongoGrants.ts:18`, `paymongoCheckout.ts:67`); the catalog the deployed functions carry (`lib/examCatalog.json`, from `content/exams/catalog.json`, prod functions deployed Nov 22 from main 20e8065a3) lists CSE Pro and Sub sittings 2027-03-14 and 2027-08-08 with the CSC source, so a pass bought on or before Mar 14, 2027 ends Mar 14, 2027 23:59:59 Manila. | Security and billing lead r2 | No |
| M10 | Payment record retention matches the published text. | **Open.** The Nov 9 note says account deletion can erase payment source records before the published five-year period; no protected archive is built (`docs/legal/2026-11-09-publication-dependencies.md`). The interim text was reworded to say deletion removes Pantas's payment records (`LL:2853`). What the live text says versus the system: unknown, check. | Under-13 and legal lanes, manager | Sign-off HIS |

## 4. Legal and privacy

| # | Gate | State and evidence | Owner | HIS? |
|---|---|---|---|---|
| L1 | Public Terms, Privacy Policy and Teen Notice are published, match what the app does, and carry live-payments and refund text. | In-app texts are live on prod from the Nov 10 interim set and the Nov 12 teen notice approval (`LL:3138-3143`, `LL:3189`). The payments and refunds Terms is still a draft with brackets for operator name, DTI number and address (`docs/legal-drafts/2026-10-30-terms-payments-refunds-draft.md:3`). Public pages on pantas.study: unknown, check. **Legal sign-off approved Nov 24** (Aedwon, relayed by the manager: "legal sign-off: approved"). The texts still publish per H5: with or after the D1, D2, D3 and D7 builds, each claim checked live on prod, with the date and version stamps moved to the go-live day if it is after Nov 24. | Legal lane; agent drafts under rule 5, Codex Sol High critiques | **Sign-off HIS** |
| L2 | Public-launch legal package, including the teen notice "Age check" basis (NPC Opinion 2017-049). | **Signed off Nov 24** (Aedwon: "legal sign-off: approved"). Publishing waits on H5 (see L1). | Unassigned (manager launches a lane) | Signed off
| L3 | Operator facts exist for the footer and Terms: business phone, name, DTI number, BIR details. | **Met Nov 24.** All facts are supplied and held privately as build inputs, not in this repo: phone (Nov 18, founder app), registered name (display form "Pantas Online Tutorial Services", as in the legal texts), place of business, DTI and BIR details. The seller line takes them through `--dart-define` (`lib/core/config/seller_facts.dart`); a public prod build refuses to start while one is missing | Aedwon | **HIS** (facts about him) |
| L4 | NPC registration filed and confirmed. | Unconfirmed: box unchecked (`docs/OPERATIONS.md:246`, last updated 7 May), and listed as waiting on him (`BL:28`). Whether it is required before opening: unknown, check. | Aedwon | **HIS** |
| L5 | dpo@, contact@ and support@ mailboxes are monitored. | support@ proven Nov 18 (sign-in code sent and verified). dpo@ and contact@: unconfirmed (`BL:158`, `BL:28`). | Aedwon | **HIS** (his mailboxes) |
| L6 | Rule 9 is ready: from the moment of opening, any change to what is collected goes out by email first (guardian too for under 18). | Rule is written (`process-improvement.md:110`). The build lead flags such a change; the manager holds the prod "ship it". Gate: nothing collection-changing is queued after opening without its email. Mail capacity limit applies (see S4). | Operations manager | Every email goes to him first (rule 6) |
| L7 | Legal version stamps equal the publish date, and a Terms version bump prompt is acceptable. | Stamps read 2026-11-12 on main; confirm that is the day the documents went live (`BL:71`, C2). Replacing the interim Terms with final Terms will ask existing students to accept again (his Nov 11 "okay proceed", `LL:3122`). | Integrator | No |
| L8 | Lawyer review. | **Not a gate by his decision**: "no way, no money" (Nov 9, `LL:2755`). Recorded so no agent asks again. | None | Decided |
| L9 | Under-13 stays closed. CSE is 13+. | Draft PR #76 is in progress and must not deploy. The signed child privacy assessment is needed only before child accounts open (`BL:34`). | Under-13 build lead | Assessment HIS |
| L10 | The BIR Registration Seal Badge (with its QR) is shown prominently on the website and the Pro page, visible and scannable (BIR Form 2303 page 3, Aedwon's certificate, Oct 29, 2026: "the BIR Registration Seal Badge should be prominently displayed on their website or profile page ... easily visible to the public and readily scannable"). | **Website only (Nov 24).** Aedwon: "yes show the BIR badge but only on the landing page pantas-web project in domain www.pantas.study". Not in the app: C9's Pro page and wide-row placements are dropped; the website placement under the D3 seller details stands. BIR RMC 113-2026 (Oct 26, 2026) suspended the mandatory display, so this is voluntary and not a gate. Publishing the website needs his "ship it". | CSE release lead | Decided (website only)

## 5. Security and cost

| # | Gate | State and evidence | Owner | HIS? |
|---|---|---|---|---|
| S1 | Prod Firestore App Check stays enforced with no real client refused. | **Met** (watch ended Nov 22 12:40 UTC): over 24 hours prod Firestore App Check allowed 144 real-app requests and refused only the lead's 2 tokenless probes; Auth allowed 4, refused 0; no App Check or permission errors (`LL`, "Nov 22, prod Firestore App Check watch ended clean"). Storage, Auth and Firestore are all enforced. | Security and billing lead r2 | No |
| S2 | The CI free-tier gate passes at and after Nov 24 00:00 Manila. | **Pass** (lead, Nov 22 about 00:45 UTC, main 20e8065a3): `free_tier.mjs` passes now and in an `evaluate()` simulation at Nov 24 00:01 Manila and Dec 1. `free_tier_live.mjs`: 9 OK, 3 WARN (as ruled), 1 OVER = staging reads on Nov 20 (126,854), outside the CI gate, ages out about Nov 27. Warm-up stops in code at Nov 23 16:00 UTC; the lead's scheduled check re-runs both at Nov 23 14:00 UTC. | Security and billing lead r2 | No |
| S3 | Spend caps and cutoffs are sized for public traffic so launch day cannot cut the app off for everyone. | **Met for 500 sign-ups (Nov 25, E-166, his "yes"):** prod reCAPTCHA cap 1,000 a day, App Check token 6 hours, prod cutoff $30, account budget email $40, Cloud Run caps $5 kept. Raise again before 5,000 sign-ups (table below). Was: **Open, proposal below** ("Launch sizing proposal (S3, S4)"). Measured Nov 22: prod reCAPTCHA cap is **280 a day** (not 300), App Check token lifetime 1 hour, and the beta made 3 to 21 assessments a day. At launch that cap is the first thing that breaks: past it, new App Check tokens fail and enforced sign-in and Firestore refuse everyone. Spend cap $5 a month (Cloud Run) and the $15 cutoff also bind at 5,000 sign-ups. | Security and billing lead r2 | Raising a budget or cap is **HIS** (billing) |
| S4 | Email capacity covers launch. **Nov 25 (E-166, his "yes"): stays on Resend Free; prod sign-in caps open 60 and reserved 30 (guardian mail closed by option C); alert "Sign-in mail above 80 a day" emails the owner. About 150 code mails on a 500 sign-up peak day still pass 100: moving to Resend Pro is his call when the alert fires.** Sign-in code mail is capped at 20 a day for non-beta addresses; Resend Free allows 100 a day shared with guardian mail and the website (`docs/deploy-prod.md:191-199`). Held-back sends look normal to the user but no mail goes out. | **Open, proposal below.** Even 500 sign-ups in week one need about 150 code mails on the peak day: over the 20-a-day send cap and over Resend Free's 100 a day. Resend Pro is $20 a month for 50,000 mails with no daily limit (resend.com/pricing, read Nov 22). | Security and billing lead r2 | Moving Resend to a paid plan is **HIS** (billing) |
| S5 | Cloudflare sign-in rate limit is in place. | **Met** (lead, Nov 22, read-only): Cloudflare rate-limit rule on pantas.study (Free plan), enabled: `http.host eq "app.pantas.study" and starts_with(path, "/__/")`, block above 30 requests per 10 s per IP and data center, for 10 s ("security fixes step 5, Nov 17"). Access: the Cloudflare connector reads rulesets; the stored DNS token (`~/.config/pantas/cloudflare.env`) is valid but lacks ruleset read. Limit: the sign-in code callables run on cloudfunctions.net, not behind Cloudflare; they keep their own per-account and daily caps. | Security and billing lead r2 | Console click only if access tests fail |
| S6 | The old Firebase address no longer serves the full app. | **Met** (Nov 25, CSE release lead r7, PR #132, launch log "the old Firebase addresses retired"): his Google sign-in through app.pantas.study succeeded at 13:10 UTC; since 13:29 UTC both old addresses serve a 472 B page that sends visitors to app.pantas.study, and the /__/ sign-in paths still work. | Integrator | Phone step only if logs show none |
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
| G4 | Beta-only surfaces are removed or reworded for the public: the beta sign-in page, Home beta notice, Settings "Feedback (Beta)", guide page, and the beta Pro switch in functions env. | **Listed, not done.** 19 beta-only surfaces with file, line, text and a remove or reword verdict (`docs/superpowers/verification/2026-11-22-cse-qa/ui-2-findings.md`, G4; consolidated U53 to U57). Also found: the "BETA" mark on `web/og-image.png` and its alt text, and the prod sign-in code cap of 20 a day for people not on the beta list (S25). | Integrator, DS4 lane | No |
| G5 | Installed copies still carrying the gate update. | Open apps take the new build at their next safe point; a copy that stays offline keeps its own gate (`LL:3710`). Not a blocker; expect stragglers. | Integrator | No |
| G6 | First-hour watch after opening: sign-up, onboarding, quiz save, mock, one live checkout, alarm emails, 401 rate. | Pattern exists in every ship entry (for example `LL:4056`). | Integrator, then manager | Live checkout is **HIS** (real money) |
| G7 | Rule 9 applies from the moment of opening. | See L6. | Operations manager | **HIS** |
| G8 | No exam whose takers are under 18 opens before guardian-first sign-up for 13 to 17 is on prod (option C, rulings file "If he chooses C" item 7). | Under-18 sign-up closed on prod Nov 25 (launch log, E-164): minimum age 18, server switch `GUARDIAN_REQUESTS_OPEN` false. Reopening adds collection, so rule 9 is checked before that release. | Integrator, under-13 lead | Opening another exam is **HIS** |

## Launch sizing proposal (S3, S4)

Security and billing lead, Nov 22, read-only. **Raising any cap, budget or plan is Aedwon's call.** Nothing
was changed.

Assumptions (estimates, not measurements): the peak day has 40% of week-one sign-ups active, month one
averages 30% of sign-ups active a day; half of new users sign in with an email code (1.5 mails on sign-up
day, about 1 a week after); per active user a day, about 430 Firestore reads and 80 writes (modeled from
the measured per-call costs, docs/deploy-prod.md "Count before every hosted run", with exam summaries live),
about 30 callable requests, and 3 reCAPTCHA assessments at today's 1-hour App Check token (beta measured
3 to 21 a day in total).

| Item | Today | 500 sign-ups (peak 200 active, average 150) | 5,000 sign-ups (peak 2,000, average 1,500) |
|---|---|---|---|
| reCAPTCHA assessments a day (cap) | cap 280; beta 3 to 21 | peak about 600: **over the cap** | peak about 6,000: **over the cap** |
| App Check token lifetime | 1 hour | raise to 6 hours: peak about 300, month about 6,750 (free up to 10,000) | 6 hours: peak about 3,000, month about 67,500 |
| Proposed reCAPTCHA cap | 280 | 1,000 a day | 5,000 a day |
| reCAPTCHA cost a month | $0 | $0 with the 6-hour token ($8 flat without it) | $8 flat (10,001 to 100,000; about $43 with the 1-hour token) |
| Sign-in code mails, peak day | cap 20 (plus 40 beta), Resend Free 100 a day | about 150 | about 1,500 |
| Proposed mail | | Resend Pro, send cap 500 a day | Resend Pro, send cap 3,000 a day |
| Mail cost a month | $0 | $20 (about 1,400 mails) | $20 (about 14,000 mails, under 50,000) |
| Firestore a day | free 50,000 reads, 20,000 writes | peak 86,000 reads, 16,000 writes; under a dollar a month | peak 860,000 reads, 160,000 writes; about $15 to $20 a month (price per 100,000 not verified for asia-southeast1) |
| Firestore cutoff alarms | 500,000 reads or 100,000 writes an hour; 2M reads or 400,000 writes a day | no change | no change (peak day uses about 43% of the daily read alarm) |
| Cloud Run spend cap | $5 a month a project | keep $5 (about 135,000 requests, inside the free 2M) | raise to $30: about 1.35M requests and roughly 400,000 vCPU-seconds against 180,000 free, about $5 a month, which would pause every function at $5 |
| Prod billing cutoff | $15 a month | raise to $30 (expected Google cost under $10) | raise to $75 (expected about $30: Firestore, Cloud Run, reCAPTCHA) |
| Worker (sign-in paths only) | Free, 100,000 requests a day | no change | no change (about 20,000 on the peak day); Workers Paid is $5 a month if ever needed |
| Budget email | $20 a month account budget | raise to $40 | raise to $100 |

Expected added cost a month: **about $20** for 500 sign-ups (Resend Pro; Google stays near $0 to $10), and
**about $50 to $60** for 5,000 (Resend $20, Google about $30 to $40). Changes with no cost of their own: the
token lifetime (a config change; a stolen token then lives 6 hours instead of 1), the reCAPTCHA and mail caps,
and the cutoff amounts. Sources read Nov 22: resend.com/pricing, Cloudflare Workers pricing, Firebase pricing,
Google Cloud free tier (Cloud Run), reCAPTCHA tier comparison. Before launch, re-measure reads and
assessments per active user from the first real day and adjust.

Also found: a held-back code mail looks normal to the user (no mail arrives, no error). At launch that is the
worst failure mode; the app should say so. App change, not costed here.

## Security pass before live keys (M4)

Plan, security and billing lead, Nov 22. Trigger: before live PayMongo keys (M1 to M3). Prod needs his
"ship it". Each part logs its own velocity row and follows rule 7 for any staging run.

1. **Money-path audit (Codex GPT 6.2 Sol High, read-only, two runs):** PayMongo checkout, webhook, grants and
   refunds (`paymongo*.ts`, `grants.ts`, about 930 lines); RevenueCat, passes and web entitlement
   (`revenuecat*.ts`, `webPlans.ts`, `webEntitlement.ts`, `entitlementInputs.ts`, about 970 lines). Findings
   appended as found; the lead verifies each; fixes test first. About 1 h 30 min of Codex and 1 h of lead
   review, plus fixes as found.
2. **Narrower function permissions:** replace the default compute account on the 60 services with about five
   service accounts by need (content read, user data, payments, sign-in token minting, scheduled jobs), each
   with only its roles; preflight extended to check them. About 3 h plus a staging proof. No cost.
3. **Security headers on the Worker:** today only HSTS. Add `X-Content-Type-Options`, `Referrer-Policy`,
   `Permissions-Policy`, `frame-ancestors 'none'`, and a Content-Security-Policy in report-only mode for one week
   before enforcing (Flutter web, reCAPTCHA and Firebase need explicit sources). About 2 h, then the week.
4. **Pro sync quotas:** per-account caps on sync writes and document sizes in rules and the sync callables, so
   one account cannot write without limit. About 3 h.

Estimate: about 1.5 working days of lead and worker time, plus one week of report-only CSP before the
enforcing ship. Needs one Codex slot for part 1.

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

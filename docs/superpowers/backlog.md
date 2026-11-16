# Open backlog: everything open, parked or deferred

Built November 17, 2026 from `origin/main` at 7ada447c4. Request: Aedwon, "what about the question generation engine? why wasn't that surfaced. i'm worried we're missing items".

Format per line: item | status | source file:line | last mentioned | owner.
`LL` = `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md`. `PB` = `docs/superpowers/decisions/2026-11-03-post-beta-priorities-log.md`. `MH` = `docs/superpowers/plans/2026-11-15-manager-handoff.md`.

## Why the question generator was not surfaced

It is recorded in four places and in none of the lists a manager reads.

- It is not in `docs/future/README.md` (the index OPERATIONS.md tells managers to read for "pending things"). Its Oct 25 idea sits only in the "After launch" list of `docs/superpowers/plans/2026-10-19-pwa-launch.md:372`.
- The Nov 3 option 1 is in the post-beta log (`PB:17`), but its build choice was set for "after November 15 using beta data" (`PB:23`). No later queue, handoff or follow-up list carries it. The Nov 9 queue (`LL:2790`) and the Nov 15 handoff (`MH:73-78`) omit it.
- It is a release gate: PSHS-NCE, PMA, PNPA, PMMA and MAAP cannot go on sale until it ships (`docs/pricing.md:28,31,44`; `2026-10-04-tiered-pricing-log.md:52-55`).
- Fix applied here: it is item D1 below. Recommend also adding it to `docs/future/README.md` and the handoff.

---

## A. Waiting on Aedwon (a decision, an approval or a physical step)

1. Cloudflare token permission "Zone WAF: Edit" so the security lead can add the sign-in rate limit | waiting | `LL:3594`; `MH:70` | Nov 14 | Aedwon
2. One real Google sign-in on his phone; unblocks retiring the old Firebase page (48 h clean from Nov 16 18:40 UTC plus one real sign-in) | waiting | `LL:3593`; `MH:70` | Nov 16 | Aedwon
3. Phone check of the pixel-ratio cap before any prod ship; otherwise do not ship it. The scroll work itself was stopped by him | waiting, work stopped | `LL:3878`, `LL:3909` | Nov 16 | Aedwon
4. Legal sign-off: usage-tracking step 2 notice wording and the under-18 guardian question (branch `web/usage-counts-r1`) | waiting | `MH:67`; `OPERATIONS.md:231-243` | Nov 15 | Aedwon
5. Founder app spec (branch `docs/founder-app-spec`, 20 boards) not approved; no build started. Open: Posts spec, Growth question list, source tracking scope | waiting | `docs/superpowers/decisions/2026-11-02-founder-app-log.md:429,454`; `plans/2026-11-10-manager-handoff.md:46-48` | Nov 10 | Aedwon and founder app lead
6. Founder app owner inputs: business phone, website footer facts, BIR registration and invoicing, NPC registration, signed child privacy assessment, monitored dpo inbox | waiting | `LL:2756` | Nov 9 | Aedwon
7. PayMongo live activation: BIR COR, DTI name, upgrade from Individual to Sole Proprietor, ask PayMongo support about QR Ph refunds | waiting | `LL:2841`, `LL:2839` | Nov 9 | Aedwon
8. Minor label before guardian consent: choose option D (consent before age check plus checkout declaration, 1 to 2 days) before live payments | waiting | `LL:3134,3136` | Nov 11 | Aedwon
9. Secrets merge: his "ship it" for prod, then approval to destroy the old secrets 48 h after (before Nov 24) | waiting (future) | `LL:3908,3902` | Nov 17 | Aedwon
10. Optional: BigQuery billing export (console only); staging Resend key (issue #74) | waiting, no deadline | `LL:3761`, `LL:3450`; `MH:71` | Nov 15 | Aedwon and manager
11. CET content finish: resume after items ahead of it; steps at the end of `docs/content/rewrite/cet/final-run-report.md` on `content/cet-finish-r1` (Astra on 61 lessons, about 150 of 194 figures, review package) | paused by him, last in queue | `PB:152-164`; `MH:24` | Nov 10 | Aedwon
12. Beta reminder email: no record on main of a planned reminder to testers (only the extension email, sent Nov 15). Needs his word on whether one is wanted | waiting, unconfirmed | `LL:3763`; `process-improvement.md:140-147` | Nov 15 | Aedwon
13. Disk cleanup: only the Oct 30 cleanup is on main. No current disk task is recorded, so the item is unconfirmed | unconfirmed | `LL:2095` | Oct 30 | Aedwon
14. Verification and learning build (hardened scope chosen): resume on or after Nov 16 and approve the spec policy change (scripted pass or fail only; screenshots only on failure) | waiting, due now | `2026-11-04-verification-and-learning-log.md:73-93` | Nov 4 | Aedwon
15. Published main history carries 5 commits with a `Co-Authored-By` trailer; rewriting needs his explicit authorization | waiting | `2026-09-30-adaptive-roadmap-log.md:439-442` | Oct 1 | Aedwon
16. CSE figure style choice (four samples) and use of three Plus accounts for Codex | waiting (may be old) | `2026-10-25-cse-rewrite-p0-notes.md:29-31` | Oct 25 | Aedwon
17. Subprofessional CSE mock counts are an even-split placeholder until a taker recalls the real counts | waiting | `LL:1056,1110` | Oct 19 | Aedwon
18. Prod real-device proof: stuck Reviews session, finish a quiz, send feedback with a screenshot (headless cannot pass prod App Check) | waiting | `LL:3196` | Nov 14 | Aedwon or a tester
19. Monthly-trial change: Terms, Pro page, paywall trial routing and the Play offer need separate approval | waiting (may be old) | `2026-10-04-tiered-pricing-log.md:77-83` | Oct 4 | Aedwon
20. Google sign-in and eye checks on his iPhone home-screen app (splash, Study gap, Backup row) | waiting | `LL:2673,2678,2713` | Nov 8 | Aedwon

## B. Approved and in progress

1. Secrets release `web/secrets-merge-r1` (d463cf39a): two secrets per project (payment and app). Staging proof Nov 18 to 19, handoff Nov 20 | in progress | `LL:3908,3902` | Nov 17 | security fixes lead and integrator
2. CI free-tier check branch `web/free-tier-check-r1` (7c20b2871) green, handed to the integrator to merge | in progress | `LL:3865` | Nov 16 | integrator
3. Prod App Check staged rollout: Auth enforced Nov 16, watch ended Nov 17 06:30 UTC | in progress | `LL:3888` | Nov 16 | security fixes lead
4. Staging Firestore budget (40,000 reads, 16,000 writes per day) and daily live check | in progress | `LL:3866` | Nov 16 | security fixes lead
5. Beta window Nov 9 to 22; monitor every 12 h, SSOT daily | in progress | `MH:22-23` | Nov 15 | beta monitor, SSOT keeper
6. Design guardrails (barrel import, type-aware lint, Material theme work); lint baseline 631, shrink only | in progress | `process-improvement.md:253`; `LL:3066` | Nov 14 | guardrails lead
7. CSE Algebra split follow-up: all 11 lessons split, 220 questions re-approved. Baseline for the CET rewrite | in progress | `MH:77` | Nov 15 | bite-sized lessons lead
8. Staging payment runs must disable the prod test webhook first | standing rule | `LL:2831` | Nov 9 | all lanes
9. Manager's daily three-way sweep (cost, users, dates within 14 days) | standing | `process-improvement.md:151-158` | Nov 15 | operations manager

## C. Approved but not started

1. Verification and learning, all stages (journey checks, shared mistake log, proof rule, daily review of real use). "All after beta" | approved, paused to Nov 16 | `2026-11-04-verification-and-learning-log.md:69-71` | Nov 4 | unassigned
2. Legal version stamps set to the publish date at prod ship | approved, ship pending | `LL:3122` | Nov 12 | integrator
3. Real-device sync verification before any native release | approved, not started | `OPERATIONS.md:43` | Aug 12 | Aedwon
4. Native release rebuild of the protected content package at schema 11, then an install check | approved, not started | `MH:74` | Nov 15 | unassigned
5. CET-account proof (credit carry-over, catalog refresh, retired-id redirect) before any CET exam opens | approved gate | `LL:3658`; `MH:75` | Nov 15 | CET lane
6. Illustration style kit and pipeline, after the coverage audit | approved, not started | `2026-10-05-illustration-production-log.md:31-41` | Oct 5 | unassigned
7. Fix 8 backslash display problems in `light-and-optics.yaml` when next edited | approved | `2026-10-25-cse-rewrite-p0-notes.md:8-11` | Oct 25 | content lead
8. Fix the CI path filter gap (docs-only merge into a branch starts no CI) | noted | `LL:3809` | Nov 15 | guardrails lane

## D. Ideas and options not yet approved

1. **Parameterized question generator with abstract reasoning.** Idea Oct 25 (`LL:1573`; `plans/2026-10-19-pwa-launch.md:372`, "its own conversation"). Option 1 of 5 on Nov 3 (`PB:17`): large build, generated questions need an independent audit. Build to be chosen after Nov 15 from beta data (`PB:23`). It also gates PSHS-NCE and the four academy exams (`docs/pricing.md:44`) and thins repeats in CSE pools (`question-style-guide.md:249`). Status: not approved, no spec. Last mention Nov 3. Owner: Aedwon to choose after Nov 15. **Choice is now due.**
2. Smarter roadmap: knowledge map and readiness forecast (R3 probabilistic engine; Pro screens). Option 2 on Nov 3 | idea / parked | `PB:18`; `specs/2026-10-26-prerequisite-roadmap-design.md`; `LL:1831` | Nov 3 | Aedwon
3. Next exams after CSE: UPCAT with DCAT, USTET, ACET (132 lessons). Recommendation only | brief, not approved | `docs/future/2026-11-03-next-exam-brief.md:7`; `PB:45` | Nov 3 | Aedwon. Next ACET filing deadline Dec 12, 2026 (current cycle)
4. Funding brief: Google for Startups, startup.gov.ph and others | brief, not approved | `docs/future/2026-11-03-funding-brief.md:4` | Nov 3 | Aedwon
5. Flashcards mode in Study | idea | `docs/future/2026-11-09-flashcards-idea.md:4` | Nov 9 | Aedwon, after beta
6. Codebase gardening | archived idea, revisit when earning | `docs/future/2026-11-09-codebase-gardening-idea.md:5` | Nov 9 | Aedwon
7. Parent and child pairing for under-13 consent (needed before PSHS-NCE) | idea | `docs/future/2026-08-02-parent-child-pairing-and-consent.md:4,86` | Nov 2 | Aedwon
8. Post-launch revenue streams and telemetry foundation | forward-looking | `docs/future/post-launch-revenue-and-telemetry.md:3` | May 18 | Aedwon
9. Bite-sized split for CET lessons ("the same treatment") | idea | `LL:3782` | Nov 15 | Aedwon
10. Admin lookup tool for double charges; redemption codes and gift codes; account-ID grants | idea / after launch | `plans/2026-10-19-pwa-launch.md:36-38`; `2026-10-04-giveaways-and-gift-codes-log.md:13-15` | Oct 19 | Aedwon
11. Animated lesson illustrations (3 to 4 days) | after launch | `plans/2026-10-19-pwa-launch.md:39-42` | Oct 29 | Aedwon
12. Wrapped and sharing (W4g); desktop layout from Claude Design | after launch | `plans/2026-10-19-pwa-launch.md:34-35` | Oct 19 | Aedwon
13. Pointer resampling for every screen; the reader's pull-to-advance drag delay | idea, for a future decision | `LL:3911` | Nov 16 | Aedwon
14. Fold Content Pass into the founder app (full port ruled) and a Posts tab | idea | `founder-app-log.md:353,385` | Nov 10 | Aedwon
15. Fresh-device first sync makes one call per read lesson; providers rerun local work on token refresh | idea | `LL:3819` | Nov 15 | manager
16. DMARC tightening beyond report-only | idea | `LL:3263` | Nov 14 | unknown
17. Teen Notice "Age check" legal basis (NPC Opinion 2017-049) | idea | `LL:3142` | Nov 12 | manager
18. Not approved security items: checkout S-12, narrower function permissions, branch protection on main, security headers, Pro sync quotas, replace marketing key | not approved | `LL:3245` | Nov 14 | Aedwon
19. Repo private plan and CI budget | idea | `LL:3117` | Nov 11 | Aedwon
20. QR Ph in-app refunds | later, only if refunds become common | `founder-app-log.md:45` | Nov 2 | Aedwon

## E. Parked

1. Native Android and iOS store releases (waiting on funds) | parked | `PB:23`; `plans/2026-10-19-pwa-launch.md:48` | Nov 3 | Aedwon
2. Review center deals | parked | `PB:23` | Nov 3 | Aedwon
3. Scroll smoothness work (E-098, E-102), stopped. Unmerged: `web/scroll-jank-r1`, `web/scroll-input-check-r1`, `exp/scroll-ab-local`; staging still serves the check build | parked | `LL:3909-3911` | Nov 16 | DS4 lead and integrator
4. PayMongo live path steps 3 to 5 (live keys, public Terms, drop beta gate) | parked | `LL:2786` | Nov 9 | Aedwon
5. Under-13 support (CSE stays 13+) | parked | `LL:2393` | Nov 2 | Aedwon
6. Custom exams row hidden on web; reminders and non-CSE exams hidden | parked | `LL:3833,2708` | Nov 9 | Aedwon
7. Native reminders (W4f Task 1) | parked | `plans/new-design/STATUS.md:42` | Oct 24 | unassigned
8. Wrapped page private on prod | parked | `LL:3512` | Nov 14 | unknown
9. Unused paid APIs (BigQuery family and others) cannot be disabled without force | parked | `LL:3757` | Nov 15 | security fixes lead
10. Staging Resend key (issue #74) | parked | `LL:3450` | Nov 14 | manager
11. Golden-lock open items (focus ring, zoom badge, Home 1440 label, Pro hero offset) | parked | `LL:3539` | Nov 14 | guardrails lead
12. Gauge gradient wording; Phosphor and Source Serif files | parked | `LL:2885,2695` | Nov 10 | DS4 lead
13. Android 18 to 27 s load (reopen only above 10 s) | parked | `LL:3727` | Nov 15 | beta experience lead
14. CI S7 functions split (built, declined) | parked | `LL:3037` | Nov 11 | manager
15. Pro pages for Licensure, academy exams, PSHS-NCE | parked until those exams launch | `2026-10-05-engineering-restart-log.md:495,769` | Oct 5 | unassigned
16. Roadmap Task 11 change log; low-end device test campaign | parked | `2026-10-01-release-first-cuts-log.md:21,142-146` | Oct 1 | unassigned
17. A student who turns 18 stays marked a minor | parked | `LL:2395` | Nov 2 | unassigned
18. Native Android content defect (20 passage ids) | parked | `LL:998` | Oct 19 | unassigned

## F. Date-bound items

- Nov 17 06:30 UTC | prod Auth App Check watch ended; confirm clean | `LL:3888` | security fixes lead
- Nov 18 | Codex weekly reset; no parallel runs above 85% weekly | `LL:3584` | manager
- Nov 18 to 19 | secrets merge staging proof; handoff Nov 20 | `LL:3908` | security fixes lead
- Nov 21 06:10 UTC | prod Firestore App Check, only if staging traffic is clean | `LL:3646,3888` | security fixes lead
- Nov 21 | wire prod usage alarms to the $15 cutoff | `LL:3478` | security fixes lead
- Nov 22 | beta ends; Pro ends Nov 23 00:00 PHT | `LL:3715` | Aedwon
- Nov 23 16:00 UTC (Nov 24 00:00 PHT) | warm-up stops in code; CI free-tier check fails on every branch unless the secrets merge ships | `LL:3902,3734` | security fixes lead
- Nov 24 00:00 PHT | exit survey closes; old secrets must be destroyed before this | `LL:3715,3908` | Aedwon, security fixes lead
- Nov 30 | beta reward appeal window | `LL:2639` | Aedwon
- Dec 1 02:00 UTC | monthly cost check (alarm pricing, last bill) | `MH:38` | operations manager
- Dec 12, 2026 | ACET filing deadline, current cycle (test Jan 16, 2027) | `next-exam-brief.md:28` | Aedwon (information)
- Mar 14, 2027 | CSC sitting; CSE Pro pass bound to it | `LL:949,2814` | Aedwon
- Dec 31, 2027 | beta reward activation deadline | `LL:2590` | Aedwon
- Weekly | free-tier live check; monthly alerting SKU check | `LL:3741,3758` | security fixes lead
- At public launch | privacy-change emails (rule 9); beta gate must be turned off by a build | `LL:3829,3710` | manager

## Verify done (finished or superseded, but this sweep could not confirm)

Likely finished, confirm and delete:
- Bite-sized lessons design spec still says "waiting for Aedwon's approval of Part A" (`specs/2026-11-13-bite-sized-lessons-design.md`), yet the feature is live (`MH:12`).
- CI speed plan says "needs approval" (`plans/2026-11-08-ci-speed.md`); `LL:3075` shows its last item closed.
- Security audit plan lists Auditor 1 as TODO (`plans/2026-11-14-security-audit.md`); `LL:3214` shows it ran.
- Prod guardian mail key v2 and sender intended as final (`LL:3084,2923`).
- `web/npm-vulnerability-updates` merged? (`LL:2466-2470`). Local test panel (`LL:2195`). Check-moving to Actions (`LL:2444`).
- Astra re-audit of payments fixes (`LL:1886,1991,2064`). Nov 3 change list, items 1 to 17 (`LL:2406-2428`).
- `web/staging-image-cleanup-fix` merged; prod Artifact Registry 1-day keep (`LL:3866,3735`). Tiny Firebase page on staging (`LL:3733`).
- Regression test 7e33dd5a2 merged (`LL:3634`). Billing watcher first real budget figure (`LL:3538`).
- Google API key referrer restrictions (`LL:626`). Mailboxes dpo@ and contact@ (`LL:2027`).
- Privacy policy sentence on the trial-abuse code; "encrypted on your device" web wording (`LL:1872,1484`).

Old or stale lists, treat as superseded unless Aedwon says otherwise:
- `docs/OPERATIONS.md` unchecked boxes (last updated May 7): NPC registration, Apple and Google developer accounts, pentester, iOS schemes, Codemagic signing, PH lawyer review of Privacy and Terms, store privacy forms, branch protection (`OPERATIONS.md:17-20,151-154,222-259`). Lawyer review: Nov 9 "risk accepted" (`LL:2389`).
- `docs/superpowers/2026-08-03-launch-checklist.md`: native-era checklist with about 30 unchecked boxes (lines 57-148). Likely superseded by the PWA launch.
- `docs/superpowers/plans/new-design/STATUS.md` rows A5 to A8, VP (visual pass "not started"), B4.
- October engineering-restart items: sync upload held, Pending Android purchase handling, four W3 design choices, save-failure line, W4 phone acceptance (`2026-10-05-engineering-restart-log.md:980-1201,2315`). Log ends Oct 24.
- October CSE rewrite items: parked RA 6713 lesson, Aedwon's QA of rewritten lessons and figures, Astra review of all rewritten content, lesson figures seen in the app, teaching-gaps lessons (`LL:1819,1620,1634,2015,1649`).
- Release first cuts: AGENTS.md still names Ink and Rule (`release-first-cuts-log.md:165-172`); Filipino-wording AGENTS.md change answer (`question-explanations-log.md:1100-1106`); 134 "NEEDS AEDWON" content items (`question-explanations-log.md:387-405`).
- Giveaways: cancellation fix, short public ID (`giveaways-and-gift-codes-log.md:104-169`).
- Pantas Master SSOT connector on another Google account (`LL:2106`).
- 968 unapproved questions still exported "until their subject is split" (`LL:2398,3253`).
- `docs/TERMS.md` and `docs/PRIVACY.md` old v0 drafts (`LL:2861`).
- `process-improvement.md` is 434 lines against its own 120-line trigger to archive closed entries.
- Remaining small technical notes from the launch log (lines 472 to 2398), for example clipboard test, mock reopen copy, YAML parse of one file, intermittent tests, Safari and Firefox database check, release source tag. All are old Oct 19 to Nov 2 notes with no later closure seen.

# Operations manager handoff (Nov 25, 6:50 PM Manila)

Manager thread: `mcp:launch:2f628e2495c6e1411884e3ca9e4a1bdc13467273ae2643e58f0fdb984177a926`. Read `docs/workflow/operations-manager.md` (lanes table is current), `docs/workflow/process-improvement.md` (seven new Nov 25 entries) and the "Aedwon's requests" table at the top of `docs/superpowers/backlog.md` first. That table is the running list of his requests and their status.

## Live on prod today (all verified, launch log has each)
Week strip short names; his Pro on all 18 exams (owner grant plus the web mapper fix); wide reader without lesson dashes; pulley figures; tester-only items removed; Home counts refresh; paused session option A (Reviews sheet, Quiz tab card, header count removed, Discard spacing restored); loading spinner with real percent (option A); CSE content fixes (10 keys and notes, Pro mock 150 + 20, 8 lesson facts); wide button pairs and single buttons to his Nov 7 placement rule, plus a placement check; under-18 sign-up closed (option C); launch limits for about 500 sign-ups (cutoff $30, budget $40, reCAPTCHA 1,000 a day, App Check 6 h, sign-in mail 90 of Resend Free's 100, alert at 80).

## Waiting on him (his list before opening sign-up)
1. Approve the legal texts: change summary on branch legal/publish-r1 (`docs/legal-drafts/2026-11-22-public-launch/change-summary.md`, sections "Nov 25" and "Round 5"). Business name everywhere; his full name only in Terms and Privacy Policy; DPO by title.
2. Google Analytics retention 2 months with "Reset user data on new activity" off; Gmail labels `pay-2y` and `hold`.
3. Seller details on the website homepage (his copy; offer an agent draft).
4. Opening day and hour, then "ship it" for the gate-off build (proven on staging, release lead r7).
5. Guided first-run board https://claude.ai/artifact/D3JLTrRGiN8vjnfLrbhoMN: taste lesson A (fixed starter, recommended) or B; assessment progress A (as now) or B (save as you go, recommended). Decided by him: Skip allowed; after the taste Home shows "take the assessment". He wants it before launch (about 2 to 3 days of build).
6. One Google sign-in on app.pantas.study (retires the old Firebase address). Codex accounts a and c need re-login.
Link-preview image: decided from his approved splash (board https://claude.ai/artifact/8emGUsKPxKrkpqd1rHi2sw); ships with the opening.

## Queued
- Lesson walk-through standard: APPROVED (picks at recommendations: length a, Quick Check A). Starts for CSE after his first-run picks and his steps 2 and 6. Lead: `mcp:launch:6fcf82ba...` (parked).
- No-echo loader for SELLER_* inputs: he asked whether it stays on the laptop; answered (the three seller-line facts are in the app by design); awaiting his yes.
- Service worker mix gap: held until before opening; needs him to lift the Nov 14 rule.
- 68 Minor and 14 Unsure CSE audit findings: backlog C11, re-check before launch.
- Ideas: flashcard mode, slides mode (backlog D5, D23).

## Leads
- CSE release lead r7 (integrator) `mcp:launch:55d23bdfde1cbdbac9638f0f42400f367a941a688ddb9d6bea85cda3646e2cd2`: idle, handoff `2026-11-25-cse-release-lead-r7-under18-limits-legal-gateoff.md`. Next task with freshContext.
- UX lead `mcp:d8548b12-d7ea-4fd6-8dc3-919a8b8c0570`: idle. Builds the first run after his picks.
- Paused by him: security r2, payments (PayMongo is sole-prop verified, QR Ph only; prepaid plans fit), under-13 (must keep 13 to 17 closed), PSHS-NCE, QG Phase 2, dots.

## Lessons from today (see process entries)
Briefs carry his exact words; nothing answered goes on his boards; rulings name their search (the U24 footer reached prod for 4 minutes); reviews check patterns.md, not only boards; freshContext must not be sent to a lead with work in flight.

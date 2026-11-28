# CSE release readiness, Phase 1 report (inspection), 22 November 2026

Lead: CSE release lead (Opus 5.5), branch `qa/cse-release-r1`. Policy: `origin/main` ecfeaf0d1
at start, 47ac60058 at report. Requested by the operations manager for Aedwon's six findings
(Nov 22) and checklist rows P1, P2, P3, P8, P10, C3, C4 and G4 of
`docs/superpowers/plans/2026-11-22-cse-public-release-checklist.md`.

Evidence: `docs/superpowers/verification/2026-11-22-cse-qa/`. The full deduplicated list is
`consolidated.md` there: 125 findings, each with sources, severity, platforms and fix size.

## Part A. For Aedwon (plain language)

**Outcome.** The two causes of "Could not save your progress" are found and fixed on main.
They wait for your "ship it". Reports from students have never been sent anywhere, and that
needs your decision. Everything else is ranked below with a fix plan.

**Your six findings**

1. *Study vs Quiz spacing.* Confirmed. Both boards put the title at the same height. The code
   puts the Quiz title 40 px lower than Study on the phone. The two screens were set to
   different numbers in an earlier fix. Fix: one shared top offset from the boards.
2. *"Part X of Y · N questions".* Your complaint stands. A Fable ruling under your delegation
   chose this label on Nov 14 (launch log, "Bite-sized lessons decisions"), but on one
   condition: a mockup the manager shows you before anything is built. That step never
   happened. The label then spread to 17 places, more than any board shows. Fix: you pick from
   Claude Design options (decision 2 below).
3. *Buttons without a border are too big.* Confirmed, and the cause is the design-system rule
   itself: the sheet guidance makes every Cancel and Close a 52 px full-width button. The
   boards show 44 px natural-width text buttons. Several sheets (Home Lessons, Reviews, New
   questions) add a Close that no board draws at all. 77 borderless buttons inventoried. Fix:
   correct the rule, then every site, to the boards. No new board needed.
4. *Check does not save.* Two causes, both fixed on main, neither yet on prod:
   - The app logged an analytics event before saving, and that event refused question ids over
     64 characters. 261 of 4,427 prod questions have such ids, in every exam, not only CSE. It
     hit only students who allow usage sharing. Your friend's Nov 12 question was the same
     cause (its id is 70 characters). The Nov 12 fix missed it because save errors were not
     reported then, and the test account did not allow usage sharing. Fixed in PR #82.
   - Found by both audits: when another question split a reading passage, the passage's second
     question failed to save in Retake, Today, the in-lesson quiz, Drill and Restart. Fixed in
     PR #83.
   - The check you asked for: three build checks now fail on any analytics call that can stop
     or delay a save, on any question id past the analytics limit (100 characters, Google's own
     limit), and on a session stored in a different order than shown. Size: about 150 lines of
     checks and 120 lines of tests. Each was shown failing on the old code.
   - Every question in every exam's bank was checked against 51 more rules. No other question
     format breaks the save.
5. *Report does not morph.* Confirmed. The report opens as a separate layer over the bar, and
   "Saved on this device." is a second element on top. The note editor already morphs the bar
   in place; the report does not reuse it. Fix: the report boards (QN_Report and its states).
6. *Reports do not submit.* Confirmed, and not a network or App Check problem. Reports are only
   kept on the phone. No server endpoint was ever built, so no report has ever reached anyone.
   App Check and the security rules allowed every call from your phone.

**Decisions for you**

1. *Report sending.* (a) Build it: a protected server endpoint that stores each report, plus
   the morph from finding 5. About 1 day. Cost: about 2 database writes per report, far inside
   the free tier. Reports already queued on phones are sent after the update. (b) Hide the
   report button for launch: about 1 hour, and reports stay lost. Recommended: (a).
2. *The part label.* You pick from Claude Design options built from the approved screens, for
   example: no label (title only), "Part 2 of 3" only on Study cards, or the label only where
   minutes used to be. Recommended: show you the options before any change.
3. *Complexity.* Minimal, balanced or hardened (Part C). Recommended: balanced.

**Launch items found (for the manager and integrator, not decisions for you)**

- The prod web build has the beta gate on. A public visitor would see "This email isn't on the
  beta list". The public build must turn it off (checklist G3).
- Sign-in codes for people not on the beta list are capped at 20 a day on prod. The 21st new
  student in a day cannot sign in.
- 19 beta-only surfaces are listed with a remove or reword verdict, including a "BETA" mark on
  the share image (checklist G4).
- The Subprofessional mock shows section counts Pantas split evenly, as if official. Ruling
  (lead, under "never invent a figure"): Subprofessional shows no per-section counts, and both
  CSE mocks carry the existing "Pantas practice exam, not the official format" line, unless you
  object.

## Part B. Findings by severity

Counts after removing duplicates (125): 1 blocker if the public build keeps the beta gate on
(U53); 1 item one source rated blocker and the other major (S14, a question with no correct
choice; none exist in any bank today); 42 major; 5 rated major by one source and minor by the
other; 76 minor. Already fixed: 2 (PR #82, #83).

| Group | Blocker | Major | Major or minor | Minor | Main items |
|---|---:|---:|---:|---:|---|
| Save and sync | 1 (S14) | 18 | 2 | 2 | Answer, review and log written in separate steps, so a failure in the middle repeats or splits on retry (S1); a 50 ms delay before a web answer is stored for good (S6); Reviews can fail at Finish (S10); one bad item rejects a whole finished quiz on the server, for good (S3); sittings over 300 answers are rejected (S5); five more places wait on notifications or crash reporting before saving (S17 to S21, the same pattern as finding 4) |
| Reports | 0 | 2 | 0 | 1 | Never sent (S24); no morph (U1) |
| Layout and spacing | 0 | 2 | 0 | 11 | Finding 1 (U3); mock proctor notice moves the page (U5) |
| Text no board asked for | 0 | 5 | 0 | 22 | Finding 2 (U16); wide-web mock says "Saved on this device" for server answers (U17); the exam named three ways (U18) |
| Button sizing | 0 | 2 | 1 | 7 | Finding 3 (U43); Restore Purchases (U44); wide-web tertiary buttons (U45) |
| Public launch | 1 (U53) | 5 | 1 | 8 | Beta gate (U53); sign-in cap (S25); beta Pro row (U54); mock counts (U58, U59); Record "this week" and streak figures (U60, U61) |
| Content tooling | 0 | 1 | 0 | 3 | The lesson audit tool stops on prod content (C1); no CSE student sees a broken figure |
| Other | 0 | 7 | 1 | 22 | Pro page shows Weekly and Yearly the CSE boards do not (U69, check against `docs/pricing.md`); delete-account steps (U70); native-only items (U71 to U73); Free mock interval 14 vs 30 days (U74) |

Verified by the lead in code: S24, U3 (boards and code), U16 (decision record), U43 (button
minimum size), U71, S25, S16 (real, but a CSE student's bank stays under the limit, so minor
for CSE). The rest come from two independent audits per area (Codex and Gemini for code,
Claude reviewers for UI) and are marked by source in `consolidated.md`. Pixel values are read
from code and boards, not measured on a device; one headless render sheet per changed screen
confirms them in Phase 2.

## Part C. Fix plan and complexity

All UI work is done by Claude workers, never Codex. Each change matches an approved board 1:1.
A change with no board goes to Aedwon as Claude Design options first (rule 3).

| Level | Scope | Lead estimate (active) | Wall time |
|---|---|---|---|
| Minimal | His six findings (1, 2 after his pick, 3, 5, 6) and the launch items above; S17 to S21; legal gates D1, D2 and D3, D7 | 4 days | 5 working days |
| **Balanced (recommended)** | Minimal, plus the save and sync items a CSE web student can hit (S1, S3, S5, S6, S10) and every web major in UI (U5, U17, U18, U20, U44, U45, U68 to U70, U74) | 5.5 days | 7 working days |
| Hardened | Balanced, plus all 76 minors, native-phone-only items, the server and sync defensive fixes (S7 to S9, S11 to S16), and C1 | 8.5 days | 10 to 12 working days |

Revised Nov 22 to add the legal launch gates ruled that day (`docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md`, "Nov 22, legal package D1 to D8"): D1 delete the under-18 record when a guardian request fails (0.5 day), D2 and D3 the Pro checkout declaration, policy link and seller line (1.5 days; his tick or no-tick pick is on the CSE Release Picks board), D7 trial-code dates with a 730-day expiry (0.5 day). D1 and D7 are server-only and run beside the UI work. C1 moved to hardened: the manager ruled the audit tool does not gate launch.

Estimates are uncalibrated for this kind of work; recent velocity rows ran 0.1 to 0.6 of the
estimate. Wall time includes CI, the one-Flutter-job machine cap, Codex weekly room (about 7%
until the reset), and his picks on boards.

Order: ship #82 and #83 (waiting for "ship it"), then report sending, then buttons and spacing,
then save robustness, then the remaining UI majors. Each batch: tests first, CI, one render
sheet per changed screen, merge to main, prod only after his "ship it".

## Part D. Checklist rows closed or updated

P1 fixed on main (#82, #83), prod after "ship it". P2 decision 1. P3 not passed: 49 blocker and
major items. P8 closed (48812779c, tests for Tab order, focus ring, Enter, Space and hover).
P10 not met (U58 to U61). C3 open in tooling only: 0 broken visuals reach a CSE student. C4
met: the content gate finds 0 unapproved questions on prod's content, and the approved ledger
covers all 4,427. G4 listed (19 surfaces).

## Part E. Agent notes

- Audits: Codex GPT 6.2 Sol High (save path and banks, parts A and B), Gemini 4 Neon High
  (save and report paths, parts A to D; content C3 and C4; consolidation), Sonnet 5.5 (UI, two
  reviewers; one started four more Sonnet workers of its own, logged in process-improvement),
  Sonnet 5.5 independent review of #82.
- Bank audit: 7,590 question rows across the prod tree (d97de9415) and main; per-rule failing-id
  lists were kept in the lead's local `build/audit/` and are reproducible with the scripts the
  audit describes (`codex-findings.md`, Part B).
- Not verified: device rendering; the Pro page products (U69) against `docs/pricing.md`; the
  native-only items, since native is out of launch scope.

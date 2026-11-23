# CSE release readiness, Phase 2 plan (hardened), 23 November 2026

Lead: CSE release lead. Spec: `docs/superpowers/plans/2026-11-22-cse-release-qa-phase1-report.md`
(Parts A to C) and its evidence `docs/superpowers/verification/2026-11-22-cse-qa/consolidated.md`.
Decisions: launch log, "Nov 23, save-fix web ship to prod, and Aedwon's CSE release decisions"
(scope hardened; part label A; build report sending; the content gate). Legal gates: rulings
`docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md`, "Nov 22, legal package D1 to D8".
Boards: Claude Design "CSE Release Picks" https://claude.ai/artifact/PMKs9koUswojKFY27aExv8.

## Standards applied

- `AGENTS.md` (never invent a figure, voice, pricing), `WORKFLOW.md` (verification, completion),
  `SUBAGENTS.md` (tests first, verify do not relay), process-improvement rules 1 to 4 (motion,
  Claude Design boards, copy under delegation) and rule 7 (free tier, count before hosted runs).
- WCAG 2.2: 2.5.8 target size (24 px minimum; boards use 44 px), 2.4.7 focus visible, 4.1.3
  status messages (report sent, offline saved, Paused).
- Firebase: App Check on callables, server-owned writes for student reports, Firestore free tier
  (50,000 reads, 20,000 writes a day per project).

## Limits

One Flutter build, test or analyze at a time machine-wide (`build/audit/flutter-locked.sh` in the
lead's worktree serializes them). At most 2 Claude workers; workers start no subagents. Codex only
for audits; Gemini Flash only for bulk checks the lead verifies. UI work is Claude only. Each worker
has its own worktree and branch; the lead reviews, merges to main, and ships to prod only after
Aedwon's "ship it".

## Tasks

| ID | Task | Depends on | Owner |
|---|---|---|---|
| T1 | Content gate layer (a): every shipped question, quiz, mock and lesson part through the app's real Dart logic, no UI, no network; a permanent CI check | none | Sonnet worker |
| T2 | Report sending: server callable, rules, client sender for queued reports, tests, free-tier count | none | Sonnet worker |
| T3 | Part label removed from every UI site (board option A); data kept | none | Sonnet worker |
| T4 | Report bar morph (QN_Report and states), phone; wide drop-down form as boards | T2 | Sonnet worker |
| T5 | Borderless buttons and the sheet guidance (finding 3), board option A | none | Sonnet worker |
| T6 | Study and Quiz title offset (finding 1, U3) and the layout majors and minors | none | Sonnet worker |
| T7 | Save and sync: S1, S3, S5, S6, S10, S7 to S9, S11 to S16 | none | Sonnet worker; Codex Sol High audit |
| T8 | Awaited side effects S17 to S21 (same class as PR #82), with the analytics-never-blocks check widened to notifications and crash reporting | none | Sonnet worker |
| T9 | Remaining web and phone UI majors and all minors (consolidated U-items) | boards where needed | Sonnet workers |
| T10 | Legal gates: D1 under-18 record deletion (server), D7 trial-code dates and expiry (server), D2 and D3 checkout declaration (UI) | D2 and D3 (tick, option T): the text lane's wording | Sonnet workers |
| T11 | Launch items: beta surfaces (G4) removed or reworded, P10 ruling (no Subprofessional section counts; practice-exam line on both CSE mocks) | public build plan (integrator) | Sonnet worker |
| T12 | C1: the lesson audit tool runs clean on the content prod serves | none | Sonnet worker |
| T13 | Content gate layer (b): one browser run per distinct loop, per open exam (CSE Pro, CSE Sub) and mode | T1, the fix batches | Lead |
| T15 | Lesson reader full screen, "4 Held" (wide web; phone unchanged): spec `docs/superpowers/specs/2026-11-23-lesson-reader-full-screen-design.md`, canvas Lesson Reader Full Screen; fallback "figures at rest" (direction 1) if the held figure cannot move in the same frame as the scroll | UX hand-off a41d7102f | Sonnet worker |
| T16 | Core loops polish B2, B4, B3, B5, B1 in that order: spec `docs/superpowers/specs/2026-11-23-core-loops-polish-design.md`, canvas Core Loops | UX hand-off a41d7102f | Sonnet workers |
| T17 | Money-path app items from the security lead's audit (Nov 23, details private): ENT-06 (High, before live keys) map `beta_reward` grants to that exam's Pro coverage in the web payment gateway's entitlement mapper, with a test; ENT-12 (Low) drop entitlement replies older than the latest request (request counter). Fresh review of the money path | security lead hand-off | Sonnet worker; Codex Sol High review |

## T1 contract (content gate layer a)

Input: a content export (`build/export.json` from the content tree being checked; the lead also
runs it once on prod's tree, d97de9415 plus main's three files). For every active item, using the
app's own code paths (the mirror mapper, the content repository, `SubmitAnswer`, the quiz session
repository, completion, results, review and resume), with an in-memory database:

1. It loads and maps without error (question sets, passages, figures, lessons and parts, mocks).
2. Its parts render offscreen (stem, choices, passage, images, math, figures) with no exception
   and no error widget.
3. It has exactly one correct choice, 2 to 6 choices, and unique choice ids.
4. Grading: the correct choice grades correct and one wrong choice grades wrong.
5. The answer saves through `SubmitAnswer` into a session, and the analytics properties pass
   `assertPropertiesAllowed` with no drop.
6. The server payload passes the server's own limits (ids, lengths, counts, the 300 cap).
7. Results, review and resume rebuild from the stored record.
8. Every mock blueprint fills every slot from active, exam-tagged items.

Every failure names the item id and the cause. The check runs in CI on every push that touches
content, lib or tools, and in the content upload's gate. Existing checks reused, not duplicated:
`question-id-limits`, `analytics-never-blocks`, `session-stored-order`, `mock-blueprint-topics`,
`bold-stem`, the content approval gate.

## T2 contract (report sending)

- A callable (App Check enforced, signed-in account) stores one report document server-side
  with question id, question version, exam id, message (trimmed, at most the client's limit),
  created time and app build. Client writes to that collection are refused by the rules.
- Server limits match the client's: 3 reports per question per account, 20 per account per day.
- `ReportQueue.sendPending` sends queued reports (including those already on phones) with retry,
  removes each only after the server accepts it, and never loses one on failure. The per-question
  lifetime count survives sending.
- Free-tier count (rule 7): each report is 1 invocation, 1 to 2 writes and 1 read for the daily
  limit. Expected use is far under 1% of the daily free writes. Staging proof: 5 reports, about
  10 writes and 5 reads.

## Verification

UI tasks (T3 to T10 and every hardened minor), required (Aedwon confirmed the spec, Nov 23: "this is exactly why I wanted you to do the QA pass. get things moving properly please, and be more conscientious next time."): the spec is Pantas Web, Pantas Redesign and Guardian Manage and Minor Checkout. The worker names the boards it built from. Before the task counts as done, a reviewer who did not build it compares the build side by side with those boards at phone and wide widths, including motion timing and easing. Every difference is classified (Aedwon, Nov 23, replacing "every difference is a defect"): BUILD WORSE is fixed to the board; BUILD BETTER is kept and listed for the reference canvases (sent to the manager's board inventory); UNSURE goes to a council of Gemini 4 Neon High (through agy; GPT 6.2 Sol High through codex-pick only if Gemini is unavailable, judging only) and a Fable 5.2 high agent, each given the board, the build at phone and wide widths and his guidance; agreement rules, a split goes to Fable; each ruling is recorded in the rulings file. Copy is compressed on every touched screen without changing meaning (rule 4), before and after recorded. Motion (timing, easing, feel) is checked phone first, then wide. A screen no board covers goes to a Fable ruling.

T14 (phone pass): Phase 1 has evidence for 108 of the 288 Pantas Redesign phone boards. A full per-board phone pass (Gemini 4 Neon High, read only; the lead verifies samples) classifies every board; its BUILD WORSE items join the fix tasks.


Each task: tests first and shown failing, focused tests while working, `run_checks.dart`, CI on
the branch by full SHA, one headless render sheet per changed screen (Nov 9 exception), a fresh
review for UI and for money, student data or security, then merge to main. Prod ships in batches
after his "ship it", each with a rollback point and a live check.

## Estimate

Hardened scope 8.5 days active plus the content gate (layer a about 1 day, layer b about 1 day):
about 10.5 days active, 12 to 14 working days wall with two workers and one Flutter slot. Recent
velocity rows ran 0.1 to 0.6 of their estimates. Velocity rows E-138 onward.

## Rulings that settle the boards (Nov 23, final)

The approved boards are the spec (manager, relaying Aedwon: "why are you asking me things that have
been decided before?"). Build to them; escalate only a state no board draws, to Fable 5.2 first.

- Section 1, part label: A, no label in the UI; the data stays.
- Section 2, report: exactly as the approved boards draw it: QN_Report phone frames with the
  0.42 s morph and its states; the wide drop-down form. T4 is unblocked.
- Section 3, Cancel and Close: A, match the boards; no Close where the board draws none. T5 is
  unblocked.
- Section 4, checkout: T, the required tick in the approved guardian box card (Fable D2). The D2
  and D3 part of T10 waits only on the text lane's final wording.
- Section 5, Backup paused: 0.

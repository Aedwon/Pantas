# Engineering restart strategy (plan of plans)

Date: October 5, 2026, rewritten top-down the same day. Status: Part A approved by Aedwon on
October 5 (see the decision record). Policy revision read: `origin/main` at ac4b30da (AGENTS.md, WORKFLOW.md, SUBAGENTS.md).
Decision record: `docs/superpowers/decisions/2026-10-05-engineering-restart-log.md`.

This is level 1 of four. It defines every workstream, the order of planning, the rules shared
by all plans, and the gates between levels. It contains no implementation detail.

---

## Part A. Plain-language summary for approval

### Why top-down

Past rounds wrote one overall plan, then planned and built one piece at a time. Each piece made
local choices, and the pieces drifted apart. This restart finishes each planning level for
**every** workstream before anyone starts the next level. No code is written until all planning
is finished and cross-checked.

### The four levels

1. **Plan of plans (this document).** Workstreams, order, shared rules, gates.
2. **Workstream plans.** For each workstream: scope, the design boards it covers, acceptance
   checks, and the contracts other workstreams rely on (design values, shared component
   interfaces, screen routes, data). Fixed contracts are what prevent drift.
3. **Implementation plans.** For each workstream: tasks in order, files, tests, and checks.
4. **Implementation.** Workers build exactly what level 3 says.

### Rules that hold every level together

- **Level gates.** A level is complete for all workstreams before the next level starts. A
  review then checks every document at that level against the others and against the level
  above. Problems are fixed before moving down.
- **One traceability table.** Every design board, every decision, and every gap-pass answer maps
  to exactly one task. Nothing is unassigned and nothing is built twice. The gate reviews check
  this table.
- **Changes go up first.** If a lower level needs something different, work on it stops. The
  higher level is amended, recorded, and reviewed, and the change flows down to every affected
  document. Changes to approved behavior come back to Aedwon.
- **Abuse cases are a requirement.** Added October 6 with Aedwon's approval, after the abuse review
  (`plans/new-design/gates/abuse-review-1.md`). Every workstream that touches payments, Pro access,
  the server, stored files or shared links lists its abuse cases and their fixes in its level 2
  plan. An independent Opus reviewer checks them at each gate, and the release checks test them on
  the final build. The goal is no avoidable mistake, not absolute protection: a patched app can
  always unlock what runs on the phone, so anything valuable is checked on the server.
- **The design is authoritative.** Changes the design made to older screens are built as drawn
  and listed for Aedwon's information. Things the design left out are listed for his
  keep-or-discard decision. He decides only on missing things.

### The sequence, and where Aedwon is needed

| Stage | What happens | Aedwon's part |
|---|---|---|
| 0. Inputs | Gap pass on every screen; triage of kept branches and stashes; spec update for behavior changes; traceability table started | Decide missing items and kept work; approve the spec update |
| 1. Level 2 | All workstream plans written, then the level 2 gate review | None, unless the review finds a product question |
| 2. Level 3 | All implementation plans written, then the level 3 gate review | None, unless the review finds a product question |
| 3. Level 4 | Implementation in the planned order, with independent review | Visual checking from his own screenshots; phone checks |

Decisions already made (pause lifted for the listed items, roadmap branch as the base, balanced
complexity, all handoff answers, date format) are in the decision record and are not reopened.

### Effort and usage

- Stage 0: mostly Sonnet, plus Aedwon's answers. About one session.
- Levels 2 and 3: the lead model writes the contracts and reviews; Sonnet drafts the screen
  plans. About three to four sessions, after the weekly limit resets.
- Implementation size: about 25 screen families and 15 to 20 shared components. A real estimate
  comes out of level 3.

### Approval

Approved by Aedwon on October 5, 2026. Stage 0 has started.

---

## Part B. Agent section

### B1. Verified state (October 5, 2026)

| Item | State |
|---|---|
| Integration branch | `integration/new-design-r1` at 1f79d880, created from `origin/web/roadmap-engine-r1`, pushed. Baseline: analyze 1 info (deprecated `onReorder`, bookmarks sheet), format, layering and attribution clean, 3,403 of 3,403 tests pass. Seed assets copied from the roadmap worktree (gitignored). Details in the decision record. |
| Roadmap branch | Contains beta/integration-r1, every E04 to E09 line, security verification. |
| main | Policy and documents only beyond b642e2d1. Design handoff at 58667f2a (286 boards, `docs/design/`). |
| content/question-qa-r2 | 765c5dc0. Not in the integration branch. Corrected Oct 6: 328 files, no application code (question YAML, audit ledgers, one importer rule, tests). Merged in W0 as a fast-forward. |
| Content coverage audit | Running on `docs/content-coverage-audit-r1`. Separate track. |
| Kept after cleanup | 9 dirty worktrees, about 30 branches with uncontained commits, 3 stashes. Triaged in stage 0. |
| SSOT | Google Doc tab "Pantas Production Readiness Assessment". The 5 Oct entry says the baseline is running. It needs a one-line update. |

### B2. Workstreams (level 1 definition)

Each workstream gets one level 2 plan and one level 3 plan. "Owns" means that workstream's level
2 plan fixes the contract; others consume it and may not change it.

| ID | Workstream | Depends on | Owns (contracts) |
|---|---|---|---|
| W0 | Integration: merge question-qa-r2 code and content into the integration branch; regenerate; full checks. Amended Oct 6 (level 2 gates): also the data the design adds (JSON fields for notes and blank reasons, per-part wrong and blank counts), the exam catalog (content database schema 10, Coming soon exam rows, functions copy) and the mock blueprint placeholder marker | Stage 0 | Content and question file formats; data layer; exam catalog; blueprint format |
| W1 | Design foundation: color and type values for light and dark, Geist and Source Serif 4 fonts, icon set, motion primitives from `MOTION.md`, app shell with the pill tab bar (Home, Study, Quiz, Settings), date formatting, visual rules section for AGENTS.md | W0 | Theme value names, font roles, icon names, motion API, shell routes, date format helpers |
| W2 | Shared components (15 to 20): grouped rows, cards, gauge, floating bar, week strip, notice strip, wheels, question grid, buttons, Pro lock pattern, placeholder marking. Replaces Ink-named components and the 9 bottom-sheet call sites | W1 | Component interfaces and states |
| W3 | Pre-beta fixes: subscription cancellation keeps Pro until expiry; short public ID for giveaways. Added Oct 6 by Aedwon's decision: Pro priced by exam tier per `docs/pricing.md` (tiers, higher tiers include lower, Season Passes, upgrade on switching to a pricier exam, trial on Monthly only). Amended Oct 6 (abuse review 1): the payment and Pro-access abuse fixes: purchase validation and current-state reconciliation in the webhook, a server pass ledger bound to product, exam and transaction (refunds and transfers included), bounded offline Pro after the paid period, Pro reset on account change, RevenueCat tamper-check results honored, tier-specific giveaway grants, server tier checks on server content | W0; deploys wait for W6's deployable package | Entitlement state rules; tier and pass rules; public ID format and API |
| W4a to W4h | Screen families (amended Oct 6, abuse review 1: (g) also fixes the share-link file path check and upload limits): (a) onboarding; (b) Home with Your plan, History, weeks, Your performance, Your record, Your tendencies; (c) Study map, reader, bookmarks; (d) Quiz tab, customize, question screens; (e) Mock, including review gating; (f) Settings, Pro pages, subscription, legal; (g) Wrapped and sharing; (h) loading, errors, offline, update required. Includes retiring the old Progress routes | W1, W2; (b), (d), (e), (f), (g) also W3; (b) uses the roadmap engine | Routes per family in their own route files. Amended Oct 6 (level 2 gate): a family may own a family-specific contract another family consumes, named in its level 2 plan with the order: (a) exam picker screen; (b) day context, table order setting, Your record slot; (d) lesson and quick quiz starts; (e) mock card, per-exam scoring rule, CSE and ACET blueprints; (f) reminder settings and service, About slot; (g) Wrapped and shared links rows; (h) app-wide state patterns |
| W6 | Backend hardening (added Oct 6, abuse review 1): a deployable Functions package (dependencies, build, entry point, Admin setup) and tests that run the real handlers and rules; strict create rules for user records; per-account limits on audit, sync staging and other server writes; unfinished endpoints disabled (data export placeholder, unused content query function); working cleanup and retention jobs | W0 | Functions packaging and test contract; server quota rules |
| W5 | Release checks: E09 phone checks #22 to #28 and Redmi smoke, E10 to E14, A01, A02, A03, A04, A07, updated for the new screens. Amended Oct 6 (abuse review 1): release build code obfuscation, and an abuse re-check of every recorded abuse case on the final build | W4 complete, W3, W6 | Release evidence format |

Fixes that release checks find are new work items. Each one enters at the level its change
requires and flows down.

Content track (not in this program): coverage audit, question QA content, illustration
production. W0 fixes the content file formats; no workstream changes them without telling that
track.

### B3. Stage 0: inputs before level 2

1. **Gap pass (Sonnet, one dispatch per screen family, parallel).** For each family, compare the
   current app (integration branch) and pre-October specs against the boards in `SCREENS.md`
   and `DECISIONS.md`. Output two lists per family:
   - Changed by the design: old behavior, new behavior, board id. For Aedwon's information.
   - Missing from the design: old feature, control, or state with no board. For his decision.
   The lead merges the lists into one document and removes duplicates. Aedwon decides.
2. **Kept work triage (Sonnet).** For each kept worktree, branch, and stash: what the unique work
   is, whether the integration branch already does the same thing another way, and a keep or
   discard recommendation. Aedwon decides. Nothing is deleted without his decision.
3. **Spec update (lead).** One amendment spec in `docs/superpowers/specs/` covering the behavior
   changes: mock review gating, Pro History, Wrapped moments, Progress retired into Home, date
   format, CSE and ACET placeholders, and the missing-item decisions from step 1. Plain-language
   section for Aedwon's approval, agent section below it.
4. **Traceability table (Sonnet, lead reviews).** `docs/superpowers/plans/new-design/traceability.md`.
   One row per board, per decision in the restart log and handoff `DECISIONS.md`, and per gap
   answer. Columns: item, source, workstream, level 2 section, level 3 task (filled later),
   status.
5. **Execution arrangement (lead).** Read
   `docs/superpowers/decisions/2026-09-25-chatgpt-web-relay-routing.md` and record how level 4
   work will be dispatched. The Google worker service is canceled; do not use it.
6. **SSOT.** Update the 5 Oct entry with the baseline result.

Stage 0 exit: Aedwon has answered steps 1 and 2 and approved step 3; the traceability table lists
every input item with a workstream.

### B4. Level 2: workstream plans

Location: `docs/superpowers/plans/new-design/L2-<id>-<name>.md`.

Writing order within the level, so each plan reads contracts that already exist:
W0, then W1 and W3, then W2, then W4a to W4h (parallel drafts), then W5.

Every level 2 plan has these sections:
- Purpose and scope, including what is out of scope.
- Inputs: spec sections, boards by id, decisions, gap answers (by traceability row).
- Contracts owned: exact names, interfaces, states. Contracts consumed: by reference only.
- Behavior, including Free and Pro rules and placeholder figures.
- Motion entries from `MOTION.md` and the 1:1 rule.
- Acceptance: how completion is judged, automated checks, and Aedwon's visual check.
- Risks and stop conditions (schema version mismatch, board contradicts spec, figure without a
  source, missing contract).
- Abuse cases and their fixes, for workstreams that touch payments, Pro access, the server, stored
  files or shared links (amended Oct 6).
- Files and directories the workstream may touch.

Drafters: the lead writes W0, W1, W2 contracts, W3, and W5. Sonnet drafts W4a to W4h from the
template; the lead completes their behavior and acceptance sections.

**Level 2 gate review.** An independent reviewer (not an author) checks all level 2 plans
together:
- Every traceability row has exactly one owning workstream and section.
- No two workstreams own the same contract or touch the same files without a stated order.
- Every consumed contract exists in its owner's plan with the same names.
- Plans agree with the spec, the handoff, and the decision record.
- Nothing in a plan is a product decision that Aedwon has not made.
- Every confirmed finding of the abuse review has an owning workstream and section, and each
  plan's abuse cases are complete for what it touches (amended Oct 6).
The lead fixes findings, then records the gate as passed in the decision record.

### B5. Level 3: implementation plans

Location: `docs/superpowers/plans/new-design/L3-<id>-<name>.md`. Written only after the level 2
gate passes.

Each level 3 plan follows `WORKFLOW.md` "Plan detail and simplicity" and `SUBAGENTS.md`: tasks
in order, files per task, the failing test to write first, focused checks per task, full checks
at the end, base SHA, and stop conditions. Every task cites its traceability rows.

**Level 3 gate review.** An independent reviewer checks all level 3 plans together:
- The traceability table has a task for every row.
- Task file lists across all plans: overlapping files have a stated order.
- A parallel execution map: which plans can run at once, in separate worktrees.
- Each task's checks are concrete commands with expected results.
- Each level 3 plan agrees with its level 2 plan.
The lead fixes findings, records the gate, and updates the SSOT.

### B6. Level 4: implementation

- Order: W0; then W1, W3 and W6 in parallel (W6 added Oct 6); then W2; then W4 families per the
  parallel map; then W5.
- One plan per worker, one worktree per worker, per `SUBAGENTS.md`. Workers never merge.
- The lead integrates into `integration/new-design-r1`, runs the combined checks, and updates the
  traceability table and SSOT as each workstream completes.
- Independent review for every workstream before integration.
- Aedwon does visual checking from his own screenshots. No autonomous screenshot capture.

**Change control.** A worker that finds the plan wrong, incomplete, or in conflict stops that
task and reports. The lead decides the level the change belongs to, amends that level first,
records it in the decision record, re-runs that level's consistency check for the affected
documents, and updates every lower document affected. Behavior changes return to Aedwon.

### B7. Model layering

Aedwon's rule (October 5): planning uses Opus 5.5 at medium effort; Sonnet 5.5 only for parts
that need no reasoning. Implementation uses Sonnet 5.5 unless the lead judges a task needs Opus.

- **Opus 5.5, medium (lead and planners):** everything in stage 0 steps 3 and 5, every level 2
  and level 3 plan including the W4 screen plans, gap-pass merging and judgment, gate reviews,
  change control, integration, final checks.
- **Sonnet 5.5, medium (no reasoning needed):** gathering for the gap pass (listing what each old
  screen and spec contains), kept-work inventories, building the traceability table rows,
  keyframe extraction with `docs/design/tools/timeline.py`, SSOT and log transcription.
- **Implementation:** Sonnet 5.5 workers by default. Opus for W0 merge conflicts, W3 payments and
  entitlement logic, any schema change, and any task a Sonnet worker stops on twice.
- **Independent reviewers:** Opus for gate reviews and for W0 and W3 code review; Sonnet may
  review other code workstreams. Never the author.
- **Amended October 6 (Aedwon):** "6.1 Sol High for execution (if the plans are already ready),
  then Astra for deep, security/optimization, sweeping audits. you (Claude Opus 5.5 Med) would
  only oversee this process". From level 4 on:
  - Implementation: GPT-6.1 Sol at high reasoning, through Codex, for every workstream, one plan
    per worker in its own worktree, following SUBAGENTS.md like any worker. This replaces the
    Sonnet and Opus implementation lines above.
  - Audits: GPT-6 Astra through Codex, a deep security and efficiency sweep of each workstream
    before it integrates, and of the whole release before W5's evidence review.
  - Opus lead: oversight only. Writes each dispatch, judges every audit finding (agree or not,
    with reasons), runs the plan gates, integrates, updates the plans, traceability and SSOT, and
    brings Aedwon the decisions. Opus does not write implementation code.
  - Pace follows Aedwon's Codex limits; the three-worker limit in the parallel map still applies.
- Every dispatch carries the startup instruction from `docs/workflow/startup.md` and the policy
  revision.

### B8. Usage budget

The weekly limit resets Saturday 2 PM. Stage 0 steps 1, 2, 4, and 6 are Sonnet work and can run
before the reset if Aedwon wants. Steps 3 and 5 and all of levels 2 and 3 use the lead model.

### B9. Unattended running

Goal: after Aedwon answers stage 0, the work runs through levels 2 and 3 to the start of level 4
without him, resuming by itself after usage limits reset.

- **Status file:** `docs/superpowers/plans/new-design/STATUS.md` on main. It holds the current
  stage, the next step, what is waiting on Aedwon (if anything), a lock with a start time, and the
  last completed step with its commit. Every step ends by updating and pushing it, so any fresh
  session can resume from it alone.
- **Resume task:** a desktop scheduled task runs about every hour. Each run starts fresh, reads the
  policy files and the status file, and then:
  - If the lock is held and younger than 3 hours, it exits.
  - If the status says it is waiting on Aedwon, it exits.
  - Otherwise it takes the lock, does the next step, records it, releases the lock.
- **Notifications:** a push notification only when Aedwon is needed: a product question, a stop
  condition, a gate passed that needs his eyes, or the start of level 4.
- **Limits:** a run that hits a 5-hour limit stops; the next hourly run after the reset continues.
  When the weekly limit is reached, nothing runs until it resets or Aedwon resets it.
- **Unverified:** how a scheduled run behaves when it starts while the limit is still in effect.
  The first unattended run will confirm it; until then, the hourly retry is the fallback.
- The task is removed when level 4 starts or when Aedwon asks.


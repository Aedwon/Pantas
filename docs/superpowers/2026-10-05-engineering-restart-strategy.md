# Engineering restart strategy (plan of plans)

Date: October 5, 2026. Status: draft for Aedwon's review. Nothing in this document is approved
or started. Policy revision read: `origin/main` at 23c48fea (AGENTS.md, WORKFLOW.md, SUBAGENTS.md).

This document does not plan the code. It plans **how the code plans get made**: what must be
cleaned up first, which decisions Aedwon owns before planning, which plans to write and in what
order, and which model does which layer of work. Each workstream below becomes its own spec (if
needed) and plan under the normal `WORKFLOW.md` process.

---

## Part A. Plain-language summary for approval

### Where things stand

- The current engineering candidate is the roadmap branch. It already contains the beta
  integration line, every E04 to E09 repair line, and the security verification line. Main is
  ahead of it only by policy documents. So the roadmap branch is the natural base for the restart.
- Application code is still paused. On September 30 Aedwon lifted the stop for the roadmap build
  only: "All other engineering stays paused." Starting new design work needs that pause lifted.
- The release checkpoint verdict is still "NO-GO for Internal-beta acceptance." Phone checks wait
  until the new UI is connected (Aedwon, October 1).
- The new design handoff (286 boards, tokens, motion) is committed on local main but not
  pushed. It redesigns every student-facing screen. The app has a theme layer that can be swapped,
  but its colors, font and most shared components follow the retired Ink and Rule look.
- Two fixes are already required before internal beta and are not started: the subscription
  cancellation bug (Pro is removed on cancel instead of on expiry) and the short public ID for
  giveaways, which ships with the new Settings screen.
- The content question review (question-qa-r2) changed app code as well as content (about 475
  non-document files). It is not in the roadmap branch. Joining the two needs a deliberate merge.
- The repository has about 30 worktrees, about 50 unmerged branches and 3 old stashes. Most are
  leftovers from earlier rounds that the roadmap branch already contains.

### What gets set up first (needs Aedwon's approval where marked)

1. Save and push the new design handoff and the three uncommitted documents on main. **Approval:**
   these were written in other sessions; confirm they are final.
2. Record the missing items in the SSOT: the new design handoff, the October 5 illustration
   decision, the content coverage audit, and the current pause state.
3. Clean up branches and worktrees whose work is already inside the roadmap branch or main.
   **Approval:** deletion. Unmerged or uncommitted work is listed for a decision, never removed.
4. Run the full checks once on the roadmap branch to get a trusted starting point.

### Decisions Aedwon owns before any code plan

1. **Lift the pause** for new design work, the two pre-beta fixes, and the merge of the content
   review code. Recommended: lift it for exactly those.
2. **Base branch.** Recommended: start a new integration branch from the roadmap branch.
3. **Complexity level** for the whole restart. Recommended: balanced (details in Part B, B3).
4. **Open handoff items** (Part B, B4): about eight behavior questions the handoff raises, such as
   Free mock review limits and the Pro History screen. Each needs a yes or a short answer.
5. **Screens with no board** (legal viewer, subscription management, dark mode outside the main
   screens). Choose: design them in Claude Design, or let the lead apply the Settings rules and
   show them in the visual companion.

### How the work is split

- The lead model holds decisions, specs, plan review, merging, and final checks.
- Cheaper Sonnet workers do inventory, mapping, mechanical edits, and first drafts of tests.
- An independent reviewer checks each finished workstream, as `SUBAGENTS.md` requires.
- The content audit and illustration work continue on their own track. Code work only needs to
  keep the content format stable, and the plans say so.

### Expected effort

- Setup and decisions: one to two sessions, mostly Sonnet, plus Aedwon's answers.
- Writing all workstream plans: two to three sessions of the lead model.
- Implementation: large. Roughly 25 route families and 15 to 20 shared components. A real
  estimate comes with each plan, not here.

---

## Part B. Agent section

### B1. Verified state (October 5, 2026)

| Line | SHA | Notes |
|---|---|---|
| origin/main | 23c48fea | Policy and docs only beyond b642e2d1 (non-doc diff vs roadmap: AGENTS.md, WORKFLOW.md, SUBAGENTS.md and 3 other policy files). |
| local main | 58667f2a | +1 unpushed: new design handoff (commit subject uses the old name "Clarity") (754 files, +40,611). Dirty: question-explanations log (+668, append only); untracked: `docs/design/pipelines-handoff.md`, `decisions/2026-10-05-illustration-production-log.md`, `specs/2026-10-03-exam-content-coverage-audit-design.md`. |
| origin/web/roadmap-engine-r1 | 1f79d880 | Contains beta/integration-r1, e09-qlp5-prepared-next-r1, e09-security-performance-verification-r1, e04-content-protection-r1. Last recorded suite 3,403/3,403 (SSOT, Oct 1). Missing main's 84 policy and doc commits. |
| origin/beta/integration-r1 | 0f69e79c | Ancestor of the roadmap branch. Not an ancestor of main. |
| origin/content/question-qa-r2 | 765c5dc0 | Not in roadmap (214 commits). Non-doc diff: 475 files, about 16% under `lib/features`, plus tests and content. Subject branches -math, -other, -science feed it. |
| docs/content-coverage-audit-r1 | e51dbf98 | Dirty: spec modified (may differ from the untracked copy on main), one untracked profile doc. Owned by the audit track. |

SSOT: Google Doc `1LzdBQjPmRYXV1LSrLnK7F6_eadQi7cb1fj8mg7yuZg4`, tab "Pantas Production
Readiness Assessment". Doc comments could not be read through the connector; treat as unknown.

### B2. Phase 0: housekeeping (Sonnet, medium; lead approves)

Run in this order. Each step is a separate, small dispatch.

1. **Main documents.** After Aedwon confirms: commit the three untracked documents and the log
   change on main, then push main (docs-only, allowed under the workflow rollout exception). Reconcile
   the two copies of the coverage audit spec first; the audit worktree's copy is the newer edit.
2. **SSOT update.** Append a checkpoint entry: new design handoff (commit, board count, precedence
   rules), October 5 illustration decision, coverage audit approval state, pause state, and this
   strategy. Record the same in a repository decision log.
3. **Cleanup inventory, then cleanup.** A worker produces a list; the lead verifies each row with
   `git merge-base --is-ancestor <branch> origin/web/roadmap-engine-r1` (or main) and a clean
   status before proposing removal. Aedwon approves the deletion list once.
   - Removal candidates: worktrees and branches fully contained in the roadmap branch or main and
     clean (for example the e04, e09 and beta-integration worktrees, `web/pantas-rc-be-repair-r1`,
     the 57 local branches already in main, local `-verify` branches whose SHA equals an origin
     branch).
   - Needs Aedwon's decision, never auto-removed: dirty worktrees (`beta-final-verification-r1`
     with 38 modified lib files, `e04-content-protection-r1` with 23, detached `qlp5-physical-r1`
     with 22, release-e2e worktrees with untracked tests, `wt-m7`), local-only branches with
     unique commits (`mock-resume-correctness-r1`, `e09-product-defects-repair-r1/-r2`,
     `lesson-illus-w5a/-w5b/-w5verify`), `track-a-salvage`, `wt-m8`, and the three stashes.
   - Untouched: the content QA and coverage audit worktrees (active content track).
4. **Baseline check.** On a fresh worktree of the roadmap branch: regenerate code
   (`build_runner`), then the five `SUBAGENTS.md` Part 5 checks. Record exact output. This is the
   trusted starting point; do not reuse the October 1 result.

### B3. Complexity options (Aedwon chooses)

- **Minimal:** token and font swap, rebuild shared components, restyle existing screens to the
  boards. Skips motion except what a screen cannot work without, and skips handoff behavior
  changes. Fails the 1:1 rule for motion, so it is not suitable to keep. Not recommended.
- **Balanced (recommended):** every board implemented 1:1 including drawn motion; behavior
  changes from the handoff go through short spec amendments; the two pre-beta fixes; focused
  tests per screen plus golden or widget checks for shared components; no new infrastructure.
- **Hardened:** balanced plus visual regression tests against board stills, full dark mode on
  every screen, accessibility audit per screen, and performance budgets. Adds an estimated 30 to
  50 percent. Better done after beta feedback.

### B4. Handoff questions that need Aedwon (collect in one sitting)

From the handoff review. Each becomes a spec amendment line or a "use as drawn" note.

1. Mock results gating: Free keeps full review until the next mock opens, then score and
   breakdown only; Pro reopens any time; notes on misses are Pro only. New behavior; confirm.
2. Pro History screen vs the October 1 decision to keep the change log on the device with no
   screen. Pro reinstall loses history until sync exists. Confirm scope.
3. Wrapped triggers: handoff adds "topic turning weak to strong" and differs from the coded
   streak list. Confirm the new list. Pro Wrapped history placement is still open in the handoff.
4. Bottom sheets: README says none; DECISIONS still shows a few. Proposed rule: only where a
   board shows one.
5. Navigation: Progress merges into Home and Settings becomes a tab. Confirm the old Progress
   routes are retired.
6. Date format is marked "proposed 4 Oct". Confirm.
7. CSE per-subject counts and ACET aptitude time have no published source. Under the never-invent
   rule they cannot ship as figures. Confirm they are hidden until sourced.
8. Screens without boards (see Part A, decision 5) and the deferred guided first-run demo.

### B5. Workstreams and plan order

Each row is one plan in `docs/superpowers/plans/`. Write plans in this order; later plans may
be drafted in parallel once their dependencies' interfaces are fixed.

| # | Workstream | Depends on | Spec work | Plan drafter | Execution |
|---|---|---|---|---|---|
| W0 | Integration branch: new branch from roadmap; bring main's policy docs (read-only, policy comes from main anyway); decide and merge question-qa-r2 code | Phase 0 | None, unless the QA merge changes behavior | Lead | Lead (conflicts, schema regen) |
| W1 | New design foundation: tokens (light, dark), Geist and Source Serif 4 fonts, icon set, motion primitives (about 11 effects, curve table), app shell with pill tab bar | W0 | Visual rules section for AGENTS.md derived from the handoff | Lead | Sonnet workers per component, lead reviews |
| W2 | Shared components (15 to 20): grouped rows, cards, gauge, floating bar, week strip, notice strip, wheels, question grid, buttons; replace Ink-named components and the 9 bottom-sheet call sites | W1 | None | Sonnet drafts, lead reviews | Sonnet workers in parallel, one worktree each |
| W3 | Pre-beta backend fixes: cancellation keeps Pro until expiry (balanced), short public ID (hardened, ships with Settings) | W0 | Exists in giveaways log; check it is a full spec | Lead | Lead or one Sonnet worker plus independent review (payments are high risk) |
| W4 | Screens, one plan per route family: onboarding; Home with roadmap (day, plan, weeks, history, performance, record, tendencies); Study (map, reader, bookmarks); Quiz (tab, customize, question); Mock (about 36 boards, gating); Settings and Pro pages; Wrapped and sharing; loading, errors, update-required | W2, B4 answers; Settings also W3 | Amendments from B4 | Sonnet drafts board-to-widget mapping; lead writes behavior and acceptance | Sonnet workers per family; lead integrates |
| W5 | Release resume: E09 phone checks #22 to #28 and Redmi smoke (Aedwon on device), then E10 to E14 and A01, A02, A03, A04, A07 | W4 connected, W3 done | Existing release contract | Lead | Aedwon on device; lead records |

Parallel, not in this program: content coverage audit, question QA content, illustration
production (code-generated figures per the October 5 log). Code plans must not change the
question or lesson file formats without telling that track.

### B6. Model layering

- **Lead (Opus):** Part A decisions with Aedwon, spec amendments, W0 and W3 plans, review of every
  drafted plan against spec and handoff, merges, final combined checks, SSOT and decision log
  updates. Never delegated: product decisions, payments logic review, schema bumps.
- **Planner drafts (Sonnet, high or medium):** W2 and W4 plan drafts from a fixed template
  (scope, boards covered, routes, components used, behavior, Free and Pro rules, tests, checks,
  stop conditions). The lead reviews before execution.
- **Grunt work (Sonnet, medium):** inventories, board-to-route matrices, keyframe extraction
  with `docs/design/tools/timeline.py`, token tables to Dart, mechanical renames, test scaffolds,
  doc and SSOT drafts. Each dispatch is bounded with assigned files and a check command.
- **Independent review:** a different agent than the author, per `SUBAGENTS.md`, for every
  workstream before integration.
- Every dispatch carries the startup instruction from `docs/workflow/startup.md` and the policy
  revision. Read `docs/superpowers/decisions/2026-09-25-chatgpt-web-relay-routing.md` before the
  first execution dispatch; it sets the current execution arrangement and may route some work
  elsewhere. The Google worker service is canceled; do not use it.

### B7. Usage budget

Weekly limits are near. Order the work so the expensive model is used where judgment matters:

1. Now (cheap): Phase 0 inventory, SSOT draft, board-to-route matrix, motion keyframe tables.
   All Sonnet, all read-only or doc-only.
2. After Aedwon's answers: lead writes W0, W1 and W3 plans and the spec amendments.
3. After the reset: Sonnet drafts W2 and W4 plans in parallel; lead reviews; execution begins.

### B8. Plan template for each workstream

Every plan names: controlling spec and handoff boards (by board id), base SHA, file table,
dependencies on other workstreams, Free and Pro rules, motion entries from `MOTION.md`,
the 1:1 acceptance rule (Aedwon does visual checking from his own screenshots; no autonomous
screenshot capture), focused checks per task, full checks at the end, and stop conditions
(schema version mismatch, board contradicts a spec, figure without a source).

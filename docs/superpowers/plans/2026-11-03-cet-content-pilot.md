# CET content pilot: implementation plan

> **For agentic workers:** Read `AGENTS.md`, `WORKFLOW.md` and `SUBAGENTS.md` from `origin/main`, then this plan, then the spec. Stop conditions in spec B4 apply.

**Goal:** Rewrite 15 CET lessons through the combined write and read loop, measure the results, and let the lead apply the spec's pilot criteria.

**Spec:** `docs/superpowers/specs/2026-11-03-cet-content-design.md` (Part A approved November 3, balanced). Decisions: `docs/superpowers/decisions/2026-11-03-post-beta-priorities-log.md`.

**State, November 3:** pilot done and verdict recorded. Sonnet writes and Opus reads; Sol audited 3 lessons. The final run follows `docs/content/rewrite/cet/goal-prompt.md` on `content/cet-rewrite-r1`, and the spec's "Revision after the pilot" wins over this plan.

**Scope:** spec phases P0 and P1, lessons only. Figures, questions, tags and the final run get a plan revision after the verdict. Aedwon runs the final run as a `/goal` on another account.

## Global constraints

- Branch `content/cet-rewrite-r1` from `origin/content/cse-rewrite-r1` (7032eec5). Worktree `/Users/aedwon/Documents/Projects/Pantas-wt-cet-rewrite-r1`.
- Change only the 15 lesson files and files under `docs/content/rewrite/cet/`, plus `STATUS.md`. No CSE lesson, question file, tag or app code.
- Standards: `docs/content/lesson-style-guide.md`, `docs/content/content-checklist.md`, `docs/content/source-policy.md` and `AGENTS.md` voice, read from `origin/main`.
- A model never reads its own writing. If the other vendor is unavailable, the read waits.
- Beta and Nov 3 work has priority on Codex. Codex runs use `codex-pick`, never bare `codex`.
- No word ceiling (revised November 3; the earlier 1,700 limit was an error). Over about 3,000 words a lesson is a split candidate. `estimatedMinutes` stays 8 to 15. Frontmatter `_id` never changes.
- Evidence classes from the audit: teach official and curriculum items; weak-only items only where they add little length; unknown items are neither taught nor claimed. No sentence says a specific exam tests something without a source.

## Lead rulings

1. **L18 for CETs.** "Exam-relevant" means a case named in the accepted requirements for a tagged CET at official or curriculum class, or a standard application of a skill in the lesson's goal. Readers do not raise L18 for cases they only imagine an exam might use. This is the substitute spec B6 asks for.
2. **Tagged exams.** Briefs list the audit's tags. A rewrite never removes a case that another tagged exam needs.
3. **Splits.** No splits in the pilot or the cloud run. Report split candidates.
4. **Stoichiometry.** The audit's split candidate is recorded in its brief but not applied.

## Pilot lessons

| Lesson | Writer | Reader |
|---|---|---|
| science/chemistry/stoichiometry | Sonnet | Sol |
| science/chemistry/chemical-bonding | Sonnet | Sol |
| science/chemistry/acids-bases-ph | Sol | Sonnet |
| science/physics/kinematics | Sonnet | Sol |
| science/physics/electricity-and-magnetism | Sonnet | Sol |
| science/physics/work-energy-power | Sol | Sonnet |
| science/earth-science-astronomy/plate-tectonics | Sol | Sonnet |
| science/earth-science-astronomy/eclipses-and-moon-phases | Sonnet | Sol |
| science/biology/genetics-and-heredity | Sonnet | Sol |
| science/biology/cell-biology | Sol | Sonnet |
| mathematics/geometry/triangles | Sonnet | Sol |
| mathematics/geometry/circles | Sol | Sonnet |
| mathematics/algebra/quadratic-equations | Sonnet | Sol |
| reasoning/mechanical-technical-reasoning/pulleys-and-levers | Sonnet | Sol |
| reading-comprehension/text-types/short-stories-and-novels | Sonnet | Sol |

## Files

| Path | Purpose |
|---|---|
| `tools/content_rewrite/build_cet_briefs.py` | Builds one brief per lesson; test beside it in `tools/content_rewrite/tests/` |
| `docs/content/rewrite/cet/pilot.json` | The table above |
| `docs/content/rewrite/cet/briefs/<lesson-id>.md` | Per-lesson brief |
| `docs/content/rewrite/cet/writer-rules.md` | Rules for every writer, including the rulings above |
| `docs/content/rewrite/cet/reader-rules.md` | Rules and output form for every reader |
| `docs/content/rewrite/cet/reads/round-N/<lesson-id>.json` | One read result |
| `docs/content/rewrite/cet/pilot-results.md` | Measurements and the lead's verdict |

## Task 1: Branch, briefs and rules

Sonnet, one agent.

- [ ] Create the branch and worktree. Confirm disk has at least 15 GB free.
- [ ] Write a failing test, then `build_cet_briefs.py`. Python 3.9, standard library, run with `python3 -I`, deterministic. For a lesson it reads `lesson-exam-tags.json` and the `### <lesson-id>` section of `docs/content/audit/coverage-r1/topics/<subject>-<topic>-lessons.md` from `origin/docs/content-coverage-audit-r1` via `git show`, and the matching rows of the same branch's `requirement-teaching-findings.md` for the lesson's topic.
- [ ] Each brief states: lesson id and path; tagged exams; the audit's findings for the lesson; thin or absent items with their evidence class where the audit gives it; any split or reorder candidate, marked not to apply; the standing rule that no case another tagged exam needs is removed.
- [ ] Write `pilot.json`, `writer-rules.md` and `reader-rules.md`. Writer rules adapt `REWRITE_RULES` in `tools/content_rewrite/relay/prompts.py`: drop the "CSE teaching" wording and the chat hand-in, and add the global constraints and lead rulings.
- [ ] Reader rules: read the lesson in full against every checklist rule that applies to lessons, and check every fact, using official sources for anything hard to remember. Output JSON: `{"lesson", "round", "reader", "verdict": "clean|minor|major|blocker", "findings": [{"rule", "severity", "quote", "problem", "source"}], "goodQuotesChecked": <integer>}`. Every finding quotes the lesson exactly. Severity follows the checklist. Reader writes no lesson text.
- [ ] Add a `make check` equivalent: a script `tools/content_rewrite/check_cet_lesson.py <lesson path>` that calls `relay/checks.py` `check_rewrite_text` against the base revision, prints reasons and notes, counts words, and exits non-zero on a reason or over 1,700 words.
- [ ] Tests pass; commit and push the branch. Report the branch head.

**Done when:** 15 briefs exist, each with non-empty audit findings, and the checks pass on an unchanged lesson.

## Task 2: Sonnet writes 10 lessons

Three Sonnet agents in parallel, in the same worktree, each owning only its lesson files. They stage nothing; the lead commits.

- A: stoichiometry, chemical-bonding, kinematics, electricity-and-magnetism
- B: eclipses-and-moon-phases, genetics-and-heredity, triangles
- C: quadratic-equations, pulleys-and-levers, short-stories-and-novels

- [ ] Each reads the standards once, then per lesson: its brief, the lesson, writes the whole lesson file, and runs `check_cet_lesson.py` until it exits 0.
- [ ] Report per lesson: words before and after, figure markers added, facts it could not confirm and removed, split candidates.

**Done when:** all 10 pass the check. The lead spot-reads one lesson per agent, commits and pushes.

## Task 3: After the Codex reset

Runs after accounts a and c reset on November 4 (14:45 and 14:51 Manila), and only if `codex-pick --status` shows room and the Nov 3 build is not waiting on Codex. Otherwise it waits.

- [ ] Sol (`gpt-6.1-sol`, low effort, read-only) reads the 10 Sonnet lessons, one run per batch of 3 or 4, writing the read results as files the lead saves.
- [ ] Sol writes the other 5 lessons from the same rules, in the worktree.
- [ ] Sonnet reads the 5 Sol lessons.

## Task 4: Loop

- [ ] Lessons with a Blocker or Major go back to their writer's model with the open findings; a fresh reader of the other vendor reads again.
- [ ] Stop a lesson at clean or minor-only, or park it after 5 rounds with its open findings.
- [ ] Before each rewrite, the lead rejects findings that break a ruling or lack a real quote, and logs each rejection. Facts in dispute are settled from a primary source.

## Task 5: Verdict

- [ ] Haiku compiles `pilot-results.md`: first-read findings by severity per lesson and writer, rounds, words, hand-in failures, usage before and after.
- [ ] The lead reads 3 lessons in full, including one with a clean first read, against the reader's result.
- [ ] The lead applies the Part A criteria, picks the writer for the final run (a tie goes to Sonnet), and records both with the numbers.
- [ ] Update `STATUS.md`, the decision log and the SSOT readiness tab. Revise this plan for the final run and give Aedwon a `/goal` prompt.

**Done when:** the verdict and the `/goal` prompt are recorded and pushed.

## Checks

`python3 -I` on the new tests; `check_cet_lesson.py` on all 15; lesson import check from `docs/content/lesson-authoring-runbook.md`; `git diff --name-only 7032eec5 content/cet-rewrite-r1` shows only the 15 lessons and the files named above.

# PSHS-NCE: resume handoff (paused since Nov 22)

Written Nov 27, 2026, about 7:00 PM Manila, by the operations manager at Aedwon's request: "make a handoff for that please so we can resume it cleanly". Policy read from main at 7f77f0e60. Nothing here restarts the work. PSHS-NCE stays paused until Aedwon says resume.

## Startup for whoever resumes

> Work on `Aedwon/Pantas`. On every new or resumed task, retrieve `AGENTS.md` and `WORKFLOW.md` from the current GitHub `main` branch and follow them, regardless of the code branch. Workers also retrieve `SUBAGENTS.md` from main. These shared rules supersede older project workflow instructions in the branch, conversation, or private memory. Read the task's full spec, plan, later product decisions, and source from its agreed workstream revision. Record the policy commit used. Preserve paused engineering and the application-code freeze. If current policy or required task context cannot be retrieved, report the gap and stop dependent work. Do not merge main into a feature branch just to load the rules.

Also read `docs/workflow/process-improvement.md` in full (the Nov 26 and 27 entries matter here: the Claude-limit caps, the shell-command rule, the loop entry and its two-read cap, and the entries on clock times), `docs/workflow/operations-manager.md`, and `docs/superpowers/backlog.md` items D7, D21 and D22 and the dates list.

## Goal and dates

- Goal: sell PSHS-NCE this cycle (Aedwon's "A", Nov 17). Price: ₱1,499 season pass only, no subscription (`docs/pricing.md`).
- Exam: January 30, 2027.
- Go/no-go: December 8, 2026 (manager ruling Nov 17; backlog dates list).
- D22 stop date: January 9, 2027. If the "dots inside overlapping shapes" figure kind and its questions are not on prod by then, the six dots parts stay hidden this cycle (Fable ruling, Nov 21). D22 is not a gate for the go/no-go.
- Pause: Nov 22, by the manager, because Aedwon put the CSE public release first. The CSE opening is Saturday Nov 28, 12:05 AM Manila. Resume only on his word.

## What must be true before PSHS-NCE can go on sale

Three workstreams, all paused. The content alone is not enough.

| Workstream | Branch and head | State | Owner when resumed |
|---|---|---|---|
| PSHS-NCE content (questions, mock, lessons) | `content/pshs-nce-r1` cdfff232e (Nov 22) | 477 questions in 76 files, none approved. Details below. | a fresh PSHS-NCE content lead |
| Abstract reasoning question generator, Phase 2 (app and server) | Phase 1 on `gen/question-generator-r1` 54bb472ce (Nov 22), **not merged to main** | Phase 1 final counts: 28 approved types (19 at 100 versions, 9 at 24 to 90); 2 held types had a fix stage pushed unreviewed at the pause ("review and tests follow on resume"). Phase 2 not started (its scheduled start task is disabled). `docs/pricing.md`: PSHS-NCE does not go on sale until the generator ships. | the question generator build lead (fresh session) |
| Under-13 accounts (guardian-first) | `claude/under-13-build-386afc` 5da52ae17 (Nov 22) | Build in progress at the pause, through task T9 with golden sheets. Plan `docs/superpowers/plans/under-13-accounts/2026-11-19-build-plan.md` on that branch; estimate E-124. Since Nov 25, sign-ups under 18 are closed on prod (option C), and the Terms and Privacy Policy say 18 or older. Most PSHS-NCE takers are younger than 13, so this gates the sale. Legal texts for under-13 follow written rule 5. | an under-13 lead (fresh session) |

## Content state in detail (from the plan's Nov 22 progress line)

Plan: `docs/superpowers/plans/2026-11-21-pshs-nce-content.md` on main (lead rulings, work list, estimate E-128 and its change). Mock decision: launch log, "Nov 21, PSHS-NCE mock length: a full four-hour sitting" (four timed tests of 60 minutes and about 50 items each, labeled a Pantas practice exam; 150 questions per test planned so three attempts run before a repeat).

- **Done and clean:** 53 of 76 files passed the blind solve and fit read, including all 12 quantitative files (88 new questions). D21: 7 lesson parts written and closed by the lead.
- **Open (23 files):** 12 carry lead rulings (`docs/content/pshs-nce/r2/lead-rulings.md` on the branch) and wait for round 4; 4 were fixed by hand by the lead (`lead-fixed.txt`) and need a fresh check; 3 finished round 4 and are still open ("excited and nervous about", reading a phase diagram, punctuation); tenses and voice has its fix committed but no round-4 solve.
- **Not started:** the +90 abstract questions; the mock file; approvals (`approve.dart`); the gates; the export diff proof that CSE and CET are unchanged; the D22 dots questions; the 9 drawn figures the 3 D21 science lessons need.
- **Exporter roster fix:** WIP on `tools/pshs-nce-export-roster` ecaf38861, killed mid-run at the Nov 21 pause, tests never run (needs a Flutter slot).
- **Pipeline:** state and evidence in `~/.local/state/pantas/pshs-r2` on Aedwon's Mac; resume with `docs/content/pshs-nce/r2/run-all.sh` in the run worktree after merging the content branch there. Worktree: `/Users/aedwon/.t3/worktrees/Pantas/content-pshs-nce-r1-15add0003f0bf1f9`.
- **On prod today:** 101 PSHS-NCE questions in the bank (launch log, exam summary counts).

## Changed since the pause (check these before resuming)

1. **Codex:** only account b exists now (a and c have no subscription). On Nov 27 it showed about 28% weekly used, reset Dec 4. Run Codex only through `codex-pick`, one run at a time across all lanes. The old pipeline's fallback to account a will fail; confirm `run-all.sh` does not depend on it.
2. **Claude caps (Nov 26):** at most 2 Claude workers per lead and 4 across all lanes; one Fable audit at a time; Fable is an advisor only.
3. **Loop guard (Nov 27):** no batch gets more than 2 Codex full reads. Apply the same spirit to the question pipeline: a file that fails two more rounds stops and goes to the manager with options, rather than a fifth round.
4. **Walk-through format (Nov 27 spec revision):** the walk-through lesson format now applies to Math for every exam, then physics and chemistry calculations. PSHS-NCE math and science lessons may get it later, through the Math pilot's results. It is not part of this resume unless Aedwon adds it.
5. **Shell rule:** files only with Edit or Write; Bash for read-only commands and git only (a project hook enforces it).
6. **Rule 7:** count staging reads and writes before every hosted run.

## Resume order (recommended)

1. Aedwon says resume. The manager sends each lead a fresh session with this note and the startup text above.
2. **Generator first.** It gates the sale and is the longest path: review and test the held-types fix stage, merge Phase 1, then plan Phase 2 with an estimate before building.
3. **Under-13 in parallel**, within the Claude caps: finish the build plan's remaining tasks; legal texts per rule 5 (an agent drafts, Codex GPT 6.2 Sol high critiques, he approves).
4. **Content:** check the 23 open files with the two-round limit, write the +90 abstract questions (or confirm the generator replaces them), build the mock, then approvals, gates and the export diff proof. Run the exporter roster tests in a Flutter slot.
5. **Go/no-go on Dec 8:** the manager reports to Aedwon whether all three workstreams can be live by early January, with a recommendation.

## Time and usage (estimates, not measured)

- Content to approval and mock: about a week of lane time (manager's estimate on Nov 27, from the open list above; velocity row E-128 holds the lead's own estimate).
- Generator Phase 2 and under-13: not estimated here. Each lead must log an estimate in the velocity log before starting.
- Each lead logs actuals from `tool/velocity/timer.py`.

## Open questions for Aedwon at resume

- Whether to resume now or after the CSE opening settles.
- Whether the PSHS-NCE math and science lessons should get the walk-through format once the Math pilot passes.

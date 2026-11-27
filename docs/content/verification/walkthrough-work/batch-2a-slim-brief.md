# Brief: slim Math batch 2a (E-206, step 1)

Lead: walk-through Math lead, batch 2. Plan: `docs/superpowers/plans/2026-11-27-walkthrough-math-batch-2.md` (read "Steps
for each batch" and "Pictures").

Read in full first, in this order:
1. `docs/content/verification/walkthrough-work/pilot-slim-brief.md`. Its "revised format" rules 1 to 9, "Checks" and
   "Report" sections apply here unchanged, except the assignments, the start word counts and the policy commit (below).
2. `docs/content/verification/walkthrough-work/pilot-r1-fix-brief.md`, "Patterns and the lead's rulings" 1 to 10. These are
   the patterns Codex found in the pilot. Apply all of them now, before any read, to every lesson you edit.
3. `docs/content/verification/walkthrough-work/worker-rules.md` (hard limits, block syntax, voice).

Startup: retrieve `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md` from current GitHub main and follow them. Lead's policy commit
`be4ec2f41`. Spec: `git show origin/main:docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md`, Part A
"Revision, November 27, 2026" points 1 to 5.

Worktree: `/Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1`, shared with the lead and one
figure worker. Edit only your assigned lesson files and the figure list file named below, with the Edit or Write tool. No
shell command that changes a file. Do not commit; the lead commits. If you hit a Claude usage limit, stop at once and report
what you changed.

## Extra rules for this batch

- Start word counts: measure each lesson with `wc.dart` (pilot brief, Checks 3) before your first edit and report them.
  Words before a tap may only go down, except for lines added under pattern 5 or 7 of the fix brief, and every lesson ends
  at or under 900.
- Notation: never set a value equal to a percent ("$= 28\%$" for a value). End the chain at the number, then say in words
  what percent it is.
- Do not touch any `<!-- FIGURE WANTED: ... -->` or `<!-- ILLUSTRATION: ... -->` line, except to keep it at the same spot when
  you move text. Markers must never sit inside a `:::` block.
- Simple interest (`arithmetic-number-sense/simple-interest.md`) is already slim. Fix its Codex read 2 rows in
  `docs/content/verification/walkthrough-work/codex-math-pilot-r2.md` (the Blocker and every Major for this lesson), by
  pattern. The Blocker: an older pair note says to add the interest to the original principal for "the final balance",
  which is false after the payment rule (the balance after the payment is Php 15,080, not Php 19,080). Make every
  sentence about a final amount or balance true for both the plain case and the payment case, or scope it. Re-solve every
  number in the lesson after the fix.

## Pictures (spec revision point 5)

For each of your lessons, judge where a picture would help a learner understand a relation that words carry poorly
(rule 10: explain, never decorate). Add one row per picture, or one "none, because ..." row per lesson, to
`docs/content/verification/walkthrough-work/batch-2-figure-list.md` (create it if missing, with the header
`| Lesson | Spot (line and heading) | What it shows | Every number and label, equal to the text beside it | Source |`).
A lesson's existing hidden note counts as a candidate: confirm it, or say why it should go. Every number in a row must
equal the lesson text right next to that spot after your edits. Do not draw anything.

## Assignment (this round)

Writer A (the only writer this round): under `content/lessons/mathematics/`:
`arithmetic-number-sense/simple-interest.md`, `arithmetic-number-sense/compound-interest.md`,
`arithmetic-number-sense/commission-and-sales-tax.md`, `arithmetic-number-sense/markup-on-cost.md`,
`arithmetic-number-sense/successive-percentages-and-increases.md`, `arithmetic-number-sense/direct-proportion-and-travel.md`.
The other six lessons of batch 2a go to a second round.

## Report (under 350 words)

As in the pilot slim brief, plus: the simple-interest rows fixed and how; the figure list rows you added (count per lesson);
start and end words per lesson; any rule you broke.

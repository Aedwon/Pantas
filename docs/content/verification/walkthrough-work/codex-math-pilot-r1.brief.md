# Math pilot, Codex full read 1 of at most 2 (Codex GPT 6.2 Sol high, read-only)

Startup: Work on `Aedwon/Pantas`. Read `AGENTS.md` (including "Maths in content" and Voice) and `WORKFLOW.md` from
`origin/main` (`git -C /Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1 show origin/main:<path>`).
Read the spec `git show origin/main:docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md`: Part B "Authoring
rules" AS AMENDED by Part A "Revision, November 27, 2026" (the revision wins where they differ).

Hard rules:
- READ-ONLY on the repository. Never edit, stage or commit anything under `/Users/aedwon/.t3/worktrees/Pantas/`. Do not run
  dart or flutter.
- Write findings to `pilot-r1.md` in your working directory (this folder), appending after each lesson you finish, so a
  stopped run keeps its work. No em dashes.
- Read every lesson once, fully. Recompute every number yourself.

Target: worktree `/Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1`, branch
`content/lesson-walkthrough-cse-r1`, commit `0e9cc8ef3`. Ten lessons under `content/lessons/mathematics/`:
`algebra/age-word-problems.md`, `algebra/mixture-word-problems.md`, `algebra/work-rate-problems.md`,
`arithmetic-number-sense/discounted-prices.md`, `arithmetic-number-sense/percentage-base-and-fraction-division.md`,
`arithmetic-number-sense/identities-and-like-terms.md`, `arithmetic-number-sense/decimal-and-percent-conversions.md`,
`arithmetic-number-sense/simple-interest.md`, `data-interpretation/percentage-change.md`,
`data-interpretation/table-values-and-totals.md`. Questions: grep `lesson: <_id>` under `content/questions/mathematics/`.
Question files are not changed in this lane; report a question-file defect only if it is a Blocker, in a separate section.

The format these lessons follow (Nov 27 revision): one `:::check` per lesson, one `:::try` (the faded last step of the last
example), no `**Check:**` lines (rule 7 was dropped on purpose: do not flag a missing Check line), 2 or 3 always-open
`:::pair` blocks (Right, Wrong, note), a `:::checklist` that links back. A Quick Check or try may be the same kind of problem
as the worked example with new numbers or a new context. `:::answer` and `:::why` are hidden until a tap; everything else is
visible. `<!-- ILLUSTRATION -->` markers are drawn figures (`content/illustrations/mathematics/<topic>/<lesson>/`, in marker
order); `<!-- FIGURE WANTED -->` comments are NOT shown, so the text must work without them.

Lead's checks at the target (do not rerun): the app's walk-through parser passes all 10; `lesson_checks.dart` from
`tools/walkthrough-checks-r1` `9cd88773b` reports nothing for them (size at or under 900 pre-tap words, trap-pair evidence,
example connection, fresh instance, giveaway, slim format, fences, line breaks, block spacing). A blind pre-check (0 Blockers;
its 6 Majors fixed) and an independent recompute (0 mismatches) ran before this read:
`docs/content/verification/walkthrough-work/pilot-precheck-findings.md` and `pilot-recompute-findings.md`.

Audit against:
1. Aedwon's example rule (Nov 26, verbatim): "notice what's missing here? there was not enough context given here. where's
   the expression from? ... the lessons should be clearly assisting the user to understand logic" / "no that's too wordy now,
   you just made it wordy. i wanted you to connect things better, not explain with more words. those are entirely different
   asks". Each worked example opens with one short lead-in naming what we find and from what; every display chain starts at
   its expression and ends at its value; one move per line; no narration. Flag missing connections AND wordiness.
2. Every number, step, rule and answer correct and scoped. A rule with an unstated exception or precondition that a student
   meets in these exam questions is a finding.
3. The check and the try each test a taught rule, have exactly one defensible answer, and cannot be answered by copying
   visible text (a key printed above or in its own stem, a visible step that already does it, a heading naming it). A check
   that repeats the example or pair directly above with only numbers or names swapped is a Major.
4. Every `:::pair` Wrong line shows the mistake of a wrong choice cited for that pair in `content/walkthrough-trap-evidence.json`
   (same error; the exact value may differ when the note says so), from a question whose `lesson:` is that lesson.
5. Grade 5 English in lesson prose, American spelling, no em or en dashes, `\dfrac` not top-level `\frac`, math between single
   dollars.

Severity: Blocker = a wrong number or false rule, an unsolvable or ambiguous item, an answer that can be copied, broken
structure. Major = missing connection, missing condition, citation mismatch, misleading wording, wordiness, frame clone.
Minor = style.
Format: `Severity | file:line | problem | fix`.

End `pilot-r1.md` with `PILOT VERDICT: PASS` (0 Blockers; Majors are listed and will be fixed once by the lead) or
`PILOT VERDICT: FAIL (N Blockers, M Majors, K Minors)`, then `STAGE-DONE`.

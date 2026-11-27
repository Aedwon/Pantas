# Reasoning audit, round 5: FULL read after the fresh-instance sweep (Codex GPT 6.2 Sol high, read-only)

Startup: Work on `Aedwon/Pantas`. Read `AGENTS.md`, `WORKFLOW.md` and `docs/workflow/process-improvement.md` from `origin/main` (`git -C <worktree> show origin/main:<path>`). Read the spec `git show origin/main:docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md` (Part B), the lane's rules `docs/content/verification/walkthrough-work/worker-rules.md` and `docs/content/verification/walkthrough-work/pattern-checklist.md` in the worktree, and the approved samples `git show origin/tools/walkthrough-checks-r1:docs/content/walkthrough-samples/substituting-negative-numbers.md` and `.../finding-subjects-and-matching-verbs.md`.

Hard rules:
- READ-ONLY on the repository. Never edit, stage or commit anything under `/Users/aedwon/.t3/worktrees/Pantas/`. Do not run dart or flutter.
- Write findings to `rs-r5.md` in your working directory (this folder), appending after each lesson you finish, so a stopped run keeps its work. No em dashes.
- This is the full read that decides PASS (manager ruling, Nov 27: only a full Codex read with 0 Blockers and 0 Majors counts). Read every lesson once, fully, with its questions. Re-solve every filing order, sequence, truth value, inference, matrix, fold, turn, net and shadow yourself.

Target: worktree `/Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1`, branch `content/lesson-walkthrough-cse-r1`, commit `<TARGET>` (set by the lead at launch). Every lesson that contains a `:::` block in `content/lessons/reasoning/clerical-ability/` (9), `logical-verbal-reasoning/` (13), `spatial-abstract-reasoning/` (17) and `verbal-logic/` (8): 47. Questions: grep `lesson: <_id>` under `content/questions/reasoning/`.

History: `docs/content/verification/walkthrough-batch-2-reasoning.md` (round 4 PASS on Nov 26, before the fresh-instance rule 5a existed). After it, a fresh-instance sweep changed checks and tries that reused an earlier instance, and independent workers re-solved them; 12 spatial tries that needed new hand-made figures were left out by manager ruling (recorded in `docs/content/walkthrough-figure-worklist.md`). Question files are not changed in this lane; report a question-file defect only if it is a Blocker, in a separate section at the end.

Figures: an `<!-- ILLUSTRATION: ... -->` marker shows a drawn figure (files in `content/illustrations/reasoning/<topic>/<lesson>/`, in marker order); you may open the SVG to check it matches the text. A `<!-- FIGURE WANTED: ... -->` comment is a figure not yet drawn and is NOT shown to the student. The text must make sense and be solvable without it. A step, check or try that needs a picture the student cannot see is a Blocker if it cannot be solved, a Major if it only reads oddly.

Lead's checks at the target (already run, do not rerun): the app's walk-through parser passes every walk-through lesson; `lesson_checks.dart` from `tools/walkthrough-checks-r1` passes (size, split coverage, pool, trap-pair evidence for every pair, example connection, fresh instance, example Check line, closing fences, line breaks, block spacing); main's content export passes.

Standard to audit against (all of these):
1. Aedwon's example rule (verbatim, Nov 26): "notice what's missing here? there was not enough context given here. where's the expression from? ... the lessons should be clearly assisting the user to understand logic" / "for example: you could say, Let's substitute x=-2 to the terms 3x x^2 and 12/x, and that would be clearer" / "no that's too wordy now, you just made it wordy. i wanted you to connect things better, not explain with more words. those are entirely different asks" / on the target "Let's substitute x = -2 into 3x, x^2 and 12/x:" followed by each chain to its value: "yes that's it!". Each worked example opens with one short lead-in naming what we find and from what; each chain starts at its given and ends at its result; no narration. Flag missing connections AND added wordiness.
2. Every rule, step and answer true and scoped. A rule with an unstated exception, or a list that reads as complete but is not, is a finding. A short scope word is enough at a Grade 5 lesson's level.
3. Fresh instances: every `:::check` and `:::try` tests a rule the lesson taught, on an instance (names, strings, numbers, figures, premises) not already worked or stated earlier in the lesson. It has exactly one defensible answer. No visible step, stem phrase or heading gives the answer away or leaves it by elimination. Each try's `**Check:**` is inside its `:::answer`. Every worked example ends with a `**Check:**`.
4. Every `:::pair` Wrong line shows the mistake of a non-correct choice cited for that pair in `content/walkthrough-trap-evidence.json`, from a question whose `lesson:` is that lesson.
5. Grade 5 English in lesson prose, American spelling, no em or en dashes, `\dfrac` not top-level `\frac`.

Format: `Severity | file:line | problem | fix`, Blocker (false rule or answer, unsolvable or ambiguous item, answer given away, broken structure), Major (missing connection, citation mismatch, misleading wording, wordiness, reused instance), Minor (style).

End `rs-r5.md` with `REASONING VERDICT: PASS` or `REASONING VERDICT: FAIL (N Blockers, M Majors, K Minors)`, then `STAGE-DONE`. PASS means zero Blockers and zero Majors.

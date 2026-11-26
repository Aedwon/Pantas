# Vocabulary, round 3: DELTA audit (Codex GPT 6.2 Sol high, read-only)

Startup: Work on `Aedwon/Pantas`. Read `AGENTS.md`, `WORKFLOW.md` and `docs/workflow/process-improvement.md` from `origin/main` (`git -C <worktree> show origin/main:<path>`). Read the spec `git show origin/main:docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md` (Part B), the lane's rules file `docs/content/verification/walkthrough-work/worker-rules.md` and pattern checklist `docs/content/verification/walkthrough-work/pattern-checklist.md` in the worktree.

Hard rules:
- READ-ONLY on the repository. Never edit, stage or commit anything under `/Users/aedwon/.t3/worktrees/Pantas/`. Do not run dart or flutter.
- Write findings to `v-r3.md` in your working directory, appending as you go. No em dashes.

This is a delta round (manager ruling, Nov 27): it does NOT count as a pass. A batch passes only after a later full read with 0 Blockers and 0 Majors. Its job is to confirm that your round 2 findings are closed and that the fixes did not create new defects, so the full read can converge.

Target: worktree `/Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1`, branch `content/lesson-walkthrough-cse-r1`, commit `9785415c0`, the 29 lessons in `content/lessons/language-proficiency/vocabulary/` with `:::` blocks. Your round 2 report (target `f130a5510`; Vocabulary unchanged since `44d38877f`) is `docs/content/verification/walkthrough-work/codex-vocab-r2.md`. The changes since: `git diff 44d38877f 9785415c0 -- content/lessons/language-proficiency/vocabulary/`. Questions: `content/questions/language-proficiency/vocabulary/`.

Do exactly this:
1. For every round 2 row: CLOSED or OPEN, one line each, with the current line if OPEN.
2. Read every changed hunk with enough of its lesson to judge it. Report any new Blocker or Major the change introduced, or one it exposed in the lines it touches: a false or overbroad rule, a wrong answer, an answer given away (heading, stem, visible step, elimination), two defensible answers, a reused instance, a chain or Check that ends short or repeats the step above, a worked example without its `**Check:**`, a later line naming an old instance, missing connection, wordiness. Use the references in the rules file. Do not report on unchanged lines outside a changed hunk's neighborhood; the full read covers those.

Lead's checks at `9785415c0` (already run): the app's parser passes all 207 walk-through lessons; `lesson_checks.dart` from `tools/walkthrough-checks-r1` passes (exit 0), including fresh instance, example Check line, closing fences and line breaks. Since your round 2, the 29 lessons were swept by the five patterns, read by two independent Claude verifiers and then a delta verifier (`vocab-va-verifier-findings.md`, `vocab-vb-verifier-findings.md`, `vocab-delta-verifier-findings.md`); all their Blockers and Majors were fixed. Use Merriam-Webster and Cambridge for English, KWF and the Ortograpiyang Pambansa 2013 for Filipino (*kuwerdas* is a KWF Diksiyonaryo headword).

Format: `Severity | file:line | problem | fix`. End `v-r3.md` with `VOCABULARY DELTA: N rows open, M new Blockers, K new Majors`, then `STAGE-DONE`.

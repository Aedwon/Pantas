# Grammar (round 4) and Vocabulary (round 1) audit (Codex GPT 6.2 Sol high, read-only)

Startup: Work on `Aedwon/Pantas`. Read `AGENTS.md`, `WORKFLOW.md` and `docs/workflow/process-improvement.md` from `origin/main` (`git -C <worktree> show origin/main:<path>`). Read the spec `git show origin/main:docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md` (Part B), the Filipino section of `git show origin/main:docs/content/lesson-style-guide.md`, and the approved sample `git show origin/tools/walkthrough-checks-r1:docs/content/walkthrough-samples/finding-subjects-and-matching-verbs.md`.

Hard rules:
- READ-ONLY on the repository. Never edit, stage or commit anything under `/Users/aedwon/.t3/worktrees/Pantas/`. Do not run dart or flutter.
- Write findings incrementally to `gv-r4.md` in your working directory (this folder). No em dashes.
- This is the last Codex audit available this week. Be thorough, and be efficient: read each lesson once, fully.

Target: worktree `/Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1`, branch `content/lesson-walkthrough-cse-r1`, commit `fabe161e7`.
- Grammar and Structure: every active lesson in `content/lessons/language-proficiency/grammar-and-structure/` that contains a `:::` block (52; 38 English, 14 Filipino). Your round 3 report is `batch3-r3.md` in this folder. Since round 3, independent Claude verifiers swept all 52 lessons and every finding was fixed.
- Vocabulary: every active lesson in `content/lessons/language-proficiency/vocabulary/` that contains a `:::` block (29; 22 English, 7 Filipino). Never audited by Codex; verified twice by Claude verifiers.

Lead's checks at `fabe161e7` (already run, do not rerun): the app's walk-through parser passes all 191 walk-through lessons; `lesson_checks.dart` from `tools/walkthrough-checks-r1` reports 0 violations for both topics (size, split coverage, pool, trap-pair evidence for every pair, example connection). Question files for both topics are unchanged since `a7cc22b6b` except `q-vocabulary-spelling-rules-0012` (fixed and approved earlier).

Standard to audit against (all of these):
1. Aedwon's example rule (verbatim, Nov 26): "notice what's missing here? there was not enough context given here. where's the expression from? ... the lessons should be clearly assisting the user to understand logic" / "for example: you could say, Let's substitute x=-2 to the terms 3x x^2 and 12/x, and that would be clearer" / "no that's too wordy now, you just made it wordy. i wanted you to connect things better, not explain with more words. those are entirely different asks" / on the target "Let's substitute x = -2 into 3x, x^2 and 12/x:" followed by each chain to its value: "yes that's it!". With sentences: one short lead-in naming what we do and to what; each chain ends at its finished sentence; no narration. Flag missing connections AND added wordiness.
2. Every rule and answer true and scoped: English per Cambridge, British Council, Purdue OWL, Merriam-Webster; Filipino per KWF and Ortograpiyang Pambansa 2013. A list that reads as complete but is not, or a rule with an unstated exception, is a finding.
3. Fresh instances: every `:::check` and `:::try` tests a rule the lesson taught, on a word or sentence not already worked or stated earlier in the lesson (as the sample checks "My sister (teach / teaches)" after teaching "The dog barks"). No visible step, stem phrase or heading gives the answer away or leaves it by elimination. Each try's `**Check:**` is inside its `:::answer`.
4. Every `:::pair` Wrong line shows the mistake of a non-correct choice cited for that pair in `content/walkthrough-trap-evidence.json`, from a question whose `lesson:` is that lesson.
5. Filipino lessons: simple Filipino, no Taglish, a short English gloss for a hard grammar term at its first use in teaching prose only (Aedwon's Oct 4 decision; not in headings, stems, example sentences, Right/Wrong lines or checklists; no cognate-only glosses such as aspekto (aspect)).
6. Grade 5 English in lesson prose, American spelling, no em or en dashes.

Format: `Severity | file:line | problem | fix`, Blocker (false rule or answer, answer given away, broken structure), Major (missing connection, citation mismatch, misleading wording, wordiness, reused instance), Minor (style). Group by topic. For Grammar, first list each round 3 finding as closed or not in one line each.

End `gv-r4.md` with two verdict lines, `GRAMMAR VERDICT: PASS` or `GRAMMAR VERDICT: FAIL (N Blockers, M Majors, K Minors)` and the same for `VOCABULARY VERDICT`, then `STAGE-DONE`. PASS means zero Blockers and zero Majors.

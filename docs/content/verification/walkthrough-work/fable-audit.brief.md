# Walk-through audit (Claude Fable 5.2 high, read-only), session 3

Manager ruling (Nov 26): Codex account b is at 98% weekly, so Fable 5.2 high audits replace Codex until Monday Nov 30's reset; Codex re-audits every Fable-passed batch after that. This brief is the Codex round 5 brief (`codex-grammar-r5.brief.md`) adapted; the standard is the same.

Startup: Work on `Aedwon/Pantas`. Read `AGENTS.md`, `WORKFLOW.md` and `docs/workflow/process-improvement.md` from `origin/main` (`git show origin/main:<path>`). Read the spec `git show origin/main:docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md` (Part B), the Filipino section of `git show origin/main:docs/content/lesson-style-guide.md`, the lane's rules `docs/content/verification/walkthrough-work/worker-rules.md`, the pattern checklist `docs/content/verification/walkthrough-work/pattern-checklist.md`, and the approved sample `git show origin/tools/walkthrough-checks-r1:docs/content/walkthrough-samples/finding-subjects-and-matching-verbs.md`.

Hard rules:
- Do not start subagents; do the work yourself.
- READ-ONLY on the repository except your one report file (below), written with the Write tool. Never edit a lesson.
- Bash only for plain read-only commands: grep, ls, cat, git show, git diff, git status, git log, date. No `>` or `>>` redirection, no scripts, no loops. Run no dart or flutter.
- Append to your report after each lesson you finish (rewrite the whole file with Write each time), so a stopped run keeps its work. No em dashes.

Target: worktree `/Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1`, branch `content/lesson-walkthrough-cse-r1`, at the commit named in your task. Lessons and questions folders are named in your task.

History: the earlier audit report for your topic is named in your task. Since then every finding was fixed or rejected with a reason, and a five-pattern sweep (P1 to P5) went over every check, try, chain, pair note, why, shortcut and checklist line.

Lead's checks at the target (already run, do not rerun): the app's walk-through parser passes every lesson; no lesson's pre-tap word count grew; `lesson_checks.dart` results are in your task.

Standard to audit against (all of these):
1. Aedwon's example rule (verbatim, Nov 26): "notice what's missing here? there was not enough context given here. where's the expression from? ... the lessons should be clearly assisting the user to understand logic" / "for example: you could say, Let's substitute x=-2 to the terms 3x x^2 and 12/x, and that would be clearer" / "no that's too wordy now, you just made it wordy. i wanted you to connect things better, not explain with more words. those are entirely different asks" / on the target "Let's substitute x = -2 into 3x, x^2 and 12/x:" followed by each chain to its value: "yes that's it!". With sentences: one short lead-in naming what we do and to what; each chain ends at its finished sentence; no narration. Flag missing connections AND added wordiness.
2. Every rule and answer true and scoped: English per Cambridge, British Council, Purdue OWL, Merriam-Webster; Filipino per KWF and Ortograpiyang Pambansa 2013 (Schachter and Otanes for grammar). A list that reads as complete but is not, or a rule with an unstated exception, is a finding. Judge scope at a Grade 5 lesson's level: a short scope word ("usually", "in this lesson", "such as") is enough; do not ask for exception lists.
3. Fresh instances: every `:::check` and `:::try` tests a rule the lesson taught, on a word or sentence not already worked or stated earlier in the lesson. It has exactly one defensible answer. No visible step, stem phrase, heading or just-printed list gives the answer away or leaves it by elimination. Each try's `**Check:**` is inside its `:::answer`. Answers end at the finished sentence, not a letter or label.
4. Every `:::pair` Wrong line shows the mistake of a non-correct choice cited for that pair in `content/walkthrough-trap-evidence.json`, from a question whose `lesson:` is that lesson. (Where the task says citations are held in a `walkthrough-work/*.json` file instead, check that file.)
5. Filipino lessons: simple Filipino, no Taglish, a short English meaning gloss for a hard grammar term at its first use in teaching prose only (Aedwon's Oct 4 decision; not in headings, stems, example sentences, Right/Wrong lines or checklists; no cognate-only glosses such as aspekto (aspect)).
6. Grade 5 English in lesson prose, American spelling, no em or en dashes.

Be a strict auditor but a fair one: a finding must name a real student harm (a false rule, a wrong or doubled answer, a give-away, a missing connection, real wordiness). Do not raise taste preferences as Majors.

Format: `Severity | file:line | problem | fix`, Blocker (false rule or answer, answer given away, broken structure), Major (missing connection, citation mismatch, misleading wording, wordiness, reused instance), Minor (style). First list each finding of the earlier report that is still open, one line each (skip closed ones).

End the report with `VERDICT: PASS` or `VERDICT: FAIL (N Blockers, M Majors, K Minors)`, then `STAGE-DONE`. PASS means zero Blockers and zero Majors.

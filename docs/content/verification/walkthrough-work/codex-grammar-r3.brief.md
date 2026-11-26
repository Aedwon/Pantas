# Batch 3 Grammar and Structure, round 3 audit (Codex GPT 6.2 Sol high, read-only)

Startup: Work on `Aedwon/Pantas`. Read `AGENTS.md`, `WORKFLOW.md` and `docs/workflow/process-improvement.md` from `origin/main` (`git -C <worktree> show origin/main:<path>`), policy commit `650eda378`. Read the spec `git show origin/main:docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md` (Part B) and the Filipino section of `git show origin/main:docs/content/lesson-style-guide.md`.

Hard rules:
- READ-ONLY on the repository. Never edit, stage or commit anything under `/Users/aedwon/.t3/worktrees/Pantas/`. Do not run dart or flutter.
- Write your findings incrementally to `batch3-r3.md` in your working directory (this folder). No em dashes in it.
- Keep scope tight to conserve quota: the items below, plus a regression read of the changed lessons only.

Target: worktree `/Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1`, branch `content/lesson-walkthrough-cse-r1`, commit `3c6add9c1`. Changes since your round 2 target: `git diff a5dea5097 3c6add9c1 -- content/lessons/language-proficiency/grammar-and-structure/` (19 lessons).
Your round 2 report: `gemini/batch3/codex-audit-batch3-r2.md` (in this folder).

Lead's checks at `3c6add9c1` (already run, do not rerun): the app's walk-through parser passes all 191 walk-through lessons; `lesson_checks.dart` from `tools/walkthrough-checks-r1` `b8640b532` reports 0 violations for Grammar and Structure (size, split coverage, pool, trap-pair evidence, example connection).

**Correction to round 1 and 2:** your round 1 asked to delete every English gloss in the Filipino lessons, and round 2 praised their removal. That was wrong. Aedwon's decision (Oct 4, 2026, option 1) and the style guide require a short English gloss for a hard grammar term at its first use in teaching prose, then the Filipino term alone. The glosses are restored. Audit them against that rule: one per hard term per lesson, at first teaching use, never in headings, quiz stems, example sentences, Right/Wrong lines or checklist lines, no common words or obvious cognates.

Aedwon's example rule (verbatim, Nov 26): "notice what's missing here? there was not enough context given here. where's the expression from? ... the lessons should be clearly assisting the user to understand logic" / "for example: you could say, Let's substitute x=-2 to the terms 3x x^2 and 12/x, and that would be clearer" / "no that's too wordy now, you just made it wordy. i wanted you to connect things better, not explain with more words. those are entirely different asks" / on the target "Let's substitute x = -2 into 3x, x^2 and 12/x:" followed by each chain to its value: "yes that's it!". With sentences: one short lead-in naming what we do and to what, each chain ends at its finished sentence, no narration. Flag both missing connections and added wordiness.

Scope:
1. Each of your 15 round 2 findings: closed or not, with the quoted line.
2. Read each of the 19 changed lessons in full as a student who has never seen it. Check: every rule true (English: Cambridge, British Council, Purdue OWL; Filipino: KWF and Ortograpiyang Pambansa 2013); every new :::try sentence is fresh, natural, correctly answered, with its Check inside :::answer, and no earlier text or visible step gives its answer away; connection and wordiness as above; first-use glosses as above; no Taglish in Filipino teaching prose.
3. Every :::pair in the 19 lessons: its Wrong line shows the mistake of a non-correct choice cited for that pair in `content/walkthrough-trap-evidence.json`, from a question whose `lesson:` is that lesson.
4. One change to rule on: `pokus-at-papel-ng-paksa.md` removed `-an` from its object-focus affix list because `ugnayan-ng-pandiwa-at-paksa.md` uses `-an` verbs for ganapan and direksiyon. Say whether the lesson is now false, incomplete in a way that misleads, or acceptable, and cite your source.
5. Question files unchanged: `git diff a7cc22b6b 3c6add9c1 --stat -- content/questions/language-proficiency/grammar-and-structure/` is empty.

Classify each finding Blocker (false rule, wrong answer, answer given away, broken structure), Major (missing connection, citation mismatch, misleading wording, wordiness), or Minor (style). Format: `Severity | file:line | problem | fix`.

End `batch3-r3.md` with `VERDICT: PASS` or `VERDICT: FAIL (N Blockers, M Majors, K Minors)`, then `STAGE-DONE`. PASS means zero Blockers and zero Majors.

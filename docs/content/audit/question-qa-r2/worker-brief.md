Work on `Aedwon/Pantas`. Read policy first and record the SHA: `git show origin/main:AGENTS.md`, `git show origin/main:WORKFLOW.md`, `git show origin/main:SUBAGENTS.md` (all three in full). Main receives documentation-only commits while you work; a newer main is not a stop condition.

You are the content implementor for ONE subject group of the question audit and expansion (question QA round r2). Approved by Aedwon on 1 October 2026; record: `git show origin/main:docs/superpowers/decisions/2026-10-01-question-explanations-log.md`.

- Worktree (the only place you may write): __WT__, branch __BR__. Never write anywhere else. Two other Codex instances work on other subjects in other worktrees at the same time; do not touch their subjects.
- Your subjects (the only question files you may change or add): __SUBJECTS__ under `content/questions/`.
- Your ledger directory: `docs/content/audit/question-qa-r2/<subject>/<topic>/<lesson>.tsv` for your subjects only, plus a summary `docs/content/audit/question-qa-r2/__GROUP__-summary.md`.
- Do not change application code, tools, tests, lessons, `assets/seed`, or any file outside the above.

## Rules (read in full before writing)

- `git show origin/main:docs/content/question-style-guide.md` (updated 1 October: explanation rule, required wrong-choice notes and their shape, no position-dependent choices, ids never renumbered, at least 20 active questions per lesson).
- `git show origin/main:docs/content/question-authoring-runbook.md` and `git show origin/main:docs/content/question-blueprints/<subject>.md` for each of your subjects (archetypes, distractor sources; the style guide wins where an example conflicts).
- AGENTS.md "Voice" and "Maths in content" sections (`\dfrac`, no em dashes, American spelling, "points" not "marks").
- The lesson each question belongs to: its file under `content/lessons/` (find it by the lesson slug in the question file's `meta.subtopic`). Read the lesson before working on its questions.

## Work, lesson by lesson

First run `git status`. Uncommitted changes are an interrupted lesson from an earlier pass (a usage limit can stop a pass mid-lesson): read them, finish that lesson to the rules below, and commit it before starting another. Then process one lesson file at a time, fully, then write its ledger, then move to the next. Before starting a lesson, check whether its ledger already exists with every row complete; if so, skip it (this lets a rerun resume), except: for any `NEEDS AEDWON` row in it, make sure that question's explanation, wrong-choice notes and formatting meet the rules below, and fix them if not.

### 1. Audit every existing question

For each question:
1. **Answer key:** solve or answer it yourself from the stem alone before looking at the marked answer. If yours differs, find out which is right; fix the key, the stem, or the choices so exactly one answer is correct.
2. **One defensible answer:** no wrong choice can be argued correct by a careful student. Fix if one can.
3. **Distractors:** each wrong choice is plausible and comes from a real mistake or misconception for this topic. Replace throwaway, unrelated, joke, or obviously wrong choices with mistake-based ones. No "All of the above", "None of the above", "Both A and B", or choice text naming another choice by letter or position (the app shuffles choices).
4. **Lesson fit and exam realism:** the question tests what its lesson teaches, in realistic target-exam wording (do not simplify the stem or choices to Grade 5). If it tests something the lesson does not teach, record it in the ledger with status `NEEDS AEDWON`, keep its stem, choices and key as they are, and still apply every other rule to it (answer-key check, explanation, wrong-choice notes, formatting).
5. **Explanation:** rewrite so it says only why the correct answer is correct, with the worked solution step by step when solving is involved, in plain English a Grade 5 student can understand, without losing accuracy. Remove every mention of wrong choices from it.
6. **Wrong-choice notes:** every wrong choice has a `rationale` in the style guide's shape: the specific mistake, why it looks right, one check to avoid it. Written about the choice, not the student (no "You picked"), so it reads correctly both for a student who picked it and in a list. Never restate the full solution. Rewrite existing notes that do not fit; add missing ones. The correct choice has no note.
7. **Formatting:** maths between single dollars, `\dfrac` never `\frac`, numbers in choices quoted per the style guide's YAML rules, no em dashes, American spelling.
8. **Duplicates:** no near-duplicate of another question in the lesson or your subjects (same scenario with swapped numbers counts). Rewrite one of them into a different scenario or framing.

Never change an existing question's `id`. Keep `approved` as it is for existing questions.

### 2. Expand to at least 20 active questions

Count active questions in the lesson (a question with `figure:` is not active and does not count). Add new questions until there are at least 20. New questions:
- cover the blueprint archetypes the lesson is thinnest on, ramp from easy to exam level, and differ in scenario or framing from every existing question;
- take the next unused ids in the file (`q-<topicSlug>-<subtopicSlug>-NNNN`), never reusing or renumbering;
- follow every audit rule above (solve first, one defensible answer, mistake-based distractors, solution-only explanation, a note on every wrong choice);
- set `approved: false`;
- count as active only if the importer emits them with `isActive: true`.

**Lead rulings (1 October 2026), these override the blueprint where they differ:**
- **Figures.** A question with `figure:` AND a `figureSpec` the app can draw is active and counts; one with `figure:` and no `figureSpec` is figure-pending, inactive, and does not count. In figure-dependent lessons (Spatial-Abstract and Mechanical-Technical Reasoning, and any other lesson whose existing questions use `figureSpec`), new questions use a `figureSpec` of a kind that already exists in the bank (cube-net, figure-matrix, figure-series, fluid-vessel, gear-train, lever-balance, paper-fold, pulley-system, shape-row, spring-scale, stability-shape), in exactly the field shape existing questions use. Before writing one, read the renderer for that kind under `lib/core/ui/figures/` (read only) to confirm every field and value you use is supported. Never invent a new kind or field, never leave a new question figure-pending, and never replace a figure with a prose description of it where the blueprint forbids that. If a lesson cannot reach 20 within these limits, stop adding to that lesson, and list it with its count and the reason in the summary.
- **General Information has no blueprint.** Use the style guide, the lesson, and the `type` values its existing questions already use as the archetype vocabulary. Do not write a blueprint.
- **Missing blueprint or similar gaps are not stop conditions for this job.** Apply the closest written rule, note the gap in the summary, and continue.

### 3. Ledger row per question

`docs/content/audit/question-qa-r2/<subject>/<topic>/<lesson>.tsv`, header:
`question_id	status	key_check	changes	severity	note`
- status: `VERIFIED` (no change needed beyond explanation/notes reshaping), `CORRECTED` (key, stem, choices or distractors changed), `NEW`, or `NEEDS AEDWON`.
- key_check: `SOLVED-MATCH`, `SOLVED-FIXED` (key was wrong and is fixed), or `NEW`.
- changes: short list, e.g. `explanation;notes;distractor C`.
- severity of what you found before fixing: `NONE`, `LOW` (wording), `MEDIUM` (weak distractor, unclear stem), `HIGH` (wrong key, two defensible answers, wrong fact).
- note: one line on what was wrong, required for anything above NONE.

### 4. Validate after each lesson

Run `dart run tools/import_questions/import_questions.dart --root content/questions > /dev/null` and require exit 0 (it validates the whole bank; fix any error in your files; if an error is in another group's subject, ignore it and note it). Then check: every wrong choice in the lesson has a non-empty `rationale`; active count >= 20; no `\frac` without `d`; no em dash (U+2014).

Commit after each completed lesson (its YAML and ledger only) with a message saying why, e.g. "content: audit and expand <lesson> questions". No attribution trailer or marker of any kind. Do not push, merge, or touch other branches.

## Finish

When every lesson in your subjects has a complete ledger and passes validation, write the summary file: lessons done, questions audited, new questions added, counts by status and severity, every HIGH finding listed with its id and one line, every NEEDS AEDWON item, and the final per-lesson active counts (all must be >= 20). Commit it. Then report per SUBAGENTS.md Part 7 with pasted command output.

Do not stop early to ask for confirmation between lessons; this is a long, mechanical-but-careful job and Aedwon has approved it in full. Stop only for a SUBAGENTS.md Part 6 stop condition or if a rule here contradicts the policy files. If you run low on context, finish and commit the current lesson first; a rerun resumes from the ledgers.

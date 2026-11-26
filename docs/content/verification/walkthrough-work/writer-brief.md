# Writer brief: rewrite a CSE lesson to the walk-through standard

First read the rules file in full and follow it exactly:
/Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1/docs/content/verification/walkthrough-work/worker-rules.md

- Do not start subagents; do the work yourself.
- Change files only with the Edit or Write tool, scratch files included. Bash only for plain read-only commands (grep, ls, cat, git diff/status/log/show, date). No `>` or `>>` redirection, no sh, python or perl scripts, no zsh array or loop tricks, not even in scratch folders. Run no checks; the lead runs the importer and word counts.
- Edit only the lesson files your task names. Never edit question files or `content/walkthrough-trap-evidence.json`.

Read first, in full:
- The spec, Part B "Authoring rules" and "Markup": `git show origin/main:docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md`.
- The approved grammar sample: `git show origin/tools/walkthrough-checks-r1:docs/content/walkthrough-samples/finding-subjects-and-matching-verbs.md`. Match its shape.
- Two finished, audited lessons from a sibling topic for shape: `content/lessons/language-proficiency/grammar-and-structure/commas-with-openings-and-extra-information.md` and (Filipino) `content/lessons/language-proficiency/grammar-and-structure/pokus-at-papel-ng-paksa.md`.
- Your lesson as it is now, and every question whose `lesson:` is its `_id` (grep under `content/questions/`). The quiz bank is the source of the lesson's skills and of its trap pairs.

Shape of each rewritten lesson:
1. Front matter: keep every field and value exactly as it is (`_id`, title, summary, part, partCount, ordering, keyPoints). Do not add or remove fields.
2. `## Core Concept`: one `###` per rule (follow the keyPoints). Under each: the rule in plain words, then at least one worked sentence or set right under it, one move per line, ending at the finished sentence; `:::why` only for extra reasoning (1 to 3 sentences, optional); a `:::check` (one question, fresh instance, answer starts with the result and one-line reason). Gloss an exam instruction word the first time it appears.
3. Traps at their step: 2 or 3 `:::pair #slug` blocks in the whole lesson, each at the step where the slip happens, each matching a real non-correct choice of a question linked to this lesson. Lines: `Right:`, `Wrong:`, then one or two sentences naming the slip. A slip with no matching wrong choice gets no pair.
4. `## Examples`: 2 to 4 worked examples `### #1: <neutral title>`. Stem at real exam wording and difficulty, with no method hints. One short lead-in or a `**Solution:**` with numbered steps, one move per step, ending at the finished answer. Every example ends with `**Check:**` (a second way or a sense check). The LAST example's final step is a `:::try` with `:::answer`, and its Check goes inside the answer. Example stems must not copy quiz stems; write fresh ones at the same level.
5. `## Traps to Watch For`: only a `:::checklist` of 2 or 3 lines, each `- Cue: right move (result). {#slug}` where slug is a pair id or a `###` heading slug (lowercase, hyphens). Every former trap in the old lesson moves to a pair or a checklist line; none is dropped.
6. Keep any old teaching that is correct. Content is moved and tightened, not cut. Remove old sections that the new shape replaces (old trap lists, mnemonics sections that are really methods: fold those into Core Concept).
7. Size: pre-tap words (outside `:::answer`, `:::why`, HTML comments, front matter) between 150 and 900. If a lesson cannot fit, stop and tell the lead; do not split.
8. Optional figure: `<!-- ILLUSTRATION: ... -->` at the exact spot, only where a picture shows a relation words carry poorly.
9. Filipino lessons: everything in the rules file's Filipino section.

Then reread each lesson in full as a student who has never seen it: rules 5, 5a, 5b and 7 for every check and try; every example connected and ending at its finished sentence; nothing wordy; every rule true.

Report under 600 words: per lesson pre-tap word count, number of pairs, anything unresolved; importer output; and a JSON block of every pair's citations in this exact shape:
{"<lesson _id>": {"<pair slug>": [{"questionId": "...", "wrongChoice": "<exact text from the YAML>", "mistakeNote": "<one line>"}]}}

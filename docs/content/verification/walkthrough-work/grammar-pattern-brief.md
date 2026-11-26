# Grammar pattern sweep brief (session 3, manager ruling 1)

You are a content worker (fixer). Lead: Claude lesson lead (E-198). Read in full, in this order, and follow exactly:
1. `docs/content/verification/walkthrough-work/worker-rules.md` (the standard and the hard limits; the hard limits bind you).
2. `docs/content/verification/walkthrough-work/fixer-brief.md` (method).
3. `docs/content/verification/walkthrough-work/pattern-checklist.md` (P1 to P5).
4. The audit report for your topic: Grammar `docs/content/verification/walkthrough-work/codex-grammar-r5.md` (every row naming one of your lessons, including the "Open round 4 findings" at the top); Vocabulary `docs/content/verification/walkthrough-work/codex-vocab-r2.md` (every row naming one of your lessons). Below, "round 5 row" means a row of your topic's report, and the questions folder is your topic's folder under `content/questions/language-proficiency/`.
5. The approved sample: `git show origin/tools/walkthrough-checks-r1:docs/content/walkthrough-samples/finding-subjects-and-matching-verbs.md`.

Hard limits in short: no subagents; files only with Edit or Write; Bash only for plain read-only commands (grep, ls, cat, git show, git diff, git status, git log, date), no redirection, no scripts, no loops; run no checks; no git writes. Edit only your assigned lessons. Never edit question files or `content/walkthrough-trap-evidence.json`.

The job is a sweep by pattern, not a list of fixes. Round 4 and round 5 each found a new layer because fixes covered the named line only. For each lesson:
1. Read it in full, and its questions (grep its `_id` as `lesson:` under `content/questions/language-proficiency/grammar-and-structure/`).
2. Fix every round 5 row for it. Verify each claim against the references in rule 7 first; if a row is wrong, do not apply it and say why in one line.
3. Then go through EVERY `:::check`, `:::try`, worked chain, `:::pair` note, `:::why`, Speed Tricks line and `:::checklist` line, and apply P1 to P5 to each. P5 means: when you change a rule, grep the lesson for every restatement and fix them all in the same pass.
4. Keep pre-tap words (outside `:::answer`, `:::why` and HTML comments) from growing: offset each addition with a cut in the same lesson. Scope words are short ("usually", "here", "in this kind of sentence"); no exception lists.
5. If a pair's Wrong line changes so that its cited choice no longer fits, tell the lead the exact entry (lesson id, slug, questionId, wrongChoice) and the replacement you propose, quoted exactly from the YAML.

Report under 700 words: per lesson, one line per round 5 row (fixed how, or rejected why), then P1 to P5 extra changes (one line each), words added and cut, evidence changes needed. Anything you could not resolve goes to the lead; do not guess.

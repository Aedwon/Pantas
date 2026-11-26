# Verifier brief: CSE lesson walk-through rewrite

You are an independent verifier. You did not write the lessons you check. First read the rules file in full; it defines the standard:
/private/tmp/claude-501/-Users-aedwon--t3-worktrees-Pantas-content-lesson-walkthro-85719f9d9f054ca1/ccba2862-baef-455a-a40a-1db609b1af35/scratchpad/worker-rules.md

- Do not start subagents; do the work yourself.
- READ-ONLY: do not edit any file in the repository. Bash for read-only commands only. Scratch notes or arithmetic scripts only under your own folder in the scratchpad, written with the Write tool, run with `python3 -I`. Never run dart or flutter anywhere except the importer runner in its own directory (pass lesson paths as separate arguments, for example with xargs). Never run any tool with its working directory inside the repository's `content/` folder.
- Worktree: /Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1. Other workers may be editing other folders; ignore them.

For each lesson in your list, read the whole file line by line as a student who has never seen it, and read its questions (grep `lesson: "<_id>"` or `lesson: <_id>` under `content/questions/`). Check:
1. Every rule and every answer is true. English usage: Cambridge, British Council, Purdue OWL, Merriam-Webster. Filipino: KWF and Ortograpiyang Pambansa 2013. Math: recompute every number. General Information: check each fact against the primary text (Constitution, RA text) named in the lesson or question; flag any fact you cannot trace.
2. Connection rule: each worked example opens with one short lead-in naming what we do and to what; each chain starts from its source (expression, sentence, passage line, provision) and ends at its value or finished sentence. Flag missing connections. Flag added narration and wordiness just as hard: connection, not more words.
3. No visible step, earlier pair, check or Right line gives away a :::try or :::check answer. Each try's `**Check:**` sits inside its :::answer.
4. Every :::pair: its Wrong line shows the mistake of a non-correct choice cited for that pair in `content/walkthrough-trap-evidence.json`; the cited choice text exists exactly in a question whose `lesson:` is that lesson. Check every pair, not a sample.
5. Filipino lessons: simple Filipino teaching prose, no Taglish, first-use English gloss for each hard grammar term (once, at first teaching use, never in headings, stems, example sentences, Right/Wrong lines or checklist lines).
6. Style: Grade 5 English in lessons, American spelling, no em or en dashes, `\dfrac` not top-level `\frac`, no ALL-CAPS emphasis, no stock AI phrasing.
7. Run the importer runner on your files and paste its output line.

Report: verdict PASS or FAIL; one line per lesson (OK, or its findings); findings as `Severity | file:line | problem | fix`. Blocker: false rule or fact, wrong answer, answer given away, parse failure. Major: missing connection, citation mismatch, misleading wording, added wordiness. Minor: style. Under 700 words. No praise.

# Grammar round 6 fix brief (manager-approved method, Nov 27)

You are a content worker (fixer) for the Claude lesson lead (E-198). Read in full and follow exactly, in this order:
1. `docs/content/verification/walkthrough-work/worker-rules.md` (the standard and the hard limits; the hard limits bind you).
2. `docs/content/verification/walkthrough-work/fixer-brief.md` (method) and `pattern-checklist.md` (P1 to P5).
3. `docs/content/verification/walkthrough-work/codex-grammar-r6.md`: every row naming one of your lessons, both under "Open round 5 findings" and "Round 6 findings". Skip rows on `.yaml` question files (they go to the question owner).
4. `docs/content/verification/walkthrough-work/missing-example-checks.md`: every line naming one of your lessons.

Hard limits in short: no subagents; files only with Edit or Write; Bash only for plain read-only commands (grep, ls, cat, git show, git diff, git status, git log, date), no redirection, no scripts, no loops, not even in scratch folders; run no checks (the lead runs the parser, word counts and lesson checks); no git writes. Edit only your assigned lessons. Never edit question files or `content/walkthrough-trap-evidence.json`.

Why this round is different: round 6 found more than round 5 (81 Blockers, 102 Majors) for two causes. Earlier workers cut required Check lines to keep word counts down, and free sweeping edits created new defects (a try asking about a word the example no longer had). So:
- Change only what a row names, plus every restatement of the same rule in the same lesson (P5: grep the lesson for the rule's other statements in pair notes, Why, Speed Tricks, shortcut and checklist). No other edits.
- Verify each row first (Cambridge, British Council, Purdue OWL, Merriam-Webster; Filipino: KWF, Ortograpiyang Pambansa 2013, Schachter and Otanes). If a row is wrong, do not apply it; say why in one line.
- Every worked example (each `###` under `## Examples`) ends with a `**Check:**` line: a second method or a sense check, never a restatement of the step above. In a `:::try` example the Check sits inside the try's `:::answer`. Restore each missing one. A Check is required even when it costs words.
- Word budget: no lesson above its count before the sweep (`git show 518404ccd^:<path>`; pre-tap words, outside `:::answer`, `:::why` and HTML comments; estimate by reading). Offset additions with cuts of lines a reader would not miss. Never cut a required Check, a lead-in, a finished sentence or the meaning at the end of a chain.
- When you replace a check or try instance, make sure every later line that names the old instance (steps, answer, Check, pair, checklist) names the new one.
- Option lines separated by blank lines; one level of emphasis; every block fence on its own line.
- If a pair's Wrong line must change so that its cited choice no longer fits, give the exact evidence entry and the replacement, quoted from the YAML.

Report under 700 words: per lesson, one line per row (Fixed how / Rejected why), Checks restored (heading), words added and cut, evidence changes needed. Anything unresolved goes to the lead; do not guess.

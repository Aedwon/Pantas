# Grammar round 8 fix brief (session 5, Nov 27, E-198)

You are a content worker (fixer) for the Claude lesson lead. Policy read by the lead: `origin/main` `3fd9fdf0e`. Read in full and follow exactly, in this order:
1. `docs/content/verification/walkthrough-work/worker-rules.md` (the standard and the hard limits; the hard limits bind you).
2. `docs/content/verification/walkthrough-work/fixer-brief.md` (method) and `pattern-checklist.md` (P1 to P5).
3. `docs/content/verification/walkthrough-work/grammar-r6-fix-brief.md`: its rules all still apply (rows only plus P5 restatements, verify each row first, every example keeps a `**Check:**`, word budget, renamed instances followed through, format rules). This file adds to it.
4. `docs/content/verification/walkthrough-work/codex-grammar-r8-full.md`: every row naming one of your lessons, under "Open round 6 or round 7 findings" and "Full-read findings by lesson". Skip the `.yaml` row (it goes to the question owner).

Hard limits in short: no subagents; files only with Edit or Write; Bash only for plain read-only commands (grep, ls, cat, git show, git diff, git status, git log, date), no redirection, no scripts, no loops, not even in scratch folders; run no checks; no git writes. Edit only your assigned lessons. Never edit question files or `content/walkthrough-trap-evidence.json`. Another worker may change `<!-- ILLUSTRATION:` to `<!-- FIGURE WANTED:` on one line of some of your files: leave those comment lines alone, and never undo that change.

Round 8 notes (what the full read keeps finding; get each right the first time):
- A `**Check:**` must confirm the result a different way: reread the finished sentence with a swap, test the wrong form and show what breaks, compare meaning. It never repeats the step just above it, the answer's reason, or a fact the stem gave. This is the largest class in round 8.
- A new check or try instance must be new to the whole lesson: not a sentence, verb group, cue word (*last Saturday*, *lang*, *pa*), pair or pattern already worked in the core, a pair, an example or an earlier check.
- No giveaway: the stem must not print the keyed word or a phrase only one choice repeats; a visible step must not resolve what the try asks; a heading must not name the category asked for; the right choice must not be the only one that fits a visible marker (*si*, *ni*, *its*).
- Exactly one defensible answer: if two forms are grammatical (respectful *inyo* and familiar *iyo*, *sa akin* and *sa 'kin*, *at* and *ngunit*), the stem supplies the fact that decides it.
- First-use English gloss for a hard Filipino term goes in the first visible teaching prose, never first inside a hidden `:::why` or a pair note.
- Pronouns for a named person: do not assign *he* or *she* unless the passage does; use the name or "the person".
- Isolating a dependent group: show it in brackets or inside the sentence, never with a full stop.
- If you think a row is wrong, do not apply it; give a one-line reason with a source. The lead rules on it.

Report under 700 words: per lesson, one line per row (Fixed how / Rejected why), words added and cut, evidence changes needed (exact YAML quotes). Anything unresolved goes to the lead; do not guess.

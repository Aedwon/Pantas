# Language Application Codex round 3 fix brief (session 5, Nov 27, E-198)

You are a fixer for the Claude lesson lead. Policy read by the lead: `origin/main` `0234382b8`. Read in full and follow, in order:
1. `docs/content/verification/walkthrough-work/worker-rules.md` (standard and hard limits: Edit tool only, Bash read-only, no redirection, no scripts, no git writes, no subagents, run no checks).
2. `docs/content/verification/walkthrough-work/pattern-checklist.md` (P1 to P5), and `docs/content/verification/walkthrough-work/la-precheck-fix-brief.md` (the lead ruling on word-specific facts, rules 1 to 5 and 2a).
3. `docs/content/verification/walkthrough-work/codex-la-r3-full.md`: every row naming one of your lessons. Skip the `.yaml` row (it goes to the question owner).

What this round must get right:
- **Rules stated too broadly are the main class (most Blockers).** For each such row, find the rule and EVERY restatement of it in the lesson (core, pair note, Why, Speed Tricks, shortcut, checklist; grep its key words) and scope all of them the same way in the same pass (P5). A short scope phrase is enough: "an opening time, reason or condition clause", "here", "in these sentences", "usually". Do not add exception lists. Check against Cambridge, British Council, Purdue OWL, Merriam-Webster; Filipino against KWF, Ortograpiyang Pambansa 2013, Schachter and Otanes.
- Filipino aspect: a past time word (*kahapon*, *kanina*) does not prove a completed action. Any item that keys a completed form must carry a completion cue (*natapos*, *na*, a result), and any rule saying otherwise gets scoped.
- **A `**Check:**` confirms the answer a different way** (reread the finished sentence with a swap, test the wrong form and show what breaks). It never repeats the step above, the answer's reason, or a fact the stem gave.
- **Chains and answers end at the finished sentence or full statement**, never at a letter or label alone.
- A rewritten check or try changes its setup, not only its words. Exactly one defensible answer; the key never appears above it.
- Rows you think are wrong: do not apply; give a one-line reason with a source.

Limits: change only what a row names, plus every restatement (P5). Do not touch `:::pair` Right/Wrong lines unless a row requires it; if you do, the cited mistake in `content/walkthrough-trap-evidence.json` must still fit, and you report the evidence change needed (exact YAML quote). Manager ruling: no lesson may grow by more than 20 pre-tap words against `3cf5cf08e`, growth only inside rewritten checks and tries or a needed scope phrase, no narration, at or under 900. Several lessons already grew up to 17: offset growth by cutting a line a reader would not miss, never a Check, a lead-in or a finished sentence. Option lines are separated by blank lines. Do not touch `<!-- FIGURE WANTED:` lines.

Report under 700 words: per row, fixed how (one line); rejected rows with reasons; words added and cut per lesson; evidence changes needed; files touched.

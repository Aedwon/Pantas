# Math pre-check fix brief (session 5, Nov 27, E-198)

You are a fixer for the Claude lesson lead. Policy read by the lead: `origin/main` `0234382b8`. Read in full and follow, in order:
1. `docs/content/verification/walkthrough-work/worker-rules.md` (standard and hard limits: Edit tool only, Bash read-only, no redirection, no scripts, no git writes, no subagents, run no checks), and `AGENTS.md` "Maths in content" (`\dfrac`, single dollars).
2. `docs/content/verification/walkthrough-work/pattern-checklist.md` (P1 to P5).
3. `docs/content/verification/walkthrough-work/la-precheck-fix-brief.md`, "Lead ruling on word-specific facts" rule 3 (a check must not copy the frame of the demo or pair right above it with only the numbers swapped).
4. `docs/content/verification/walkthrough-work/math-precheck-findings.md`: every row in your lessons.

Required step from main (process-improvement entry "Grammar walk-through lessons fail every Codex audit round (Nov 27)"): for each flagged item, rewrite the WHOLE Quick Check or try: a fresh number set AND a changed setup (a different unknown, a different order of givens, a different context, or a two-step version), so that it is not the demo above with new numbers. Recompute every number you write, twice, by different methods. Exactly one defensible answer: if two forms are correct (an equation written two ways), the question must say which form it wants, or accept both in the answer. The key must never appear in the stem or anywhere above the item. Keep each try's `**Check:**` inside its `:::answer`; the Check confirms the result a different way.

Already fixed by the lead (do not change): `data-interpretation/chart-scales-and-differences.md` Example 1 now matches the drawn chart (Factory A 440, answer 120), and its core tick example is now $200+3\times20=260$. Its Check 2 row is still yours.

Limits: change only the flagged items, plus every line that names the old instance (steps, answer, Check, pair, checklist) and every restatement (P5). Do not touch `:::pair` Right/Wrong lines unless a row requires it; then the cited wrong choice in `content/walkthrough-trap-evidence.json` must still fit. Manager ruling: a lesson may grow by at most 20 pre-tap words, only inside rewritten checks and tries, no new narration, and stay at or under 900. Never cut a required Check, a lead-in, or a final value. Do not touch `<!-- FIGURE WANTED:` or `<!-- ILLUSTRATION:` lines, and never edit SVG files.

Report under 600 words: per row, fixed how (one line, with the new key); rows you think are wrong, with a reason; words added and cut per lesson; files touched.

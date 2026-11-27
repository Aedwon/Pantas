# Reasoning pre-check fix brief (session 5, Nov 27, E-198)

You are a fixer for the Claude lesson lead. Policy read by the lead: `origin/main` `0234382b8`. Read in full and follow, in order:
1. `docs/content/verification/walkthrough-work/worker-rules.md` (standard and hard limits: Edit tool only, Bash read-only, no redirection, no scripts, no git writes, no subagents, run no checks).
2. `docs/content/verification/walkthrough-work/pattern-checklist.md` (P1 to P5).
3. `docs/content/verification/walkthrough-work/la-precheck-fix-brief.md`, section "Lead ruling on word-specific facts" rules 3 and 4 (frames and signal words): they apply here too.
4. `docs/content/verification/walkthrough-work/reasoning-precheck-findings.md`: every row in your lessons.

Required step from main (process-improvement entry "Grammar walk-through lessons fail every Codex audit round (Nov 27)"): for each flagged item, rewrite the WHOLE Quick Check or try, not only the flagged words: a fresh instance (new names, strings, numbers, figure description or premises) and choices that all fit the visible text, so no choice can be found by copying a printed form, echoing the stem, or reusing the demo's frame. Re-solve every item you write yourself, and check it has exactly one defensible answer. Keep each try's `**Check:**` inside its `:::answer`; the Check confirms the answer a different way.

Reasoning-specific:
- Yes/no or valid/invalid checks: across a lesson, the answers must not all be the same ("no", "invalid"). Where every such check in a lesson has one answer, change at least one so the other answer is correct, by changing the premises, not the question wording.
- A visible step above a try must not already do what the try asks.
- An ambiguous key (two defensible answers) is fixed by changing the item's facts so only one answer holds, not by adding a hint.
- A figure that contradicts its text: fix the text to match the drawn figure (SVG in `content/illustrations/reasoning/<topic>/<lesson>/`, in marker order); never edit the SVG. If the text cannot match the figure, report it to the lead.
- Spatial items: no new figures. If an item can only be fixed with a new drawing, rewrite it so the text alone describes it fully, or report it.

Limits: change only the flagged items, plus every line that names the old instance (steps, answer, Check, pair, checklist) and every restatement of a rule you change (P5). Do not touch `:::pair` Right/Wrong lines unless a row requires it; then the cited mistake in `content/walkthrough-trap-evidence.json` must still fit. No lesson grows by more than 10 pre-tap words; offset with lines a reader would not miss. Never cut a required Check, a lead-in, or a finished result. Do not touch `<!-- FIGURE WANTED:` or `<!-- ILLUSTRATION:` lines.

Report under 600 words: per row, fixed how (one line); rows you think are wrong, with a reason; words added and cut per lesson; files touched.

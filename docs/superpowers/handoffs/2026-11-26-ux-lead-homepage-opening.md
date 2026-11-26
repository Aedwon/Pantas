# UX lead: homepage for the opening, Free and Pro, walk-through board r2 (E-193, E-194, E-195), Nov 26

Policy read: `Aedwon/Pantas` main 0dc0f231 at start; rechecked through c3c3583e9 (process-improvement entries Nov 26: shell-script edits, pricing practice, wordy UI repeat). Lane rules followed: UI only to Claude workers, at most 2 at once, "Do not start subagents" in every brief, browsers with `--use-mock-keychain --password-store=basic`, files changed only with Edit or Write.

## Delivered

- **Homepage for the opening:** pantas-web `web/home-opening-r1` head **0d11f64** (base e625511, the legal pages and footer). Handed to the CSE release lead r9, who rechecked it (208 of 208 tests) and publishes it at step 4 of the opening, Saturday Nov 28, 6:00 AM Manila. Nothing published before then.
  - Top bar keeps its full size and the page width; a paper backdrop and hairline fade in on scroll (opaque, 0.2 s; on above 24 px, off below 8 px); the tassel swing stays.
  - One button on screen: "Open Pantas" in the top bar (and a compact one on phone) hides while "Start studying" is visible and slides in once it passes under the bar. Phone menu button follows the same rule. Wide hand-off A and phone bar button Yes (his "okay go with your recommendations").
  - Hero: "Start studying" and "Now open for the Civil Service Exam."; the beta section, beta status call and BIR badge are gone (his "okay take it off"; badge asset deleted from the canvas with his "yes delete").
  - Free and Pro section above the founder note: his own lists (Free "Basic daily study plan / All lessons for the exam / Unlimited quizzes / Basic explanations / Monthly mock exams"; Pro "Everything in Free, plus:" "Full adaptive plan, tailored for you / Unlimited mock exams / Detailed explanations / Concept-specific results / Your tendencies as a test-taker"); open book under Free (hidden below 768); Free rows level with Pro rows (shared 44 px title row, a silent spacer where Pro has its "plus" line); Pro card in the app's phone Pro green (160deg #0E8B76, #0B7A68, #075548) with white text (AA everywhere, measured at the lightest corner); exam picker at the card's top right (label plus up-down arrow, Civil Service Exam, College entrance tests "Soon"); plan switch 38 px tall with 44 px tap areas, two rows of two where the card is narrow; "No ads" dropped by his pick. No button in the section.
  - Tests: `tests/home-opening.test.js` (each added test failed on the previous head first); full suite 208 of 208. Side-by-side reviews passed (opening top bar at 1440, 768, 390, 320; Free and Pro at 1440, 1024, 768, 390, 320); their findings are fixed and tested.
- **Boards:** Pantas Website canvas https://claude.ai/artifact/UwrETr5cf5HH6CVkcC7pLr (version 115): "Home at the opening" (before and after), and the Free and Pro rounds 1 to 4, final ("one system") and "Pro card in the app's Pro green". The approved card is `project/PL5_Switch.dc.html` with props `fix="final"` and `bg="app"` (frames PL9_Green and PL9_Green_Phone).
- **Walk-through board round 2:** "Lesson Walk-Through Samples" https://claude.ai/artifact/7hd4pLNonSKfmrbs9kyePu version 11. Approved: "layout approved. for the lesson board". Text matches the samples at `tools/walkthrough-checks-r1` b8640b532 word for word; frames refit; notes cut.
- **Records on main:** launch log entries (homepage board, build hand-off, Free and Pro answers, BIR badge reversal, walk-through approval); process entry "Pricing section drawn from house style, not from pricing-page practice"; standards sheet `~/Documents/Projects/agent-standards/pricing-page-design.md` (PRICE-* and PRICE-PREMIUM-* rules).

## Next: the renderer and importer for the lesson `:::` blocks (not started)

Manager's brief: build 1:1 to the approved walk-through board; short build spec and plan first; Claude Sonnet workers; tests that fail first; side-by-side at phone and wide, light and dark, Reduce Motion; CI green; hand to r9. Estimate given: about 10 h active, about 1.5 days wall.

Syntax agreed with the Gemini walk-through lead (thread `mcp:launch:b7636146c2e66e268cb6e853fade6c2d585c3fa734c80ae1f6ecaaec1648308c`), matching its checks on `tools/walkthrough-checks-r1` (`tool/checks/walkthrough_trap_pair_check.dart`, `walkthrough_example_connection_check.dart`, `lesson_size_check.dart`, `tools/audit/sweep_structure.py`):
1. Fences: trimmed lines `:::check`, `:::try`, `:::why`, `:::pair #slug`, `:::checklist` open; `:::` closes. `:::answer` once, inside check or try only, closed by the block's own `:::`. Nothing else nests. In `:::try`, `**Check:**` sits inside `:::answer`.
2. Pair: `^:::pair\s+#([a-z0-9]+(?:-[a-z0-9]+)*)$`, unique per lesson, at most 3 per lesson; body `Right:` then `Wrong:` (one each), then 1 or 2 sentences. Markers `Right:`, `Wrong:`, the section headings, `**Solution:**` and `**Check:**` stay English in Filipino lessons.
3. Checklist: 1 to 3 lines `- Cue: right move {#slug}`; `{#slug}` is stripped from the visible text and resolves to a `:::pair` id or a `###` heading slug (lowercase, non-alphanumerics to `-`, trimmed).
4. Next step: derived from 4 or more numbered steps in an example's `**Solution:**`; a `:::pair` or display math can sit inside a step; a `:::try` can follow the last step.
5. Inside blocks: ordinary lesson Markdown, inline `$math$`, occasional display `$$math$$`, blank lines.
Reference samples: `docs/content/walkthrough-samples/` on `tools/walkthrough-checks-r1` b8640b532; 180+ rewritten CSE lessons on `content/lesson-walkthrough-cse-r1`. UI: the spec `docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md` (Part B, UI) and the round 2 handoff `docs/superpowers/handoffs/2026-11-26-ux-lead-walkthrough-board-r2.md`.

## Open

- His in-app Pro wording goes to r9's worker (`ux/pro-wording-r1`), not this lane.
- Velocity: E-193, E-194, E-195 closed with timer actuals; the renderer's row is written when it starts.

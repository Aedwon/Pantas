# Spatial tries that reuse the core's figure (session 3, manager ruling 3)

You are a content worker (fixer). Lead: Claude lesson lead (E-198). Read `docs/content/verification/walkthrough-work/worker-rules.md` in full first; its hard limits bind you (no subagents; Edit and Write only; Bash only for plain read-only commands, no redirection, no scripts, no loops; run no checks; no git writes).

Background: the session 2 fresh-instance sweep (commit `801fa7644`) found that about twelve `:::check` or `:::try` blocks in `content/lessons/reasoning/spatial-abstract-reasoning/` test the same figure the Core Concept already worked (the same `<!-- ILLUSTRATION: ... -->` figure, or the same described grid, net, fold or series). A fresh instance needs a new hand-made figure, and figures are never invented in text or generated. The list of the twelve was not saved, so you find them.

Manager ruling (verbatim intent): do not invent figures in text. Leave those tries out for now, record each in the figure worklist with what the figure must show; figures are a separate Claude UI job later.

For each lesson in that folder:
1. Read it in full. For every `:::check` and `:::try`, decide: does it ask about a figure, grid, net, fold, solid or series that the lesson already worked earlier (same shapes, same positions, same answer path)? A "Finish the last step" try inside a worked example is fine when the example's own figure is different from the core's; it is a reuse only when the example's figure is the core's figure.
2. For each reuse:
   - Remove the `:::try` or `:::check` block.
   - If it was a try that finished a worked example, put its last step back as a visible numbered step ending at the answer, so the example is complete, with its `**Check:**` line after the steps (not inside a block).
   - If removing it leaves a section with no Quick Check, that is acceptable for now.
   - Do not change any other part of the lesson.
3. Append one row per removed block to `docs/content/walkthrough-figure-worklist.md` under a new heading `## Spatial fresh-instance figures (session 3, ruling 3)`, numbered from 1: the lesson path, the section heading, the removed block's text (quoted in full, so it can return), and `Figure needed:` one or two sentences saying what the new figure must show so the block tests the same taught rule on a fresh instance (shapes, counts, positions, and the answer it must lead to).

Report under 400 words: the list of removed blocks (lesson, heading, check or try), anything you judged borderline and left in, files touched.

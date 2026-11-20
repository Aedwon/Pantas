# CET content: review package for Aedwon

Date: November 20, 2026. Content branch: `content/cet-bite-r1` (head after this file). Plan: `docs/superpowers/plans/2026-11-19-cet-bite-sized-finish.md` on main.

## Status

- Every CET lesson follows the bite-sized rule, like the CSE corpus. Size, nothing-dropped and pool checks pass.
- Every question is on the approval ledger. A separate GPT 6.2 Sol run solved each blind and matched the key (about 3,500 solves, 0 mismatches).
- All 166 missing figures are drawn in style D. All 435 figures pass the static check and the render check (light and dark, 0 failures; run from the SVG branch's app code, since this branch lacks the theme classes the test needs).
- ACET verbal logic now has 54 approved questions for the 45 slots (26 new, written by Sol, each solved blind by a separate Sol run, 0 mismatches), so the mock can draw 45 with no repeats.
- An independent Sol audit ran on every science, math and reasoning group. Its fixes were re-checked twice by separate Sol runs. Evidence: `docs/content/rewrite/cet/audit-*.md`, `auditfix-*.md`, `recheckfix-*.md`, and `docs/content/verification/cet-split.md`.

## Decisions for you

1. Structural-stability exam title (B10).
2. Distribution functions and normal-curve areas: in or out of the CET scope.
3. DCAT and USTET have no blueprint.
4. Some roadmap links point outside ACET, DCAT and USTET.

## Known limits

- Two figures cannot show their exact condition without a renderer change (an edit to the app, not content). The orbital figure labels subshell capacities as "orbital". The seismograph figure prints "proportional to distance" without the steady-speed condition. Both are stated correctly in the lesson text.
- One branching-pipes marker is rejected by the older checker (`tools/audit/check_lesson_illustrations.py`), which keys on the retired lesson slug. The marker matches its SVG. Confirm it loads in the app.
- The checker flags the meiosis, reflex, glucose-feedback and mitochondrion figure placements in biology. Those match the earlier candidate; the checker's inventory predates the split.
- Eleven Algebra word-problems questions were skipped by the packet tool as identical to the earlier CSE solve. They rely on that solve.

## Hand-off to the integrator

1. Export with main's tools. Upload to staging.
2. Gate C5: on a CET-exam account, prove credit carry-over, catalog refresh and the retired-id redirect.
3. Prod only after Aedwon's "ship it". Opening any CET exam to students is a separate decision for Aedwon.

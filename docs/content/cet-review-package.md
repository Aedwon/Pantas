# CET content: review package for Aedwon

Date: November 20, 2026. Content branch: `content/cet-bite-r1` (head after this file). Plan: `docs/superpowers/plans/2026-11-19-cet-bite-sized-finish.md` on main.

## Status

- Every CET lesson follows the bite-sized rule, like the CSE corpus. Size, nothing-dropped and pool checks pass.
- Every question is on the approval ledger. A separate GPT 6.2 Sol run solved each blind and matched the key (about 3,500 solves, 0 mismatches).
- All 166 missing figures are drawn in style D. All 435 figures pass the static check and the render check (light and dark, 0 failures; run from the SVG branch's app code, since this branch lacks the theme classes the test needs).
- ACET verbal logic now has 54 approved questions for the 45 slots (26 new, written by Sol, each solved blind by a separate Sol run, 0 mismatches), so the mock can draw 45 with no repeats.
- An independent Sol audit ran on every science, math and reasoning group. Its fixes were re-checked twice by separate Sol runs. Evidence: `docs/content/rewrite/cet/audit-*.md`, `auditfix-*.md`, `recheckfix-*.md`, and `docs/content/verification/cet-split.md`.

## Aedwon's rulings (Nov 20, logged in the launch log)

1. Structural-stability title stays "Structural Stability" ("okay with 1 and 2").
2. Normal curve: one DCAT-only lesson (Grade 11 DepEd Statistics and Probability competencies M11/12SP-IIIc-1, IIIc-3, IIIc-4, IIIc-d-1) with 10 approved questions.
3. DCAT and USTET practice mocks written (`content/mock/dcat.yaml`, `ustet.yaml`); reported figures cite sources, the rest are marked Pantas-set. Summary: `docs/content/bite-sized/cet/mock-blueprints-summary.md`.
4. Roadmap links outside the exam stay as they are ("okay go with your reco then").
5. Staging after this work ("staging timing, after we're done here").

## Known limits

- Two figures cannot show their exact condition without a renderer change (an edit to the app, not content). The orbital figure labels subshell capacities as "orbital". The seismograph figure prints "proportional to distance" without the steady-speed condition. Both are stated correctly in the lesson text.
- One branching-pipes marker is rejected by the older checker (`tools/audit/check_lesson_illustrations.py`), which keys on the retired lesson slug. The marker matches its SVG. Confirm it loads in the app.
- The checker flags the meiosis, reflex, glucose-feedback and mitochondrion figure placements in biology. Those match the earlier candidate; the checker's inventory predates the split.
- Eleven Algebra word-problems questions were skipped by the packet tool as identical to the earlier CSE solve. They rely on that solve.

- Mocks: the label "Pantas practice exam, not the official format" is in each blueprint's name and source note. The app has no dedicated field for it, and the setup screen for DCAT uses a fixed title. Needs an app decision.
- Mocks: the compiled web sampler rejects both papers when it uses the server's exam-prefixed topic IDs. It fills both with the shared `topic_upcat_*` IDs that the topic check accepts (as the ACET blueprint does). The integrator must confirm this on staging.
- The DCAT time and counts come from one 2019 test-taker report; USTET counts come from two review sites that differ on English. Both are marked reported.

## Hand-off to the integrator

1. Export with main's tools. Upload to staging.
2. Gate C5: on a CET-exam account, prove credit carry-over, catalog refresh and the retired-id redirect.
3. Prod only after Aedwon's "ship it". Opening any CET exam to students is a separate decision for Aedwon.

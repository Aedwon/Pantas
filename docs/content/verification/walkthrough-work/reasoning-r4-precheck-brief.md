# Brief: blind pre-check, batch R4 (E-216, step 3)

Follow `docs/content/verification/walkthrough-work/reasoning-r1-precheck-brief.md` in this worktree in full (startup,
steps 1 to 5, severities, hard rules, format), with these changes:

- Lessons (4), under `content/lessons/reasoning/verbal-logic/`: `needed-assumptions.md`, `negating-assumptions.md`,
  `must-be-true-conclusions.md`, `none-and-may.md`. No pictures.
- Step 1, for verbal logic items: a second defensible answer means another choice that also passes the lesson's test
  (the negation test, "must be true", or the some/none/may rules) under a fair reading of the passage.
- Step 2: re-derive every verdict in every demo, pair, example, check, try and checklist line.
- Step 3, rules: test every claim about "some", "all", "none", "may", "must", "needed" and "negation" against one
  counterexample; flag any rule a question in `content/questions/reasoning/verbal-logic/assumptions-and-conclusions.yaml`
  (lines whose `lesson:` is one of these four) would break.
- Also flag (Major) any demo or example that reuses a linked quiz question's passage or answer. A `:::pair` may keep the
  quiz's cited wrong choice.
- Findings file: `docs/content/verification/walkthrough-work/reasoning-r4-precheck-findings.md`.
- Report: verdict, counts per lesson, your blind answers for the 4 checks and 4 tries (under 250 words).

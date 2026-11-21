Task: fix the series and grouping types that failed the release audit or ruling R6, and add the R6 checker rule. Rulings R1 to R6: docs/superpowers/plans/2026-11-17-question-generator-briefs/fix-rulings.md. Findings: docs/superpowers/verification/question-generator/audit-r1a.md. Tests first; index 0 must reproduce its source on prod root 646326517.

1. R6 checker rule with planted tests: in an active list no single correct answer (key text for text choices, canonical key figure for figure choices, value for math) appears in more than half of the versions.
2. series-corner-edge-count (Major): the corner walk wording requires four-cornered outlines; restrict outlines to squares, or hold if under 20.
3. group-line-count, group-center-cuts (Major): replace position-only and tied-extreme distractors with real named mistakes (R3); notes true per variant.
4. group-specific-rule (R6: one key in 30 of 45): vary the answer or hold.
5. R5 for each: regenerate at min(100, capacity), re-measure, hold under 20. Report counts and checker results. Do not touch other types or approve anything.

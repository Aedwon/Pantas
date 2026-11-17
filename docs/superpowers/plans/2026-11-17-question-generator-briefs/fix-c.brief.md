Task: fix the open re-audit findings. Findings: docs/superpowers/verification/question-generator/reaudit-a.md and reaudit-b.md. Rulings R1 to R5 in docs/superpowers/plans/2026-11-17-question-generator-briefs/fix-rulings.md still apply. Tests first; index 0 of every merged type must still reproduce its source exactly.

1. matrix-ray-turn (Blocker): add up-to-down reflection of the ray to the matrix solver library, then constrain the generator so no variant admits it. Confirm the checker fails on the audit's index-57 example before the constraint and passes after.
2. matrix-dot-sum (Blocker): add the counting-sequence continuation (c = 2b - a) to the library as a competing rule. Constrain draws so the completed rows rule it out (no completed row where a + b equals 2b - a). Same checker proof as item 1 with index 56.
3. matrix-ray-intersection (Blocker): add "keep the ray pointing highest" to the library. The merged source itself admits it, so move the type to content/types-held/ and record a FINDINGS line for the content lane.
4. matrix-corner-step (Major): the wording counts corners, so restrict outlines to forms drawn with four corners (square, rectangle if the figure kind draws it). Also remove the text-length rejection that never keys bottom-right (Minor). Re-measure; if it falls under 100 distinct task signatures, hold it.
5. Leave group-polygon-replacement and matrix-corner-reflection Minors open; they are accepted by the lead as documented variety limits.
6. R5 for every type you touch. Report new counts.

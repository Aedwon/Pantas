# Question QA R1 source ledger — Mathematics / Geometry

**Branch:** `web/content-qa-questions-r1`  
**Base:** `3a1ac087fd88bce1e1903d5c7996371054b36094`  
**Reviewed:** 25 August 2026

This supplemental ledger records substantive Geometry corrections. Geometry keys were independently recomputed or re-derived from the stated givens. The matching repository lessons were reviewed for all eight subtopics. No external factual source was needed because the findings are mathematical or repository-schema issues.

## Corrected questions

| Question | Finding | Disposition | Evidence |
|---|---|---|---|
| `q-geometry-basic-geometric-concepts-0015` | The final trap note called 140 degrees the supplement of Q=50, although 140 is the supplement of the requested R=40. | CORRECTED | The keyed computation remains Q=50, R=40. The note now correctly identifies 140 as the supplement of R. |
| `q-geometry-measurement-0006` | The original trapezoid asserted bases 10 and 18, height 4, and two 5 cm slant legs. Those dimensions cannot all hold for one trapezoid: with height 4, each 5 cm leg has horizontal projection 3, so equal legs would give a base difference of 6 rather than 8. | CORRECTED | Stem now says one non-parallel slant leg is 5 cm. The area remains `(10+18)/2 * 4 = 56 cm^2`; the 5 cm value still serves the intended slant-height distractor. |
| `q-geometry-parallel-perpendicular-lines-0013` | The explanation referenced an undefined point O in angle ABO. | CORRECTED | The explanation now states directly that AB is perpendicular to L2 at B, so the angle between AB and L2 is 90 degrees. |
| `q-geometry-parallel-perpendicular-lines-0014` | Original A, B, C were all intersections of one transversal with three parallel lines, yet angle ABC was treated as a 75-degree transversal/parallel angle. A-B-C are collinear, so that named angle is a straight angle. | CORRECTED | Stem now uses corresponding acute angles at L1 and L3; at B, ray BD bisects the adjacent obtuse angle. Re-derived: x=20, acute angle=75 degrees, supplement=105 degrees, bisected result=52.5 degrees. |
| `q-geometry-parallel-perpendicular-lines-0015` | A `figure` field made a fully text-solvable item figure-pending/inactive under the authoring contract. Removing the figure initially exposed an orientation ambiguity. | CORRECTED | Final stem explicitly makes L1/L2 horizontal and states that both transversal intersections with the parallel lines lie to the left of P. The left-facing angle is therefore uniquely `50+65=115` degrees from text alone. The unnecessary `figure` field was removed. |
| `q-geometry-triangles-0010` | The explanation rejected algebraic root x=0 using only x>0, but the side x-2 must itself be positive. | CORRECTED | The valid geometric domain is x-2>0, hence x>2; this excludes x=0 and retains x=8, giving hypotenuse 10. |
| `q-geometry-logic-and-reasoning-0011` | Direct recognition of the sole false row of material implication was labeled `hard`, out of scale with the neighboring multi-step logic items. | CORRECTED | Difficulty changed to `medium`; stem, choices, key, and explanation are unchanged. |

## Lesson conformity

All eight corresponding Geometry lessons were reviewed:

- `basic-geometric-concepts.md`
- `circles.md`
- `coordinate-geometry.md`
- `logic-and-reasoning.md`
- `measurement.md`
- `parallel-perpendicular-lines.md`
- `quadrilaterals-and-polygons.md`
- `triangles.md`

No item-level lesson contradiction remains in the reviewed Geometry bank. The quadrilateral lesson uses the exclusive convention that a trapezoid has exactly one pair of parallel sides; no reviewed question depends on the inclusive/exclusive trapezoid convention.

## Visual classification

No reviewed Geometry question requires an external figure after remediation. Many spatial questions are tagged `TEXT SUFFICIENT; VISUAL BENEFICIAL` in the per-item ledgers, but every active item states enough geometric relationships and values to determine its answer from text alone.

The `figure` removal from `q-geometry-parallel-perpendicular-lines-0015` follows `docs/content/question-style-guide.md`: a present `figure` marks a question figure-pending and causes the importer to emit it inactive, so figures should be reserved for questions that actually need an image that cannot be inferred from the written stem.

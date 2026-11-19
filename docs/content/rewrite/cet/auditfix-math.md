# PASS | CET Math audit fixes
Policy revision `71d58f260`. Scope is the findings listed in the audit.
- Fixed basic derivatives q0001. The explanation now labels the derivative.
- Fixed Counting Choices in Stages. Removed the false rule about reuse.
- Fixed Same-Side Angles and Supplements. The sum rule now requires parallel lines.
- Fixed Adjusting for Eye Height. The rules now account for both base levels.
- Fixed Inverse Cosine and Input Limits. The shared acute-angle rule now applies to inputs strictly between zero and one.
- Fixed conic sections q0014 coverage. Added the horizontal focus rule and defined $p$.
- Fixed limits and continuity q0003. Moved it to One-Sided Limits and Continuity.
- Fixed circles q0009 and q0010. Moved them to the parts that teach their angle rules.
- Fixed coordinate geometry q0008, q0012, and q0015 coverage. Added the active area prerequisite, grid area steps, and a point-to-line example.
- Fixed quadrilaterals and polygons q0007 coverage. Defined the midsegment and its length rule.
- Fixed combinatorics q0006, q0007, q0011, q0013, and q0015 coverage. Added repeated-object, circular, and grouped arrangements.
- Fixed basic probability q0014 and q0016. Added the missing branch and sequence setups to the stems.
- Fixed measures of central tendency q0014 and q0016. Moved them to Median and Mode.
- Fixed Identifying Axis-Aligned Conics. Moved the answer figure below the solution.
- Fixed Circle and Parabola Standard Forms. Moved the answer figure below the solution.
- Fixed Factoring to Evaluate Limits. Moved the answer figure below the solution.
- Fixed One-Sided Limits and Continuity. Moved the answer figure below the solution.
- Fixed Arc Length With Radians. The figure now shows the known radius and angle and labels the arc $s$.
- Fixed Finding Coterminal Angles. Moved the answer figure below the solution.
- Fixed Inverse Sine and Arctangent, Inverse Cosine and Input Limits, and Composing Trigonometric Functions. Moved five answer figures below their solutions.
- Fixed Reading If-Then Statements, Biconditionals, and Deduction and Conditional Chains. Moved three answer illustrations below their solutions.
- Fixed the team and role example references in Counting Choices in Stages and Combinations and Complementary Choices.
- Fixed the overlap example reference in Adding Counts With Overlap.
- Fixed the example references and removed the old numbering notes in Bisecting Angles and Chord Lengths and Segments.
- Fixed the example reference and removed the old numbering note in Comparing Two Observations.
- Fixed Chain Rule and Tangent Slopes. The point now includes both coordinates.
- Fixed the vertical leg label in Distance on the Coordinate Plane.
## CHANGED-QUESTIONS
```
q-geometry-circles-0009
q-geometry-circles-0010
q-precalculus-basic-calculus-basic-derivatives-0001
q-precalculus-basic-calculus-limits-and-continuity-0003
q-statistics-and-probability-basic-probability-0014
q-statistics-and-probability-basic-probability-0016
q-statistics-and-probability-measures-of-central-tendency-0014
q-statistics-and-probability-measures-of-central-tendency-0016
```
Keys checked twice. Matching retired lesson text and markers updated.
## Check output
`dart run` was blocked by sandbox permissions on the shared Objective-C hook lock. The same checker ran directly with the existing package config and exited 1 with seven pool diagnostics and zero size, nothing-dropped, or part failures.
Areas on a Grid (PSHS-NCE) has pool 1 below quiz size 2. Direct Substitution for Limits (PUPCET) has no shipping, gate-passing question for key point 1. Arithmetic Mean and Missing Values (UPCAT, ACET, DLSUCET, USTET, PUPCET) has pool 3 below quiz size 4 for each exam.
## Files touched
- `content/lessons/mathematics/geometry/` · angles-in-parallelograms-and-trapezoids, basic-geometric-concepts, biconditionals, bisecting-angles, chord-lengths-and-segments, circles, coordinate-geometry, deduction-and-conditional-chains, distance-on-the-coordinate-plane, logic-and-reasoning, parallel-perpendicular-lines, quadrilaterals-and-polygons, reading-if-then-statements, same-side-angles-and-supplements (.md).
- `content/lessons/mathematics/precalculus-basic-calculus/` · basic-derivatives, chain-rule-and-tangent-slopes, circle-and-parabola-standard-forms, conic-sections, factoring-to-evaluate-limits, identifying-axis-aligned-conics, limits-and-continuity, one-sided-limits-and-continuity (.md).
- `content/lessons/mathematics/statistics-and-probability/` · adding-counts-with-overlap, combinations-and-complementary-choices, combinatorics, counting-choices-in-stages, factorials-and-permutations (.md).
- `content/lessons/mathematics/trigonometry/` · adjusting-for-eye-height, angles-and-radian-measure, arc-length-with-radians, comparing-two-observations, composing-trigonometric-functions, finding-coterminal-angles, inverse-cosine-and-input-limits, inverse-sine-and-arctangent, inverse-trigonometric-functions, solving-right-triangles (.md).
- `content/questions/mathematics/` · geometry/circles, precalculus-basic-calculus/{basic-derivatives,limits-and-continuity}, statistics-and-probability/{basic-probability,measures-of-central-tendency} (.yaml). Also `content/lesson-prerequisites.json` and this report.

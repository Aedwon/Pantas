# CET rest pool gaps

PASS. The worktree adds the minimum 14 questions across eight parts. All 26 parts meet the tagged pool rule for every exam in their file.
No tagged pools remain short. The 14 new questions await approval before they can count at the build gate.
Policy revision `71d58f260`.

| Part | Key point and new question IDs |
| --- | --- |
| Complementary Angle Ratios | 1 · `q-trigonometry-basic-trigonometric-ratios-0021` |
| Special-Angle Side Lengths | 1 · `q-trigonometry-basic-trigonometric-ratios-0022`, 2 · `q-trigonometry-basic-trigonometric-ratios-0023` |
| Simple Polygons and Interior Angle Sums | 1 · `q-geometry-quadrilaterals-and-polygons-0021` |
| Quadrilateral Angle Sums | 1 · `q-geometry-quadrilaterals-and-polygons-0022`, `q-geometry-quadrilaterals-and-polygons-0023` |
| Classifying Quadrilaterals by Diagonals | 1 · `q-geometry-quadrilaterals-and-polygons-0024`, `q-geometry-quadrilaterals-and-polygons-0025` |
| Triangle Angle Sums and Types | 2 · `q-geometry-triangles-0021`, `q-geometry-triangles-0022` |
| Proving Triangle Congruence from a Figure | 1 · `q-geometry-triangles-0023`, `q-geometry-triangles-0024` |
| Proof of the Pythagorean Theorem | 1 · `q-geometry-triangles-0025`, `q-geometry-triangles-0026` |

Second solves checked trig keys with a 3:4 triangle, the special-angle ratio list, and the panel's diagonal squared.
Polygon checks used the inward turn, angle back-substitution, half the total minus half the known sum, equal perpendicular half-diagonals, and the rectangle's center of symmetry.
Triangle checks used the base opposite the unique angle, the two 45-degree angles, a half-turn about the crossing, matching distinct side lengths, a square split into two squares and two rectangles, and perpendicular central sides with direction vectors `(a,b)` and `(-b,a)`.
The requested `dart run` exited 1 before validation because the sandbox blocked a native build-hook lock. Direct execution of the same importer from the finish worktree validated the full question root with exit 0 and empty stderr.
All 14 additions have one correct choice and three wrong-choice notes. The five files preserve every question from HEAD.

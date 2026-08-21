---
_id: "lesson-geometry-quadrilaterals-and-polygons"
title: "Quadrilaterals and Polygons (Properties, Interior and Exterior Angle Sums)"
summary: "The special quadrilaterals and the formulas for the angles of any polygon."
subject: "subject-mathematics"
topic: "topic-geometry"
estimatedMinutes: 12
isActive: true
---
## Core Concept

A **polygon** is a closed figure made of straight sides. It is named by its side count: triangle ($3$), quadrilateral ($4$), pentagon ($5$), hexagon ($6$), heptagon ($7$), octagon ($8$), nonagon ($9$), decagon ($10$). A **regular** polygon has all sides equal and all angles equal.

Two formulas run this whole topic. For a polygon with $n$ sides:

The sum of the interior angles:

$$S = (n - 2) \times 180^\circ$$

Why $n - 2$? Because you can slice any polygon into $n - 2$ triangles from one corner, and each triangle carries $180^\circ$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "polygon-triangulation", "labels": ["Hexagon (n = 6)", "4 Triangles", "(6 - 2) × 180° = 720°"], "semanticsLabel": "Hexagon with diagonals drawn from one vertex dividing it into 4 triangles."} -->

The sum of the exterior angles (one at each vertex) is always:

$$360^\circ$$

This is true for every polygon, whether it has $3$ sides or $100$ sides. Walk around the polygon once and you turn one full circle.

For a regular polygon, divide either sum by $n$ to get each single angle.

**Quadrilaterals** ($n = 4$, interior sum $360^\circ$) form a family tree:

- **Parallelogram**: both pairs of opposite sides parallel. Opposite sides are equal, opposite angles are equal, consecutive angles are supplementary, and the diagonals bisect each other (cut each other in half).
- **Rectangle**: a parallelogram with four right angles. Its diagonals are equal.
- **Rhombus**: a parallelogram with four equal sides. Its diagonals are perpendicular and bisect the corner angles.
- **Square**: rectangle and rhombus at once. It has every property above.
- **Trapezoid**: exactly one pair of parallel sides. Not a parallelogram.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "quadrilateral-tree", "labels": ["Quadrilateral", "Trapezoid", "Parallelogram", "Rectangle", "Rhombus", "Square"], "semanticsLabel": "Hierarchy diagram showing parallelogram branching into rectangle and rhombus, merging into square, with trapezoid separate."} -->

CETs love two question types here: plug into the angle formulas (forward or backward), and true-or-false property statements like "the diagonals of a rectangle are perpendicular" (false; that is the rhombus).

## Examples

### #1: Interior Angle Sum

Find the sum of the interior angles of a hexagon.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "polygon-triangulation", "labels": ["Hexagon", "6 Interior Angles", "4 Triangles", "Sum = 720°"], "semanticsLabel": "Regular hexagon with six interior angles and dashed lines splitting it into 4 triangles."} -->


**Solution:**
A hexagon has $n = 6$ sides.

1. Use the formula.

$$S = (6 - 2) \times 180$$

2. Compute.

$$S = 4 \times 180 = 720$$

3. The interior angles of any hexagon add up to $720^\circ$.

### #2: Each Angle of a Regular Polygon

Find the measure of each interior angle of a regular octagon.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "polygon", "labels": ["Regular Octagon (n = 8)", "Each angle = ?"], "semanticsLabel": "Regular octagon with one interior angle highlighted with a question mark."} -->


**Solution:**
Find the total first, then share it equally among the $8$ corners.

1. Total interior sum for $n = 8$.

$$S = (8 - 2) \times 180 = 1080$$

2. Divide by the number of angles.

$$\dfrac{1080}{8} = 135$$

3. Each interior angle of a regular octagon is $135^\circ$.

### #3: Working Backwards to Find $n$

The interior angles of a polygon add up to $1440^\circ$. How many sides does it have?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "polygon", "labels": ["Regular n-gon", "Sum = 1440°", "Sides n = ?"], "semanticsLabel": "Regular polygon labeled with interior angle sum 1440 degrees and unknown number of sides n."} -->


**Solution:**
Use the formula in reverse.

1. Set up the equation.

$$(n - 2) \times 180 = 1440$$

2. Divide both sides by $180$.

$$n - 2 = 8$$

3. Add $2$.

$$n = 10$$

4. The polygon has $10$ sides. It is a decagon.

### #4: Exterior Angles

Each exterior angle of a regular polygon measures $24^\circ$. How many sides does the polygon have?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "polygon-exterior", "labels": ["Exterior angle = 24°", "Sum of exterior = 360°", "Sides = 360° / 24°"], "semanticsLabel": "Regular polygon with one side extended to show an exterior angle of 24 degrees."} -->


**Solution:**
All the exterior angles add to $360^\circ$, and in a regular polygon they are all equal.

1. Divide the full turn by one exterior angle.

$$n = \dfrac{360}{24} = 15$$

2. The polygon has $15$ sides.
3. Bonus check: each interior angle is $180 - 24 = 156^\circ$, since an interior and its exterior angle form a straight line.

### #5: Parallelogram Angles with Algebra

In parallelogram $ABCD$, opposite angles $A$ and $C$ measure $(3x + 10)^\circ$ and $(5x - 30)^\circ$. Find the measure of angle $B$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "parallelogram", "labels": ["A", "B", "C", "D", "Angle A: (3x + 10)°", "Angle C: (5x - 30)°", "Angle B: ?"], "semanticsLabel": "Parallelogram ABCD with opposite angles A labeled 3x plus 10 degrees and C labeled 5x minus 30 degrees, and angle B marked with a question mark."} -->


**Solution:**
Opposite angles of a parallelogram are equal. Consecutive angles are supplementary.

1. Set the opposite angles equal.

$$3x + 10 = 5x - 30$$

2. Add $30$ and subtract $3x$ on both sides.

$$40 = 2x$$

$$x = 20$$

3. So angle $A = 3(20) + 10 = 70^\circ$. Check: $5(20) - 30 = 70$. Correct.
4. Angle $B$ is consecutive (next-door) to angle $A$, so they add to $180^\circ$.

$$180 - 70 = 110$$

5. Angle $B$ measures $110^\circ$. Notice the question asked for $B$, not $A$.

### #6: Quadrilateral Angles in a Ratio

The four angles of a quadrilateral are in the ratio $1 : 2 : 3 : 4$. Find the largest angle.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "quadrilateral", "labels": ["x", "2x", "3x", "4x", "Sum = 360°"], "semanticsLabel": "Four-sided quadrilateral with interior angles labeled x, 2x, 3x, and 4x."} -->


**Solution:**
Call the angles $x$, $2x$, $3x$, $4x$. A quadrilateral's angles add to $360^\circ$.

1. Write the sum.

$$x + 2x + 3x + 4x = 360$$

2. Combine.

$$10x = 360$$

$$x = 36$$

3. The angles are $36^\circ$, $72^\circ$, $108^\circ$, and $144^\circ$.
4. The largest angle is $4(36) = 144^\circ$. Check the sum: $36 + 72 + 108 + 144 = 360$. Correct.

## Speed Tricks & Shortcuts

For each interior angle of a regular polygon, it is often faster through the back door: find the exterior angle first ($360 \div n$), then subtract from $180$. For a regular octagon: $360 \div 8 = 45$, and $180 - 45 = 135$. Two easy divisions instead of one big multiplication.

Memorize the small interior sums: quadrilateral $360^\circ$, pentagon $540^\circ$, hexagon $720^\circ$. Each extra side adds exactly $180^\circ$.

For "how many sides" questions with exterior angles, just divide $360$ by the given angle. If the answer is not a whole number, no such regular polygon exists, and that can itself be the answer.

## Traps to Watch For

### #1: Exterior Angles Do Not Grow

> The exterior angle sum is $360^\circ$ for every polygon.

Students assume a bigger polygon has a bigger exterior sum and reach for $(n - 2) \times 180$. Only the interior sum grows. The exterior sum is stuck at $360^\circ$ forever, and test-makers hide easy one-step problems behind this fact.

### #2: Consecutive Is Not Opposite

> In a parallelogram, opposite angles are equal; neighboring angles add to $180^\circ$.

Setting two consecutive angles equal to each other (or making opposite angles supplementary) builds the wrong equation and produces a clean-looking wrong answer. Say the positions out loud: across means equal, next-door means supplementary.

### #3: Every Square Is a Rhombus, Not the Reverse

> Properties flow down the family tree, not up.

A square is always a rectangle and always a rhombus. But a rhombus is usually not a square. True-or-false items like "every rhombus is a square" (false) and "every square is a rhombus" (true) differ only in word order. Read direction carefully.

### #4: Whose Diagonals Do What

> Rectangle diagonals are equal. Rhombus diagonals are perpendicular.

These two get swapped constantly. Remember: the rhombus is the "pointy" one, and its diagonals cross at sharp right angles. Only the square, being both, has diagonals that are equal and perpendicular.

---
_id: "lesson-spatial-abstract-reasoning-grouping-outlines-and-symmetry"
title: "Grouping Outlines and Symmetry"
summary: "Group figures by side count and straight or curved outlines."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
isActive: true
part: 1
partCount: 3
ordering: 4
keyPoints:
  - "Group figures by side count and straight or curved outlines."
  - "Check whether figures have matching halves."
---
## Core Concept

### Counting Sides and Checking Edge Type

**Figure grouping** questions show a row of figures where most follow one rule. The **odd-one-out** is the single figure that breaks it.

Test two simple outline rules first:

- **Side count**: count straight sides, ignoring tilt, slant, or unequal side lengths.
- **Straight vs. curved edges**: check whether an outline uses only straight segments or has a curve.

1. Look at a parallelogram, rectangle, hexagon, and rhombus.
2. Count sides: parallelogram ($4$), rectangle ($4$), hexagon ($6$), rhombus ($4$).
3. Three outlines have $4$ sides, so the $6$-sided **hexagon** is the odd-one-out.

Now test an even-side rule: square ($4$), rectangle ($4$), hexagon ($6$), pentagon ($5$). Since $4, 4, 6$ are even and $5$ is odd, the **pentagon** breaks the rule.

:::pair #slant-changes-count
Right: in parallelogram, rectangle, hexagon, rhombus, pick **Hexagon** ($6$ sides vs. $4$).
Wrong: pick **Parallelogram** because its slanted sides look different.
Slanting a shape never changes its side count. Count every straight edge first.
:::

:::pair #require-exact-four-sides
Right: under an even-side rule on square ($4$), rectangle ($4$), hexagon ($6$), pentagon ($5$), pick **Pentagon**.
Wrong: pick **Hexagon** because it does not have $4$ sides.
Six is still even. Test the shared rule ($4, 4, 6$ are even) across every figure.
:::

:::why
Why check side count before proportions? Turning or stretching a $4$-sided shape changes its look, yet all $4$-sided polygons still share $4$ sides.
:::

:::check
Four outlines are shown: a trapezoid, a square, a pentagon, and a rhombus. Grouped by side count, which outline does not belong?
:::answer
The answer is the **pentagon**. The trapezoid, square, and rhombus each have $4$ sides, while the pentagon has $5$ sides.
:::

### Testing Reflection Symmetry

A figure has **reflection symmetry** when a straight line, called a **reflection axis**, splits it into two halves that match when folded across that line. A reflection axis can run vertically, horizontally, or diagonally, and internal marks must match across it too.

<!-- ILLUSTRATION: four equal square frames in one row: first square with an internal line at 30 degrees from vertical, second square with one top-center dot, third square with one top-left corner dot and a dashed diagonal reflection axis, fourth square with two dots mirrored across the vertical center line -->

Test the four squares for symmetry:

1. Square $2$ (top-center dot) folds evenly along a vertical axis.
2. Square $3$ (top-left dot) folds evenly along its diagonal.
3. Square $4$ (two symmetric dots) folds evenly along a vertical axis.
4. Square $1$ (line tilted at $30^\circ$) matches no axis of the square, so **square $1$** lacks reflection symmetry.

:::pair #ignore-diagonal-axis
Right: a square with a top-left dot keeps a diagonal axis, so exclude the **leftmost square** ($30^\circ$ line).
Wrong: exclude the **Third square from the left** because the corner dot is off-center.
A corner dot keeps symmetry along the diagonal through that corner and the center. Check diagonal folds as well as vertical and horizontal ones.
:::

:::check
Four figures are shown: a circle, an equilateral triangle, a rectangle, and a scalene triangle with three unequal sides. Which figure has no reflection axis?
:::answer
The answer is the **scalene triangle**. With all three sides unequal, no fold line makes matching halves.
:::

## Examples

### #1: Grouping by Number of Sides

Four figures are shown: a square, a rectangle, a rhombus, and a triangle. Which figure does not belong?

<!-- ILLUSTRATION: four figures in one row, a square, a rectangle, a rhombus, and a triangle, all with plain unshaded outlines -->

**Solution:**

1. Count the straight sides of each outline.
2. The square, rectangle, and rhombus each have $4$ sides.
3. The triangle has $3$ sides, breaking the shared $4$-side count.

The odd-one-out is the **triangle**.

**Check:** Notice the rhombus looks tilted and the rectangle is wider than tall, yet all three are $4$-sided polygons.

### #2: Grouping by Symmetry

Four figures are shown: a circle, a square, an equilateral triangle, and an irregular blob with no line that makes matching halves. Which figure does not belong?

<!-- ILLUSTRATION: four figures in one row, a circle, a square, an equilateral triangle, and an irregular lopsided blob with no line of reflection symmetry -->

**Solution:**

1. Test whether each figure has at least one reflection axis.
2. The circle, square, and equilateral triangle each have axes that make matching halves.
3. The irregular lopsided blob has no line that makes matching halves.

The odd-one-out is the **irregular blob**.

**Check:** Straight vs. curved boundaries would single out the circle, yet the blob also has curves; only reflection symmetry groups the first three figures together.

### #3: Grouping by Curved and Straight Lines

Four figures are shown: a triangle, a square, a pentagon, and a circle. Which figure does not belong?

<!-- ILLUSTRATION: four figures in one row, a triangle, a square, a pentagon, and a circle, all with plain unshaded outlines -->

**Solution:**

1. Check whether each outline uses straight segments or a curve.
2. The triangle ($3$ sides), square ($4$ sides), and pentagon ($5$ sides) use only straight segments.

:::try
Finish the last step: check the fourth figure's boundary to name the odd-one-out.
:::answer
The answer is the **circle**. Unlike the three polygons, the circle has a curved outline.

**Check:** All four figures have reflection symmetry and different side counts ($3, 4, 5$), so only straight vs. curved boundary separates one figure cleanly.
:::

## Traps to Watch For

:::checklist
- Slanted or tilted shapes: count the sides instead of picking the outline that looks odd. {#slant-changes-count}
- Parity rules like even side counts: test whether $6$ fits the rule instead of assuming every shape needs $4$ sides. {#require-exact-four-sides}
- Off-center marks on squares: check diagonal fold lines as well as vertical and horizontal ones. {#ignore-diagonal-axis}
:::

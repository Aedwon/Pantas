---
_id: "lesson-spatial-abstract-reasoning-grouping-regions-and-inside-details"
title: "Grouping Regions and Inside Details"
summary: "Count enclosed regions from the actual line arrangement."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
isActive: true
part: 2
partCount: 3
ordering: 5
keyPoints:
  - "Count enclosed regions from the actual line arrangement."
  - "Compare dots and other details inside the outlines."
---
## Core Concept

### Counting Enclosed Regions

Unlike plain outlines such as a square, rectangle, rhombus, parallelogram, and pentagon, many grouping items change what sits inside.

<!-- ILLUSTRATION: one row containing a square, a rectangle, a rhombus, a slanted parallelogram, and a regular pentagon, all with plain unshaded outlines -->

An **enclosed region** is a closed area inside a figure. Count the closed areas directly, never the dividing lines.

1. Four circles have $1, 2, 3,$ and $0$ lines through the center.
2. Count enclosed regions: $2, 4, 6,$ and $1$.
3. Circles $1$ to $3$ have even counts ($2, 4, 6$), so the uncut **$1$-region circle** is the odd-one-out.

:::why
Why do $3$ distinct lines through a circle's center make $6$ regions, not $3$? Each straight line cuts all the way across, splitting every region it crosses in two.
:::

:::pair #lines-not-regions
Right: $3$ center lines make $6$ regions (even), so the uncut **$1$-region circle** breaks the even-region rule.
Wrong: pick the **Third circle from the left** because it has $3$ lines and $3$ is odd.
Line count is not region count. Trace and number every closed area inside the figure.
:::

:::check
Square $1$ has $1$ diagonal ($2$ regions), square $2$ has $2$ crossing diagonals ($4$ regions), and square $3$ has $2$ parallel horizontal lines ($3$ strips). Which square has an odd region count?
:::answer
The answer is **square $3$**. Two parallel lines divide the square into $3$ strips, and $3$ is odd.
:::

### Comparing Inside Details

**Inside details** include dots, fill, arrows, and internal lines. When outer shapes differ, check the inside marks first.

1. Look at a square ($1$ dot), triangle ($1$ dot), circle ($1$ dot), pentagon ($1$ dot), and hexagon ($2$ dots).
2. Dot counts are $1, 1, 1, 1, 2$, so the **hexagon** breaks the rule, even though the circle is curved.

Some rules link inside marks to outer sides: square ($4$ sides, $2$ dots), rectangle ($4, 2$), hexagon ($6, 3$), and triangle ($3, 2$). Three shapes have sides $=2\times\text{dots}$, while the **triangle** ($3$ sides, $2$ dots) fails.

:::pair #outer-shape-over-inside-detail
Right: in square ($1$ dot), triangle ($1$ dot), circle ($1$ dot), pentagon ($1$ dot), hexagon ($2$ dots), pick **Hexagon**.
Wrong: pick **Circle** because it is the only curved shape.
A curved outline stands out visually, yet inside marks often carry the rule. Count inside details first.
:::

:::pair #largest-count-over-relation
Right: when side count equals twice the dots, square ($4, 2$), rectangle ($4, 2$), and hexagon ($6, 3$) match, so exclude **Triangle** ($3, 2$).
Wrong: exclude **Hexagon** because $3$ dots is more than $2$ dots.
A larger dot count still fits when sides scale up too. Test the relation on every figure.
:::

:::check
Square $1$ has $1$ dot and $1$ edge line, square $2$ has $2$ dots and $2$ lines, square $3$ has $2$ dots and $3$ lines, and square $4$ has $3$ dots and $3$ lines. Which square breaks the rule?
:::answer
The answer is **square $3$**. Squares $1, 2,$ and $4$ have matching counts, while square $3$ has $2$ dots and $3$ lines.
:::

## Examples

### #1: Grouping by Number of Enclosed Regions

Four circles are shown. The first has one straight line through the center and $2$ regions. The second has two different straight lines through the center and $4$ regions.

The third has three different straight lines through the center and $6$ regions. The fourth has two parallel off-center lines that do not cross, making $3$ regions. Which figure does not belong?

<!-- ILLUSTRATION: four circles in one row, the first split into 2 regions by one full center line, the second into 4 regions by two full center lines, the third into 6 regions by three distinct full center lines, and the fourth into 3 regions by two parallel horizontal chords above and below the center -->

**Solution:**

1. Count regions from left to right: $2, 4, 6,$ and $3$.
2. Circles $1, 2,$ and $3$ have even region counts.
3. Circle $4$ has $3$ regions, which is odd.

The odd-one-out is the **fourth circle**.

**Check:** Two crossing off-center lines would still make $4$ regions; parallel chords create the odd count of $3$ regions.

### #2: Grouping by an Inside Detail

Five figures have different outlines: a square, a triangle, a circle, a pentagon, and a hexagon. Each of the first four contains one shaded dot. The hexagon contains two shaded dots.

Which figure does not belong?

<!-- ILLUSTRATION: five figures in one row, a square with 1 shaded dot, a triangle with 1 shaded dot, a circle with 1 shaded dot, a pentagon with 1 shaded dot, and a hexagon with 2 shaded dots -->

**Solution:**

1. Count the shaded dots inside each figure, ignoring the outer shape.
2. The square, triangle, circle, and pentagon each hold $1$ shaded dot.
3. The hexagon holds $2$ shaded dots, breaking the shared $1$-dot rule.

The odd-one-out is the **hexagon**.

**Check:** Even though the circle is the only curved outline, its $1$ dot matches the first four figures.

### #3: Comparing Side Count and Dot Count

Four polygons contain shaded dots: a square with $2$ dots, a rectangle with $2$ dots, a hexagon with $3$ dots, and a triangle with $2$ dots. Which figure does not belong?

<!-- ILLUSTRATION: four unshaded outlines in one row, a square with 2 shaded dots, a rectangle with 2 shaded dots, a hexagon with 3 shaded dots, and a triangle with 2 shaded dots -->

**Solution:**

1. List sides and dots: square ($4, 2$), rectangle ($4, 2$), hexagon ($6, 3$), triangle ($3, 2$).
2. Check whether $\text{sides}=2\times\text{dots}$ for the first three: $4=2\times2$ (square), $4=2\times2$ (rectangle), and $6=2\times3$ (hexagon).

:::try
Finish the last step: test the triangle against the rule that side count is twice the dot count.
:::answer
The answer is the **triangle**. With $2$ dots, twice the dot count would be $4$ sides, yet the triangle has $3$ sides.

**Check:** Notice the hexagon has $3$ dots, yet $6=2\times3$ matches the rule; only the triangle fails it.
:::

## Traps to Watch For

:::checklist
- Divided shapes: count the enclosed spaces directly instead of counting the lines. {#lines-not-regions}
- Mixed outer shapes: inspect dots, shading, and arrows inside before picking a curved or slanted outline. {#outer-shape-over-inside-detail}
- Differing inside counts: test whether the inside count scales with the outer shape's sides. {#largest-count-over-relation}
:::

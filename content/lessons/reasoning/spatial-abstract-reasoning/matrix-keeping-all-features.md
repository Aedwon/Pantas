---
_id: "lesson-spatial-abstract-reasoning-matrix-keeping-all-features"
title: "Matrix Rules: Keeping All Features"
summary: "Combine all features from the starting cells."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
isActive: true
part: 3
partCount: 4
ordering: 9
keyPoints:
  - "Combine all features from the starting cells."
---
## Core Concept

### Combining Lines and Marks Into the Third Cell

A **combination rule** builds the third cell from the marks in the first two cells. Under a **keep-all rule**, every line, dot, or shaded piece in cell $1$ or cell $2$ stays in cell $3$.

1. In row $1$ of a $2 \times 3$ grid, a circle with a right ray and a circle with an up ray combine into a circle with **both** rays.
2. In row $2$, a square has an upper-right ray in cell $1$ and a lower-right ray in cell $2$.
3. Keep both rays on the square: the blank shows a **square with both diagonal rays**.

:::why
Why check row $1$ first? A shared-only rule keeps only matching marks, so row $1$'s third cell tells you which rule is active.
:::

:::pair #keep-only-one-input
Right: combining an upper-right ray and a lower-right ray gives **Square with both diagonal rays**.
Wrong: pick **Square with only the upper-right ray**.
Keeping one input drops the second cell's ray. Lay both starting cells together so every mark stays.
:::

:::pair #copy-first-row-parts
Right: combine row $2$'s diagonal rays to get **Square with both diagonal rays**.
Wrong: pick **Square with rays up and right** by copying row $1$.
Row $2$ uses diagonal rays, not up and right. Apply the rule to the blank row's own inputs.
:::

:::check
In a $2 \times 3$ grid, row $1$ shows a triangle with a top dot, a triangle with a left dot, and a triangle with both dots. Row $2$ shows a square with a top-left dot and a square with a bottom-right dot. What belongs in the blank?
:::answer
The answer is a **square with dots at top-left and bottom-right**. Keep the square outline and place both input dots into cell $3$.
:::

### Combining Shaded Areas and Dot Counts

The keep-all rule also adds shaded areas and dot counts together.

1. In a $2 \times 3$ grid, row $1$ has bottom-half black, top-half black, and a fully black square.
2. Row $2$ has a large bottom-half black square, a large top-half black square, and a blank.
3. Combine bottom half and top half: together they make a **fully black square**.

With dot counts ($1, 2, 3$ in row $1$; $2, 2, 4$ in row $2$), row $3$ starting with $1$ dot and $3$ dots gives $1+3=4$ dots.

:::pair #erase-when-combining
Right: combining a bottom-half black square and a top-half black square makes a **Fully black square**.
Wrong: pick **Fully white square** by erasing the fill.
Shaded pieces stay shaded when combined. Imagine stacking two clear films so every shaded part stays dark.
:::

:::check
A $3 \times 3$ matrix adds dot counts across each row: row $1$ has $2, 1, 3$ dots and row $2$ has $3, 3, 6$ dots. If row $3$ starts with $2$ dots and $4$ dots, how many dots belong in the third cell?
:::answer
The answer is **$6$ dots**. Add the first two counts in row $3$: $2+4=6$.
:::

## Examples

### #1: Keeping All Features

A $3 \times 3$ matrix has three rows. The top row shows a circle with a horizontal line, a circle with a vertical line, and a circle with both lines. The middle row shows a triangle with a dot near the top, a triangle with a dot near the bottom, and a triangle with both dots.

The bottom row shows a square with a diagonal from top-left to bottom-right, a square with a diagonal from bottom-left to top-right, and a blank. What should the blank show?

<!-- ILLUSTRATION: a 3 by 3 grid, top row circles containing a horizontal diameter, a vertical diameter, and both diameters; middle row upward triangles containing a dot near the top, a dot near the bottom center, and both dots at those positions; bottom row squares containing the top-left to bottom-right diagonal, the bottom-left to top-right diagonal, and a blank -->

**Solution:**

1. Row $1$ combines both lines into a cross, and row $2$ combines both dots.
2. Apply the keep-all rule to row $3$: combine both opposite diagonals inside the square.

The blank shows a **square with both diagonals (an X inside)**.

**Check:** Each completed row keeps every mark from cells $1$ and $2$ without dropping anything, so the blank keeps both diagonals.

### #2: Shaded Squares

A $2 \times 3$ matrix uses squares. Row $1$ shows a small bottom-half black square, a small top-half black square, and a small fully black square.

Row $2$ shows a large bottom-half black square, a large top-half black square, and a blank. What should the blank show?

<!-- FIGURE WANTED: a 2 by 3 grid of squares: row 1 small bottom-half black square, small top-half black square, small fully black square; row 2 large bottom-half black square, large top-half black square, blank -->

**Solution:**

1. Row $1$ combines the bottom half and top half into one fully black small square.
2. Row $2$ uses large squares, so the blank stays large.

3. Combine row $2$'s bottom-half black and top-half black shading: together they cover the entire large square.

The blank shows a **large fully black square**.

**Check:** Do not erase the fill to white or keep only one half; all shaded pieces from both starting cells stay filled.

## Traps to Watch For

:::checklist
- Two different marks in one row: keep both inputs in the third cell instead of dropping one. {#keep-only-one-input}
- Row $1$'s picture: combine row $2$'s own marks instead of copying row $1$. {#copy-first-row-parts}
- Combining shaded halves: keep all shaded areas filled instead of erasing them to white. {#erase-when-combining}
:::

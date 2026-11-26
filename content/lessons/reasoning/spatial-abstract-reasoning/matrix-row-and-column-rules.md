---
_id: "lesson-spatial-abstract-reasoning-matrix-row-and-column-rules"
title: "Matrix Row and Column Rules"
summary: "Use row and column rules together to find a missing figure."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
isActive: true
part: 2
partCount: 4
ordering: 8
keyPoints:
  - "Use row and column rules together to find a missing figure."
---
## Core Concept

### Matching Separate Row and Column Rules

A $2 \times 2$ grid has $2$ rows and $2$ columns, while a $3 \times 3$ grid has $3$ rows and $3$ columns. Often one feature follows a rule across rows while a second feature follows a rule down columns.

<!-- ILLUSTRATION: a 3 by 3 grid of triangles, top row all pointing up with 1, 2, and 3 dots, middle row all pointing right with 1, 2, and 3 dots, bottom row pointing down with 1 dot, pointing down with 2 dots, and a blank bottom-right cell -->

1. In the $3 \times 3$ grid above, dot counts across each row go $1, 2, 3$, so column $3$ needs **$3$ dots**.
2. Down each column, triangles point up in row $1$, right in row $2$, and **down** in row $3$.
3. Combining both gives a **down-pointing triangle with $3$ dots**.

Test every rule on all completed rows or columns. Do not copy a feature from the middle row when the column rule keeps changing.

:::why
Why test both directions on all completed lines? Checking one row misses column changes, and checking one pair can hide a rule that fails elsewhere.
:::

:::pair #copy-row-above
Right: when size grows small, medium, large down columns and dots go $1, 2, 3$ across rows, the blank is **Large triangle with three dots**.
Wrong: pick **Medium triangle with three dots** by copying size from row $2$.
Medium belongs to row $2$. Follow size down column $3$ to row $3$'s large size.
:::

:::check
A $3 \times 3$ grid shows stars: row $1$ has small white, small gray, small black; row $2$ has medium white, medium gray, medium black. Row $3$ starts with a large white star and a large gray star, so what belongs in the blank?
:::answer
The answer is a **large black star**. Fill goes white, gray, black across every row, and row $3$ keeps the large size.
:::

### Checking Shifted Cycles and Full-Set Rules

Some $3 \times 3$ grids place the same $3$ shapes, sizes, or positions once in every row and column, shifted by one step per row.

1. Look at a $3 \times 3$ shape grid: row $1$ is circle, triangle, square; row $2$ is triangle, square, circle; row $3$ is square, circle, blank.
2. Every row and column holds each shape once with no repeats.
3. Row $3$ and column $3$ already have square and circle, so the blank is a **triangle**.

In another shifted grid, a dot moves $1$ corner clockwise across every row: row $3$ goes bottom-right, bottom-left, blank. Do not copy top-right from row $2$ above the blank; step clockwise from bottom-left to **top-left**.

:::pair #repeat-in-latin-row
Right: in a one-of-each row (square, circle, ?), pick **Triangle**.
Wrong: pick **Circle** because circle sits beside the blank.
No shape repeats in a one-of-each row. Check both row $3$ and column $3$.
:::

:::pair #copy-cell-above-blank
Right: when dots move clockwise across each row (bottom-right, bottom-left, ?), pick **Square with dot at top-left**.
Wrong: pick **Square with dot at top-right** because top-right sits directly above the blank.
Top-right was row $2$'s ending corner, not a column constant. Continue the clockwise shift across row $3$.
:::

:::check
A $3 \times 3$ grid uses three sizes: row $1$ is small, medium, large; row $2$ is medium, large, small; row $3$ begins large, small. What size belongs in the blank?
:::answer
The answer is **medium**. Each row shifts the cycle one step left, and column $3$ also needs medium after large and small.
:::

## Examples

### #1: Different Rules in Rows and Columns

A $3 \times 3$ matrix uses squares. The top row shows small black, white, and black squares. The middle row shows medium black, white, and black squares.

The bottom row shows a large black square, a large white square, and a blank. What should the blank show?

<!-- ILLUSTRATION: a 3 by 3 grid, top row small black square, small white square, small black square; middle row medium black square, medium white square, medium black square; bottom row large black square, large white square, blank; white squares have visible black outlines -->

**Solution:**

1. Check size down each column: small, medium, large. The blank is **large**.
2. Check fill across each row: black, white, black. Row $3$ starts black, white, so the blank is **black**.
3. Combine both: the blank is a **large black square**.

**Check:** Column $3$ runs small black, medium black, so a large black square satisfies both row and column rules.

### #2: Shapes in a Grid

A $3 \times 3$ matrix contains plain outlines. Row $1$ shows a circle, a triangle, and a square, while row $2$ shows a triangle, a square, and a circle.

Row $3$ shows a square, a circle, and a blank. Which outline completes the blank cell?

<!-- ILLUSTRATION: a 3 by 3 grid of plain unshaded outlines: row 1 circle, triangle, square; row 2 triangle, square, circle; row 3 square, circle, blank -->

**Solution:**

1. Check completed rows $1$ and $2$: each row uses circle, triangle, and square once each.
2. Check completed columns $1$ and $2$: each column also contains circle, triangle, and square once each.

3. Row $3$ and column $3$ already contain square and circle, so the missing outline is a **triangle**.

The blank shows a **triangle**.

**Check:** Do not repeat circle (beside the blank) or square (start of row $3$); every row and column uses each shape once.

## Traps to Watch For

:::checklist
- Separate row and column traits: follow size down columns instead of copying from the row above. {#copy-row-above}
- One-of-each grids: check all three positions in the blank's row and column so no item repeats. {#repeat-in-latin-row}
- Shifted cycles: continue the row's movement into the blank instead of copying the cell above. {#copy-cell-above-blank}
:::

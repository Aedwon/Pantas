---
_id: "lesson-spatial-abstract-reasoning-matrix-keeping-shared-features"
title: "Matrix Rules: Keeping Shared Features"
summary: "Keep only features shared by both starting cells."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
isActive: true
part: 4
partCount: 4
ordering: 10
keyPoints:
  - "Keep only features shared by both starting cells."
---
## Core Concept

### Telling Shared-Only Rules Apart from Keep-All Rules

A **combination rule** builds the third cell from the first two cells in a row or column. Under a **shared-only rule**, the third cell keeps **only** the marks that appear in **both** starting cells at the same spot.

1. In row $1$, a circle with up and right rays and a circle with up and down rays give a circle with **only the up ray**.
2. Right and down disappear because each was in only one starting cell.
3. In row $2$, cell $1$ has upper-right and lower-right rays; cell $2$ has lower-right and lower-left rays.
4. Only the **lower-right ray** is in both cells, so the blank keeps only that ray.

:::why
Why check row $1$'s third cell before working on row $2$? The starting cells look the same as a keep-all problem until the third cell shows whether unshared marks are dropped.
:::

:::pair #keep-all-instead-of-shared
Right: when row $1$ keeps only the shared ray, row $2$ keeps **Square with only the lower-right ray**.
Wrong: pick **Square with all three diagonal rays** by combining every ray.
Completed row $1$ dropped unshared rays. Never use the keep-all rule when row $1$ removes marks.
:::

:::pair #copy-second-cell-instead
Right: compare cell $1$ and cell $2$ to keep only **Square with only the lower-right ray**.
Wrong: pick **Square with the lower-right and lower-left rays** by copying cell $2$.
Copying cell $2$ keeps an unshared mark (lower-left). Compare both starting cells first.
:::

:::check
In row $1$, a circle with a horizontal line and top dot, plus a circle with a horizontal line and bottom dot, gives a circle with only the horizontal line. Row $2$ shows a square with a vertical line and left dot, then a square with a vertical line and right dot. What belongs in the blank?
:::answer
The answer is a **square with only a vertical line**. Both starting squares share the vertical line, while the dots appear in only one cell each.
:::

### Checking Every Feature Position

When cells hold several marks, check each corner one by one.

<!-- ILLUSTRATION: three rows of three squares with corner dots: row 1 (top-left and top-right), (top-right and bottom-left), (top-right); row 2 (bottom-left and bottom-right), (top-left and bottom-left), (bottom-left); row 3 (top-left, top-right, bottom-right), (top-left, bottom-left, bottom-right), blank -->

Find row $3$'s blank cell:

1. Row $1$ keeps **top-right**, and row $2$ keeps **bottom-left**.
2. In row $3$, test all four corners across cell $1$ (top-left, top-right, bottom-right) and cell $2$ (top-left, bottom-left, bottom-right):
   - Top-left: in both cells -> **keep**.
   - Top-right (cell $1$ only) and bottom-left (cell $2$ only) -> drop.
   - Bottom-right: in both cells -> **keep**.
3. The blank keeps **top-left and bottom-right**.

:::pair #stop-after-one-shared-mark
Right: test all four corners in row $3$ to keep **Top-left, bottom-right**.
Wrong: pick **Top-left corner only** after spotting top-left first.
Two or more marks can be shared at once. Check every position before stopping.
:::

:::check
In a shared-only row, cell $1$ has dots at top-left, top-right, and bottom-left, while cell $2$ has dots at top-right, bottom-left, and bottom-right. Which dots belong in cell $3$?
:::answer
The answer is **top-right and bottom-left**. Those two positions appear in both starting cells.
:::

## Examples

### #1: Keeping Only Shared Features

A $3 \times 3$ matrix uses squares with lines inside. In row $1$, the first square has a horizontal and a vertical line.

The second has the same horizontal line and a diagonal from top-left to bottom-right. The third has only the horizontal line.

In row $2$, the first square has a vertical line and a diagonal from bottom-left to top-right. The second has the same vertical line and a horizontal line. The third has only the vertical line.

In row $3$, the first square has both diagonals. The second has a horizontal line and the diagonal from top-left to bottom-right.

The third cell is blank. What should it show?

<!-- ILLUSTRATION: a 3 by 3 grid of equal squares with all internal lines crossing the center; row 1 horizontal plus vertical, horizontal plus top-left to bottom-right diagonal, horizontal only; row 2 vertical plus bottom-left to top-right diagonal, vertical plus horizontal, vertical only; row 3 both diagonals, horizontal plus top-left to bottom-right diagonal, blank -->

**Solution:**

1. Rows $1$ and $2$ keep only the single line present in both starting squares (horizontal in row $1$, vertical in row $2$).
2. Row $3$ starts with both diagonals in cell $1$, and the horizontal line plus top-left-to-bottom-right diagonal in cell $2$.
3. Keep only the line shared by both cells: the **diagonal from top-left to bottom-right**.

The blank shows a **square with only the diagonal from top-left to bottom-right**.

**Check:** Unshared lines drop out in rows $1$ and $2$, confirming the third square keeps shared full lines rather than joining all lines.

### #2: Corner Dots in a Grid

A $3 \times 3$ matrix shows squares with corner dots. Row $1$ shows (top-left, top-right), then (top-right, bottom-left), then (top-right).

Row $2$ shows (bottom-left, bottom-right), then (top-left, bottom-left), then (bottom-left). Row $3$ shows (top-left, top-right, bottom-right), then (top-left, bottom-left, bottom-right), and a blank. Which corner dots belong in the blank square?

<!-- ILLUSTRATION: a 3 by 3 grid of equal squares with large corner dots: row 1 has (top-left, top-right), (top-right, bottom-left), (top-right); row 2 has (bottom-left, bottom-right), (top-left, bottom-left), (bottom-left); row 3 has (top-left, top-right, bottom-right), (top-left, bottom-left, bottom-right), blank -->

**Solution:**

1. Rows $1$ and $2$ keep only dots found in the exact same corners of both starting squares.
2. In row $3$, test top-left (in both -> keep) and top-right (cell $1$ only -> drop).

:::try
Finish the last step: test bottom-left and bottom-right in row $3$, and list all corner dots for the blank square.
:::answer
The answer is **top-left and bottom-right**. Bottom-left is only in cell $2$ (drop), while bottom-right is in both cells (keep), leaving top-left and bottom-right.

**Check:** Testing all four corners avoids stopping at top-left alone or keeping unshared corners.
:::

## Traps to Watch For

:::checklist
- Shared-only matrices: check a completed row first so you do not keep all marks by mistake. {#keep-all-instead-of-shared}
- Marks next to the blank: compare both starting cells instead of copying cell $2$. {#copy-second-cell-instead}
- Multiple marks in each cell: test every position one by one so you do not stop after one match. {#stop-after-one-shared-mark}
:::

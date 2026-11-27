---
_id: "lesson-spatial-abstract-reasoning-matrix-turns-and-counts"
title: "Matrix Turns and Counts"
summary: "Track a whole figure and its details through a turn."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
isActive: true
part: 1
partCount: 4
ordering: 7
keyPoints:
  - "Track a whole figure and its details through a turn."
  - "Check dot counts across rows and down columns."
---
## Core Concept

### Tracking Turns Across Rows and Columns

A **figure matrix** is a grid of figures with one blank **cell** (one grid box). Rows run left to right, and columns run top to bottom.

**Rotation** turns a figure around a center point. A **clockwise** turn follows clock hands; a **counterclockwise** turn goes the opposite way. Quarter, eighth, and half turns measure $90^\circ$, $45^\circ$, and $180^\circ$.

Find row $2$'s blank direction in a $2 \times 2$ grid where row $1$ turns $90^\circ$ clockwise from up ($0^\circ$) to right ($90^\circ$) and row $2$ starts down ($180^\circ$):

1. Turn $90^\circ$ clockwise from $180^\circ$: $180^\circ+90^\circ=270^\circ$ (**left**).

Some $3 \times 3$ grids increase the turn step from row to row: row $1$ turns $+45^\circ$ ($0^\circ, 45^\circ, 90^\circ$), row $2$ turns $+90^\circ$ ($0^\circ, 90^\circ, 180^\circ$), and row $3$ turns $+135^\circ$ ($0^\circ, 135^\circ, 270^\circ$ = left). Keep the same step across the whole row.

:::why
Why apply row $1$'s turn rule to row $2$'s starting figure instead of copying row $1$'s answer? Row $2$ can start in a different direction or outline, so only the turn rule repeats.
:::

:::pair #copy-first-row-direction
Right: row $1$ turns $+90^\circ$ (up to right), so row $2$ turns $+90^\circ$ from down to **Square with line pointing left**.
Wrong: pick **Square with line pointing right** by copying row $1$'s ending direction.
Row $2$ started pointing down, not up. Start the turn from the blank row's own first cell.
:::

:::pair #change-turn-step-in-row
Right: in row $3$ ($0^\circ \to 135^\circ \to ?$), repeat the $+135^\circ$ step to get $270^\circ$ (**Line pointing left**).
Wrong: pick **Line pointing down** ($180^\circ$) by stepping only $+45^\circ$ after $135^\circ$.
The turn step stays constant across that row. Measure from cell $1$ to cell $2$ first.
:::

:::check
In a $2 \times 2$ matrix, row $1$ shows a circle with a top-left dot, then a top-right dot. Row $2$ starts with a square with a bottom-right dot. Where should the dot sit in the blank square?
:::answer
The answer is **bottom-left**. Row $1$ moves $1$ corner clockwise, and $1$ corner clockwise from bottom-right is bottom-left.
:::

### Tracking Counts Across Rows and Columns

Write dot or line counts in each cell as numbers, then check each completed row and column.

Find the blank dot count in a $3 \times 3$ grid (row $1$: $1, 2, 3$; row $2$: $2, 3, 4$; row $3$: $3, 4,$ blank):

1. Row $3$ and column $3$ both add $1$ per step ($3 \to 4 \to 5$), giving **$5$ dots**.

:::pair #add-row-and-column-twice
Right: row $3$ ($3, 4, ?$) and column $3$ ($3, 4, ?$) both give **Circle with five dots**.
Wrong: pick **Circle with six dots** by adding $+1$ for the row and $+1$ for the column.
Row and column rules describe the same single cell. Never add both steps together.
:::

:::check
A $3 \times 3$ matrix has squares with $2, 4, 6$ dots in row $1$ and $4, 6, 8$ dots in row $2$. Row $3$ begins with $6$ and $8$ dots. How many dots belong in the blank?
:::answer
The answer is **$10$ dots**. Both row $3$ ($6 \to 8 \to 10$) and column $3$ ($6 \to 8 \to 10$) add $2$ dots per step.
:::

## Examples

### #1: A Visible Rotation Rule

A $2 \times 2$ matrix has an up-pointing triangle with a dot near its top point, followed by a right-pointing triangle with a dot near its right point. The bottom-left cell has a square with a thick top side and a dot near its top-left corner. What should the blank bottom-right cell show?

<!-- ILLUSTRATION: a 2 by 2 grid, top-left an upward triangle with a dot near its top point, top-right the same triangle rotated 90 degrees clockwise with the dot near its right point, bottom-left a square with a thick top side and a dot just inside its top-left corner, bottom-right blank -->

**Solution:**

1. Row $1$ turns the triangle and dot $90^\circ$ clockwise (up to right).
2. Turn the bottom-left square $90^\circ$ clockwise: its thick top side moves to the **right side**, and its top-left dot moves to the **top-right corner**.

The blank shows a **square with a thick right side and a dot near its top-right corner**.

**Check:** A plain square looks unchanged after $90^\circ$, so tracking the thick side and dot confirms the turn.

### #2: Increasing Dot Counts

A $3 \times 3$ matrix shows circles with dot counts. Row $1$ has $1$, $2$, and $3$ dots. Row $2$ has $2$, $3$, and $4$ dots.

Row $3$ has $3$, $4$, and a blank. How many dots should the blank cell have?

<!-- ILLUSTRATION: a 3 by 3 grid of equal circles, row 1 containing 1, 2, and 3 dots, row 2 containing 2, 3, and 4 dots, row 3 containing 3 dots, 4 dots, and a blank bottom-right cell -->

**Solution:**

1. Rows $1$ and $2$ add $1$ dot per step ($1 \to 2 \to 3$ and $2 \to 3 \to 4$).
2. Row $3$ ($3 \to 4 \to 5$) and column $3$ ($3 \to 4 \to 5$) both give **$5$ dots**.

The blank shows a **circle with $5$ dots**.

**Check:** Do not add $+1$ twice to get $6$; row $3$ and column $3$ agree on $5$.

### #3: Lines in Squares

A $3 \times 3$ matrix shows squares with one center line. Row $1$ lines point up, upper-right, and right, while row $2$ lines point up, right, and down.

Row $3$ lines point up, lower-right, and a blank. Which direction does the line point in the blank cell?

<!-- FIGURE WANTED: a 3 by 3 grid of equal squares each with one radial line from the center: row 1 up, upper-right, right; row 2 up, right, down; row 3 up, lower-right, blank -->

**Solution:**

1. Row $1$ turns $+45^\circ$ per step ($0^\circ \to 45^\circ \to 90^\circ$).
2. Row $2$ turns $+90^\circ$ per step ($0^\circ \to 90^\circ \to 180^\circ$).
3. Row $3$ starts with $+135^\circ$ clockwise ($0^\circ \to 135^\circ$).

4. Apply the $+135^\circ$ turn to lower-right ($135^\circ$): $135^\circ+135^\circ=270^\circ$, which points straight left.

The blank shows a **line pointing left**.

**Check:** Column $3$ turns $+90^\circ$ per step too (right $90^\circ$, down $180^\circ$, left $270^\circ$), confirming left.

## Traps to Watch For

:::checklist
- Row $1$'s ending picture: apply the turn rule to row $2$'s starting figure instead of copying row $1$. {#copy-first-row-direction}
- Row-specific turn steps: keep the exact degree step from cell $1$ to cell $2$ across the whole row. {#change-turn-step-in-row}
- Increasing row and column counts: verify both directions agree on one number without adding them twice. {#add-row-and-column-twice}
:::

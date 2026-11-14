---
_id: "lesson-spatial-abstract-reasoning-matrix-turns-and-counts"
title: "Matrix Turns and Counts"
summary: "Track a whole figure and its details through a turn."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
isActive: true
part: 1
partCount: 4
ordering: 1.2
keyPoints:
  - "Track a whole figure and its details through a turn."
  - "Check dot counts across rows and down columns."
---
## Core Concept

A **figure matrix** is a grid of figures with one missing cell. A **cell** is one space in the grid. Rows run from left to right, and columns run from top to bottom.

Check one feature at a time. Look at shape, size, shading, dots, and internal lines. Also check **rotation**, which means turning a figure around a fixed point.

A clockwise turn follows the direction of a clock's hands. A $90^\circ$ turn is a quarter turn. When a whole figure turns, its dots and lines turn with it.

## Examples

### #1: A Visible Rotation Rule

A $2 \times 2$ matrix has an up-pointing triangle with a dot near its top point, followed by a right-pointing triangle with a dot near its right point. The bottom-left cell has a square with a thick top side and a dot near its top-left corner. What should the blank bottom-right cell show?

<!-- ILLUSTRATION: a 2 by 2 grid, top-left an upward triangle with a dot near its top point, top-right the same triangle rotated 90 degrees clockwise with the dot near its right point, bottom-left a square with a thick top side and a dot just inside its top-left corner, bottom-right blank -->

**Solution:**

1. Read the top row. The triangle and its dot turn $90^\circ$ clockwise.
2. Turn the whole marked square the same way. Its top side moves to the right side. Its top-left corner moves to the top-right corner.
3. The blank should show a square with a thick right side and a dot near its top-right corner.

A plain square looks unchanged after this turn. The thick side and the dot make the turn visible.

### #2: Increasing Dot Counts

A $3 \times 3$ matrix shows circles with dot counts. Row $1$ has $1$, $2$, and $3$ dots. Row $2$ has $2$, $3$, and $4$ dots.

Row $3$ has $3$, $4$, and a blank. How many dots should the blank cell have?

<!-- ILLUSTRATION: a 3 by 3 grid of equal circles, row 1 containing 1, 2, and 3 dots, row 2 containing 2, 3, and 4 dots, row 3 containing 3 dots, 4 dots, and a blank bottom-right cell -->

**Solution:**

1. In each completed row, the count rises by $1$ at each step.

$$1 \to 2 \to 3$$

$$2 \to 3 \to 4$$

2. Apply the same increase to row $3$.

$$3 \to 4 \to 5$$

3. Check the last column. Its counts also rise by $1$.

$$3 \to 4 \to 5$$

4. The blank should show a circle with $5$ dots.

## Traps to Watch For

### #1: Expecting Every Row to Use the Same Shape

> Different shapes can follow the same change.

A triangle and a marked square can both turn $90^\circ$ clockwise. Track what changes in each row.

### #2: Missing a Small Detail

> Track each changing feature before choosing.

A square outline can look unchanged after a turn. A dot or a thick side can show where it moved. Include those details in the answer.

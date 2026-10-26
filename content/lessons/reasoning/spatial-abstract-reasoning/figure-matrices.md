---
_id: "lesson-spatial-abstract-reasoning-figure-matrices"
title: "Figure Matrices (Completing a 2x2 or 3x3 Grid of Shapes)"
summary: "Follow row, column, and feature-combination rules to complete a missing figure in a grid."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
estimatedMinutes: 12
isActive: true
---
## Core Concept

A **figure matrix** is a grid of figures with one missing cell. A **cell** is one space in the grid. Rows run from left to right, and columns run from top to bottom.

A $2 \times 2$ grid has $2$ rows and $2$ columns. A $3 \times 3$ grid has $3$ rows and $3$ columns. The figures follow a rule across rows, down columns, or both.

Check one feature at a time. Look at shape, size, shading, dots, and internal lines. Also check **rotation**, which means turning a figure around a fixed point.

A clockwise turn follows the direction of a clock's hands. A $90^\circ$ turn is a quarter turn. When a whole figure turns, its dots and lines turn with it.

<!-- ILLUSTRATION: a 3 by 3 grid of triangles, top row all pointing up with 1, 2, and 3 dots, middle row all pointing right with 1, 2, and 3 dots, bottom row pointing down with 1 dot, pointing down with 2 dots, and a blank bottom-right cell -->

A row rule and a column rule can control different features. Dot count may change across a row while direction changes down a column. The missing figure must fit both rules.

A **combination rule** builds a later cell from features in earlier cells. One rule keeps every feature found in either of the first two cells. Another keeps only features found in both cells at the same position.

For example, joining a horizontal line and a vertical line can give a cross. Keeping only shared lines gives a different result: a line stays only if both starting figures have it. Use a completed row or column to find which rule applies.

These are checks to try, not a complete list of possible rules. Test a proposed rule on all completed rows or columns where it should apply. Do not choose a rule just because it fits one pair of cells.

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

A $3 \times 3$ matrix shows circles with dot counts. Row $1$ has $1$, $2$, and $3$ dots. Row $2$ has $2$, $3$, and $4$ dots. Row $3$ has $3$, $4$, and a blank. How many dots should the blank cell have?

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

### #3: Different Rules in Rows and Columns

A $3 \times 3$ matrix uses squares. The top row shows small black, white, and black squares. The middle row shows medium black, white, and black squares. The bottom row shows a large black square, a large white square, and a blank. What should the blank show?

<!-- ILLUSTRATION: a 3 by 3 grid, top row small black square, small white square, small black square; middle row medium black square, medium white square, medium black square; bottom row large black square, large white square, blank; white squares have visible black outlines -->

**Solution:**

1. Check size down the completed columns. The squares change from small to medium to large. The blank must be large.
2. Check shading across the completed rows. Each row follows black, white, black. The blank must be black.
3. The missing figure is a large black square.

### #4: Keeping All Features

A $3 \times 3$ matrix has three rows. The top row shows a circle with a horizontal line, a circle with a vertical line, and a circle with both lines. The middle row shows a triangle with a dot near the top, a triangle with a dot near the bottom, and a triangle with both dots.

The bottom row shows a square with a diagonal from top-left to bottom-right, a square with a diagonal from bottom-left to top-right, and a blank. What should the blank show?

<!-- ILLUSTRATION: a 3 by 3 grid, top row circles containing a horizontal diameter, a vertical diameter, and both diameters; middle row upward triangles containing a dot near the top, a dot near the bottom center, and both dots at those positions; bottom row squares containing the top-left to bottom-right diagonal, the bottom-left to top-right diagonal, and a blank -->

**Solution:**

1. In the top row, the third circle keeps both lines from the first two circles.
2. Check the middle row. The third triangle also keeps all the details from the first two triangles.
3. Apply that rule to the bottom row. Keep both diagonals. The blank should show a square with an X inside.

### #5: Keeping Only Shared Features

A $3 \times 3$ matrix uses squares with lines inside. In row $1$, the first square has a horizontal and a vertical line. The second has the same horizontal line and a diagonal from top-left to bottom-right. The third has only the horizontal line.

In row $2$, the first square has a vertical line and a diagonal from bottom-left to top-right. The second has the same vertical line and a horizontal line. The third has only the vertical line.

In row $3$, the first square has both diagonals. The second has a horizontal line and the diagonal from top-left to bottom-right. The third cell is blank. What should it show?

<!-- ILLUSTRATION: a 3 by 3 grid of equal squares with all internal lines crossing the center; row 1 horizontal plus vertical, horizontal plus top-left to bottom-right diagonal, horizontal only; row 2 vertical plus bottom-left to top-right diagonal, vertical plus horizontal, vertical only; row 3 both diagonals, horizontal plus top-left to bottom-right diagonal, blank -->

**Solution:**

1. In row $1$, both starting squares have the horizontal line in the same position. The third square keeps only that shared line.
2. Row $2$ confirms the rule. Only the vertical line is in both starting squares, so only that line stays.
3. In row $3$, both starting squares have the diagonal from top-left to bottom-right. The other lines are not shared.
4. The blank should show a square with only the diagonal from top-left to bottom-right.

The third cell keeps shared lines, not just the points where different lines cross. Joining every line would fail the completed rows.

## Traps to Watch For

### #1: Checking Only One Direction

> A row and a column can control different features.

Check both directions. A choice can have the right shading but the wrong size.

### #2: Guessing How to Combine Features

> A completed row or column must show what stays.

Some rules keep all features. Others keep only shared features. Check the completed cells before using either rule.

### #3: Expecting Every Row to Use the Same Shape

> Different shapes can follow the same change.

A triangle and a marked square can both turn $90^\circ$ clockwise. Track what changes in each row.

### #4: Missing a Small Detail

> Track each changing feature before choosing.

A square outline can look unchanged after a turn. A dot or a thick side can show where it moved. Include those details in the answer.

### #5: Accepting a Rule After One Match

> Test the rule wherever the grid gives you a complete case.

A rule may fit the top row but fail the middle row. Reject it if it fails a row or column where the same rule should work.

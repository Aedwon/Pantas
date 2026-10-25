---
_id: "lesson-spatial-abstract-reasoning-figure-matrices"
title: "Figure Matrices (Completing a 2x2 or 3x3 Grid of Shapes)"
summary: "Learn how to follow row, column, and feature-combination rules to complete a missing cell in a figure matrix."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
estimatedMinutes: 11
isActive: true
---
## Core Concept

A **figure matrix** is a grid of figures with one missing cell. The figures follow a rule across rows, down columns, or both.

Check the grid in this order:

- **Rows**: look from left to right.
- **Columns**: look from top to bottom.
- **Features**: track shape, size, shading, rotation, dots, and internal lines one at a time.
- **Combination**: in some grids, a later cell puts together features from earlier cells.

<!-- FIGURE: {"kind": "figure-matrix", "rows": 3, "cols": 3, "cells": [{"form": "triangle", "rotation": 0, "dots": 1}, {"form": "triangle", "rotation": 0, "dots": 2}, {"form": "triangle", "rotation": 0, "dots": 3}, {"form": "triangle", "rotation": 90, "dots": 1}, {"form": "triangle", "rotation": 90, "dots": 2}, {"form": "triangle", "rotation": 90, "dots": 3}, {"form": "triangle", "rotation": 180, "dots": 1}, {"form": "triangle", "rotation": 180, "dots": 2}, "blank"], "semanticsLabel": "A 3 by 3 grid of shapes where dots increase across rows and shapes rotate down columns, with the bottom-right cell left blank."} -->

A row rule and a column rule can control different features at the same time. For example, size may change down a column while shading changes across a row.

A **combination rule** means the missing cell is built from features already shown in other cells. Use this only when a completed row or column shows the same way of combining features.

## Examples

### #1: A Visible Rotation Rule

A $2 \times 2$ matrix has an up-pointing triangle with a dot near its top point, followed by the same triangle turned $90^\circ$ clockwise. The dot turns with the triangle. The bottom-left cell has a square with a dot in its top-left corner. What should the blank bottom-right cell show?

<!-- ILLUSTRATION: a 2 by 2 grid, top-left an upward triangle with a dot near the top point, top-right the same triangle turned 90 degrees clockwise with the dot near the right point, bottom-left a square with a dot in the top-left corner, bottom-right blank -->

**Solution:**

1. Read the completed top row. The whole marked figure turns $90^\circ$ clockwise.
2. Apply the same turn to the marked square. The square outline looks the same, but its dot moves from the top-left corner to the top-right corner.
3. The blank should show a square with a dot in the top-right corner.

### #2: Increasing Dot Counts

A $3 \times 3$ matrix shows circles with dot counts. Row $1$ has $1$, $2$, and $3$ dots. Row $2$ has $2$, $3$, and $4$ dots. Row $3$ has $3$, $4$, and a blank. How many dots should the blank cell have?

<!-- FIGURE: {"kind": "figure-matrix", "rows": 3, "cols": 3, "cells": [{"form": "circle", "dots": 1}, {"form": "circle", "dots": 2}, {"form": "circle", "dots": 3}, {"form": "circle", "dots": 2}, {"form": "circle", "dots": 3}, {"form": "circle", "dots": 4}, {"form": "circle", "dots": 3}, {"form": "circle", "dots": 4}, "blank"], "semanticsLabel": "A 3 by 3 grid of circles with increasing dot counts and a blank bottom-right cell."} -->

**Solution:**

1. Across each row, the dot count goes up by $1$.
2. Row $3$ follows $3 \to 4 \to ?$.
3. The blank should show a circle with $5$ dots.

### #3: Different Rules in Rows and Columns

A $3 \times 3$ matrix uses squares. Moving down a column, size changes from small to medium to large. Moving across a row, shading follows black, white, black. The bottom-right cell is blank. What size and shading should it have?

<!-- FIGURE: {"kind": "figure-matrix", "rows": 3, "cols": 3, "cells": [{"form": "square", "size": "small", "fill": "black"}, {"form": "square", "size": "small", "fill": "white"}, {"form": "square", "size": "small", "fill": "black"}, {"form": "square", "size": "medium", "fill": "black"}, {"form": "square", "size": "medium", "fill": "white"}, {"form": "square", "size": "medium", "fill": "black"}, {"form": "square", "size": "large", "fill": "black"}, {"form": "square", "size": "large", "fill": "white"}, "blank"], "semanticsLabel": "A 3 by 3 grid where shapes grow larger down columns and alternate black and white across rows, with the bottom-right cell left blank."} -->

**Solution:**

1. Check the column rule. The blank is in the bottom row, so its size must be large.
2. Check the row rule. The bottom row must follow black, white, black.
3. The blank should show a large black square.

### #4: Combining Features

A $3 \times 3$ matrix has a completed row of circles. The first circle has a horizontal line. The second has a vertical line. The third has both lines. Another row has a square with one diagonal line, then a square with the other diagonal line, then a blank. What should the blank show?

<!-- FIGURE: {"kind": "figure-matrix", "rows": 2, "cols": 3, "cells": [{"form": "circle", "line": 90}, {"form": "circle", "line": 0}, {"form": "circle", "lines": [90, 0]}, {"form": "square", "line": 45}, {"form": "square", "line": 135}, "blank"], "semanticsLabel": "Two matrix rows showing a combination rule: the third circle combines horizontal and vertical lines, and the third square is left blank."} -->

**Solution:**

1. Read the completed circle row. The third cell keeps both lines from the first two cells.
2. Apply the same rule to the square row. Keep both diagonal lines.
3. The blank should show a square with both diagonals, forming an X.

## Traps to Watch For

### #1: Checking Only One Direction

> A row can show one rule while a column shows another.

Check both directions before choosing the missing figure. One direction may tell you the size while the other tells you the shading or another feature.

### #2: Guessing a Combination Rule Too Early

> Use a combination rule only when a completed row or column shows how the features combine.

Do not join features just because two cells look related. First find a completed part of the grid that proves the same rule.

### #3: Expecting the Same Exact Figures in Every Row

> The starting figures can differ while the change stays the same.

A triangle and a marked square can both follow a $90^\circ$ clockwise turn. Focus on what changes, not only on the shape name.

### #4: Missing One Feature

> Track shape, size, shading, rotation, dots, and internal lines separately.

A choice can match the shape but fail the shading rule. Check every feature that changes before you answer.

---
_id: "lesson-spatial-abstract-reasoning-figure-matrices"
title: "Figure Matrices (Completing a 2x2 or 3x3 Grid of Shapes)"
summary: "Learn how to find the pattern across rows and columns of a figure matrix and determine the missing shape."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
estimatedMinutes: 10
isActive: true
---
## Core Concept

A **figure matrix** arranges shapes in a grid (commonly $2 \times 2$ or $3 \times 3$), where the figures follow a consistent pattern moving across each row and/or down each column. One cell (usually the bottom-right) is left blank, and you must determine which figure correctly completes the pattern.

Two directions to check for a pattern:

- **Row pattern**: does each figure change in a consistent way as you move left to right across a row (similar to a figure series)?
- **Column pattern**: does each figure change in a consistent way as you move top to bottom down a column?

<!-- FIGURE: {"kind": "figure-matrix", "rows": 3, "cols": 3, "cells": [{"form": "square", "dots": 1}, {"form": "square", "dots": 2}, {"form": "square", "dots": 3}, {"form": "square", "dots": 1}, {"form": "square", "dots": 2}, {"form": "square", "dots": 3}, {"form": "square", "dots": 1}, {"form": "square", "dots": 2}, "blank"], "semanticsLabel": "A 3 by 3 grid of squares where dots increase across rows and shapes rotate down columns, with the bottom-right cell left blank."} -->

Some matrices follow a single pattern that applies consistently in one direction (only across rows, or only down columns). Others combine two patterns at once: one rule governing rows, and a different rule governing columns simultaneously, similar to combining features in a figure series.

A useful additional check for $3 \times 3$ matrices: sometimes the third figure in a row (or column) is some combination of the first two (like the union or overlap of their features), rather than following a simple step-by-step progression.

## Examples

### #1: A Simple Row Pattern

A $2 \times 2$ matrix's top row shows a triangle, then a triangle rotated $90°$. The bottom row shows a square, then (blank). What should the blank cell show?

<!-- FIGURE: {"kind": "figure-matrix", "rows": 2, "cols": 2, "cells": [{"form": "triangle"}, {"form": "triangle"}, {"form": "square"}, "blank"], "semanticsLabel": "A 2 by 2 grid with triangles in the top row and a square and an empty cell in the bottom row."} -->


**Solution:**
1. Identify the row pattern: moving left to right, each shape rotates $90°$.
2. Apply the same row pattern to the bottom row: starting with a square, rotating it $90°$ gives a square that looks the same as an unrotated square (since a square has rotational symmetry every $90°$), but if the square has some distinguishing mark (like a dot in one corner), that mark would move to the next corner.
3. The blank cell should show a square rotated $90°$ from the first bottom-row square (with any distinguishing mark shifted accordingly).

### #2: A Combined Row-and-Column Pattern

A $3 \times 3$ matrix's rows show an increasing number of dots inside a circle: row 1 has circles with $1$, $2$, $3$ dots; row 2 has circles with $2$, $3$, $4$ dots; row 3 has circles with $3$, $4$, and (blank). How many dots should the blank cell have?

<!-- FIGURE: {"kind": "figure-matrix", "rows": 3, "cols": 3, "cells": [{"form": "circle", "dots": 1}, {"form": "circle", "dots": 2}, {"form": "circle", "dots": 3}, {"form": "circle", "dots": 2}, {"form": "circle", "dots": 3}, {"form": "circle", "dots": 4}, {"form": "circle", "dots": 3}, {"form": "circle", "dots": 4}, "blank"], "semanticsLabel": "A 3 by 3 grid of circles with increasing dot counts and a blank bottom-right cell."} -->


**Solution:**
1. Identify the row pattern: within each row, the dot count increases by $1$ moving left to right ($1 \to 2 \to 3$, then $2 \to 3 \to 4$).
2. Confirm this same increase applies to row 3: $3 \to 4 \to \, ?$, continuing the "+1" pattern.
3. The blank cell should show a circle with $5$ dots.

### #3: A Matrix Testing Both Directions Separately

A $3 \times 3$ matrix's columns show a shape's size growing (small, medium, large) moving top to bottom, while its rows show the shape's shading alternating (black, white, black) moving left to right. Given the blank is in the bottom-right cell, what size and shading should it have?

<!-- FIGURE: {"kind": "figure-matrix", "rows": 3, "cols": 3, "cells": [{"form": "square", "size": "small", "fill": "black"}, {"form": "square", "size": "small", "fill": "white"}, {"form": "square", "size": "small", "fill": "black"}, {"form": "square", "size": "medium", "fill": "black"}, {"form": "square", "size": "medium", "fill": "white"}, {"form": "square", "size": "medium", "fill": "black"}, {"form": "square", "size": "large", "fill": "black"}, {"form": "square", "size": "large", "fill": "white"}, "blank"], "semanticsLabel": "A 3 by 3 grid where shapes grow larger down columns and alternate black and white across rows, with the bottom-right cell left blank."} -->


**Solution:**
1. Check the column pattern for size: since the blank is in the bottom row, and size grows small → medium → large moving down each column, the blank's size should be large.
2. Check the row pattern for shading: since the blank is in the right-most position of its row, and shading alternates black → white → black moving across, the blank's shading should be black (continuing the alternation from the pattern established in that row).
3. The blank cell should show a large, black shape.

### #4: Using the "Combination" Rule

A $3 \times 3$ matrix's first row shows: a circle with a horizontal line, a circle with a vertical line, and a circle with both a horizontal and a vertical line (a plus-sign pattern) in the third cell. If the same combination rule applies to another row showing a square with a diagonal line (top-left to bottom-right) and a square with the other diagonal line (top-right to bottom-left), what should the third cell in that row show?

<!-- FIGURE: {"kind": "figure-matrix", "rows": 2, "cols": 3, "cells": [{"form": "circle", "line": 90}, {"form": "circle", "line": 0}, {"form": "circle"}, {"form": "square", "line": 45}, {"form": "square", "line": 135}, "blank"], "semanticsLabel": "Two rows of shapes showing a combination rule with the last cell left blank."} -->


**Solution:**
1. Identify the combination rule from the completed first row: the third cell combines both features from the first two cells (horizontal line + vertical line = both lines together).
2. Apply the same combination logic to the second row: the third cell should combine both diagonal lines from the first two cells.
3. The third cell should show a square with both diagonal lines drawn (forming an X pattern).

## Speed Tricks & Shortcuts

**Check rows first, then columns, then consider combination patterns if neither alone fully explains the grid.** Most matrices use one of these three approaches, so working through them in order is an efficient default strategy.

**For $3 \times 3$ matrices specifically, always check whether the third item in a row or column is a combination of the first two**, since this pattern type appears frequently and is easy to miss if you're only looking for simple step-by-step progressions.

**Track each visual feature (shape, size, shading, rotation, dot count) separately across the grid**, exactly like in figure series questions, since a matrix can combine multiple independently-changing features.

## Traps to Watch For

### #1: Checking Only Rows or Only Columns, Not Both

> Many matrices require checking both the row pattern and the column pattern together: solving only one direction may give an incomplete or wrong answer, especially when different features follow different directional rules.

Example 3 shows how size follows the column direction while shading follows the row direction: solving only one direction misses half the required answer.

### #2: Missing a "Combination" Pattern in a 3x3 Matrix

> The third figure in a row or column is sometimes the overlap or combination of the first two, rather than a simple next-step continuation.

Assuming the third cell should follow a simple incrementing pattern (like a figure series) when it is actually meant to combine features from the first two cells leads to a plausible but incorrect prediction.

### #3: Assuming All Rows Share the Exact Same Individual Figures

> Different rows or columns can apply the same transformation rule to different starting shapes: do not expect literally identical figures across rows, only a consistent pattern of change.

In Example 1, the top row and bottom row start with completely different shapes (triangle vs. square), but the same rotation rule ($90°$ rotation) applies to both: recognizing the rule, not memorizing specific shapes, is the key skill.

---
_id: "lesson-arithmetic-number-sense-growing-square-borders"
title: "Growing Square Borders"
summary: "Find the number of tiles on the border of a growing square."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 3
partCount: 5
ordering: 0
keyPoints:
  - "Connect a figure's number to its side length and border count."
---
## Core Concept

### Growing Square Borders

A **border** is the outside row of tiles around a figure. In a filled square with side length $s$ tiles, there are $s^2$ tiles in total. Removing its border leaves an inner square with side length $s-2$.

For a whole-number side length $s\geq2$, the border count is:

$\text{border}=s^2-(s-2)^2$

You can also count the top and bottom rows, then the side tiles between them:

$\text{border}=2s+2(s-2)=4s-4$

Both rules count each corner once. For a single tile, the border count is $1$; these rules do not apply to that case.

If a pattern starts with side length $a$ and grows by $1$ tile per side each time, Figure $n$ has side length $a+(n-1)$. The **nth figure** means the figure at position $n$. First find its side length, then count its border.

## Examples

### #1: Border Tiles in a Growing Display

Figure $1$ is a $4$ by $4$ square of tiles. Figure $2$ is $5$ by $5$, and Figure $3$ is $6$ by $6$. Each new figure adds $1$ tile to each side length. Only the border tiles are blue. How many blue tiles are in Figure $12$?

<!-- ILLUSTRATION: Three filled square tile grids labeled Figure 1, Figure 2, and Figure 3, with side lengths 4, 5, and 6 tiles respectively; color only their outermost tiles blue and leave interiors white; do not show Figure 12 or border totals. -->

**Solution:**

1. Find how many growth steps come after Figure $1$.

$12-1=11$

2. Add these steps to the first side length.

$s=4+11=15$

3. The inside has $2$ fewer tiles along each side because a border row is removed from both ends.

$15-2=13$

4. Subtract the inside tile count from the full tile count.

$15^2-13^2=225-169$

$225-169=56$

5. Check by counting the top and bottom rows, then the sides between them.

$2\times15+2\times13=56$

Figure $12$ has $56$ blue tiles.

## Speed Tricks & Shortcuts

### Find the Side Before the Border

The figure number may differ from its side length. Write the starting side length and the number of growth steps first. Then use the border rule.

## Traps to Watch For

### #1: Counting Corners Twice

> Adding four full sides counts each corner twice.

For a square border with side length at least $2$, subtract $4$ from $4s$. Each of the four corners needs one extra count removed.

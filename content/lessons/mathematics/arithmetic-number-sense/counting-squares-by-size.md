---
_id: "lesson-arithmetic-number-sense-counting-squares-by-size"
title: "Counting Squares by Size"
summary: "Count squares of every size in complete and incomplete grids."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 2
partCount: 5
ordering: 0
keyPoints:
  - "Count squares by size before adding them."
---
## Core Concept

### Counting Squares by Size

A grid is a figure made from rows and columns of small squares. A square can cover several of those small squares. Count each possible size separately.

In a complete $n$ by $n$ grid, $n$ is the number of small squares along each side. For a square with side $k$ small squares, there are $n-k+1$ starting positions across and the same number down. So its count is:

$(n-k+1)^2$

Here $n$ is a positive whole number, and $k$ runs from $1$ through $n$. Add the counts to get:

$\text{total}=1^2+2^2+\cdots+n^2$

The dots mean continue through the square of each whole number up to $n$. This is a **sum of squares**. Count squares whose sides follow the grid lines, not tilted squares made from diagonal lines.

For a figure with missing parts, check which squares still have complete sides. Do not use the full-grid total without checking the missing lines.

## Examples

### #1: Squares in a Complete Grid

A square window is divided into a $4$ by $4$ grid of equal small squares. How many squares of all sizes have sides along the grid lines?

<!-- ILLUSTRATION: A complete 4 by 4 square grid with equal cells, labeled 4 small squares across and 4 small squares down; no count totals or highlighted solution squares. -->

**Solution:**

1. Count squares with side length $1$. Each small cell is one square.

$4\times4=16$

2. Count squares with side length $2$. Their left edges can start in the first $3$ columns. Their top edges can start in the first $3$ rows.

$3\times3=9$

3. A square with side length $3$ has $2$ starting positions across and $2$ down.

$2\times2=4$

4. The whole window is one square with side length $4$.

$1\times1=1$

5. Add the counts for the different sizes.

$16+9+4+1=30$

There are $30$ squares. Counting just the small cells would miss the larger ones.

### #2: Squares in a Figure with a Missing Corner

Start with a $3$ by $3$ grid of unit squares. Remove the upper-right cell and its top and right outer edges. Keep the other grid lines. How many complete squares remain, using the grid lines as sides?

<!-- ILLUSTRATION: A 3 by 3 unit-square grid with the upper-right cell absent, including its top and right outer edges; retain all boundaries of the other eight cells; no highlighted groups or answer totals. -->

**Solution:**

1. Count the remaining unit squares. One cell was removed.

$9-1=8$

2. A complete $3$ by $3$ grid has $2\times2=4$ positions for a square with side length $2$. Check them by their upper-left corners: top left, top middle, middle left, and center.

3. The square starting at the top middle needs the removed upper-right corner. Its sides are incomplete. The other three positions still have complete sides.

$4-1=3$

4. A square with side length $3$ would need the full outside boundary. That boundary is broken, so there are $0$ squares of this size.

5. Add the counts.

$8+3+0=11$

The figure contains $11$ complete squares.

## Speed Tricks & Shortcuts

### Count Positions, Not Guesses

For squares in a full grid, count starting positions across and down. For an incomplete figure, list the possible positions and cross out those with broken sides. Overlapping squares still count as separate squares.

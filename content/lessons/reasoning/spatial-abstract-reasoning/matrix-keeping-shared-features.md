---
_id: "lesson-spatial-abstract-reasoning-matrix-keeping-shared-features"
title: "Matrix Rules: Keeping Shared Features"
summary: "Keep only features shared by both starting cells."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
isActive: true
part: 4
partCount: 4
ordering: 1.8
keyPoints:
  - "Keep only features shared by both starting cells."
---
## Core Concept

A **combination rule** builds a later cell from features in earlier cells. One rule keeps every feature found in either of the first two cells. Another keeps only features found in both cells at the same position.



## Examples

### #1: Keeping Only Shared Features

A $3 \times 3$ matrix uses squares with lines inside. In row $1$, the first square has a horizontal and a vertical line.

The second has the same horizontal line and a diagonal from top-left to bottom-right. The third has only the horizontal line.

In row $2$, the first square has a vertical line and a diagonal from bottom-left to top-right. The second has the same vertical line and a horizontal line. The third has only the vertical line.

In row $3$, the first square has both diagonals. The second has a horizontal line and the diagonal from top-left to bottom-right.

The third cell is blank. What should it show?

<!-- ILLUSTRATION: a 3 by 3 grid of equal squares with all internal lines crossing the center; row 1 horizontal plus vertical, horizontal plus top-left to bottom-right diagonal, horizontal only; row 2 vertical plus bottom-left to top-right diagonal, vertical plus horizontal, vertical only; row 3 both diagonals, horizontal plus top-left to bottom-right diagonal, blank -->

**Solution:**

1. In row $1$, both starting squares have the horizontal line in the same position. The third square keeps only that shared line.
2. Row $2$ confirms the rule. Only the vertical line is in both starting squares, so only that line stays.
3. In row $3$, both starting squares have the diagonal from top-left to bottom-right. The other lines are not shared.
4. The blank should show a square with only the diagonal from top-left to bottom-right.

The third cell keeps shared lines, not just the points where different lines cross. Joining every line would fail the completed rows.

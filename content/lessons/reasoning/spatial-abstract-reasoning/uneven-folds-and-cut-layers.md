---
_id: "lesson-spatial-abstract-reasoning-uneven-folds-and-cut-layers"
title: "Uneven Folds and Cut Layers"
summary: "Count only the layers actually reached by a punch."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
isActive: true
part: 4
partCount: 4
ordering: 14
keyPoints:
  - "Count only the layers actually reached by a punch."
---
## Core Concept

### Finding Which Area Has Two Layers

An **uneven fold** creates a $2$-layer **overlap** only where the folded flap lands.

When a shorter left flap folds right onto a wider sheet (or intersect the reflected flap with the stationary sheet):

1. Mark the fold line from the left edge.
2. Measure the flap width.
3. Add them on the folded side, stopping at the right edge.

For a $16\text{ cm}$ sheet with its leftmost $6\text{ cm}$ strip folded right at $6\text{ cm}$:

- Since $12 < 16\text{ cm}$, the flap covers $6$ to $12\text{ cm}$ ($2$ layers); $12$ to $16\text{ cm}$ stays $1$ layer.
- Away from creases and edges, a full-depth punch at $10\text{ cm}$ cuts **$2$ layers** ($2$ holes); at $14\text{ cm}$, it cuts **$1$ layer** ($1$ hole).

:::pair #guess-overlap-without-measuring
Right: folding a $6\text{ cm}$ strip right across $6\text{ cm}$ covers $6$ to $12\text{ cm}$; a full-depth punch through both layers at $(10, 3)$ makes **$(2, 3)$ and $(10, 3)$**.
Wrong: pick **$(10, 3)$ only, with no second hole** guessing $10\text{ cm}$ misses the flap.
Add flap width to fold line ($6+6=12$, capped at right edge) first.
:::

:::check
A $14\text{ cm}$ wide rectangle has its leftmost $5\text{ cm}$ strip folded right along a vertical line $5\text{ cm}$ from the left edge. Between which two distances from the left edge does the $2$-layer overlap lie?
:::answer
The answer is **between $5\text{ cm}$ and $10\text{ cm}$**. The $5\text{ cm}$ flap folds across $5\text{ cm}$ and ends at $5+5=10\text{ cm}$.
:::

### Reflecting Inside the Overlap and Checking Cut Depth

Even inside an overlap, count **only layers actually cut**. A shallow cut through just the top layer leaves **$1$ hole**, not $2$.

When a punch cuts **both** layers across a vertical fold:

1. Find sideways distance from the fold.
2. Step that distance to the opposite side.
3. Keep height unchanged.

For $(10, 3)$ across a vertical fold at $6\text{ cm}$, $10-6=4\text{ cm}$ right reflects to $6-4=2\text{ cm}$ at height $3\text{ cm}$: **$(2, 3)$ and $(10, 3)$**.

:::why
Why does the height stay $3\text{ cm}$? A vertical fold flips paper left and right across a vertical line, so distances from the bottom edge never move.
:::

:::pair #assume-all-layers-cut
Right: a shallow cut through only the top layer away from folds and edges leaves **One hole**.
Wrong: pick **Two holes** because the paper was folded once.
Reflection copies a cut only into layers the blade pierced. Check cut depth before doubling.
:::

:::pair #flip-both-directions-on-one-fold
Right: a full-depth punch through both layers at $(10, 3)$ across a vertical fold at $6\text{ cm}$ keeps height $3\text{ cm}$: **$(2, 3)$ and $(10, 3)$**.
Wrong: pick **$(2, 5)$ and $(10, 3)$** by also flipping height inside an $8\text{ cm}$ sheet.
One vertical fold reflects sideways position only. Across a vertical fold, punch height always stays unchanged.
:::

:::check
A $15\text{ cm}$ wide, $8\text{ cm}$ tall sheet has its leftmost $5\text{ cm}$ strip folded right across $5\text{ cm}$. A punch cuts both layers at $(8, 2)$. What are the coordinates of the reflected hole?
:::answer
The answer is **$(2, 2)$**. The punch is $8-5=3\text{ cm}$ right of the fold, so its mirror lies $5-3=2\text{ cm}$ from the left edge, with height still $2\text{ cm}$.
:::

## Examples

### #1: A Punch Through Only Some Layers

A $12\text{ cm}$ wide, $6\text{ cm}$ tall sheet has its leftmost $4\text{ cm}$ strip folded right along $4\text{ cm}$.

A small hole is punched at $(10, 3)\text{ cm}$. How many holes appear when opened, and where?

<!-- ILLUSTRATION: rectangle 12 cm wide and 6 cm tall with vertical fold at 4 cm from left edge; arrow folds leftmost 4 cm strip right onto region from 4 cm to 8 cm; show two layers between 4 cm and 8 cm and one layer between 8 cm and 12 cm; punch at 10 cm from original left edge and 3 cm from bottom; unfolded sheet shows only that one hole -->

**Solution:**

1. Find the overlap: the $4\text{ cm}$ flap folds right across $4\text{ cm}$, covering $4$ to $4+4=8\text{ cm}$.
2. Locate the punch at $10\text{ cm}$: since $10>8$, it lies in the $1$-layer region outside the overlap.
3. Opening the flap adds no second hole because the flap never reached $10\text{ cm}$.

The open sheet has **$1$ hole** at $(10, 3)$ in centimeters.

**Check:** Reflecting $10$ across the fold at $4$ gives $x = 2 \times 4 - 10 = -2$, which lies outside the original $0$-to-$12\text{ cm}$ sheet, so only $(10, 3)$ exists.

### #2: Finding Hole Coordinates Inside an Uneven Overlap

A $16\text{ cm}$ wide, $8\text{ cm}$ tall sheet has its leftmost $6\text{ cm}$ strip folded right along $6\text{ cm}$. A full-depth punch cuts at $(10, 3)\text{ cm}$, touching no fold or edge.

When opened, where are the hole centers in centimeters (from left edge, from bottom)?

<!-- ILLUSTRATION: rectangle 16 cm wide and 8 cm tall with vertical fold line at x=6 cm; leftmost 6 cm strip folded right onto region x=6 to x=12 cm; punch marked at (10, 3) inside the 2-layer overlap; unfolded state not shown -->

**Solution:**

1. Find the overlap: folding the $6\text{ cm}$ strip right across $6\text{ cm}$ covers $6$ to $6+6=12\text{ cm}$.
2. Check $(10, 3)$: since $10$ is between $6$ and $12$, the punch cuts both layers.
3. Measure distance from the fold line: $10-6=4\text{ cm}$ right of the fold.

:::try
Finish the last step: reflect the hole $4\text{ cm}$ to the left of the $6\text{ cm}$ fold line and give both hole positions.
:::answer
The answer is **$(2, 3)$ and $(10, 3)$**. Moving $4\text{ cm}$ left of $6\text{ cm}$ gives $6-4=2\text{ cm}$, while the height stays $3\text{ cm}$.

**Check:** Both $2$ and $10$ are $4\text{ cm}$ from the fold at $6$ ($6-2=4$ and $10-6=4$), and the height $3$ is unchanged by a vertical fold.
:::

## Traps to Watch For

:::checklist
- Uneven flaps: add the flap width to the fold line (and stop at the sheet's edge) to find the exact overlap range before counting distinct off-crease holes. {#guess-overlap-without-measuring}
- Partial-depth cuts: count only layers the blade actually pierces, even inside a $2$-layer fold. {#assume-all-layers-cut}
- Coordinate reflections: change only the coordinate across the fold line, keeping height unchanged for a vertical fold. {#flip-both-directions-on-one-fold}
:::

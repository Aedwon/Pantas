---
_id: "lesson-spatial-abstract-reasoning-folding-and-checking-cube-nets"
title: "Folding and Checking Cube Nets"
summary: "Fold the full net to find opposite faces."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
isActive: true
part: 2
partCount: 3
ordering: 16
keyPoints:
  - "Fold the full net to find opposite faces."
  - "Reject a net whose squares overlap on a cube face."
---
## Core Concept

### Folding the Full Net Face by Face

A **cube net** is a flat pattern of $6$ connected squares folding along shared edges into $6$ cube faces with no overlap.

Skip flat shortcuts. Fold step by step:

1. Hold one square flat as a reference.
2. Fold adjacent squares up $90^\circ$.
3. Keep folding $90^\circ$ along each next edge.
4. Check opposite faces.

<!-- FIGURE: {"kind": "cube-net", "cells": [[0, 1], [1, 0], [1, 1], [1, 2], [2, 1], [3, 1]], "labels": ["side", "side", "bottom", "side", "side", "top"], "showFolded": true, "semanticsLabel": "A cross-shaped cube net folded step by step into six distinct cube faces."} -->

Trace a cross net with A at top, B-C-D across the middle, E below C, and F below E:

1. Hold C as the **bottom**.
2. Fold A to back, B to left, D to right, and E to front.
3. Fold F by $90^\circ$ from E over the open top. F becomes the **top**.
4. Opposite pairs: **A and E; B and D; C and F**.

:::why
Why does folding beat a "skip one square" rule? Skipping one square works in a straight strip, yet misleads you on bent nets like staircases. Folding by $90^\circ$ at each edge works on every net.
:::

:::pair #stop-at-neighbor
Right: in a strip C-E-F with bottom C, E folds to front and F folds across to top (**F**)
Wrong: E
Stopping at E picks C's attached neighbor instead of finishing the second $90^\circ$ fold. Edge-sharing squares can never be opposite.
:::

:::pair #flat-distance-opposite
Right: in the cross net (A above C, B-C-D across, E then F below C), opposites are **A and E; B and D; C and F**
Wrong: A and F; B and C; D and E
Flat distances mislead because $90^\circ$ folds wrap arms together: F reaches top while A rises up the back, so A and F share an edge instead of opposing.
:::

:::check
A staircase net steps down from A to B, right to C, down to D, right to E, and down to F. With A as top, which face folds to bottom?
:::answer
The answer is **D**. B folds down to front, C turns to right, and D folds from C onto the bottom across from A.
:::

### Rejecting Nets That Overlap

Six connected squares do not guarantee a cube net. Every square must hit a different face: top, bottom, front, back, left, right. Two squares on one face fail.

Test a straight row of $6$ squares (A, B, C, D, E, F from left to right):

1. Hold A as **front**.
2. Fold B to **right**, C to **back**, and D to **left**.
3. Fold E by $90^\circ$ from D: E lands on **front**, overlapping A.
4. Since E overlaps A and leaves top and bottom open, a $6$-square row fails.

:::pair #count-guarantees-cube
Right: all $6$ squares reach $6$ distinct cube faces with no overlap
Wrong: Six connected squares must form a cube.
Matching the $6$ faces of a cube is not enough. Fold every square to verify that no two overlap.
:::

:::check
A row of $4$ squares A, B, C, D has E attached above A and F attached above C. Does it fold into a cube?
:::answer
The answer is **no**. A through D wrap around the four sides, while E and F both fold onto the top and overlap.
:::

## Examples

### #1: Opposite Face in a Familiar Cross Net

A cross net has $1$ center square with $4$ edge-neighbors and $1$ extra square beyond the lower neighbor. If the center becomes the bottom, which face becomes the top?

<!-- FIGURE: {"kind": "cube-net", "cells": [[0, 1], [1, 0], [1, 1], [1, 2], [2, 1], [3, 1]], "labels": ["side", "side", "bottom", "side", "side", "top"], "semanticsLabel": "A cross-shaped cube net with the center labeled bottom and the far end of the vertical arm labeled top."} -->

**Solution:**

1. Hold the center flat as the bottom.
2. Fold all $4$ edge-neighbors upward by $90^\circ$ as side faces.
3. Fold the extra square by $90^\circ$ over the open top.

The extra square becomes the **top**, opposite the center.

**Check:** The extra square turns $90^\circ$ twice from the bottom, landing parallel to the bottom on the sole remaining top face.

### #2: Invalid Net by Overlap

Four squares A, B, C, D sit in a row, and $2$ squares (E, then F) stack directly above B. Does this pattern form a cube?

<!-- FIGURE: {"kind": "cube-net", "cells": [[0, 1], [1, 1], [2, 0], [2, 1], [2, 2], [2, 3]], "semanticsLabel": "A flat pattern of six squares with four in a row and two stacked directly above the second square."} -->

**Solution:**

1. Hold B as **front**.
2. Fold A $90^\circ$ to **left**.
3. Fold C $90^\circ$ to **right**.
4. Fold D $90^\circ$ from C to **back**.
5. Fold E $90^\circ$ up from B to **top**.
6. Fold F $90^\circ$ down from E to **back**, overlapping D.

The pattern is **not a valid cube net** because D and F overlap.

**Check:** Five directions are filled (front, left, right, top, back twice) and bottom is open, confirming overlap.

### #3: Faces of a Folded Net

A row of $4$ squares reads B, C, D, E from left to right, with A above B and F below E. Fold the net into a cube. Which set meets at one corner: (A, B, D), (A, B, F), or (A, B, C)?

<!-- ILLUSTRATION: flat net of six labeled squares with B, C, D, E in one horizontal row, A directly above B, and F directly below E -->

**Solution:**

1. Hold B as **front**.
2. Fold C from B to **right**.
3. Fold D from C to **back**.
4. Fold E from D to **left**.
5. Fold A up from B to **top**.
6. Fold F down from E to **bottom**.

:::try
Finish the last step: name the set of three faces that meet at one corner.
:::answer
The answer is **A, B, C**. The opposite pairs are A and F, B and D, and C and E. Faces that oppose each other never share a corner, so only A (top), B (front), and C (right) meet at the top-front-right corner.

**Check:** Folding brings A's right edge directly onto C's top edge, so A and C share an entire edge whose front endpoint lies on B.
:::

## Speed Tricks & Shortcuts

**Opposite faces never touch.** Edge-sharing squares in the net cannot be opposite, and opposite cube faces never meet at a corner.

## Traps to Watch For

:::checklist
- Attached neighbor on the path to top: finish the second $90^\circ$ fold instead of stopping early. {#stop-at-neighbor}
- Far ends of a flat net: fold every square instead of judging flat distance. {#flat-distance-opposite}
- Six connected squares: track all six face directions to catch overlaps. {#count-guarantees-cube}
:::

---
_id: "lesson-spatial-abstract-reasoning-folding-and-checking-cube-nets"
title: "Folding and Checking Cube Nets"
summary: "Fold the full net to find opposite faces."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
isActive: true
part: 2
partCount: 3
ordering: 3.5
keyPoints:
  - "Fold the full net to find opposite faces."
  - "Reject a net whose squares overlap on a cube face."
---
## Core Concept

### Cube Nets

A **cube net** is a connected pattern of $6$ squares that can fold into the $6$ faces of a cube without overlap.

There is no safe rule such as "$2$ squares with $1$ square between them are always opposite." The rest of the net matters. The reliable method is to track each face while folding:

1. Choose a square as a reference face.
2. Fold each square that touches it by $90^\circ$.
3. Keep folding across the net.
4. Check that all $6$ squares reach different faces of the cube with no overlap.

For a familiar cross net, you may be able to see the result quickly. The same folding method still explains why it works.

<!-- FIGURE: {"kind": "cube-net", "cells": [[0, 1], [1, 0], [1, 1], [1, 2], [2, 1], [3, 1]], "labels": ["side", "side", "bottom", "side", "side", "top"], "showFolded": true, "semanticsLabel": "A cross-shaped cube net folded step by step into six distinct cube faces."} -->

## Examples

### #1: Opposite Face in a Familiar Cross Net

A cross net has $1$ central square with $4$ edge-neighbors and $1$ extra square attached beyond one of those neighbors. If the center becomes the bottom, which face becomes the top?

**Solution:**

1. Fold the $4$ neighbors upward to make the side faces.
2. Fold the extra square over the open side of the cube.

The extra square becomes the face opposite the center, so it is the **top**. This result comes from folding this net, not from a flat-spacing rule.

<!-- FIGURE: {"kind": "cube-net", "cells": [[0, 1], [1, 0], [1, 1], [1, 2], [2, 1], [3, 1]], "labels": ["side", "side", "bottom", "side", "side", "top"], "semanticsLabel": "A cross-shaped cube net with the center labeled bottom and the far end of the vertical arm labeled top."} -->

### #2: Invalid Net by Overlap

A pattern has $6$ squares. $4$ are in a row, and $2$ more form a stack above the second square. Does the pattern form a cube?

**Solution:**

When you track the folds, $2$ squares try to occupy the same cube face before all $6$ faces are filled. The pattern is **not a valid cube net**.

<!-- FIGURE: {"kind": "cube-net", "cells": [[0, 1], [1, 1], [2, 0], [2, 1], [2, 2], [2, 3]], "semanticsLabel": "A flat pattern of six squares with four in a row and two stacked directly above the second square."} -->

## Traps to Watch For

### #1: Using a Flat-Spacing Rule for Opposite Faces

> Opposite cube faces come from the full fold, not from a single spacing pattern in the flat net.

A tempting wrong answer treats a local spacing pattern as a rule for every net. Fold the full net instead and check where each face lands.

### #2: Assuming Any $6$ Connected Squares Form a Cube Net

> A valid net must fold into $6$ different cube faces with no overlap.

A connected pattern can still make $2$ squares land on the same face. That overlap makes the net invalid.

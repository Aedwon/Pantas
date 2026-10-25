---
_id: "lesson-spatial-abstract-reasoning-mental-rotation-3d-visualization"
title: "Mental Rotation and 3D Visualization (Cube Nets and Shadows)"
summary: "Learn how to preserve spatial relationships while rotating objects, folding cube nets, and interpreting simplified shadow projections."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
estimatedMinutes: 11
isActive: true
---
## Core Concept

**Mental rotation** asks whether $2$ views can show the same solid object after you turn it without flipping it. A turn keeps the same parts touching and keeps the same shape and distances.

**Handedness** means the object's left-hand or right-hand arrangement. Your left and right hands are mirror forms. You can turn your left hand, but turning alone does not make it become your right hand.

To compare $2$ views, track a few clear parts together:

1. Pick $3$ easy-to-follow parts, such as a long arm, a short arm, and a marked face.
2. Check that the same parts still touch.
3. Imagine turning the whole object. Track where the chosen parts move together.
4. If the view works only after a mirror flip, it is not the same rotation.

A useful check is to trace $3$ parts around the same corner. A turn keeps their order around that corner. A mirror image reverses that order.

### Cube Nets

A **cube net** is a connected pattern of $6$ squares that can fold into the $6$ faces of a cube without overlap.

There is no safe rule such as "$2$ squares with $1$ square between them are always opposite." The rest of the net matters. The reliable method is to track each face while folding:

1. Choose a square as a reference face.
2. Fold each square that touches it by $90^\circ$.
3. Keep folding across the net.
4. Check that all $6$ squares reach different faces of the cube with no overlap.

For a familiar cross net, you may be able to see the result quickly. The same folding method still explains why it works.

<!-- FIGURE: {"kind": "cube-net", "cells": [[0, 1], [1, 0], [1, 1], [1, 2], [2, 1], [3, 1]], "labels": ["side", "side", "bottom", "side", "side", "top"], "showFolded": true, "semanticsLabel": "A cross-shaped cube net folded step by step into six distinct cube faces."} -->

### Shadows and Projections

Some shadow questions use **parallel rays**, which means the light rays travel in the same direction. A **projection** is the flat shape formed on a surface when those rays pass the object.

A nearby point light sends rays outward from one place, so the shadow can become larger or change shape. The simple projection rule applies only when the question uses parallel light or a distant-source model.

Marks painted on a solid do not change its outline. A hole changes the shadow only when light can pass through it in the shown direction.

## Examples

### #1: Comparing Two Turned Views

An original solid has $3$ unequal arms meeting at a joint: a long arm, a medium arm, and a short arm. Candidate A and Candidate B show $2$ possible turned views. Which candidate can show the same solid after rotation?

<!-- ILLUSTRATION: original 3D joint with long, medium, and short arms meeting at one point; Candidate A shows the same three-arm order after a turn; Candidate B shows the mirrored three-arm order; label long, medium, and short in every view -->

**Solution:**

1. Track the long, medium, and short arms. Their lengths and connections must stay the same.
2. Candidate A keeps the same order of the arms around the joint. Turning the whole object can make that view.
3. Candidate B reverses the order around the joint. That needs a mirror flip, so it cannot come from rotation alone.

The correct choice is **Candidate A**.

### #2: Opposite Face in a Familiar Cross Net

A cross net has $1$ central square with $4$ edge-neighbors and $1$ extra square attached beyond one of those neighbors. If the center becomes the bottom, which face becomes the top?

**Solution:**

1. Fold the $4$ neighbors upward to make the side faces.
2. Fold the extra square over the open side of the cube.

The extra square becomes the face opposite the center, so it is the **top**. This result comes from folding this net, not from a flat-spacing rule.

<!-- FIGURE: {"kind": "cube-net", "cells": [[0, 1], [1, 0], [1, 1], [1, 2], [2, 1], [3, 1]], "labels": ["side", "side", "bottom", "side", "side", "top"], "semanticsLabel": "A cross-shaped cube net with the center labeled bottom and the far end of the vertical arm labeled top."} -->

### #3: Invalid Net by Overlap

A pattern has $6$ squares. $4$ are in a row, and $2$ more form a stack above the second square. Does the pattern form a cube?

**Solution:**

When you track the folds, $2$ squares try to occupy the same cube face before all $6$ faces are filled. The pattern is **not a valid cube net**.

<!-- FIGURE: {"kind": "cube-net", "cells": [[0, 1], [1, 1], [2, 0], [2, 1], [2, 2], [2, 3]], "semanticsLabel": "A flat pattern of six squares with four in a row and two stacked directly above the second square."} -->

### #4: Cylinder, Parallel Light from Above

An upright cylinder receives parallel light straight downward onto a horizontal ground plane. What is its ideal shadow?

**Solution:**

The projection along the cylinder's axis is a **circle** with the same diameter as the cylinder.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "cylinder-shadow-above", "labels": ["Light from above", "Circular shadow"], "semanticsLabel": "An upright cylinder with light shining from above, casting a circular shadow on the ground."} -->

### #5: Cylinder, Parallel Light from the Side

The same upright cylinder receives horizontal parallel light and casts a shadow onto a vertical wall that faces the rays. What is its ideal shadow?

**Solution:**

The side projection is a **rectangle**. Its height matches the cylinder's height, and its width matches the cylinder's diameter.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "cylinder-shadow-side", "labels": ["Light from side", "Rectangular shadow"], "semanticsLabel": "An upright cylinder with light shining from the side, casting a rectangular shadow on the wall."} -->

## Traps to Watch For

### #1: Using a Flat-Spacing Rule for Opposite Faces

> Opposite cube faces come from the full fold, not from a single spacing pattern in the flat net.

A tempting wrong answer treats a local spacing pattern as a rule for every net. Fold the full net instead and check where each face lands.

### #2: Assuming Any $6$ Connected Squares Form a Cube Net

> A valid net must fold into $6$ different cube faces with no overlap.

A connected pattern can still make $2$ squares land on the same face. That overlap makes the net invalid.

### #3: Confusing a Mirror Image with a Rotation

> Turning an object does not change its handedness.

A mirror image can keep the same lengths and many of the same connections, which makes it look close. Check the order of clear parts around a corner to catch the flip.

### #4: Treating Every Shadow Like Parallel Light

> The simple projection rule works only when the light rays are parallel.

A nearby point source sends rays outward, so the shadow can change in size or shape. Do not use the parallel-light answer unless the question gives that model.

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

**Mental rotation** asks whether two views can represent the same rigid object after rotation. A true rotation preserves distances, adjacency, handedness/chirality, and the relative arrangement of parts. A mirror image is not generally obtainable by rotation alone.

### Cube Nets

A **cube net** is a connected arrangement of six squares that can be folded into the six distinct faces of a cube without overlap.

There is no safe universal shortcut such as "two squares with exactly one square between them are always opposite." The same local-looking arrangement can behave differently depending on the rest of the net. The reliable method is to **track face orientations while folding**:

1. choose one square as a reference face;
2. assign each edge-neighbor the face direction produced by a $90^\circ$ fold;
3. continue across the net;
4. verify that all six squares reach six distinct cube-face orientations with no two squares occupying the same face.

For simple familiar cross nets, you can often visualize this directly, but mental folding is the underlying method.


<!-- FIGURE: {"kind": "cube-net", "cells": [[0, 1], [1, 0], [1, 1], [1, 2], [2, 1], [3, 1]], "labels": ["side", "side", "bottom", "side", "side", "top"], "showFolded": true, "semanticsLabel": "A cross-shaped cube net folded step by step into six distinct cube faces."} -->
### Shadows and Projections

In simplified technical-reasoning questions, light is often treated as **parallel rays** from a specified direction. Under that model, the shadow on a plane is a projection of the object's silhouette along the light direction.

A real nearby point light can produce perspective enlargement or other differences depending on source distance and screen geometry, so "the shadow is simply the orthographic view" is only valid under the parallel-ray/distant-source simplification.

Surface markings do not affect a silhouette unless they alter transmission or the object's outline. A through-hole may appear in a shadow only when the geometry allows light through it.

## Examples

### #1: Opposite Face in a Familiar Cross Net

A cross net has one central square with four edge-neighbors and one extra square attached beyond one of those neighbors. If the center becomes the bottom, which face becomes the top?

**Solution:**

Fold the four neighbors upward as side faces. The extra square attached beyond one side then folds over to the remaining face opposite the center: the **top**.

This result comes from folding that specific net, not from a universal distance-in-the-flat-net rule.

<!-- FIGURE: {"kind": "cube-net", "cells": [[0, 1], [1, 0], [1, 1], [1, 2], [2, 1], [3, 1]], "labels": ["side", "side", "bottom", "side", "side", "top"], "semanticsLabel": "A cross-shaped cube net with the center labeled bottom and the far end of the vertical arm labeled top."} -->
### #2: Invalid Net by Overlap

A six-square pattern has four squares in a row, with two additional squares extending as a two-square stack above the second square. Does it form a cube?

**Solution:**

Tracking the folds causes two squares to map to the same cube-face orientation before all six distinct faces are filled. The pattern is therefore **not a valid cube net**.

<!-- FIGURE: {"kind": "cube-net", "cells": [[0, 1], [1, 1], [2, 0], [2, 1], [2, 2], [2, 3]], "semanticsLabel": "A flat pattern of six squares with four in a row and two stacked directly above the second square."} -->
### #3: Cylinder, Parallel Light from Above

An upright cylinder receives parallel light straight downward onto a horizontal ground plane. What is its ideal shadow?

**Solution:**

The projection along the cylinder's axis is a **circle** with the cylinder's diameter.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "cylinder-shadow-above", "labels": ["Light from above", "Circular shadow"], "semanticsLabel": "An upright cylinder with light shining from above, casting a circular shadow on the ground."} -->
### #4: Cylinder, Parallel Light from the Side

The same upright cylinder receives horizontal parallel light and casts onto a vertical wall perpendicular to the rays. What is its ideal shadow?

**Solution:**

The side projection is a **rectangle** whose height matches the cylinder's height and whose width matches its diameter.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "cylinder-shadow-side", "labels": ["Light from side", "Rectangular shadow"], "semanticsLabel": "An upright cylinder with light shining from the side, casting a rectangular shadow on the wall."} -->
## Speed Tricks & Shortcuts

**For rotations, preserve handedness and adjacency.** A mirrored arrangement is not a rotation unless the object itself has the relevant symmetry.

**For cube nets, fold orientations instead of relying on flat-grid spacing.** Track where each face points after successive $90^\circ$ folds.

**For shadows, identify the light model and screen.** Parallel rays permit a straightforward projection; point-source shadows depend on source geometry as well.

## Traps to Watch For

### #1: Using a Universal "One Square Between = Opposite" Rule

> Opposite faces are determined by the full fold geometry, not one flat-distance pattern.

### #2: Assuming Any Six Connected Squares Form a Cube Net

> Six squares are necessary but not sufficient; folded faces must occupy six distinct orientations without overlap.

### #3: Confusing Reflection with Rotation

> A rigid rotation preserves handedness. A mirror image generally cannot be produced by turning the object in space.

### #4: Treating Every Shadow as an Orthographic View

> That is the standard simplified result for parallel rays. A nearby point source produces a perspective projection whose size and shape can depend on source and screen positions.

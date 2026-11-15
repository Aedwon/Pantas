---
_id: "lesson-spatial-abstract-reasoning-folded-layers-and-separate-holes"
title: "Folded Layers and Separate Holes"
summary: "Count separate holes only when the punch reaches all doubled layers."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
isActive: true
part: 3
partCount: 4
ordering: 13
keyPoints:
  - "Count separate holes only when the punch reaches all doubled layers."
---
## Core Concept

A **layer** is one thickness of paper. A complete half-fold can double the layers. After $n$ half-folds, where $n$ is the number of folds, the packet can have up to $2^n$ layers at a spot.

This does not always mean $2^n$ separate holes. Check whether the punch reaches every layer at that spot. Also check whether the cut touches a fold or an outside edge.

For a small interior punch through all $2^n$ layers, away from every fold, the open sheet has $2^n$ separate holes. This shortcut needs complete half-folds and separate copies. Cuts that touch folds can join instead.

## Examples

### #1: Interior Hole Away from Two Fold Lines

A square is folded vertically in half, then horizontally in half. A small circular hole is punched through all $4$ layers, away from both folds and all outside edges. How many separate holes appear after unfolding?

<!-- ILLUSTRATION: square folded left onto right, then bottom onto top; small circular punch inside packet away from every edge; opening horizontal fold gives two holes, opening vertical fold gives four holes in mirror positions -->

**Solution:**

1. Open the horizontal fold first. The punch gets a mirror copy on the other side of that fold, giving $2$ holes.
2. Open the vertical fold. Both holes get mirror copies, giving $4$ holes.
3. None touches a fold or another hole. The result is $4$ separate holes.

### #2: Three Folds, Interior Punch

A rectangular sheet is folded in half $3$ times: left onto right, bottom onto top, then left onto right again. A small circular punch passes through all $8$ layers, away from every fold and outside edge. How many separate holes appear?

<!-- ILLUSTRATION: rectangle folded left onto right, bottom onto top, then left onto right; small circular interior punch through all eight layers away from all edges; unfold in reverse order to show eight holes in mirror positions, without implying equal spacing -->

**Solution:**

1. The punch reaches all the layers made by the $3$ complete half-folds.
2. Each opening step doubles the separate copies. The count is:

$$2^3=8$$

3. The open sheet has $8$ separate holes. Their positions mirror the folds, but the gaps between holes need not all be equal.

## Traps to Watch For

### #1: Adding One Hole for Each Fold

> A complete half-fold can double the layers at the cut.

Adding one hole per fold gives the wrong count for a punch through all doubled layers. Check the layers and whether the copies stay separate.

### #2: Always Using the Power-of-Two Count

> Use $2^n$ only when the cut reaches all doubled layers and the copies stay separate.

Cuts on folds may join. A punch outside an overlap may cut only one layer. Neither case follows the separate-hole shortcut.

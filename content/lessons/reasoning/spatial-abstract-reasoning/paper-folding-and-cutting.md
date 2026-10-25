---
_id: "lesson-spatial-abstract-reasoning-paper-folding-and-cutting"
title: "Paper Folding and Cutting Rules"
summary: "Unfold cuts with mirror copies and track the number, shape, and position of the openings."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
estimatedMinutes: 12
isActive: true
---
## Core Concept

**Paper folding and cutting** questions show folded paper with a cut or punch. Predict the open sheet by undoing the folds in reverse order. Open the last fold first.

To **reflect** a cut means to make a mirror copy across a fold line. Put the copy on the opposite side, at the same distance from the line. A cut close to the fold stays close to it after reflection.

A reflection also flips the cut's direction. Across a vertical fold, a right-pointing cut becomes a left-pointing copy. Across a horizontal fold, an upward-pointing cut becomes a downward-pointing copy.

Keep the existing cut when you add its copy. After opening the last fold, open the earlier fold and reflect every cut on the part that unfolds. Repeat until the sheet is flat.

A **layer** is one thickness of paper. A complete half-fold can double the layers. After $n$ half-folds, where $n$ is the number of folds, the packet can have up to $2^n$ layers at a spot.

This does not always mean $2^n$ separate holes. Check whether the punch reaches every layer at that spot. Also check whether the cut touches a fold or an outside edge.

An **interior hole** lies fully inside the paper. A **notch** is a cut that opens onto an edge. A notch on a folded edge can join its mirror copy to make one opening when the sheet opens.

For a small interior punch through all $2^n$ layers, away from every fold, the open sheet has $2^n$ separate holes. This shortcut needs complete half-folds and separate copies. Cuts that touch folds can join instead.

An uneven fold may leave some paper uncovered. A punch there cuts fewer layers than a punch in the overlap. Reflect cuts only where folded paper was actually cut.

<!-- ILLUSTRATION: square folded left half onto right half, then bottom half onto top half; show an interior punch away from both folded edges and arrows opening the horizontal fold first, then the vertical fold, ending with four mirror-position holes -->

## Examples

### #1: Cut on One Fold Line

A square is folded vertically in half. A triangular notch is cut into the folded edge at its midpoint. The triangle has its base on that edge and its tip inside the folded paper. What opening appears when the sheet is opened?

<!-- ILLUSTRATION: square folded left half onto right half; triangular notch at midpoint of vertical folded edge, with base on fold and tip pointing right; unfolded square has one diamond-shaped opening centered on fold -->

**Solution:**

1. The triangle touches the folded edge along its base.
2. Opening the fold adds a left-pointing mirror copy to the right-pointing triangle.
3. The copies meet along their bases. They form one diamond-shaped opening, not $2$ separate holes.

### #2: Interior Hole Away from Two Fold Lines

A square is folded vertically in half, then horizontally in half. A small circular hole is punched through all $4$ layers, away from both folds and all outside edges. How many separate holes appear after unfolding?

<!-- ILLUSTRATION: square folded left onto right, then bottom onto top; small circular punch inside packet away from every edge; opening horizontal fold gives two holes, opening vertical fold gives four holes in mirror positions -->

**Solution:**

1. Open the horizontal fold first. The punch gets a mirror copy on the other side of that fold, giving $2$ holes.
2. Open the vertical fold. Both holes get mirror copies, giving $4$ holes.
3. None touches a fold or another hole. The result is $4$ separate holes.

### #3: Cut at Both Fold Lines

A square is folded vertically in half, then horizontally in half. A small quarter-circle is cut from the corner where the two folded edges meet. Its center is that corner. What opening appears when the sheet is opened?

<!-- ILLUSTRATION: square folded left onto right, then bottom onto top; remove a quarter-circle from the packet corner formed by both folded edges, with arc centered at that corner; first unfolding shows a semicircular cut on remaining fold, full unfolding shows one circular center opening -->

**Solution:**

1. The cut touches both folded edges. Its corner is at the center of the original square.
2. Open the horizontal fold. The quarter-circle and its mirror copy join to make a semicircle.
3. Open the vertical fold. The semicircle joins its mirror copy to make one circular opening at the center.

The cut goes through all the layers. The pieces join at the folds, so the result is one opening.

### #4: Three Folds, Interior Punch

A rectangular sheet is folded in half $3$ times: left onto right, bottom onto top, then left onto right again. A small circular punch passes through all $8$ layers, away from every fold and outside edge. How many separate holes appear?

<!-- ILLUSTRATION: rectangle folded left onto right, bottom onto top, then left onto right; small circular interior punch through all eight layers away from all edges; unfold in reverse order to show eight holes in mirror positions, without implying equal spacing -->

**Solution:**

1. The punch reaches all the layers made by the $3$ complete half-folds.
2. Each opening step doubles the separate copies. The count is:

$$2^3=8$$

3. The open sheet has $8$ separate holes. Their positions mirror the folds, but the gaps between holes need not all be equal.

### #5: A Punch Through Only Some Layers

A rectangular sheet is $12$ centimeters wide and $6$ centimeters tall. Its leftmost $4$-centimeter strip is folded right along a vertical line $4$ centimeters from the left edge. A small hole is punched $10$ centimeters from the original left edge and $3$ centimeters from the bottom. How many holes appear when the paper is opened, and where?

<!-- ILLUSTRATION: rectangle 12 cm wide and 6 cm tall with vertical fold at 4 cm from left edge; arrow folds leftmost 4 cm strip right onto region from 4 cm to 8 cm; show two layers between 4 cm and 8 cm and one layer between 8 cm and 12 cm; punch at 10 cm from original left edge and 3 cm from bottom; unfolded sheet shows only that one hole -->

**Solution:**

1. The folded strip covers the region from $4$ to $8$ centimeters from the original left edge.
2. The punch is at $10$ centimeters. It lies outside that overlap, so it cuts just one layer.
3. Opening the folded strip adds no copy of the hole. That strip was not punched.
4. The open sheet has one hole, still $10$ centimeters from the left edge and $3$ centimeters from the bottom.

There was a fold, but the punch did not pass through the folded part. Count the layers at the punch itself.

## Traps to Watch For

### #1: Adding One Hole for Each Fold

> A complete half-fold can double the layers at the cut.

Adding one hole per fold gives the wrong count for a punch through all doubled layers. Check the layers and whether the copies stay separate.

### #2: Always Using the Power-of-Two Count

> Use $2^n$ only when the cut reaches all doubled layers and the copies stay separate.

Cuts on folds may join. A punch outside an overlap may cut only one layer. Neither case follows the separate-hole shortcut.

### #3: Counting Joined Pieces as Separate Holes

> Cuts that share a folded edge can join when the sheet opens.

A triangular notch on a fold makes one opening in Example $1$. Count the connected opening after unfolding, not each half of it.

### #4: Ignoring Which Layers Were Cut

> Count the layers at the punch, not the thickest part of the packet.

An uneven packet can have different layer counts in different places. Example $5$ has a folded region, but the punch misses it.

### #5: Getting the Count Right but the Position Wrong

> Place each mirror copy at the same distance across the fold.

Two choices may show the same hole count in different places. Open the folds in reverse order and check each hole's distance and direction from the fold.

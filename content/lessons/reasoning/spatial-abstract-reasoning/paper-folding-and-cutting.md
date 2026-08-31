---
_id: "lesson-spatial-abstract-reasoning-paper-folding-and-cutting"
title: "Paper Folding and Cutting Rules"
summary: "Learn how to unfold cuts by reflecting them across fold lines and how folds affect the number, shape, and position of openings."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
estimatedMinutes: 10
isActive: true
---
## Core Concept

**Paper folding and cutting** questions show paper folded one or more times, then cut or punched. To predict the unfolded result, reverse the folds one at a time and reflect the cut across each fold line.

A fold can double the number of layers, so after $n$ simple half-folds the folded packet can contain up to $2^n$ layers. However, **$2^n$ is not automatically the number of separate holes after unfolding**.

The final result depends on:

- whether every fold actually doubles the layers being cut;
- whether the cut passes through all layers;
- whether the cut lies away from every fold line;
- whether reflected copies coincide or join along a fold line;
- whether the cut is an interior hole or a notch on an edge.

For a small interior punch that passes through all $2^n$ layers and lies away from the fold lines, $2^n$ separate copies is a useful special case. If a cut lies **on a fold line**, reflected copies can meet and form one larger connected opening instead.

<!-- FIGURE: {"kind": "paper-fold", "folds": ["vertical", "horizontal"], "cut": "notch", "at": "corner", "showUnfolded": true, "semanticsLabel": "A square folded twice with a cut, then unfolded by reflecting the cut across the horizontal and vertical fold lines."} -->

## Examples

### #1: Cut on One Fold Line

A square is folded vertically in half. A triangular notch is cut **into the folded edge** at the midpoint. What happens when the paper is opened?

<!-- FIGURE: {"kind": "paper-fold", "folds": ["vertical"], "cut": "notch", "at": "on-fold", "showUnfolded": true, "semanticsLabel": "A square folded vertically with a notch cut on the fold, then opened to show a single symmetric connected opening centered on the fold line."} -->

**Solution:**

1. The cut is on the fold line itself.
2. Opening the paper reflects the notch across that line.
3. The reflected halves meet at the fold, so they form **one symmetric connected opening**, not two separated holes.

### #2: Interior Hole Away from Two Fold Lines

A square is folded vertically in half, then horizontally in half. A small circular hole is punched through all four layers at a point **away from both folded edges**. How many separate holes appear after unfolding?

<!-- FIGURE: {"kind": "paper-fold", "folds": ["vertical", "horizontal"], "cut": "hole", "at": "interior", "showUnfolded": true, "semanticsLabel": "A square folded twice with an interior hole away from both folds, then opened to show four symmetrically placed holes."} -->

**Solution:**

1. Two complete half-folds give four layers at the punch.
2. The punch is not on either fold line, so its mirror images remain separate.
3. Undoing the horizontal fold gives two holes; undoing the vertical fold reflects both again.
4. The result is **four separate holes**, arranged symmetrically.

### #3: Hole at the Intersection of Fold Lines

Using the same two-fold setup, suppose a punch is made **exactly at the corner formed by both folded edges**, corresponding to the intersection of the two fold lines in the original sheet. What happens when unfolded?

<!-- FIGURE: {"kind": "paper-fold", "folds": ["vertical", "horizontal"], "cut": "hole", "at": "fold-corner", "showUnfolded": true, "semanticsLabel": "A square folded twice with a cut at the intersection of both fold lines, then opened to show one symmetric opening centered at the intersection."} -->

**Solution:**

Reflecting the cut across either fold maps it onto itself at the intersection. The layers have all been cut, but the copies **coincide or connect at the center** rather than becoming four separated holes. The exact final outline depends on the cut's shape and how it intersects the folded edges.

### #4: Three Folds, Interior Punch

A rectangular sheet is folded in half three times so the punched location contains all eight layers. A small circular punch is made through the interior of the folded packet, away from all fold lines. How many separate holes appear?

**Solution:**

Under these stated conditions,

$$2^3=8,$$

so unfolding produces **eight separate symmetric holes**.

## Speed Tricks & Shortcuts

**Undo folds in reverse order.** Reflect the cut across the last fold first, then the previous fold, until the sheet is fully opened.

**Use $2^n$ only after checking the conditions.** It works for a cut through all doubled layers away from fold lines; it is not a universal separate-hole count.

**Mark fold-line cuts specially.** A cut touching a fold can become one connected shape when reflected.

**Track both count and geometry.** Two answer choices can have the same number of openings but place or orient them differently.

## Traps to Watch For

### #1: Assuming Every Fold Creates One More Hole

> Layer count can double with a complete half-fold; it does not increase one-for-one with fold count.

### #2: Assuming $2^n$ Always Means $2^n$ Separate Holes

> Reflected copies can coincide or merge when a cut lies on one or more fold lines.

### #3: Treating a Fold-Line Notch Like an Interior Punch

> A notch cut into a folded edge reflects into a connected symmetric opening across that fold, not necessarily two separate notches.

### #4: Ignoring Which Layers the Cut Actually Crosses

> Irregular folds or cuts near packet boundaries may not pass through every layer. Count the layers at the cut location, not merely the total number of folds.

### #5: Getting the Count Right but the Placement Wrong

> Each unfolding step is a geometric reflection across a specific fold line. Reconstruct the positions as well as the number of copies.

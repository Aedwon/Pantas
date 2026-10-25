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

**Paper folding and cutting** questions show paper folded at least once, then cut or punched. To predict the open sheet, undo the folds in reverse order and reflect each cut across the fold line.

To **reflect** a cut, make a mirror copy on the other side of the fold line. Every point in the copy must be the same distance from the fold line as the matching point in the original cut. The copy also faces the opposite way, just as it would in a mirror.

Start with the last fold you made. Open that fold and place the reflected copy. Then open the earlier fold and reflect every cut that is now present.

A fold can double the number of layers. After $n$ simple half-folds, the folded packet can contain up to $2^n$ layers. However, **$2^n$ is not always the number of separate holes after unfolding**.

The final result depends on:

- whether each fold doubles the layers at the cut;
- whether the cut passes through all layers;
- whether the cut lies away from every fold line;
- whether reflected copies overlap or join on a fold line;
- whether the cut is an interior hole or a notch on an edge.

For a small interior punch that passes through all $2^n$ layers and stays away from the fold lines, $2^n$ separate copies is a useful special case. If a cut lies **on a fold line**, reflected copies can meet and form a single connected opening.

Track both the number and the position of the openings. $2$ choices can show the same count but place the openings differently.

<!-- FIGURE: {"kind": "paper-fold", "folds": ["vertical", "horizontal"], "cut": "notch", "at": "corner", "showUnfolded": true, "semanticsLabel": "A square folded twice with a cut, then unfolded by reflecting the cut across the horizontal and vertical fold lines."} -->

## Examples

### #1: Cut on One Fold Line

A square is folded vertically in half. A triangular notch is cut **into the folded edge** at the midpoint. What happens when the paper is opened?

**Solution:**

1. The cut is on the fold line itself.
2. Opening the paper makes a mirror copy across that line.
3. Both halves meet at the fold, so they form **a single symmetric connected opening**, not $2$ separated holes.

<!-- FIGURE: {"kind": "paper-fold", "folds": ["vertical"], "cut": "notch", "at": "on-fold", "showUnfolded": true, "semanticsLabel": "A square folded vertically with a notch cut on the fold, then opened to show a single symmetric connected opening centered on the fold line."} -->

### #2: Interior Hole Away from Two Fold Lines

A square is folded vertically in half, then horizontally in half. A small circular hole is punched through all $4$ layers at a point **away from both folded edges**. How many separate holes appear after unfolding?

**Solution:**

1. The $2$ complete half-folds give $4$ layers at the punch.
2. The punch is not on either fold line, so its mirror copies stay separate.
3. Undoing the horizontal fold gives $2$ holes.
4. Undoing the vertical fold reflects both holes again, giving **$4$ separate holes** in symmetric positions.

<!-- FIGURE: {"kind": "paper-fold", "folds": ["vertical", "horizontal"], "cut": "hole", "at": "interior", "showUnfolded": true, "semanticsLabel": "A square folded twice with an interior hole away from both folds, then opened to show four symmetrically placed holes."} -->

### #3: Hole at the Intersection of Fold Lines

Using the same $2$-fold setup, suppose a punch is made **exactly at the corner formed by both folded edges**, where the $2$ fold lines meet in the original sheet. What happens when the paper is unfolded?

**Solution:**

1. The punch sits on both fold lines.
2. Reflecting it across either fold line puts the copy on the same center spot instead of making a separate hole.
3. After both folds are opened, the reflected cuts join at the center.

The result is **a single symmetric center opening**. Its exact outline depends on the cut's shape and how it crosses the folded edges.

<!-- FIGURE: {"kind": "paper-fold", "folds": ["vertical", "horizontal"], "cut": "hole", "at": "fold-corner", "showUnfolded": true, "semanticsLabel": "A square folded twice with a cut at the intersection of both fold lines, then opened to show one symmetric opening centered at the intersection."} -->

### #4: Three Folds, Interior Punch

A rectangular sheet is folded in half $3$ times so the punched location contains all $8$ layers. A small circular punch is made through the interior of the folded packet, away from all fold lines. How many separate holes appear?

**Solution:**

The punch passes through all $8$ layers and stays away from the fold lines, so the special-case count applies:

$$2^3=8$$

The unfolded sheet has **$8$ separate symmetric holes**.

<!-- FIGURE: {"kind": "paper-fold", "folds": ["vertical", "horizontal", "vertical"], "cut": "hole", "at": "interior", "sheet": "rectangle", "showUnfolded": true, "semanticsLabel": "A rectangle folded three times with one cut through all eight layers, then opened to show eight symmetrically placed holes."} -->

## Traps to Watch For

### #1: Assuming Every Fold Creates One More Hole

> A complete half-fold can double the layers at the cut, so hole count does not rise by exactly $1$ per fold.

A wrong choice may add only a single hole for each fold. Count the layers at the cut, then check whether the copies stay separate.

### #2: Assuming $2^n$ Always Means $2^n$ Separate Holes

> The $2^n$ count works only when the cut passes through all doubled layers and stays away from fold lines.

A cut on a fold line can make reflected copies overlap or join. Check the cut position before using the shortcut.

### #3: Treating a Fold-Line Notch Like an Interior Punch

> A notch cut into a folded edge can open into a single connected symmetric shape.

It is easy to count each reflected half as a separate notch. Follow the shared fold edge and see whether the reflected pieces meet.

### #4: Ignoring Which Layers the Cut Actually Crosses

> A cut near an uneven packet boundary may pass through only some layers.

The total number of folds does not tell you how many layers are cut at every spot. Count only the layers that the cut actually reaches.

### #5: Getting the Count Right but the Placement Wrong

> Each unfolding step mirrors the cut across a specific fold line.

$2$ choices may show the same number of openings but put them in different places. Undo the folds in reverse order and track each position.

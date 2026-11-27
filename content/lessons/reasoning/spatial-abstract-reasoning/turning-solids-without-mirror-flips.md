---
_id: "lesson-spatial-abstract-reasoning-turning-solids-without-mirror-flips"
title: "Turning Solids Without Mirror Flips"
summary: "Track parts together while turning a solid."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
isActive: true
part: 1
partCount: 3
ordering: 15
keyPoints:
  - "Track parts together while turning a solid."
  - "Use the order around a corner to detect a mirror flip."
---
## Core Concept

### Tracking Faces During a Turn

**Mental rotation** tests if $2$ views show one solid turned around an **axis** without a mirror flip; distances and connections stay fixed.

In a quarter-turn ($90^\circ$) around an axis through opposite face centers, both axial faces stay in place (markings may turn), opposite faces stay opposite, and middle faces shift one step together.

<!-- FIGURE WANTED: cube with star on top, triangle on front, square on right, cross on back, dot on left, and circle on bottom; vertical axis arrow through top and bottom shows a quarter-turn moving square to front and triangle to left while star stays on top -->

With star top, circle bottom, triangle front, square right, cross back, dot left, make a vertical-axis quarter-turn (right to front) and list top, front, left:

1. Top (**star**) and bottom (circle) stay on the axis.
2. Right (**square**) moves to front.
3. Front (**triangle**) moves to left; left to back; back to right.
4. Order: **star, square, triangle**.

:::pair #axis-faces-stay
Right: star top, circle bottom, triangle front, square right, vertical-axis quarter-turn (right to front) gives **Star, square, triangle**
Wrong: Circle, square, triangle
Swapping top (star) and bottom (circle) turns around a horizontal axis. Keep axial faces in place.
:::

:::pair #move-all-faces-together
Right: star top, triangle front, square right, cross back, vertical-axis quarter-turn (right to front) gives **Star, square, triangle**
Wrong: Star, square, cross
Moving right (square) to front and back (cross) to left turns opposite ways. Push every side face one step together.
:::

:::check
A cube has a heart on top, sun on front, moon on right, key on back, and leaf on left. Make a quarter-turn around the vertical axis so the left face moves to the front. Which symbol is now on the right?
:::answer
The answer is **sun**. Moving left to front pushes the front face (sun) one step to the right.
:::

### Using Corner Order to Catch a Mirror Flip

**Handedness** is a 3D solid's left- or right-hand twist; turning never turns a left hand into a right hand.

Look straight at a corner from outside and read three parts **clockwise**. Turns preserve that cycle (even from a new start); mirrors reverse it.

If outside clockwise order is circle, square, triangle, test View I (triangle, circle, square) and View II (square, circle, triangle):

1. View I from circle: circle, square, triangle (matches).
2. View II from circle: circle, triangle, square (reversed, mirror flip).

:::why
Why can the first label change after a turn? Turning brings a different face to the top of the corner, so you start reading there. Only the direction around the corner stays locked.
:::

:::pair #reversed-corner-order
Right: from outside clockwise circle, square, triangle, **I only** (View I: triangle, circle, square)
Wrong: II only (View II: square, circle, triangle)
View II (square, circle, triangle) reverses the cycle to circle, triangle, square; View I only shifts the start. Trace clockwise from one face.
:::

:::check
Viewed from outside toward a corner, three faces read clockwise as star, heart, moon. After a turn, the reading starts at the heart. Which list is possible: heart, star, moon or heart, moon, star?
:::answer
The answer is **heart, moon, star**. Moon follows heart in the original cycle, while heart, star, moon reverses it.
:::

## Examples

### #1: Comparing Two Turned Views

An original solid has $3$ mutually perpendicular arms (long, medium, short) at a 3D joint. Candidates A and B keep those lengths from the corresponding outside viewpoint looking into that corner. Which shows a rotation?

<!-- ILLUSTRATION: original 3D joint with long, medium, and short arms meeting at one point; Candidate A shows the same three-arm order after a turn; Candidate B shows the mirrored three-arm order; label long, medium, and short in every view -->

**Solution:**

1. Mutually perpendicular arms seen from outside fix one cyclic order around the joint.
2. Original clockwise order from outside: long $\to$ medium $\to$ short.
3. Candidate A keeps long $\to$ medium $\to$ short (rotation); Candidate B reads long $\to$ short $\to$ medium (mirror flip).

Choice: **Candidate A**.

**Check:** From that outside corner, original and Candidate A both cycle long $\to$ medium $\to$ short clockwise; Candidate B reverses to long $\to$ short $\to$ medium.

### #2: Tracking a Quarter-Turn and a Corner

A cube has star top, circle bottom, triangle front, square right, cross back, dot left. Turn one quarter-turn vertically so front moves to right. View the new top-front-right corner from outside.

<!-- FIGURE WANTED: starting cube with star on top, triangle on front, square on right, cross on back, and dot on left; curved arrow around vertical axis moves front to right, tracking the starting top-front-left corner into the new top-front-right corner highlighted by a dashed circle on a second turned cube -->

**Solution:**

1. Front (**triangle**) moves to right.
2. Left (**dot**) moves to front.
3. Vertical axis keeps **star** on top.

:::try
Finish the last step: list the clockwise order of the three faces at the top-front-right corner (viewed from outside), starting from the top face.
:::answer
The answer is **star, triangle, dot**. Top is star ($12$ o'clock), right is triangle ($4$ o'clock), and front is dot ($8$ o'clock), giving star $\to$ triangle $\to$ dot clockwise.

**Check:** Before the turn, that exact corner sat at top-front-left with star at top, triangle at front, and dot at left, which already read star $\to$ triangle $\to$ dot clockwise from outside.
:::

## Speed Tricks & Shortcuts

**Read one loop from any start.** Look straight at the corresponding corner from outside and write its clockwise loop, e.g., circle $\to$ square $\to$ triangle $\to$ circle. Any turn preserves that outside clockwise loop.

## Traps to Watch For

:::checklist
- Spin around one axis: faces on that axis stay fixed and never swap. {#axis-faces-stay}
- Quarter-turn of side faces: push every side face one step in the same direction. {#move-all-faces-together}
- Checking a corner after a turn: trace clockwise from the same starting face to spot a reversed cycle. {#reversed-corner-order}
:::

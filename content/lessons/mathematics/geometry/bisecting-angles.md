---
_id: "lesson-geometry-bisecting-angles"
title: "Bisecting Angles"
summary: "Find the whole angle or either half when a ray bisects it."
subject: "subject-mathematics"
topic: "topic-geometry"
isActive: true
part: 5
partCount: 5
ordering: 0
keyPoints:
  - "Find the whole angle or either half when a ray bisects it."
---
## Core Concept

An **angle bisector** is a ray from the vertex that cuts an angle into two equal angles. If ray $BD$ bisects $\angle ABC$, then $\angle ABD = \angle DBC$. Each of those is half of $\angle ABC$, and $\angle ABC$ is twice either one.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "angle-bisector", "labels": ["A", "B", "C", "D", "Ray BD bisects angle ABC", "Angle ABD = Angle DBC"], "semanticsLabel": "Angle ABC with vertex B and a ray BD inside it. Ray BD splits the angle into two equal angles, angle ABD and angle DBC, each marked with the same arc."} -->

The source notes call the midpoint problem in Points, Lines, and Midpoints Example 4 and the first example here Example 6.

## Examples

### #1: Angle Bisector

Ray $BD$ bisects $\angle ABC$. The measures are $\angle ABD = (2x + 5)^\circ$ and $\angle DBC = (4x - 15)^\circ$. Find $\angle ABC$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "angle-bisector-algebra", "labels": ["A", "B", "C", "D", "(2x + 5)°", "(4x - 15)°"], "semanticsLabel": "Angle ABC with vertex B and ray BD inside it. Angle ABD is labeled 2x plus 5 degrees and angle DBC is labeled 4x minus 15 degrees, and the two are marked equal."} -->

**Solution:**
A bisector makes the two smaller angles equal.

1. Set the two parts equal.

$$2x + 5 = 4x - 15$$

2. Subtract $2x$ from both sides and add $15$ to both sides.

$$20 = 2x$$

$$x = 10$$

3. Each part is $2(10) + 5 = 25^\circ$. Check: $4(10) - 15 = 25$.
4. The question asks for the whole angle, so add the two parts.

$$\angle ABC = 25 + 25 = 50^\circ$$

### #2: Finding a Part from the Whole Angle

Ray $BD$ bisects $\angle ABC$, and $\angle ABC = 84^\circ$. If $\angle ABD = (5x + 2)^\circ$, find $x$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "angle-bisector-whole", "labels": ["A", "B", "C", "D", "84°", "(5x + 2)°"], "semanticsLabel": "Angle ABC measuring 84 degrees with ray BD inside it bisecting the angle. Angle ABD is labeled 5x plus 2 degrees."} -->

**Solution:**
Each half of the angle is half of $84^\circ$.

1. Find one half.

$$\angle ABD = 84 \div 2 = 42$$

2. Set the expression equal to $42$.

$$5x + 2 = 42$$

3. Subtract $2$, then divide by $5$.

$$5x = 40$$

$$x = 8$$

4. Check: $5(8) + 2 = 42$, and $42 + 42 = 84$. Correct.

## Speed Tricks & Shortcuts

For a bisector, the whole angle is twice either half, and each half is the whole divided by $2$. The same is true for a midpoint and a segment.

## Traps to Watch For

### #1: Giving Half When Asked for the Whole

> A midpoint or bisector question may ask for the half or the whole. Read twice.

In Example $4$, solving gives $x = 10$ and a half-length of $23$. The question asks for the whole segment, so the answer is $46$. In Example $6$, the answer is the whole angle, $50^\circ$, not $25^\circ$ and not $x$.

### #2: Bisecting Does Not Mean Perpendicular

> A bisector splits an angle into two equal parts. It does not have to make a right angle.

Example $6$ splits a $50^\circ$ angle into two $25^\circ$ angles. Equal halves does not mean $90^\circ$ halves. The parts are $90^\circ$ each only when the whole angle is a straight angle, $180^\circ$.

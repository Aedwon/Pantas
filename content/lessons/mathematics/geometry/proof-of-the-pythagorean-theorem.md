---
_id: "lesson-geometry-proof-of-the-pythagorean-theorem"
title: "Proof of the Pythagorean Theorem"
summary: "Explain the Pythagorean theorem by comparing the areas in a square."
subject: "subject-mathematics"
topic: "topic-geometry"
isActive: true
part: 8
partCount: 9
ordering: 0
keyPoints:
  - "Explain the Pythagorean theorem by comparing the areas in a square."
---
## Core Concept

**Why it works.** Draw a big square with side $a + b$. On each side, mark a point that splits it into a piece of length $a$ and a piece of length $b$, going around the square the same way each time. Join the marked points in order.

This cuts off four right triangles, one in each corner. Each has legs $a$ and $b$. Each long side of the middle shape is the hypotenuse of one of them, so all four sides of the middle shape equal $c$.

The four corner triangles are congruent by SAS, because each has legs $a$ and $b$ around a right angle. So each has the same two acute angles.

At each corner of the middle shape, the corner angle and the two acute angles of the triangles next to it lie along a straight side of the big square, so they add to $180^\circ$. Going around the square the same way each time puts the two different acute angles of a triangle at each marked point, and these add to $90^\circ$. So each corner is $90^\circ$, and the middle shape is a square of side $c$.

<!-- ILLUSTRATION: square of side a + b, four right triangles (legs a, b) in the corners, tilted square of side c in the middle -->

The big square equals four triangles plus the middle square. Each triangle has area $\dfrac{1}{2}ab$.

$$(a+b)^2 = 4 \cdot \dfrac{1}{2}ab + c^2$$

1. Expand the left side: $(a+b)^2 = a^2 + 2ab + b^2$.
2. Simplify the triangles: $4 \cdot \dfrac{1}{2}ab = 2ab$.
3. So $a^2 + 2ab + b^2 = 2ab + c^2$.
4. Subtract $2ab$ from both sides.

$$a^2 + b^2 = c^2$$

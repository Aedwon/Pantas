---
_id: "lesson-trigonometry-law-of-cosines-for-sides"
title: "Law of Cosines for Sides"
summary: "Find the missing side from two sides and the angle between them."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 4
partCount: 7
ordering: 0
keyPoints:
  - "Find the missing side from two sides and the angle between them."
  - "Use the cosine correction for acute, right, and obtuse angles."
---
## Core Concept

### The Law of Cosines

This law is the Pythagorean theorem with a correction term. Each form below has the side on the left and the angle across from it on the right:

$$c^2 = a^2 + b^2 - 2ab\cos C$$

$$a^2 = b^2 + c^2 - 2bc\cos A \qquad b^2 = a^2 + c^2 - 2ac\cos B$$

If the included angle is a right angle, its cosine is zero and the equation becomes the Pythagorean theorem.

## Examples

### #1: Law of Cosines (SAS)

Two sides of a triangle measure $5$ and $8$, and the angle between them is $60^\circ$. Find the third side.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle", "labels": ["Side = 5", "Side = 8", "Included angle = 60°", "Third side c = ?"], "semanticsLabel": "Triangle with sides 5 and 8 meeting at a 60 degree included angle and opposite side marked with a question mark."} -->

**Solution:**
Two sides with the included angle: Law of Cosines.

1. Set up with $a = 5$, $b = 8$, $C = 60^\circ$.

$$c^2 = 5^2 + 8^2 - 2(5)(8)\cos 60^\circ$$

2. Substitute $\cos 60^\circ = \dfrac{1}{2}$.

$$c^2 = 25 + 64 - 80 \times \dfrac{1}{2}$$

3. Compute.

$$c^2 = 89 - 40 = 49$$

4. Take the square root.

$$c = 7$$

### #2: Two Ships (Exam Level)

Two ships leave the same port at the same time. After one hour, ship $X$ has sailed $3$ km and ship $Y$ has sailed $8$ km, and the angle between their paths is $60^\circ$. How far apart are the ships?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle", "labels": ["Port", "Ship X (3 km)", "Ship Y (8 km)", "Angle = 60°", "Distance d = ?"], "semanticsLabel": "Diagram of two ships leaving a port at a 60 degree angle, sailing 3 km and 8 km, with dashed distance between them marked with a question mark."} -->

**Solution:**
The port and the two ships form a triangle: two sides and the included angle. Law of Cosines.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle", "labels": ["Port", "Path 3 km", "Path 8 km", "60°", "Distance d"], "semanticsLabel": "Triangle formed by port and two ship paths of lengths 3 and 8 spreading at 60 degrees with dashed segment d."} -->

1. Set up.

$$d^2 = 3^2 + 8^2 - 2(3)(8)\cos 60^\circ$$

2. Substitute $\cos 60^\circ = \dfrac{1}{2}$.

$$d^2 = 9 + 64 - 48 \times \dfrac{1}{2}$$

3. Compute.

$$d^2 = 73 - 24 = 49$$

4. Take the square root.

$$d = 7$$

5. The ships are $7$ km apart.

## Traps to Watch For

### #1: Answering with $c^2$

> The Law of Cosines gives the square of the side. Finish with the square root.

After a clean result such as $c^2 = 49$, it is easy to stop at $49$. A wrong choice may list it on purpose. The side is $7$. Circle the square-root step in your scratch work so you never skip it.

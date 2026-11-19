---
_id: "lesson-trigonometry-counting-ssa-triangles"
title: "Counting SSA Triangles"
summary: "Compare the given side with the height to count possible triangles."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 7
partCount: 7
ordering: 37
keyPoints:
  - "Compare the given side with the height to count possible triangles."
---
## Core Concept

A quick check with the sides: if $A$ is acute, let $h = b \sin A$. This is the height from the corner $C$ down to the opposite side.

- If $a < h$: no triangle.
- If $a = h$: one right triangle.
- If $h < a < b$: two triangles.
- If $a \ge b$: one triangle.

If $A$ is $90^\circ$ or more, a triangle exists only when $a > b$. Then there is exactly one. The biggest angle must face the longest side.

## Examples

### #1: SSA With No Triangle, and With a Right Triangle

Angle $A = 30^\circ$ and side $b = 8$. How many triangles exist if (a) $a = 3$, and (b) $a = 4$?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle", "labels": ["A = 30°","b = 8","a = ?"], "semanticsLabel": "Triangle with angle A equal to 30 degrees, side b equal to 8, and side a to be tested."} -->

**Solution:**
Find $\sin B = \dfrac{b \sin A}{a}$ each time.

1. For (a):

$$\sin B = \dfrac{8 \times \frac{1}{2}}{3} = \dfrac{4}{3}$$

2. A sine cannot be more than $1$. Side $a = 3$ is too short to reach the base. No triangle exists.
3. For (b):

$$\sin B = \dfrac{8 \times \frac{1}{2}}{4} = 1$$

4. So $B = 90^\circ$ and $C = 60^\circ$. Exactly one triangle exists, and it is a right triangle.
5. Check: $h = 8 \sin 30^\circ = 4$. In (a), $a < h$. In (b), $a = h$.

## Speed Tricks & Shortcuts

In an SSA problem with an acute $A$, compare $a$ with $h = b \sin A$ and with $b$ before you compute. It tells you how many triangles to expect.

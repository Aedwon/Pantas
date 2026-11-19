---
_id: "lesson-geometry-triangle-side-limits"
title: "Triangle Side Limits"
summary: "Use the triangle inequality to find possible side lengths. Compare side lengths with opposite angles."
subject: "subject-mathematics"
topic: "topic-geometry"
isActive: true
part: 2
partCount: 9
ordering: 17
keyPoints:
  - "Use the triangle inequality to find possible side lengths."
  - "Compare side lengths with opposite angles."
---
## Core Concept

### Sides and Angles

The **Triangle Inequality Theorem** says the sum of any two sides must be greater than the third side. Sides $2$, $3$, and $7$ cannot make a triangle, because $2 + 3 = 5$ is not greater than $7$. The third side must be greater than the difference of the other two sides and less than their sum.

The longest side is across from the largest angle. The shortest side is across from the smallest angle. If two angles are equal, the sides across from them are equal too.

The trap calls the third-side problem Example 2.

## Examples

### #1: Range of the Third Side

Two sides of a triangle measure $5$ and $9$. How many whole-number lengths are possible for the third side?

<!-- ILLUSTRATION: a triangle with two sides labeled 5 and 9 and the third side labeled ? -->

**Solution:**
The third side $s$ must be less than the sum and greater than the difference.

1. Find the limits.

$$9 - 5 < s < 5 + 9$$

2. So $4 < s < 14$. The whole numbers are $5$ through $13$, and $4$ and $14$ are not allowed.
3. There are $9$ possible whole-number lengths.

### #2: Ordering Sides by Angles

In $\triangle ABC$, $\angle A = 50^\circ$ and $\angle B = 60^\circ$. Which side is the longest, and which is the shortest?

**Solution:**
Find the third angle first.

1. $\angle C = 180^\circ - 50^\circ - 60^\circ = 70^\circ$.

2. The largest angle is $C$, so the longest side is $AB$.
3. The smallest angle is $A$, so the shortest side is $BC$.

<!-- ILLUSTRATION: triangle ABC with angle A = 50°, angle B = 60°, angle C = ? -->

## Traps to Watch For

### #1: Allowing the Boundary Values

> The triangle inequality is strict: the sum must be greater, not equal.

Exactly $4$ or $14$ flattens the triangle into a line. Including both in Example $2$ gives $11$ instead of $9$.

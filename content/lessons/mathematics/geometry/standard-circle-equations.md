---
_id: "lesson-geometry-standard-circle-equations"
title: "Standard Circle Equations"
summary: "Write or read a circle equation in standard form."
subject: "subject-mathematics"
topic: "topic-geometry"
isActive: true
part: 5
partCount: 6
ordering: 47
keyPoints:
  - "Write or read a circle equation in standard form."
---
## Core Concept

### Equation of a Circle

A **circle** is the set of all points at the same distance from one point. That point is the **center** $(h, k)$. The fixed distance is the **radius** $r$, and $r$ is positive.

A point $(x, y)$ is on the circle when its distance from $(h, k)$ equals $r$. The distance formula gives $\sqrt{(x - h)^2 + (y - k)^2} = r$. Squaring both sides gives the **standard form**:

$$(x - h)^2 + (y - k)^2 = r^2$$

Read the center with the opposite signs. For example, $(x + 3)^2$ means $x - (-3)$, so $h = -3$. If the center is the origin, the equation is $x^2 + y^2 = r^2$.

<!-- ILLUSTRATION: circle with center C(3, -2) and radius 5 on a coordinate plane, a point P(x, y) on the circle, the radius segment from C to P labeled r = 5, and the equation (x - 3)^2 + (y + 2)^2 = 25 -->

## Examples

### #1: Writing a Circle Equation

A circle has center $(2, -1)$ and passes through $(5, 3)$. Write its equation.

**Solution:**
The radius is the distance from the center to the point on the circle.

1. Find the changes in $x$ and $y$.

$$5 - 2 = 3, \quad 3 - (-1) = 4$$

2. Find $r$.

$$r = \sqrt{3^2 + 4^2} = \sqrt{25} = 5$$

3. Use $h = 2$, $k = -1$ and $r^2 = 25$.

$$(x - 2)^2 + (y - (-1))^2 = 25$$

4. Simplify the double sign.

$$(x - 2)^2 + (y + 1)^2 = 25$$

5. Check $(5, 3)$: $(3)^2 + (4)^2 = 9 + 16 = 25$. Correct.

<!-- ILLUSTRATION: coordinate plane with center C(2, -1), point P(5, 3) on the circle, a right triangle with legs 3 and 4 and hypotenuse r = 5, and the circle drawn through P -->

## Speed Tricks & Shortcuts

To get the center of a circle from an equation like $(x - 3)^2 + (y + 2)^2 = 25$, change the sign of each number after $x$ and $y$ inside the brackets. The radius is the square root of the right side.

## Traps to Watch For

### #1: Wrong Signs in the Circle Center

> In $(x - h)^2 + (y - k)^2 = r^2$, the center is $(h, k)$: flip the sign of the number written after $x$ and after $y$.

The circle $(x + 3)^2 + (y - 1)^2 = 16$ has center $(-3, 1)$, not $(3, -1)$. A minus in the bracket gives a positive coordinate: $(x - 3)^2$ means $h = 3$. If no number follows $x$, as in $x^2$, then $h = 0$. Its radius is $4$, not $16$. The right side is $r^2$, so take its square root.

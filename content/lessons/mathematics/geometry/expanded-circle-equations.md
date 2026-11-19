---
_id: "lesson-geometry-expanded-circle-equations"
title: "Expanded Circle Equations"
summary: "Complete the square to find the center and radius."
subject: "subject-mathematics"
topic: "topic-geometry"
isActive: true
part: 6
partCount: 6
ordering: 48
keyPoints:
  - "Complete the square to find the center and radius."
---
## Core Concept

A circle equation may also come in expanded form, with $x^2$ and $y^2$ each having coefficient $1$:

$$x^2 + y^2 + Dx + Ey + F = 0$$

To find the center and radius, rewrite it in standard form by **completing the square**. Group the $x$ terms and the $y$ terms. For the $x$ group, take the number that multiplies $x$ (not the one that multiplies $x^2$), halve it, and square it. Add that square to both sides. Do the same for $y$.

A group of the form $x^2 + bx + \left(\dfrac{b}{2}\right)^2$ is the perfect square $\left(x + \dfrac{b}{2}\right)^2$. So the number inside the bracket is half of $b$, with the same sign as $b$. For example, $x^2 - 6x + 9 = (x - 3)^2$.

If $x^2$ and $y^2$ share a coefficient other than $1$, divide the whole equation by it first.

After completing the square, the right side is $r^2$. It must be positive. If it is $0$, the graph is a single point. If it is negative, no point satisfies the equation.

The Conic Sections lesson covers circles and other curves in more depth.

## Examples

### #1: Center and Radius from an Expanded Equation

Find the center and radius of the circle $x^2 + y^2 - 6x + 4y - 12 = 0$.

**Solution:**
Group the $x$ terms and the $y$ terms. Then complete the square for each.

1. Move the constant to the right side and group.

$$(x^2 - 6x) + (y^2 + 4y) = 12$$

2. Half of $-6$ is $-3$, and $(-3)^2 = 9$. Half of $4$ is $2$, and $2^2 = 4$. Add both to both sides.

$$(x^2 - 6x + 9) + (y^2 + 4y + 4) = 12 + 9 + 4$$

3. Write each group as a square. Half of $-6$ gives $(x - 3)^2$, and half of $4$ gives $(y + 2)^2$.

$$(x - 3)^2 + (y + 2)^2 = 25$$

4. Read the center with the opposite signs: $(3, -2)$.
5. The right side is $r^2 = 25$, which is positive, so $r = 5$.

<!-- ILLUSTRATION: coordinate plane with the circle centered at (3, -2) with radius 5, the center marked and a radius segment labeled r = 5 -->

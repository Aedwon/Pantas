---
_id: "lesson-geometry-pythagorean-theorem-and-triples"
title: "Pythagorean Theorem and Triples"
summary: "Find a missing right-triangle side or test whether three sides make a right triangle."
subject: "subject-mathematics"
topic: "topic-geometry"
isActive: true
part: 7
partCount: 9
ordering: 22
keyPoints:
  - "Find a missing right-triangle side or test whether three sides make a right triangle."
---
## Core Concept

### The Pythagorean Theorem and Special Right Triangles

In a right triangle with legs $a$ and $b$ and hypotenuse $c$ (the longest side, across the right angle):

$$a^2 + b^2 = c^2$$

If a triangle's sides satisfy this, with $c$ as the longest side, it is a right triangle. If $a^2 + b^2$ is not equal to $c^2$ for the longest side $c$, it is not.

A **Pythagorean triple** is three positive whole numbers that satisfy $a^2 + b^2 = c^2$. Common ones are $3$-$4$-$5$, $5$-$12$-$13$, $8$-$15$-$17$, and multiples like $6$-$8$-$10$.

The trap calls the Pythagorean theorem problem Example 9.

## Examples

### #1: Pythagorean Theorem

A ladder $15$ feet long leans against a wall. Its foot is $9$ feet from the base of the wall. How high up the wall does the ladder reach?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle", "labels": ["Ladder = 15 ft", "Base = 9 ft", "Height = ?", "90° wall corner"], "semanticsLabel": "Right triangle formed by wall and ground with 15 foot ladder hypotenuse, 9 foot base, and height marked with a question mark."} -->

**Solution:**
The wall, ground, and ladder form a right triangle. The ladder is the hypotenuse.

1. Write the theorem with the unknown height $h$.

$$9^2 + h^2 = 15^2$$

2. Subtract $81$ and take the square root.

$$h^2 = 225 - 81 = 144 \quad\Rightarrow\quad h = 12$$

The ladder reaches $12$ feet up the wall.

## Speed Tricks & Shortcuts

Scan for Pythagorean triples before squaring. If a right triangle has a leg $5$ and hypotenuse $13$, the missing leg is $12$.

The triple $10$-$24$-$26$ is $5$-$12$-$13$ doubled. The shortcut works when the known sides match a triple or a multiple of one in their roles, with the largest number of the triple as the hypotenuse. Legs $4$ and $5$ give a hypotenuse of $\sqrt{41}$, not a $3$-$4$-$5$ triangle.

Otherwise, add the squares of the legs, then take the square root, to find a hypotenuse. To find a leg, subtract the square of the known leg from the square of the hypotenuse, then take the square root.

## Traps to Watch For

### #1: Putting the Hypotenuse in the Wrong Spot

> In a right triangle, the hypotenuse $c$ is the longest side, across the right angle.

With sides $9$ and $15$, students often compute $9^2 + 15^2$. If $15$ is the hypotenuse, as in Example $9$, use $9^2 + b^2 = 15^2$.

---
_id: "lesson-algebra-systems-lines-and-parabolas"
title: "Systems (Lines and Parabolas)"
summary: "Find every intersection of a line and a parabola."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 4
partCount: 4
ordering: 49
keyPoints:
  - "Find every intersection of a line and a parabola."
---
## Core Concept

A **system of equations** is a group of two or more equations that share the same variables. To "solve the system" means to find the values that make all the equations true at the same time.

A **non-linear system** has at least one equation that is not a straight line, like a parabola from $y = x^2 - 4$. A line can cross a parabola at two points, so these systems can have two solutions.

Part 1, Factoring Quadratic Equations, in the Quadratic Equations lesson shows how to factor a quadratic and solve it by setting each factor equal to zero.

## Examples

### #1: A Line Meets a Parabola

Solve the non-linear system: $y = x^2 - 4$ and $y = 3x - 6$.

**Solution:**
Both equations equal $y$, so we can set them equal to each other.

1. Set the two right sides equal.

$$x^2 - 4 = 3x - 6$$

2. Move everything to one side to get a quadratic equation.

$$x^2 - 3x + 2 = 0$$

3. Factor the quadratic.

$$x^2 - 3x + 2 = (x - 1)(x - 2) = 0$$

4. So $x = 1$ or $x = 2$. Find $y$ for each using $y = 3x - 6$.

$$x = 1: \quad y = 3(1) - 6 = -3$$

$$x = 2: \quad y = 3(2) - 6 = 0$$

5. There are two solutions: $(1, -3)$ and $(2, 0)$. The line cuts through the parabola twice.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "system", "points": [[1, -3], [2, 0]], "formula": "y = x^2 - 4 and y = 3x - 6", "semanticsLabel": "A coordinate graph of a parabola and a line intersecting at (1, -3) and (2, 0)."} -->

## Traps to Watch For

### #1: Finding Only One Point on a Curve

> A line can hit a parabola twice. Find all solutions.

In non-linear systems, students find $x = 1$, compute one point, and stop. But the quadratic had two roots. If the question asks for "the solutions" or "the sum of the $x$ values", you need both crossing points.

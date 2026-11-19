---
_id: "lesson-geometry-coordinate-midpoints-and-endpoints"
title: "Coordinate Midpoints and Endpoints"
summary: "Average coordinates to find a midpoint. Use a midpoint and one endpoint to find the other endpoint."
subject: "subject-mathematics"
topic: "topic-geometry"
isActive: true
part: 2
partCount: 6
ordering: 44
keyPoints:
  - "Average coordinates to find a midpoint."
  - "Use a midpoint and one endpoint to find the other endpoint."
---
## Core Concept

The **midpoint** is the point halfway between the two points. Its coordinates are the averages of the coordinates:

$$M = \left( \dfrac{x_1 + x_2}{2}, \dfrac{y_1 + y_2}{2} \right)$$

The average of two numbers is the number halfway between them. So the midpoint is halfway across in $x$ and halfway up or down in $y$.

The shortcut calls the missing-endpoint problem Example 6.

## Examples

### #1: Midpoint

Find the midpoint of the segment joining $(2, -3)$ and $(-4, 7)$.

**Solution:**
Average the $x$ values, then average the $y$ values.

1. The $x$-coordinate.

$$\dfrac{2 + (-4)}{2} = \dfrac{-2}{2} = -1$$

2. The $y$-coordinate.

$$\dfrac{-3 + 7}{2} = \dfrac{4}{2} = 2$$

3. The midpoint is $(-1, 2)$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "coordinate-geometry", "labels": ["(2, -3)", "(-4, 7)", "Midpoint (-1, 2)"], "semanticsLabel": "Coordinate plane showing segment connecting 2 comma negative 3 and negative 4 comma 7 with midpoint at negative 1 comma 2."} -->

### #2: Finding a Missing Endpoint

$M(3, -1)$ is the midpoint of segment $AB$. If $A$ is $(7, 4)$, find the coordinates of $B$.

**Solution:**
This reverses the midpoint formula. The midpoint is the average, so work backwards.

1. Set up the $x$ equation with $B = (x, y)$.

$$\dfrac{7 + x}{2} = 3$$

2. Multiply by $2$, then subtract $7$.

$$7 + x = 6$$

$$x = -1$$

3. Set up the $y$ equation.

$$\dfrac{4 + y}{2} = -1$$

4. Multiply by $2$, then subtract $4$.

$$4 + y = -2$$

$$y = -6$$

5. Point $B$ is $(-1, -6)$. Check: the averages of $7$ and $-1$, and of $4$ and $-6$, are $3$ and $-1$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "coordinate-geometry", "labels": ["A(7, 4)", "M(3, -1)", "B(-1, -6)"], "semanticsLabel": "Coordinate plane showing point A at 7 comma 4, midpoint M at 3 comma negative 1, and endpoint B at negative 1 comma negative 6."} -->

## Speed Tricks & Shortcuts

A faster route to a missing endpoint (Example $6$): the midpoint is the center, so keep moving the same amount again. From $A(7, 4)$ to $M(3, -1)$ you move $-4$ in $x$ and $-5$ in $y$. Move the same again from $M$: $(3 - 4, -1 - 5) = (-1, -6)$. No equations needed.

## Traps to Watch For

### #1: Mixing Up Distance and Midpoint

> The midpoint formula adds the coordinates. The distance formula subtracts them.

For $(2, -3)$ and $(-4, 7)$, the midpoint is $(-1, 2)$ from sums divided by $2$. The distance uses the differences $-6$ and $10$, which are squared. Keep the signs of the coordinates when you average them.

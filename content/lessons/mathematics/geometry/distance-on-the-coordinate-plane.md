---
_id: "lesson-geometry-distance-on-the-coordinate-plane"
title: "Distance on the Coordinate Plane"
summary: "Use coordinate differences to find the distance between two points."
subject: "subject-mathematics"
topic: "topic-geometry"
isActive: true
part: 1
partCount: 6
ordering: 43
keyPoints:
  - "Use coordinate differences to find the distance between two points."
---
## Core Concept

The coordinate plane puts geometry on a grid. Each point has one address $(x, y)$: steps right or left, then steps up or down. With coordinates, we can calculate geometric relationships instead of just reading them off a drawing.

### Distance and Midpoint Formulas

The **distance** between points $(x_1, y_1)$ and $(x_2, y_2)$ is the length of the straight segment joining them:

$$d = \sqrt{(x_2 - x_1)^2 + (y_2 - y_1)^2}$$

This comes from the Pythagorean theorem. In a right triangle, the two sides that meet at the right angle are the **legs**. The side opposite the right angle is the **hypotenuse**. The theorem says $a^2 + b^2 = c^2$, where $a$ and $b$ are the legs and $c$ is the hypotenuse.

If both coordinates differ, draw a horizontal line from one point and a vertical line from the other until they meet. They form a right triangle. The horizontal leg has length $|x_2 - x_1|$ and the vertical leg has length $|y_2 - y_1|$. The distance is the hypotenuse.

Squaring a number gives the same result as squaring its negative, so the order of subtraction does not matter here. If the points share an $x$ or a $y$, the distance is the absolute difference in the other coordinate. The formula still works because one difference is $0$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "coordinate-geometry", "labels": ["(x1, y1)", "(x2, y2)", "dx = x2 - x1", "dy = y2 - y1", "Distance d"], "semanticsLabel": "Grid diagram showing two points joined by a segment forming a right triangle with horizontal and vertical distance legs."} -->

## Examples

### #1: Distance Between Two Points

Perpendicular Height in Area Formulas shows how to use a base and height for a triangle or parallelogram. If the base is horizontal, its length is the difference between its endpoints’ $x$-coordinates, larger minus smaller. Use the difference in $y$-coordinates for the perpendicular height, also larger minus smaller.

Find the distance between $(-3, 4)$ and $(5, -2)$.

**Solution:**
Plug into the distance formula. Watch the signs.

1. Horizontal change.

$$5 - (-3) = 8$$

2. Vertical change.

$$-2 - 4 = -6$$

3. Square both, add, and take the root.

$$d = \sqrt{8^2 + (-6)^2} = \sqrt{64 + 36}$$

4. Simplify.

$$d = \sqrt{100} = 10$$

5. The distance is $10$ units. The squaring removes the sign of each change. Also, $6$-$8$-$10$ is double the $3$-$4$-$5$ right triangle.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "coordinate-geometry", "labels": ["(-3, 4)", "(5, -2)", "run = 8", "Vertical leg = 6", "d = ?"], "semanticsLabel": "Coordinate plane with points at negative 3 comma 4 and 5 comma negative 2 forming a right triangle with legs 8 and 6."} -->

### #2: Distance From a Point to a Line

Find the shortest distance from $(0,0)$ to $y=x+4$.

**Solution:**
The line meets the axes at $(-4,0)$ and $(0,4)$. These points and the origin form a right triangle with area $\dfrac{1}{2}(4)(4)=8$. The distance between the two intercepts is $\sqrt{4^2+4^2}=4\sqrt{2}$. Use that side as the base. Its perpendicular height $h$ from the origin is the shortest distance to the line. The area is still $8$, so $\dfrac{1}{2}(4\sqrt{2})h=8$ and $h=2\sqrt{2}$.

## Speed Tricks & Shortcuts

Before using the distance formula, check whether the points share an $x$ or a $y$. Points like $(2, 5)$ and $(2, 9)$ lie on a vertical line. The distance is the larger $y$ minus the smaller $y$: $9 - 5 = 4$. No square roots.

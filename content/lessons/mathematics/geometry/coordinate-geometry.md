---
_id: "lesson-geometry-coordinate-geometry"
title: "Coordinate (Analytic) Geometry"
summary: "How to measure distances, find midpoints, compute slopes, and write equations of lines on the coordinate plane."
subject: "subject-mathematics"
topic: "topic-geometry"
estimatedMinutes: 13
isActive: true
---
## Core Concept

The coordinate plane puts geometry on a grid. Every point gets an address $(x, y)$: steps right or left, then steps up or down. With coordinates, we can calculate geometric relationships instead of relying only on a drawing.

### Distance and Midpoint Formulas

The **distance** between points $(x_1, y_1)$ and $(x_2, y_2)$:

$$d = \sqrt{(x_2 - x_1)^2 + (y_2 - y_1)^2}$$

This comes from the Pythagorean theorem. The horizontal and vertical changes are the legs of a right triangle, and the distance between the points is the hypotenuse.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "coordinate-geometry", "labels": ["(x1, y1)", "(x2, y2)", "dx = x2 - x1", "dy = y2 - y1", "Distance d"], "semanticsLabel": "Grid diagram showing two points joined by a segment forming a right triangle with horizontal and vertical distance legs."} -->

The **midpoint** is the average of the coordinates:

$$M = \left( \dfrac{x_1 + x_2}{2}, \dfrac{y_1 + y_2}{2} \right)$$

### Slope of a Line

**Slope** ($m$) measures steepness: rise over run.

$$m = \dfrac{y_2 - y_1}{x_2 - x_1}$$

Read slopes at a glance: uphill left-to-right is positive, downhill is negative, a horizontal line has slope $0$, and a vertical line has undefined slope because its run is $0$.

Two useful line relationships:

- **Parallel nonvertical lines** have equal slopes. Distinct vertical lines are also parallel to one another.
- **Perpendicular nonvertical, nonhorizontal lines** have slopes that are negative reciprocals. For example, a slope of $2$ pairs with $-\dfrac{1}{2}$, and their product is $-1$. A vertical line and a horizontal line are also perpendicular, but the product-of-slopes test does not apply because the vertical slope is undefined.

### Equations of a Line

- **Slope-intercept form**: $y = mx + b$, where $m$ is the slope and $b$ is the $y$-intercept (where the line crosses the $y$-axis).
- **Point-slope form**: $y - y_1 = m(x - x_1)$, useful when you know one point and the slope.
- **Standard form**: $Ax + By = C$.

For nonvertical lines, putting an equation into $y = mx + b$ makes its slope and $y$-intercept easy to read. Vertical lines instead have the form $x = c$.

## Examples

### #1: Distance Between Two Points

Find the distance between $(-3, 4)$ and $(5, -2)$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "coordinate-geometry", "labels": ["(-3, 4)", "(5, -2)", "run = 8", "rise = 6", "d = ?"], "semanticsLabel": "Coordinate plane with points at negative 3 comma 4 and 5 comma negative 2 forming a right triangle with legs 8 and 6."} -->


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

5. The distance is $10$ units. The squaring removes the sign of each change, and $6$-$8$-$10$ is a Pythagorean triple.

### #2: Midpoint

Find the midpoint of the segment joining $(2, -3)$ and $(-4, 7)$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "coordinate-geometry", "labels": ["(2, -3)", "(-4, 7)", "Midpoint (-1, 2)"], "semanticsLabel": "Coordinate plane showing segment connecting 2 comma negative 3 and negative 4 comma 7 with midpoint at negative 1 comma 2."} -->


**Solution:**
Average the $x$ values, then average the $y$ values.

1. The $x$-coordinate.

$$\dfrac{2 + (-4)}{2} = \dfrac{-2}{2} = -1$$

2. The $y$-coordinate.

$$\dfrac{-3 + 7}{2} = \dfrac{4}{2} = 2$$

3. The midpoint is $(-1, 2)$.

### #3: Slope, Then the Equation

Find the equation of the line through $(1, 2)$ and $(4, 11)$ in slope-intercept form.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "coordinate-geometry", "labels": ["(1, 2)", "(4, 11)", "run = 3", "rise = 9", "slope m = 3"], "semanticsLabel": "Coordinate plane with points 1 comma 2 and 4 comma 11 showing rise of 9 and run of 3 along the line."} -->


**Solution:**
Slope first, then use one point to find $b$.

1. Compute the slope.

$$m = \dfrac{11 - 2}{4 - 1} = \dfrac{9}{3} = 3$$

2. Start the equation: $y = 3x + b$. Substitute the point $(1, 2)$.

$$2 = 3(1) + b$$

3. Solve for $b$.

$$b = -1$$

4. The equation is $y = 3x - 1$.
5. Check with the other point: $3(4) - 1 = 11$. Correct.

### #4: A Perpendicular Line

Find the equation of the line perpendicular to $y = 2x + 3$ that passes through $(4, 1)$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "coordinate-geometry", "labels": ["y = 2x + 3", "(4, 1)", "m1 = 2", "m2 = -1/2", "90°"], "semanticsLabel": "Coordinate plane with line y equals 2x plus 3 and perpendicular line through 4 comma 1 intersecting at a right angle."} -->


**Solution:**
The given line is neither vertical nor horizontal, so the perpendicular line has the negative reciprocal slope.

1. The given slope is $2$. Take the reciprocal and switch the sign.

$$m = -\dfrac{1}{2}$$

2. Use point-slope form with $(4, 1)$.

$$y - 1 = -\dfrac{1}{2}(x - 4)$$

3. Distribute.

$$y - 1 = -\dfrac{1}{2}x + 2$$

4. Add $1$ to both sides.

$$y = -\dfrac{1}{2}x + 3$$

5. Quick check: both slopes are defined, and $2 \times \left(-\dfrac{1}{2}\right) = -1$, so the lines are perpendicular.

### #5: Finding a Missing Endpoint

$M(3, -1)$ is the midpoint of segment $AB$. If $A$ is $(7, 4)$, find the coordinates of $B$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "coordinate-geometry", "labels": ["A(7, 4)", "M(3, -1)", "B(-1, -6)"], "semanticsLabel": "Coordinate plane showing point A at 7 comma 4, midpoint M at 3 comma negative 1, and endpoint B at negative 1 comma negative 6."} -->


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

5. Point $B$ is $(-1, -6)$. Check: the averages of $7$ and $-1$, and of $4$ and $-6$, are indeed $3$ and $-1$.

## Speed Tricks & Shortcuts

A faster route to a missing endpoint (Example $5$): the midpoint is the center, so keep moving the same amount again. From $A(7, 4)$ to $M(3, -1)$ you move $-4$ in $x$ and $-5$ in $y$. Move the same again from $M$: $(3 - 4, -1 - 5) = (-1, -6)$. No equations needed.

Before using the distance formula, check if the points share an $x$ or a $y$. Points like $(2, 5)$ and $(2, 9)$ lie on a vertical line; the distance is just $9 - 5 = 4$. No square roots.

To read the slope from standard form $Ax + By = C$ without rearranging, use $m = -\dfrac{A}{B}$ when $B \neq 0$. If $B = 0$, the equation describes a vertical line and its slope is undefined.

## Traps to Watch For

### #1: Subtracting in Mismatched Order

> In the slope formula, both subtractions must go in the same direction.

Computing $\dfrac{y_2 - y_1}{x_1 - x_2}$ (top one way, bottom the other) flips the sign of the slope. Pick a "first point" and subtract it in both the top and bottom.

### #2: Reciprocal Without the Sign Switch

> For two nonvertical, nonhorizontal perpendicular lines, flip and negate the slope.

Given slope $\dfrac{2}{3}$, the perpendicular slope is $-\dfrac{3}{2}$. If one line is vertical, however, its perpendicular line is horizontal; do not try to take a reciprocal of an undefined slope.

### #3: Distance Signs Vanish, Coordinates Do Not

> Squaring removes signs in distance, but midpoints keep their signs.

In the distance formula a negative coordinate difference becomes positive after squaring. Midpoint coordinates are averages, so their signs remain important. For $(2, -3)$ and $(-4, 7)$, the midpoint is $(-1, 2)$.

### #4: Zero Slope vs. No Slope

> Horizontal lines have slope $0$. Vertical lines have undefined slope.

These are different things: $0$ is a defined number, while a vertical slope would require division by zero. The line $x = 5$ has undefined slope; the line $y = 5$ has slope $0$.

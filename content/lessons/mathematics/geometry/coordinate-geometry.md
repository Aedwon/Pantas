---
_id: "lesson-geometry-coordinate-geometry"
title: "Coordinate (Analytic) Geometry"
summary: "How to measure distances, find midpoints, compute slopes, write equations of lines, and read the equation of a circle on the coordinate plane."
subject: "subject-mathematics"
topic: "topic-geometry"
estimatedMinutes: 15
isActive: true
---
## Core Concept

The coordinate plane puts geometry on a grid. Each point has one address $(x, y)$: steps right or left, then steps up or down. With coordinates, we can calculate geometric relationships instead of just reading them off a drawing.

### Distance and Midpoint Formulas

The **distance** between points $(x_1, y_1)$ and $(x_2, y_2)$ is the length of the straight segment joining them:

$$d = \sqrt{(x_2 - x_1)^2 + (y_2 - y_1)^2}$$

This comes from the Pythagorean theorem. In a right triangle, the two sides that meet at the right angle are the **legs**. The side opposite the right angle is the **hypotenuse**. The theorem says $a^2 + b^2 = c^2$, where $a$ and $b$ are the legs and $c$ is the hypotenuse.

Draw a horizontal line and a vertical line from the two points until they meet. They form a right triangle. The horizontal leg has length $|x_2 - x_1|$ and the vertical leg has length $|y_2 - y_1|$. The distance is the hypotenuse.

Squaring a number gives the same result as squaring its negative, so the order of subtraction does not matter here. If the points share an $x$ or a $y$, one leg is $0$ and the formula still works.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "coordinate-geometry", "labels": ["(x1, y1)", "(x2, y2)", "dx = x2 - x1", "dy = y2 - y1", "Distance d"], "semanticsLabel": "Grid diagram showing two points joined by a segment forming a right triangle with horizontal and vertical distance legs."} -->

The **midpoint** is the point halfway between the two points. Its coordinates are the averages of the coordinates:

$$M = \left( \dfrac{x_1 + x_2}{2}, \dfrac{y_1 + y_2}{2} \right)$$

The average of two numbers is the number halfway between them. So the midpoint is halfway across in $x$ and halfway up or down in $y$.

### Slope of a Line

**Slope** ($m$) measures steepness: rise over run. The **rise** is the change in $y$. The **run** is the change in $x$.

$$m = \dfrac{y_2 - y_1}{x_2 - x_1}, \quad x_2 \neq x_1$$

On a straight line, the slope is the same for any two points you pick. A line that goes up from left to right has positive slope. A line that goes down has negative slope.

A horizontal line has slope $0$. A vertical line has an undefined slope, because its run is $0$ and we cannot divide by $0$.

Two lines can be related in two ways:

- **Parallel lines** never meet. Two different nonvertical lines are parallel exactly when their slopes are equal. Two different vertical lines are also parallel.
- **Perpendicular lines** meet at a right angle. If neither line is vertical or horizontal, their slopes are **negative reciprocals**.

The **reciprocal** of a number is $1$ divided by it. To get the negative reciprocal of a fraction, flip it and change its sign. A slope of $2$ pairs with $-\dfrac{1}{2}$, and their product is $-1$.

A horizontal line and a vertical line are also perpendicular. The product test does not apply to them, because the vertical slope is undefined.

### Equations of a Line

- **Slope-intercept form**: $y = mx + b$, where $m$ is the slope and $b$ is the $y$-intercept (where the line crosses the $y$-axis).
- **Point-slope form**: $y - y_1 = m(x - x_1)$, useful when you know one point $(x_1, y_1)$ on the line and the slope.
- **Standard form**: $Ax + By = C$, where $A$ and $B$ are not both $0$.

Slope-intercept and point-slope forms need a slope, so they do not describe vertical lines. A vertical line has the form $x = c$, where $c$ is the $x$-value of every point on it.

To read the slope of a nonvertical line, put its equation into $y = mx + b$ form.

### Equation of a Circle

A **circle** is the set of all points at the same distance from one point. That point is the **center** $(h, k)$. The fixed distance is the **radius** $r$, and $r$ is positive.

A point $(x, y)$ is on the circle when its distance from $(h, k)$ equals $r$. The distance formula gives $\sqrt{(x - h)^2 + (y - k)^2} = r$. Squaring both sides gives the **standard form**:

$$(x - h)^2 + (y - k)^2 = r^2$$

Read the center with the opposite signs. For example, $(x + 3)^2$ means $x - (-3)$, so $h = -3$. If the center is the origin, the equation is $x^2 + y^2 = r^2$.

<!-- ILLUSTRATION: circle with center C(3, -2) and radius 5 on a coordinate plane, a point P(x, y) on the circle, the radius segment from C to P labeled r = 5, and the equation (x - 3)^2 + (y + 2)^2 = 25 -->

A circle equation may also come in expanded form, with $x^2$ and $y^2$ each having coefficient $1$:

$$x^2 + y^2 + Dx + Ey + F = 0$$

To find the center and radius, rewrite it in standard form by **completing the square**. Group the $x$ terms and the $y$ terms. For the $x$ group, take the number that multiplies $x$ (not the one that multiplies $x^2$), halve it, and square it. Add that square to both sides. Do the same for $y$.

A group of the form $x^2 + bx + \left(\dfrac{b}{2}\right)^2$ is the perfect square $\left(x + \dfrac{b}{2}\right)^2$. So the number inside the bracket is half of $b$, with the same sign as $b$. For example, $x^2 - 6x + 9 = (x - 3)^2$.

If $x^2$ and $y^2$ share a coefficient other than $1$, divide the whole equation by it first.

After completing the square, the right side is $r^2$. It must be positive. If it is $0$, the graph is a single point. If it is negative, no point satisfies the equation.

The Conic Sections lesson covers circles and other curves in more depth.

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

5. The distance is $10$ units. The squaring removes the sign of each change. Also, $6$-$8$-$10$ is double the $3$-$4$-$5$ right triangle.

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

### #5: A Parallel Line from Standard Form

Find the equation of the line through $(3, -1)$ that is parallel to $2x + 3y = 6$.

<!-- ILLUSTRATION: coordinate plane with line 2x + 3y = 6 (y-intercept 2, slope -2/3) and a parallel dashed line through (3, -1) with y-intercept 1, both labeled with slope -2/3 -->

**Solution:**
Parallel lines have equal slopes. First find the slope of the given line.

1. Solve for $y$.

$$3y = -2x + 6$$

$$y = -\dfrac{2}{3}x + 2$$

2. The slope is $-\dfrac{2}{3}$, so the new line has the same slope. Use point-slope form with $(3, -1)$.

$$y - (-1) = -\dfrac{2}{3}(x - 3)$$

3. Distribute.

$$y + 1 = -\dfrac{2}{3}x + 2$$

4. Subtract $1$ from both sides.

$$y = -\dfrac{2}{3}x + 1$$

5. Check: at $x = 3$, $y = -2 + 1 = -1$. The line passes through $(3, -1)$. The new line has $b = 1$, and the given line has $b = 2$, so they are different lines.

### #6: Finding a Missing Endpoint

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

5. Point $B$ is $(-1, -6)$. Check: the averages of $7$ and $-1$, and of $4$ and $-6$, are $3$ and $-1$.

### #7: Writing a Circle Equation

A circle has center $(2, -1)$ and passes through $(5, 3)$. Write its equation.

<!-- ILLUSTRATION: coordinate plane with center C(2, -1), point P(5, 3) on the circle, a right triangle with legs 3 and 4 and hypotenuse r = 5, and the circle drawn through P -->

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

### #8: Center and Radius from an Expanded Equation

Find the center and radius of the circle $x^2 + y^2 - 6x + 4y - 12 = 0$.

<!-- ILLUSTRATION: coordinate plane with the circle centered at (3, -2) with radius 5, the center marked and a radius segment labeled r = 5 -->

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

## Speed Tricks & Shortcuts

A faster route to a missing endpoint (Example $6$): the midpoint is the center, so keep moving the same amount again. From $A(7, 4)$ to $M(3, -1)$ you move $-4$ in $x$ and $-5$ in $y$. Move the same again from $M$: $(3 - 4, -1 - 5) = (-1, -6)$. No equations needed.

Before using the distance formula, check whether the points share an $x$ or a $y$. Points like $(2, 5)$ and $(2, 9)$ lie on a vertical line. The distance is the larger $y$ minus the smaller $y$: $9 - 5 = 4$. No square roots.

To read the slope from standard form $Ax + By = C$ without rearranging, use $m = -\dfrac{A}{B}$ when $B \neq 0$. If $B = 0$, the equation describes a vertical line and its slope is undefined.

To get the center of a circle from an equation like $(x - 3)^2 + (y + 2)^2 = 25$, change the sign of each number after $x$ and $y$ inside the brackets. The radius is the square root of the right side.

## Traps to Watch For

### #1: Subtracting in Mismatched Order

> In the slope formula, both subtractions must go in the same direction.

Computing $\dfrac{y_2 - y_1}{x_1 - x_2}$ (top one way, bottom the other) flips the sign of the slope. Pick a "first point" and subtract it in both the top and bottom. The distance formula does not have this problem, because it squares each difference.

### #2: Reciprocal Without the Sign Switch

> For two perpendicular lines that are not vertical or horizontal, flip the slope and change its sign.

Given slope $\dfrac{2}{3}$, the perpendicular slope is $-\dfrac{3}{2}$. Flipping alone gives $\dfrac{3}{2}$, which is wrong.

If one line is vertical, its perpendicular line is horizontal. A horizontal line has slope $0$, which has no reciprocal. In both cases, use the vertical and horizontal rule instead.

### #3: Mixing Up Distance and Midpoint

> The midpoint formula adds the coordinates. The distance formula subtracts them.

For $(2, -3)$ and $(-4, 7)$, the midpoint is $(-1, 2)$ from sums divided by $2$. The distance uses the differences $-6$ and $10$, which are squared. Keep the signs of the coordinates when you average them.

### #4: Zero Slope vs. No Slope

> Horizontal lines have slope $0$. Vertical lines have undefined slope.

These are different things: $0$ is a defined number, while a vertical slope would require division by zero. The line $x = 5$ has undefined slope. The line $y = 5$ has slope $0$.

### #5: Wrong Signs in the Circle Center

> In $(x - h)^2 + (y - k)^2 = r^2$, the center is $(h, k)$: flip the sign of the number written after $x$ and after $y$.

The circle $(x + 3)^2 + (y - 1)^2 = 16$ has center $(-3, 1)$, not $(3, -1)$. A minus in the bracket gives a positive coordinate: $(x - 3)^2$ means $h = 3$. If no number follows $x$, as in $x^2$, then $h = 0$. Its radius is $4$, not $16$. The right side is $r^2$, so take its square root.

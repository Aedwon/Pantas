---
_id: "lesson-geometry-coordinate-geometry"
title: "Coordinate (Analytic) Geometry"
summary: "This lesson teaches you how to measure distances, find midpoints, compute slopes, and write equations of lines on the coordinate plane."
subject: "subject-mathematics"
topic: "topic-geometry"
estimatedMinutes: 13
isActive: true
---
## Core Concept

The coordinate plane puts geometry on a grid. Every point gets an address $(x, y)$: steps right or left, then steps up or down. With addresses, we can CALCULATE geometry instead of drawing it.

### Distance and Midpoint Formulas

The **distance** between points $(x_1, y_1)$ and $(x_2, y_2)$:

$$d = \sqrt{(x_2 - x_1)^2 + (y_2 - y_1)^2}$$

This is secretly the Pythagorean theorem. The horizontal change and vertical change are the legs, and the distance is the hypotenuse.

<!-- ILLUSTRATION: two points on a grid joined by a slanted segment, with a dashed horizontal leg and dashed vertical leg forming a right triangle -->

The **midpoint** is the average of the coordinates:

$$M = \left( \dfrac{x_1 + x_2}{2}, \dfrac{y_1 + y_2}{2} \right)$$

### Slope of a Line

**Slope** ($m$) measures steepness: rise over run.

$$m = \dfrac{y_2 - y_1}{x_2 - x_1}$$

Read slopes at a glance: uphill left-to-right is positive, downhill is negative, a horizontal line has slope $0$, and a vertical line has UNDEFINED slope (you cannot divide by zero).

Two rules the CETs adore:

- **Parallel lines** have EQUAL slopes.
- **Perpendicular lines** have slopes that are negative reciprocals: flip the fraction and switch the sign. A slope of $2$ pairs with $-\dfrac{1}{2}$, and their product is $-1$.

### Equations of a Line

- **Slope-intercept form**: $y = mx + b$, where $m$ is the slope and $b$ is the $y$-intercept (where the line crosses the $y$-axis).
- **Point-slope form**: $y - y_1 = m(x - x_1)$, perfect when you know one point and the slope.
- **Standard form**: $Ax + By = C$.

To graph or compare lines fast, get them into $y = mx + b$ and read off $m$ and $b$.

## Examples

### #1: Distance Between Two Points

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

5. The distance is $10$ units. The squaring erases the minus sign, and $6$-$8$-$10$ is a Pythagorean triple.

### #2: Midpoint

Find the midpoint of the segment joining $(2, -3)$ and $(-4, 7)$.

**Solution:**
Average the $x$ values, then average the $y$ values.

1. The $x$-coordinate.

$$\dfrac{2 + (-4)}{2} = \dfrac{-2}{2} = -1$$

2. The $y$-coordinate.

$$\dfrac{-3 + 7}{2} = \dfrac{4}{2} = 2$$

3. The midpoint is $(-1, 2)$.

### #3: Slope, Then the Equation

Find the equation of the line through $(1, 2)$ and $(4, 11)$ in slope-intercept form.

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

**Solution:**
Perpendicular means negative reciprocal slope.

1. The given slope is $2$. Flip and switch the sign.

$$m = -\dfrac{1}{2}$$

2. Use point-slope form with $(4, 1)$.

$$y - 1 = -\dfrac{1}{2}(x - 4)$$

3. Distribute.

$$y - 1 = -\dfrac{1}{2}x + 2$$

4. Add $1$ to both sides.

$$y = -\dfrac{1}{2}x + 3$$

5. Quick check: the slopes multiply to $2 \times \left(-\dfrac{1}{2}\right) = -1$. Perpendicular confirmed.

### #5: Finding a Missing Endpoint

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

5. Point $B$ is $(-1, -6)$. Check: the averages of $7$ and $-1$, and of $4$ and $-6$, are indeed $3$ and $-1$.

## Speed Tricks & Shortcuts

A faster route to a missing endpoint (Example $5$): the midpoint is the CENTER, so keep moving the same amount again. From $A(7, 4)$ to $M(3, -1)$ you move $-4$ in $x$ and $-5$ in $y$. Move the same again from $M$: $(3 - 4, -1 - 5) = (-1, -6)$. No equations needed.

Before using the distance formula, check if the points share an $x$ or a $y$. Points like $(2, 5)$ and $(2, 9)$ lie on a vertical line; the distance is just $9 - 5 = 4$. No square roots.

To read the slope from standard form $Ax + By = C$ without rearranging: $m = -\dfrac{A}{B}$. For $3x + 4y = 12$, the slope is $-\dfrac{3}{4}$ instantly.

## Traps to Watch For

### #1: Subtracting in Mismatched Order

> In the slope formula, both subtractions must go in the SAME direction.

Computing $\dfrac{y_2 - y_1}{x_1 - x_2}$ (top one way, bottom the other) flips the sign of the slope. Pick a "first point" and subtract it in both the top and bottom. A sign-flipped slope is always among the choices.

### #2: Reciprocal Without the Sign Switch

> Perpendicular slope means flip AND negate.

Given slope $\dfrac{2}{3}$, the perpendicular slope is $-\dfrac{3}{2}$. Students flip without negating ($\dfrac{3}{2}$) or negate without flipping ($-\dfrac{2}{3}$), and both wrong versions sit in the choices. Test with the product: it must equal $-1$.

### #3: Distance Signs Vanish, Coordinates Do Not

> Squaring kills minus signs in DISTANCE, but midpoints keep their signs.

Some students drop negative signs everywhere. In the distance formula that accident is harmless, but a midpoint of $(2, -3)$ and $(-4, 7)$ is $(-1, 2)$, not $(1, 2)$ or $(3, 5)$. Track signs in every average.

### #4: Zero Slope vs. No Slope

> Horizontal lines have slope $0$. Vertical lines have UNDEFINED slope.

These are different things: $0$ is a perfectly fine number, while undefined means the formula breaks (division by zero). A question asking for the slope of $x = 5$ wants "undefined", and $0$ is the planted wrong answer. For $y = 5$, the slope is $0$.

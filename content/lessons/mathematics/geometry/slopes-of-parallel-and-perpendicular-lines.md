---
_id: "lesson-geometry-slopes-of-parallel-and-perpendicular-lines"
title: "Slopes of Parallel and Perpendicular Lines"
summary: "Use equal slopes for parallel lines. Find a perpendicular slope or recognize a horizontal and vertical pair."
subject: "subject-mathematics"
topic: "topic-geometry"
isActive: true
part: 4
partCount: 6
ordering: 0
keyPoints:
  - "Use equal slopes for parallel lines."
  - "Find a perpendicular slope or recognize a horizontal and vertical pair."
---
## Core Concept

Two lines can be related in two ways:

- **Parallel lines** never meet. Two different nonvertical lines are parallel exactly when their slopes are equal. Two different vertical lines are also parallel.
- **Perpendicular lines** meet at a right angle. If neither line is vertical or horizontal, their slopes are **negative reciprocals**.

The **reciprocal** of a number is $1$ divided by it. To get the negative reciprocal of a fraction, flip it and change its sign. A slope of $2$ pairs with $-\dfrac{1}{2}$, and their product is $-1$.

A horizontal line and a vertical line are also perpendicular. The product test does not apply to them, because the vertical slope is undefined.

## Examples

### #1: A Perpendicular Line

Find the equation of the line perpendicular to $y = 2x + 3$ that passes through $(4, 1)$.

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

<!-- FIGURE: {"kind": "geometry-diagram", "type": "coordinate-geometry", "labels": ["y = 2x + 3", "(4, 1)", "m1 = 2", "m2 = -1/2", "90°"], "semanticsLabel": "Coordinate plane with line y equals 2x plus 3 and perpendicular line through 4 comma 1 intersecting at a right angle."} -->

### #2: A Parallel Line from Standard Form

Find the equation of the line through $(3, -1)$ that is parallel to $2x + 3y = 6$.

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

<!-- ILLUSTRATION: coordinate plane with line 2x + 3y = 6 (y-intercept 2, slope -2/3) and a parallel dashed line through (3, -1) with y-intercept 1, both labeled with slope -2/3 -->

## Traps to Watch For

### #1: Reciprocal Without the Sign Switch

> For two perpendicular lines that are not vertical or horizontal, flip the slope and change its sign.

Given slope $\dfrac{2}{3}$, the perpendicular slope is $-\dfrac{3}{2}$. Flipping alone gives $\dfrac{3}{2}$, which is wrong.

If one line is vertical, its perpendicular line is horizontal. A horizontal line has slope $0$, which has no reciprocal. In both cases, use the vertical and horizontal rule instead.

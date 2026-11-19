---
_id: "lesson-geometry-coordinate-slope-and-line-forms"
title: "Coordinate Slope and Line Forms"
summary: "Find slope from two points. Read or write equations of lines in different forms."
subject: "subject-mathematics"
topic: "topic-geometry"
isActive: true
part: 3
partCount: 6
ordering: 45
keyPoints:
  - "Find slope from two points."
  - "Read or write equations of lines in different forms."
---
## Core Concept

### Slope of a Line

**Slope** ($m$) measures steepness: rise over run. The **rise** is the change in $y$. The **run** is the change in $x$.

$$m = \dfrac{y_2 - y_1}{x_2 - x_1}, \quad x_2 \neq x_1$$

On a straight line, the slope is the same for any two points you pick. A line that goes up from left to right has positive slope. A line that goes down has negative slope.

A horizontal line has slope $0$. A vertical line has an undefined slope, because its run is $0$ and we cannot divide by $0$.

### Equations of a Line

- **Slope-intercept form**: $y = mx + b$, where $m$ is the slope and $b$ is the $y$-intercept (where the line crosses the $y$-axis).
- **Point-slope form**: $y - y_1 = m(x - x_1)$, useful when you know one point $(x_1, y_1)$ on the line and the slope.
- **Standard form**: $Ax + By = C$, where $A$ and $B$ are not both $0$.

Slope-intercept and point-slope forms need a slope, so they do not describe vertical lines. A vertical line has the form $x = c$, where $c$ is the $x$-value of every point on it.

To read the slope of a nonvertical line, put its equation into $y = mx + b$ form.

## Examples

### #1: Slope, Then the Equation

Part 2, Systems (Elimination), shows how to solve two linear equations to find where their lines meet.

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

<!-- FIGURE: {"kind": "geometry-diagram", "type": "coordinate-geometry", "labels": ["(1, 2)", "(4, 11)", "run = 3", "rise = 9", "slope m = 3"], "semanticsLabel": "Coordinate plane with points 1 comma 2 and 4 comma 11 showing rise of 9 and run of 3 along the line."} -->

## Speed Tricks & Shortcuts

To read the slope from standard form $Ax + By = C$ without rearranging, use $m = -\dfrac{A}{B}$ when $B \neq 0$. If $B = 0$, the equation describes a vertical line and its slope is undefined.

## Traps to Watch For

### #1: Subtracting in Mismatched Order

> In the slope formula, both subtractions must go in the same direction.

Computing $\dfrac{y_2 - y_1}{x_1 - x_2}$ (top one way, bottom the other) flips the sign of the slope. Pick a "first point" and subtract it in both the top and bottom. The distance formula does not have this problem, because it squares each difference.

### #2: Zero Slope vs. No Slope

> Horizontal lines have slope $0$. Vertical lines have undefined slope.

These are different things: $0$ is a defined number, while a vertical slope would require division by zero. The line $x = 5$ has undefined slope. The line $y = 5$ has slope $0$.

---
_id: "lesson-algebra-linear-equations-inequalities"
title: "Linear Equations and Inequalities (Solving and Graphing)"
summary: "Solve and graph linear equations and inequalities, and use slope, intercept, and boundary information correctly."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 12
isActive: true
---
## Core Concept

A linear equation in one variable can be written as $ax+b=0$ with $a\ne0$. Solving it means finding the value that makes both sides equal.

An equation stays balanced when you do the same valid operation to both sides. You may add or subtract the same amount, or multiply or divide both sides by the same nonzero amount.

For equal fractions, multiplying both sides by the denominators clears the fractions. This is why cross-multiplication works when the denominators are nonzero.

A **linear inequality** uses a comparison such as $<$, $>$, $\le$, or $\ge$. Its solution can contain many values instead of one value.

### One-Variable Inequalities on a Number Line

Use an **open circle** for $<$ or $>$ because the endpoint is not included. Use a **closed circle** for $\le$ or $\ge$ because the endpoint is included.

Shade left for values less than the endpoint. Shade right for values greater than the endpoint.

If you multiply or divide both sides of an inequality by a negative number, reverse the inequality sign. This keeps the comparison true.

### Lines in Two Variables

A linear equation in two variables can be written as:

$$Ax+By=C,$$

where $A$ and $B$ are not both $0$. Its graph is a straight line.

For a nonvertical line, slope-intercept form is:

$$y=mx+b,$$

where $m$ is the slope and $b$ is the $y$-intercept.

For $Ax+By=C$ with $B\ne0$, the slope is:

$$m=-\dfrac{A}{B}.$$

If $B=0$, the equation is vertical and can be written as:

$$x=\dfrac{C}{A}.$$

A vertical line has undefined slope. A horizontal line has slope $0$.

Distinct nonvertical parallel lines have the same slope. Two nonvertical lines with nonzero slopes are perpendicular when their slopes are negative reciprocals:

$$m_2=-\dfrac{1}{m_1}.$$

A vertical line is perpendicular to a horizontal line.

The **point-slope form** of a nonvertical line through $(x_1,y_1)$ with slope $m$ is:

$$y-y_1=m(x-x_1).$$

### Two-Variable Linear Inequalities

A two-variable linear inequality usually shades one side of a boundary line. Use a dashed boundary for $<$ or $>$, and a solid boundary for $\le$ or $\ge$.

To decide which side to shade, test a point that is not on the boundary. If the point makes the inequality true, shade the side containing that point.

## Examples

### #1: Basic Equation with Fractions

If $\dfrac{3x-1}{2}=\dfrac{x+4}{3}$, what is $x$?

**Solution:**

1. Multiply both sides by $6$ to clear the denominators.

$$3(3x-1)=2(x+4)$$

2. Expand both sides.

$$9x-3=2x+8$$

3. Subtract $2x$ from both sides, then add $3$ to both sides.

$$7x=11$$

4. Divide both sides by $7$.

$$x=\dfrac{11}{7}$$

### #2: Inequality with a Negative Flip and Number-Line Graph

Solve $-2(x-4)>3x+13$, then describe its graph on a number line.

<!-- ILLUSTRATION: number line with an open circle at $-1$ and shading to the left, labeled $x<-1$ -->

**Solution:**

1. Expand the left side.

$$-2x+8>3x+13$$

2. Collect the variable terms and number terms.

$$-5x>5$$

3. Divide by $-5$ and reverse the inequality sign.

$$x<-1$$

4. The endpoint $-1$ is not included, so use an open circle at $-1$.
5. The solution contains values less than $-1$, so shade to the left.

### #3: Finding the Equation of a Perpendicular Line

Find the equation of the line through $(3,-1)$ that is perpendicular to $2x+5y=10$.

**Solution:**

1. Use the standard-form slope formula.

$$m=-\dfrac{2}{5}$$

2. Take the negative reciprocal to get the perpendicular slope.

$$m_\perp=\dfrac{5}{2}$$

3. Use point-slope form with $(3,-1)$.

$$y+1=\dfrac{5}{2}(x-3)$$

4. Rearrange the equation.

$$2y+2=5x-15$$

$$5x-2y=17$$

### #4: Vertical and Horizontal Line Slopes

Find the slope of $3x=12$ and the slope of $2y=6$. State whether the two lines are perpendicular.

**Solution:**

1. Rewrite the first equation.

$$x=4$$

This is a vertical line, so its slope is undefined.

2. Rewrite the second equation.

$$y=3$$

This is a horizontal line, so its slope is $0$.

3. A vertical line and a horizontal line are perpendicular.

### #5: Graphing a Two-Variable Inequality

A shaded region includes $(0,0)$. Its boundary is a dashed line through $(0,3)$ and $(3,0)$. Which inequality defines the region?

<!-- FIGURE: {"kind": "coordinate-graph", "type": "linear-inequality", "formula": "x + y < 3", "points": [[0, 3], [3, 0]], "shaded": "below", "semanticsLabel": "A coordinate graph with a dashed line through (0, 3) and (3, 0) and the region containing the origin shaded."} -->

**Solution:**

1. The boundary has slope $-1$ and $y$-intercept $3$, so its equation is:

$$x+y=3$$

2. The dashed line means the boundary is not included, so the inequality is strict.
3. Test $(0,0)$ because it is stated to be in the shaded region.

$$0+0<3$$

4. The test is true, so the shaded region is:

$$x+y<3$$

## Speed Tricks & Shortcuts

For $Ax+By=C$ with $B\ne0$, read the slope directly as $-\dfrac{A}{B}$.

To find the $x$-intercept of $Ax+By=C$, set $y=0$ when that intercept exists. To find the $y$-intercept, set $x=0$ when that intercept exists.

For a two-variable inequality, test a point that is not on the boundary. The origin $(0,0)$ is convenient only when the boundary does not pass through it.

## Traps to Watch For

### #1: Negative Multiplier or Divisor

> Multiplying or dividing an inequality by a negative number reverses the sign.

For example, dividing $-5x>5$ by $-5$ gives $x<-1$. Keeping the same sign would reverse which values actually work.

### #2: Parallel and Perpendicular Edge Cases

> The negative-reciprocal shortcut is for nonzero finite slopes.

A vertical line has undefined slope, and a horizontal line has slope $0$. These two lines are perpendicular, so do not force the reciprocal formula onto this edge case.

### #3: Solid vs. Dashed Boundary

> A dashed line excludes the boundary, while a solid line includes it.

Use dashed for $<$ or $>$. Use solid for $\le$ or $\ge$.

---
_id: "lesson-algebra-linear-equations-inequalities"
title: "Linear Equations and Inequalities (Solving and Graphing)"
summary: "Solve and graph linear equations and inequalities while handling slope and boundary cases correctly."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 10
isActive: true
---
## Core Concept

A linear equation in one variable can be written in the form $ax+b=0$ with $a\ne0$. A linear equation in two variables can be written as:

$$Ax+By=C,$$

where $A$ and $B$ are not both zero. Its graph is a straight line.

A **linear inequality** replaces equality with a comparison such as $<$, $>$, $\le$, or $\ge$. In one variable, its solution is shown on a number line. In two variables, its graph is typically a half-plane separated by a boundary line.

For a nonvertical line, slope-intercept form is:

$$y=mx+b,$$

where $m$ is the slope and $b$ is the $y$-intercept.

## Mnemonics & Memory Aids

When graphing $y=mx+b$, start at the $y$-intercept and use the slope as rise over run to locate another point.

For a two-variable linear inequality:

- use a **dashed** boundary for $<$ or $>$ because the boundary is not included;
- use a **solid** boundary for $\le$ or $\ge$ because the boundary is included.

When multiplying or dividing both sides of an inequality by a negative number, reverse the inequality sign.

## Examples

### #1: Basic Equation with Fractions

If $\dfrac{3x-1}{2}=\dfrac{x+4}{3}$, what is $x$?

**Solution:**

1. Cross-multiply.

$$3(3x-1)=2(x+4)$$

2. Expand and solve.

$$9x-3=2x+8$$

$$7x=11$$

$$x=\dfrac{11}{7}$$

### #2: Inequality with a Negative Flip

Solve $-2(x-4)>3x+13$.

**Solution:**

1. Expand.

$$-2x+8>3x+13$$

2. Collect terms.

$$-5x>5$$

3. Divide by $-5$ and reverse the sign.

$$x<-1$$

### #3: Finding the Equation of a Line

Find the equation of the line through $(3,-1)$ that is perpendicular to $2x+5y=10$.

**Solution:**

1. Because $B=5\ne0$, the slope of $Ax+By=C$ is $-\dfrac{A}{B}$.

$$m=-\dfrac{2}{5}$$

2. A nonvertical line perpendicular to a line of nonzero slope has slope equal to the negative reciprocal.

$$m_\perp=\dfrac{5}{2}$$

3. Use point-slope form.

$$y+1=\dfrac{5}{2}(x-3)$$

4. Rearrange.

$$2y+2=5x-15$$

$$5x-2y=17$$

### #4: Graphing an Inequality

A shaded region includes $(0,0)$. Its boundary is a dashed line through $(0,3)$ and $(3,0)$. Which inequality defines the region?

<!-- FIGURE: {"kind": "coordinate-graph", "type": "linear-inequality", "formula": "x + y < 3", "points": [[0, 3], [3, 0]], "shaded": "below", "semanticsLabel": "A coordinate graph with a dashed line through (0, 3) and (3, 0) and the region containing the origin shaded."} -->

**Solution:**

1. The boundary has slope $-1$ and $y$-intercept $3$, so:

$$x+y=3$$

2. The dashed line means a strict inequality.
3. Test $(0,0)$, which is not on the boundary and is stated to be in the shaded region.

$$0+0<3$$

4. Therefore:

$$x+y<3$$

### #5: System of Equations Word Problem

A store sells basic calculators for Php $150$ and scientific calculators for Php $400$. If it sells $30$ calculators for total revenue of Php $7,000$, how many basic calculators were sold?

**Solution:**

Let $b$ be the number of basic calculators and $s$ the number of scientific calculators.

$$b+s=30$$

$$150b+400s=7000$$

From $s=30-b$:

$$150b+400(30-b)=7000$$

$$-250b=-5000$$

$$b=20$$

So $20$ basic calculators were sold.

## Speed Tricks & Shortcuts

For $Ax+By=C$ with $B\ne0$, the slope is:

$$m=-\dfrac{A}{B}.$$

If $B=0$, the equation is a vertical line $x=\dfrac{C}{A}$ and its slope is undefined.

To find intercepts of $Ax+By=C$, set $y=0$ for the $x$-intercept and set $x=0$ for the $y$-intercept, when those intercepts exist.

For a two-variable inequality, test a point that is **not on the boundary**. The origin $(0,0)$ is convenient only when the boundary does not pass through the origin.

## Traps to Watch For

### #1: Negative Multiplier or Divisor

If you multiply or divide an inequality by a negative number, reverse the inequality sign.

### #2: Parallel and Perpendicular Edge Cases

Distinct nonvertical parallel lines have the same slope. For nonzero finite slope $m$, a perpendicular nonvertical line has slope $-\dfrac{1}{m}$.

A vertical line is perpendicular to a horizontal line, so the "flip and change the sign" shortcut must not be applied blindly to slope $0$ or an undefined slope.

### #3: Solid vs. Dashed Boundary

A dashed line represents a strict boundary ($<$ or $>$). A solid line represents an included boundary ($\le$ or $\ge$).

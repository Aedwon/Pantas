---
_id: "lesson-algebra-types-of-functions"
title: "Types of Functions (Linear, Quadratic, Rational, Absolute Value, Exponential, Logarithmic, Piecewise)"
summary: "Recognize common function families and their defining features, domains, and graph behavior."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 14
isActive: true
---
## Core Concept

Functions can be grouped into families with characteristic formulas and graph behavior.

**Linear:** $f(x)=mx+b$. Its graph is a straight nonvertical line. Vertical lines are also linear relations but cannot be written as functions of $x$ in this form.

**Quadratic:** $f(x)=ax^2+bx+c$ with $a\ne0$. Its graph is a parabola. It opens upward when $a>0$ and downward when $a<0$. The vertex has $x$-coordinate:

$$x=-\dfrac{b}{2a}.$$

**Rational:** a function that can be written as a quotient of polynomials:

$$f(x)=\dfrac{P(x)}{Q(x)},\qquad Q(x)\ne0.$$

Its domain excludes zeros of the original denominator. Rational graphs may have vertical, horizontal, or slant asymptotes, and they may also have removable discontinuities.

**Absolute value:** $f(x)=|x|$ has a V-shaped graph and outputs only nonnegative values. Transformed absolute-value functions can shift, stretch, or reflect this graph.

**Exponential:** $f(x)=a^x$ for $a>0$ and $a\ne1$. If $a>1$, the function grows as $x$ increases; if $0<a<1$, it decays.

**Logarithmic:** $f(x)=\log_a x$ for $a>0$, $a\ne1$, and $x>0$. It is the inverse of $a^x$.

**Piecewise:** a function defined by different formulas on specified parts of its domain.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "function-gallery", "functions": ["linear", "quadratic", "rational", "absolute-value", "exponential", "logarithmic", "piecewise"], "semanticsLabel": "A gallery showing graphs of linear, quadratic, rational, absolute value, exponential, logarithmic, and piecewise functions."} -->

## Examples

### #1: Naming the Family

Classify $f(x)=3x-7$, $g(x)=5^x$, and $h(x)=x^5$.

**Solution:**

1. $f(x)=3x-7$ is linear.
2. $g(x)=5^x$ is exponential because the variable is in the exponent.
3. $h(x)=x^5$ is a polynomial power function, not an exponential function.

### #2: Vertex of a Quadratic

Find the vertex of $f(x)=x^2-4x+3$ and state whether it is a minimum or maximum.

**Solution:**

$$x=-\dfrac{-4}{2(1)}=2$$

Then:

$$f(2)=4-8+3=-1$$

The vertex is $(2,-1)$. Since $a=1>0$, the parabola opens upward, so the vertex is a minimum.

### #3: Asymptotes of a Rational Function

Find the vertical and horizontal asymptotes of $f(x)=\dfrac{x+1}{x-2}$.

**Solution:**

1. The denominator is zero at $x=2$, while the numerator is nonzero there, so $x=2$ is a vertical asymptote.
2. Numerator and denominator have the same degree. Their leading coefficients are both $1$, so the horizontal asymptote is:

$$y=1.$$

<!-- FIGURE: {"kind": "coordinate-graph", "type": "rational", "formula": "y = (x+1)/(x-2)", "asymptotes": [{"axis": "x", "value": 2}, {"axis": "y", "value": 1}], "semanticsLabel": "A rational function graph with a vertical asymptote at x = 2 and a horizontal asymptote at y = 1."} -->

An asymptote describes limiting behavior. A graph can cross a horizontal or slant asymptote; "asymptote" does not mean every such line is never touched.

### #4: Solving an Absolute Value Equation

Solve $|2x-5|=7$.

**Solution:**

$$2x-5=7\quad\text{or}\quad2x-5=-7$$

So:

$$x=6\quad\text{or}\quad x=-1$$

Both values check in the original equation.

### #5: Exponential and Logarithmic Equations

Solve $2^{x+1}=32$, then evaluate $\log_3 81$.

**Solution:**

Since $32=2^5$:

$$x+1=5$$

$$x=4$$

Also, since $3^4=81$:

$$\log_3 81=4$$

### #6: Evaluating a Piecewise Function

Let $f(x)=x^2$ when $x<2$, and $f(x)=3x-1$ when $x\ge2$. Find $f(2)+f(-3)$.

**Solution:**

For $x=2$, use the second rule:

$$f(2)=3(2)-1=5$$

For $x=-3$, use the first rule:

$$f(-3)=(-3)^2=9$$

Therefore:

$$f(2)+f(-3)=14$$

## Speed Tricks & Shortcuts

For graph matching, identify the family first, then test an easy input such as $x=0$ **when $0$ belongs to the domain**. One point can eliminate candidates, but a single matching point does not prove two graphs are identical.

For a quadratic's maximum or minimum value, find the vertex and use its $y$-coordinate.

For exponential equations, recognizing common powers can make matching bases faster.

## Traps to Watch For

### #1: Impossible Absolute-Value Equation

If $|u|$ is set equal to a negative number, there is no real solution because absolute value is nonnegative.

### #2: Piecewise Boundary

At a boundary point, use the rule whose condition actually includes that input.

### #3: Polynomial vs. Exponential Growth

For a fixed exponential base $a>1$, $a^x$ eventually grows faster than any fixed polynomial as $x\to\infty$. This statement does **not** apply to an exponential with $0<a<1$, which decays as $x$ increases.

### #4: Logarithm Domain

For real logarithms, the argument must be positive. Thus $\log_2 0$ and $\log_2(-8)$ are undefined in the real numbers.

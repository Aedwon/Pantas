---
_id: "lesson-algebra-types-of-functions"
title: "Types of Functions (Linear, Quadratic, Rational, Absolute Value, Exponential, Logarithmic, Piecewise)"
summary: "Recognize common function families and connect their formulas to domains, graphs, and basic transformations."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 15
isActive: true
---
## Core Concept

A **function** gives one output for each allowed input. The **domain** is the set of allowed inputs. Functions can be grouped into families by their formulas and graph shapes.

In exam questions, **classify** means name the group something belongs to. **Evaluate** means find the final number value.

**Linear:** $f(x)=mx+b$. Its graph is a straight nonvertical line. A vertical line is a linear relation, but it is not a function of $x$.

**Quadratic:** $f(x)=ax^2+bx+c$ with $a\ne0$. Its graph is a parabola. It opens upward when $a>0$ and downward when $a<0$. The **vertex** is the turning point of the parabola.

The vertex has $x$-coordinate:

$$x=-\dfrac{b}{2a}$$

**Rational:** a function that can be written as one polynomial divided by another:

$$f(x)=\dfrac{P(x)}{Q(x)},\qquad Q(x)\ne0$$

The domain leaves out every value that makes the original denominator $0$. The **degree** of a nonzero polynomial is its highest exponent. The **leading coefficient** is the coefficient of its highest-degree term.

An **asymptote** is a line that a graph approaches in a certain direction. For graph features, first cancel any common polynomial factors only to see the simpler graph shape. A common factoring rule is:

$$a^2-b^2=(a-b)(a+b)$$

A canceled factor can create a **removable discontinuity**, also called a hole. The canceled input is still not in the original domain.

A zero left in the simplified denominator can give a **vertical asymptote**. The graph gets closer to that vertical line near the excluded input.

Horizontal asymptotes depend on polynomial degree after simplification:

- If the numerator has lower degree than the denominator, the horizontal asymptote is $y=0$.
- If the degrees are equal, divide the leading coefficient of the numerator by the leading coefficient of the denominator.
- If the numerator has degree exactly $1$ more than the denominator, there is no horizontal asymptote. Polynomial division can give a **slant asymptote**, a diagonal line the graph approaches far to the left or right.
- If the numerator degree is more than $1$ greater, there is no horizontal or slant asymptote of these types. Polynomial division gives a higher-degree polynomial part.

After polynomial division, a rational function can be written as:

$$\dfrac{P(x)}{Q(x)}=q(x)+\dfrac{r(x)}{Q(x)}$$

When $q(x)$ is linear and the fraction gets close to $0$ far from the vertical asymptotes, $y=q(x)$ is the slant asymptote.

**Absolute value:** $|x|$ means the distance of $x$ from $0$. Distance cannot be negative, so $|x|\ge0$.

For an equation $|u|=c$ with $c>0$, the inside value can be $c$ or $-c$ because both are the same distance from $0$.

A useful transformed form is:

$$f(x)=a|x-h|+k$$

Its vertex is $(h,k)$. The value $h$ shifts the graph left or right, and $k$ shifts it up or down. If $|a|>1$, the graph has a vertical stretch and the V becomes narrower. If $0<|a|<1$, it has a vertical compression and becomes wider. If $a<0$, the V reflects across the $x$-axis and opens downward.

**Exponential:** $f(x)=a^x$ for $a>0$ and $a\ne1$. If $a>1$, the outputs grow as $x$ increases. If $0<a<1$, the outputs shrink toward $0$ as $x$ increases.

**Logarithmic:** $f(x)=\log_a x$ for $a>0$, $a\ne1$, and $x>0$. It reverses the exponential relationship $a^y=x$:

$$\log_a x=y\quad\Longleftrightarrow\quad a^y=x$$

**Piecewise:** a function that uses different formulas for different input ranges. At a boundary, use the rule whose condition includes that input.

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

1. Use the vertex formula.

$$x=-\dfrac{-4}{2(1)}=2$$

2. Find the matching $y$-value.

$$f(2)=4-8+3=-1$$

3. The vertex is $(2,-1)$. Since $a=1>0$, the parabola opens upward, so the vertex is a minimum.

### #3: Vertical and Horizontal Asymptotes

Find the vertical and horizontal asymptotes of $f(x)=\dfrac{x+1}{x-2}$.

**Solution:**

1. The denominator is $0$ at $x=2$. The numerator is not $0$ there, so $x=2$ is a vertical asymptote.
2. The numerator and denominator have the same degree. Their leading coefficients are both $1$.

$$y=\dfrac{1}{1}=1$$

3. The horizontal asymptote is $y=1$.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "rational", "formula": "y = (x+1)/(x-2)", "asymptotes": [{"axis": "x", "value": 2}, {"axis": "y", "value": 1}], "semanticsLabel": "A rational function graph with a vertical asymptote at x = 2 and a horizontal asymptote at y = 1."} -->

A graph can cross a horizontal or slant asymptote. Those lines describe what the graph approaches far away, not a line it can never touch.

### #4: Slant Asymptote

Find the slant asymptote of $f(x)=\dfrac{x^2+1}{x-1}$.

**Solution:**

1. The numerator has degree exactly $1$ more than the denominator, so divide the polynomials.
2. Polynomial division gives:

$$x^2+1=(x-1)(x+1)+2$$

3. Rewrite the function.

$$f(x)=x+1+\dfrac{2}{x-1}$$

4. Far from $x=1$, the fraction gets close to $0$. The slant asymptote is:

$$y=x+1$$

### #5: Removable Hole

Describe the graph feature of $f(x)=\dfrac{x^2-1}{x-1}$ at $x=1$.

**Solution:**

1. Factor the numerator.

$$x^2-1=(x-1)(x+1)$$

2. Cancel the common factor to see the graph shape.

$$f(x)=x+1,\qquad x\ne1$$

3. The original denominator is $0$ at $x=1$, so that input stays outside the domain.
4. The simpler line would have value $2$ there, so the graph has a hole at $(1,2)$.

### #6: Absolute-Value Equation

Solve $|2x-5|=7$.

**Solution:**

1. Since $7>0$, the inside can be $7$ or $-7$.

$$2x-5=7\quad\text{or}\quad2x-5=-7$$

2. Solve both equations.

$$x=6\quad\text{or}\quad x=-1$$

3. Both values satisfy the original equation.

### #7: Absolute-Value Transformation

Describe the graph of $f(x)=-2|x-3|+1$ from the basic graph $y=|x|$.

**Solution:**

1. The value $h=3$ shifts the graph right by $3$. The value $k=1$ shifts it up by $1$.
2. Since $|a|=2>1$, the V is narrower than $y=|x|$.
3. Since $a=-2<0$, the graph reflects across the $x$-axis and opens downward.
4. The vertex is $(3,1)$.

### #8: Exponential Growth and Decay

Classify each function as exponential growth or exponential decay: $f(x)=1.2^x$ and $g(x)=0.4^x$.

**Solution:**

1. For $f(x)$, the base is $1.2>1$, so the function shows exponential growth.
2. For $g(x)$, the base satisfies $0<0.4<1$, so the function shows exponential decay.

### #9: Exponential and Logarithmic Equations

Solve $2^{x+1}=32$, then evaluate $\log_3 81$.

**Solution:**

1. Write $32$ as a power of $2$.

$$32=2^5$$

2. Match the exponents.

$$x+1=5$$

$$x=4$$

3. For the logarithm, find the power of $3$ that gives $81$.

$$3^4=81$$

4. Therefore:

$$\log_3 81=4$$

### #10: Evaluating a Piecewise Function

Let $f(x)=x^2$ when $x<2$, and $f(x)=3x-1$ when $x\ge2$. Find $f(2)+f(-3)$.

**Solution:**

1. For $x=2$, use the second rule because it includes $2$.

$$f(2)=3(2)-1=5$$

2. For $x=-3$, use the first rule because $-3<2$.

$$f(-3)=(-3)^2=9$$

3. Add the results.

$$f(2)+f(-3)=14$$

## Speed Tricks & Shortcuts

For graph matching, identify the family first. Then test an easy input such as $x=0$ when $0$ belongs to the domain. One point can remove some choices, but one matching point does not prove two graphs are identical.

For a quadratic's maximum or minimum value, find the vertex and use its $y$-coordinate.

For exponential equations, look for a way to write both sides with the same base.

For a rational function, simplify common factors before deciding whether a denominator zero gives a vertical asymptote or a hole. Keep the original domain restriction even after a factor cancels.

## Traps to Watch For

### #1: Impossible Absolute-Value Equation

> Absolute value cannot equal a negative number in the real numbers.

An equation such as $|u|=-3$ has no real solution because distance from $0$ is never negative.

### #2: Piecewise Boundary

> At a boundary, use the rule that includes the input.

If one rule says $x<2$ and the other says $x\ge2$, then $x=2$ uses the second rule.

### #3: Growth and Decay

> Check whether the exponential base is above or below $1$.

A base greater than $1$ gives growth. A base between $0$ and $1$ gives decay as $x$ increases.

### #4: Logarithm Domain

> A real logarithm needs a positive argument.

For real logarithms, $\log_2 0$ and $\log_2(-8)$ are undefined because their arguments are not positive.

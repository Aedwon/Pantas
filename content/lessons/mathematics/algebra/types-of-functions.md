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

**Classify** means name the group something belongs to. **Evaluate** means find the final number value.

**Linear:** $f(x)=mx+b$. Its graph is a straight nonvertical line. A vertical line is not a function of $x$ because one input has many outputs.

A **polynomial** is a sum of terms with nonnegative whole-number powers of $x$, such as $x^2+3x-1$. A **power function** has the form $kx^p$, where $k$ and $p$ are constants. For example, $x^5$ is both a polynomial and a power function.

**Quadratic:** $f(x)=ax^2+bx+c$ with $a\ne0$. Its graph is a parabola.

It opens upward when $a>0$ and downward when $a<0$. The **vertex** is its turning point. An upward-opening parabola has its lowest value there; a downward-opening one has its highest value there.

The vertex has $x$-coordinate:

$$x=-\dfrac{b}{2a}$$

Put this input into the function to find the vertex's $y$-coordinate.

**Rational:** a function written as one polynomial divided by another:

$$f(x)=\dfrac{P(x)}{Q(x)},\qquad Q(x)\ne0$$

The domain leaves out every value that makes the original denominator $0$. The **degree** of a nonzero polynomial is its highest exponent. Its **leading coefficient** is the number multiplying its highest-power term.

An **asymptote** is a line that a graph approaches in a certain direction. First cancel common factors to study the simpler graph shape. One useful factoring rule is:

$$a^2-b^2=(a-b)(a+b)$$

If a denominator factor cancels completely, its excluded input can leave a **removable discontinuity**, or hole. The simpler formula gives the height of the missing point. The input stays outside the original domain.

If a factor remains in the denominator after all common factors cancel, its real zero gives a **vertical asymptote**. Near that input, the graph rises or falls without bound. A partly canceled factor can therefore still give a vertical asymptote.

Compare degrees after cancellation to find the graph's behavior far to the left and right:

- A lower numerator degree gives the horizontal asymptote $y=0$.
- Equal degrees give a horizontal asymptote at the ratio of the leading coefficients.
- A numerator degree exactly $1$ greater gives a **slant asymptote**, a diagonal line the graph approaches far away.
- A numerator degree more than $1$ greater gives no horizontal or slant asymptote. Division gives a curved polynomial part instead.

Polynomial division separates a rational function into a polynomial part and a smaller fraction:

$$\dfrac{P(x)}{Q(x)}=q(x)+\dfrac{r(x)}{Q(x)}$$

Here $q(x)$ is the quotient and $r(x)$ is the remainder, whose degree is below the denominator's degree. Far to the left or right, the fraction gets close to $0$. If $q(x)$ is linear, $y=q(x)$ is the slant asymptote.

A graph can cross a horizontal or slant asymptote. These lines describe what happens far away, not a boundary the graph cannot touch.

**Absolute value:** $|x|$ means the distance of $x$ from $0$. The bars tell you to take that distance, so the result cannot be negative.

$$|x|=\begin{cases}x,&x\ge0\\-x,&x<0\end{cases}$$

For example, $|-4|=-(-4)=4$. The graph of $y=|x|$ is a V with vertex $(0,0)$.

For $|u|=c$ with $c>0$, the inside value is $c$ or $-c$. Both are the same distance from $0$. If $c=0$, only $u=0$ works; if $c<0$, there is no real solution.

A transformed absolute-value function has the form:

$$f(x)=a|x-h|+k,\qquad a\ne0$$

Its vertex is $(h,k)$. Replacing $x$ with $x-h$ moves the vertex to input $h$. Adding $k$ moves every output up by $k$ when $k>0$, or down when $k<0$.

Multiplying by $a$ changes the outputs' distances from the vertex height. If $|a|>1$, the V stretches vertically and becomes narrower. If $0<|a|<1$, it compresses vertically and becomes wider.

A negative $a$ also reflects the V across the $x$-axis before the vertical shift. The V then opens downward.

**Exponential:** $f(x)=a^x$ for $a>0$ and $a\ne1$. The variable is in the exponent. Each increase of $1$ in $x$ multiplies the output by $a$.

If $a>1$, the outputs grow as $x$ increases. If $0<a<1$, they shrink toward $0$. Equal powers of the same allowed base have equal exponents.

**Logarithmic:** $f(x)=\log_a x$ for $a>0$, $a\ne1$, and $x>0$. A logarithm asks which exponent gives the input:

$$\log_a x=y\quad\Longleftrightarrow\quad a^y=x$$

**Piecewise:** a function that uses different formulas for different input ranges. At a boundary, use the rule whose condition includes that input.

<!-- ILLUSTRATION: seven labeled coordinate panels: y=x on -3<=x<=3; y=x^2 on -3<=x<=3; y=1/x on -3<=x<=3 excluding 0 with asymptotes x=0 and y=0; y=|x| on -3<=x<=3; y=2^x on -3<=x<=3; y=log_2(x) on 0<x<=4 with asymptote x=0; and y=x for x<0, y=2 for x>=0 on -3<=x<=3 with open point (0,0) and filled point (0,2); label each family and both axes -->

## Examples

### #1: Naming the Family

Classify $f(x)=3x-7$, $g(x)=5^x$, and $h(x)=x^5$.

**Solution:**

1. $f(x)=3x-7$ is linear because it has the form $mx+b$.
2. $g(x)=5^x$ is exponential because the variable is in the exponent.
3. $h(x)=x^5$ is a polynomial power function. Its exponent is fixed, and its base is the variable.

### #2: Vertex of a Quadratic

Find the vertex of $f(x)=x^2-4x+3$ and state whether it is a minimum or maximum.

**Solution:**

1. Use the vertex formula.

$$x=-\dfrac{-4}{2(1)}=2$$

2. Find the matching output.

$$f(2)=4-8+3=-1$$

3. The vertex is $(2,-1)$. Since $a=1>0$, the graph opens upward. Its minimum value is $-1$.

<!-- ILLUSTRATION: coordinate graph of y=x^2-4x+3 on -1<=x<=5 and -2<=y<=9, with labeled vertex (2,-1), opening upward, and both axes labeled -->

### #3: Vertical and Horizontal Asymptotes

Find the vertical and horizontal asymptotes of $f(x)=\dfrac{x+1}{x-2}$.

**Solution:**

1. No factor cancels. The denominator is $0$ at $x=2$, so the vertical asymptote is $x=2$.
2. The degrees are equal. Divide the leading coefficients.

$$y=\dfrac{1}{1}=1$$

3. The horizontal asymptote is $y=1$.

<!-- ILLUSTRATION: coordinate graph of y=(x+1)/(x-2), with dashed asymptotes x=2 and y=1, labeled points (-1,0), (0,-1/2), and (3,4), and both branches -->

### #4: Lower Numerator Degree

Find the horizontal asymptote of $f(x)=\dfrac{2}{x^2+1}$.

**Solution:**

1. The numerator has degree $0$, and the denominator has degree $2$.
2. The numerator degree is lower, so the horizontal asymptote is $y=0$.

### #5: Slant Asymptote

Find the slant asymptote of $f(x)=\dfrac{x^2+1}{x-1}$.

**Solution:**

1. The numerator degree is exactly $1$ greater. Divide using this identity:

$$x^2+1=(x-1)(x+1)+2$$

2. Rewrite the function.

$$f(x)=x+1+\dfrac{2}{x-1}$$

3. Far to the left or right, the fraction gets close to $0$. The slant asymptote is $y=x+1$.

### #6: Removable Hole

Describe the graph feature of $f(x)=\dfrac{x^2-1}{x-1}$ at $x=1$.

**Solution:**

1. Factor the numerator.

$$x^2-1=(x-1)(x+1)$$

2. Cancel to see the graph shape. Keep the original excluded input.

$$f(x)=x+1,\qquad x\ne1$$

3. The simpler line gives $1+1=2$. The graph has a hole at $(1,2)$, not a vertical asymptote.

<!-- ILLUSTRATION: coordinate graph of y=(x^2-1)/(x-1), showing line y=x+1 with an open circle at (1,2) -->

### #7: Absolute-Value Equation

Solve $|2x-5|=7$.

**Solution:**

1. The inside can be $7$ or $-7$ because both have distance $7$ from $0$.

$$2x-5=7\quad\text{or}\quad2x-5=-7$$

2. Add $5$ to each equation.

$$2x=12\quad\text{or}\quad2x=-2$$

3. Divide by $2$.

$$x=6\quad\text{or}\quad x=-1$$

4. Substitution gives $|7|=7$ or $|-7|=7$. Both answers work.

### #8: Absolute-Value Transformation

Describe the graph of $f(x)=-2|x-3|+1$ from the basic graph $y=|x|$.

**Solution:**

1. The expression $x-3$ shifts the graph right by $3$. The added $1$ shifts it up by $1$.
2. The factor has size $2$, so the graph stretches vertically by $2$ and becomes narrower.
3. The negative factor reflects the V across the $x$-axis before the upward shift. The graph opens downward with vertex $(3,1)$.

<!-- ILLUSTRATION: coordinate graph of y=-2|x-3|+1 with vertex (3,1), points (2,-1) and (4,-1), opening downward, alongside dashed y=|x| for comparison -->

### #9: A Wider Absolute-Value Graph

Describe the graph of $g(x)=\dfrac{1}{2}|x+2|-3$.

**Solution:**

1. Write $x+2$ as $x-(-2)$. The graph shifts left by $2$ and down by $3$, giving vertex $(-2,-3)$.
2. The positive factor $\dfrac{1}{2}$ makes the V wider. It still opens upward.

<!-- ILLUSTRATION: coordinate graph of y=(1/2)|x+2|-3 on -6<=x<=4 and -4<=y<=4, with labeled vertex (-2,-3) and points (-4,-2) and (0,-2), alongside dashed y=|x| for comparison, and both axes labeled -->

### #10: Exponential Growth and Decay

Classify $f(x)=1.2^x$ and $g(x)=0.4^x$ as growth or decay. Find each function's values at $x=0$ and $x=1$.

**Solution:**

1. The base $1.2>1$ gives growth.

$$f(0)=1,\qquad f(1)=1.2$$

2. The base satisfies $0<0.4<1$, so it gives decay.

$$g(0)=1,\qquad g(1)=0.4$$

### #11: Exponential and Logarithmic Equations

Solve $2^{x+1}=32$, then evaluate $\log_3 81$.

**Solution:**

1. Write the right side with base $2$.

$$32=2^5$$

2. Match the exponents and subtract $1$.

$$x+1=5$$

$$x=4$$

3. For the logarithm, find the power of $3$ that gives $81$.

$$3^4=81$$

4. Therefore, $\log_3 81=4$.

### #12: Evaluating a Piecewise Function

Let $f(x)=x^2$ when $x<2$, and $f(x)=3x-1$ when $x\ge2$. Find $f(2)+f(-3)$.

**Solution:**

1. The second rule includes $2$.

$$f(2)=3(2)-1=5$$

2. Since $-3<2$, use the first rule for $-3$.

$$f(-3)=(-3)^2=9$$

3. Add the results.

$$f(2)+f(-3)=5+9=14$$

### #13: Matching a Graph to a Formula

A graph is a downward-opening V with vertex $(2,3)$ and passes through $(0,-1)$. Which formula matches it: $y=2|x-2|+3$, $y=-2|x+2|+3$, or $y=-2|x-2|+3$?

<!-- ILLUSTRATION: coordinate graph on -1<=x<=5 and -4<=y<=4 of a downward-opening V with labeled vertex (2,3) and labeled point (0,-1), with no equation printed -->

**Solution:**

1. The downward-opening V needs a negative factor. This removes $y=2|x-2|+3$.
2. The vertex has input $2$, so the inside must be $x-2$. This leaves $y=-2|x-2|+3$.
3. Check the given point.

$$-2|0-2|+3=-4+3=-1$$

4. The matching formula is $y=-2|x-2|+3$.

## Speed Tricks & Shortcuts

For graph matching, identify the family first. Then check the vertex, opening direction, or asymptotes. Test an easy input that belongs to the domain.

One matching point does not prove that two graphs are identical. Use the shape and the point together.

For a quadratic's maximum or minimum value, find the vertex and use its $y$-coordinate. For exponential equations, try writing both sides with the same base.

For rational functions, cancel common factors before deciding between a hole and a vertical asymptote. Keep every original domain restriction.

## Traps to Watch For

### #1: Impossible Absolute-Value Equation

> Absolute value cannot equal a negative number.

The equation $|u|=-3$ has no real solution. Distance from $0$ cannot be negative, so changing it into two equations would give false answers.

### #2: Piecewise Boundary

> Use the rule that includes the boundary input.

If the rules say $x<2$ and $x\ge2$, input $2$ uses the second rule. Using the first rule can give the wrong output.

### #3: Growth and Decay

> Check whether the exponential base is above or below $1$.

A base greater than $1$ gives growth. A base between $0$ and $1$ gives decay as $x$ increases. A large-looking exponent alone does not mean the output grows.

### #4: Logarithm Domain

> A real logarithm needs a positive input.

The values $\log_2 0$ and $\log_2(-8)$ are undefined in the real numbers. Neither input can be the value of $2$ raised to a real power.

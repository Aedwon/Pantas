---
_id: "lesson-algebra-types-of-functions"
title: "Types of Functions (Linear, Quadratic, Rational, Absolute Value, Exponential, Logarithmic, Piecewise)"
summary: "This lesson teaches you the seven function families you will meet on the exam and how to recognize and solve each one."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 14
isActive: true
---
## Core Concept

Functions come in families. Each family has its own equation shape and its own graph shape. If you can name the family fast, you already know how the function behaves.

**Linear**: $f(x) = mx + b$. The graph is a straight line. The number $m$ is the slope (steepness) and $b$ is where the line crosses the $y$-axis.

**Quadratic**: $f(x) = ax^2 + bx + c$. The graph is a **parabola**, a U-shape. It opens up if $a$ is positive and opens down if $a$ is negative. Its tip is called the **vertex**, found at $x = \dfrac{-b}{2a}$.

**Rational**: a fraction with $x$ in the denominator, like $f(x) = \dfrac{x + 1}{x - 2}$. The graph has **asymptotes**, invisible lines the curve gets close to but never touches.

**Absolute value**: $f(x) = |x|$. The graph is a V-shape. Absolute value means distance from zero, so the output is never negative.

**Exponential**: $f(x) = a^x$, where the variable is in the EXPONENT, like $f(x) = 2^x$. The graph grows very fast in one direction and flattens toward the $x$-axis in the other.

**Logarithmic**: $f(x) = \log_a x$. This is the inverse of the exponential. The statement $\log_2 8 = 3$ just asks: "$2$ raised to what power gives $8$?" The answer is $3$.

**Piecewise**: a function built from pieces, with a different rule for different parts of the domain. Read the conditions to know which rule to use.

<!-- ILLUSTRATION: mini-gallery of seven small labeled graphs, straight line, parabola, rational curve with asymptotes, V-shape, exponential growth curve, logarithmic curve, and a two-piece piecewise graph -->

CETs test this topic in two ways: matching an equation to its graph shape, and solving one equation from each family. Learn the shapes and you earn easy points.

## Examples

### #1: Naming the Family

Classify each function: $f(x) = 3x - 7$, $g(x) = 5^x$, and $h(x) = x^5$.

**Solution:**
Look at where the variable sits.

1. In $f(x) = 3x - 7$, the variable $x$ has power $1$. This is **linear**.
2. In $g(x) = 5^x$, the variable is in the exponent. This is **exponential**.
3. In $h(x) = x^5$, the variable is in the base and the exponent is a fixed number. This is NOT exponential. It is a polynomial (power) function.
4. The pair $5^x$ and $x^5$ is a classic exam trick. The variable's position decides the family.

### #2: Vertex of a Quadratic

Find the vertex of $f(x) = x^2 - 4x + 3$ and tell whether it is a minimum or maximum point.

**Solution:**
Use the vertex formula $x = \dfrac{-b}{2a}$ with $a = 1$ and $b = -4$.

1. Find the $x$-coordinate of the vertex.

$$x = \dfrac{-(-4)}{2(1)} = \dfrac{4}{2} = 2$$

2. Plug $x = 2$ back into the function to get the $y$-coordinate.

$$f(2) = 2^2 - 4(2) + 3$$

$$f(2) = 4 - 8 + 3 = -1$$

3. The vertex is $(2, -1)$.
4. Since $a = 1$ is positive, the parabola opens up. The vertex is the lowest point, so it is a **minimum**.

### #3: Asymptotes of a Rational Function

Find the vertical and horizontal asymptotes of $f(x) = \dfrac{x + 1}{x - 2}$.

**Solution:**
Asymptotes come from the denominator and from comparing the top and bottom.

1. The **vertical asymptote** is where the denominator becomes $0$.

$$x - 2 = 0$$

$$x = 2$$

2. For the **horizontal asymptote**, compare the highest powers on top and bottom. Both are $x^1$, so divide their front numbers (coefficients): $1$ over $1$.

$$y = \dfrac{1}{1} = 1$$

3. The vertical asymptote is $x = 2$ and the horizontal asymptote is $y = 1$.

<!-- ILLUSTRATION: graph of (x+1)/(x-2) with dashed vertical asymptote at x = 2 and dashed horizontal asymptote at y = 1 -->

### #4: Solving an Absolute Value Equation

Solve for $x$: $|2x - 5| = 7$.

**Solution:**
Absolute value means distance, and two different numbers can be $7$ steps from zero: $7$ and $-7$. So we split into two equations.

1. First case: the inside equals $7$.

$$2x - 5 = 7$$

$$2x = 12$$

$$x = 6$$

2. Second case: the inside equals $-7$.

$$2x - 5 = -7$$

$$2x = -2$$

$$x = -1$$

3. The solutions are $x = 6$ and $x = -1$. Check: $|2(6) - 5| = |7| = 7$ and $|2(-1) - 5| = |-7| = 7$. Both work.

### #5: Exponential and Logarithmic Equations

Solve $2^{x + 1} = 32$, then evaluate $\log_3 81$.

**Solution:**
For exponentials, rewrite both sides with the same base. For logs, ask the power question.

1. Write $32$ as a power of $2$.

$$32 = 2^5$$

2. Now the equation has matching bases, so the exponents must be equal.

$$x + 1 = 5$$

$$x = 4$$

3. For $\log_3 81$, ask: "$3$ raised to what power gives $81$?"

$$3^4 = 81$$

4. So $\log_3 81 = 4$.

### #6: Evaluating a Piecewise Function

A function is defined as $f(x) = x^2$ when $x < 2$, and $f(x) = 3x - 1$ when $x \geq 2$. Find $f(2) + f(-3)$.

**Solution:**
For each input, first decide which piece owns it.

1. For $f(2)$: is $2 < 2$? No. Is $2 \geq 2$? Yes. Use the second rule.

$$f(2) = 3(2) - 1 = 5$$

2. For $f(-3)$: is $-3 < 2$? Yes. Use the first rule.

$$f(-3) = (-3)^2 = 9$$

3. Add the results.

$$f(2) + f(-3) = 5 + 9 = 14$$

## Speed Tricks & Shortcuts

For "which graph matches this equation" questions, you often need only two facts: the family shape and one easy point. Plug in $x = 0$. If $f(0) = 3$, the graph must cross the $y$-axis at $3$. That one check usually kills three wrong choices.

For a quadratic's maximum or minimum VALUE (not point), you only need the $y$-coordinate of the vertex. Compute $x = \dfrac{-b}{2a}$, plug it in once, and stop.

For exponential equations, memorize the small powers: $2^5 = 32$, $2^{10} = 1024$, $3^4 = 81$, $5^3 = 125$. Matching bases becomes instant.

## Traps to Watch For

### #1: The Impossible Absolute Value

> If an absolute value equals a negative number, there is NO solution.

An equation like $|3x + 2| = -5$ has no solution at all, because distance can never be negative. Do not split it into two cases and "solve" it. The choice "no solution" is correct, and the worked-out numbers are the bait.

### #2: The Boundary of a Piecewise Function

> At a boundary point, check the inequality signs carefully.

In Example $6$, $f(2)$ uses the rule with $x \geq 2$, not the $x < 2$ rule. Students grab the top rule out of habit and get $f(2) = 4$ instead of $5$. The wrong-piece answer is always among the choices.

### #3: $x^2$ Grows, but $2^x$ Explodes

> Do not confuse power functions with exponential functions.

At $x = 10$, $x^2$ gives $100$ but $2^x$ gives $1024$. When a question says "which grows fastest for large $x$", the exponential always beats any polynomial. Also remember from Example $1$: variable in the exponent means exponential, variable in the base means power.

### #4: Logs of Zero and Negatives

> You can only take the logarithm of a POSITIVE number.

Expressions like $\log_2 0$ and $\log_2(-8)$ are undefined. No power of $2$ gives zero or a negative number. So the domain of $f(x) = \log_a x$ is $x > 0$, and solutions that make the inside of a log negative must be thrown away.

---
_id: "lesson-precalculus-basic-calculus-limits-and-continuity"
title: "Limits and Continuity"
summary: "How to evaluate basic limits, handle common indeterminate forms, and test continuity."
subject: "subject-mathematics"
topic: "topic-precalculus-basic-calculus"
estimatedMinutes: 13
isActive: true
---
## Core Concept

A **limit** asks what value $f(x)$ approaches as $x$ approaches a specified input. We write:

$$\lim_{x\to a}f(x)=L$$

A limit is determined by nearby values, so it can exist even when $f(a)$ is undefined or different from the limiting value.

### Direct substitution

For functions known to be continuous at $a$—such as polynomials, and rational functions whose denominator is nonzero there—direct substitution gives the limit:

$$\lim_{x\to a}f(x)=f(a)$$

Direct substitution is therefore a useful **first check**, but a finite value of $f(a)$ alone does not prove continuity for an arbitrary piecewise or otherwise discontinuous function. The local behavior must support the substitution rule being used.

If substitution into an algebraic expression gives $0/0$, that is an **indeterminate form**, not a final answer. It signals that more analysis is needed; in elementary rational examples, factoring and cancelling a common factor often resolves the limit.

A **one-sided limit** approaches from one direction: $x\to a^-$ from the left or $x\to a^+$ from the right. A finite two-sided limit exists exactly when both one-sided limits exist and are equal.

### Rational-function limits at infinity

For a rational function, compare the degrees and leading terms:

- numerator degree smaller than denominator degree: the limit as $x\to\pm\infty$ is $0$;
- equal degrees: the limit is the ratio of leading coefficients;
- numerator degree larger: there is no horizontal asymptote. The end behavior follows the leading-term quotient and may tend to $+\infty$ or $-\infty$ (or approach a polynomial/oblique asymptote after division), depending on degrees and signs.

### Continuity

A function is continuous at $x=a$ when all three conditions hold:

1. $f(a)$ is defined.
2. $\lim_{x\to a}f(x)$ exists.
3. $\lim_{x\to a}f(x)=f(a)$.

Common discontinuities include removable holes, jumps, and infinite discontinuities associated with vertical asymptotes.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "limits-gallery", "discontinuities": ["hole", "jump", "vertical-asymptote"], "semanticsLabel": "Three mini graphs showing a removable hole, a jump between pieces, and a vertical asymptote."} -->

## Examples

### #1: Direct Substitution for a Polynomial

Evaluate $\lim_{x\to2}(3x+1)$.

**Solution:**
Polynomials are continuous everywhere, so direct substitution is valid.

$$3(2)+1=7$$

Therefore:

$$\lim_{x\to2}(3x+1)=7$$

### #2: The $0/0$ Factor-and-Cancel Case

Evaluate $\lim_{x\to3}\dfrac{x^2-9}{x-3}$.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "limit-hole", "formula": "y = x + 3", "hole": [3, 6], "points": [[3, 6]], "semanticsLabel": "A graph of y = x + 3 with an open circle hole at (3, 6)."} -->


**Solution:**
Direct substitution gives $0/0$, so simplify.

1. Factor the numerator.

$$\dfrac{(x-3)(x+3)}{x-3}$$

2. For $x\ne3$, cancel the common factor.

$$x+3$$

3. The simplified function agrees with the original at every nearby point except the hole itself, so:

$$\lim_{x\to3}(x+3)=6$$

The limit is $6$ even though the original quotient is undefined at $x=3$.

### #3: Factoring a Trinomial

Evaluate $\lim_{x\to2}\dfrac{x^2+x-6}{x-2}$.

**Solution:**
1. Factor:

$$x^2+x-6=(x-2)(x+3)$$

2. For $x\ne2$, simplify the quotient to $x+3$.
3. Take the limit:

$$\lim_{x\to2}(x+3)=5$$

### #4: A Limit at Infinity

Evaluate $\lim_{x\to\infty}\dfrac{3x^2+5}{x^2-2}$.

**Solution:**
The numerator and denominator have the same degree, so use the leading coefficients.

$$\lim_{x\to\infty}\dfrac{3x^2+5}{x^2-2}=\dfrac31=3$$

### #5: Making a Piecewise Function Continuous

A function is defined as $f(x)=x^2+1$ for $x<1$ and $f(x)=x+k$ for $x\ge1$. Find $k$ so that $f$ is continuous at $x=1$.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "piecewise", "formula": "x^2+1 for x<1, x+1 for x>=1", "points": [[1, 2]], "semanticsLabel": "A continuous piecewise graph of a parabola and a line meeting at x = 1."} -->


**Solution:**
Continuity requires the left-hand limit, right-hand limit, and function value to agree.

1. Left-hand limit:

$$1^2+1=2$$

2. The right-hand expression and function value at $1$ are:

$$1+k$$

3. Set them equal.

$$1+k=2$$

$$k=1$$

With $k=1$, the pieces meet at $(1,2)$.

## Speed Tricks & Shortcuts

For polynomial and rational expressions, substitution is a good first diagnostic. A nonzero denominator usually ends the rational-function problem immediately. A $0/0$ result means the expression needs further work, not that the limit automatically fails.

For rational limits at infinity, the leading terms determine end behavior. Equal degrees give the ratio of leading coefficients; a larger denominator degree gives $0$; a larger numerator degree requires attention to the leading-term quotient or polynomial division.

For simple removable-hole limits, factor only after identifying the factor associated with the approached value, but cancel it only algebraically for nearby $x\ne a$. The cancellation does not redefine the original function at the hole.

## Traps to Watch For

### #1: Treating $0/0$ as a Value

> $0/0$ is an indeterminate form, not a numerical answer.

It tells you that direct substitution has not settled the limit. The next method depends on the expression; factoring is only one common elementary technique.

### #2: Confusing the Limit with the Function Value

> A limit depends on nearby behavior, not solely on $f(a)$.

A function can have a hole at $a$, or be assigned a different value there, while nearby values approach a well-defined limit.

### #3: Ignoring One-Sided Behavior

> A two-sided limit exists only when the left-hand and right-hand limits agree.

At a jump, the two sides approach different finite values. Near a vertical asymptote, the sides may also diverge in different directions.

### #4: Nonzero over Zero Needs One-Sided Analysis

> A nonzero numerator over a denominator approaching zero is not the indeterminate form $0/0$.

The magnitude may grow without bound, but the sign can differ on the two sides. For example, near a simple vertical asymptote one side may tend to $+\infty$ and the other to $-\infty$, so the ordinary two-sided finite limit does not exist.

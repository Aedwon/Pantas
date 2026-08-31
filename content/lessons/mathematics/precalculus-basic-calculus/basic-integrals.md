---
_id: "lesson-precalculus-basic-calculus-basic-integrals"
title: "Basic Integrals"
summary: "How to find basic antiderivatives and evaluate definite integrals."
subject: "subject-mathematics"
topic: "topic-precalculus-basic-calculus"
estimatedMinutes: 12
isActive: true
---
## Core Concept

An **antiderivative** reverses differentiation. Since $\dfrac{d}{dx}(x^2)=2x$, one antiderivative of $2x$ is $x^2$.

On an interval where the functions involved are defined, the family of antiderivatives is written:

$$\int 2x\,dx=x^2+C$$

The constant $C$ is needed because adding any constant does not change a derivative.

### Power rule for indefinite integrals

For $n\ne-1$ on intervals where $x^n$ is defined:

$$\int x^n\,dx=\dfrac{x^{n+1}}{n+1}+C$$

The case $n=-1$ is different:

$$\int\dfrac1x\,dx=\ln|x|+C$$

on any interval that does not cross $x=0$.

Sums and differences integrate term by term, and constant multipliers can be factored out.

### Definite integrals

A definite integral represents **net signed area**: area above the $x$-axis contributes positively and area below contributes negatively. If $f(x)\ge0$ throughout $[a,b]$, the definite integral equals the ordinary geometric area under the curve on that interval.

For a continuous function $f$ on $[a,b]$, if $F$ is any antiderivative of $f$, the Fundamental Theorem of Calculus gives:

$$\int_a^b f(x)\,dx=F(b)-F(a)$$

The arbitrary constant cancels, so no $+C$ appears in the final value of a definite integral.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "integral-area", "formula": "Net signed area from x = a to x = b", "points": [[1, 0], [4, 0]], "semanticsLabel": "A graph showing signed regions between a curve and the x-axis from x equals a to x equals b."} -->

## Examples

### #1: Power Rule

Evaluate $\int x^3\,dx$.

**Solution:**
Increase the exponent by $1$ and divide by the new exponent.

$$\int x^3\,dx=\dfrac{x^4}{4}+C$$

Differentiating $x^4/4$ returns $x^3$.

### #2: A Polynomial

Evaluate $\int(6x^2-4x+5)\,dx$.

**Solution:**
Integrate term by term.

$$\int(6x^2-4x+5)\,dx=2x^3-2x^2+5x+C$$

### #3: Rewriting a Root

Evaluate $\int\sqrt{x}\,dx$ over the usual real domain $x\ge0$.

**Solution:**
Write $\sqrt{x}=x^{1/2}$ and use the power rule.

$$\int x^{1/2}\,dx=\dfrac{x^{3/2}}{3/2}+C=\dfrac23x^{3/2}+C$$

### #4: A Definite Integral with a Nonnegative Integrand

Evaluate $\int_0^2 3x^2\,dx$.

**Solution:**
An antiderivative of $3x^2$ is $x^3$.

$$\int_0^2 3x^2\,dx=[x^3]_0^2=8$$

Because $3x^2\ge0$ on $[0,2]$, this value is also the ordinary area between the graph and the $x$-axis over the interval.

### #5: Definite Integral with Two Terms

Evaluate $\int_1^3(2x+1)\,dx$.

**Solution:**
1. An antiderivative is $F(x)=x^2+x$.
2. Evaluate top minus bottom.

$$F(3)-F(1)=(9+3)-(1+1)=10$$

3. Here $2x+1$ is positive on $[1,3]$, so the net signed area equals the ordinary area. A trapezoid check gives:

$$\dfrac12(3+7)(2)=10$$

## Speed Tricks & Shortcuts

Differentiate an antiderivative to check it. This is a reliable way to catch coefficient or exponent mistakes.

Rewrite roots and reciprocal powers when that keeps you within the power rule's valid domain. Remember that $1/x$ is the exceptional exponent $-1$ case and integrates to $\ln|x|+C$ on intervals excluding zero.

For a definite integral of a nonnegative linear function over an interval, geometric area can be faster than antidifferentiation. If the graph crosses below the axis, however, geometric **total area** and the definite integral are no longer the same quantity unless you account for signs.

## Traps to Watch For

### #1: Missing the Constant of Integration

> An indefinite antiderivative family needs $+C$.

A definite integral instead evaluates to a number, and the arbitrary constants cancel in endpoint subtraction.

### #2: Dividing by the Old Exponent

> In the integral power rule, increase the exponent first, then divide by that new exponent.

For $\int x^3\,dx$, the denominator is $4$, not $3$.

### #3: The $n=-1$ Exception

> The power-rule formula cannot be used at $n=-1$ because it would divide by zero.

On intervals avoiding zero:

$$\int\dfrac1x\,dx=\ln|x|+C$$

### #4: Signed Area vs. Total Geometric Area

> A definite integral counts regions below the $x$-axis negatively.

If a problem asks for total geometric area, split at zeros of the function and use absolute areas as necessary. Do not automatically equate every definite integral with a positive area.

### #5: Fundamental Theorem Conditions

> The basic evaluation theorem used here is stated for a continuous integrand on the closed interval.

More advanced integration theory handles broader cases, but the continuity condition is the appropriate one for this introductory lesson.

---
_id: "lesson-precalculus-basic-calculus-definite-integrals-and-signed-area"
title: "Definite Integrals and Signed Area"
summary: "Evaluate a definite integral and interpret its value as signed area."
subject: "subject-mathematics"
topic: "topic-precalculus-basic-calculus"
isActive: true
part: 3
partCount: 3
ordering: 0
keyPoints:
  - "Evaluate a definite integral using its endpoint values."
  - "Distinguish signed area from total geometric area."
---
## Core Concept

### Definite integrals

A definite integral represents **net signed area**: area above the $x$-axis contributes positively and area below contributes negatively. If $f(x)\ge0$ throughout $[a,b]$, the definite integral equals the ordinary geometric area under the curve on that interval.

For a continuous function $f$ on $[a,b]$, if $F$ is any antiderivative of $f$, the Fundamental Theorem of Calculus gives:

$$\int_a^b f(x)\,dx=F(b)-F(a)$$

The arbitrary constant cancels, so no $+C$ appears in the final value of a definite integral.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "integral-area", "formula": "Net signed area from x = a to x = b", "points": [[1, 0], [4, 0]], "semanticsLabel": "A graph showing signed regions between a curve and the x-axis from x equals a to x equals b."} -->

## Examples

### #1: A Definite Integral with a Nonnegative Integrand

Evaluate $\int_0^2 3x^2\,dx$.

**Solution:**
An antiderivative of $3x^2$ is $x^3$.

$$\int_0^2 3x^2\,dx=[x^3]_0^2=8$$

Because $3x^2\ge0$ on $[0,2]$, this value is also the ordinary area between the graph and the $x$-axis over the interval.

### #2: Definite Integral with Two Terms

Evaluate $\int_1^3(2x+1)\,dx$.

**Solution:**
1. An antiderivative is $F(x)=x^2+x$.
2. Evaluate top minus bottom.

$$F(3)-F(1)=(9+3)-(1+1)=10$$

3. Here $2x+1$ is positive on $[1,3]$, so the net signed area equals the ordinary area. A trapezoid check gives:

$$\dfrac12(3+7)(2)=10$$

## Speed Tricks & Shortcuts

For a definite integral of a nonnegative linear function over an interval, geometric area can be faster than antidifferentiation. If the graph crosses below the axis, however, geometric **total area** and the definite integral are no longer the same quantity unless you account for signs.

## Traps to Watch For

### #1: Signed Area vs. Total Geometric Area

> A definite integral counts regions below the $x$-axis negatively.

If a problem asks for total geometric area, split at zeros of the function and use absolute areas as necessary. Do not automatically equate every definite integral with a positive area.

### #2: Fundamental Theorem Conditions

> The basic evaluation theorem used here is stated for a continuous integrand on the closed interval.

More advanced integration theory handles broader cases, but the continuity condition is the appropriate one for this introductory lesson.

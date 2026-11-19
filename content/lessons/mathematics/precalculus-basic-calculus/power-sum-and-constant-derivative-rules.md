---
_id: "lesson-precalculus-basic-calculus-power-sum-and-constant-derivative-rules"
title: "Power, Sum, and Constant Derivative Rules"
summary: "Differentiate powers and add the derivatives of the terms."
subject: "subject-mathematics"
topic: "topic-precalculus-basic-calculus"
isActive: true
part: 1
partCount: 3
ordering: 8
keyPoints:
  - "Apply the power, sum, and constant rules."
  - "Rewrite roots and reciprocals as powers and check their domains."
---
## Core Concept

### Power, sum, and constant rules

For powers on intervals where the expression is defined and differentiable:

$$\dfrac{d}{dx}x^n=nx^{n-1}$$

For positive integer powers this holds for all real $x$; extensions to negative or fractional powers carry the domain restrictions of those functions. A constant differentiates to $0$, constant factors remain, and sums/differences differentiate term by term.

## Examples

### #1: Power Rule on a Polynomial

Differentiate $f(x)=3x^4-2x^2+7x-5$.

**Solution:**
Differentiate term by term.

$$f'(x)=12x^3-4x+7$$

### #2: Power Rule with a Root and a Reciprocal

Differentiate $f(x)=\sqrt{x}$ and $g(x)=\dfrac1{x^2}$ on the parts of their domains where they are differentiable.

**Solution:**
1. For $x>0$, write $\sqrt{x}=x^{1/2}$.

$$f'(x)=\dfrac12x^{-1/2}=\dfrac1{2\sqrt{x}}$$

The function $\sqrt{x}$ is defined at $x=0$, but this derivative formula is not; the derivative at $0$ is not finite.

2. For $x\ne0$, write $1/x^2=x^{-2}$.

$$g'(x)=-2x^{-3}=-\dfrac2{x^3}$$

## Traps to Watch For

### #1: Ignoring the Function's Domain

> A derivative formula is only meaningful where the original function and the derivative are defined.

For $1/x^2$, $x=0$ is excluded. For $\sqrt{x}$, the formula $1/(2\sqrt{x})$ applies for $x>0$ and does not provide a finite derivative at $0$.

### #2: Power Functions vs. Exponential Functions

> The rule $\dfrac{d}{dx}x^n=nx^{n-1}$ does not differentiate $a^x$.

A variable in the exponent requires exponential-function derivative rules, not the ordinary power rule.

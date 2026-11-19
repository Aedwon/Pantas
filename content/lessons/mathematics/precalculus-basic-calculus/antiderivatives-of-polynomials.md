---
_id: "lesson-precalculus-basic-calculus-antiderivatives-of-polynomials"
title: "Antiderivatives of Polynomials"
summary: "Reverse differentiation one term at a time."
subject: "subject-mathematics"
topic: "topic-precalculus-basic-calculus"
isActive: true
part: 1
partCount: 3
ordering: 11
keyPoints:
  - "Find the indefinite integral of a power or polynomial."
  - "Explain why an indefinite integral includes a constant."
---
## Core Concept

An **antiderivative** reverses differentiation. Since $\dfrac{d}{dx}(x^2)=2x$, one antiderivative of $2x$ is $x^2$.

On an interval where the functions involved are defined, the family of antiderivatives is written:

$$\int 2x\,dx=x^2+C$$

The constant $C$ is needed because adding any constant does not change a derivative.

### Power rule for indefinite integrals

For $n\ne-1$ on intervals where $x^n$ is defined:

$$\int x^n\,dx=\dfrac{x^{n+1}}{n+1}+C$$

Sums and differences integrate term by term, and constant multipliers can be factored out.

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

## Speed Tricks & Shortcuts

Differentiate an antiderivative to check it. This is a reliable way to catch coefficient or exponent mistakes.

## Traps to Watch For

### #1: Missing the Constant of Integration

> An indefinite antiderivative family needs $+C$.

A definite integral instead evaluates to a number, and the arbitrary constants cancel in endpoint subtraction.

---
_id: "lesson-precalculus-basic-calculus-integrating-roots-and-reciprocals"
title: "Integrating Roots and Reciprocals"
summary: "Rewrite roots and reciprocals and check the exponent before integrating."
subject: "subject-mathematics"
topic: "topic-precalculus-basic-calculus"
isActive: true
part: 2
partCount: 3
ordering: 12
keyPoints:
  - "Use the power rule on rewritten roots and reciprocals."
  - "Use the logarithm rule for the reciprocal of x."
---
## Core Concept

The case $n=-1$ is different:

$$\int\dfrac1x\,dx=\ln|x|+C$$

on any interval that does not cross $x=0$.

Check the rewritten exponent before deciding which integration rule to use.

## Examples

### #1: Rewriting a Root

Evaluate $\int\sqrt{x}\,dx$ over the usual real domain $x\ge0$.

**Solution:**
Write $\sqrt{x}=x^{1/2}$ and use the power rule.

$$\int x^{1/2}\,dx=\dfrac{x^{3/2}}{3/2}+C=\dfrac23x^{3/2}+C$$

## Speed Tricks & Shortcuts

Rewrite roots and reciprocal powers when that keeps you within the power rule's valid domain. Remember that $1/x$ is the exceptional exponent $-1$ case and integrates to $\ln|x|+C$ on intervals excluding zero.

## Traps to Watch For

### #1: Dividing by the Old Exponent

> In the integral power rule, increase the exponent first, then divide by that new exponent.

For $\int x^3\,dx$, the denominator is $4$, not $3$.

### #2: The $n=-1$ Exception

> The power-rule formula cannot be used at $n=-1$ because it would divide by zero.

On intervals avoiding zero:

$$\int\dfrac1x\,dx=\ln|x|+C$$

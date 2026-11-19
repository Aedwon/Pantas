---
_id: "lesson-precalculus-basic-calculus-direct-substitution-for-limits"
title: "Direct Substitution for Limits"
summary: "Read limit notation and check when substitution works."
subject: "subject-mathematics"
topic: "topic-precalculus-basic-calculus"
isActive: true
part: 1
partCount: 4
ordering: 0
keyPoints:
  - "Interpret a limit from nearby values."
  - "Evaluate a limit by direct substitution."
---
## Core Concept

A **limit** asks what value $f(x)$ approaches as $x$ approaches a specified input. We write:

$$\lim_{x\to a}f(x)=L$$

A limit is determined by nearby values, so it can exist even when $f(a)$ is undefined or different from the limiting value.

### Direct substitution

For functions known to be continuous at $a$, such as polynomials, and rational functions whose denominator is nonzero there, direct substitution gives the limit:

$$\lim_{x\to a}f(x)=f(a)$$

Direct substitution is therefore a useful **first check**, but a finite value of $f(a)$ alone does not prove continuity for an arbitrary piecewise or otherwise discontinuous function. The local behavior must support the substitution rule being used.

## Examples

### #1: Direct Substitution for a Polynomial

Evaluate $\lim_{x\to2}(3x+1)$.

**Solution:**
Polynomials are continuous everywhere, so direct substitution is valid.

$$3(2)+1=7$$

Therefore:

$$\lim_{x\to2}(3x+1)=7$$

## Speed Tricks & Shortcuts

For polynomial and rational expressions, substitution is a good first diagnostic. A nonzero denominator usually ends the rational-function problem immediately. A $0/0$ result means the expression needs further work, not that the limit automatically fails.

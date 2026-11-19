---
_id: "lesson-precalculus-basic-calculus-one-sided-limits-and-continuity"
title: "One-Sided Limits and Continuity"
summary: "Check the limits on both sides and compare them with the function value."
subject: "subject-mathematics"
topic: "topic-precalculus-basic-calculus"
isActive: true
part: 4
partCount: 4
ordering: 7
keyPoints:
  - "Compare the left and right limits at a point."
  - "Check the conditions for continuity."
---
## Core Concept

A **one-sided limit** approaches from one direction: $x\to a^-$ from the left or $x\to a^+$ from the right. A finite two-sided limit exists exactly when both one-sided limits exist and are equal.

### Continuity

A function is continuous at $x=a$ when all three conditions hold:

1. $f(a)$ is defined.
2. $\lim_{x\to a}f(x)$ exists.
3. $\lim_{x\to a}f(x)=f(a)$.

Common discontinuities include removable holes, jumps, and infinite discontinuities associated with vertical asymptotes.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "limits-gallery", "discontinuities": ["hole", "jump", "vertical-asymptote"], "semanticsLabel": "Three mini graphs showing a removable hole, a jump between pieces, and a vertical asymptote."} -->

## Examples

### #1: Making a Piecewise Function Continuous

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

## Traps to Watch For

### #1: Confusing the Limit with the Function Value

> A limit depends on nearby behavior, not solely on $f(a)$.

A function can have a hole at $a$, or be assigned a different value there, while nearby values approach a well-defined limit.

### #2: Ignoring One-Sided Behavior

> A two-sided limit exists only when the left-hand and right-hand limits agree.

At a jump, the two sides approach different finite values. Near a vertical asymptote, the sides may also diverge in different directions.

### #3: Nonzero over Zero Needs One-Sided Analysis

> A nonzero numerator over a denominator approaching zero is not the indeterminate form $0/0$.

The magnitude may grow without bound, but the sign can differ on the two sides. For example, near a simple vertical asymptote one side may tend to $+\infty$ and the other to $-\infty$, so the ordinary two-sided finite limit does not exist.

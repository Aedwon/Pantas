---
_id: "lesson-precalculus-basic-calculus-factoring-to-evaluate-limits"
title: "Factoring to Evaluate Limits"
summary: "Factor out the source of a zero-over-zero form."
subject: "subject-mathematics"
topic: "topic-precalculus-basic-calculus"
isActive: true
part: 2
partCount: 4
ordering: 5
keyPoints:
  - "Recognize the zero-over-zero form."
  - "Factor and cancel to evaluate a limit."
---
## Core Concept

If substitution into an algebraic expression gives $0/0$, that is an **indeterminate form**, not a final answer. It signals that more analysis is needed; in elementary rational examples, factoring and cancelling a common factor often resolves the limit.

## Examples

### #1: The $0/0$ Factor-and-Cancel Case

Evaluate $\lim_{x\to3}\dfrac{x^2-9}{x-3}$.

**Solution:**
Direct substitution gives $0/0$, so simplify.

1. Factor the numerator.

$$\dfrac{(x-3)(x+3)}{x-3}$$

2. For $x\ne3$, cancel the common factor.

$$x+3$$

3. The simplified function agrees with the original at every nearby point except the hole itself, so:

$$\lim_{x\to3}(x+3)=6$$

The limit is $6$ even though the original quotient is undefined at $x=3$.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "limit-hole", "formula": "y = x + 3", "hole": [3, 6], "points": [[3, 6]], "semanticsLabel": "A graph of y = x + 3 with an open circle hole at (3, 6)."} -->

### #2: Factoring a Trinomial

Evaluate $\lim_{x\to2}\dfrac{x^2+x-6}{x-2}$.

**Solution:**
1. Factor:

$$x^2+x-6=(x-2)(x+3)$$

2. For $x\ne2$, simplify the quotient to $x+3$.
3. Take the limit:

$$\lim_{x\to2}(x+3)=5$$

## Speed Tricks & Shortcuts

For simple removable-hole limits, factor only after identifying the factor associated with the approached value, but cancel it only algebraically for nearby $x\ne a$. The cancellation does not redefine the original function at the hole.

## Traps to Watch For

### #1: Treating $0/0$ as a Value

> $0/0$ is an indeterminate form, not a numerical answer.

It tells you that direct substitution has not settled the limit. The next method depends on the expression; factoring is only one common elementary technique.

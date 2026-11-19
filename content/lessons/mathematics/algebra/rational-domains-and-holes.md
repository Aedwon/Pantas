---
_id: "lesson-algebra-rational-domains-and-holes"
title: "Rational Functions (Domains and Holes)"
summary: "Keep original domain restrictions and identify removable holes."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 2
partCount: 8
ordering: 58
keyPoints:
  - "Keep original domain restrictions and identify removable holes."
---
## Core Concept

### Rational Functions

A **rational function** is one polynomial divided by another:

$$f(x)=\dfrac{P(x)}{Q(x)},\qquad Q(x)\ne0$$

The domain leaves out every input that makes the original denominator $0$. The **degree** of a nonzero polynomial is its highest exponent. Its **leading coefficient** is the number multiplying its highest-power term.

An **asymptote** is a line a graph gets closer to in a certain direction. First cancel common factors to study the simpler graph shape. One useful factoring rule is:

$$a^2-b^2=(a-b)(a+b)$$

Part 5, Polynomials (Factoring Cubes), shows how to factor a sum or difference of cubes, such as $x^3+64=(x+4)(x^2-4x+16)$.

If a denominator factor cancels completely, its excluded input can leave a **removable discontinuity**, or hole. Use the simpler formula to find the missing point's height. That input stays outside the original domain.

## Examples

### #1: Removable Hole

Describe the graph feature of $f(x)=\dfrac{x^2-1}{x-1}$ at $x=1$.

**Solution:**

1. Factor the numerator.

$$x^2-1=(x-1)(x+1)$$

2. Cancel to see the graph shape. Keep the original excluded input.

$$f(x)=x+1,\qquad x\ne1$$

3. Use the simpler line to find the missing height.

$$y=1+1=2$$

4. The graph has a hole at $(1,2)$. The denominator factor canceled completely, so there is no vertical asymptote there.

<!-- ILLUSTRATION: coordinate graph of y=(x^2-1)/(x-1), showing line y=x+1 with an open circle at (1,2) -->

## Speed Tricks & Shortcuts

For rational functions, cancel common factors before deciding between a hole and a vertical asymptote. Keep every original domain restriction.

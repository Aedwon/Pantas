---
_id: "lesson-algebra-quadratic-equations-from-roots"
title: "Quadratic Equations From Roots"
summary: "Build a monic quadratic from its roots."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 1
partCount: 1
ordering: 39
keyPoints:
  - "Build a monic quadratic from its roots."
  - "Recognize a root of 1 and recover the other root."
---
## Core Concept

### Sum and Product of Roots

Suppose the roots are $r_1$ and $r_2$. Then $ax^2+bx+c=a(x-r_1)(x-r_2)$. Multiplying out and comparing coefficients gives these formulas, called Vieta's formulas:

$$r_1+r_2=-\dfrac{b}{a}$$

$$r_1r_2=\dfrac{c}{a}$$

To build an equation from its roots, use $x^2-(r_1+r_2)x+r_1r_2=0$.

## Speed Tricks & Shortcuts

- When $a+b+c=0$, $x=1$ is a root. The product of the roots is $\dfrac{c}{a}$, so the other root is $\dfrac{c}{a}$.
- For real roots, a positive product $\dfrac{c}{a}$ means the roots have the same sign. A negative product means they have opposite signs. Look at $\dfrac{c}{a}$, not at $c$ alone, because $a$ may be negative.

## Examples

### #1: Sum and Product of Roots

If $r_1$ and $r_2$ are the roots of $3x^2-12x+7=0$, find $\dfrac1{r_1}+\dfrac1{r_2}$.

**Solution:**

1. Find the sum and the product of the roots.

$$r_1+r_2=-\dfrac{b}{a}=-\dfrac{-12}{3}=4$$

$$r_1r_2=\dfrac{c}{a}=\dfrac73$$

2. Combine the two fractions over a common denominator.

$$\dfrac1{r_1}+\dfrac1{r_2}=\dfrac{r_1+r_2}{r_1r_2}$$

3. Substitute. The product is not $0$, so the division is allowed.

$$\dfrac{r_1+r_2}{r_1r_2}=\dfrac{4}{\frac{7}{3}}=4\cdot\dfrac37=\dfrac{12}{7}$$

### #2: Equation From Its Roots

Write a quadratic equation with integer coefficients whose roots are $2$ and $-5$.

**Solution:**

1. Find the sum and the product.

$$r_1+r_2=2+(-5)=-3$$

$$r_1r_2=2(-5)=-10$$

2. Use $x^2-(r_1+r_2)x+r_1r_2=0$.

$$x^2-(-3)x+(-10)=x^2+3x-10=0$$

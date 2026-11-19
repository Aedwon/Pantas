---
_id: "lesson-algebra-polynomial-multiple-factors"
title: "Polynomials (Multiple Factors)"
summary: "Use each linear factor to form equations for unknown coefficients."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 9
partCount: 9
ordering: 28
keyPoints:
  - "Use each linear factor to form equations for unknown coefficients."
---
## Core Concept

Write $P(c)$ to mean the value found by replacing $x$ with $c$ in $P(x)$. When dividing by $x-c$, the **Remainder Theorem** says the remainder is $P(c)$.

The **Factor Theorem** says $x-c$ is a factor of $P(x)$ exactly when $P(c)=0$. A remainder of $0$ means the division has no leftover part.

A **quadratic** has degree $2$. A **monic quadratic** has coefficient $1$ on its $x^2$ term. For $x^2+bx+c$, find numbers $r$ and $s$ whose product is $c$ and whose sum is $b$:

$$x^2+bx+c=(x+r)(x+s)$$

For $ax^2+bx+c$ with $a\ne0$, find two numbers whose product is $ac$ and whose sum is $b$. Split the middle term using those numbers, then group terms to find shared factors.

The integer-pair methods work when the needed integers exist. Some quadratics cannot be factored into linear factors with integer coefficients. "Factor completely" means keep factoring until no factor can be split further using the allowed numbers.

## Examples

### #1: Finding Coefficients with Multiple Factors

If $P(x)=2x^3+ax^2+bx-6$ is divisible by $x^2-x-2$, find $a+b$.

**Solution:**

1. Factor the divisor.

$$x^2-x-2=(x-2)(x+1)$$

2. Each linear factor divides $P(x)$ with no remainder. Use $P(2)=0$.

$$16+4a+2b-6=0$$

3. Combine constants and divide by $2$.

$$2a+b=-5$$

4. Use $P(-1)=0$.

$$-2+a-b-6=0$$

$$a-b=8$$

5. Add the two equations to remove $b$.

$$3a=3$$

$$a=1$$

6. Put $a=1$ into $2a+b=-5$.

$$2+b=-5$$

$$b=-7$$

7. Find the requested sum.

$$a+b=1-7=-6$$

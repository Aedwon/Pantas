---
_id: "lesson-algebra-remainder-and-factor-theorems"
title: "Polynomials (Remainder and Factor Theorems)"
summary: "Evaluate the polynomial to find a remainder."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 8
partCount: 9
ordering: 27
keyPoints:
  - "Evaluate the polynomial to find a remainder."
  - "Use a zero remainder to test a factor or find a coefficient."
---
## Core Concept

Write $P(c)$ to mean the value found by replacing $x$ with $c$ in $P(x)$. When dividing by $x-c$, the **Remainder Theorem** says the remainder is $P(c)$.

The **Factor Theorem** says $x-c$ is a factor of $P(x)$ exactly when $P(c)=0$. A remainder of $0$ means the division has no leftover part.

## Examples

### #1: The Remainder Theorem

What is the remainder when $P(x)=x^4-3x^3+2x-5$ is divided by $x-2$?

**Solution:**

1. The divisor is $x-2$, so the remainder is $P(2)$.
2. Replace $x$ with $2$ and compute.

$$P(2)=2^4-3(2)^3+2(2)-5=16-24+4-5=-9$$

3. The remainder is $-9$.

### #2: The Factor Theorem with an Unknown

If $x-3$ is a factor of $x^3-kx^2+4x-12$, find $k$.

**Solution:**

1. Since $x-3$ is a factor, set $P(3)=0$.

$$P(3)=3^3-k(3)^2+4(3)-12=27-9k+12-12=0$$

2. Combine the constants.

$$27-9k=0$$

3. Subtract $27$, then divide by $-9$.

$$-9k=-27$$

$$k=3$$

## Speed Tricks & Shortcuts

When the divisor is $x-c$ and you only need the remainder, use $P(c)$ instead of polynomial division.

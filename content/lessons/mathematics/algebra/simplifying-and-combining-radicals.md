---
_id: "lesson-algebra-simplifying-and-combining-radicals"
title: "Simplifying and Combining Radicals"
summary: "Simplify square roots and combine matching radical terms."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 1
partCount: 3
ordering: 10
keyPoints:
  - "Simplify radicals with domain and absolute-value checks."
  - "Combine radicals without adding their radicands."
---
## Core Concept

A **radical expression** contains a root symbol. In $\sqrt[n]{x}$, $x$ is the **radicand** and $n$ is the **index**. If no index is written, the index is $2$.

For real-valued even roots, the radicand must be nonnegative. Odd roots can have negative radicands.

When simplifying square roots, perfect-square factors can be moved outside the radical. Remember an important identity for real $x$:

$$\sqrt{x^2}=|x|,$$

not automatically $x$. If a problem explicitly states that a variable is nonnegative, the absolute value may simplify further.

After simplifying, radicals with the same index and radicand are **like radicals**. Add or subtract their coefficients, the numbers in front, and keep the radical unchanged.

## Mnemonics & Memory Aids

For square roots of products of nonnegative factors:

> Perfect-square factors can come out; unmatched factors stay inside.

## Examples

### #1: Simplifying Radicals

Assume $x\ge0$ and $y\ge0$. Simplify $\sqrt{72x^3y^4}$.

**Solution:**

1. Factor the radicand into perfect-square parts.

$$72x^3y^4=36x^2y^4(2x)$$

2. Take the square root of the perfect-square factor.

$$\sqrt{36x^2y^4}=6xy^2$$

because the assumptions give $x\ge0$ and $y^2\ge0$.

3. Therefore:

$$\sqrt{72x^3y^4}=6xy^2\sqrt{2x}$$

### #2: Adding and Subtracting Radicals

Find $3\sqrt{20}-\sqrt{45}+2\sqrt5$.

**Solution:**

$$\sqrt{20}=2\sqrt5$$

$$\sqrt{45}=3\sqrt5$$

So:

$$3(2\sqrt5)-3\sqrt5+2\sqrt5=5\sqrt5$$

## Traps to Watch For

### #1: Adding Radicands

In general,

$$\sqrt a+\sqrt b\ne\sqrt{a+b}.$$

For example, $\sqrt9+\sqrt{16}=3+4=7$, not $5$.

### #2: Principal Square Root vs. Equation Solutions

The symbol $\sqrt{25}$ means the principal square root, $5$. But solving $x^2=25$ gives both $x=5$ and $x=-5$.

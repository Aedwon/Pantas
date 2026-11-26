---
_id: "lesson-algebra-radicals-and-rationalization"
title: "Radicals and Rationalization"
summary: "Simplify radicals and rationalize denominators while respecting domain restrictions."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 10
isActive: true
status: retired
replacedBy:
  - lesson-algebra-simplifying-and-combining-radicals
  - lesson-algebra-rationalizing-square-root-denominators
  - lesson-algebra-cube-root-denominators-and-nested-radicals
---
## Core Concept

A **radical expression** contains a root symbol. In $\sqrt[n]{x}$, $x$ is the **radicand** and $n$ is the **index**. If no index is written, the index is $2$.

For real-valued even roots, the radicand must be nonnegative. Odd roots can have negative radicands.

When simplifying square roots, perfect-square factors can be moved outside the radical. Remember an important identity for real $x$:

$$\sqrt{x^2}=|x|,$$

not automatically $x$. If a problem explicitly states that a variable is nonnegative, the absolute value may simplify further.

**Rationalizing a denominator** means rewriting an equivalent fraction so its denominator is rational. This is a conventional simplification form, not a statement that the original fraction is undefined.

## Mnemonics & Memory Aids

For square roots of products of nonnegative factors:

> Perfect-square factors can come out; unmatched factors stay inside.

For a binomial denominator such as $a-\sqrt b$, use the conjugate $a+\sqrt b$ because the middle terms cancel when the two are multiplied.

## Examples

### #1: Simplifying Radicals

To bound a square root, compare its radicand with nearby perfect squares. For an integer $n\ge0$, if $n^2<a<(n+1)^2$, then $n<\sqrt a<n+1$.

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

### #3: Rationalizing a Simple Denominator

For positive rational $x$, rationalize $\dfrac{10}{\sqrt{5x}}$.

**Solution:**

Multiply numerator and denominator by $\sqrt{5x}$.

$$\dfrac{10}{\sqrt{5x}}\cdot\dfrac{\sqrt{5x}}{\sqrt{5x}}=\dfrac{10\sqrt{5x}}{5x}=\dfrac{2\sqrt{5x}}{x}$$

### #4: Rationalizing with a Binomial

Simplify $\dfrac4{3-\sqrt5}$ by rationalizing the denominator.

**Solution:**

Multiply by the conjugate.

$$\dfrac4{3-\sqrt5}\cdot\dfrac{3+\sqrt5}{3+\sqrt5}$$

The denominator is:

$$(3-\sqrt5)(3+\sqrt5)=9-5=4$$

So:

$$\dfrac{4(3+\sqrt5)}4=3+\sqrt5$$

### #5: Rationalizing a Cube-Root Denominator

For nonzero rational $x$, rationalize $\dfrac2{\sqrt[3]{4x}}$.

**Solution:**

1. Since $4x=2^2x$, multiply by a cube root that completes each exponent to a multiple of $3$:

$$\sqrt[3]{2x^2}.$$

2. Then:

$$\dfrac2{\sqrt[3]{4x}}\cdot\dfrac{\sqrt[3]{2x^2}}{\sqrt[3]{2x^2}}=\dfrac{2\sqrt[3]{2x^2}}{\sqrt[3]{8x^3}}$$

3. Because $\sqrt[3]{8x^3}=2x$ for real $x$:

$$\dfrac{2\sqrt[3]{2x^2}}{2x}=\dfrac{\sqrt[3]{2x^2}}{x}$$

## Speed Tricks & Shortcuts

For $y>0$:

$$\dfrac{x}{\sqrt y}=\dfrac{x\sqrt y}{y}.$$

For example:

$$\dfrac{10}{\sqrt2}=5\sqrt2.$$

For a nested radical such as

$$L=\sqrt{20+\sqrt{20+\cdots}},$$

you may set $L=\sqrt{20+L}$ **only after the problem establishes or assumes that the nested expression converges to a real limit**. Then:

$$L^2-L-20=0.$$

The numbers $-5$ and $4$ multiply to $-20$ and add to $-1$. So the equation factors as $(L-5)(L+4)=0$. A product equals $0$ only when at least one factor equals $0$, so set each factor equal to $0$ to get $L=5$ or $L=-4$. Since the principal square root is nonnegative, $L=5$.

Do not rely on a factor-pair mnemonic without checking the equation and the allowed sign of the limit.

## Traps to Watch For

### #1: Adding Radicands

In general,

$$\sqrt a+\sqrt b\ne\sqrt{a+b}.$$

For example, $\sqrt9+\sqrt{16}=3+4=7$, not $5$.

### #2: Conjugates

For real expressions where the products are defined:

$$(a+b)(a-b)=a^2-b^2.$$

With radicals, this often removes the radical term from a binomial denominator.

### #3: Principal Square Root vs. Equation Solutions

The symbol $\sqrt{25}$ means the principal square root, $5$. But solving $x^2=25$ gives both $x=5$ and $x=-5$.

### #4: Cube-Root Rationalization

To rationalize $\dfrac1{\sqrt[3]x}$ for nonzero rational $x$, multiply both the numerator and the denominator by $\sqrt[3]{x^2}$ so the denominator becomes $x$.

---
_id: "lesson-arithmetic-number-sense-imaginary-unit-and-powers"
title: "Imaginary Unit and Powers"
summary: "Identify the real and imaginary parts of a complex number."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 2
partCount: 3
ordering: 202
keyPoints:
  - "Identify the real and imaginary parts of a complex number."
  - "Use the repeating cycle of powers of i."
  - "Rewrite negative square roots using i before multiplying."
---
## Core Concept

No real number squares to $-1$. The **imaginary unit** $i$ is defined by:

$$i^2=-1$$

It is also written as $i=\sqrt{-1}$ when square roots are extended to complex numbers. For a positive real number $k$, write $\sqrt{-k}=i\sqrt{k}$.

A **complex number** has the form $a+bi$, where $a$ and $b$ are real numbers. The number $a$ is the **real part**, and $b$ is the **imaginary part**.

If $b=0$, the number is real. If $a=0$ and $b\ne0$, it is purely imaginary.

### Powers of $i$

The powers of $i$ repeat every $4$ powers:

$$i^1=i$$

$$i^2=-1$$

$$i^3=-i$$

$$i^4=1$$

Then the same pattern starts again. For a large positive exponent, divide the exponent by $4$ and use the remainder to find its place in the cycle. A remainder of $0$ matches $i^4=1$.

## Mnemonics & Memory Aids

> Powers of $i$: $i,-1,-i,1$, then repeat.

## Examples

### #1: Simplifying Large Powers of $i$

"Evaluate" means find the final number answer.

Evaluate $i^{143}+i^{2024}$.

**Solution:**

1. Divide $143$ by $4$. The remainder is $3$.

$$143=4(35)+3$$

$$i^{143}=i^3=-i$$

2. Divide $2024$ by $4$. The remainder is $0$.

$$2024=4(506)$$

$$i^{2024}=1$$

3. Add the two results.

$$i^{143}+i^{2024}=-i+1=1-i$$

## Speed Tricks & Shortcuts

- **Large powers of $i$.** Divide the exponent by $4$. Use only the remainder to find the answer in the repeating cycle.

## Traps to Watch For

### #1: Multiplying Square Roots of Negative Real Numbers

> Rewrite negative square roots using $i$ before multiplying them.

For nonnegative real numbers $a$ and $b$, the rule $\sqrt{a}\sqrt{b}=\sqrt{ab}$ works. If both numbers under the square roots are negative, using that rule can give the wrong sign.

For example:

$$\sqrt{-4}\sqrt{-9}=(2i)(3i)=6i^2=-6$$

Multiplying the numbers under the roots first would give $\sqrt{36}=6$. That is the wrong answer here.

---
_id: "lesson-algebra-cube-root-denominators-and-nested-radicals"
title: "Cube-Root Denominators and Nested Radicals"
summary: "Work with cube-root denominators and convergent nested radicals."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 3
partCount: 3
ordering: 17
keyPoints:
  - "Complete cube-root factors to rationalize a denominator."
  - "Find a stated real limit of a nested radical and check its sign."
---
## Core Concept

This part brings together two uses of roots: changing a denominator and finding a limit. In each example, keep the stated conditions in view as you follow the steps.

For a nested radical such as

$$L=\sqrt{20+\sqrt{20+\cdots}},$$

you may set $L=\sqrt{20+L}$ **only after the problem establishes or assumes that the nested expression converges to a real limit**. Then:

$$L^2-L-20=0.$$

The numbers $-5$ and $4$ multiply to $-20$ and add to $-1$. So the equation factors as $(L-5)(L+4)=0$. A product equals $0$ only when at least one factor equals $0$, so set each factor equal to $0$ to get $L=5$ or $L=-4$. Since the principal square root is nonnegative, $L=5$.

Do not rely on a factor-pair mnemonic without checking the equation and the allowed sign of the limit.

## Examples

### #1: Rationalizing a Cube-Root Denominator

For nonzero rational $x$, rationalize $\dfrac2{\sqrt[3]{4x}}$.

**Solution:**

1. Since $4x=2^2x$, multiply by a cube root that completes each exponent to a multiple of $3$:

$$\sqrt[3]{2x^2}.$$

2. Then:

$$\dfrac2{\sqrt[3]{4x}}\cdot\dfrac{\sqrt[3]{2x^2}}{\sqrt[3]{2x^2}}=\dfrac{2\sqrt[3]{2x^2}}{\sqrt[3]{8x^3}}$$

3. Because $\sqrt[3]{8x^3}=2x$ for real $x$:

$$\dfrac{2\sqrt[3]{2x^2}}{2x}=\dfrac{\sqrt[3]{2x^2}}{x}$$

## Traps to Watch For

### #1: Cube-Root Rationalization

To rationalize $\dfrac1{\sqrt[3]x}$ for nonzero rational $x$, multiply both the numerator and the denominator by $\sqrt[3]{x^2}$ so the denominator becomes $x$.

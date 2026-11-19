---
_id: "lesson-algebra-inverting-restricted-quadratics"
title: "Inverting Restricted Quadratics"
summary: "Exchange the original domain and range for the inverse."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 1
partCount: 1
ordering: 56
keyPoints:
  - "Exchange the original domain and range for the inverse."
  - "Choose the inverse branch that fits the original restricted domain."
---
## Core Concept

To find an inverse:

1. Write $y=f(x)$.
2. Swap $x$ and $y$.
3. Solve for $y$. That $y$ is $f^{-1}(x)$.

The domain of $f^{-1}$ is the range of $f$, and the range of $f^{-1}$ is the domain of $f$.

If $f$ is not one-to-one, you can cut its domain down to a piece where it is. For $f(x)=x^2$, the piece $x\ge0$ works. Step $3$ can then give two branches, with a plus sign and a minus sign.

Keep the branch whose outputs match the cut-down domain, because they are the inputs of $f$.

## Examples

### #1: Restricting a Domain to Get an Inverse

Let $f(x)=(x-2)^2+1$ with domain $x\ge2$. Find $f^{-1}(x)$ and its domain.

<!-- ILLUSTRATION: xy graph of y = (x-2)^2 + 1 for x >= 2 only, a solid curve starting at the closed dot (2, 1) and rising to the right through (3, 2); the left half of the parabola is dashed and labeled "removed" -->

**Solution:**

1. On the whole real line $f$ is not one-to-one, since $f(1)=f(3)$. On $x\ge2$, the graph only goes up, so it is one-to-one.
2. Write $y=(x-2)^2+1$ and swap $x$ and $y$.

$$x=(y-2)^2+1$$

3. Solve for $y$.

$$(y-2)^2=x-1$$

$$y-2=\pm\sqrt{x-1}$$

4. The outputs of $f^{-1}$ are the inputs of $f$, which are $x\ge2$. So $y\ge2$, which needs the plus sign.

$$f^{-1}(x)=2+\sqrt{x-1}$$

5. The domain of $f^{-1}$ is the range of $f$. Since $f(2)=1$ is the smallest output, the range is $[1,\infty)$. This matches $x-1\ge0$.
6. Check: $f(3)=2$ and $f^{-1}(2)=2+\sqrt{1}=3$.

## Traps to Watch For

### #1: Taking a Plus-or-Minus Branch Without Checking

> An inverse of a restricted function keeps only the branch that matches the restricted domain.

For $f(x)=x^2$ with $x\ge0$, the inverse is $\sqrt{x}$. Writing $\pm\sqrt{x}$ gives two outputs for each positive input, so it is not a function. If the domain were $x\le0$, the right branch would be $-\sqrt{x}$.

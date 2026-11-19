---
_id: "lesson-precalculus-basic-calculus-chain-rule-and-tangent-slopes"
title: "Chain Rule and Tangent Slopes"
summary: "Find a derivative of a composition or use a derivative to find slope."
subject: "subject-mathematics"
topic: "topic-precalculus-basic-calculus"
isActive: true
part: 3
partCount: 3
ordering: 0
keyPoints:
  - "Apply the chain rule to a composition."
  - "Use the derivative to find a tangent slope or instantaneous rate."
---
## Core Concept

Where a function is differentiable, its **derivative** measures instantaneous rate of change and gives the slope of the tangent line to its graph. Common notation includes $f'(x)$ and $\dfrac{dy}{dx}$.

### Chain Rule

For a composition, differentiate the outer function and multiply by the derivative of the inner function. For a power of a differentiable inner function $g$:

$$\dfrac{d}{dx}[g(x)]^n=n[g(x)]^{n-1}g'(x)$$

where the expression is defined and the relevant functions are differentiable.

## Examples

### #1: Chain Rule

Differentiate $f(x)=(3x^2+1)^5$.

**Solution:**
1. Differentiate the outer fifth power while keeping the inner expression.

$$5(3x^2+1)^4$$

2. Multiply by the derivative of the inner expression, $6x$.

$$f'(x)=30x(3x^2+1)^4$$

### #2: Slope of a Tangent Line

Find the slope of the tangent to $f(x)=x^2-4x$ at $x=3$, and find where the tangent is horizontal.

**Solution:**
1. Differentiate.

$$f'(x)=2x-4$$

2. Evaluate at $x=3$.

$$f'(3)=2$$

3. A horizontal tangent has derivative $0$.

$$2x-4=0\Rightarrow x=2$$

4. $f(2)=-4$, so the horizontal tangent occurs at $(2,-4)$.

## Speed Tricks & Shortcuts

For tangent-line problems, $f(a)$ gives the point on the curve and $f'(a)$ gives the slope, provided the derivative exists at $a$.

For compositions, look for an inner function whose derivative must be multiplied by the derivative of the outer function. A factor of $1$ may be invisible after simplification, so the important idea is applying the chain rule correctly, not merely seeing an extra written factor.

## Traps to Watch For

### #1: Skipping the Chain Rule

> A composition requires the derivative of the inner function as well as the outer derivative.

For $(3x^2+1)^5$, omitting the inner derivative loses the factor $6x$.

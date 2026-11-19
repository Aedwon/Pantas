---
_id: "lesson-precalculus-basic-calculus-derivatives-of-products-and-quotients"
title: "Derivatives of Products and Quotients"
summary: "Find derivatives when functions are multiplied or divided."
subject: "subject-mathematics"
topic: "topic-precalculus-basic-calculus"
isActive: true
part: 2
partCount: 3
ordering: 0
keyPoints:
  - "Differentiate a product of functions."
  - "Differentiate a quotient of functions."
---
## Core Concept

### Product Rule

If $u$ and $v$ are differentiable:

$$(uv)'=u'v+uv'$$

### Quotient Rule

If $u$ and $v$ are differentiable and $v(x)\ne0$:

$$\left(\dfrac uv\right)'=\dfrac{u'v-uv'}{v^2}$$

Check whether the expression is a product or quotient before picking a rule.

## Examples

### #1: Product Rule

Differentiate $f(x)=x^2(3x+1)$.

**Solution:**
Let $u=x^2$ and $v=3x+1$. Then $u'=2x$ and $v'=3$.

$$f'(x)=2x(3x+1)+x^2(3)=9x^2+2x$$

Expanding first gives $f(x)=3x^3+x^2$, whose derivative is the same result.

### #2: Quotient Rule

Differentiate $f(x)=\dfrac{2x+1}{x-3}$.

**Solution:**
The original function is defined for $x\ne3$. Let $u=2x+1$ and $v=x-3$.

$$f'(x)=\dfrac{2(x-3)-(2x+1)(1)}{(x-3)^2}$$

Simplify the numerator:

$$2x-6-2x-1=-7$$

Therefore:

$$f'(x)=-\dfrac7{(x-3)^2},\qquad x\ne3$$

## Speed Tricks & Shortcuts

Before choosing the quotient rule, simplify when algebra allows it. For example, $5/x^3=5x^{-3}$ can be differentiated directly with the power rule on $x\ne0$.

## Traps to Watch For

### #1: Multiplying Derivatives in a Product

> In general, $(uv)'\ne u'v'$.

The product rule has two terms: $u'v+uv'$.

### #2: Reversing the Quotient-Rule Numerator

> Keep the order $u'v-uv'$.

Reversing the two terms changes the sign.

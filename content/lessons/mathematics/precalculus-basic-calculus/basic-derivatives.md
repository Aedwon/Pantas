---
_id: "lesson-precalculus-basic-calculus-basic-derivatives"
title: "Basic Derivatives (Power Rule, Product/Quotient Rule, Chain Rule)"
summary: "How to differentiate functions using the power, product, quotient, and chain rules."
subject: "subject-mathematics"
topic: "topic-precalculus-basic-calculus"
estimatedMinutes: 14
isActive: true
---
## Core Concept

Where a function is differentiable, its **derivative** measures instantaneous rate of change and gives the slope of the tangent line to its graph. Common notation includes $f'(x)$ and $\dfrac{dy}{dx}$.

### Power, sum, and constant rules

For powers on intervals where the expression is defined and differentiable:

$$\dfrac{d}{dx}x^n=nx^{n-1}$$

For positive integer powers this holds for all real $x$; extensions to negative or fractional powers carry the domain restrictions of those functions. A constant differentiates to $0$, constant factors remain, and sums/differences differentiate term by term.

### Product Rule

If $u$ and $v$ are differentiable:

$$(uv)'=u'v+uv'$$

### Quotient Rule

If $u$ and $v$ are differentiable and $v(x)\ne0$:

$$\left(\dfrac uv\right)'=\dfrac{u'v-uv'}{v^2}$$

### Chain Rule

For a composition, differentiate the outer function and multiply by the derivative of the inner function. For a power of a differentiable inner function $g$:

$$\dfrac{d}{dx}[g(x)]^n=n[g(x)]^{n-1}g'(x)$$

where the expression is defined and the relevant functions are differentiable.

## Examples

### #1: Power Rule on a Polynomial

Differentiate $f(x)=3x^4-2x^2+7x-5$.

**Solution:**
Differentiate term by term.

$$f'(x)=12x^3-4x+7$$

### #2: Power Rule with a Root and a Reciprocal

Differentiate $f(x)=\sqrt{x}$ and $g(x)=\dfrac1{x^2}$ on the parts of their domains where they are differentiable.

**Solution:**
1. For $x>0$, write $\sqrt{x}=x^{1/2}$.

$$f'(x)=\dfrac12x^{-1/2}=\dfrac1{2\sqrt{x}}$$

The function $\sqrt{x}$ is defined at $x=0$, but this derivative formula is not; the derivative at $0$ is not finite.

2. For $x\ne0$, write $1/x^2=x^{-2}$.

$$g'(x)=-2x^{-3}=-\dfrac2{x^3}$$

### #3: Product Rule

Differentiate $f(x)=x^2(3x+1)$.

**Solution:**
Let $u=x^2$ and $v=3x+1$. Then $u'=2x$ and $v'=3$.

$$f'(x)=2x(3x+1)+x^2(3)=9x^2+2x$$

Expanding first gives $f(x)=3x^3+x^2$, whose derivative is the same result.

### #4: Quotient Rule

Differentiate $f(x)=\dfrac{2x+1}{x-3}$.

**Solution:**
The original function is defined for $x\ne3$. Let $u=2x+1$ and $v=x-3$.

$$f'(x)=\dfrac{2(x-3)-(2x+1)(1)}{(x-3)^2}$$

Simplify the numerator:

$$2x-6-2x-1=-7$$

Therefore:

$$f'(x)=-\dfrac7{(x-3)^2},\qquad x\ne3$$

### #5: Chain Rule

Differentiate $f(x)=(3x^2+1)^5$.

**Solution:**
1. Differentiate the outer fifth power while keeping the inner expression.

$$5(3x^2+1)^4$$

2. Multiply by the derivative of the inner expression, $6x$.

$$f'(x)=30x(3x^2+1)^4$$

### #6: Slope of a Tangent Line

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

Before choosing the quotient rule, simplify when algebra allows it. For example, $5/x^3=5x^{-3}$ can be differentiated directly with the power rule on $x\ne0$.

For tangent-line problems, $f(a)$ gives the point on the curve and $f'(a)$ gives the slope, provided the derivative exists at $a$.

For compositions, look for an inner function whose derivative must be multiplied by the derivative of the outer function. A factor of $1$ may be invisible after simplification, so the important idea is applying the chain rule correctly, not merely seeing an extra written factor.

## Traps to Watch For

### #1: Multiplying Derivatives in a Product

> In general, $(uv)'\ne u'v'$.

The product rule has two terms: $u'v+uv'$.

### #2: Reversing the Quotient-Rule Numerator

> Keep the order $u'v-uv'$.

Reversing the two terms changes the sign.

### #3: Skipping the Chain Rule

> A composition requires the derivative of the inner function as well as the outer derivative.

For $(3x^2+1)^5$, omitting the inner derivative loses the factor $6x$.

### #4: Ignoring the Function's Domain

> A derivative formula is only meaningful where the original function and the derivative are defined.

For $1/x^2$, $x=0$ is excluded. For $\sqrt{x}$, the formula $1/(2\sqrt{x})$ applies for $x>0$ and does not provide a finite derivative at $0$.

### #5: Power Functions vs. Exponential Functions

> The rule $\dfrac{d}{dx}x^n=nx^{n-1}$ does not differentiate $a^x$.

A variable in the exponent requires exponential-function derivative rules, not the ordinary power rule.

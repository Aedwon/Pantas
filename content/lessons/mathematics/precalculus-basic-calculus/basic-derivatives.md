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

The **derivative** of a function measures how fast it changes: the slope of the graph at each point. We write it as $f'(x)$ or $\dfrac{dy}{dx}$. At any $x$, the derivative is the slope of the tangent line touching the curve there.

Four rules unlock the exam questions.

**Power Rule** — bring the exponent down, then reduce it by one:

$$\dfrac{d}{dx} x^n = nx^{n-1}$$

Companions: the derivative of a constant is $0$ (flat line, no slope), and constants multiplying a function just tag along: the derivative of $5x^3$ is $15x^2$. Sums differentiate term by term.

**Product Rule** — for $u \cdot v$, do not just multiply the derivatives:

$$(uv)' = u'v + uv'$$

In words: derivative of the first times the second, plus the first times derivative of the second.

**Quotient Rule** — for $\dfrac{u}{v}$:

$$\left(\dfrac{u}{v}\right)' = \dfrac{u'v - uv'}{v^2}$$

The order in the numerator matters because of the minus sign.

**Chain Rule** — for a function inside another function, like $(3x^2 + 1)^5$: differentiate the outside (treating the inside as a block), then multiply by the derivative of the inside.

$$\dfrac{d}{dx} \left[ g(x) \right]^n = n \left[ g(x) \right]^{n-1} \cdot g'(x)$$

## Examples

### #1: Power Rule on a Polynomial

Differentiate $f(x) = 3x^4 - 2x^2 + 7x - 5$.

**Solution:**
Term by term: multiply by the exponent, drop the exponent by one.

1. First term: $3x^4$ becomes $3 \times 4 \, x^3 = 12x^3$.
2. Second term: $-2x^2$ becomes $-4x$.
3. Third term: $7x$ is $7x^1$, so its derivative is just $7$.
4. Last term: the constant $-5$ vanishes.

$$f'(x) = 12x^3 - 4x + 7$$

### #2: Power Rule with Roots and Fractions

Differentiate $f(x) = \sqrt{x}$ and $g(x) = \dfrac{1}{x^2}$.

**Solution:**
Rewrite as powers first — that is the whole trick.

1. $\sqrt{x} = x^{1/2}$. Apply the power rule.

$$f'(x) = \dfrac{1}{2} x^{-1/2} = \dfrac{1}{2\sqrt{x}}$$

2. $\dfrac{1}{x^2} = x^{-2}$. Apply the power rule: bring down $-2$.

$$g'(x) = -2x^{-3} = -\dfrac{2}{x^3}$$

3. Watch the exponent go down: from $-2$ to $-3$, more negative.

### #3: Product Rule

Differentiate $f(x) = x^2 (3x + 1)$.

**Solution:**
Let $u = x^2$ and $v = 3x + 1$.

1. Find the pieces: $u' = 2x$ and $v' = 3$.
2. Assemble $u'v + uv'$.

$$f'(x) = 2x(3x + 1) + x^2(3)$$

3. Expand and combine.

$$f'(x) = 6x^2 + 2x + 3x^2 = 9x^2 + 2x$$

4. Check by expanding first: $f(x) = 3x^3 + x^2$, whose derivative is $9x^2 + 2x$. Same answer, confidence earned.

### #4: Quotient Rule

Differentiate $f(x) = \dfrac{2x + 1}{x - 3}$.

**Solution:**
Let $u = 2x + 1$ (top) and $v = x - 3$ (bottom), so $u' = 2$ and $v' = 1$.

1. Assemble $\dfrac{u'v - uv'}{v^2}$.

$$f'(x) = \dfrac{2(x - 3) - (2x + 1)(1)}{(x - 3)^2}$$

2. Expand the numerator.

$$2x - 6 - 2x - 1 = -7$$

3. Write the result.

$$f'(x) = \dfrac{-7}{(x - 3)^2}$$

### #5: Chain Rule

Differentiate $f(x) = (3x^2 + 1)^5$.

**Solution:**
Outside first, then multiply by the inside's derivative.

1. Outside: a fifth power. Bring down the $5$, reduce to the fourth power, keep the inside intact.

$$5(3x^2 + 1)^4$$

2. Inside: the derivative of $3x^2 + 1$ is $6x$.
3. Multiply.

$$f'(x) = 5(3x^2 + 1)^4 \cdot 6x = 30x(3x^2 + 1)^4$$

### #6: Slope of a Tangent Line

Find the slope of the tangent line to $f(x) = x^2 - 4x$ at $x = 3$, and the point where the tangent is horizontal.

**Solution:**
The derivative is the slope machine.

1. Differentiate.

$$f'(x) = 2x - 4$$

2. Evaluate at $x = 3$.

$$f'(3) = 2(3) - 4 = 2$$

3. The slope at $x = 3$ is $2$.
4. A horizontal tangent means slope $0$.

$$2x - 4 = 0 \quad \Rightarrow \quad x = 2$$

5. At $x = 2$, $f(2) = 4 - 8 = -4$. The tangent is horizontal at the point $(2, -4)$ — the bottom of the parabola.

## Speed Tricks & Shortcuts

Before differentiating, rewrite: roots become fraction powers, and $\dfrac{1}{x^n}$ becomes $x^{-n}$. Thirty seconds of rewriting turns quotient-rule monsters into one-line power rules. Never use the quotient rule on $\dfrac{5}{x^3}$ — write $5x^{-3}$ and finish instantly.

Memorize the quotient rule with the chant "low d-high minus high d-low, over low-low": bottom times derivative of top, minus top times derivative of bottom, over bottom squared.

For tangent-line problems, two numbers do everything: $f(a)$ gives the point, $f'(a)$ gives the slope. Most questions only want one of them — read which.

## Traps to Watch For

### #1: Multiplying Derivatives in a Product

> $(uv)'$ is not $u' \cdot v'$.

For $x^2(3x + 1)$, multiplying derivatives gives $2x \times 3 = 6x$, far from the true $9x^2 + 2x$. The product rule has two terms. The lazy one-term answer is always in the choices.

### #2: Flipping the Quotient Rule Order

> The numerator is $u'v - uv'$, in that exact order.

Swapping it flips the sign of the answer: Example $4$ would give $+7$ instead of $-7$ on top. Since both versions appear in the choices, lock in the chant before exam day.

### #3: Skipping the Inside Derivative

> The chain rule's final multiplication is the step everyone forgets.

Writing the derivative of $(3x^2 + 1)^5$ as just $5(3x^2 + 1)^4$ misses the factor $6x$. If the base is anything more than a plain $x$, an inside derivative must appear. Scan your answer: no inside factor, no credit.

### #4: Differentiating the Exponent's Variable

> The power rule works for $x^n$ with a constant exponent, not for $2^x$.

Applying the power rule to $2^x$ (getting $x \cdot 2^{x-1}$) is wrong: exponential functions have their own rule involving logarithms, which is beyond this lesson. On the CET, know that $x^5$ and $5^x$ are different species — a favorite concept question.

---
_id: "lesson-precalculus-basic-calculus-basic-integrals"
title: "Basic Integrals"
summary: "How to find antiderivatives with the power rule and how to evaluate definite integrals."
subject: "subject-mathematics"
topic: "topic-precalculus-basic-calculus"
estimatedMinutes: 12
isActive: true
---
## Core Concept

Integration is differentiation in reverse. The derivative of $x^2$ is $2x$; so an **antiderivative** of $2x$ is $x^2$. We write:

$$\int 2x \, dx = x^2 + C$$

Why the $+ C$? Because $x^2 + 7$ and $x^2 - 100$ also have derivative $2x$. Constants vanish when differentiating, so when we reverse, we must admit "plus some constant". Every indefinite integral ends with $+ C$.

**Power rule for integrals** — the power rule backwards: raise the exponent by one, then divide by the new exponent.

$$\int x^n \, dx = \dfrac{x^{n+1}}{n + 1} + C \qquad (n \neq -1)$$

The one exception is $n = -1$: you cannot divide by zero, and $\displaystyle\int \dfrac{1}{x} \, dx = \ln|x| + C$, a special case to recognize.

Sums integrate term by term, and constant multipliers tag along, just like with derivatives.

A **definite integral** has endpoints and produces a number, the signed area under the curve between $x = a$ and $x = b$:

$$\int_a^b f(x) \, dx = F(b) - F(a)$$

where $F$ is any antiderivative. This recipe — antidifferentiate, plug in the top limit, subtract the bottom limit — is the **Fundamental Theorem of Calculus**. The $C$ cancels in the subtraction, so definite integrals need no $+ C$.

<!-- ILLUSTRATION: curve above the x-axis with the region between x = a and x = b shaded, labeled as the definite integral -->

## Examples

### #1: Power Rule

Evaluate $\displaystyle\int x^3 \, dx$.

**Solution:**
Raise the exponent, divide by the new one.

1. The exponent $3$ becomes $4$; divide by $4$.

$$\int x^3 \, dx = \dfrac{x^4}{4} + C$$

2. Check by differentiating: $\dfrac{d}{dx}\left(\dfrac{x^4}{4}\right) = x^3$. Correct.

### #2: A Polynomial, Term by Term

Evaluate $\displaystyle\int (6x^2 - 4x + 5) \, dx$.

**Solution:**
Integrate each term separately.

1. First term: $6 \times \dfrac{x^3}{3} = 2x^3$.
2. Second term: $-4 \times \dfrac{x^2}{2} = -2x^2$.
3. Third term: the constant $5$ integrates to $5x$ (since the derivative of $5x$ is $5$).

$$\int (6x^2 - 4x + 5) \, dx = 2x^3 - 2x^2 + 5x + C$$

### #3: Rewriting a Root

Evaluate $\displaystyle\int \sqrt{x} \, dx$.

**Solution:**
Rewrite the root as a power first.

1. $\sqrt{x} = x^{1/2}$. Raise the exponent to $\dfrac{3}{2}$, divide by $\dfrac{3}{2}$.

$$\dfrac{x^{3/2}}{\dfrac{3}{2}} = \dfrac{2}{3} x^{3/2}$$

2. So:

$$\int \sqrt{x} \, dx = \dfrac{2}{3} x^{3/2} + C$$

3. Dividing by a fraction means multiplying by its flip — that is where the $\dfrac{2}{3}$ comes from.

### #4: A Definite Integral

Evaluate $\displaystyle\int_0^2 3x^2 \, dx$.

**Solution:**
Antidifferentiate, then top minus bottom.

1. The antiderivative of $3x^2$ is $x^3$.
2. Evaluate at the limits.

$$2^3 - 0^3 = 8 - 0 = 8$$

3. The definite integral equals $8$: the exact area under $y = 3x^2$ from $0$ to $2$.

### #5: Definite Integral with Two Terms

Evaluate $\displaystyle\int_1^3 (2x + 1) \, dx$.

**Solution:**
Same recipe, more careful bookkeeping.

1. Antidifferentiate.

$$\int (2x + 1) \, dx = x^2 + x$$

2. Plug in the top limit $3$.

$$3^2 + 3 = 12$$

3. Plug in the bottom limit $1$.

$$1^2 + 1 = 2$$

4. Subtract.

$$12 - 2 = 10$$

5. Geometry check: the region is a trapezoid with parallel sides $3$ and $7$ and width $2$, so its area is $\dfrac{1}{2}(3 + 7)(2) = 10$. The calculus and the geometry agree.

## Speed Tricks & Shortcuts

Always check an integral by differentiating your answer. It takes five seconds and catches every coefficient slip. If the derivative of your answer is not the original integrand, fix it before shading.

Rewrite before integrating, exactly like with derivatives: roots become fraction powers, $\dfrac{1}{x^n}$ becomes $x^{-n}$ (for $n \neq 1$). Then one power rule finishes the job.

For definite integrals of linear functions, you can skip calculus entirely: the region is a trapezoid or triangle, so use the geometry formula, like the check in Example $5$. On multiple choice, geometry is often faster than antidifferentiating.

## Traps to Watch For

### #1: The Missing $+ C$

> Every indefinite integral needs $+ C$; definite integrals do not.

Choices for indefinite integrals include the same expression with and without $+ C$, and the bare one is wrong. But do not bolt a $C$ onto a definite integral: those answers are pure numbers. Match the answer type to the integral type.

### #2: Dividing by the Old Exponent

> Divide by the new exponent, the one after adding $1$.

For $\int x^3 \, dx$, dividing by $3$ gives $\dfrac{x^4}{3}$, wrong. The correct divisor is $4$. The differentiate-to-check habit exposes this instantly: $\dfrac{d}{dx} \dfrac{x^4}{3} = \dfrac{4x^3}{3} \neq x^3$.

### #3: The $n = -1$ Landmine

> The power rule breaks for $\displaystyle\int \dfrac{1}{x} \, dx$.

Raising $-1$ by one gives exponent $0$ and a division by zero. The answer is $\ln|x| + C$, a fact test-makers probe directly. Any choice showing $\dfrac{x^0}{0}$ machinery is automatically wrong.

### #4: Sloppy Lower-Limit Subtraction

> $F(b) - F(a)$: compute both, subtract in the right order.

Students plug in the top limit and forget the bottom (fine only when $F(0) = 0$), or subtract in reverse and flip the sign. In Example $5$, forgetting the lower limit gives $12$ instead of $10$ — and $12$ is in the choices, smiling.

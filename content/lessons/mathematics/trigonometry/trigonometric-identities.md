---
_id: "lesson-trigonometry-trigonometric-identities"
title: "Trigonometric Identities (Reciprocal, Quotient, Pythagorean)"
summary: "The basic trigonometric identities and how to use them to simplify expressions and find missing values."
subject: "subject-mathematics"
topic: "topic-trigonometry"
estimatedMinutes: 12
isActive: true
---
## Core Concept

An **identity** is an equation that is true for every angle where both sides are defined. Identities let you rewrite trigonometric expressions into simpler equivalent forms on their shared domain.

There are three families to master.

**Reciprocal identities**: each function has a reciprocal partner wherever the denominator is nonzero:

$$\csc \theta = \dfrac{1}{\sin \theta} \qquad \sec \theta = \dfrac{1}{\cos \theta} \qquad \cot \theta = \dfrac{1}{\tan \theta}$$

**Quotient identities**:

$$\tan \theta = \dfrac{\sin \theta}{\cos \theta} \qquad \cot \theta = \dfrac{\cos \theta}{\sin \theta}$$

These are valid where the denominator on the right is nonzero.

**Pythagorean identities**:

$$\sin^2 \theta + \cos^2 \theta = 1$$

Dividing that identity by $\cos^2 \theta$ or by $\sin^2 \theta$—where those quantities are nonzero—gives:

$$1 + \tan^2 \theta = \sec^2 \theta \qquad 1 + \cot^2 \theta = \csc^2 \theta$$

Why does $\sin^2 \theta + \cos^2 \theta = 1$? On the unit circle, the point is $(\cos \theta, \sin \theta)$ and its distance from the center is $1$. The identity is the Pythagorean theorem applied to those coordinates.

A common simplification strategy is to convert functions to sine and cosine, apply identities, then cancel only factors that are nonzero on the original expression's domain. When you see $1 - \sin^2 \theta$, replace it with $\cos^2 \theta$; similarly, $1 - \cos^2 \theta = \sin^2 \theta$.

## Examples

### #1: Finding Cosine from Sine

If $\sin \theta = \dfrac{3}{5}$ and $\theta$ is acute, find $\cos \theta$ using an identity.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ", "Opposite = 3", "Adjacent = 4", "Hypotenuse = 5", "sin²θ + cos²θ = 1"], "semanticsLabel": "Right triangle with opposite 3, adjacent 4, and hypotenuse 5 confirming the Pythagorean identity."} -->


**Solution:**
Use $\sin^2 \theta + \cos^2 \theta = 1$.

1. Substitute the known sine.

$$\left(\dfrac{3}{5}\right)^2 + \cos^2 \theta = 1$$

2. Square the fraction.

$$\dfrac{9}{25} + \cos^2 \theta = 1$$

3. Subtract $\dfrac{9}{25}$ from both sides.

$$\cos^2 \theta = \dfrac{16}{25}$$

4. Thus $\cos \theta = \pm\dfrac{4}{5}$. Since $\theta$ is acute, cosine is positive.

$$\cos \theta = \dfrac{4}{5}$$

### #2: Simplifying with a Quotient Identity

Simplify: $\tan \theta \cdot \cos \theta$.

**Solution:**
The original expression contains $\tan \theta$, so it is defined only where $\cos \theta \neq 0$.

1. Substitute the quotient identity.

$$\dfrac{\sin \theta}{\cos \theta} \cdot \cos \theta$$

2. On the original domain, $\cos \theta \neq 0$, so the factor cancels.

$$\sin \theta$$

3. Therefore $\tan \theta\cos \theta = \sin \theta$ **where the original expression is defined**. The simplified formula $\sin \theta$ by itself has a larger domain, so the original domain restriction should not be forgotten.

### #3: Simplifying with a Pythagorean Identity

Simplify: $\dfrac{1 - \cos^2 \theta}{\cos^2 \theta}$.

**Solution:**
The denominator requires $\cos \theta \neq 0$.

1. Replace $1 - \cos^2 \theta$ with $\sin^2 \theta$.

$$\dfrac{\sin^2 \theta}{\cos^2 \theta}$$

2. Sine over cosine is tangent, so:

$$\tan^2 \theta$$

3. This equality holds where $\cos \theta \neq 0$, exactly the domain of the original expression.

### #4: Factoring Before Substituting

Simplify: $\sec \theta - \sec \theta \sin^2 \theta$.

**Solution:**
Because the original expression contains secant, it requires $\cos \theta \neq 0$.

1. Factor out $\sec \theta$.

$$\sec \theta (1 - \sin^2 \theta)$$

2. Replace $1 - \sin^2 \theta$ with $\cos^2 \theta$.

$$\sec \theta \cdot \cos^2 \theta$$

3. Rewrite secant as $\dfrac{1}{\cos \theta}$.

$$\dfrac{\cos^2 \theta}{\cos \theta}$$

4. Since $\cos \theta \neq 0$ on the original domain, cancel one factor.

$$\cos \theta$$

5. Thus the expression equals $\cos \theta$ wherever the original secant expression is defined.

### #5: Using the Tangent-Secant Identity

If $\tan \theta = 2$ and $\theta$ is acute, find $\sec \theta$ and $\cos \theta$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ", "Opposite = 2", "Adjacent = 1", "Hypotenuse = √5", "1 + tan²θ = sec²θ"], "semanticsLabel": "Right triangle with opposite 2, adjacent 1, and hypotenuse square root of 5 verifying tangent and secant identity."} -->


**Solution:**
The identity $1 + \tan^2 \theta = \sec^2 \theta$ connects them directly.

1. Substitute the tangent.

$$1 + 2^2 = \sec^2 \theta$$

2. Compute.

$$\sec^2 \theta = 5$$

3. Therefore $\sec \theta = \pm\sqrt{5}$. Since $\theta$ is acute, secant is positive.

$$\sec \theta = \sqrt{5}$$

4. Cosine is the reciprocal of secant. Rationalize the denominator if desired.

$$\cos \theta = \dfrac{1}{\sqrt{5}} = \dfrac{\sqrt{5}}{5}$$

## Speed Tricks & Shortcuts

When an expression looks complicated, try this sequence: convert functions to sines and cosines, apply a known identity, then simplify while keeping the original domain restrictions.

Useful rearrangements of the Pythagorean identities include:

$$1 - \sin^2 \theta = \cos^2 \theta$$

$$1 - \cos^2 \theta = \sin^2 \theta$$

$$\sec^2 \theta - 1 = \tan^2 \theta$$

$$\csc^2 \theta - 1 = \cot^2 \theta$$

For a multiple-choice identity check, substituting a convenient angle can sometimes eliminate wrong choices, but one matching test value does **not** prove an identity. Use algebra or the known identities for the final justification.

## Traps to Watch For

### #1: Different Angles, No Identity

> $\sin^2 A + \cos^2 B = 1$ is not generally true when $A$ and $B$ are different angles.

The Pythagorean identity uses the same angle in both terms. Check the angle labels before applying it.

### #2: Dropping the Sign at the Square Root

> From $u^2=k$, taking the square root gives both signs when $k>0$; the angle's quadrant or range determines which sign is valid.

For example, from $\cos^2 \theta = \dfrac{16}{25}$, cosine could initially be $+\dfrac{4}{5}$ or $-\dfrac{4}{5}$. If $\theta$ is in Quadrant II, cosine must be negative.

### #3: Misreading $\sin^2 \theta$

> $\sin^2 \theta$ means $(\sin \theta)^2$.

It does not mean $\sin(\theta^2)$ and is not the same as $\sin(2\theta)$. If $\sin \theta = \dfrac{3}{5}$, then $\sin^2 \theta = \dfrac{9}{25}$.

### #4: Cancelling Away a Domain Restriction

> Algebraic cancellation can make a formula look defined at more angles than the original expression.

For example, $\tan\theta\cos\theta$ simplifies to $\sin\theta$, but the starting expression is still undefined when $\cos\theta=0$. Preserve the domain of the original problem when reporting an equivalent simplification.

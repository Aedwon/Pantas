---
_id: "lesson-trigonometry-simplifying-trigonometric-expressions"
title: "Simplifying Trigonometric Expressions"
summary: "Use factoring and the Pythagorean identity to simplify."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 4
partCount: 6
ordering: 22
keyPoints:
  - "Use factoring and the Pythagorean identity to simplify."
---
## Core Concept

A common plan for simplifying is to rewrite every function in sine and cosine, apply an identity, then cancel. Cancel only factors that are nonzero on the original expression's domain. When you see $1 - \sin^2 \theta$, replace it with $\cos^2 \theta$. In the same way, $1 - \cos^2 \theta = \sin^2 \theta$.

## Examples

### #1: Simplifying with a Pythagorean Identity

Simplify: $\dfrac{1 - \cos^2 \theta}{\cos^2 \theta}$.

**Solution:**
The denominator requires $\cos \theta \neq 0$.

1. Replace $1 - \cos^2 \theta$ with $\sin^2 \theta$.

$$\dfrac{\sin^2 \theta}{\cos^2 \theta}$$

2. Sine over cosine is tangent, so:

$$\tan^2 \theta$$

3. This equality holds where $\cos \theta \neq 0$, which is exactly the domain of the original expression.

### #2: Factoring Before Substituting

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

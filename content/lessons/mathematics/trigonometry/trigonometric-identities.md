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

An **identity** is an equation that is true for every allowed angle. Identities let you rewrite ugly trigonometric expressions into simple ones, often a single function or just the number $1$.

There are three families to master.

**Reciprocal identities**: each function has a flip partner:

$$\csc \theta = \dfrac{1}{\sin \theta} \qquad \sec \theta = \dfrac{1}{\cos \theta} \qquad \cot \theta = \dfrac{1}{\tan \theta}$$

**Quotient identities**: tangent and cotangent are built from sine and cosine:

$$\tan \theta = \dfrac{\sin \theta}{\cos \theta} \qquad \cot \theta = \dfrac{\cos \theta}{\sin \theta}$$

**Pythagorean identities**: the star of the show:

$$\sin^2 \theta + \cos^2 \theta = 1$$

Divide that equation by $\cos^2 \theta$ or by $\sin^2 \theta$ and you get its two brothers:

$$1 + \tan^2 \theta = \sec^2 \theta \qquad 1 + \cot^2 \theta = \csc^2 \theta$$

Why does $\sin^2 \theta + \cos^2 \theta = 1$? On the unit circle, the point is $(\cos \theta, \sin \theta)$ and its distance from the center is $1$. The identity is just the Pythagorean theorem wearing a trigonometry costume.

The main strategy for simplifying: convert everything to sines and cosines, then cancel. When you see $1 - \sin^2 \theta$, replace it with $\cos^2 \theta$ instantly (and $1 - \cos^2 \theta$ with $\sin^2 \theta$).

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

4. Take the square root. Since $\theta$ is acute (Quadrant I), cosine is positive.

$$\cos \theta = \dfrac{4}{5}$$

### #2: Simplifying with a Quotient Identity

Simplify: $\tan \theta \cdot \cos \theta$.

**Solution:**
Rewrite tangent as sine over cosine.

1. Substitute the quotient identity.

$$\dfrac{\sin \theta}{\cos \theta} \cdot \cos \theta$$

2. Cancel the $\cos \theta$ on top and bottom.

$$\sin \theta$$

3. The whole expression is just $\sin \theta$. One substitution, one cancellation.

### #3: Simplifying with a Pythagorean Identity

Simplify: $\dfrac{1 - \cos^2 \theta}{\cos^2 \theta}$.

**Solution:**
Spot the Pythagorean piece on top.

1. Replace $1 - \cos^2 \theta$ with $\sin^2 \theta$.

$$\dfrac{\sin^2 \theta}{\cos^2 \theta}$$

2. Sine over cosine is tangent, so sine squared over cosine squared is tangent squared.

$$\tan^2 \theta$$

### #4: Factoring Before Substituting

Simplify: $\sec \theta - \sec \theta \sin^2 \theta$.

**Solution:**
Factor first, then use the identities.

1. Factor out $\sec \theta$.

$$\sec \theta (1 - \sin^2 \theta)$$

2. Replace $1 - \sin^2 \theta$ with $\cos^2 \theta$.

$$\sec \theta \cdot \cos^2 \theta$$

3. Rewrite secant as $\dfrac{1}{\cos \theta}$.

$$\dfrac{\cos^2 \theta}{\cos \theta}$$

4. Cancel one $\cos \theta$.

$$\cos \theta$$

### #5: Using the Tangent-Secant Identity

If $\tan \theta = 2$ and $\theta$ is acute, find $\sec \theta$ and $\cos \theta$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ", "Opposite = 2", "Adjacent = 1", "Hypotenuse = √5", "1 + tan²θ = sec²θ"], "semanticsLabel": "Right triangle with opposite 2, adjacent 1, and hypotenuse square root of 5 verifying tangent and secant identity."} -->


**Solution:**
The identity $1 + \tan^2 \theta = \sec^2 \theta$ connects them directly.

1. Substitute the tangent.

$$1 + 2^2 = \sec^2 \theta$$

2. Compute.

$$\sec^2 \theta = 5$$

3. Take the positive square root (acute angle).

$$\sec \theta = \sqrt{5}$$

4. Cosine is the reciprocal of secant. Rationalize the denominator.

$$\cos \theta = \dfrac{1}{\sqrt{5}} = \dfrac{\sqrt{5}}{5}$$

## Speed Tricks & Shortcuts

When an expression looks scary, run this two-step machine: convert every function to sines and cosines, then cancel and combine. Nearly every CET simplification collapses within three lines.

Memorize the disguises of the main identity. Seeing any of these, substitute without thinking: $1 - \sin^2 \theta = \cos^2 \theta$, $\quad 1 - \cos^2 \theta = \sin^2 \theta$, $\quad \sec^2 \theta - 1 = \tan^2 \theta$, $\quad \csc^2 \theta - 1 = \cot^2 \theta$.

On multiple-choice identity questions, you can also cheat honestly: plug a test angle like $30^\circ$ into the original expression and into each choice. Only the true identity matches for your test angle. This is slower but bulletproof when you blank out.

## Traps to Watch For

### #1: Different Angles, No Identity

> $\sin^2 A + \cos^2 B = 1$ is false when $A$ and $B$ are different angles.

The Pythagorean identity needs the same angle in both places. Test-makers write mixed-angle versions hoping you pattern-match too fast. Check the angle letters before you substitute.

### #2: Dropping the Sign at the Square Root

> Taking a square root gives $\pm$; the quadrant picks the sign.

From $\cos^2 \theta = \dfrac{16}{25}$, cosine is $+\dfrac{4}{5}$ or $-\dfrac{4}{5}$. If the problem says $\theta$ is in Quadrant II, cosine must be negative. Problems that name a quadrant are testing exactly this choice.

### #3: Misreading $\sin^2 \theta$

> $\sin^2 \theta$ means $(\sin \theta)^2$: compute the sine first, then square.

It does not mean $\sin(\theta^2)$, and it is not the same as $\sin(2\theta)$ either. If $\sin \theta = \dfrac{3}{5}$, then $\sin^2 \theta = \dfrac{9}{25}$. Confusing these notations breaks every identity computation downstream.

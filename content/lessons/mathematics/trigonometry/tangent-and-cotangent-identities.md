---
_id: "lesson-trigonometry-tangent-and-cotangent-identities"
title: "Tangent and Cotangent Identities"
summary: "Use the tangent-secant and cotangent-cosecant identities."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 3
partCount: 6
ordering: 21
keyPoints:
  - "Use the tangent-secant and cotangent-cosecant identities."
---
## Core Concept

This one holds for every angle. Dividing it by $\cos^2 \theta$, where $\cos \theta \neq 0$, gives $1 + \tan^2 \theta = \sec^2 \theta$. Dividing it by $\sin^2 \theta$, where $\sin \theta \neq 0$, gives $1 + \cot^2 \theta = \csc^2 \theta$.

$$1 + \tan^2 \theta = \sec^2 \theta \qquad 1 + \cot^2 \theta = \csc^2 \theta$$

## Examples

### #1: Using the Cotangent-Cosecant Identity

Simplify: $(1 + \cot^2 \theta)\sin^2 \theta$.

**Solution:**
Cotangent needs $\sin \theta \neq 0$. So the expression is defined only where $\sin \theta \neq 0$.

1. Replace $1 + \cot^2 \theta$ with $\csc^2 \theta$.

$$\csc^2 \theta \cdot \sin^2 \theta$$

2. Cosecant is the reciprocal of sine, so the two factors multiply to $1$.

$$\dfrac{1}{\sin^2 \theta} \cdot \sin^2 \theta = 1$$

3. The result is $1$ wherever $\sin \theta \neq 0$. At $\theta = 0^\circ$ the original expression is undefined, even though the number $1$ is not.

### #2: Using the Tangent-Secant Identity

If $\tan \theta = 2$ and $\theta$ is acute, find $\sec \theta$ and $\cos \theta$.

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

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ", "Opposite = 2", "Adjacent = 1", "Hypotenuse = √5", "1 + tan²θ = sec²θ"], "semanticsLabel": "Right triangle with opposite 2, adjacent 1, and hypotenuse square root of 5 verifying tangent and secant identity."} -->

## Speed Tricks & Shortcuts

Useful rearrangements of the Pythagorean identities include:

$$1 - \sin^2 \theta = \cos^2 \theta \qquad 1 - \cos^2 \theta = \sin^2 \theta$$

$$\sec^2 \theta - 1 = \tan^2 \theta \qquad \csc^2 \theta - 1 = \cot^2 \theta$$

The first two hold for every angle. The third needs $\cos \theta \neq 0$, and the fourth needs $\sin \theta \neq 0$.

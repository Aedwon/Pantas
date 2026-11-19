---
_id: "lesson-trigonometry-pythagorean-identity-and-signs"
title: "Pythagorean Identity and Signs"
summary: "Use the same angle in both terms of the Pythagorean identity."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 2
partCount: 6
ordering: 0
keyPoints:
  - "Use the same angle in both terms of the Pythagorean identity."
  - "Find a ratio and pick its sign from the quadrant."
  - "Read a squared trigonometric function."
---
## Core Concept

The notation $\sin^2 \theta$ means $(\sin \theta)^2$. The sign of each function depends on the quadrant, the quarter of the plane where the angle ends. Quadrant I is $0^\circ$ to $90^\circ$, II is $90^\circ$ to $180^\circ$, III is $180^\circ$ to $270^\circ$, and IV is $270^\circ$ to $360^\circ$. Sine is positive in I and II. Cosine is positive in I and IV. Tangent is positive in I and III. The Unit Circle lesson explains this in full.

**Pythagorean identities**:

$$\sin^2 \theta + \cos^2 \theta = 1$$

Why does $\sin^2 \theta + \cos^2 \theta = 1$? On the unit circle, the point for angle $\theta$ is $(\cos \theta, \sin \theta)$, and it is $1$ unit from the center. The identity is the Pythagorean theorem applied to those coordinates.

## Examples

### #1: Finding Cosine from Sine

If $\sin \theta = \dfrac{3}{5}$ and $\theta$ is acute, find $\cos \theta$ using an identity.

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

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ", "Opposite = 3", "Adjacent = 4", "Hypotenuse = 5", "sin²θ + cos²θ = 1"], "semanticsLabel": "Right triangle with opposite 3, adjacent 4, and hypotenuse 5 confirming the Pythagorean identity."} -->

### #2: All Six Values in Quadrant II

If $\sin \theta = \dfrac{5}{13}$ and $\theta$ is in Quadrant II, find the other five trigonometric values.

**Solution:**
Find cosine first. Then use the quotient and reciprocal identities.

1. Use the Pythagorean identity.

$$\cos^2 \theta = 1 - \left(\dfrac{5}{13}\right)^2 = \dfrac{144}{169}$$

2. Cosine is negative in Quadrant II.

$$\cos \theta = -\dfrac{12}{13}$$

3. Divide sine by cosine for the tangent.

$$\tan \theta = \dfrac{5/13}{-12/13} = -\dfrac{5}{12}$$

4. Flip each of the three values for its reciprocal partner.

$$\csc \theta = \dfrac{13}{5} \qquad \sec \theta = -\dfrac{13}{12} \qquad \cot \theta = -\dfrac{12}{5}$$

## Traps to Watch For

### #1: Different Angles, No Identity

> $\sin^2 A + \cos^2 B = 1$ is not generally true when $A$ and $B$ are different angles.

The Pythagorean identity uses the same angle in both terms. For example, $\sin^2 90^\circ + \cos^2 0^\circ = 2$. Check the angle labels before applying it.

### #2: Dropping the Sign at the Square Root

> From $u^2=k$, taking the square root gives both signs when $k>0$; the angle's quadrant or range determines which sign is valid.

For example, from $\cos^2 \theta = \dfrac{16}{25}$, cosine could be $+\dfrac{4}{5}$ or $-\dfrac{4}{5}$. If $\theta$ is in Quadrant II, cosine must be negative.

### #3: Misreading $\sin^2 \theta$

> $\sin^2 \theta$ means $(\sin \theta)^2$.

It does not mean $\sin(\theta^2)$ and is not the same as $\sin(2\theta)$. If $\sin \theta = \dfrac{3}{5}$, then $\sin^2 \theta = \dfrac{9}{25}$.

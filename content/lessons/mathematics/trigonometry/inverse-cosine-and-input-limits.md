---
_id: "lesson-trigonometry-inverse-cosine-and-input-limits"
title: "Inverse Cosine and Input Limits"
summary: "Find the principal arccosine angle."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 2
partCount: 3
ordering: 39
keyPoints:
  - "Find the principal arccosine angle."
  - "Check which inputs are allowed and which outputs lie on axes."
---
## Core Concept

For nonzero inputs, the sign helps locate the principal angle. A positive input sends all three inverse functions to a positive acute angle. A negative input gives a negative principal value for arcsine and arctangent, while arccosine returns an obtuse angle in Quadrant II. Endpoint inputs such as $0$, $1$, and $-1$ can return angles on an axis instead of inside a quadrant.

Inputs are limited too: $\arcsin x$ and $\arccos x$ accept only $x \in [-1,1]$, because sine and cosine values stay in that interval. $\arctan x$ accepts every real number.

## Examples

### #1: Negative Input to Arccosine

Evaluate $\arccos\left(-\dfrac{1}{2}\right)$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "unit-circle", "labels": ["120° in Q II", "cos = -1/2", "arccos range [0°, 180°]"], "semanticsLabel": "Unit circle marking 120 degrees in Quadrant II where cosine equals negative 1 half within arccosine principal range."} -->


**Solution:**
Arccosine answers only between $0^\circ$ and $180^\circ$. For this non-endpoint negative cosine, the principal angle lies in Quadrant II.

1. The reference angle comes from $\cos 60^\circ = \dfrac{1}{2}$.
2. Move it to Quadrant II.

$$180 - 60 = 120$$

3. So:

$$\arccos\left(-\dfrac{1}{2}\right) = 120^\circ$$

4. It is not $-60^\circ$, because that angle lies outside the principal range of arccosine.

## Speed Tricks & Shortcuts

For nonzero inputs, a useful sign reminder is: arcsine negative, arctangent negative, arccosine obtuse. Check endpoint inputs separately because they may land on an axis.

## Traps to Watch For

### #1: Impossible Inputs

> $\arcsin(2)$ and $\arccos(-1.5)$ are undefined over the real numbers.

Sine and cosine outputs lie between $-1$ and $1$, so their inverse functions accept only inputs in that interval. Arctangent accepts every real input.

### #2: Endpoint Inputs Sit on Axes

> Principal ranges include some boundary angles.

For example, $\arcsin(1)=90^\circ$, $\arcsin(-1)=-90^\circ$, $\arccos(1)=0^\circ$, and $\arccos(-1)=180^\circ$. These values lie on axes, so quadrant-only mnemonics are not enough for endpoints.

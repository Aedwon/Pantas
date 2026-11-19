---
_id: "lesson-trigonometry-inverse-sine-and-arctangent"
title: "Inverse Sine and Arctangent"
summary: "Read inverse-function notation."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 1
partCount: 3
ordering: 38
keyPoints:
  - "Read inverse-function notation."
  - "Find principal values of arcsine and arctangent."
---
## Core Concept

Ordinary trigonometric functions take an angle and give a ratio: $\sin 30^\circ = \dfrac{1}{2}$.

Inverse trigonometric functions run in the other direction on restricted domains. They take a ratio and return one principal angle: $\arcsin\left(\dfrac{1}{2}\right) = 30^\circ$. You will see two notations that mean the same thing: $\arcsin x$ and $\sin^{-1}x$.

There is a catch. Infinitely many angles can have the same sine, cosine, or tangent value. An inverse function must return only one output for each allowed input, so each inverse trigonometric function has a fixed **principal range**:

- $\arcsin x$ returns angles from $-90^\circ$ to $90^\circ$, inclusive: $[-90^\circ,90^\circ]$.
- $\arccos x$ returns angles from $0^\circ$ to $180^\circ$, inclusive: $[0^\circ,180^\circ]$.
- $\arctan x$ returns angles strictly between $-90^\circ$ and $90^\circ$: $(-90^\circ,90^\circ)$.

## Examples

### #1: Basic Evaluation

Evaluate $\arcsin\left(\dfrac{1}{2}\right)$ and $\arctan(1)$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "unit-circle", "labels": ["30° (sin = 1/2)", "45° (tan = 1)", "Quadrant I"], "semanticsLabel": "Unit circle marking angles 30 degrees and 45 degrees in Quadrant I within arcsine and arctangent principal ranges."} -->


**Solution:**
Ask the reverse question for each.

1. Which angle in $[-90^\circ,90^\circ]$ has sine $\dfrac{1}{2}$?

$$\arcsin\left(\dfrac{1}{2}\right) = 30^\circ$$

2. Which angle in $(-90^\circ,90^\circ)$ has tangent $1$?

$$\arctan(1) = 45^\circ$$

3. Both inputs are positive and nonzero, so their principal angles are in Quadrant I.

### #2: Negative Input to Arctangent

Evaluate $\arctan(-\sqrt{3})$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "unit-circle", "labels": ["-60° in Q IV", "tan = -√3", "arctan range (-90°, 90°)"], "semanticsLabel": "Unit circle marking negative 60 degrees in Quadrant IV where tangent equals negative square root of 3 within arctangent principal range."} -->


**Solution:**
Arctangent answers between $-90^\circ$ and $90^\circ$. A negative tangent has a negative principal angle.

1. The reference angle comes from $\tan 60^\circ = \sqrt{3}$.
2. Apply the negative sign to the principal value.

$$\arctan(-\sqrt{3}) = -60^\circ$$

3. Although $\tan 120^\circ$ is also $-\sqrt{3}$, $120^\circ$ lies outside arctangent's principal range.

## Traps to Watch For

### #1: Answering Outside the Principal Range

> Each inverse function has one principal output range.

For $\arcsin\left(-\dfrac{1}{2}\right)$, many angles have sine $-\dfrac{1}{2}$, but the inverse function returns the one in its principal range: $-30^\circ$.

### #2: Confusing $\sin^{-1}x$ with $\dfrac{1}{\sin x}$

> $\sin^{-1}x$ is the inverse function, not the reciprocal.

The reciprocal of sine is cosecant. The raised $-1$ on the function symbol is inverse-function notation in this context.

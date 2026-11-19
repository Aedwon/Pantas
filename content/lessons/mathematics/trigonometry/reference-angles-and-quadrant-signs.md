---
_id: "lesson-trigonometry-reference-angles-and-quadrant-signs"
title: "Reference Angles and Quadrant Signs"
summary: "Find a reference angle."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 3
partCount: 9
ordering: 12
keyPoints:
  - "Find a reference angle."
  - "Use the quadrant to choose the sign of each value."
---
## Core Concept

For angles beyond $90^\circ$, use two tools. First, the axes split the plane into four **quadrants**, numbered I to IV counterclockwise from the upper right. An angle on an axis is in no quadrant.

**Tool 1, the reference angle**: the positive acute angle between the terminal side and the $x$-axis. It is defined for an angle not on an axis. For $\theta$ between $0^\circ$ and $360^\circ$, use $180^\circ-\theta$ in Quadrant II, $\theta-180^\circ$ in Quadrant III, and $360^\circ-\theta$ in Quadrant IV. In Quadrant I, the angle is its own reference angle.

The point in any quadrant is a mirror image of a first-quadrant point. So its coordinates have the same sizes. This means $\sin\theta$, $\cos\theta$ and $\tan\theta$ have the same size as the values at the reference angle.

**Tool 2, the quadrant signs**: the quadrant gives the sign. Cosine is $x$ and sine is $y$. Quadrant I has both positive. Quadrant II has sine positive and cosine negative. Quadrant III has both negative. Quadrant IV has cosine positive and sine negative. Tangent is positive when sine and cosine have the same sign, and negative when they differ.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "unit-circle-quadrants", "labels": ["Q I: All (+)", "Q II: Sine (+)", "Q III: Tangent (+)", "Q IV: Cosine (+)"], "semanticsLabel": "Unit circle divided into four quadrants showing which trigonometric functions are positive: All, Sine, Tangent, and Cosine."} -->

## Mnemonics & Memory Aids

For the signs of sine, cosine, and tangent in the four quadrants, going counterclockwise from Quadrant I:

> All Students Take Calculus.

**A**ll positive, **S**ine positive, **T**angent positive, **C**osine positive. In each quadrant, the functions not named are negative.

## Examples

### #1: Reading a Quadrant II Value

Find the exact value of $\cos 120^\circ$.

**Solution:**
Reference angle first, then sign.

1. $120^\circ$ is in Quadrant II. Its reference angle is:

$$180 - 120 = 60$$

2. The size comes from $\cos 60^\circ = \dfrac{1}{2}$.
3. In Quadrant II, cosine is negative.

$$\cos 120^\circ = -\dfrac{1}{2}$$

<!-- FIGURE: {"kind": "geometry-diagram", "type": "unit-circle", "labels": ["120°", "Reference angle: 60°", "(-1/2, √3/2)", "Quadrant II"], "semanticsLabel": "Unit circle with terminal ray at 120 degrees in Quadrant II, 60 degree reference angle, and coordinates negative 1 half comma square root 3 over 2."} -->

### #2: A Quadrant III Value

Find the exact value of $\sin 225^\circ$.

**Solution:**
1. $225^\circ$ is in Quadrant III. Its reference angle is:

$$225 - 180 = 45$$

2. The size comes from $\sin45^\circ=\dfrac{\sqrt2}{2}$.
3. Sine is negative in Quadrant III.

$$\sin225^\circ=-\dfrac{\sqrt2}{2}$$

<!-- FIGURE: {"kind": "geometry-diagram", "type": "unit-circle", "labels": ["225°", "Reference angle: 45°", "(-√2/2, -√2/2)", "Quadrant III"], "semanticsLabel": "Unit circle with terminal ray at 225 degrees in Quadrant III, 45 degree reference angle, and coordinates negative root 2 over 2 comma negative root 2 over 2."} -->

## Traps to Watch For

### #1: Right Size, Wrong Sign

> The reference angle gives the size; the quadrant gives the sign.

For example, $\cos120^\circ$ has the same size as $\cos60^\circ$ but is negative because $120^\circ$ lies in Quadrant II.

### #2: The Reference-Angle Formula Depends on the Quadrant

> Measure the positive acute angle from the terminal side to the $x$-axis.

For an angle between $0^\circ$ and $360^\circ$ that is not on an axis, use the formula for its quadrant. For angles outside one full turn, first find a coterminal angle in that range.

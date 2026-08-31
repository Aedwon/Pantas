---
_id: "lesson-trigonometry-inverse-trigonometric-functions"
title: "Inverse Trigonometric Functions"
summary: "How inverse trigonometric functions turn ratios back into angles and which principal values they return."
subject: "subject-mathematics"
topic: "topic-trigonometry"
estimatedMinutes: 11
isActive: true
---
## Core Concept

Ordinary trigonometric functions take an angle and give a ratio: $\sin 30^\circ = \dfrac{1}{2}$.

Inverse trigonometric functions run in the other direction on restricted domains. They take a ratio and return one principal angle: $\arcsin\left(\dfrac{1}{2}\right) = 30^\circ$. You will see two notations that mean the same thing: $\arcsin x$ and $\sin^{-1}x$.

There is a catch. Infinitely many angles can have the same sine, cosine, or tangent value. An inverse function must return only one output for each allowed input, so each inverse trigonometric function has a fixed **principal range**:

- $\arcsin x$ returns angles from $-90^\circ$ to $90^\circ$, inclusive: $[-90^\circ,90^\circ]$.
- $\arccos x$ returns angles from $0^\circ$ to $180^\circ$, inclusive: $[0^\circ,180^\circ]$.
- $\arctan x$ returns angles strictly between $-90^\circ$ and $90^\circ$: $(-90^\circ,90^\circ)$.

For nonzero inputs, the sign helps locate the principal angle. A positive input sends all three inverse functions to a positive acute angle. A negative input gives a negative principal value for arcsine and arctangent, while arccosine returns an obtuse angle in Quadrant II. Endpoint inputs such as $0$, $1$, and $-1$ can return angles on an axis instead of inside a quadrant.

Inputs are limited too: $\arcsin x$ and $\arccos x$ accept only $x \in [-1,1]$, because sine and cosine values stay in that interval. $\arctan x$ accepts every real number.

Useful problems in this topic include evaluating exact inverse values, respecting principal ranges, and simplifying compositions such as $\sin\left(\arccos \dfrac{3}{5}\right)$ by building a right triangle.

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

### #2: Negative Input to Arccosine

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

### #3: Negative Input to Arctangent

Evaluate $\arctan(-\sqrt{3})$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "unit-circle", "labels": ["-60° in Q IV", "tan = -√3", "arctan range (-90°, 90°)"], "semanticsLabel": "Unit circle marking negative 60 degrees in Quadrant IV where tangent equals negative square root of 3 within arctangent principal range."} -->


**Solution:**
Arctangent answers between $-90^\circ$ and $90^\circ$. A negative tangent has a negative principal angle.

1. The reference angle comes from $\tan 60^\circ = \sqrt{3}$.
2. Apply the negative sign to the principal value.

$$\arctan(-\sqrt{3}) = -60^\circ$$

3. Although $\tan 120^\circ$ is also $-\sqrt{3}$, $120^\circ$ lies outside arctangent's principal range.

### #4: Composition with a Triangle

Evaluate $\sin\left(\arccos \dfrac{3}{5}\right)$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ = arccos(3/5)", "Adjacent = 3", "Hypotenuse = 5", "Opposite = 4", "sin θ = 4/5"], "semanticsLabel": "Right triangle for angle theta with adjacent side 3, hypotenuse 5, and opposite side 4 giving sine 4 fifths."} -->


**Solution:**
Let $\theta = \arccos \dfrac{3}{5}$. Since the input is positive, $\theta$ is an acute principal angle. Build a right triangle whose cosine is $3/5$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ", "Adjacent = 3", "Hypotenuse = 5", "Opposite = 4", "90°"], "semanticsLabel": "Right triangle with angle theta, adjacent side 3, hypotenuse 5, and opposite side 4."} -->

1. Cosine is adjacent over hypotenuse: adjacent $3$, hypotenuse $5$.
2. Find the opposite side with the Pythagorean theorem.

$$\text{opposite} = \sqrt{5^2 - 3^2} = \sqrt{16} = 4$$

3. Read the sine.

$$\sin \theta = \dfrac{4}{5}$$

4. Therefore:

$$\sin\left(\arccos \dfrac{3}{5}\right) = \dfrac{4}{5}$$

### #5: Composition

Evaluate $\tan\left(\arcsin \dfrac{5}{13}\right)$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ = arcsin(5/13)", "Opposite = 5", "Hypotenuse = 13", "Adjacent = 12", "tan θ = 5/12"], "semanticsLabel": "Right triangle for angle theta with opposite side 5, hypotenuse 13, and adjacent side 12 giving tangent 5 twelfths."} -->


**Solution:**
Let $\theta = \arcsin \dfrac{5}{13}$. The positive input gives an acute principal angle.

1. Sine is opposite over hypotenuse, so use opposite $5$ and hypotenuse $13$.
2. Find the adjacent side.

$$\text{adjacent} = \sqrt{13^2 - 5^2} = \sqrt{169 - 25} = \sqrt{144} = 12$$

3. Read the tangent.

$$\tan \theta = \dfrac{5}{12}$$

4. Therefore:

$$\tan\left(\arcsin \dfrac{5}{13}\right) = \dfrac{5}{12}$$

## Speed Tricks & Shortcuts

For compositions such as $\sin(\arccos x)$ or $\tan(\arcsin x)$, a right triangle can avoid computing the angle explicitly. Use the inside function to label two sides, find the third side with the Pythagorean theorem, and then read the outside ratio. Keep the principal range in mind when the input can make the angle non-acute.

Same-function compositions cancel on the inverse function's input domain: $\sin(\arcsin x)=x$ for $x\in[-1,1]$. The reversed order needs more care: $\arcsin(\sin\theta)=\theta$ only when $\theta$ is already in arcsine's principal range.

For nonzero inputs, a useful sign reminder is: arcsine negative, arctangent negative, arccosine obtuse. Check endpoint inputs separately because they may land on an axis.

## Traps to Watch For

### #1: Answering Outside the Principal Range

> Each inverse function has one principal output range.

For $\arcsin\left(-\dfrac{1}{2}\right)$, many angles have sine $-\dfrac{1}{2}$, but the inverse function returns the one in its principal range: $-30^\circ$.

### #2: Confusing $\sin^{-1}x$ with $\dfrac{1}{\sin x}$

> $\sin^{-1}x$ is the inverse function, not the reciprocal.

The reciprocal of sine is cosecant. The raised $-1$ on the function symbol is inverse-function notation in this context.

### #3: Impossible Inputs

> $\arcsin(2)$ and $\arccos(-1.5)$ are undefined over the real numbers.

Sine and cosine outputs lie between $-1$ and $1$, so their inverse functions accept only inputs in that interval. Arctangent accepts every real input.

### #4: Endpoint Inputs Sit on Axes

> Principal ranges include some boundary angles.

For example, $\arcsin(1)=90^\circ$, $\arcsin(-1)=-90^\circ$, $\arccos(1)=0^\circ$, and $\arccos(-1)=180^\circ$. These values lie on axes, so quadrant-only mnemonics are not enough for endpoints.

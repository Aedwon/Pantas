---
_id: "lesson-trigonometry-unit-circle"
title: "The Unit Circle (Exact Values of Standard Angles)"
summary: "How to find exact sine, cosine, and tangent values for common special angles using the unit circle."
subject: "subject-mathematics"
topic: "topic-trigonometry"
estimatedMinutes: 13
isActive: true
---
## Core Concept

The **unit circle** is a circle of radius $1$ centered at the origin. It extends trigonometric functions beyond acute angles in right triangles: angles such as $225^\circ$ and $-30^\circ$ also have sine and cosine values.

Put an angle $\theta$ in standard position and mark where its terminal side crosses the unit circle. That point has coordinates:

$$(\cos \theta, \sin \theta)$$

Cosine is the $x$-coordinate. Sine is the $y$-coordinate. Where $\cos\theta\neq0$, tangent is their ratio:

$$\tan \theta = \dfrac{\sin \theta}{\cos \theta}$$

<!-- FIGURE: {"kind": "geometry-diagram", "type": "unit-circle", "labels": ["θ", "P(cos θ, sin θ)", "x = cos θ", "y = sin θ", "r = 1"], "semanticsLabel": "Unit circle with angle theta from positive x-axis and intersection point labeled cos theta comma sin theta."} -->

The exact values for the most commonly used first-quadrant special angles are worth memorizing:

- $\sin 0^\circ = 0$, $\quad \sin 30^\circ = \dfrac{1}{2}$, $\quad \sin 45^\circ = \dfrac{\sqrt{2}}{2}$, $\quad \sin 60^\circ = \dfrac{\sqrt{3}}{2}$, $\quad \sin 90^\circ = 1$.
- Cosine runs the same list backwards: $\cos 0^\circ = 1$ down to $\cos 90^\circ = 0$.
- Tangent: $\tan 0^\circ = 0$, $\tan 30^\circ = \dfrac{\sqrt{3}}{3}$, $\tan 45^\circ = 1$, $\tan 60^\circ = \sqrt{3}$, and $\tan 90^\circ$ is undefined.

For angles beyond $90^\circ$, use two tools:

**Tool 1, the reference angle**: the positive acute angle between the terminal side and the $x$-axis. For angles between $0^\circ$ and $360^\circ$, the usual formulas are $180^\circ-\theta$ in Quadrant II, $\theta-180^\circ$ in Quadrant III, and $360^\circ-\theta$ in Quadrant IV. In Quadrant I, the angle itself is its reference angle.

**Tool 2, the quadrant signs**: the quadrant determines the signs. Since cosine is $x$ and sine is $y$: Quadrant I has sine and cosine positive; Quadrant II has sine positive and cosine negative; Quadrant III has both negative; Quadrant IV has cosine positive and sine negative. Tangent follows from sine divided by cosine.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "unit-circle-quadrants", "labels": ["Q I: All (+)", "Q II: Sine (+)", "Q III: Tangent (+)", "Q IV: Cosine (+)"], "semanticsLabel": "Unit circle divided into four quadrants showing which trigonometric functions are positive: All, Sine, Tangent, and Cosine."} -->

## Mnemonics & Memory Aids

For the signs of sine, cosine, and tangent in the four quadrants, going counterclockwise from Quadrant I:

> All Students Take Calculus.

**A**ll positive, **S**ine positive, **T**angent positive, **C**osine positive.

For the sine values of $0^\circ, 30^\circ, 45^\circ, 60^\circ, 90^\circ$, use the square-root ladder: $\dfrac{\sqrt{0}}{2}, \dfrac{\sqrt{1}}{2}, \dfrac{\sqrt{2}}{2}, \dfrac{\sqrt{3}}{2}, \dfrac{\sqrt{4}}{2}$. Cosine is the same ladder in reverse.

## Examples

### #1: Reading a Quadrant II Value

Find the exact value of $\cos 120^\circ$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "unit-circle", "labels": ["120°", "Reference angle: 60°", "(-1/2, √3/2)", "Quadrant II"], "semanticsLabel": "Unit circle with terminal ray at 120 degrees in Quadrant II, 60 degree reference angle, and coordinates negative 1 half comma square root 3 over 2."} -->


**Solution:**
Reference angle first, then sign.

1. $120^\circ$ is in Quadrant II. Its reference angle is:

$$180 - 120 = 60$$

2. The magnitude comes from $\cos 60^\circ = \dfrac{1}{2}$.
3. In Quadrant II, cosine is negative.

$$\cos 120^\circ = -\dfrac{1}{2}$$

### #2: A Quadrant III Value

Find the exact value of $\sin 225^\circ$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "unit-circle", "labels": ["225°", "Reference angle: 45°", "(-√2/2, -√2/2)", "Quadrant III"], "semanticsLabel": "Unit circle with terminal ray at 225 degrees in Quadrant III, 45 degree reference angle, and coordinates negative root 2 over 2 comma negative root 2 over 2."} -->


**Solution:**
1. $225^\circ$ is in Quadrant III. Its reference angle is:

$$225 - 180 = 45$$

2. The magnitude comes from $\sin45^\circ=\dfrac{\sqrt2}{2}$.
3. Sine is negative in Quadrant III.

$$\sin225^\circ=-\dfrac{\sqrt2}{2}$$

### #3: A Quadrant IV Tangent

Find the exact value of $\tan 300^\circ$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "unit-circle", "labels": ["300°", "Reference angle: 60°", "(1/2, -√3/2)", "Quadrant IV"], "semanticsLabel": "Unit circle with terminal ray at 300 degrees in Quadrant IV, 60 degree reference angle, and coordinates 1 half comma negative root 3 over 2."} -->


**Solution:**
1. $300^\circ$ is in Quadrant IV. Its reference angle is:

$$360 - 300 = 60$$

2. The magnitude comes from $\tan60^\circ=\sqrt3$.
3. Tangent is negative in Quadrant IV because sine is negative and cosine is positive.

$$\tan300^\circ=-\sqrt3$$

### #4: Negative and Axis Angles

Find $\sin(-30^\circ)$, $\cos180^\circ$, and $\sin90^\circ$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "unit-circle", "labels": ["-30° (330°)", "180°: (-1, 0)", "90°: (0, 1)"], "semanticsLabel": "Unit circle marking positions negative 30 degrees, 180 degrees at negative 1 comma 0, and 90 degrees at 0 comma 1."} -->


**Solution:**
Negative angles are measured clockwise from the positive $x$-axis. Axis angles can be read directly from their coordinates.

1. $-30^\circ$ is coterminal with $330^\circ$, where sine is negative.

$$\sin(-30^\circ)=-\dfrac12$$

2. $180^\circ$ points at $(-1,0)$. Cosine is the $x$-coordinate.

$$\cos180^\circ=-1$$

3. $90^\circ$ points at $(0,1)$. Sine is the $y$-coordinate.

$$\sin90^\circ=1$$

### #5: Combining Values

Evaluate $\sin150^\circ+\cos300^\circ$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "unit-circle", "labels": ["150° (sin = 1/2)", "300° (cos = 1/2)", "Sum = 1"], "semanticsLabel": "Unit circle marking 150 degrees in Quadrant II with sine 1 half and 300 degrees in Quadrant IV with cosine 1 half."} -->


**Solution:**
1. $\sin150^\circ$: reference angle $30^\circ$, and sine is positive in Quadrant II.

$$\sin150^\circ=\dfrac12$$

2. $\cos300^\circ$: reference angle $60^\circ$, and cosine is positive in Quadrant IV.

$$\cos300^\circ=\dfrac12$$

3. Add:

$$\dfrac12+\dfrac12=1$$

## Speed Tricks & Shortcuts

For special-angle value questions, use the same routine: locate the quadrant, find the reference angle, recall the special-angle magnitude, then apply the sign. For radians, compare with $\dfrac\pi2$, $\pi$, and $\dfrac{3\pi}{2}$.

For the special angles emphasized in this lesson, sine and cosine values come from the set $0$, $\pm\dfrac12$, $\pm\dfrac{\sqrt2}{2}$, $\pm\dfrac{\sqrt3}{2}$, and $\pm1$. This is a shortcut for these common angles, not a list of all possible sine or cosine values.

In the first quadrant, sine increases from $0$ to $1$ while cosine decreases from $1$ to $0$. This can help distinguish $\sin30^\circ$ from $\sin60^\circ$ if you forget which is larger.

## Traps to Watch For

### #1: Right Magnitude, Wrong Sign

> The reference angle gives the magnitude; the quadrant gives the sign.

For example, $\cos120^\circ$ has the same magnitude as $\cos60^\circ$ but is negative because $120^\circ$ lies in Quadrant II.

### #2: Swapping Sine and Cosine Coordinates

> The unit-circle point is $(\cos\theta,\sin\theta)$: cosine first.

Coordinates are ordered $(x,y)$. Cosine supplies the $x$-coordinate and sine supplies the $y$-coordinate.

### #3: The Reference-Angle Formula Depends on the Quadrant

> Measure the positive acute angle from the terminal side to the $x$-axis.

For an angle between $0^\circ$ and $360^\circ$, use the appropriate formula for its quadrant. For angles outside one full turn, first find a coterminal angle in that range.

### #4: Tangent Is Undefined on the $y$-Axis

> $\tan90^\circ$ and $\tan270^\circ$ are undefined.

At those angles cosine is $0$, so $\tan\theta=\dfrac{\sin\theta}{\cos\theta}$ would require division by zero. Tangent is $0$ where sine is $0$, such as at $0^\circ$ and $180^\circ$.

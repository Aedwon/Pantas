---
_id: "lesson-trigonometry-unit-circle"
title: "The Unit Circle (Exact Values of Standard Angles)"
summary: "How to find exact sine, cosine, and tangent values for any standard angle using the unit circle."
subject: "subject-mathematics"
topic: "topic-trigonometry"
estimatedMinutes: 13
isActive: true
---
## Core Concept

The **unit circle** is a circle of radius $1$ centered at the origin. It upgrades trigonometry beyond right triangles: now any angle, even $225^\circ$ or $-30^\circ$, has a sine and cosine.

Here is the whole idea. Stand an angle $\theta$ in standard position and mark where its ray crosses the circle. That crossing point is:

$$(\cos \theta, \sin \theta)$$

Cosine is the $x$-coordinate. Sine is the $y$-coordinate. Tangent is their ratio:

$$\tan \theta = \dfrac{\sin \theta}{\cos \theta}$$

<!-- ILLUSTRATION: unit circle with an angle theta drawn from the positive x-axis, the intersection point labeled (cos theta, sin theta) with dashed lines to both axes -->

The exact values for the first-quadrant standard angles must live in your memory:

- $\sin 0^\circ = 0$, $\quad \sin 30^\circ = \dfrac{1}{2}$, $\quad \sin 45^\circ = \dfrac{\sqrt{2}}{2}$, $\quad \sin 60^\circ = \dfrac{\sqrt{3}}{2}$, $\quad \sin 90^\circ = 1$.
- Cosine runs the same list backwards: $\cos 0^\circ = 1$ down to $\cos 90^\circ = 0$.
- Tangent: $\tan 0^\circ = 0$, $\tan 30^\circ = \dfrac{\sqrt{3}}{3}$, $\tan 45^\circ = 1$, $\tan 60^\circ = \sqrt{3}$, and $\tan 90^\circ$ is undefined.

For angles beyond $90^\circ$, use two tools:

**Tool 1, the reference angle**: the acute angle between the terminal ray and the $x$-axis. In Quadrant II it is $180^\circ - \theta$, in Quadrant III it is $\theta - 180^\circ$, in Quadrant IV it is $360^\circ - \theta$. The reference angle decides the size of the value.

**Tool 2, the quadrant signs**: the quadrant decides the sign. Since cosine is $x$ and sine is $y$, just picture where the point sits. Quadrant I: all positive. Quadrant II: only sine positive. Quadrant III: only tangent positive. Quadrant IV: only cosine positive.

<!-- ILLUSTRATION: unit circle divided into four quadrants labeled with which functions are positive in each: All, Sine, Tangent, Cosine -->

## Mnemonics & Memory Aids

For the quadrant signs, going counterclockwise from Quadrant I:

> All Students Take Calculus.

**A**ll positive, **S**ine positive, **T**angent positive, **C**osine positive.

For the sine values of $0^\circ, 30^\circ, 45^\circ, 60^\circ, 90^\circ$, use the square-root ladder: they are $\dfrac{\sqrt{0}}{2}, \dfrac{\sqrt{1}}{2}, \dfrac{\sqrt{2}}{2}, \dfrac{\sqrt{3}}{2}, \dfrac{\sqrt{4}}{2}$. Just count $0, 1, 2, 3, 4$ under the root. Cosine is the same ladder in reverse.

## Examples

### #1: Reading a Quadrant II Value

Find the exact value of $\cos 120^\circ$.

**Solution:**
Reference angle first, then sign.

1. $120^\circ$ is in Quadrant II. Its reference angle:

$$180 - 120 = 60$$

2. The size comes from $\cos 60^\circ = \dfrac{1}{2}$.
3. In Quadrant II, only sine is positive, so cosine is negative.

$$\cos 120^\circ = -\dfrac{1}{2}$$

### #2: A Quadrant III Value

Find the exact value of $\sin 225^\circ$.

**Solution:**
Same two tools.

1. $225^\circ$ is in Quadrant III. Reference angle:

$$225 - 180 = 45$$

2. The size comes from $\sin 45^\circ = \dfrac{\sqrt{2}}{2}$.
3. In Quadrant III, only tangent is positive, so sine is negative.

$$\sin 225^\circ = -\dfrac{\sqrt{2}}{2}$$

### #3: A Quadrant IV Tangent

Find the exact value of $\tan 300^\circ$.

**Solution:**
Reference angle, size, sign.

1. $300^\circ$ is in Quadrant IV. Reference angle:

$$360 - 300 = 60$$

2. The size comes from $\tan 60^\circ = \sqrt{3}$.
3. In Quadrant IV, only cosine is positive, so tangent is negative.

$$\tan 300^\circ = -\sqrt{3}$$

### #4: Negative and Axis Angles

Find $\sin(-30^\circ)$, $\cos 180^\circ$, and $\sin 90^\circ$.

**Solution:**
Negative angles swing clockwise. Axis angles sit right on the axes, so read their coordinates directly.

1. $-30^\circ$ is $30^\circ$ below the positive $x$-axis, in Quadrant IV, where sine is negative.

$$\sin(-30^\circ) = -\dfrac{1}{2}$$

2. $180^\circ$ points at the point $(-1, 0)$. Cosine is the $x$-coordinate.

$$\cos 180^\circ = -1$$

3. $90^\circ$ points at $(0, 1)$. Sine is the $y$-coordinate.

$$\sin 90^\circ = 1$$

### #5: Combining Values at Exam Level

Evaluate $\sin 150^\circ + \cos 300^\circ$.

**Solution:**
Handle each term with the reference-angle routine, then add.

1. $\sin 150^\circ$: Quadrant II, reference angle $180 - 150 = 30$, sine positive in Quadrant II.

$$\sin 150^\circ = \dfrac{1}{2}$$

2. $\cos 300^\circ$: Quadrant IV, reference angle $360 - 300 = 60$, cosine positive in Quadrant IV.

$$\cos 300^\circ = \dfrac{1}{2}$$

3. Add the two values.

$$\dfrac{1}{2} + \dfrac{1}{2} = 1$$

## Speed Tricks & Shortcuts

Turn every value question into the same three-step routine: quadrant, reference angle, sign. Say it like a chant. It works for degrees and radians alike; for radians, first anchor against $\pi$ (for example, $\dfrac{5\pi}{6}$ is just short of $\pi$, so Quadrant II with reference angle $\dfrac{\pi}{6}$).

The only sines and cosines that exist for standard angles are $0$, $\pm\dfrac{1}{2}$, $\pm\dfrac{\sqrt{2}}{2}$, $\pm\dfrac{\sqrt{3}}{2}$, and $\pm 1$. If a choice offers anything else (like $\dfrac{\sqrt{3}}{3}$ for a sine), it can only be a tangent value, and you can eliminate it.

Remember which pairs match: bigger angle in the first quadrant means bigger sine and smaller cosine. If you blank on whether $\sin 60^\circ$ is $\dfrac{1}{2}$ or $\dfrac{\sqrt{3}}{2}$, note that $60^\circ$ is a tall angle: sine must be the larger value, $\dfrac{\sqrt{3}}{2} \approx 0.87$.

## Traps to Watch For

### #1: Right Size, Wrong Sign

> The reference angle gives the size; the quadrant gives the sign.

The most common error is answering $\cos 120^\circ = \dfrac{1}{2}$, correct digits with a missing minus. Every choice list contains the sign-flipped twin. Finish the routine: never write the value until you have checked the quadrant.

### #2: Swapping Sine and Cosine Coordinates

> The unit circle point is $(\cos \theta, \sin \theta)$: cosine first.

Since coordinate pairs are $(x, y)$ and cosine is the $x$-value, cosine comes first, even though we usually say "sine and cosine" out loud. Reading the pair backwards swaps every answer, and it is a silent error you will not feel.

### #3: The Subtraction Depends on the Quadrant

> Use $180 - \theta$, $\theta - 180$, or $360 - \theta$: each quadrant has its own reference formula.

Students memorize only $180 - \theta$ and apply it everywhere. For $300^\circ$ that gives $-120$, which is nonsense. Picture the terminal ray and measure to the nearest piece of the $x$-axis (never the $y$-axis).

### #4: Tangent Blows Up on the $y$-Axis

> $\tan 90^\circ$ and $\tan 270^\circ$ are undefined.

At those angles the cosine is $0$, and dividing by zero is not allowed. The planted wrong answers are $0$ and $1$. Remember: tangent is $0$ where sine is $0$ ($0^\circ$ and $180^\circ$), and undefined where cosine is $0$.

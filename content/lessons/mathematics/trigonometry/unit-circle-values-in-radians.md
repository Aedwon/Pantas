---
_id: "lesson-trigonometry-unit-circle-values-in-radians"
title: "Unit Circle Values in Radians"
summary: "Convert between radians and degrees."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 6
partCount: 9
ordering: 0
keyPoints:
  - "Convert between radians and degrees."
  - "Find exact values for radian angles."
---
## Core Concept

### Radians

A **radian** measures an angle by arc length on the unit circle. Start at $(1,0)$ and walk counterclockwise along the circle for a distance of $1$. The angle you turned is $1$ radian.

The circle has length $2\pi$, so a full turn is $2\pi$ radians. Half a turn is $\pi$ radians. To change units:

$$\text{degrees}\times\dfrac{\pi}{180}=\text{radians} \qquad \text{radians}\times\dfrac{180}{\pi}=\text{degrees}$$

An angle written without a degree sign, such as $\dfrac\pi6$, is in radians. To place a special angle, look at the denominator of the fraction of $\pi$. Denominator $6$ means steps of $\dfrac\pi6=30^\circ$. Denominator $4$ means $45^\circ$ steps, $3$ means $60^\circ$ steps, and $2$ means $90^\circ$ steps. The numerator counts the steps.

So $\dfrac{5\pi}{6}$ is five steps of $30^\circ$, which is $150^\circ$. This shortcut covers denominators $1$, $2$, $3$, $4$ and $6$. An angle such as $\dfrac{\pi}{12}$ is $15^\circ$, which this lesson does not use.

In radians, the reference angle is $\pi-\theta$ in Quadrant II, $\theta-\pi$ in Quadrant III, and $2\pi-\theta$ in Quadrant IV. Coterminal angles differ by multiples of $2\pi$.

## Examples

### #1: Converting Between Degrees and Radians

Convert $\dfrac{5\pi}{6}$ radians to degrees and $240^\circ$ to radians. Then find $\cos240^\circ$.

**Solution:**
1. Multiply the radians by $\dfrac{180}{\pi}$:

$$\dfrac{5\pi}{6}\times\dfrac{180}{\pi}=150^\circ$$

2. Multiply the degrees by $\dfrac{\pi}{180}$:

$$240\times\dfrac{\pi}{180}=\dfrac{4\pi}{3}$$

3. $240^\circ$ is in Quadrant III. Its reference angle is $240-180=60$, and cosine is negative there.

$$\cos240^\circ=-\dfrac12$$

<!-- ILLUSTRATION: unit circle with 5π/6 marked at 150° in Quadrant II and 4π/3 marked at 240° in Quadrant III, each with its degree and radian label -->

### #2: Values at Radian Angles

Find the exact values of $\sin\dfrac{7\pi}{6}$ and $\cos\dfrac{13\pi}{6}$.

**Solution:**
1. The denominator $6$ means steps of $30^\circ$. Seven steps give $210^\circ$, which is in Quadrant III.
2. The reference angle is:

$$\dfrac{7\pi}{6}-\pi=\dfrac\pi6$$

3. Sine is negative in Quadrant III, and $\sin\dfrac\pi6=\dfrac12$.

$$\sin\dfrac{7\pi}{6}=-\dfrac12$$

4. $\dfrac{13\pi}{6}$ is more than one turn. Subtract $2\pi$:

$$\dfrac{13\pi}{6}-\dfrac{12\pi}{6}=\dfrac\pi6$$

5. So the angle is coterminal with $\dfrac\pi6$.

$$\cos\dfrac{13\pi}{6}=\dfrac{\sqrt3}{2}$$

<!-- ILLUSTRATION: unit circle with 7π/6 marked at 210° in Quadrant III and 13π/6 drawn as one full turn plus π/6, ending where π/6 ends -->

## Traps to Watch For

### #1: Mixing Degrees and Radians

> An angle with no degree sign is in radians.

The value $\sin\dfrac\pi6$ is $\dfrac12$, but $\sin30$ with no degree sign means $30$ radians, which is not $\dfrac12$. Check the unit before you place an angle.

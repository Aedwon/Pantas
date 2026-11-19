---
_id: "lesson-trigonometry-unit-circle-coordinates-and-axes"
title: "Unit Circle Coordinates and Axes"
summary: "Read sine and cosine from the terminal point."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 1
partCount: 9
ordering: 0
keyPoints:
  - "Read sine and cosine from the terminal point."
  - "Find tangent on the axes or from the terminal point."
---
## Core Concept

The **unit circle** is a circle of radius $1$ centered at the origin $(0,0)$. It lets us find sine and cosine for any angle, not only the acute angles of a right triangle. Angles such as $225^\circ$ and $-30^\circ$ have sine and cosine values too.

An angle is in **standard position** when its vertex is at the origin and its first ray, the **initial side**, lies on the positive $x$-axis. The angle turns to a second ray, the **terminal side**. A turn counterclockwise is positive. A turn clockwise is negative.

Mark the point where the terminal side of $\theta$ crosses the unit circle. That point has coordinates:

$$(\cos \theta, \sin \theta)$$

Cosine is the $x$-coordinate. Sine is the $y$-coordinate. For an acute angle, these match the right-triangle ratios, because the hypotenuse is $1$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "unit-circle", "labels": ["θ", "P(cos θ, sin θ)", "x = cos θ", "y = sin θ", "r = 1"], "semanticsLabel": "Unit circle with angle theta from positive x-axis and intersection point labeled cos theta comma sin theta."} -->

A terminal side on an axis meets the circle at $(1,0)$ for $0^\circ$, $(0,1)$ for $90^\circ$, $(-1,0)$ for $180^\circ$ and $(0,-1)$ for $270^\circ$. Read sine and cosine straight from these points. So $\cos180^\circ=-1$ and $\sin270^\circ=-1$.

Tangent is $0$ at $0^\circ$ and $180^\circ$, where $y=0$. It is undefined at $90^\circ$ and $270^\circ$, where $x=0$.

The angles $\theta$ and $-\theta$ are mirror images across the $x$-axis. So their $x$-coordinates match and their $y$-coordinates are opposites:

$$\cos(-\theta)=\cos\theta \qquad \sin(-\theta)=-\sin\theta$$

Tangent follows: $\tan(-\theta)=-\tan\theta$ wherever tangent is defined.

## Examples

### #1: Negative and Axis Angles

Find $\sin(-30^\circ)$, $\cos180^\circ$, and $\sin90^\circ$.

**Solution:**
Negative angles are measured clockwise from the positive $x$-axis. Axis angles can be read directly from their coordinates.

1. $-30^\circ$ is coterminal with $330^\circ$, in Quadrant IV. Its reference angle is $360-330=30$, and sine is negative there.

$$\sin(-30^\circ)=-\dfrac12$$

2. $180^\circ$ points at $(-1,0)$. Cosine is the $x$-coordinate.

$$\cos180^\circ=-1$$

3. $90^\circ$ points at $(0,1)$. Sine is the $y$-coordinate.

$$\sin90^\circ=1$$

<!-- FIGURE: {"kind": "geometry-diagram", "type": "unit-circle", "labels": ["-30° (330°)", "180°: (-1, 0)", "90°: (0, 1)"], "semanticsLabel": "Unit circle marking positions negative 30 degrees, 180 degrees at negative 1 comma 0, and 90 degrees at 0 comma 1."} -->

### #2: Tangent on the Axes

Find $\tan0^\circ$, $\tan90^\circ$, $\tan180^\circ$ and $\tan270^\circ$. Write "undefined" where there is no value.

**Solution:**
Tangent is $\dfrac yx$ for the point on the circle.

1. At $0^\circ$ the point is $(1,0)$.

$$\tan0^\circ=\dfrac01=0$$

2. At $90^\circ$ the point is $(0,1)$. The denominator is $0$, so $\tan90^\circ$ is undefined.
3. At $180^\circ$ the point is $(-1,0)$.

$$\tan180^\circ=\dfrac{0}{-1}=0$$

4. At $270^\circ$ the point is $(0,-1)$. The denominator is $0$, so $\tan270^\circ$ is undefined.

<!-- ILLUSTRATION: unit circle with the four axis points (1,0), (0,1), (-1,0) and (0,-1) labeled 0°, 90°, 180° and 270° -->

## Traps to Watch For

### #1: Swapping Sine and Cosine Coordinates

> The unit-circle point is $(\cos\theta,\sin\theta)$: cosine first.

Coordinates are ordered $(x,y)$. Cosine supplies the $x$-coordinate and sine supplies the $y$-coordinate.

### #2: Tangent Is Undefined on the $y$-Axis

> $\tan90^\circ$ and $\tan270^\circ$ are undefined.

At those angles cosine is $0$, so $\tan\theta=\dfrac{\sin\theta}{\cos\theta}$ would need division by zero. Tangent is $0$ where sine is $0$, such as at $0^\circ$ and $180^\circ$.

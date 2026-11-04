---
_id: "lesson-trigonometry-unit-circle"
title: "The Unit Circle (Exact Values of Standard Angles)"
summary: "How to find exact sine, cosine, and tangent values for common special angles in degrees and radians, and how the unit circle leads to coordinates and graphs."
subject: "subject-mathematics"
topic: "topic-trigonometry"
estimatedMinutes: 15
isActive: true
---
## Core Concept

The **unit circle** is a circle of radius $1$ centered at the origin $(0,0)$. It lets us find sine and cosine for any angle, not only the acute angles of a right triangle. Angles such as $225^\circ$ and $-30^\circ$ have sine and cosine values too.

An angle is in **standard position** when its vertex is at the origin and its first ray, the **initial side**, lies on the positive $x$-axis. The angle turns to a second ray, the **terminal side**. A turn counterclockwise is positive. A turn clockwise is negative.

Two angles are **coterminal** when they have the same terminal side. They differ by whole turns, and one full turn is $360^\circ$. For example, $60^\circ$, $420^\circ$ and $-300^\circ$ are coterminal.

Mark the point where the terminal side of $\theta$ crosses the unit circle. That point has coordinates:

$$(\cos \theta, \sin \theta)$$

Cosine is the $x$-coordinate. Sine is the $y$-coordinate. For an acute angle, these match the right-triangle ratios, because the hypotenuse is $1$.

Tangent is the ratio of the two coordinates:

$$\tan \theta = \dfrac{\sin \theta}{\cos \theta}$$

This needs $\cos\theta\neq0$. If $\cos\theta=0$, tangent is **undefined**, which means it has no value. If $\sin\theta=0$, tangent is $0$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "unit-circle", "labels": ["θ", "P(cos θ, sin θ)", "x = cos θ", "y = sin θ", "r = 1"], "semanticsLabel": "Unit circle with angle theta from positive x-axis and intersection point labeled cos theta comma sin theta."} -->

Every point $(x,y)$ on the unit circle has $x^2+y^2=1$. So for every angle:

$$\cos^2\theta+\sin^2\theta=1$$

Here $\cos^2\theta$ means $(\cos\theta)^2$. A coordinate on the unit circle is never bigger than $1$ or smaller than $-1$. So $\sin\theta$ and $\cos\theta$ are always between $-1$ and $1$. Tangent can be any number.

An **exact value** is written with fractions and square roots, not a rounded decimal. "Evaluate" means find the final value.

Two facts give the first-quadrant values. At $45^\circ$ the point has $x=y$, and $x^2+y^2=1$ then gives $x=y=\dfrac{\sqrt2}{2}$. At $30^\circ$ and $60^\circ$, the radius is the hypotenuse of a $30^\circ$-$60^\circ$-$90^\circ$ triangle, whose sides are in the ratio $1:\sqrt3:2$. With hypotenuse $1$, the sides are $\dfrac12$ and $\dfrac{\sqrt3}{2}$.

The exact values of the special angles are worth memorizing:

- $\sin 0^\circ = 0$, $\quad \sin 30^\circ = \dfrac{1}{2}$, $\quad \sin 45^\circ = \dfrac{\sqrt{2}}{2}$, $\quad \sin 60^\circ = \dfrac{\sqrt{3}}{2}$, $\quad \sin 90^\circ = 1$.
- Cosine runs the same list backwards: $\cos 0^\circ = 1$ down to $\cos 90^\circ = 0$.
- Tangent: $\tan 0^\circ = 0$, $\tan 30^\circ = \dfrac{\sqrt{3}}{3}$, $\tan 45^\circ = 1$, $\tan 60^\circ = \sqrt{3}$, and $\tan 90^\circ$ is undefined.

A terminal side on an axis meets the circle at $(1,0)$ for $0^\circ$, $(0,1)$ for $90^\circ$, $(-1,0)$ for $180^\circ$ and $(0,-1)$ for $270^\circ$. Read sine and cosine straight from these points. So $\cos180^\circ=-1$ and $\sin270^\circ=-1$.

Tangent is $0$ at $0^\circ$ and $180^\circ$, where $y=0$. It is undefined at $90^\circ$ and $270^\circ$, where $x=0$.

For angles beyond $90^\circ$, use two tools. First, the axes split the plane into four **quadrants**, numbered I to IV counterclockwise from the upper right. An angle on an axis is in no quadrant.

**Tool 1, the reference angle**: the positive acute angle between the terminal side and the $x$-axis. It is defined for an angle not on an axis. For $\theta$ between $0^\circ$ and $360^\circ$, use $180^\circ-\theta$ in Quadrant II, $\theta-180^\circ$ in Quadrant III, and $360^\circ-\theta$ in Quadrant IV. In Quadrant I, the angle is its own reference angle.

The point in any quadrant is a mirror image of a first-quadrant point. So its coordinates have the same sizes. This means $\sin\theta$, $\cos\theta$ and $\tan\theta$ have the same size as the values at the reference angle.

If $\theta$ is outside $0^\circ$ to $360^\circ$, first add or subtract $360^\circ$ until it is inside. This gives a coterminal angle with the same sine, cosine and tangent.

**Tool 2, the quadrant signs**: the quadrant gives the sign. Cosine is $x$ and sine is $y$. Quadrant I has both positive. Quadrant II has sine positive and cosine negative. Quadrant III has both negative. Quadrant IV has cosine positive and sine negative. Tangent is positive when sine and cosine have the same sign, and negative when they differ.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "unit-circle-quadrants", "labels": ["Q I: All (+)", "Q II: Sine (+)", "Q III: Tangent (+)", "Q IV: Cosine (+)"], "semanticsLabel": "Unit circle divided into four quadrants showing which trigonometric functions are positive: All, Sine, Tangent, and Cosine."} -->

The angles $\theta$ and $-\theta$ are mirror images across the $x$-axis. So their $x$-coordinates match and their $y$-coordinates are opposites:

$$\cos(-\theta)=\cos\theta \qquad \sin(-\theta)=-\sin\theta$$

Tangent follows: $\tan(-\theta)=-\tan\theta$ wherever tangent is defined.

### Radians

A **radian** measures an angle by arc length on the unit circle. Start at $(1,0)$ and walk counterclockwise along the circle for a distance of $1$. The angle you turned is $1$ radian.

The circle has length $2\pi$, so a full turn is $2\pi$ radians. Half a turn is $\pi$ radians. To change units:

$$\text{degrees}\times\dfrac{\pi}{180}=\text{radians} \qquad \text{radians}\times\dfrac{180}{\pi}=\text{degrees}$$

An angle written without a degree sign, such as $\dfrac\pi6$, is in radians. To place a special angle, look at the denominator of the fraction of $\pi$. Denominator $6$ means steps of $\dfrac\pi6=30^\circ$. Denominator $4$ means $45^\circ$ steps, $3$ means $60^\circ$ steps, and $2$ means $90^\circ$ steps. The numerator counts the steps.

So $\dfrac{5\pi}{6}$ is five steps of $30^\circ$, which is $150^\circ$. This shortcut covers denominators $1$, $2$, $3$, $4$ and $6$. An angle such as $\dfrac{\pi}{12}$ is $15^\circ$, which this lesson does not use.

In radians, the reference angle is $\pi-\theta$ in Quadrant II, $\theta-\pi$ in Quadrant III, and $2\pi-\theta$ in Quadrant IV. Coterminal angles differ by multiples of $2\pi$.

### Points on Other Circles

A point can be given by rectangular coordinates $(x,y)$ or by **polar coordinates** $(r,\theta)$. Here $r$ is the distance from the origin, with $r\geq0$. The angle $\theta$ is the angle of the ray from the origin through the point.

A circle of radius $r$ is the unit circle stretched by the factor $r$. So the point at angle $\theta$ is $r$ times the unit-circle point:

$$x=r\cos\theta \qquad y=r\sin\theta$$

To go the other way, use the distance formula, then place the angle:

$$r=\sqrt{x^2+y^2}$$

The reference angle comes from the sizes $|x|$ and $|y|$, and the signs of $x$ and $y$ give the quadrant. If $r=0$, the point is the origin and any angle works.

### Graphs of Sine, Cosine and Tangent

To graph $y=\sin x$, put the angle $x$ in radians on the horizontal axis and $\sin x$ on the vertical axis. The **period** is the length of one full pattern before it repeats. Sine and cosine have period $2\pi$, one full turn. Tangent has period $\pi$, because opposite points on the circle give the same $\dfrac yx$.

The **amplitude** is half the distance from the greatest value to the least value. Sine and cosine have amplitude $1$, with greatest value $1$ and least value $-1$. Tangent has no greatest or least value.

For $0\leq x\leq2\pi$, the sine graph is $0$ at $0$, $\pi$ and $2\pi$. It reaches $1$ at $\dfrac\pi2$ and $-1$ at $\dfrac{3\pi}{2}$. The cosine graph is the sine graph shifted left by $\dfrac\pi2$. It is $1$ at $0$ and $2\pi$, $-1$ at $\pi$, and $0$ at $\dfrac\pi2$ and $\dfrac{3\pi}{2}$.

The tangent graph is $0$ at $0$, $\pi$ and $2\pi$. At $\dfrac\pi2$ and $\dfrac{3\pi}{2}$ it has vertical **asymptotes**, which are lines the graph approaches but never touches. Between asymptotes the graph rises through all values, and it passes through $\left(\dfrac\pi4,1\right)$.

## Mnemonics & Memory Aids

For the signs of sine, cosine, and tangent in the four quadrants, going counterclockwise from Quadrant I:

> All Students Take Calculus.

**A**ll positive, **S**ine positive, **T**angent positive, **C**osine positive. In each quadrant, the functions not named are negative.

For the sine values of $0^\circ, 30^\circ, 45^\circ, 60^\circ, 90^\circ$, use the square-root ladder: $\dfrac{\sqrt{0}}{2}, \dfrac{\sqrt{1}}{2}, \dfrac{\sqrt{2}}{2}, \dfrac{\sqrt{3}}{2}, \dfrac{\sqrt{4}}{2}$. Cosine is the same ladder in reverse.

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

### #3: A Quadrant IV Tangent

Find the exact value of $\tan 300^\circ$.

**Solution:**
1. $300^\circ$ is in Quadrant IV. Its reference angle is:

$$360 - 300 = 60$$

2. The size comes from $\tan60^\circ=\sqrt3$.
3. In Quadrant IV, sine is negative and cosine is positive. So tangent is negative.

$$\tan300^\circ=-\sqrt3$$

<!-- FIGURE: {"kind": "geometry-diagram", "type": "unit-circle", "labels": ["300°", "Reference angle: 60°", "(1/2, -√3/2)", "Quadrant IV"], "semanticsLabel": "Unit circle with terminal ray at 300 degrees in Quadrant IV, 60 degree reference angle, and coordinates 1 half comma negative root 3 over 2."} -->

### #4: Negative and Axis Angles

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

### #5: Combining Values

Evaluate $\sin150^\circ+\cos300^\circ$.

**Solution:**
1. $\sin150^\circ$: reference angle $30^\circ$, and sine is positive in Quadrant II.

$$\sin150^\circ=\dfrac12$$

2. $\cos300^\circ$: reference angle $60^\circ$, and cosine is positive in Quadrant IV.

$$\cos300^\circ=\dfrac12$$

3. Add:

$$\dfrac12+\dfrac12=1$$

<!-- FIGURE: {"kind": "geometry-diagram", "type": "unit-circle", "labels": ["150° (sin = 1/2)", "300° (cos = 1/2)", "Sum = 1"], "semanticsLabel": "Unit circle marking 150 degrees in Quadrant II with sine 1 half and 300 degrees in Quadrant IV with cosine 1 half."} -->

### #6: Tangent on the Axes

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

### #7: Angles Beyond One Turn

Find the exact values of $\cos780^\circ$ and $\tan(-135^\circ)$.

**Solution:**
Find a coterminal angle between $0^\circ$ and $360^\circ$ first.

1. Subtract two full turns from $780^\circ$:

$$780-720=60$$

2. So $\cos780^\circ=\cos60^\circ=\dfrac12$.
3. Add one full turn to $-135^\circ$:

$$-135+360=225$$

4. $225^\circ$ is in Quadrant III with reference angle $45^\circ$. Tangent is positive there, and $\tan45^\circ=1$.

$$\tan(-135^\circ)=1$$

<!-- ILLUSTRATION: unit circle showing 780° as two full turns plus 60° and -135° as a clockwise turn ending at 225°, both with their terminal sides in the labeled quadrants -->

### #8: Converting Between Degrees and Radians

Convert $\dfrac{5\pi}{6}$ radians to degrees and $240^\circ$ to radians. Then find $\cos240^\circ$.

**Solution:**
1. Multiply the radians by $\dfrac{180}{\pi}$:

$$\dfrac{5\pi}{6}\times\dfrac{180}{\pi}=150^\circ$$

2. Multiply the degrees by $\dfrac{\pi}{180}$:

$$240\times\dfrac{\pi}{180}=\dfrac{4\pi}{3}$$

3. $240^\circ$ is in Quadrant III. Its reference angle is $240-180=60$, and cosine is negative there.

$$\cos240^\circ=-\dfrac12$$

<!-- ILLUSTRATION: unit circle with 5π/6 marked at 150° in Quadrant II and 4π/3 marked at 240° in Quadrant III, each with its degree and radian label -->

### #9: Values at Radian Angles

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

### #10: Finding the Angle from a Value

Find all angles $\theta$ with $0^\circ\leq\theta<360^\circ$ such that $\cos\theta=-\dfrac{\sqrt2}{2}$.

**Solution:**
1. The size is $\dfrac{\sqrt2}{2}$, so the reference angle is $45^\circ$.
2. Cosine is negative in Quadrants II and III.
3. In Quadrant II, the angle is $180-45=135$.
4. In Quadrant III, the angle is $180+45=225$.

$$\theta=135^\circ \text{ or } 225^\circ$$

<!-- ILLUSTRATION: unit circle with the x-coordinate -√2/2 marked as a vertical line, meeting the circle at the 135° point in Quadrant II and the 225° point in Quadrant III -->

### #11: Using the Identity with a Quadrant

The angle $\theta$ is in Quadrant II and $\sin\theta=\dfrac35$. Find $\cos\theta$ and $\tan\theta$.

**Solution:**
1. Use $\cos^2\theta+\sin^2\theta=1$:

$$\cos^2\theta=1-\dfrac{9}{25}=\dfrac{16}{25}$$

2. So $\cos\theta=\pm\dfrac45$. Cosine is negative in Quadrant II.

$$\cos\theta=-\dfrac45$$

3. Divide sine by cosine:

$$\tan\theta=\dfrac{3/5}{-4/5}=-\dfrac34$$

<!-- ILLUSTRATION: unit circle with a point in Quadrant II at height 3/5 and x-coordinate -4/5 -->

### #12: Polar to Rectangular

A point has polar coordinates $r=4$ and $\theta=210^\circ$. Find its rectangular coordinates.

**Solution:**
1. $210^\circ$ is in Quadrant III with reference angle $30^\circ$. So $\cos210^\circ=-\dfrac{\sqrt3}{2}$ and $\sin210^\circ=-\dfrac12$.
2. Multiply each by $r=4$:

$$x=4\left(-\dfrac{\sqrt3}{2}\right)=-2\sqrt3$$

$$y=4\left(-\dfrac12\right)=-2$$

The point is $(-2\sqrt3,-2)$.

<!-- ILLUSTRATION: coordinate plane with a circle of radius 4 and the point at 210° with coordinates (-2√3, -2) -->

### #13: Rectangular to Polar

A point has rectangular coordinates $(-1,\sqrt3)$. Find $r$ and $\theta$ with $0^\circ\leq\theta<360^\circ$.

**Solution:**
1. Find the distance from the origin:

$$r=\sqrt{(-1)^2+(\sqrt3)^2}=\sqrt4=2$$

2. The sizes are $|x|=1$ and $|y|=\sqrt3$. The ratio is $\dfrac{\sqrt3}{1}=\sqrt3$, so the reference angle is $60^\circ$.
3. The point has $x$ negative and $y$ positive, so it is in Quadrant II.

$$\theta=180-60=120$$

The polar coordinates are $(2,120^\circ)$, which is $\left(2,\dfrac{2\pi}{3}\right)$.

<!-- ILLUSTRATION: coordinate plane with the point (-1, √3), a segment of length 2 from the origin, and the angle 120° from the positive x-axis -->

### #14: Reading the Graphs

For $0\leq x\leq2\pi$, find the greatest and least values of $y=\cos x$ and where they happen. Then find where $y=\tan x$ is undefined.

**Solution:**
1. The greatest value of cosine is $1$. It happens at $x=0$ and $x=2\pi$.
2. The least value is $-1$. It happens at $x=\pi$.
3. Tangent is undefined where $\cos x=0$. This happens at $x=\dfrac\pi2$ and $x=\dfrac{3\pi}{2}$, where the tangent graph has its asymptotes.

<!-- ILLUSTRATION: graphs of y = cos x and y = tan x for x from 0 to 2π, with cos x reaching 1 at 0 and 2π and -1 at π, and tan x with vertical asymptotes at π/2 and 3π/2 -->

## Speed Tricks & Shortcuts

For special-angle value questions, use the same routine: locate the quadrant, find the reference angle, recall the special-angle size, then apply the sign. If the angle is on an axis, skip this and read the point. For radians, compare with $\dfrac\pi2$, $\pi$, and $\dfrac{3\pi}{2}$.

For the special angles in this lesson (multiples of $30^\circ$ and $45^\circ$), sine and cosine values come from the set $0$, $\pm\dfrac12$, $\pm\dfrac{\sqrt2}{2}$, $\pm\dfrac{\sqrt3}{2}$, and $\pm1$. This is a shortcut for these angles, not a list of all possible sine or cosine values.

Between $0^\circ$ and $90^\circ$, sine increases from $0$ to $1$ while cosine decreases from $1$ to $0$. This can help distinguish $\sin30^\circ$ from $\sin60^\circ$ if you forget which is larger.

## Traps to Watch For

### #1: Right Size, Wrong Sign

> The reference angle gives the size; the quadrant gives the sign.

For example, $\cos120^\circ$ has the same size as $\cos60^\circ$ but is negative because $120^\circ$ lies in Quadrant II.

### #2: Swapping Sine and Cosine Coordinates

> The unit-circle point is $(\cos\theta,\sin\theta)$: cosine first.

Coordinates are ordered $(x,y)$. Cosine supplies the $x$-coordinate and sine supplies the $y$-coordinate.

### #3: The Reference-Angle Formula Depends on the Quadrant

> Measure the positive acute angle from the terminal side to the $x$-axis.

For an angle between $0^\circ$ and $360^\circ$ that is not on an axis, use the formula for its quadrant. For angles outside one full turn, first find a coterminal angle in that range.

### #4: Tangent Is Undefined on the $y$-Axis

> $\tan90^\circ$ and $\tan270^\circ$ are undefined.

At those angles cosine is $0$, so $\tan\theta=\dfrac{\sin\theta}{\cos\theta}$ would need division by zero. Tangent is $0$ where sine is $0$, such as at $0^\circ$ and $180^\circ$.

### #5: Mixing Degrees and Radians

> An angle with no degree sign is in radians.

The value $\sin\dfrac\pi6$ is $\dfrac12$, but $\sin30$ with no degree sign means $30$ radians, which is not $\dfrac12$. Check the unit before you place an angle.

### #6: Finding the Angle from $\dfrac yx$ Alone

> Two different angles can have the same ratio $\dfrac yx$.

The points $(-1,\sqrt3)$ and $(1,-\sqrt3)$ both have $\dfrac yx=-\sqrt3$, but their angles are $120^\circ$ and $300^\circ$. Use the signs of $x$ and $y$ to pick the quadrant. If $x=0$, the ratio does not exist, and the angle is $90^\circ$ or $270^\circ$.

---
_id: "lesson-trigonometry-law-of-cosines-for-angles"
title: "Law of Cosines for Angles"
summary: "Use the three sides to find or classify an angle."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 5
partCount: 7
ordering: 0
keyPoints:
  - "Use the three sides to find or classify an angle."
  - "Find sine and cosine for an obtuse angle."
---
## Core Concept

### Sine and cosine of angles up to $180^\circ$

An angle in a triangle can be obtuse, which means more than $90^\circ$ and less than $180^\circ$. For these angles, use two facts:

$$\sin(180^\circ - x) = \sin x \qquad \cos(180^\circ - x) = -\cos x$$

So $\sin 120^\circ = \sin 60^\circ = \dfrac{\sqrt{3}}{2}$, and $\cos 120^\circ = -\cos 60^\circ = -\dfrac{1}{2}$. The sine of an obtuse angle is positive. The cosine of an obtuse angle is negative.

Here are the values you need most:

- $\sin 30^\circ = \dfrac{1}{2}$, $\sin 45^\circ = \dfrac{\sqrt{2}}{2}$, $\sin 60^\circ = \dfrac{\sqrt{3}}{2}$
- $\cos 30^\circ = \dfrac{\sqrt{3}}{2}$, $\cos 45^\circ = \dfrac{\sqrt{2}}{2}$, $\cos 60^\circ = \dfrac{1}{2}$

If $C = 90^\circ$, then $\cos C = 0$ and the correction disappears. You get plain Pythagoras. To find an angle, solve the first form for $\cos C$:

$$\cos C = \dfrac{a^2 + b^2 - c^2}{2ab}$$

A cosine fixes one angle between $0^\circ$ and $180^\circ$. A positive cosine means an acute angle. A negative cosine means an obtuse angle.

## Examples

### #1: Law of Cosines (SSS) for an Angle

A triangle has sides $3$, $5$, and $7$. Find its largest angle.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle", "labels": ["Side = 3", "Side = 5", "Side = 7", "Largest angle = ?"], "semanticsLabel": "Triangle with sides 3, 5, and 7 and its largest angle marked with a question mark."} -->

**Solution:**
The largest angle sits opposite the longest side, $7$. Solve the Law of Cosines for that angle.

1. Call the wanted angle $C$, so $c = 7$.

$$\cos C = \dfrac{3^2 + 5^2 - 7^2}{2(3)(5)}$$

2. Compute the squares.

$$\cos C = \dfrac{9 + 25 - 49}{30}$$

3. Simplify.

$$\cos C = \dfrac{-15}{30} = -\dfrac{1}{2}$$

4. Cosine of $60^\circ$ is $\dfrac{1}{2}$. So an angle with cosine $-\dfrac{1}{2}$ is $180^\circ - 60^\circ$.

$$C = 120^\circ$$

5. The largest angle is $120^\circ$. The negative cosine told us early that the angle is obtuse.

## Speed Tricks & Shortcuts

Special angles keep the arithmetic clean. Angles of $60^\circ$ and $120^\circ$ have cosines of $\dfrac{1}{2}$ and $-\dfrac{1}{2}$. Then the term $2ab\cos C$ becomes $ab$ or $-ab$.

## Traps to Watch For

### #1: Losing the Sign of the Cosine

> For obtuse angles, $\cos C$ is negative, and subtracting a negative adds.

With $C = 120^\circ$, the term $-2ab\cos C$ becomes $-2ab \times \left(-\dfrac{1}{2}\right) = +ab$. Students drop the sign and subtract instead. The third side then comes out too short. Track the sign all the way through.

### #2: Finding a Large Angle With the Sine

> A sine cannot tell an acute angle from an obtuse one. A cosine can.

If $\sin B = \dfrac{1}{2}$, then $B$ could be $30^\circ$ or $150^\circ$. In SSS and SAS problems, use the Law of Cosines to find angles. It gives one answer. Use the Law of Sines for an angle only when you know the angle is acute, or when you test both answers as in an SSA problem.

---
_id: "lesson-trigonometry-polar-and-rectangular-coordinates"
title: "Polar and Rectangular Coordinates"
summary: "Convert polar coordinates to rectangular coordinates."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 8
partCount: 9
ordering: 17
keyPoints:
  - "Convert polar coordinates to rectangular coordinates."
  - "Find the radius and angle from rectangular coordinates."
---
## Core Concept

### Points on Other Circles

A point can be given by rectangular coordinates $(x,y)$ or by **polar coordinates** $(r,\theta)$. Here $r$ is the distance from the origin, with $r\geq0$. The angle $\theta$ is the angle of the ray from the origin through the point.

A circle of radius $r$ is the unit circle stretched by the factor $r$. So the point at angle $\theta$ is $r$ times the unit-circle point:

$$x=r\cos\theta \qquad y=r\sin\theta$$

To go the other way, use the distance formula, then place the angle:

$$r=\sqrt{x^2+y^2}$$

The reference angle comes from the sizes $|x|$ and $|y|$: when $x$ and $y$ are both nonzero, its tangent is $\dfrac{|y|}{|x|}$. The signs of $x$ and $y$ give the quadrant. If $r=0$, the point is the origin and any angle works.

## Examples

### #1: Polar to Rectangular

A point has polar coordinates $r=4$ and $\theta=210^\circ$. Find its rectangular coordinates.

**Solution:**
1. $210^\circ$ is in Quadrant III with reference angle $30^\circ$. So $\cos210^\circ=-\dfrac{\sqrt3}{2}$ and $\sin210^\circ=-\dfrac12$.
2. Multiply each by $r=4$:

$$x=4\left(-\dfrac{\sqrt3}{2}\right)=-2\sqrt3$$

$$y=4\left(-\dfrac12\right)=-2$$

The point is $(-2\sqrt3,-2)$.

<!-- ILLUSTRATION: coordinate plane with a circle of radius 4 and the point at 210° with coordinates (-2√3, -2) -->

### #2: Rectangular to Polar

A point has rectangular coordinates $(-1,\sqrt3)$. Find $r$ and $\theta$ with $0^\circ\leq\theta<360^\circ$.

**Solution:**
1. Find the distance from the origin:

$$r=\sqrt{(-1)^2+(\sqrt3)^2}=\sqrt4=2$$

2. The sizes are $|x|=1$ and $|y|=\sqrt3$. The ratio is $\dfrac{\sqrt3}{1}=\sqrt3$, so the reference angle is $60^\circ$.
3. The point has $x$ negative and $y$ positive, so it is in Quadrant II.

$$\theta=180-60=120$$

The polar coordinates are $(2,120^\circ)$, which is $\left(2,\dfrac{2\pi}{3}\right)$.

<!-- ILLUSTRATION: coordinate plane with the point (-1, √3), a segment of length 2 from the origin, and the angle 120° from the positive x-axis -->

## Traps to Watch For

### #1: Finding the Angle from $\dfrac yx$ Alone

> Two different angles can have the same ratio $\dfrac yx$.

The points $(-1,\sqrt3)$ and $(1,-\sqrt3)$ both have $\dfrac yx=-\sqrt3$, but their angles are $120^\circ$ and $300^\circ$. Use the signs of $x$ and $y$ to pick the quadrant. If $x=0$ and $y\neq0$, the ratio does not exist. The angle is $90^\circ$ when $y>0$ and $270^\circ$ when $y<0$.

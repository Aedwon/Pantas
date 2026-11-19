---
_id: "lesson-physics-angular-speed-and-rotation"
title: "Angular Speed and Rotation"
summary: "Use angular speed to find the speed and acceleration of a point on a rotating object."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 7
partCount: 7
ordering: 0
keyPoints:
  - "Convert between period, rpm, and angular speed."
  - "Relate angular speed and radius to speed and centripetal acceleration."
---
## Core Concept

### Angular Speed and Rotational Motion

In **rotational motion**, an object turns about a fixed line called the **axis**. Think of a spinning wheel. In **translational motion**, the whole object moves from place to place.

The turn is measured as an angle. The **radian** (rad) is the angle unit used in physics formulas. One full turn is $2\pi$ rad, which is $360^\circ$.

**Angular speed** $\omega$ is the angle turned per unit time. For steady turning:

$$\omega=\dfrac{\Delta\theta}{\Delta t}.$$

Its unit is rad/s. Compare it with speed: speed is distance per time, and angular speed is angle per time.

One full turn takes the **period** $T$, in seconds. So

$$\omega=\dfrac{2\pi}{T}.$$

If the turning is given in revolutions per minute (rpm), change it with $\omega=\dfrac{2\pi\times\text{rpm}}{60}$.

A point at distance $r$ from the axis moves along a circle. Its speed is

$$v=\omega r,$$

with $\omega$ in rad/s. This is the link between turning and moving along the circle.

Now put $v=\omega r$ into $a_c=v^2/r$:

$$a_c=\omega^2r.$$

All points on a rigid spinning object have the same $\omega$. But points farther from the axis have a larger $v$ and a larger $a_c$.

<!-- ILLUSTRATION: top view of a circular platform turning at 12 rpm, with rider A at r = 2.0 m and rider B at r = 4.0 m on the same radius line, each with a tangent velocity arrow, B's arrow drawn twice as long as A's -->

## Examples

### #1: Period, Angular Speed, and Centripetal Acceleration

A rider sits $3.0$ m from the center of a merry-go-round that makes one full turn every $4.0$ s. Find the angular speed, the rider's speed, and the rider's centripetal acceleration.

**Solution:**

1. Angular speed, with $T=4.0$ s:

$$\omega=\dfrac{2\pi}{T}=\dfrac{2\pi}{4.0}\approx1.57\,\mathrm{rad/s}.$$

2. Speed:

$$v=\omega r=(1.57)(3.0)\approx4.71\,\mathrm{m/s}.$$

3. Centripetal acceleration:

$$a_c=\omega^2r=(1.57)^2(3.0)\approx7.4\,\mathrm{m/s^2}.$$

Check: $v^2/r=\dfrac{(4.71)^2}{3.0}\approx7.4\,\mathrm{m/s^2}$. It matches.

### #2: Two Riders on the Same Platform

A platform turns at $12$ rpm. Rider A sits $2.0$ m from the axis and rider B sits $4.0$ m from it. Compare their angular speeds and speeds.

**Solution:**

1. Change rpm to rad/s:

$$\omega=\dfrac{2\pi(12)}{60}\approx1.26\,\mathrm{rad/s}.$$

2. Both riders are on the same rigid platform, so both have this $\omega$.

3. Speeds:

$$v_A=\omega r_A=(1.26)(2.0)\approx2.5\,\mathrm{m/s}$$

$$v_B=\omega r_B=(1.26)(4.0)\approx5.0\,\mathrm{m/s}.$$

The angular speeds are equal. Rider B moves twice as fast because B is twice as far from the axis.

## Speed Tricks & Shortcuts

To change units to radians per second, use $2\pi$ rad per turn. Divide by $60$ when the rate is per minute.

## Traps to Watch For

### #1: Using Degrees in $v=\omega r$

> $\omega$ must be in rad/s for $v=\omega r$ to work.

Change revolutions per minute or degrees per second to rad/s first. Also do not mix up $\omega$ with $v$: all points of a spinning wheel share $\omega$, but each has its own $v$.

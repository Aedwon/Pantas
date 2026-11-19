---
_id: "lesson-physics-projectile-peaks-and-level-ground-range"
title: "Projectile Peaks and Level-Ground Range"
summary: "Find the peak, flight time, and range of a projectile on level ground."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 3
partCount: 7
ordering: 23
keyPoints:
  - "Describe velocity and acceleration at the peak."
  - "Use the level-ground formulas for time, height, and range."
---
## Core Concept

### The Highest Point

Think of a projectile that goes up first and then comes down. At the highest point, the vertical velocity is momentarily zero: $v_y=0$. The acceleration is still $a_y=-g$, because gravity does not switch off.

The total velocity at the top is the horizontal velocity $v_{x0}$. It is zero only when $v_{x0}=0$, such as a ball thrown straight up.

### Level-Ground Formulas

Suppose the object lands at the same height it was launched from. Then the path is symmetric, and these results hold:

$$t_{\text{up}}=\dfrac{v_0\sin\theta}{g},\qquad T=2t_{\text{up}}=\dfrac{2v_0\sin\theta}{g}$$

$$H=\dfrac{v_0^2\sin^2\theta}{2g},\qquad R=\dfrac{v_0^2\sin2\theta}{g}.$$

Here $T$ is the total flight time, $H$ is the greatest height above the launch point, and $R$ is the **range**, the horizontal distance traveled.

These formulas need two conditions: launch and landing at the same height, and the ideal model. If the landing height is different, go back to the basic equations.

On level ground in the ideal model, $\sin2\theta$ is largest at $\theta=45^\circ$, so $45^\circ$ gives the longest range for a given speed. Two launch angles that add to $90^\circ$, such as $30^\circ$ and $60^\circ$, give the same range.

## Examples

### #1: Time, Height, and Range on Level Ground

The projectile from #1 ($20\,\mathrm{m/s}$ at $30^\circ$) lands at its launch height. Neglect air resistance. Find the time to the top, the total flight time, the greatest height, and the range.

**Solution:**

1. At the top, $v_y=0$. With $v_{y0}=10\,\mathrm{m/s}$:

$$0=10-9.8t_{\text{up}}\quad\Rightarrow\quad t_{\text{up}}\approx1.02\,\mathrm s.$$

2. The landing height equals the launch height, so the flight is symmetric:

$$T=2t_{\text{up}}\approx2.04\,\mathrm s.$$

3. Greatest height:

$$H=\dfrac{v_{y0}^2}{2g}=\dfrac{10^2}{2(9.8)}\approx5.10\,\mathrm m.$$

4. Range, using the constant horizontal velocity:

$$R=v_{x0}T=(17.3)(2.04)\approx35.3\,\mathrm m.$$

Check with the formula: $R=\dfrac{20^2\sin60^\circ}{9.8}\approx35.3$ m. It matches.

## Speed Tricks & Shortcuts

For a launch at a level start and end, the time to the top is half the flight time. Use it only when launch and landing heights are equal.

At the highest point of a rising-then-falling projectile, $v_y=0$ but $a_y=-g$.

## Traps to Watch For

### #1: Saying Acceleration Is Zero at the Peak

> At the top, only the vertical velocity is zero.

Gravity still gives $a_y=-g$. Also, the speed at the top is not zero unless the horizontal velocity is zero.

### #2: Using the Level-Ground Formulas Anywhere

> $R=\dfrac{v_0^2\sin2\theta}{g}$ and "$45^\circ$ gives the longest range" need equal launch and landing heights and no air resistance.

If the ball lands lower, as in #4, use the basic equations. For a launch from a height onto lower ground, the angle for the longest range is less than $45^\circ$, and how much less depends on the height. For #4 it is about $27^\circ$. For landing higher than the launch, it is more than $45^\circ$.

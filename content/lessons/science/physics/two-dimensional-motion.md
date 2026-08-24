---
_id: "lesson-physics-two-dimensional-motion"
title: "Two-Dimensional Motion (Projectile Motion, Uniform Circular Motion)"
summary: "How ideal projectile motion separates into horizontal and vertical components and how inward acceleration maintains uniform circular motion."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 12
isActive: true
---
## Core Concept

### Ideal Projectile Motion

A **projectile** in the standard introductory model moves after launch under gravity alone, neglecting air resistance and treating $g$ as uniform over the motion.

Choose $x$ horizontal and $y$ upward. Then

$$a_x=0,\qquad a_y=-g.$$

The two component equations can be solved separately because gravity has no horizontal component in this model, although the two motions share the **same time variable**.

For launch from $(x_0,y_0)$ with components $v_{x0},v_{y0}$:

$$x=x_0+v_{x0}t$$

$$y=y_0+v_{y0}t-\frac12gt^2$$

$$v_x=v_{x0},\qquad v_y=v_{y0}-gt.$$

If the initial speed $v_0$ makes angle $\theta$ above the positive horizontal,

$$v_{x0}=v_0\cos\theta,\qquad v_{y0}=v_0\sin\theta.$$

Under these assumptions, eliminating $t$ gives a **parabolic** trajectory. With air resistance, variable gravity, strong winds, or very long ranges, the path need not be a parabola.

At the highest point of an ordinary upward-then-downward projectile trajectory, $v_y=0$ momentarily. The total velocity is zero there **only** if the horizontal component is also zero.

### Uniform Circular Motion

An object moving around a circle of radius $r$ at constant speed $v$ has changing velocity direction and therefore an inward acceleration:

$$a_c=\frac{v^2}{r}=\omega^2r.$$

The required **net radial force** is

$$F_{\text{net,radial}}=ma_c=m\frac{v^2}{r}.$$

"Centripetal force" is not a new extra force added to gravity, tension, friction, or the normal force. It is the name for the **net inward component of the real forces** that produces centripetal acceleration.

For a satellite in an ideal circular orbit, gravity itself supplies the required inward net force.

## Examples

### #1: Horizontal Launch

A ball leaves a horizontal table at $3\,\mathrm{m/s}$ and reaches the floor after $0.50$ s. Neglect air resistance.

Horizontal displacement:

$$\Delta x=v_xt=(3)(0.50)=1.5\,\mathrm m.$$

Its initial vertical velocity is zero. The vertical drop magnitude is

$$\Delta y_{\text{down}}=\frac12gt^2=\frac12(9.8)(0.50)^2=1.225\,\mathrm m.$$

So the table height is about $1.23$ m.

### #2: Launch Components

A projectile is launched at $20\,\mathrm{m/s}$, $30^\circ$ above horizontal.

$$v_{x0}=20\cos30^\circ=10\sqrt3\approx17.3\,\mathrm{m/s}$$

$$v_{y0}=20\sin30^\circ=10\,\mathrm{m/s}.$$

### #3: Time to the Highest Point

Using $v_{y0}=10\,\mathrm{m/s}$ and upward as positive:

$$0=v_{y0}-gt=10-9.8t$$

$$t=\frac{10}{9.8}\approx1.02\,\mathrm s.$$

This is time to the top, not automatically half the total flight time unless launch and landing heights are equal in the same ideal model.

### #4: Circular Orbit

A satellite follows a circular orbit at constant speed. Why is it accelerating?

**Solution:**

1. Velocity includes direction.
2. The velocity direction changes continuously around the orbit.
3. Therefore acceleration is nonzero and points inward.
4. Gravity supplies the required centripetal acceleration/net radial force.

### #5: What Supplies Centripetal Force?

A car turns on a level circular road without slipping. What force supplies the horizontal centripetal force?

**Solution:**

Static friction between the tires and road supplies the net inward horizontal force. There is no additional independent "centripetal-force force" acting on top of friction.

## Speed Tricks & Shortcuts

For ideal projectile motion, split the **equations** into $x$ and $y$ components but keep the same $t$ in both.

At the peak: $v_y=0$; $a_y=-g$ is **not** zero.

For circular motion, first identify the center, then identify which actual forces have inward components. Their net radial component must equal $mv^2/r$.

## Traps to Watch For

### #1: Saying Horizontal and Vertical Motion Have Different Times

> Component motions are analyzed separately but describe the same object at the same instants.

The common time variable links the two directions.

### #2: Saying Acceleration Is Zero at a Projectile's Peak

> Only the vertical velocity is momentarily zero.

Gravity still provides downward acceleration $g$.

### #3: Treating Centripetal Force as a Separate Fundamental Force

> "Centripetal" describes the net inward force requirement.

Gravity, tension, friction, normal force, or combinations can supply it.

### #4: Calling Every Projectile Path a Perfect Parabola

> The parabolic result assumes uniform gravity and negligible drag in a flat local coordinate model.

Real trajectories can depart substantially from that approximation.

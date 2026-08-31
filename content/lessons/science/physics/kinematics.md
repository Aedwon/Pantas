---
_id: "lesson-physics-kinematics"
title: "Kinematics"
summary: "How to describe one-dimensional motion using position, displacement, velocity, acceleration, and constant-acceleration equations."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 13
isActive: true
---
## Core Concept

**Kinematics** describes motion without specifying the forces that produce it.

### Position, Displacement, Velocity, and Acceleration

Position $x$ locates an object relative to a chosen origin. **Displacement** is the change in position:

$$\Delta x=x_f-x_i.$$

Displacement is a vector (signed in one dimension). It is not necessarily equal to **distance traveled**, which is the total path length.

Average velocity is

$$v_{\text{avg}}=\frac{\Delta x}{\Delta t},$$

while instantaneous velocity is the rate of change of position at an instant. **Speed** is the magnitude of velocity in one-dimensional motion.

Average acceleration is

$$a_{\text{avg}}=\frac{\Delta v}{\Delta t},$$

and instantaneous acceleration is the rate at which velocity changes.

<!-- FIGURE: {"kind":"physics-mechanics-diagram","type":"accelerated-motion","illustrationKey":"science/physics/kinematics#1","path":"straight road","moments":3,"velocityTrend":"increasing","acceleration":"constant"} -->
### Constant-Acceleration Equations

For **one-dimensional motion with constant acceleration** over the time interval considered:

$$v=v_0+at$$

$$\Delta x=v_0t+\frac12at^2$$

$$v^2=v_0^2+2a\Delta x$$

$$\Delta x=\frac{v_0+v}{2}t.$$

The fourth equation works because, under constant acceleration, average velocity equals $(v_0+v)/2$.

These equations are not general formulas for motion with changing acceleration. When acceleration varies, calculus, graphs, or interval-by-interval methods are needed.

### Free Fall Near Earth's Surface

**Free fall** means motion under gravity alone. Near Earth's surface over modest height changes, the gravitational acceleration magnitude can often be approximated as

$$g\approx9.8\,\mathrm{m/s^2}$$

directed downward.

If upward is positive, $a=-g$. If downward is positive, $a=+g$. The sign convention is a bookkeeping choice; gravity itself points toward Earth.

In the ideal model neglecting air resistance, all freely falling test bodies at the same location have the same gravitational acceleration regardless of mass. Real falling objects in air can accelerate differently because drag and buoyancy depend on shape, speed, density, and other factors.

## Examples

### #1: Final Velocity

A car starts from rest and accelerates uniformly at $4\,\mathrm{m/s^2}$ for $5$ s.

$$v=0+(4)(5)=20\,\mathrm{m/s}.$$

### #2: Displacement Under Constant Acceleration

A ball has $v_0=2\,\mathrm{m/s}$ and constant $a=3\,\mathrm{m/s^2}$ for $4$ s, with all motion remaining in the positive direction.

$$\Delta x=(2)(4)+\frac12(3)(4^2)=8+24=32\,\mathrm m.$$

Because velocity stays positive throughout this interval, distance traveled also happens to be $32$ m. In motion with reversals, distance and displacement would differ.

### #3: Free Fall from Rest

A rock is dropped and falls for $3$ s. Choose downward as positive and use $g=9.8\,\mathrm{m/s^2}$.

$$\Delta y=\frac12gt^2=\frac12(9.8)(3^2)=44.1\,\mathrm m$$

$$v=gt=(9.8)(3)=29.4\,\mathrm{m/s}$$

downward.

### #4: No-Time Equation

A car moving in the positive direction has $v_0=10\,\mathrm{m/s}$, constant $a=2\,\mathrm{m/s^2}$, and displacement $\Delta x=60$ m.

$$v^2=10^2+2(2)(60)=340$$

The equation gives $v=\pm\sqrt{340}$. The physical setup says the car is still moving in the positive direction while accelerating forward, so choose

$$v=+\sqrt{340}\approx18.4\,\mathrm{m/s}.$$

Squaring an equation can hide direction information, so choose the sign from the physics of the problem.

## Speed Tricks & Shortcuts

Before selecting an equation, list $v_0$, $v$, $a$, $t$, and $\Delta x$ and mark what is known. Then choose a constant-acceleration equation containing the needed variables and not the unnecessary unknown.

"Starts from rest" means $v_0=0$ in the chosen frame.

For free fall, choose the positive direction before substituting signs.

Graph facts are useful checks: the slope of a position-time graph is velocity; the slope of a velocity-time graph is acceleration; the signed area under a velocity-time graph is displacement.

## Traps to Watch For

### #1: Using the Four Equations When Acceleration Is Not Constant

> The standard four equations in this lesson require constant acceleration over the interval.

Do not apply them blindly to arbitrary changing acceleration.

### #2: Calling Displacement "How Far"

> Displacement is final position minus initial position; distance is total path length.

They coincide only for motion without reversal along the chosen line.

### #3: Ignoring Sign Conventions

> Velocity, acceleration, and displacement are signed/vector quantities.

A negative result can indicate direction, not an invalid magnitude.

### #4: Saying Heavy Objects Fall Faster in Vacuum

> In the ideal free-fall model at the same location, gravitational acceleration is independent of test-body mass.

Differences seen in air arise from additional forces such as drag and buoyancy.

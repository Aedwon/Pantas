---
_id: "lesson-physics-kinematics"
title: "Kinematics"
summary: "How to describe motion in a straight line using displacement, velocity, and acceleration, and how objects behave in free fall."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 13
isActive: true
---
## Core Concept

**Kinematics** describes how things move, without worrying about why (the forces causing it).

### One-Dimensional Motion (Displacement, Velocity, Acceleration)

**Displacement** ($d$ or $\Delta x$) is the change in position (a vector, with direction). **Velocity** ($v$) is the rate of change of displacement (speed with direction). **Acceleration** ($a$) is the rate of change of velocity: how quickly velocity itself is changing.

Four key kinematic equations connect these quantities for motion with constant acceleration, using initial velocity $v_0$, final velocity $v$, acceleration $a$, time $t$, and displacement $d$:

$$v = v_0 + at$$

$$d = v_0 t + \dfrac{1}{2}at^2$$

$$v^2 = v_0^2 + 2ad$$

$$d = \dfrac{(v_0 + v)}{2} t$$

Each equation uses only $4$ of the $5$ total variables ($v_0, v, a, t, d$), so you can pick whichever equation already contains the values you know and the one you want to find.

<!-- FIGURE: {"kind":"physics-mechanics-diagram","type":"accelerated-motion","illustrationKey":"science/physics/kinematics#1","path":"straight road","moments":3,"velocityTrend":"increasing","acceleration":"constant"} -->

### Free Fall Equations

**Free fall** is motion under the influence of gravity alone (ignoring air resistance). Near Earth's surface, every falling object accelerates downward at the same rate, $g \approx 9.8 \text{ m/s}^2$, regardless of the object's mass. The same four kinematic equations apply directly, just substituting $a = g$ (and being careful with the sign, usually taking "downward" as positive for a falling object, or "upward" as positive with $a = -g$).

## Examples

### #1: Finding Final Velocity

A car starts from rest and accelerates at $4 \text{ m/s}^2$ for $5$ seconds. Find its final velocity.

**Solution:**
Known: $v_0 = 0$, $a = 4$, $t = 5$. Use $v = v_0 + at$.

1. Substitute the known values.

$$v = 0 + (4)(5)$$

2. Compute.

$$v = 20 \text{ m/s}$$

### #2: Finding Displacement

A ball rolls with an initial velocity of $2 \text{ m/s}$ and accelerates at $3 \text{ m/s}^2$ for $4$ seconds. Find how far it travels.

**Solution:**
Known: $v_0 = 2$, $a = 3$, $t = 4$. Use $d = v_0 t + \dfrac{1}{2}at^2$.

1. Substitute the known values.

$$d = (2)(4) + \dfrac{1}{2}(3)(4)^2$$

2. Compute each term: $2 \times 4 = 8$, and $\dfrac{1}{2}(3)(16) = 24$.

$$d = 8 + 24$$

3. Add.

$$d = 32 \text{ m}$$

### #3: Free Fall From Rest

A rock is dropped from a cliff (initial velocity $= 0$) and falls for $3$ seconds before hitting the ground. Find how far it fell, and its velocity just before impact. (Use $g = 9.8 \text{ m/s}^2$.)

**Solution:**
Known: $v_0 = 0$, $a = g = 9.8$, $t = 3$.

1. Find the distance fallen using $d = v_0 t + \dfrac{1}{2}at^2$.

$$d = 0 + \dfrac{1}{2}(9.8)(3)^2$$

2. Compute: $3^2 = 9$, so $\dfrac{1}{2}(9.8)(9) = 44.1$.

$$d = 44.1 \text{ m}$$

3. Find the final velocity using $v = v_0 + at$.

$$v = 0 + (9.8)(3) = 29.4 \text{ m/s}$$

4. The rock fell $44.1$ meters and struck the ground at $29.4 \text{ m/s}$.

### #4: Using the No-Time Equation

A car traveling at $10 \text{ m/s}$ accelerates at $2 \text{ m/s}^2$ over a distance of $60 \text{ m}$. Find its final velocity, without using time.

**Solution:**
Known: $v_0 = 10$, $a = 2$, $d = 60$. Time is not given or asked for, so use $v^2 = v_0^2 + 2ad$.

1. Substitute the known values.

$$v^2 = 10^2 + 2(2)(60)$$

2. Compute: $10^2 = 100$, and $2(2)(60) = 240$.

$$v^2 = 100 + 240 = 340$$

3. Take the square root.

$$v = \sqrt{340} \approx 18.4 \text{ m/s}$$

## Speed Tricks & Shortcuts

Before choosing a kinematic equation, list the four values you know and the one you want to find, from the five possible variables ($v_0, v, a, t, d$). Then pick the equation that is missing exactly the one variable you don't have and don't need: this instantly identifies the correct formula.

For "starts from rest" problems, immediately set $v_0 = 0$, which simplifies every equation (the $v_0 t$ term vanishes, and $v_0^2$ vanishes).

For free fall problems, remember that mass never appears in the equations: a heavy rock and a light pebble (ignoring air resistance) fall with the exact same acceleration and reach the ground at the same time if dropped from the same height together.

## Traps to Watch For

### #1: Picking an Equation That's Missing the Wrong Variable

> Match the equation to what you know and what you want: don't just grab a formula at random.

Using $v = v_0 + at$ when time is not given (and not being asked for) forces you to solve for an unknown you do not need. Always check which variable each equation excludes before selecting one, especially when time is absent from the problem.

### #2: Forgetting That "Starting from Rest" Means Initial Velocity Is Zero

> "Dropped," "starts from rest," or "initially at rest" all mean $v_0 = 0$: do not leave this as an unknown.

Missing this detail forces you to treat $v_0$ as unknown, when the problem has actually told you its value directly through descriptive language rather than a number.

### #3: Ignoring Sign Conventions in Free Fall

> Decide on a positive direction (usually "up" or "down") at the start, and apply that sign consistently to every quantity in the problem.

Mixing a positive initial velocity (thrown upward) with a positive acceleration due to gravity (which should be negative if up is positive, since gravity always pulls down) creates contradictory signs and an incorrect answer. Pick one direction as positive and stick with it throughout the entire problem.

### #4: Assuming Heavier Objects Fall Faster

> In free fall (ignoring air resistance), all objects accelerate at the same rate, $g$, regardless of their mass.

This misconception long predates modern physics. Mass does not appear anywhere in the free fall kinematic equations, confirming that a bowling ball and a tennis ball, dropped together from the same height with no air resistance, hit the ground at exactly the same time.

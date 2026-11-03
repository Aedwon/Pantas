---
_id: "lesson-physics-kinematics"
title: "Kinematics"
summary: "How to describe motion along a straight line with displacement, velocity, and acceleration, read motion graphs, and solve constant-acceleration and free-fall problems."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 15
isActive: true
---
## Core Concept

**Kinematics** describes how things move. It does not ask what forces cause the motion. This lesson covers motion along a straight line.

### Position, Displacement, and Distance

Pick an origin and a positive direction, such as "east is positive." The **position** $x$ of an object is its place on that line, with a sign. A negative position is on the other side of the origin.

**Displacement** is the change in position:

$$\Delta x=x_f-x_i$$

It has a size and a direction. In one dimension the direction is the sign. **Distance** is the total length of the path, and it is never negative. If an object turns around, distance is bigger than the size of the displacement.

### Speed and Velocity

Average velocity is displacement divided by time. Average speed is distance divided by time:

$$v_{\text{avg}}=\dfrac{\Delta x}{\Delta t}\qquad\text{average speed}=\dfrac{\text{distance}}{\Delta t}$$

Velocity has a sign, so it shows direction. Speed has no sign. Instantaneous velocity is the velocity at one moment. Its size is the speed at that moment. The units are meters per second, $\mathrm{m/s}$.

### Acceleration

**Acceleration** is how fast velocity changes:

$$a=\dfrac{\Delta v}{\Delta t}$$

Its unit is $\mathrm{m/s^2}$. If $a$ and $v$ have the same sign, the object speeds up. If they have opposite signs, it slows down. A negative $a$ does not always mean slowing down.

<!-- FIGURE: {"kind":"physics-mechanics-diagram","type":"accelerated-motion","illustrationKey":"science/physics/kinematics#1","path":"straight road","moments":3,"velocityTrend":"increasing","acceleration":"constant"} -->

### Reading Motion Graphs

On a **position-time graph**, the slope is the velocity. A flat line means the object is at rest. A line that slopes downward means negative velocity.

On a **velocity-time graph**, the slope is the acceleration. The **signed area** between the line and the time axis is the displacement. Area above the axis is positive. Area below the axis is negative. When the line crosses the axis, the object turns around.

### Constant-Acceleration Equations

When acceleration is constant, a straight velocity-time line shows it. Then these four equations apply, with signs:

$$v=v_0+at$$

$$\Delta x=v_0t+\dfrac12at^2$$

$$v^2=v_0^2+2a\Delta x$$

$$\Delta x=\dfrac{v_0+v}{2}\,t$$

Here $v_0$ is the starting velocity and $v$ is the final velocity. The last equation works because the average velocity is the middle value of $v_0$ and $v$.

Each equation leaves out one quantity. The first has no $\Delta x$. The second has no $v$. The third has no $t$. The fourth has no $a$. They do not work if the acceleration changes.

### Free Fall

**Free fall** is motion with only gravity acting. Near Earth's surface, the acceleration is $g\approx9.8\,\mathrm{m/s^2}$ toward the ground. This ignores air resistance. All objects then fall with the same acceleration, whatever their mass.

If up is positive, $a=-g$. If down is positive, $a=+g$. The acceleration stays the same on the way up, at the top, and on the way down.

## Examples

"Calculate" and "find" mean get a number answer. "Uniformly" means with constant acceleration.

### #1: Distance, Displacement, Speed, and Velocity

A runner goes $40$ m east and then $10$ m back west. The whole run takes $20$ s. East is positive. Calculate the distance, the displacement, the average speed, and the average velocity.

**Solution:**

1. Distance: $40+10=50$ m.
2. Displacement: $x_f-x_i=+30$ m, so $30$ m east.
3. Average speed: $\dfrac{50}{20}=2.5\,\mathrm{m/s}$.
4. Average velocity: $\dfrac{+30}{20}=+1.5\,\mathrm{m/s}$, east.

### #2: Braking to a Stop

A car moves east at $20\,\mathrm{m/s}$. It brakes uniformly to rest in $4$ s. Find its acceleration and its stopping distance.

**Solution:**

1. Acceleration:

$$a=\dfrac{0-20}{4}=-5\,\mathrm{m/s^2}$$

2. The sign is negative because the car slows while moving in the positive direction.
3. Distance, using the average velocity:

$$\Delta x=\dfrac{20+0}{2}(4)=40\text{ m}$$

4. Check with $v^2=v_0^2+2a\Delta x$: $0=400+2(-5)\Delta x$, so $\Delta x=40$ m.

### #3: Starting from Rest

A car starts from rest and accelerates uniformly at $4\,\mathrm{m/s^2}$ for $5$ s. Find its final velocity and its displacement.

**Solution:**

1. "From rest" means $v_0=0$.
2. Velocity: $v=0+(4)(5)=20\,\mathrm{m/s}$.
3. Displacement:

$$\Delta x=0+\dfrac12(4)(5^2)=50\text{ m}$$

### #4: Starting with a Velocity

A ball has $v_0=2\,\mathrm{m/s}$ and a constant $a=3\,\mathrm{m/s^2}$ for $4$ s. All the motion stays in the positive direction. Find the displacement.

**Solution:**

$$\Delta x=(2)(4)+\dfrac12(3)(4^2)=8+24=32\text{ m}$$

Velocity never changes sign, so the distance is also $32$ m.

### #5: The Equation Without Time

A car moving in the positive direction has $v_0=10\,\mathrm{m/s}$ and $a=2\,\mathrm{m/s^2}$. It travels $\Delta x=60$ m. Find its final velocity.

**Solution:**

1. Time is not given, so use the third equation:

$$v^2=10^2+2(2)(60)=340$$

2. Taking the square root gives $v=\pm18.4\,\mathrm{m/s}$.
3. The car speeds up in the positive direction, so $v=+18.4\,\mathrm{m/s}$.

### #6: Dropped Object

A rock is dropped and falls for $3$ s. Down is positive and $g=9.8\,\mathrm{m/s^2}$. Find the distance fallen and the final velocity.

**Solution:**

1. Distance:

$$\Delta y=\dfrac12(9.8)(3^2)=44.1\text{ m}$$

2. Velocity:

$$v=0+(9.8)(3)=29.4\,\mathrm{m/s}$$

The rock moves downward.

### #7: Thrown Upward

A ball is thrown straight up at $19.6\,\mathrm{m/s}$. Up is positive and $g=9.8\,\mathrm{m/s^2}$. Find the time to the top, the greatest height, and the velocity when the ball returns to its starting level.

**Solution:**

1. Here $a=-9.8\,\mathrm{m/s^2}$. At the top, $v=0$.
2. Time to the top:

$$t=\dfrac{0-19.6}{-9.8}=2.0\text{ s}$$

3. Greatest height:

$$\Delta y=\dfrac{19.6+0}{2}(2.0)=19.6\text{ m}$$

4. At the starting level, $\Delta y=0$, so $v^2=19.6^2$. The ball is moving down, so $v=-19.6\,\mathrm{m/s}$.

### #8: Velocity-Time Graph, Slope and Area

A velocity-time graph is a straight line from $0\,\mathrm{m/s}$ at $0$ s to $8\,\mathrm{m/s}$ at $4$ s. It stays at $8\,\mathrm{m/s}$ until $10$ s. Then it falls in a straight line to $0\,\mathrm{m/s}$ at $12$ s. Find the acceleration in each part and the total displacement.

<!-- ILLUSTRATION: velocity-time graph, time axis 0 to 12 s, velocity axis 0 to 8 m/s; straight line from (0, 0) to (4, 8), flat to (10, 8), straight down to (12, 0) -->

**Solution:**

1. From $0$ to $4$ s: slope $=\dfrac{8-0}{4}=2\,\mathrm{m/s^2}$.
2. From $4$ to $10$ s: the line is flat, so $a=0$.
3. From $10$ to $12$ s: slope $=\dfrac{0-8}{2}=-4\,\mathrm{m/s^2}$.
4. The area is a triangle, a rectangle, and a triangle:

$$\dfrac12(4)(8)+(6)(8)+\dfrac12(2)(8)=16+48+8=72\text{ m}$$

### #9: Velocity-Time Graph with a Reversal

A velocity-time graph is one straight line from $+6\,\mathrm{m/s}$ at $0$ s to $-6\,\mathrm{m/s}$ at $6$ s. Find the acceleration, the time of the turnaround, the displacement, and the distance.

<!-- ILLUSTRATION: velocity-time graph, time axis 0 to 6 s, velocity axis -6 to +6 m/s; one straight line from (0, +6) down through (3, 0) to (6, -6); the triangle above the axis shaded +9 m and the triangle below shaded -9 m -->

**Solution:**

1. Acceleration:

$$a=\dfrac{-6-6}{6}=-2\,\mathrm{m/s^2}$$

2. The line crosses zero at $t=3$ s. That is the turnaround.
3. Area above the axis: $\dfrac12(3)(6)=+9$ m. Area below: $-9$ m.
4. Displacement: $+9+(-9)=0$ m. The object is back at its start.
5. Distance: $9+9=18$ m.

### #10: Position-Time Graph

A position-time graph is a straight line from $0$ m at $0$ s to $8$ m at $4$ s. It is flat from $4$ s to $6$ s. Then it falls in a straight line to $0$ m at $10$ s. Find the velocity in each part and the average velocity for the whole $10$ s.

<!-- ILLUSTRATION: position-time graph, time axis 0 to 10 s, position axis 0 to 8 m; straight line from (0, 0) to (4, 8), flat to (6, 8), straight down to (10, 0) -->

**Solution:**

1. From $0$ to $4$ s: slope $=\dfrac{8-0}{4}=+2\,\mathrm{m/s}$.
2. From $4$ to $6$ s: flat, so $v=0$. The object is at rest.
3. From $6$ to $10$ s: slope $=\dfrac{0-8}{4}=-2\,\mathrm{m/s}$.
4. The object starts and ends at $0$ m, so $\Delta x=0$ and $v_{\text{avg}}=0$.

## Speed Tricks & Shortcuts

Before you pick an equation, list $v_0$, $v$, $a$, $t$, and $\Delta x$. Mark which are known and which you want. Pick the equation that has these and leaves out the missing one.

Words in the problem give hidden values. "Starts from rest" means $v_0=0$. "Comes to a stop" means $v=0$. At the top of a throw, $v=0$.

Choose the positive direction first, then write every sign.

For a straight-line velocity graph, area is often a triangle, rectangle, or trapezoid. Add the signed areas.

## Traps to Watch For

### #1: Using the Equations When Acceleration Changes

> The four equations need constant acceleration.

If the velocity-time graph is curved, the acceleration is changing and the equations do not apply.

### #2: Mixing Up Distance and Displacement

> Displacement is final position minus initial position. Distance is the path length.

They are equal only when the object never turns around.

### #3: Zero Velocity Means Zero Acceleration

> At the top of a throw, $v=0$ but $a=-9.8\,\mathrm{m/s^2}$.

The velocity is changing at that instant, so the acceleration is not zero.

### #4: Negative Acceleration Always Means Slowing Down

> Compare the signs of $v$ and $a$.

If $v$ is negative and $a$ is negative, the object speeds up in the negative direction.

### #5: Ignoring Signs

> A negative answer can be correct. It shows direction.

Choose the positive direction first and keep it for the whole problem.

### #6: Heavier Objects Fall Faster

> Without air resistance, every object falls with the same acceleration.

In air, drag changes the motion. A feather falls slowly because of air, not because it is light.

---
_id: "lesson-physics-two-dimensional-motion"
title: "Two-Dimensional Motion (Projectile Motion, Uniform Circular Motion)"
summary: "How ideal projectile motion splits into horizontal and vertical parts, and how angular speed and an inward net force describe motion in a circle."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 14
isActive: true
---
## Core Concept

### Ideal Projectile Motion

A **projectile** is an object that moves through the air after launch with only gravity acting on it. The usual school model also ignores air resistance (the drag of air on the object). It treats $g$ as the same everywhere along the path.

Use $g=9.8\,\mathrm{m/s^2}$. This lesson calls this the **ideal model**.

Choose $x$ as the horizontal direction and $y$ as upward. Gravity pulls straight down, so it has no horizontal part:

$$a_x=0,\qquad a_y=-g.$$

The minus sign only means "downward", because upward is positive.

Because of this, the horizontal and vertical motions can be solved separately. They are linked by one thing: the **same time** $t$ is used in both. The ball is at one place at one moment.

Let the launch point be $(x_0,y_0)$ and the launch velocity have components $v_{x0}$ and $v_{y0}$. A **component** is the part of a velocity along one axis. Then:

$$x=x_0+v_{x0}t$$

$$y=y_0+v_{y0}t-\dfrac12gt^2$$

$$v_x=v_{x0},\qquad v_y=v_{y0}-gt.$$

Suppose the launch speed is $v_0$ at angle $\theta$ above the horizontal. Then, from a right triangle:

$$v_{x0}=v_0\cos\theta,\qquad v_{y0}=v_0\sin\theta.$$

For a horizontal launch, $\theta=0^\circ$. So $v_{y0}=0$ and $v_{x0}=v_0$.

<!-- FIGURE: {"kind": "concept-diagram", "type": "vector-components", "magnitude": 20, "angle": 30, "unit": "m/s", "components": {"horizontal": "20 cos 30°", "vertical": "20 sin 30°"}, "semanticsLabel": "A 20 m/s launch velocity vector at 30 degrees resolved into horizontal and vertical components as a right triangle."} -->

In the ideal model, three things follow:

- The horizontal velocity stays constant. With air resistance it would slowly drop.
- The vertical motion is the same as free fall. The time to fall does not depend on the horizontal speed. A ball rolled off a table and a ball dropped from the same height land at the same time.
- Removing $t$ from the two position equations gives a **parabola**. With air resistance, the real path is not a parabola.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "projectile-motion", "path": "parabola", "velocityVectors": true, "semanticsLabel": "A parabolic projectile path showing constant horizontal velocity arrows and vertical velocity shrinking at the peak."} -->

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

### Uniform Circular Motion

**Uniform circular motion** is motion around a circle of radius $r$ at constant speed $v$. The speed does not change, but the direction does. Velocity includes direction, so the velocity changes. That means the object accelerates.

This acceleration points toward the center of the circle. It is called **centripetal acceleration**, and its size is

$$a_c=\dfrac{v^2}{r}.$$

A bigger speed or a smaller circle means a larger $a_c$.

By Newton's second law, a net force must cause this acceleration. The net force toward the center is

$$F_{\text{net, inward}}=ma_c=\dfrac{mv^2}{r}.$$

"Centripetal force" is not a new force added to the list of forces. It is the name for the net inward force from the real forces. These can be gravity, tension in a string, friction, the normal force, or a mix.

When you solve, first find the center. Then add up the parts of the real forces that point toward the center. That sum equals $mv^2/r$. Do not draw an extra arrow labeled "centripetal force" on a force diagram.

Without an inward net force, the object would not turn. It would move in a straight line along the tangent, the line touching the circle where the object is.

For a satellite in an ideal circular orbit, gravity is the only force, so gravity supplies the inward net force.

<!-- FIGURE: {"kind": "concept-diagram", "type": "circular-orbit", "body": "Earth", "orbiting": "Satellite", "vectors": {"velocity": "Tangent velocity (v)", "acceleration": "Centripetal acceleration (ac)"}, "semanticsLabel": "A satellite in circular orbit around Earth with a tangent velocity arrow and an inward centripetal acceleration arrow."} -->

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

### #1: Launch Components

A projectile is launched at $20\,\mathrm{m/s}$, $30^\circ$ above the horizontal. Find the horizontal and vertical components of the launch velocity.

**Solution:**

1. Horizontal component:

$$v_{x0}=20\cos30^\circ=10\sqrt3\approx17.3\,\mathrm{m/s}.$$

2. Vertical component:

$$v_{y0}=20\sin30^\circ=10\,\mathrm{m/s}.$$

### #2: Horizontal Launch

A ball leaves a horizontal table at $3\,\mathrm{m/s}$ and reaches the floor after $0.50$ s. Neglect air resistance. How far from the table edge does it land, and how high is the table?

**Solution:**

1. The horizontal velocity stays at $3\,\mathrm{m/s}$:

$$\Delta x=v_xt=(3)(0.50)=1.5\,\mathrm m.$$

2. The ball leaves horizontally, so its starting vertical velocity is zero. The drop is

$$\Delta y_{\text{down}}=\dfrac12gt^2=\dfrac12(9.8)(0.50)^2=1.225\,\mathrm m.$$

3. The ball lands $1.5$ m from the edge, and the table is about $1.23$ m high.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "horizontal-projectile", "initialVelocity": "3 m/s", "labels": {"height": "?", "distance": "?"}, "semanticsLabel": "A ball rolling off a table at 3 m/s following a curved path to the floor with height and distance marked with question marks."} -->

### #3: Time, Height, and Range on Level Ground

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

### #4: Landing Below the Launch Point

A ball is thrown from the top of a $15$ m cliff at $10\,\mathrm{m/s}$, $30^\circ$ above the horizontal. Neglect air resistance. How far from the base of the cliff does it land?

**Solution:**

1. Components:

$$v_{x0}=10\cos30^\circ\approx8.66\,\mathrm{m/s},\qquad v_{y0}=10\sin30^\circ=5.0\,\mathrm{m/s}.$$

2. Put the origin at the base of the cliff, so $y_0=15$ m. The ball lands when $y=0$:

$$0=15+5.0t-4.9t^2.$$

3. Write it as $4.9t^2-5.0t-15=0$ and use the quadratic formula. Keep the positive root:

$$t=\dfrac{5.0+\sqrt{25+294}}{9.8}\approx2.33\,\mathrm s.$$

4. Horizontal distance:

$$x=v_{x0}t=(8.66)(2.33)\approx20.2\,\mathrm m.$$

The level-ground range formula would give only about $8.8$ m here. It does not apply, because the ball lands lower than it was launched.

<!-- ILLUSTRATION: side view of a 15 m cliff with a ball launched from the top at 10 m/s, 30° above horizontal, a parabola landing on the ground at x = ? from the cliff base, with the dashed launch-height line above the landing point -->

### #5: Period, Angular Speed, and Centripetal Acceleration

A rider sits $3.0$ m from the center of a merry-go-round that makes one full turn every $4.0$ s. Find the angular speed, the rider's speed, and the rider's centripetal acceleration.

**Solution:**

1. Angular speed, with $T=4.0$ s:

$$\omega=\dfrac{2\pi}{T}=\dfrac{2\pi}{4.0}\approx1.57\,\mathrm{rad/s}.$$

2. Speed:

$$v=\omega r=(1.57)(3.0)\approx4.71\,\mathrm{m/s}.$$

3. Centripetal acceleration:

$$a_c=\omega^2r=(1.57)^2(3.0)\approx7.4\,\mathrm{m/s^2}.$$

Check: $v^2/r=\dfrac{(4.71)^2}{3.0}\approx7.4\,\mathrm{m/s^2}$. It matches.

### #6: Two Riders on the Same Platform

A platform turns at $12$ rpm. Rider A sits $2.0$ m from the axis and rider B sits $4.0$ m from it. Compare their angular speeds and speeds.

**Solution:**

1. Change rpm to rad/s:

$$\omega=\dfrac{2\pi(12)}{60}\approx1.26\,\mathrm{rad/s}.$$

2. Both riders are on the same rigid platform, so both have this $\omega$.

3. Speeds:

$$v_A=\omega r_A=(1.26)(2.0)\approx2.5\,\mathrm{m/s}$$

$$v_B=\omega r_B=(1.26)(4.0)\approx5.0\,\mathrm{m/s}.$$

The angular speeds are equal. Rider B moves twice as fast because B is twice as far from the axis.

### #7: Tension Supplies the Inward Force

A $0.50$ kg ball on a string moves in a horizontal circle of radius $0.80$ m on a frictionless table at a steady $4.0\,\mathrm{m/s}$. Find the tension in the string.

**Solution:**

1. Gravity and the normal force are vertical and cancel. The only horizontal force is the string tension, and it points toward the center.

2. So the tension is the net inward force:

$$F_T=\dfrac{mv^2}{r}=\dfrac{(0.50)(4.0)^2}{0.80}=10\,\mathrm N.$$

<!-- ILLUSTRATION: top view of a $0.50$ kg ball moving counterclockwise on a circle of radius $0.80$ m at $4.0$ m/s, with a tangent velocity arrow and a tension arrow along the string toward the center -->

### #8: Friction Supplies the Inward Force

A $1000$ kg car turns on a level circular road of radius $50$ m at a steady $15\,\mathrm{m/s}$. What static friction force is needed so the car does not slip? What is the least coefficient of static friction $\mu_s$ that allows it?

**Solution:**

1. On a level road, the only horizontal force on the car is static friction from the road, pointing toward the center. It is the net inward force:

$$f=\dfrac{mv^2}{r}=\dfrac{(1000)(15)^2}{50}=4500\,\mathrm N.$$

2. The largest static friction is $\mu_sN$. On a level road, $N=mg$. The needed friction must not be larger than this:

$$\mu_s\ge\dfrac{f}{mg}=\dfrac{4500}{(1000)(9.8)}\approx0.46.$$

The car's mass cancels in $\mu_s\ge\dfrac{v^2}{rg}$, so the result is the same for any mass.

### #9: Why Does Constant Speed Mean Acceleration?

A satellite follows a circular orbit at constant speed. Why is it accelerating, and what supplies the force?

**Solution:**

1. Velocity includes direction.
2. The direction changes continuously around the orbit, so the velocity changes.
3. A changing velocity is an acceleration, and it points toward the center.
4. Gravity from Earth is the only force on the satellite in the ideal case. It supplies the net inward force.

## Speed Tricks & Shortcuts

In the ideal model, solve the $x$ part and the $y$ part separately, and use the same $t$ in both. Find $t$ from the vertical part first when the vertical motion is easier, then use it for $x$.

For a launch at a level start and end, the time to the top is half the flight time. Use it only when launch and landing heights are equal.

At the highest point of a rising-then-falling projectile, $v_y=0$ but $a_y=-g$.

For circular motion, find the center, then find which real forces have a part toward the center. Their sum equals $mv^2/r$, which is also $m\omega^2r$.

To change units to radians per second, use $2\pi$ rad per turn. Divide by $60$ when the rate is per minute.

## Traps to Watch For

### #1: Giving the Two Directions Different Times

> The horizontal and vertical motions share one time.

They describe the same object at the same moments. The time found from the vertical motion is the time to use for the horizontal distance.

### #2: Saying Acceleration Is Zero at the Peak

> At the top, only the vertical velocity is zero.

Gravity still gives $a_y=-g$. Also, the speed at the top is not zero unless the horizontal velocity is zero.

### #3: Using the Level-Ground Formulas Anywhere

> $R=\dfrac{v_0^2\sin2\theta}{g}$ and "$45^\circ$ gives the longest range" need equal launch and landing heights and no air resistance.

If the ball lands lower, as in #4, use the basic equations. For a launch from a height onto lower ground, the angle for the longest range is a bit less than $45^\circ$.

### #4: Treating Centripetal Force as a Separate Force

> "Centripetal" names the job of the net inward force. It is not another force to add.

Tension, friction, gravity, the normal force, or a mix can do that job. Count the real forces only.

### #5: Thinking an Outward Force Pushes the Object

> In uniform circular motion, the net force points inward, never outward.

A passenger in a turning car seems pushed outward. Seen from the ground, the passenger's body tends to keep going straight while the car turns. If the string breaks, the ball moves off along the tangent, not outward along the radius.

### #6: Using Degrees in $v=\omega r$

> $\omega$ must be in rad/s for $v=\omega r$ to work.

Change revolutions per minute or degrees per second to rad/s first. Also do not mix up $\omega$ with $v$: all points of a spinning wheel share $\omega$, but each has its own $v$.

### #7: Assuming Real Paths Are Perfect Parabolas

> The parabola comes from the ideal model.

Air resistance, wind, or a very long flight can make the real path differ clearly from a parabola.

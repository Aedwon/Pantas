---
_id: "lesson-physics-two-dimensional-motion"
title: "Two-Dimensional Motion (Projectile Motion, Uniform Circular Motion)"
summary: "How to analyze projectile motion by splitting it into horizontal and vertical parts, and the basics of circular motion."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 12
isActive: true
---
## Core Concept

### Projectile Motion

A **projectile** is any object launched into the air and then moving under gravity alone (ignoring air resistance), like a thrown ball or a launched cannonball. The key insight: horizontal and vertical motion happen independently of each other, and can be analyzed separately.

**Horizontally**: No acceleration acts (ignoring air resistance), so horizontal velocity stays constant throughout the flight.

$$x = v_x t$$

**Vertically**: gravity acts exactly like free fall, constantly accelerating the projectile downward at $g \approx 9.8 \text{ m/s}^2$.

$$v_y = v_{y0} - gt \qquad y = v_{y0}t - \dfrac{1}{2}gt^2$$

<!-- ILLUSTRATION: parabolic path of a projectile launched at an angle, with the horizontal velocity component shown as constant-length arrows at several points along the path, and the vertical velocity component shown shrinking to zero at the peak then growing downward -->

For a projectile launched at an angle $\theta$ with initial speed $v_0$, split the initial velocity into components first:

$$v_{x0} = v_0 \cos\theta \qquad v_{y0} = v_0 \sin\theta$$

The horizontal component stays constant the whole flight; only the vertical component changes due to gravity. At the very top of the projectile's path, the vertical velocity is momentarily zero (though the horizontal velocity is still moving).

### Uniform Circular Motion

An object moving in a circle at constant speed undergoes **uniform circular motion**. Even though its speed never changes, its velocity is constantly changing, because velocity is a vector and the direction keeps changing as the object curves around the circle.

This constantly changing direction means the object is accelerating, even at constant speed. This acceleration points toward the center of the circle (called **centripetal acceleration**), which is why an unbalanced force (called **centripetal force**) must also point toward the center to keep the object moving in a circle rather than flying off in a straight line.

## Examples

### #1: Horizontal Launch

A ball rolls off a table with a horizontal velocity of $3 \text{ m/s}$ and takes $0.5$ seconds to hit the floor. Find the horizontal distance it travels, and the height of the table (use $g = 9.8 \text{ m/s}^2$).

<!-- ILLUSTRATION: a ball leaving a table edge horizontally at 3 m/s, following a curved projectile path to the floor, with the table height and horizontal distance both marked "?" -->


**Solution:**
Handle horizontal and vertical motion completely separately.

1. Horizontal distance (constant velocity, no horizontal acceleration).

$$x = v_x t = (3)(0.5) = 1.5 \text{ m}$$

2. Vertical distance (starts with $v_{y0} = 0$, since the ball rolls off horizontally).

$$y = \dfrac{1}{2}gt^2 = \dfrac{1}{2}(9.8)(0.5)^2$$

3. Compute: $(0.5)^2 = 0.25$, so $\dfrac{1}{2}(9.8)(0.25) = 1.225$.

$$y = 1.225 \text{ m}$$

4. The ball travels $1.5 \text{ m}$ horizontally, and the table is $1.225 \text{ m}$ tall.

### #2: Launched at an Angle

A projectile is launched at $20 \text{ m/s}$ at an angle of $30°$ above the horizontal. Find its initial horizontal and vertical velocity components.

<!-- ILLUSTRATION: a 20 m/s launch velocity vector at 30° above the horizontal, resolved into its horizontal component (20cos30°) and vertical component (20sin30°) as a right triangle -->


**Solution:**
Split the launch velocity into components using the angle.

1. Horizontal component.

$$v_{x0} = 20 \cos 30° = 20 \times \dfrac{\sqrt{3}}{2} = 10\sqrt{3} \text{ m/s} \approx 17.3 \text{ m/s}$$

2. Vertical component.

$$v_{y0} = 20 \sin 30° = 20 \times \dfrac{1}{2} = 10 \text{ m/s}$$

### #3: Time to Reach Maximum Height

Using the projectile from Example 2 (initial vertical velocity $10 \text{ m/s}$), find how long it takes to reach its highest point. (Use $g = 9.8 \text{ m/s}^2$.)

**Solution:**
At maximum height, the vertical velocity is momentarily zero.

1. Set $v_y = 0$ in the vertical velocity equation $v_y = v_{y0} - gt$.

$$0 = 10 - 9.8t$$

2. Solve for $t$.

$$9.8t = 10$$

$$t = \dfrac{10}{9.8} \approx 1.02 \text{ s}$$

### #4: Uniform Circular Motion Concept

A satellite moves at a constant speed in a perfectly circular orbit around Earth. Explain why the satellite is still considered to be accelerating, even though its speed never changes.

<!-- ILLUSTRATION: a satellite in a circular orbit around Earth with its velocity arrow tangent to the circle and a centripetal acceleration arrow pointing inward toward Earth, showing the direction keeps changing -->


**Solution:**
Recall the vector definition of velocity and acceleration.

1. Velocity is a vector: it has both magnitude (speed) and direction.
2. Even though the satellite's speed stays constant, its direction is constantly changing as it curves around the circular path.
3. Since velocity is changing (due to the changing direction, even with constant speed), the satellite is accelerating.
4. This acceleration points toward the center of the circular orbit (centripetal acceleration), which is why a centripetal force (in this case, gravity) must continuously act toward Earth's center to maintain the circular path.

## Speed Tricks & Shortcuts

For any projectile problem, immediately split it into two separate, simpler problems: a horizontal, constant-velocity problem, and a vertical, free-fall problem. Solve each independently, then combine results only at the very end if needed.

At a projectile's peak height, remember one fact instantly: vertical velocity equals zero (though horizontal velocity is unchanged and nonzero, assuming the launch had a horizontal component).

For circular motion, remember the phrase "constant speed, changing direction, means accelerating." This single idea resolves most conceptual circular motion questions without needing any calculation.

## Traps to Watch For

### #1: Applying Gravity to Horizontal Motion

> Gravity affects only the vertical component of a projectile's motion — horizontal velocity stays constant throughout the flight (ignoring air resistance).

A common mistake tries to apply the free-fall acceleration formula to the horizontal distance calculation. Horizontal motion has no acceleration in ideal projectile motion; only $x = v_x t$ applies there, never a $\dfrac{1}{2}at^2$ term.

### #2: Believing Circular Motion at Constant Speed Means No Acceleration

> Constant speed does not mean constant velocity, and only constant velocity (unchanging in both magnitude and direction) would mean zero acceleration.

Students sometimes think "constant speed" automatically implies "no acceleration," forgetting that acceleration depends on velocity (a vector), and direction is constantly changing in circular motion, producing a real, nonzero (centripetal) acceleration.

### #3: Forgetting to Resolve the Launch Angle Before Using Kinematic Equations

> Before applying any projectile equation, first split the initial velocity into its horizontal and vertical components using $\cos\theta$ and $\sin\theta$.

Plugging the full launch speed $v_0$ directly into the horizontal or vertical equations (without first finding $v_{x0}$ and $v_{y0}$ separately) produces an incorrect answer, since only the correct component belongs in each direction's equation.

### #4: Mixing Up Which Trig Function Gives Which Component

> When the launch angle is measured from the horizontal, cosine gives the horizontal component and sine gives the vertical component.

Reversing these (using sine for horizontal and cosine for vertical) swaps the two components, producing a projectile that behaves as though it were launched at a very different angle than intended. Always double-check which side of the angle each trig function corresponds to.

---
_id: "lesson-physics-launch-components-and-the-ideal-projectile-model"
title: "Launch Components and the Ideal Projectile Model"
summary: "Resolve launch velocity and describe an ideal projectile path."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 1
partCount: 7
ordering: 21
keyPoints:
  - "Resolve the launch velocity into horizontal and vertical components."
  - "Identify the conditions and path of ideal projectile motion."
---
## Core Concept

### Ideal Projectile Motion

A **projectile** is an object that moves through the air after launch with only gravity acting on it. The usual school model also ignores air resistance (the drag of air on the object). It treats $g$ as the same everywhere along the path.

Use $g=9.8\,\mathrm{m/s^2}$. This lesson calls this the **ideal model**.

Choose $x$ as the horizontal direction and $y$ as upward. Gravity pulls straight down, so it has no horizontal part:

$$a_x=0,\qquad a_y=-g.$$

The minus sign only means "downward", because upward is positive.

Suppose the launch speed is $v_0$ at angle $\theta$ above the horizontal. Then, from a right triangle:

$$v_{x0}=v_0\cos\theta,\qquad v_{y0}=v_0\sin\theta.$$

For a horizontal launch, $\theta=0^\circ$. So $v_{y0}=0$ and $v_{x0}=v_0$.

<!-- FIGURE: {"kind": "concept-diagram", "type": "vector-components", "magnitude": 20, "angle": 30, "unit": "m/s", "components": {"horizontal": "v_x0", "vertical": "v_y0"}, "semanticsLabel": "A 20 m/s launch velocity vector at 30 degrees resolved into horizontal and vertical components as a right triangle."} -->

In the ideal model, three things follow:

- The horizontal velocity stays constant. With air resistance it would slowly drop.
- The vertical motion is the same as free fall. The time to fall does not depend on the horizontal speed. A ball rolled off a table and a ball dropped from the same height land at the same time.
- Removing $t$ from the two position equations gives a **parabola**, when $v_{x0}\ne0$. If $v_{x0}=0$, such as a ball dropped or thrown straight up, the path is a vertical straight line. With air resistance, the real path is not a parabola.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "projectile-motion", "path": "parabola", "velocityVectors": true, "semanticsLabel": "A parabolic projectile path showing constant horizontal velocity arrows and vertical velocity shrinking at the peak."} -->

## Examples

### #1: Launch Components

A projectile is launched at $20\,\mathrm{m/s}$, $30^\circ$ above the horizontal. Find the horizontal and vertical components of the launch velocity.

**Solution:**

1. Horizontal component:

$$v_{x0}=20\cos30^\circ=10\sqrt3\approx17.3\,\mathrm{m/s}.$$

2. Vertical component:

$$v_{y0}=20\sin30^\circ=10\,\mathrm{m/s}.$$

## Traps to Watch For

### #1: Assuming Real Paths Are Perfect Parabolas

> The parabola comes from the ideal model.

Air resistance, wind, or a very long flight can make the real path differ clearly from a parabola.

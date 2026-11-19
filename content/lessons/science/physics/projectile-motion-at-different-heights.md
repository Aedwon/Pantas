---
_id: "lesson-physics-projectile-motion-at-different-heights"
title: "Projectile Motion at Different Heights"
summary: "Use the same time in both axes to solve for a projectile’s landing point."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 2
partCount: 7
ordering: 22
keyPoints:
  - "Use vertical motion to find the time to land."
  - "Use horizontal motion to find the landing distance."
---
## Core Concept

In the ideal model, gravity changes only the vertical velocity. So the horizontal and vertical motions can be solved separately. They are linked by one thing: the **same time** $t$ is used in both. The ball is at one place at one moment.

Let the launch point be $(x_0,y_0)$ and the launch velocity have components $v_{x0}$ and $v_{y0}$. A **component** is the part of a velocity along one axis. Then:

$$x=x_0+v_{x0}t$$

$$y=y_0+v_{y0}t-\dfrac12gt^2$$

$$v_x=v_{x0},\qquad v_y=v_{y0}-gt.$$

If the landing-time equation has the form $at^2+bt+c=0$ with $a\ne0$, use the quadratic formula:

$$t=\dfrac{-b\pm\sqrt{b^2-4ac}}{2a}$$

## Examples

### #1: Horizontal Launch

A ball leaves a horizontal table at $3\,\mathrm{m/s}$ and reaches the floor after $0.50$ s. Neglect air resistance. How far from the table edge does it land, and how high is the table?

**Solution:**

1. The horizontal velocity stays at $3\,\mathrm{m/s}$:

$$\Delta x=v_xt=(3)(0.50)=1.5\,\mathrm m.$$

2. The ball leaves horizontally, so its starting vertical velocity is zero. The drop is

$$\Delta y_{\text{down}}=\dfrac12gt^2=\dfrac12(9.8)(0.50)^2=1.225\,\mathrm m.$$

3. The ball lands $1.5$ m from the edge, and the table is about $1.23$ m high.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "horizontal-projectile", "initialVelocity": "3 m/s", "labels": {"height": "?", "distance": "?"}, "semanticsLabel": "A ball rolling off a table at 3 m/s following a curved path to the floor with height and distance marked with question marks."} -->

### #2: Landing Below the Launch Point

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

## Speed Tricks & Shortcuts

In the ideal model, solve the $x$ part and the $y$ part separately, and use the same $t$ in both. Find $t$ from the vertical part first when the vertical motion is easier, then use it for $x$.

## Traps to Watch For

### #1: Giving the Two Directions Different Times

> The horizontal and vertical motions share one time.

They describe the same object at the same moments. The time found from the vertical motion is the time to use for the horizontal distance.

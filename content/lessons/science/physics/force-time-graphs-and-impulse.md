---
_id: "lesson-physics-force-time-graphs-and-impulse"
title: "Force-Time Graphs and Impulse"
summary: "Use signed area on a force-time graph to find impulse."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 3
partCount: 7
ordering: 0
keyPoints:
  - "Find impulse from signed area under a force-time graph."
---
## Core Concept

<!-- FIGURE: {"kind":"physics-mechanics-diagram","type":"impulse-duration","illustrationKey":"science/physics/momentum-and-impulse#1","impulse":"same","cases":[{"surface":"hard surface","force":"large","time":"very short"},{"surface":"airbag","force":"smaller","time":"longer"}]} -->
### Impulse From a Force-Time Graph

Often the force changes while it acts. Then plot force $F$ on the vertical axis and time $t$ on the horizontal axis.

For a constant force, the graph is a flat line. The area of the rectangle under it is $F\Delta t$. That is the impulse.

The same idea holds for any shape. **The impulse is the area between the force-time curve and the time axis.** Split a straight-sided shape into rectangles and triangles. Add their areas.

Area above the axis counts as positive impulse. Area below the axis counts as negative impulse, because the force points the other way.

Calculus writes this area as an integral:

$$\vec J=\int_{t_i}^{t_f}\vec F(t)\,dt$$

You do not need calculus to find an area from a straight-sided graph.

## Examples

### #1: Impulse From a Variable Force

A force along a straight line acts on an $8.0\,\mathrm{kg}$ cart that starts at rest on a level track with negligible friction. The force rises steadily from $0$ to $10\,\mathrm N$ in the first $2.0\,\mathrm s$. Then it stays at $10\,\mathrm N$ for the next $3.0\,\mathrm s$. Find the final speed of the cart at $5.0\,\mathrm s$.

<!-- ILLUSTRATION: force-time graph for the cart, time in s from $0$ to $5.0$, force in N from $0$ to $10$; a straight line from $(0,0)$ to $(2.0,10)$, then a flat line at $10\,\mathrm N$ to $t=5.0\,\mathrm s$; the triangle is labeled $J_1=10\,\mathrm{N\,s}$ and the rectangle is labeled $J_2=30\,\mathrm{N\,s}$ -->

**Solution:**

1. The first part is a triangle with base $2.0\,\mathrm s$ and height $10\,\mathrm N$:

$$J_1=\dfrac{1}{2}(2.0)(10)=10\,\mathrm{N\,s}$$

2. The second part is a rectangle:

$$J_2=(10)(3.0)=30\,\mathrm{N\,s}$$

3. Add the areas:

$$J=J_1+J_2=40\,\mathrm{N\,s}$$

4. The cart starts at rest, so $J=mv_f-0$:

$$v_f=\dfrac{J}{m}=\dfrac{40}{8.0}=5.0\,\mathrm{m/s}$$

## Speed Tricks & Shortcuts

For impulse from a graph, find the area. Rectangle: base times height. Triangle: $\dfrac{1}{2}$ times base times height. Count area under the axis as negative.

## Traps to Watch For

### #1: Using $F\Delta t$ With a Changing Force

> The impulse is $F\Delta t$ only when $F$ is constant or is the average force.

If the force changes, a peak value times the time gives the wrong impulse. Use the area under the graph, or the change in momentum.

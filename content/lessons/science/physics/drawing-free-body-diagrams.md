---
_id: "lesson-physics-drawing-free-body-diagrams"
title: "Drawing Free-Body Diagrams"
summary: "Draw the forces on one object and resolve angled forces."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 6
partCount: 6
ordering: 33
keyPoints:
  - "Draw only the forces acting on the chosen object."
  - "Resolve an angled force along the chosen axes."
---
## Core Concept

Suppose a force $F$ points at an angle $\theta$ from the $x$ axis. Its parts are $F_x=F\cos\theta$ along that axis and $F_y=F\sin\theta$ along the other. Cosine and sine are the side ratios of a right triangle: $\cos\theta$ is the side next to the angle divided by the long side, and $\sin\theta$ is the side opposite the angle divided by the long side. The Scalars and Vectors lesson teaches this in full.

### Free-Body Diagrams

A **free-body diagram** shows one chosen object by itself, drawn as a dot or a box. Then it shows every force that other objects exert on it, as arrows from the dot.

To build one:

1. Choose the object.
2. Draw gravity first: a weight arrow pointing down.
3. Look at everything that touches the object: a surface gives a normal force, and also friction if the object slides or is pushed along a rough surface. A rope gives tension, and a hand gives a push.
4. Draw each arrow in its true direction and label it.
5. Choose axes. On a slope, put one axis along the slope and one perpendicular to it.
6. Split any arrow that is not along an axis into components, using $F\cos\theta$ and $F\sin\theta$ with $\theta$ measured from an axis.
7. Write $\sum F=ma$ for each axis.

Do not draw the forces that the chosen object exerts on other things. Do not draw $m\vec a$ as a force. It is the result of the forces, not one of them.

## Examples

### #1: A Force at an Angle

A $5\,\mathrm{kg}$ box is on a smooth, level table. Ignore friction. A hand pulls it with $40\,\mathrm N$ at $30^\circ$ above the horizontal. Use $g=9.8\,\mathrm{m/s^2}$, $\sin 30^\circ=0.50$, and $\cos 30^\circ=0.866$. Find the acceleration and the normal force.

**Solution:**

1. Draw the box with its weight down, the normal force up, and the pull at $30^\circ$ above the horizontal. Take $x$ along the table and $y$ up.
2. Split the pull. The part along the table is $40\cos30^\circ=40\times0.866=34.6\,\mathrm N$. The part upward is $40\sin30^\circ=40\times0.50=20\,\mathrm N$.
3. The box stays on the table, so $a_y=0$. The weight is $mg=5\times 9.8=49\,\mathrm N$.

$$N+20-49=0\Rightarrow N=29\,\mathrm N.$$

4. Along the table only the first part of the pull acts.

$$a_x=\dfrac{34.6}{5}=6.9\,\mathrm{m/s^2}.$$

The box accelerates at $6.9\,\mathrm{m/s^2}$ along the table. The normal force is $29\,\mathrm N$, less than the weight, because the pull lifts part of the weight. It is positive, so the box stays on the table.

## Speed Tricks & Shortcuts

Draw a free-body diagram before writing $\sum\vec F=m\vec a$. Then write one equation for each axis.

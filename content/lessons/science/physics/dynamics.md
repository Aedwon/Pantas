---
_id: "lesson-physics-dynamics"
title: "Dynamics"
summary: "Newton's laws, common forces, free-body diagrams, and the assumptions behind simple friction models."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 14
isActive: true
---
## Core Concept

**Dynamics** studies how forces affect motion. Newton's laws are formulated most simply in **inertial reference frames**.

### Newton's Laws

**First law:** if the net external force on an object is zero, its velocity remains constant. Rest is just the special case of zero velocity. This property is called inertia.

**Second law:** for a constant-mass particle or system in the introductory model,

$$\sum \vec F_{\text{ext}}=m\vec a.$$

More generally, Newton's second law is related to the rate of change of momentum. Force and acceleration are vectors, so equations must be applied component by component.

**Third law:** if object A exerts a force on object B, object B simultaneously exerts an equal-magnitude, opposite-direction force on A. The two forces act on **different objects** and are the same interaction pair.


<!-- FIGURE: {"kind":"physics-mechanics-diagram","type":"newton-laws","illustrationKey":"science/physics/dynamics#1","laws":[{"label":"first law","scene":"book motionless on table","relationship":"balanced forces"},{"label":"second law","scene":"hand pushing cart","relationship":"force arrow and acceleration arrow"},{"label":"third law","scene":"swimmer pushes water backward","relationship":"water pushes swimmer forward equally"}]} -->
### Common Forces

**Weight:** near Earth's surface,

$$\vec W=m\vec g,$$

directed toward Earth.

**Normal force:** a contact force exerted by a surface, perpendicular to the contact surface. It is not automatically equal to $mg$.

**Tension:** the pulling force transmitted by a taut rope/cable. In an ideal **massless rope over frictionless pulleys**, tension can be treated as uniform along the rope; real ropes and pulleys can violate that shortcut.

### Friction

For many dry surfaces, introductory problems use the empirical Coulomb-friction model:

$$f_s\le\mu_sN$$

$$f_{s,\max}=\mu_sN$$

$$f_k\approx\mu_kN.$$

Static friction **adjusts as needed** up to a maximum; it is not always equal to $\mu_sN$.

Kinetic friction in this simple model is approximately independent of apparent contact area and only weakly dependent on sliding speed over a limited range. In real materials, friction can depend on speed, temperature, surface condition, deformation, lubrication, and other factors. Likewise, $\mu_s$ is often greater than $\mu_k$ for a given dry pair of surfaces, but this is an empirical tendency rather than a universal law.

### Free-Body Diagrams

A **free-body diagram** isolates one chosen object/system and shows the **external forces acting on that object/system**. Do not draw the forces that the chosen object exerts on other objects on the same free-body diagram.

## Examples

### #1: Newton's Second Law

A $5\,\mathrm{kg}$ object has net external force $20\,\mathrm N$ in the positive $x$ direction.

$$a_x=\frac{F_{\text{net},x}}{m}=\frac{20}{5}=4\,\mathrm{m/s^2}.$$

### #2: Third-Law Pair vs. Force Balance

A book rests on a horizontal table.

**Forces on the book:**

- Earth pulls the book downward gravitationally.
- Table pushes the book upward normally.

If the book has zero vertical acceleration, these two **forces on the book** balance.

A Newton-third-law pair is different:

- table pushes upward on book;
- book pushes downward on table.

These contact forces are equal and opposite because they are the two sides of the **same book-table interaction**. The downward contact force on the table should not be described as simply "the book's weight transmitted through the table": its magnitude follows from the book-table contact dynamics and happens to equal the book's weight in this simple static setup.

The gravitational third-law partner of "Earth pulls book downward" is "book pulls Earth upward."

### #3: Static and Kinetic Friction

A crate on a horizontal floor requires $200\,\mathrm N$ of horizontal applied force to be just on the verge of sliding. Once it slides at constant speed, a $150\,\mathrm N$ horizontal force maintains that speed.

Under the simple friction model:

1. $f_{s,\max}=200\,\mathrm N$.
2. At constant sliding speed, net horizontal force is zero, so $f_k=150\,\mathrm N$.

This example determines these values from the stated motion; it is not evidence that all surfaces always have $f_{s,\max}>f_k$.

### #4: Box on a Table

A box rests on a horizontal table with no other vertical forces.

1. Weight $mg$ acts downward.
2. Normal force $N$ acts upward.
3. Since $a_y=0$,

$$N-mg=0\Rightarrow N=mg.$$

The equality follows from this **specific force balance**, not from the definition of normal force.

<!-- FIGURE: {"kind": "concept-diagram", "type": "free-body", "forces": [{"label": "Normal Force (Fn)", "direction": "up"}, {"label": "Weight (Fg)", "direction": "down"}], "semanticsLabel": "A free body diagram of a box with an upward normal force arrow and an equal downward gravity arrow."} -->
## Speed Tricks & Shortcuts

Draw a free-body diagram before writing $\sum\vec F=m\vec a$.

For a Newton-third-law pair, verify three things: same interaction, equal magnitude/opposite direction, different bodies.

For static friction, solve the required friction first and check whether it is less than or equal to $\mu_sN$. Do not automatically substitute $f_s=\mu_sN$.

## Traps to Watch For

### #1: Confusing Third-Law Pairs with Balanced Forces

> Third-law pairs act on different objects; equilibrium forces act on the same object.

Normal force and weight on a resting book are not a third-law pair.

### #2: Assuming Force Is Needed to Maintain Constant Velocity

> In an inertial frame, zero net force means constant velocity, not necessarily rest.

A continued applied force may be needed in everyday situations only because opposing forces such as friction are also present.

### #3: Treating Friction Formulas as Exact Universal Laws

> $f_k\approx\mu_kN$ and $f_{s,\max}=\mu_sN$ are useful empirical models for many dry-contact problems.

Real friction is more complicated.

### #4: Assuming Normal Force Always Equals Weight

> Normal force depends on the full force balance perpendicular to the surface.

Inclines and additional pushes/pulls change it.

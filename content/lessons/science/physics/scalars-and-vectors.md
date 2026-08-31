---
_id: "lesson-physics-scalars-and-vectors"
title: "Scalars and Vectors (Vector Addition and Resolution)"
summary: "The difference between scalar and vector physical quantities and how to add vectors and resolve them into components."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 11
isActive: true
---
## Core Concept

Physical quantities can be scalar or vector quantities.

A **scalar** is fully specified by a magnitude and unit. Examples include mass, temperature, time, speed, energy, and path length/distance.

A **vector** requires both magnitude and direction and obeys vector-addition rules. Examples include displacement, velocity, acceleration, force, and momentum.

Whether a quantity is a vector is a property of the **physical quantity**, not simply whether a sentence happens to contain a direction word. A problem can ask only for the magnitude of a vector, and a scalar statement can still refer to a location or orientation in ordinary language.

Vectors are commonly represented by arrows, with arrow direction representing vector direction and arrow length representing magnitude according to a chosen scale.

### Adding Vectors

Vector addition is performed component-wise or geometrically.

- Same direction: magnitudes add.
- Opposite directions along one line: signed components add, which may look like subtracting magnitudes.
- General directions: use tip-to-tail construction or resolve into components and add corresponding components.

For perpendicular vectors with magnitudes $A$ and $B$, the resultant magnitude is

$$R=\sqrt{A^2+B^2}.$$

For arbitrary vectors, do **not** use the Pythagorean theorem unless their components are perpendicular; use components or the law of cosines as appropriate.

### Resolving a Vector into Components

If a vector of magnitude $V$ makes angle $\theta$ measured counterclockwise from the positive $x$-axis,

$$V_x=V\cos\theta,\qquad V_y=V\sin\theta.$$

The signs follow from the quadrant. If the angle is measured from a different axis or direction, derive the components from the geometry instead of memorizing these expressions blindly.

A vector's magnitude can be reconstructed from perpendicular Cartesian components:

$$V=\sqrt{V_x^2+V_y^2}.$$

Its direction can be obtained from an inverse tangent with quadrant care, for example using an $\operatorname{atan2}(V_y,V_x)$ interpretation.

## Examples

### #1: Scalar or Vector?

Classify:

(a) path length traveled = $10\,\mathrm{km}$;  
(b) displacement = $6\,\mathrm{km}$ east;  
(c) temperature = $30\,^{\circ}\mathrm C$;  
(d) speed = $20\,\mathrm{m/s}$.

**Solution:**

1. Path length/distance: scalar.
2. Displacement: vector.
3. Temperature: scalar.
4. Speed: scalar, even though velocity—its vector counterpart—is a vector quantity.

### #2: Perpendicular Displacements

A hiker walks $3\,\mathrm{km}$ east then $4\,\mathrm{km}$ north.

$$R=\sqrt{3^2+4^2}=5\,\mathrm{km}.$$

The **displacement magnitude** is $5$ km. The **distance traveled** is $3+4=7$ km. These are different quantities.

### #3: Components

A $10\,\mathrm N$ force acts $30^\circ$ above the positive horizontal axis.

$$F_x=10\cos30^\circ=5\sqrt3\,\mathrm N$$

$$F_y=10\sin30^\circ=5\,\mathrm N$$

Both components are positive because the vector lies in quadrant I.

### #4: Opposite Forces

Take right as positive. A $600\,\mathrm N$ force acts left and a $450\,\mathrm N$ force acts right.

$$F_{\text{net}}=(-600)+(450)=-150\,\mathrm N.$$

The negative sign means the net force is $150\,\mathrm N$ left.

## Speed Tricks & Shortcuts

First identify the **quantity name**: speed is scalar; velocity is vector; distance is scalar; displacement is vector.

For one-dimensional vectors, assign a positive direction and use signed numbers. This is safer than memorizing "subtract the smaller from the larger."

For two-dimensional vectors, components are the general-purpose method: resolve, add $x$ components, add $y$ components, then reconstruct magnitude and direction.

## Traps to Watch For

### #1: Using a Direction Word as the Definition of a Vector

> A vector is defined by its mathematical/physical transformation and addition properties, not by sentence wording.

A question may ask only for a vector's magnitude without restating its direction.

### #2: Confusing Distance and Displacement

> Distance is total path length; displacement is change in position.

A round trip can have positive distance and zero displacement.

### #3: Adding Magnitudes Instead of Vectors

> $|\vec A+\vec B|$ is not generally $A+B$.

Direct magnitude addition works only when the vectors point in the same direction.

### #4: Memorizing Sine/Cosine Without Checking the Angle Definition

> $V_x=V\cos\theta$ and $V_y=V\sin\theta$ assume $\theta$ is measured from the positive horizontal axis.

If the reference axis changes, derive the triangle again.

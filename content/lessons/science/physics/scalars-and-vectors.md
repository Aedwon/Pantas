---
_id: "lesson-physics-scalars-and-vectors"
title: "Scalars and Vectors (Vector Addition and Resolution)"
summary: "The difference between scalar and vector quantities and how to add and break apart vectors."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 11
isActive: true
---
## Core Concept

Physics quantities come in two types.

A **scalar** has only magnitude (size), no direction: mass, temperature, time, speed, distance. Saying "the car traveled $50 \text{ km}$" is a scalar statement.

A **vector** has both magnitude and direction: displacement, velocity, acceleration, force. Saying "the car traveled $50 \text{ km}$ north" is a vector statement — the direction matters.

Vectors are drawn as arrows: the arrow length represents magnitude, and the arrow direction represents the direction of the quantity.

<!-- ILLUSTRATION: two arrows of different lengths pointing in different directions, one labeled 5 N east and a longer one labeled 8 N northeast, showing how arrow length represents magnitude and arrow direction represents direction -->

### Adding Vectors

When vectors point in the same direction, simply add their magnitudes. When vectors point in opposite directions, subtract the smaller from the larger (the result points in the direction of the larger vector).

When vectors point in different (non-opposite) directions, use the **tip-to-tail method**: draw the first vector, then start the second vector's tail at the first vector's tip. The **resultant** (the sum) is the single arrow drawn from the very first tail to the very last tip. For vectors at right angles to each other, the resultant's magnitude can be found using the Pythagorean theorem, since the two vectors and the resultant form a right triangle.

### Resolving Vectors into Components

Just as two vectors can be combined into one resultant, a single vector can be broken apart into two perpendicular pieces, called **components**: usually a horizontal ($x$) component and a vertical ($y$) component. For a vector with magnitude $V$ at angle $\theta$ from the horizontal:

$$V_x = V\cos\theta \qquad V_y = V\sin\theta$$

This is useful because horizontal and vertical motions can then be analyzed separately and independently.

## Examples

### #1: Scalar or Vector?

Classify each quantity as a scalar or a vector: (a) "the runner covered $10 \text{ km}$"; (b) "the runner's displacement was $6 \text{ km}$ east"; (c) "the temperature is $30°C$."

**Solution:**
Check whether a direction is specified.

1. (a) "$10 \text{ km}$" with no direction given: Scalar (this is distance).
2. (b) "$6 \text{ km}$ east" includes a specific direction: Vector (this is displacement).
3. (c) Temperature has magnitude only, no direction: Scalar.

### #2: Adding Perpendicular Vectors

A hiker walks $3 \text{ km}$ east, then $4 \text{ km}$ north. Find the magnitude of the hiker's total displacement.

**Solution:**
The two vectors are perpendicular, so use the Pythagorean theorem.

1. Set up the Pythagorean theorem with the two perpendicular legs.

$$R^2 = 3^2 + 4^2$$

2. Compute.

$$R^2 = 9 + 16 = 25$$

3. Take the square root.

$$R = 5 \text{ km}$$

4. The hiker's total displacement has a magnitude of $5 \text{ km}$ (this is the familiar $3$-$4$-$5$ right triangle).

### #3: Resolving a Vector into Components

A force of $10 \text{ N}$ is applied at an angle of $30°$ above the horizontal. Find its horizontal and vertical components.

**Solution:**
Apply the component formulas with $V = 10$ and $\theta = 30°$.

1. Horizontal component.

$$V_x = 10 \cos 30° = 10 \times \dfrac{\sqrt{3}}{2} = 5\sqrt{3} \text{ N}$$

2. Vertical component.

$$V_y = 10 \sin 30° = 10 \times \dfrac{1}{2} = 5 \text{ N}$$

3. The horizontal component is $5\sqrt{3} \text{ N}$ (about $8.7 \text{ N}$), and the vertical component is $5 \text{ N}$.

### #4: Vectors in Opposite Directions

Two tug-of-war teams pull on a rope. Team A pulls with $600 \text{ N}$ to the left; Team B pulls with $450 \text{ N}$ to the right. Find the net force and its direction.

**Solution:**
Since the forces are in opposite directions, subtract the smaller from the larger.

1. Subtract the magnitudes.

$$600 - 450 = 150 \text{ N}$$

2. The net force takes the direction of the larger force, which is Team A's direction (left).
3. The net force is $150 \text{ N}$ to the left.

## Speed Tricks & Shortcuts

To tell scalar from vector fast, listen for a direction word (north, up, left, at an angle) — its presence means vector; its absence means scalar.

For perpendicular vector addition, check first whether the numbers form a known Pythagorean triple ($3$-$4$-$5$, $5$-$12$-$13$, $8$-$15$-$17$) to skip the squaring and rooting.

Remember which trig function goes with which component: Cosine goes with the adjacent side (usually the horizontal component when the angle is measured from the horizontal), and sine goes with the opposite side (usually the vertical component).

## Traps to Watch For

### #1: Confusing Distance (Scalar) with Displacement (Vector)

> Distance is the total path length traveled (scalar). Displacement is the straight-line change in position, with direction (vector).

If a runner jogs around a circular track and ends up back at the starting point, the distance traveled is the full circumference (a large positive number), but the displacement is zero, since the runner ended up exactly where they started. Confusing these two produces very different, often contradictory answers.

### #2: Simply Adding Magnitudes When Vectors Are Not in the Same Direction

> Vector magnitudes can only be added directly when the vectors point in the exact same direction.

Adding $3 \text{ km}$ and $4 \text{ km}$ directly (getting $7 \text{ km}$) when the two displacements are actually perpendicular gives the wrong total; the correct combined magnitude (using the Pythagorean theorem) is $5 \text{ km}$, not $7 \text{ km}$.

### #3: Swapping Sine and Cosine When Finding Components

> Whether you use sine or cosine for a component depends on which side of the angle the component represents — always double-check against the actual triangle, don't just guess.

If the angle is measured from the vertical instead of the horizontal (a less common but valid setup), the sine and cosine roles for the $x$ and $y$ components swap compared to the usual convention. Always sketch the triangle and identify the adjacent and opposite sides relative to the given angle before applying a formula.

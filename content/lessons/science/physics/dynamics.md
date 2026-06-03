---
_id: "lesson-physics-dynamics"
title: "Dynamics"
summary: "Newton's three laws of motion, the main types of forces, and how to draw free body diagrams to solve force problems."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 14
isActive: true
---
## Core Concept

While kinematics describes how things move, **dynamics** explains why: the forces causing motion to happen or change.

### Newton's Laws of Motion

**First Law (Law of Inertia)**: an object at rest stays at rest, and an object in motion stays in motion at constant velocity in a straight line, unless acted on by a net (unbalanced) external force. **Inertia** is an object's natural resistance to changing its motion, and mass is the measure of how much inertia an object has.

**Second Law**: the net force on an object equals its mass times its acceleration.

$$F_{net} = ma$$

A bigger net force causes more acceleration; a bigger mass causes less acceleration for the same force.

**Third Law**: for every action force, there is an equal and opposite reaction force. Crucially, these two forces act on two different objects, which is why they do not cancel each other out.

<!-- ILLUSTRATION: two figures, one showing a book resting motionless on a table with balanced forces (first law), one showing a hand pushing a cart with force arrow and resulting acceleration arrow (second law), and one showing a swimmer pushing water backward with an equal arrow showing water pushing the swimmer forward (third law) -->

### Force, Friction, Tension, and Normal Force

A **force** is a push or pull (measured in newtons, $N$). Several specific named forces appear constantly in physics problems:

- **Weight** ($W = mg$): the force of gravity pulling an object downward.
- **Normal force** ($N$): the support force a surface exerts, always perpendicular to that surface, preventing objects from sinking through it.
- **Tension** ($T$): the pulling force transmitted through a rope, string, or cable.
- **Friction** ($f$): the force resisting relative sliding between two surfaces in contact. **Static friction** acts on an object that is not yet moving, resisting the start of motion (and can vary up to a maximum value). **Kinetic friction** acts on an object that is already sliding, and stays roughly constant regardless of speed. Static friction's maximum value is usually slightly greater than kinetic friction, which is why it can be harder to start pushing a heavy box than to keep it moving once sliding.

### Free Body Diagrams

A **free body diagram** isolates one object and shows every force acting on it as an arrow, with length roughly representing magnitude and direction matching the real force's direction. Drawing one correctly is often the key step to solving any force problem, since it turns a real-world scenario into a clear picture ready for Newton's second law.

## Examples

### #1: Applying Newton's Second Law

A $5 \text{ kg}$ object experiences a net force of $20 \text{ N}$. Find its acceleration.

**Solution:**
Apply $F_{net} = ma$, solved for acceleration.

1. Rearrange the formula.

$$a = \dfrac{F_{net}}{m}$$

2. Substitute the values.

$$a = \dfrac{20}{5}$$

3. Compute.

$$a = 4 \text{ m/s}^2$$

### #2: Identifying Newton's Third Law Pairs

A book rests on a table. Identify the action-reaction pair of forces involved, according to Newton's third law.

**Solution:**
Find the two forces that are equal, opposite, and act on different objects.

1. The book pushes down on the table (due to its weight, transmitted through contact).
2. By Newton's third law, the table pushes up on the book with an equal and opposite force (this upward force is the normal force).
3. These two forces (book-on-table, and table-on-book) are the action-reaction pair — notice they act on different objects (one on the table, one on the book), which is why the book itself does not simply cancel out and float; the relevant forces for the book's own motion are its weight and the normal force acting on it, which happen to also balance (from the first law), but that balance is a separate fact from the third law pairing.

### #3: Static vs. Kinetic Friction

A heavy crate requires a push of $200 \text{ N}$ to just begin sliding, but only requires $150 \text{ N}$ to keep it sliding at a constant speed once moving. Identify which value represents the maximum static friction and which represents kinetic friction.

**Solution:**
Match each force value to the type of friction it overcomes.

1. The force needed to just begin moving the crate must overcome the maximum static friction: $200 \text{ N}$.
2. The force needed to keep it moving at constant speed matches the kinetic friction (which is typically lower than the maximum static friction): $150 \text{ N}$.
3. This matches the general rule that maximum static friction is usually greater than kinetic friction between the same two surfaces.

### #4: Drawing a Free Body Diagram

A box sits at rest on a flat, horizontal table. Identify and describe the forces that should appear on its free body diagram.

<!-- ILLUSTRATION: a free body diagram of a box with a downward weight (gravity) arrow and an equal upward normal force arrow, both labeled -->


**Solution:**
Consider every force acting directly on the box.

1. Weight: pulling the box straight down (due to gravity), with magnitude $mg$.
2. Normal force: pushing the box straight up (from the table's surface), perpendicular to the table.
3. Since the box is at rest (not accelerating), by Newton's first law, these two forces must be equal in magnitude and opposite in direction, balancing each other exactly.
4. If nothing else is pushing or pulling the box (like a rope, applied push, or friction from sliding), these are the only two forces in this diagram.

## Speed Tricks & Shortcuts

For any dynamics problem, draw the free body diagram first before writing any equations. Identify every force acting directly on the object of interest (weight, normal force, tension, friction, and any applied force), then apply $F_{net} = ma$ using the sum of these forces.

Remember that Newton's third law pairs always act on two different objects. If you find yourself describing two forces acting on the same object that seem "equal and opposite," you are more likely observing a first-law force balance (equilibrium), not a third-law action-reaction pair.

For friction problems, remember: static friction handles the "before it starts moving" phase and can vary up to its maximum; kinetic friction handles the "already sliding" phase and stays roughly constant. The maximum static value is typically the larger of the two.

## Traps to Watch For

### #1: Confusing Newton's Third Law Pairs with Balanced Forces

> Third law pairs act on two different objects. Balanced forces (equilibrium, from the first law) act on the same object.

The normal force and weight acting on the same book are balanced forces (first law), not a third-law action-reaction pair — even though they happen to be equal and opposite in this specific resting scenario. The true third-law partner of "table pushes up on book" is "book pushes down on table" (a different object entirely).

### #2: Assuming More Mass Always Means More Acceleration

> For the same net force, more mass produces less acceleration, not more — mass and acceleration are inversely related in Newton's second law.

Confusing the direct relationship between force and acceleration with the inverse relationship between mass and acceleration is a very common Newton's second law error. Double the mass (with the same force) halves the acceleration, it does not double it.

### #3: Treating Kinetic Friction as Always Weaker Than Any Applied Force

> Kinetic friction is roughly constant once sliding begins, but it can still be strong enough to eventually stop a moving object if no other force keeps pushing it.

A sliding object with no continued applied force will eventually decelerate to a stop due to kinetic friction, since friction opposes the direction of motion. Do not assume friction is negligible just because an object is already moving.

### #4: Forgetting the Normal Force Isn't Always Equal to Weight

> The normal force equals weight only when the surface is horizontal and there are no other vertical forces acting (like an additional push or pull at an angle).

On an inclined surface, or when an additional force pushes down or pulls up on the object, the normal force must be recalculated from the actual vertical force balance in that specific situation — it does not automatically equal $mg$ in every scenario.

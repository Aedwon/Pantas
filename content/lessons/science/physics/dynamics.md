---
_id: "lesson-physics-dynamics"
title: "Dynamics"
summary: "This lesson teaches you Newton's three laws of motion, the main types of forces, and how to draw free body diagrams to solve force problems."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 14
isActive: true
---
## Core Concept

While kinematics describes HOW things move, **dynamics** explains WHY: the forces causing motion to happen or change.

### Newton's Laws of Motion

**First Law (Law of Inertia)**: an object at rest stays at rest, and an object in motion stays in motion at constant velocity in a straight line, UNLESS acted on by a net (unbalanced) external force. **Inertia** is an object's natural resistance to changing its motion, and MASS is the measure of how much inertia an object has.

**Second Law**: the net force on an object equals its mass times its acceleration.

$$F_{net} = ma$$

A bigger net force causes MORE acceleration; a bigger mass causes LESS acceleration for the same force.

**Third Law**: for every action force, there is an equal and opposite reaction force. Crucially, these two forces act on TWO DIFFERENT objects, which is why they do NOT cancel each other out.

<!-- ILLUSTRATION: two figures, one showing a book resting motionless on a table with balanced forces (first law), one showing a hand pushing a cart with force arrow and resulting acceleration arrow (second law), and one showing a swimmer pushing water backward with an equal arrow showing water pushing the swimmer forward (third law) -->

### Force, Friction, Tension, and Normal Force

A **force** is a push or pull (measured in newtons, $N$). Several specific named forces appear constantly in physics problems:

- **Weight** ($W = mg$): the force of gravity pulling an object downward.
- **Normal force** ($N$): the SUPPORT force a surface exerts, always PERPENDICULAR to that surface, preventing objects from sinking through it.
- **Tension** ($T$): the pulling force transmitted through a rope, string, or cable.
- **Friction** ($f$): the force resisting relative sliding between two surfaces in contact. **Static friction** acts on an object that is NOT yet moving, resisting the start of motion (and can vary up to a maximum value). **Kinetic friction** acts on an object that IS already sliding, and stays roughly CONSTANT regardless of speed. Static friction's maximum value is usually SLIGHTLY GREATER than kinetic friction, which is why it can be harder to START pushing a heavy box than to KEEP it moving once sliding.

### Free Body Diagrams

A **free body diagram** isolates ONE object and shows EVERY force acting on it as an arrow, with length roughly representing magnitude and direction matching the real force's direction. Drawing one correctly is often the key step to solving any force problem, since it turns a real-world scenario into a clear picture ready for Newton's second law.

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

A book rests on a table. Identify the action-reaction PAIR of forces involved, according to Newton's third law.

**Solution:**
Find the two forces that are equal, opposite, and act on DIFFERENT objects.

1. The book pushes DOWN on the table (due to its weight, transmitted through contact).
2. By Newton's third law, the table pushes UP on the book with an EQUAL and OPPOSITE force (this upward force is the normal force).
3. These two forces (book-on-table, and table-on-book) are the action-reaction pair — notice they act on DIFFERENT objects (one on the table, one on the book), which is why the book itself does not simply cancel out and float; the RELEVANT forces for the book's own motion are its weight and the normal force acting ON it, which happen to also balance (from the first law), but that balance is a separate fact from the third law pairing.

### #3: Static vs. Kinetic Friction

A heavy crate requires a push of $200 \text{ N}$ to JUST BEGIN sliding, but only requires $150 \text{ N}$ to KEEP it sliding at a constant speed once moving. Identify which value represents the maximum static friction and which represents kinetic friction.

**Solution:**
Match each force value to the type of friction it overcomes.

1. The force needed to JUST BEGIN moving the crate must overcome the MAXIMUM STATIC friction: $200 \text{ N}$.
2. The force needed to KEEP it moving at constant speed matches the KINETIC friction (which is typically lower than the maximum static friction): $150 \text{ N}$.
3. This matches the general rule that maximum static friction is usually greater than kinetic friction between the same two surfaces.

### #4: Drawing a Free Body Diagram

A box sits at rest on a flat, horizontal table. Identify and describe the forces that should appear on its free body diagram.

**Solution:**
Consider every force acting directly ON the box.

1. WEIGHT: pulling the box straight DOWN (due to gravity), with magnitude $mg$.
2. NORMAL FORCE: pushing the box straight UP (from the table's surface), perpendicular to the table.
3. Since the box is at REST (not accelerating), by Newton's first law, these two forces must be EQUAL in magnitude and opposite in direction, balancing each other exactly.
4. If nothing else is pushing or pulling the box (like a rope, applied push, or friction from sliding), these are the ONLY two forces in this diagram.

## Speed Tricks & Shortcuts

For any dynamics problem, draw the free body diagram FIRST before writing any equations. Identify every force acting directly on the object of interest (weight, normal force, tension, friction, and any applied force), then apply $F_{net} = ma$ using the SUM of these forces.

Remember that Newton's third law pairs ALWAYS act on TWO DIFFERENT objects. If you find yourself describing two forces acting on the SAME object that seem "equal and opposite," you are more likely observing a first-law force balance (equilibrium), not a third-law action-reaction pair.

For friction problems, remember: static friction handles the "before it starts moving" phase and can vary up to its maximum; kinetic friction handles the "already sliding" phase and stays roughly constant. The maximum static value is typically the LARGER of the two.

## Traps to Watch For

### #1: Confusing Newton's Third Law Pairs with Balanced Forces

> Third law pairs act on TWO DIFFERENT objects. Balanced forces (equilibrium, from the first law) act on the SAME object.

The normal force and weight acting ON THE SAME BOOK are balanced forces (first law), NOT a third-law action-reaction pair — even though they happen to be equal and opposite in this specific resting scenario. The TRUE third-law partner of "table pushes up on book" is "book pushes down on table" (a different object entirely).

### #2: Assuming More Mass Always Means More Acceleration

> For the SAME net force, MORE mass produces LESS acceleration, not more — mass and acceleration are INVERSELY related in Newton's second law.

Confusing the direct relationship between force and acceleration with the INVERSE relationship between mass and acceleration is a very common Newton's second law error. Double the mass (with the same force) HALVES the acceleration, it does not double it.

### #3: Treating Kinetic Friction as Always Weaker Than Any Applied Force

> Kinetic friction is roughly CONSTANT once sliding begins, but it can still be strong enough to eventually stop a moving object if no other force keeps pushing it.

A sliding object with no continued applied force will eventually decelerate to a stop due to kinetic friction, since friction opposes the direction of motion. Do not assume friction is negligible just because an object is already moving.

### #4: Forgetting the Normal Force Isn't Always Equal to Weight

> The normal force equals weight ONLY when the surface is horizontal and there are no OTHER vertical forces acting (like an additional push or pull at an angle).

On an inclined surface, or when an additional force pushes down or pulls up on the object, the normal force must be recalculated from the actual vertical force balance in that specific situation — it does not automatically equal $mg$ in every scenario.

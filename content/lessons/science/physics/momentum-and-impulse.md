---
_id: "lesson-physics-momentum-and-impulse"
title: "Momentum and Impulse (Conservation of Momentum, Elastic vs. Inelastic Collisions)"
summary: "How momentum and impulse are related and how to use conservation of momentum to analyze collisions."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 13
isActive: true
---
## Core Concept

**Momentum** ($p$) measures how hard it is to stop a moving object: the product of mass and velocity.

$$p = mv$$

A heavy truck moving slowly can have the same momentum as a light car moving fast: momentum depends on both mass and velocity together.

**Impulse** ($J$) is the change in momentum, caused by a force acting over a period of time:

$$J = Ft = \Delta p = mv_f - mv_i$$

This means the same impulse (change in momentum) can be delivered by a large force over a short time (like a punch), or a small force over a longer time (like a gentle, sustained push): this is why airbags and padded surfaces reduce injury: they extend the time of impact, reducing the force needed to produce the same change in momentum.

<!-- FIGURE: {"kind":"physics-mechanics-diagram","type":"impulse-duration","illustrationKey":"science/physics/momentum-and-impulse#1","impulse":"same","cases":[{"surface":"hard surface","force":"large","time":"very short"},{"surface":"airbag","force":"smaller","time":"longer"}]} -->

### Conservation of Momentum

In a closed system (no outside forces), the total momentum before a collision equals the total momentum after:

$$p_{total, before} = p_{total, after}$$

This comes directly from Newton's third law: during any collision, the forces the two objects exert on each other are equal and opposite, so their impulses cancel out, leaving the total combined momentum unchanged.

### Elastic vs. Inelastic Collisions

An **elastic collision** conserves both momentum and kinetic energy: objects "bounce off" each other with no energy lost to heat or sound (a close real-world approximation: billiard balls colliding).

An **inelastic collision** conserves momentum, but not kinetic energy: some kinetic energy converts into other forms (heat, sound, deformation). A **perfectly inelastic collision** is the extreme case where the two objects stick together after colliding, moving as one combined mass.

## Examples

### #1: Calculating Momentum

Find the momentum of a $1000 \text{ kg}$ car moving at $20 \text{ m/s}$.

**Solution:**
Apply the momentum formula.

1. Substitute the values.

$$p = (1000)(20)$$

2. Compute.

$$p = 20{,}000 \text{ kg} \cdot \text{m/s}$$

### #2: Impulse and Force

A $0.5 \text{ kg}$ ball traveling at $10 \text{ m/s}$ is caught and brought to a complete stop in $0.2$ seconds. Find the average force exerted to stop it.

**Solution:**
Find the impulse (change in momentum) first, then use $J = Ft$ to solve for force.

1. Find the change in momentum. Initial momentum: $(0.5)(10) = 5 \text{ kg} \cdot \text{m/s}$. Final momentum (ball stops): $0$.

$$\Delta p = 0 - 5 = -5 \text{ kg} \cdot \text{m/s}$$

2. Set impulse equal to this change in momentum.

$$Ft = \Delta p$$

$$F(0.2) = -5$$

3. Solve for $F$.

$$F = \dfrac{-5}{0.2} = -25 \text{ N}$$

4. The magnitude of the force is $25 \text{ N}$ (the negative sign shows it acts opposite to the ball's original motion, slowing it down).

### #3: Perfectly Inelastic Collision

A $3 \text{ kg}$ cart moving at $4 \text{ m/s}$ collides with a stationary $1 \text{ kg}$ cart, and the two carts stick together after the collision. Find their combined velocity afterward.

**Solution:**
Total momentum before the collision equals total momentum after (they now move together as one mass).

1. Total momentum before: only the moving cart has momentum, since the second cart starts at rest.

$$p_{before} = (3)(4) + (1)(0) = 12 \text{ kg} \cdot \text{m/s}$$

2. After sticking together, the combined mass is $3 + 1 = 4 \text{ kg}$, moving at some shared velocity $v$.

$$p_{after} = (4)v$$

3. Set the two equal (conservation of momentum).

$$12 = 4v$$

4. Solve for $v$.

$$v = 3 \text{ m/s}$$

### #4: Elastic or Inelastic?

Two identical billiard balls collide, bounce apart, and measurements show that both the total momentum and the total kinetic energy are the same before and after the collision. Classify this collision.

**Solution:**
Check which quantities were conserved.

1. Momentum was conserved: expected for any collision in a closed system.
2. Kinetic energy was also conserved: this only happens in an elastic collision.
3. Since both quantities were conserved, this is classified as an elastic collision.

## Speed Tricks & Shortcuts

Remember momentum is always conserved in a closed system, for every type of collision (elastic or inelastic): only kinetic energy conservation depends on the collision type. This makes momentum conservation your reliable "first tool" for any collision problem.

For "stick together" (perfectly inelastic) problems, immediately combine the masses into one final mass moving at one shared final velocity: this simplifies the after-collision side of the equation to a single term.

Remember the impulse-force tradeoff in one phrase: "same push, different time, different force": extending the time over which a momentum change happens always reduces the force needed (and vice versa).

## Traps to Watch For

### #1: Assuming Kinetic Energy Is Always Conserved

> Only elastic collisions conserve kinetic energy. Momentum is conserved in all closed-system collisions, elastic or not.

A common mistake applies a kinetic energy conservation equation to an inelastic collision, producing an incorrect result. Always check (or assume, unless told otherwise) that a real-world collision is inelastic, since perfectly elastic collisions are an idealized case.

### #2: Forgetting a Stationary Object Still Has (Zero) Momentum to Include

> A stationary object contributes momentum $= mv = 0$, but it still needs to be included in the total momentum calculation.

Skipping the stationary cart's momentum term entirely (rather than correctly including it as zero) is usually harmless numerically, but skipping its mass in the "after" total (when objects stick together) is a common and costly error: the combined mass must include both objects' masses, even the one that started at rest.

### #3: Confusing Impulse with Force

> Impulse equals force multiplied by time (or equivalently, the total change in momentum): it is not simply the force alone.

A large force applied for a very short time can produce the same impulse as a small force applied for a much longer time. Reporting a raw force value when a question asks specifically for impulse (or vice versa) misses the time component entirely.

### #4: Mixing Up the Direction (Sign) of Momentum

> Momentum is a vector: assign a clear positive direction and keep it consistent for every object throughout the whole problem.

If two objects move toward each other before a collision, one must be treated as negative momentum (opposite direction) in the total momentum calculation. Treating both as positive, regardless of their actual directions, produces an incorrect total.

---
_id: "lesson-physics-work-energy-power"
title: "Work, Energy, and Power (Kinetic and Potential Energy, Conservation of Energy)"
summary: "This lesson teaches you how to calculate work, kinetic and potential energy, power, and how energy conservation connects them."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 13
isActive: true
---
## Core Concept

**Work** ($W$) is done when a force moves an object a certain DISTANCE in the direction of the force:

$$W = Fd$$

Work is measured in **joules** ($J$). If the force and the direction of motion are not perfectly aligned, only the component of force ALONG the motion counts — pushing straight down on a cart moving horizontally does zero work on its horizontal motion.

### Kinetic and Potential Energy

**Kinetic energy** ($KE$) is the energy of MOTION:

$$KE = \dfrac{1}{2}mv^2$$

**Potential energy** ($PE$), specifically GRAVITATIONAL potential energy, is stored energy due to an object's HEIGHT:

$$PE = mgh$$

### The Work-Energy Theorem

The **work-energy theorem** connects work directly to a CHANGE in kinetic energy: the net work done on an object equals its change in kinetic energy.

$$W_{net} = \Delta KE = KE_f - KE_i$$

### Conservation of Energy

The **law of conservation of energy** states that energy cannot be created or destroyed, only converted from one form to another. In a system with no friction or air resistance (only "conservative" forces like gravity), the TOTAL mechanical energy (kinetic plus potential) stays CONSTANT:

$$KE_i + PE_i = KE_f + PE_f$$

<!-- ILLUSTRATION: pendulum or roller coaster shown at three points, high point with all potential energy and zero kinetic energy, midpoint with a mix of both, and low point with all kinetic energy and zero potential energy, total height of the energy bar staying the same throughout -->

### Power

**Power** ($P$) is the RATE at which work is done (how quickly energy is transferred), measured in **watts** ($W$, where $1 \text{ watt} = 1 \text{ joule/second}$):

$$P = \dfrac{W}{t}$$

## Examples

### #1: Calculating Kinetic Energy

Find the kinetic energy of a $2 \text{ kg}$ ball moving at $6 \text{ m/s}$.

**Solution:**
Apply the kinetic energy formula.

1. Substitute the values.

$$KE = \dfrac{1}{2}(2)(6)^2$$

2. Compute the square first: $6^2 = 36$.

$$KE = \dfrac{1}{2}(2)(36)$$

3. Compute.

$$KE = 36 \text{ J}$$

### #2: Calculating Potential Energy

Find the gravitational potential energy of a $5 \text{ kg}$ book held $2 \text{ m}$ above the ground (use $g = 9.8 \text{ m/s}^2$).

**Solution:**
Apply the potential energy formula.

1. Substitute the values.

$$PE = (5)(9.8)(2)$$

2. Compute.

$$PE = 98 \text{ J}$$

### #3: Conservation of Energy on a Slide

A $10 \text{ kg}$ child starts from rest at the top of a frictionless slide, $3 \text{ m}$ high. Find their speed at the bottom of the slide (use $g = 9.8 \text{ m/s}^2$).

**Solution:**
Total energy at the top (all potential, since they start at rest) equals total energy at the bottom (all kinetic, since height is zero there).

1. Energy at the top.

$$PE_i = mgh = (10)(9.8)(3) = 294 \text{ J}$$

2. Since the child starts from rest, $KE_i = 0$. By conservation of energy, all of this becomes kinetic energy at the bottom.

$$KE_f = 294 \text{ J}$$

3. Set up the kinetic energy formula to solve for velocity.

$$294 = \dfrac{1}{2}(10)v^2$$

4. Simplify.

$$294 = 5v^2$$

5. Divide both sides by $5$.

$$v^2 = 58.8$$

6. Take the square root.

$$v \approx 7.67 \text{ m/s}$$

### #4: Calculating Power

A motor does $600 \text{ J}$ of work in $4$ seconds. Find its power output.

**Solution:**
Apply the power formula.

1. Substitute the values.

$$P = \dfrac{600}{4}$$

2. Compute.

$$P = 150 \text{ W}$$

## Speed Tricks & Shortcuts

Remember the "energy see-saw" for conservation problems: whatever potential energy is LOST must exactly equal the kinetic energy GAINED (in a frictionless system), and vice versa. This lets you skip directly to the useful equation without needing every intermediate step.

For kinetic energy problems, always square the velocity FIRST before multiplying by the other numbers — this is the step most often rushed and miscalculated.

Remember power's role as "how fast" energy work happens: the SAME amount of work done in LESS time means MORE power, and the same work done over MORE time means LESS power.

## Traps to Watch For

### #1: Forgetting to Square the Velocity in Kinetic Energy

> $KE = \dfrac{1}{2}mv^2$ — the velocity term is SQUARED, not just multiplied once.

Forgetting the exponent turns a moving object's kinetic energy calculation into a much smaller (and wrong) number. Since velocity is squared, DOUBLING an object's speed actually QUADRUPLES its kinetic energy, not just doubles it.

### #2: Confusing Work with Force

> Work requires BOTH a force AND a distance moved in the direction of that force — a force with NO motion does ZERO work.

Holding a heavy box perfectly still (applying a large upward force to support it, but with no vertical displacement) does ZERO work on the box, even though real physical effort is being exerted. Work is specifically about force causing DISPLACEMENT.

### #3: Ignoring That Conservation of Energy Assumes No Friction

> Energy conservation as $KE_i + PE_i = KE_f + PE_f$ assumes NO energy is lost to friction, air resistance, or heat.

In real-world scenarios with friction, SOME mechanical energy converts into heat and is "lost" from the kinetic-plus-potential total (though it is never truly destroyed — it just changes form). Problems that explicitly mention a frictionless surface or ignore air resistance are signaling that the simple conservation equation applies directly.

### #4: Mixing Up Power and Energy

> ENERGY (or work) measures a total AMOUNT (in joules). POWER measures a RATE (in watts, joules per second).

A machine that does a LOT of work SLOWLY can have LOW power, while a machine that does LESS work very QUICKLY can have HIGH power. Confusing "how much" energy (joules) with "how fast" it is delivered (watts) leads to picking the wrong formula or misreading a question's units.

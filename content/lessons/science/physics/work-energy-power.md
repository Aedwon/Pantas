---
_id: "lesson-physics-work-energy-power"
title: "Work, Energy, and Power (Kinetic and Potential Energy, Conservation of Energy)"
summary: "How to calculate work, kinetic and potential energy, power, and how energy conservation connects them."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 13
isActive: true
---
## Core Concept

**Work** ($W$) is energy transferred by a force acting through a displacement. For a constant force,

$$W = Fd\cos\theta$$

where $\theta$ is the angle between the force and the displacement. If the force points in exactly the same direction as the displacement, $\theta=0$ and this simplifies to $W=Fd$. If the force is perpendicular to the displacement, the work done by that force is zero.

Work is measured in **joules** ($J$). For a force that varies with position, work is found by adding the force's contribution over the path (mathematically, an integral) rather than by using one constant $F$ value.

### Kinetic and Potential Energy

**Kinetic energy** ($KE$) is the energy associated with an object's motion:

$$KE = \dfrac{1}{2}mv^2$$

**Gravitational potential energy** near Earth's surface, where $g$ can be treated as approximately constant, can be written relative to a chosen zero height as:

$$PE = mgh$$

The absolute zero of potential energy is a choice; changes in potential energy are what affect physical predictions. For large changes in distance from Earth or another massive body, the more general gravitational-potential-energy expression is needed instead of $mgh$.

### The Work-Energy Theorem

The **work-energy theorem** connects work directly to a change in kinetic energy: the net work done by all forces on an object equals its change in kinetic energy.

$$W_{net} = \Delta KE = KE_f - KE_i$$

### Conservation of Energy

The **law of conservation of energy** states that energy is transferred or transformed but the total energy of an isolated system remains constant. A narrower statement applies to **mechanical energy** ($KE+PE$): if nonconservative forces do no net work, mechanical energy remains constant.

$$KE_i + PE_i = KE_f + PE_f$$

If nonconservative forces such as friction do work, mechanical energy can change even though total energy is still conserved. A useful accounting form is

$$W_{nc} = \Delta(KE+PE)$$

where $W_{nc}$ is the work done by nonconservative forces.

<!-- ILLUSTRATION: pendulum or roller coaster shown at three points, high point with all potential energy and zero kinetic energy, midpoint with a mix of both, and low point with all kinetic energy and zero potential energy, total height of the energy bar staying the same throughout -->

### Power

**Power** ($P$) is the rate at which work is done or energy is transferred, measured in **watts** ($W$, where $1 \text{ watt} = 1 \text{ joule/second}$):

$$P_{avg} = \dfrac{W}{\Delta t}$$

For a force acting on a moving object, instantaneous power can also be written as $P=\vec F\cdot\vec v$.

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

Find the gravitational potential energy of a $5 \text{ kg}$ book held $2 \text{ m}$ above a chosen zero level near Earth's surface (use $g = 9.8 \text{ m/s}^2$).

**Solution:**
Apply the near-Earth potential energy formula.

1. Substitute the values.

$$PE = (5)(9.8)(2)$$

2. Compute.

$$PE = 98 \text{ J}$$

### #3: Conservation of Energy on a Slide

A $10 \text{ kg}$ child starts from rest at the top of a frictionless slide, $3 \text{ m}$ above the bottom. Find their speed at the bottom of the slide (use $g = 9.8 \text{ m/s}^2$).

**Solution:**
With friction neglected, no nonconservative work changes the child's mechanical energy. Choose the bottom as $PE=0$.

1. Energy at the top.

$$PE_i = mgh = (10)(9.8)(3) = 294 \text{ J}$$

2. Since the child starts from rest, $KE_i = 0$. Mechanical-energy conservation gives

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

A motor does $600 \text{ J}$ of work in $4$ seconds. Find its average power output over that interval.

**Solution:**
Apply the average-power formula.

1. Substitute the values.

$$P_{avg} = \dfrac{600}{4}$$

2. Compute.

$$P_{avg} = 150 \text{ W}$$

## Speed Tricks & Shortcuts

For constant-force work questions, first check the angle between the force and displacement. Same direction gives $W=Fd$; perpendicular gives zero; otherwise use $W=Fd\cos\theta$.

For mechanical-energy problems, identify the system and ask whether any nonconservative force does work. If not, set $KE+PE$ equal between the two states. If friction or another nonconservative force does work, include that work instead of pretending the missing mechanical energy vanished.

For kinetic energy problems, always square the velocity first before multiplying by the other numbers: doubling speed quadruples kinetic energy.

Remember power's role as "how fast" energy transfer happens: the same amount of work done in less time means greater average power.

## Traps to Watch For

### #1: Using $W=Fd$ When the Force Is Not Parallel to Motion

> For a constant force, the general expression is $W=Fd\cos\theta$.

Only the component of force along the displacement contributes to work. A force perpendicular to the motion does zero work even if its magnitude is large.

### #2: Forgetting to Square the Velocity in Kinetic Energy

> $KE = \dfrac{1}{2}mv^2$: the velocity term is squared.

Since velocity is squared, doubling an object's speed quadruples its kinetic energy.

### #3: Saying Energy Is "Lost" to Friction

> Friction can reduce mechanical energy, but total energy is still conserved.

Mechanical energy transformed into thermal energy, sound, deformation, or other forms has not been destroyed. If a problem includes friction, either track those forms explicitly or use the work done by nonconservative forces.

### #4: Treating $mgh$ as the Universal Gravity Formula

> $PE=mgh$ is the near-Earth, approximately uniform-gravity expression.

For orbital or very large altitude changes, gravity varies significantly with distance, so the general gravitational-potential-energy relationship must be used.

### #5: Mixing Up Power and Energy

> Energy or work measures an amount in joules; power measures a rate in watts (joules per second).

A machine that transfers a lot of energy slowly can have lower power than one transferring less energy in a much shorter time.

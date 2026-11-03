---
_id: "lesson-physics-work-energy-power"
title: "Work, Energy, and Power (Kinetic and Potential Energy, Conservation of Energy)"
summary: "How to calculate work, kinetic and potential energy, power, and machine efficiency, and how energy conservation connects them."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 13
isActive: true
---
## Core Concept

**Work** ($W$) is energy transferred by a force that moves an object. A force is a push or a pull, measured in newtons ($N$). The displacement ($d$) is how far the object moves in a straight line, from start to finish.

For a constant force,

$$W = Fd\cos\theta$$

The angle $\theta$ is the angle between the force and the displacement. The factor $\cos\theta$ tells how much of the force points along the motion. Here are four values to know:

- $\cos 0^\circ = 1$: the force points along the motion, so $W=Fd$.
- $\cos 60^\circ = 0.5$.
- $\cos 90^\circ = 0$: the force is perpendicular to the motion, so it does zero work.
- $\cos 180^\circ = -1$: the force points against the motion, so the work is negative. Friction does negative work.

Work is measured in **joules** ($J$). One joule is the work of a $1\ N$ force over $1\ m$. This formula needs a force that stays constant. A force that changes along the path needs other methods.

### Kinetic and Potential Energy

**Kinetic energy** ($KE$) is the energy of motion. Use mass $m$ in kilograms and speed $v$ in meters per second:

$$KE = \dfrac{1}{2}mv^2$$

**Gravitational potential energy** ($PE$) is stored energy from height. Near Earth's surface, use $g = 9.8\ \text{m/s}^2$ and height $h$ in meters above a level you choose as zero:

$$PE = mgh$$

Only the change in $PE$ matters, so the zero level is your choice. The formula works only where gravity is about the same everywhere. For a very large change in height, such as an orbit, another formula is needed.

### The Work-Energy Theorem

The **net work** is the total work done by all forces together. The **work-energy theorem** says that net work equals the change in kinetic energy:

$$W_{net} = \Delta KE = KE_f - KE_i$$

Positive net work speeds an object up. Negative net work slows it down.

### Conservation of Energy

Energy is never created or destroyed. It changes form or moves from place to place. The total energy of an isolated system stays constant.

**Mechanical energy** is $KE+PE$. A **conservative force**, such as gravity, can give back the energy it takes. If only conservative forces do work, mechanical energy stays the same:

$$KE_i + PE_i = KE_f + PE_f$$

A **nonconservative force**, such as friction or air drag, changes mechanical energy into thermal energy and other forms. Then the work $W_{nc}$ done by these forces equals the change in mechanical energy:

$$W_{nc} = \Delta(KE+PE)$$

<!-- FIGURE: {"kind":"physics-mechanics-diagram","type":"mechanical-energy","illustrationKey":"science/physics/work-energy-power#1","system":"pendulum","points":[{"position":"high","potential":"all","kinetic":"zero"},{"position":"midpoint","potential":"some","kinetic":"some"},{"position":"low","potential":"zero","kinetic":"all"}],"totalEnergy":"constant"} -->
### Power and Efficiency

**Power** ($P$) is the rate of doing work. It is measured in **watts** ($W$), where $1\ \text{W} = 1\ \text{J/s}$:

$$P_{avg} = \dfrac{W}{\Delta t}$$

If a force moves an object at a steady speed $v$ in the direction of the force, then $P = Fv$.

**Efficiency** tells how much of the energy put into a machine becomes useful output:

$$\text{efficiency} = \dfrac{\text{useful output}}{\text{total input}} \times 100\%$$

A real machine wastes some energy as heat and sound. So its efficiency is always below $100\%$.

## Examples

### #1: Work at an Angle

A student pulls a sled $10\ \text{m}$ along level ground with a rope. The rope pulls with $50\ \text{N}$ at $60^\circ$ above the ground. (a) Find the work done by the rope. (b) Find the work done by gravity on the sled.

<!-- ILLUSTRATION: sled on level ground pulled to the right by a rope at 60 degrees above the ground, pull labeled 50 N, distance labeled 10 m -->
**Solution:**

1. The rope's force is not along the motion, so use the angle.

$$W = Fd\cos\theta = (50)(10)\cos 60^\circ$$

2. Compute, using $\cos 60^\circ = 0.5$.

$$W = 500 \times 0.5 = 250\ \text{J}$$

3. Gravity points straight down. The sled moves sideways. The angle is $90^\circ$ and $\cos 90^\circ = 0$, so gravity does $0\ \text{J}$ of work.

### #2: Calculating Kinetic Energy

Find the kinetic energy of a $2\ \text{kg}$ ball moving at $6\ \text{m/s}$.

**Solution:**

1. Square the speed first: $6^2 = 36$.
2. Substitute.

$$KE = \dfrac{1}{2}(2)(36) = 36\ \text{J}$$

### #3: Calculating Potential Energy

Find the gravitational potential energy of a $5\ \text{kg}$ book held $2\ \text{m}$ above the floor. Use $g = 9.8\ \text{m/s}^2$.

**Solution:**

$$PE = mgh = (5)(9.8)(2) = 98\ \text{J}$$

### #4: Using the Work-Energy Theorem

A $4.0\ \text{kg}$ block rests on a smooth floor. A constant horizontal force of $10\ \text{N}$ pushes it $5.0\ \text{m}$ in a straight line. Find its final speed.

**Solution:**

1. The push is the net force, along the motion. Find the net work.

$$W_{net} = Fd = (10)(5.0) = 50\ \text{J}$$

2. The block starts at rest, so $KE_i = 0$ and $W_{net} = KE_f$.

$$50 = \dfrac{1}{2}(4.0)v^2$$

3. Simplify and solve.

$$v^2 = 25 \quad\Rightarrow\quad v = 5.0\ \text{m/s}$$

### #5: Conservation of Energy on a Slide

A $10\ \text{kg}$ child starts from rest at the top of a frictionless slide, $3\ \text{m}$ above the bottom. Find the speed at the bottom. Use $g = 9.8\ \text{m/s}^2$.

**Solution:**
With no friction, mechanical energy stays constant. Choose the bottom as $PE=0$.

1. Energy at the top. The child starts at rest, so $KE_i=0$.

$$PE_i = (10)(9.8)(3) = 294\ \text{J}$$

2. At the bottom, all of it is kinetic energy.

$$294 = \dfrac{1}{2}(10)v^2$$

3. Solve for $v$.

$$v^2 = 58.8 \quad\Rightarrow\quad v \approx 7.67\ \text{m/s}$$

### #6: Friction on a Ramp

A $2.0\ \text{kg}$ block slides from rest down a rough ramp. It starts $1.5\ \text{m}$ above the bottom. At the bottom its speed is $3.0\ \text{m/s}$. Find the work done by friction. Use $g = 9.8\ \text{m/s}^2$.

<!-- ILLUSTRATION: ramp with a 2.0 kg block at the top, height labeled 1.5 m, speed 3.0 m/s labeled at the bottom -->
**Solution:**
Friction is the only nonconservative force. Choose the bottom as $PE=0$.

1. Initial mechanical energy. The block starts at rest.

$$KE_i + PE_i = 0 + (2.0)(9.8)(1.5) = 29.4\ \text{J}$$

2. Final mechanical energy. The height is zero at the bottom.

$$KE_f + PE_f = \dfrac{1}{2}(2.0)(3.0)^2 + 0 = 9.0\ \text{J}$$

3. Friction's work equals the change in mechanical energy.

$$W_{nc} = 9.0 - 29.4 = -20.4\ \text{J}$$

Friction did $-20.4\ \text{J}$ of work. The $20.4\ \text{J}$ became thermal energy, not nothing.

### #7: Calculating Power

(a) A $60\ \text{kg}$ climber goes up $10\ \text{m}$ in $20\ \text{s}$. Find the average power. (b) A crane lifts a $500\ \text{kg}$ load at a steady $0.20\ \text{m/s}$. Find the power. Use $g = 9.8\ \text{m/s}^2$.

**Solution:**

1. For (a), the work equals the gain in potential energy.

$$W = mgh = (60)(9.8)(10) = 5880\ \text{J}$$

2. Divide by the time.

$$P_{avg} = \dfrac{5880}{20} = 294\ \text{W}$$

3. For (b), the speed is steady, so the net force is zero. The crane's force equals the weight.

$$F = mg = (500)(9.8) = 4900\ \text{N}$$

4. Use $P=Fv$.

$$P = (4900)(0.20) = 980\ \text{W}$$

### #8: Machine Efficiency

An electric hoist takes in $3500\ \text{J}$ of electrical energy. It lifts a $100\ \text{kg}$ load by $2.5\ \text{m}$. Find its efficiency. Use $g = 9.8\ \text{m/s}^2$.

**Solution:**

1. The useful output is the gain in potential energy.

$$PE = (100)(9.8)(2.5) = 2450\ \text{J}$$

2. Divide by the input.

$$\text{efficiency} = \dfrac{2450}{3500} \times 100\% = 70\%$$

The other $1050\ \text{J}$ was wasted as heat and sound.

## Speed Tricks & Shortcuts

For work, check the angle first. Same direction gives $W=Fd$. Perpendicular gives zero. Opposite gives a negative answer.

For a mechanical-energy problem, ask if friction does work. If not, set $KE+PE$ equal at the two states. If it does, include $W_{nc}$.

In a frictionless problem, mass cancels. In Example #5, $v=\sqrt{2gh}$ gives the same speed for any mass.

Doubling the speed makes the kinetic energy four times as large.

Power is how fast energy moves. The same work in less time means more power.

## Traps to Watch For

### #1: Using $W=Fd$ at an Angle

> For a constant force, the general expression is $W=Fd\cos\theta$.

Only the part of the force along the displacement does work. A large force at $90^\circ$ does none.

### #2: Forgetting to Square the Speed

> $KE = \dfrac{1}{2}mv^2$: the speed is squared.

Square the speed before you multiply by the other numbers.

### #3: Saying Energy Is "Lost" to Friction

> Friction lowers mechanical energy, but total energy is still conserved.

The energy becomes thermal energy, sound, or other forms. It is not destroyed.

### #4: Using $mgh$ Everywhere

> $PE=mgh$ is for gravity that is about the same everywhere.

For orbits or very large height changes, gravity changes with distance.

### #5: Mixing Up Power and Energy

> Energy is an amount in joules. Power is a rate in watts.

A machine that moves a lot of energy slowly can have less power than one that moves less energy very fast.

### #6: Efficiency Above $100\%$

> A machine cannot give out more useful energy than it takes in.

If your answer is above $100\%$, you probably put the input and the output in the wrong places.

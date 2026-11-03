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
- $\cos 180^\circ = -1$: the force points against the motion, so the work is negative. Friction on an object sliding over a surface at rest does negative work.

Work is measured in **joules** ($J$). One joule is the work of a $1\ N$ force over $1\ m$.

This formula needs a force that stays constant. A force that changes along the path needs other methods.

### Kinetic and Potential Energy

**Kinetic energy** ($KE$) is the energy of motion. Use mass $m$ in kilograms and speed $v$ in meters per second:

$$KE = \dfrac{1}{2}mv^2$$

**Gravitational potential energy** ($PE$) is stored energy from height. Near Earth's surface, use $g = 9.8\ \text{m/s}^2$ and height $h$ in meters above a level you choose as zero:

$$PE = mgh$$

The number $g$ is the acceleration due to gravity. A freely falling object, with air ignored, gains about $9.8\ \text{m/s}$ of speed every second. That is why the unit is meters per second per second, written $\text{m/s}^2$.

The **weight** of an object is the pull of gravity on it, in newtons:

$$F_g = mg$$

Only the change in $PE$ matters, so the zero level is your choice. The formula works only where gravity is about the same everywhere. For a very large change in height, such as an orbit, another formula is needed.

### The Work-Energy Theorem

The **net work** is the total work done by all forces together. The **work-energy theorem** says that net work equals the change in kinetic energy:

$$W_{net} = \Delta KE = KE_f - KE_i$$

The symbol $\Delta$ means change: the final value minus the starting value. The small letters $i$ and $f$ mean initial (at the start) and final (at the end). An object that starts at rest has $KE_i=0$.

Positive net work speeds an object up. Negative net work slows it down.

### Conservation of Energy

Energy is never created or destroyed. It changes form or moves from place to place. The total energy of an isolated system stays constant.

**Mechanical energy** is $KE+PE$. A **conservative force**, such as gravity, can give back the energy it takes. If only conservative forces do work, mechanical energy stays the same:

$$KE_i + PE_i = KE_f + PE_f$$

A **nonconservative force**, such as friction, air drag, or an applied push, pull or motor, can change mechanical energy. Friction and drag turn it into thermal energy. A push or a motor can add to it. The work $W_{nc}$ done by these forces equals the change in mechanical energy:

$$W_{nc} = \Delta(KE+PE)$$

<!-- FIGURE: {"kind":"physics-mechanics-diagram","type":"mechanical-energy","illustrationKey":"science/physics/work-energy-power#1","system":"pendulum","points":[{"position":"high","potential":"all","kinetic":"zero"},{"position":"midpoint","potential":"some","kinetic":"some"},{"position":"low","potential":"zero","kinetic":"all"}],"totalEnergy":"constant"} -->
### Power and Efficiency

**Power** ($P$) is the rate of doing work. It is measured in **watts** ($W$), where $1\ \text{W} = 1\ \text{J/s}$:

$$P_{avg} = \dfrac{W}{\Delta t}$$

Here $\Delta t$ is the time taken to do the work, in seconds.

If a force moves an object at a steady speed $v$ in the direction of the force, then $P = Fv$.

**Efficiency** tells how much of the energy put into a machine becomes useful output:

$$\text{efficiency} = \dfrac{\text{useful output}}{\text{total input}} \times 100\%$$

A real machine wastes some energy as heat and sound. So its efficiency is below $100\%$. Only an ideal machine with no waste reaches $100\%$.

A **simple machine**, such as a lever or a pulley, changes the size or direction of a force. Input work is effort force times effort distance, and output work is load force times load distance. The pulleys-and-levers lesson explains effort, load and the ideal case.

$$\text{efficiency} = \dfrac{F_{load}\,d_{load}}{F_{effort}\,d_{effort}} \times 100\%$$

This form needs both forces along the motion.

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

### #5: Net Work from Several Forces

A $3.0\ \text{kg}$ crate rests on a rough floor. A worker pushes it $6.0\ \text{m}$ with a horizontal force of $40\ \text{N}$. Friction acts against the motion with a force of $15\ \text{N}$. Find the final speed.

<!-- ILLUSTRATION: crate on a floor moving right, 40 N push arrow to the right, 15 N friction arrow to the left, distance labeled 6.0 m -->
**Solution:**

1. The push points along the motion, so $\theta=0^\circ$. Friction points against it, so $\theta=180^\circ$.

$$W_{push} = (40)(6.0)\cos 0^\circ = 240\ \text{J}$$

$$W_{friction} = (15)(6.0)\cos 180^\circ = -90\ \text{J}$$

2. Gravity and the floor's support are perpendicular to the motion. They do zero work. Add the works.

$$W_{net} = 240 - 90 = 150\ \text{J}$$

3. The crate starts at rest, so $KE_i=0$ and $W_{net}=KE_f$.

$$150 = \dfrac{1}{2}(3.0)v^2 \quad\Rightarrow\quad v^2 = 100$$

4. Take the square root.

$$v = 10\ \text{m/s}$$

### #6: Conservation of Energy on a Slide

A $10\ \text{kg}$ child starts from rest at the top of a frictionless slide, $3\ \text{m}$ above the bottom. Find the speed at the bottom. Use $g = 9.8\ \text{m/s}^2$.

**Solution:**
With no friction, mechanical energy stays constant. Choose the bottom as $PE=0$.

1. Energy at the top. The child starts at rest, so $KE_i=0$.

$$PE_i = (10)(9.8)(3) = 294\ \text{J}$$

2. At the bottom, all of it is kinetic energy.

$$294 = \dfrac{1}{2}(10)v^2$$

3. Solve for $v$.

$$v^2 = 58.8 \quad\Rightarrow\quad v \approx 7.67\ \text{m/s}$$

Check the mass. Writing $mgh=\dfrac{1}{2}mv^2$, the $m$ cancels, so a lighter child would reach the same speed.

### #7: Friction on a Ramp

A $2.0\ \text{kg}$ block slides from rest down a rough ramp. It starts $1.5\ \text{m}$ above the bottom. At the bottom its speed is $3.0\ \text{m/s}$. Find the work done by friction. Use $g = 9.8\ \text{m/s}^2$.

<!-- ILLUSTRATION: ramp with a 2.0 kg block at the top, height labeled 1.5 m, speed 3.0 m/s labeled at the bottom -->
**Solution:**
Friction is the only nonconservative force that does work. The ramp's support force is perpendicular to the motion and does none. Choose the bottom as $PE=0$.

1. Initial mechanical energy. The block starts at rest.

$$KE_i + PE_i = 0 + (2.0)(9.8)(1.5) = 29.4\ \text{J}$$

2. Final mechanical energy. The height is zero at the bottom.

$$KE_f + PE_f = \dfrac{1}{2}(2.0)(3.0)^2 + 0 = 9.0\ \text{J}$$

3. Friction's work equals the change in mechanical energy.

$$W_{nc} = 9.0 - 29.4 = -20.4\ \text{J}$$

Friction did $-20.4\ \text{J}$ of work. The $20.4\ \text{J}$ became thermal energy, not nothing.

### #8: Calculating Power

(a) A $60\ \text{kg}$ climber goes up $10\ \text{m}$ in $20\ \text{s}$. Find the average power. (b) A crane lifts a $500\ \text{kg}$ load at a steady $0.20\ \text{m/s}$. Find the power. Use $g = 9.8\ \text{m/s}^2$.

**Solution:**

1. For (a), the work equals the gain in potential energy.

$$W = mgh = (60)(9.8)(10) = 5880\ \text{J}$$

2. Divide by the time.

$$P_{avg} = \dfrac{5880}{20} = 294\ \text{W}$$

3. For (b), the speed is steady, so the net force is zero. The crane's force equals the weight $F_g=mg$.

$$F = mg = (500)(9.8) = 4900\ \text{N}$$

4. Use $P=Fv$.

$$P = (4900)(0.20) = 980\ \text{W}$$

### #9: Efficiency of a Pulley System

A worker lifts a $50\ \text{kg}$ load by $2.0\ \text{m}$ with a pulley system. The worker pulls the rope with a steady $350\ \text{N}$ force through $4.0\ \text{m}$. Find the efficiency. Use $g = 9.8\ \text{m/s}^2$.

<!-- ILLUSTRATION: movable pulley supporting a 50 kg load with two rope segments, load rising 2.0 m, rope end pulled 4.0 m with a 350 N effort -->
**Solution:**

1. The load force is its weight.

$$F_{load} = mg = (50)(9.8) = 490\ \text{N}$$

2. Find the useful output work and the input work.

$$W_{out} = (490)(2.0) = 980\ \text{J}$$

$$W_{in} = (350)(4.0) = 1400\ \text{J}$$

3. Divide the output by the input.

$$\text{efficiency} = \dfrac{980}{1400} \times 100\% = 70\%$$

The other $420\ \text{J}$ was wasted, mostly as heat from friction. An ideal system would need only $245\ \text{N}$ of effort.

## Speed Tricks & Shortcuts

For work by a constant force, check the angle first. Same direction gives $W=Fd$, perpendicular gives zero, and opposite gives a negative answer.

For a mechanical-energy problem, ask if any force other than gravity or a spring does work. Friction, air drag, a push, a pull and a motor all count. If none does, set $KE+PE$ equal at the two states. If one does, include $W_{nc}$.

If an object starts from rest and only gravity does work, mass cancels. Then $mgh=\dfrac{1}{2}mv^2$ gives $v=\sqrt{2gh}$, where $h$ is the drop in height. It fails if the object already has speed or if any other force does work.

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

> Friction from a surface at rest lowers mechanical energy, but total energy is still conserved.

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

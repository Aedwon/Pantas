---
_id: "lesson-physics-fluid-mechanics"
title: "Fluid Mechanics (Density, Pressure, Buoyancy, Archimedes' Principle, Bernoulli's Principle)"
summary: "How density, pressure, and buoyancy work in fluids, and how pressure, speed, and height relate in ideal flow."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 12
isActive: true
---
## Core Concept

A **fluid** is a substance that can flow; liquids and gases are both fluids.

### Density and Pressure

**Density** ($\rho$) is mass per unit volume:

$$\rho = \dfrac{m}{V}$$

**Pressure** ($P$) is normal force per unit area:

$$P = \dfrac{F_\perp}{A}$$

In a fluid at rest, pressure at a point acts in all directions. For a fluid of approximately constant density under gravity, pressure increases with depth according to

$$P = P_0 + \rho gh$$

where $P_0$ is the pressure at the reference surface and $h$ is the depth below it.

### Archimedes' Principle and Buoyancy

**Archimedes' principle** states that the upward **buoyant force** on a body immersed partly or fully in a fluid equals the weight of the fluid displaced:

$$F_B = \rho_{fluid}gV_{displaced}$$

For a freely floating object in static equilibrium, the buoyant force equals the object's weight. Whether an object ultimately floats, sinks, or remains suspended depends on the balance of forces and, for simple freely immersed objects, on its average density relative to the fluid.

<!-- ILLUSTRATION: two objects submerged in water, one less dense than water shown floating with a buoyant force arrow equal to its weight arrow, and one denser than water shown sinking with a buoyant force arrow smaller than its weight arrow -->

### Bernoulli's Equation

For **steady, incompressible, nonviscous flow along a streamline**, Bernoulli's equation relates pressure, flow speed, and height:

$$P + \dfrac{1}{2}\rho v^2 + \rho gh = \text{constant}$$

A useful special case occurs when comparing two points at the same height in such a flow: if the other assumptions hold, greater speed corresponds to lower static pressure. This is not a universal rule for every moving fluid; height changes, viscosity, pumps, turbulence, compressibility, and comparisons between different streamlines can all matter.

Bernoulli's equation helps analyze pressure distributions around wings, but airplane lift should not be reduced to the claim that air must travel faster over a curved top because that path is longer. Real lift results from the wing's pressure distribution and the downward deflection of airflow; angle of attack, wing shape, circulation, viscosity, and other aerodynamic effects matter.

## Examples

### #1: Calculating Density

An object has a mass of $500 \text{ g}$ and a volume of $200 \text{ cm}^3$. Find its density.

**Solution:**

$$\rho = \dfrac{500}{200} = 2.5 \text{ g/cm}^3$$

### #2: Will It Float or Sink?

A solid object with average density $0.8 \text{ g/cm}^3$ is placed freely in water of density $1.0 \text{ g/cm}^3$. Neglect trapped bubbles or other external forces. Will it float or sink?

**Solution:**

1. The object's average density is lower than the water's density.
2. It can displace a volume of water whose weight equals its own before becoming fully submerged.
3. It therefore floats partially submerged.

### #3: Applying Archimedes' Principle

A solid block, fully submerged in water, displaces $300 \text{ cm}^3$ of water. Given that water has a density of $1 \text{ g/cm}^3$ and use $g = 9.8 \text{ m/s}^2$, find the buoyant force.

**Solution:**

1. Mass of displaced water:

$$m = \rho V = (1 \text{ g/cm}^3)(300 \text{ cm}^3)=300\text{ g}=0.3\text{ kg}$$

2. Weight of displaced water:

$$F_B = mg = (0.3)(9.8)=2.94\text{ N}$$

3. The buoyant force is $2.94\text{ N}$ upward.

### #4: Applying Bernoulli's Equation in a Horizontal Pipe

Water flows steadily through a horizontal pipe that narrows. At point 1 the water moves more slowly; at point 2 it moves faster. Assume the water is incompressible, viscosity is negligible, and the two points are at the same height. Which point has greater static pressure?

**Solution:**

With $h_1=h_2$, Bernoulli's equation gives

$$P_1+\frac12\rho v_1^2=P_2+\frac12\rho v_2^2$$

Since $v_2>v_1$, the kinetic-energy-per-volume term is larger at point 2, so its static-pressure term is smaller:

$$P_2<P_1$$

The faster section has lower static pressure **under these stated Bernoulli conditions**.

## Speed Tricks & Shortcuts

For buoyancy calculations, use the **displaced fluid**, not the object's material:

$$F_B=\rho_{fluid}gV_{displaced}$$

For simple float/sink questions involving a freely immersed object, compare its average density with the fluid's density. For unusual shapes, attached forces, sealed containers, or changing fluid density, analyze the actual forces and displaced volume.

For Bernoulli questions, do not memorize only “faster means lower pressure.” First check whether the comparison is along an idealized steady streamline and whether the two points are at the same height. If height changes, keep the $\rho gh$ term.

## Traps to Watch For

### #1: Using the Object's Density to Calculate Buoyant Force

> Archimedes' principle uses the density and displaced volume of the **fluid**.

The object's density can help predict floating behavior, but the buoyant-force formula itself depends on displaced fluid.

### #2: Assuming Bigger Objects Always Sink

> Floating depends on force balance and average density, not size alone.

A large hollow ship can float while a much smaller solid piece of dense metal sinks.

### #3: Treating “Faster Fluid = Lower Pressure” as Universal

> That relationship is a special consequence of Bernoulli's equation under stated conditions, especially when height is unchanged.

A pump can raise both pressure and speed; a vertical flow trades energy with gravitational potential; viscous and turbulent flows lose mechanical energy.

### #4: Using the Equal-Transit-Time Wing Myth

> Air parcels split at a wing's leading edge are not required to meet again at the trailing edge.

Do not argue that the upper stream must move faster merely because the upper surface is longer. Lift is understood through the actual pressure field and momentum change of the airflow.

### #5: Saying Fluid Pressure Is the Same Everywhere

> A fluid at rest has pressure that acts in all directions at a point, but its magnitude generally changes with depth.

For constant density in gravity, deeper points have greater pressure by approximately $\rho gh$.

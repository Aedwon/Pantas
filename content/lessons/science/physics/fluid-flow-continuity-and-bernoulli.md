---
_id: "lesson-physics-fluid-flow-continuity-and-bernoulli"
title: "Fluid Flow (Continuity and Bernoulli's Equation)"
summary: "How flow speed, pressure, and height are linked in a moving fluid, using the continuity equation and Bernoulli's equation with the conditions each needs."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 8
isActive: true
---
## Core Concept

A **fluid** is a substance that can flow. Liquids and gases are both fluids. This lesson looks at fluids that are moving, mostly water in pipes.

It uses density ($\rho$, mass in one unit of volume), pressure ($P$, force pushing straight into a surface divided by its area, measured in pascals, $\text{Pa}$), and the pressure of a fluid at depth. These are taught in Fluid Statics (Density, Pressure, Pascal's Principle, Buoyancy), so learn that lesson first. The symbol $g$ is the acceleration due to gravity, about $9.8 \text{ m/s}^2$ near Earth's surface.

### Continuity: Flow Speed in a Pipe

The **volume flow rate** is the volume of fluid passing a point each second. For a steady flow of an incompressible fluid in a pipe with no leaks, the same volume per second passes each cross-section. The **continuity equation** says:

$$A_1 v_1 = A_2 v_2$$

Here $A$ is the cross-sectional area and $v$ is the flow speed. When the pipe narrows, the fluid speeds up. When the pipe widens, the fluid slows down.

The equation assumes an incompressible fluid, so it is not accurate for a gas that is strongly compressed or expanded along the pipe.

### Bernoulli's Equation

Some terms first. A **streamline** is the path a small bit of fluid follows. A flow is **steady** when the speed and pressure at each point do not change with time.

A flow is **nonviscous** when the fluid has no internal friction. **Viscosity** is that internal friction, like the thickness of honey. The **static pressure** is the pressure the fluid itself exerts, the $P$ in the equation.

A flow is called **ideal** when it is steady, incompressible and nonviscous. If a question says "ideal flow" or "ideal fluid", use continuity and Bernoulli's equation, and apply Bernoulli's equation along one streamline.

For steady, incompressible, nonviscous flow along a streamline, **Bernoulli's equation** links pressure, speed, and height:

$$P + \dfrac{1}{2}\rho v^2 + \rho gh = \text{constant}$$

Here $h$ is the height of the point above any chosen reference level. The equation is an energy balance for the fluid.

The term $\dfrac{1}{2}\rho v^2$ is the kinetic energy in each unit of volume. The term $\rho gh$ is the gravitational potential energy in each unit of volume.

To compare two points on the same streamline, write:

$$P_1 + \dfrac{1}{2}\rho v_1^2 + \rho g h_1 = P_2 + \dfrac{1}{2}\rho v_2^2 + \rho g h_2$$

A useful special case is two points at the same height. The $\rho gh$ terms cancel. Then the point with the higher speed has the lower static pressure.

This comparison holds only when the stated assumptions hold. Height changes, viscosity, pumps, turbulence, compressibility, and comparing different streamlines can all change the result.

Bernoulli's equation helps explain the pressure around a wing. Do not explain lift by saying air must travel faster over the curved top because that path is longer. Air that splits at the front of the wing does not have to meet again at the back.

Real lift comes from the pressure pattern around the wing and from the wing pushing air downward. Angle of attack, wing shape, and viscosity matter too.

<!-- ILLUSTRATION: horizontal pipe that narrows from a wide section (point 1, area A1, slow arrows, speed v1) to a narrow section (point 2, area A2, fast arrows, speed v2), with two vertical pressure gauges above points 1 and 2 where the gauge at point 2 shows a lower liquid column -->

## Examples

In exam questions, "neglect" or "ignore" means leave that effect out of your calculation. Use $g = 9.8 \text{ m/s}^2$ and water density $1000 \text{ kg/m}^3$ in the examples below unless a question gives other values.

### #1: Continuity and Bernoulli in a Horizontal Pipe

Water flows steadily through a horizontal pipe. In the wide section, the area is $4.0 \times 10^{-3} \text{ m}^2$, the speed is $2.0 \text{ m/s}$, and the pressure is $2.00 \times 10^5 \text{ Pa}$. The pipe narrows to an area of $1.0 \times 10^{-3} \text{ m}^2$. Assume the water is incompressible and nonviscous. Find the speed and the pressure in the narrow section.

**Solution:**

1. Use continuity to find the speed:

$$v_2 = v_1 \dfrac{A_1}{A_2} = 2.0 \times \dfrac{4.0 \times 10^{-3}}{1.0 \times 10^{-3}} = 8.0 \text{ m/s}$$

2. The pipe is horizontal, so $h_1 = h_2$ and the height terms cancel:

$$P_1 + \dfrac{1}{2}\rho v_1^2 = P_2 + \dfrac{1}{2}\rho v_2^2$$

3. Solve for $P_2$:

$$P_2 = P_1 + \dfrac{1}{2}\rho (v_1^2 - v_2^2)$$

$$P_2 = 2.00 \times 10^5 + \dfrac{1}{2}(1000)(4.0 - 64)$$

$$P_2 = 2.00 \times 10^5 - 3.0 \times 10^4$$

$$P_2 = 1.70 \times 10^5 \text{ Pa}$$

4. The water in the narrow section moves at $8.0 \text{ m/s}$ and has the lower pressure, $1.70 \times 10^5 \text{ Pa}$.

### #2: Bernoulli When the Height Changes

Water flows steadily through a pipe of constant width that rises $5.0 \text{ m}$ from point $1$ to point $2$. The pressure at point $1$ is $3.00 \times 10^5 \text{ Pa}$. Assume ideal flow (steady, incompressible and nonviscous). Find the pressure at point $2$.

**Solution:**

1. The pipe has constant width, so continuity gives $v_1 = v_2$. The $\dfrac{1}{2}\rho v^2$ terms cancel.

2. Bernoulli's equation becomes:

$$P_1 + \rho g h_1 = P_2 + \rho g h_2$$

3. Solve for $P_2$ with $h_2 - h_1 = 5.0 \text{ m}$:

$$P_2 = P_1 - \rho g (h_2 - h_1)$$

$$P_2 = 3.00 \times 10^5 - (1000)(9.8)(5.0)$$

$$P_2 = 3.00 \times 10^5 - 0.49 \times 10^5$$

$$P_2 = 2.51 \times 10^5 \text{ Pa}$$

4. The pressure at point $2$ is $2.51 \times 10^5 \text{ Pa}$. The speed did not change here, yet the pressure fell because the water is higher.

## Speed Tricks & Shortcuts

For Bernoulli questions, do not rely on "faster means lower pressure" alone. First check that both points are on the same streamline in ideal flow (steady, incompressible, nonviscous). Then check the heights. If the heights differ, keep the $\rho gh$ term.

## Traps to Watch For

### #1: Treating "Faster Fluid, Lower Pressure" as a Universal Rule

> That relationship comes from Bernoulli's equation under stated conditions, mainly at constant height.

A pump can raise both pressure and speed. Vertical flow trades pressure with height. Viscous and turbulent flows lose mechanical energy.

### #2: Using the Equal-Transit-Time Wing Myth

> Air that splits at a wing's front is not required to meet again at the back.

Do not argue that the top air must go faster just because the top surface is longer. Lift is explained by the real pressure pattern and the change in the air's motion.

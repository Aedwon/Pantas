---
_id: "lesson-physics-bernoullis-equation-and-height"
title: "Bernoulli’s Equation and Height"
summary: "Use the energy balance for ideal flow when pipe height changes."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 2
partCount: 3
ordering: 0
keyPoints:
  - "Identify the conditions for Bernoulli’s equation."
  - "Identify fluid energy terms and use the equation when height changes."
---
## Core Concept

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

## Examples

In exam questions, "neglect" or "ignore" means leave that effect out of your calculation. Use $g = 9.8 \text{ m/s}^2$ and water density $1000 \text{ kg/m}^3$ in the examples below unless a question gives other values.

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

For Bernoulli questions, do not rely on "faster means lower pressure" alone. First check that both points are on the same streamline in ideal flow (steady, incompressible, nonviscous). Then check the heights, and keep the $\rho gh$ term if they differ.

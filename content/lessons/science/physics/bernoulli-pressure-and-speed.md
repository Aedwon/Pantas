---
_id: "lesson-physics-bernoulli-pressure-and-speed"
title: "Bernoulli Pressure and Speed"
summary: "Compare fluid pressures as speed changes along a horizontal pipe or near a wing."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 3
partCount: 3
ordering: 68
keyPoints:
  - "Compare pressure and speed at equal heights under the stated conditions."
  - "Explain what the pressure difference does around a wing."
---
## Core Concept

A useful special case is two points at the same height. The $\rho gh$ terms cancel. Then the point with the higher speed has the lower static pressure.

Use this comparison at equal heights along one streamline. The flow must be steady, keep the same density, and have no internal friction. No device can add or take out energy between the points.

Bernoulli's equation helps explain the pressure around a wing. Do not explain lift by saying air must travel faster over the curved top because that path is longer. Air that splits at the front of the wing does not have to meet again at the back.

Real lift comes from the pressure pattern around the wing and from the wing pushing air downward. Angle of attack, wing shape, and viscosity matter too.

<!-- ILLUSTRATION: horizontal pipe that narrows from a wide section (point 1, area A1, slow arrows, speed v1) to a narrow section (point 2, area A2, fast arrows, speed v2), with two vertical pressure gauges above points 1 and 2 where the gauge at point 2 shows a lower liquid column -->

## Examples

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

## Traps to Watch For

### #1: Treating "Faster Fluid, Lower Pressure" as a Universal Rule

> That relationship comes from Bernoulli's equation under stated conditions, mainly at constant height.

A pump can raise both pressure and speed. Vertical flow trades pressure with height. Viscous and turbulent flows lose mechanical energy.

### #2: Using the Equal-Transit-Time Wing Myth

> Air that splits at a wing's front is not required to meet again at the back.

Do not argue that the top air must go faster just because the top surface is longer. Lift is explained by the real pressure pattern and the change in the air's motion.

---
_id: "lesson-physics-fluid-mechanics"
title: "Fluid Mechanics (Density, Pressure, Buoyancy, Archimedes' Principle, Bernoulli's Principle)"
summary: "How density, pressure, buoyancy, hydraulic systems, and ideal flow work in liquids and gases, with the conditions each rule needs."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 15
isActive: true
---
## Core Concept

A **fluid** is a substance that can flow. Liquids and gases are both fluids. This lesson mostly uses water, but the same ideas work for air.

Two units appear again and again. A **newton** ($\text{N}$) is the unit of force. A **pascal** ($\text{Pa}$) is the unit of pressure, and $1 \text{ Pa} = 1 \text{ N/m}^2$. The symbol $g$ is the acceleration due to gravity, about $9.8 \text{ m/s}^2$ near Earth's surface. The **weight** of an object is $W = mg$, the downward pull of gravity on its mass $m$.

### Density

**Density** ($\rho$) is the mass in one unit of volume. A dense material packs more mass into the same space.

$$\rho = \dfrac{m}{V}$$

Water has a density of about $1000 \text{ kg/m}^3$, which is the same as $1 \text{ g/cm}^3$. To change $\text{g/cm}^3$ to $\text{kg/m}^3$, multiply by $1000$. The density of a gas changes a lot when its pressure or temperature changes. The density of a liquid changes very little.

### Pressure

**Pressure** ($P$) is the force pushing straight into a surface, divided by the area of that surface. "Straight into" means at a right angle to the surface.

$$P = \dfrac{F_\perp}{A}$$

The same force on a smaller area gives a larger pressure. This is why a sharp knife cuts better than a dull one.

### Pressure and Depth

In a fluid at rest, the pressure at a point pushes equally in all directions. Deeper points have more pressure because there is more fluid above them pressing down.

For a fluid with constant density, the pressure at depth $h$ is:

$$P = P_0 + \rho gh$$

Here $P_0$ is the pressure at the top surface, and $h$ is the depth below that surface. For a lake open to the air, $P_0$ is the **atmospheric pressure**, about $1.01 \times 10^5 \text{ Pa}$ near sea level. This full value is the **absolute pressure**. The part $\rho gh$ alone is the **gauge pressure**, the pressure above the surface pressure.

Look at what the formula contains. It has the fluid's density, $g$, and the depth. It does not contain the shape of the container or the amount of liquid. Two points at the same depth in the same connected liquid at rest have the same pressure, even if one container is wide and the other is narrow. The formula assumes the density stays constant, so it is good for liquids over small depth ranges. For a tall column of gas, density changes with height and this formula does not hold.

<!-- ILLUSTRATION: three connected containers of different shapes (narrow tube, wide tank, slanted tube) all filled with water to the same level, with a horizontal dashed line at depth h below the surface marked in each container and the label "same depth h, same pressure" -->

### Pascal's Principle and Hydraulic Systems

**Pascal's principle** says that when you change the pressure on an enclosed fluid at rest, the change is passed on, by the same amount, to each part of the fluid and to the container walls. The fluid must be incompressible, which means it cannot be squeezed into a smaller volume. Liquids behave this way very closely.

A **hydraulic system** uses this idea. Two pistons (sliding plugs) close two connected cylinders filled with liquid. The small piston has area $A_1$ and the large piston has area $A_2$. A force $F_1$ on the small piston raises the pressure in the liquid by $\dfrac{F_1}{A_1}$. That same pressure change pushes on the large piston.

$$\dfrac{F_1}{A_1} = \dfrac{F_2}{A_2}$$

This gives the output force:

$$F_2 = F_1 \dfrac{A_2}{A_1}$$

A large area ratio gives a large force, so a small push can lift a heavy car. You do not get extra energy, though. The liquid is incompressible, so the volume it moves is the same at both pistons. This means the small piston moves a long way while the large piston moves a short way:

$$A_1 d_1 = A_2 d_2$$

Here $d_1$ and $d_2$ are the distances moved. In the ideal case, the work done on each piston, force times distance, comes out equal. For circular pistons, the area ratio equals the square of the ratio of their diameters.

The formula $\dfrac{F_1}{A_1} = \dfrac{F_2}{A_2}$ assumes an ideal system: no friction, no trapped air, and both pistons at the same height. If the pistons are at different heights, the liquid's weight adds a pressure of $\rho gh$ between them. In real machines, friction and trapped air make the output force smaller.

<!-- ILLUSTRATION: hydraulic lift with a small piston of area A1 on the left and a large piston of area A2 on the right joined by a liquid-filled tube; arrows show force F1 pushing down on the small piston and force F2 pushing up on the large piston; distances d1 (large) and d2 (small) labeled -->

### Archimedes' Principle and Buoyancy

Pressure is higher at the bottom of an object in a fluid than at the top. This difference pushes the object up. The upward push is the **buoyant force** ($F_B$).

**Archimedes' principle** says the buoyant force on an object that is partly or fully in a fluid equals the weight of the fluid it **displaces**. To displace fluid means to push it out of the way. A fully submerged object displaces a volume equal to its own volume. A floating object displaces only the volume that is below the surface.

$$F_B = \rho_{fluid}\, g\, V_{displaced}$$

Look at what this formula uses. It uses the density of the fluid, not the density of the object. The buoyant force equals the object's own weight only when the object floats or hangs still in the fluid.

Now think about the forces on an object. Weight pulls down and the buoyant force pushes up.

- If $F_B < W$, the net force is downward and the object sinks.
- If $F_B = W$, the forces balance and the object floats or stays suspended.
- If an object is held under the surface and $F_B > W$, it rises when released until it floats.

A scale holding an object under water shows a smaller reading than in air. This reading is the **apparent weight**:

$$W_{apparent} = W - F_B$$

For a solid object let go in a fluid, you can compare densities. The object's **average density** is its total mass divided by its total volume, including any hollow spaces. If the average density is less than the fluid's, it floats. If it is more, it sinks. If it is equal, it stays suspended.

A floating object with uniform density also has a simple rule. The fraction of its volume below the surface is $\dfrac{\rho_{object}}{\rho_{fluid}}$. This rule needs the object to be floating at rest and to have the same density throughout.

The density rule works for an object that is free to move and surrounded by fluid. It does not predict what happens if the object is tied down, pushed by another force, or sealed against the container floor with no fluid under it. For those cases, draw the forces and work out the displaced volume.

<!-- ILLUSTRATION: two beakers of water side by side; left shows a floating block with arrows "weight W down" and "buoyant force F_B up" of equal length; right shows a sinking block with F_B arrow shorter than the W arrow -->

### Continuity: Flow Speed in a Pipe

The **volume flow rate** is the volume of fluid passing a point each second. For a steady flow of an incompressible fluid in a pipe with no leaks, the same volume per second passes each cross-section. The **continuity equation** says:

$$A_1 v_1 = A_2 v_2$$

Here $A$ is the cross-sectional area and $v$ is the flow speed. When the pipe narrows, the fluid speeds up. When the pipe widens, the fluid slows down. The equation assumes an incompressible fluid, so it is not accurate for a gas that is strongly compressed or expanded along the pipe.

### Bernoulli's Equation

Some terms first. A **streamline** is the path a small bit of fluid follows. A flow is **steady** when the speed and pressure at each point do not change with time. A flow is **nonviscous** when the fluid has no internal friction. **Viscosity** is that internal friction, like the thickness of honey. The **static pressure** is the pressure the fluid itself exerts, the $P$ in the equation.

For steady, incompressible, nonviscous flow along a streamline, **Bernoulli's equation** links pressure, speed, and height:

$$P + \dfrac{1}{2}\rho v^2 + \rho gh = \text{constant}$$

Here $h$ is the height of the point above any chosen reference level. The equation is an energy balance for the fluid. The term $\dfrac{1}{2}\rho v^2$ is the kinetic energy in each unit of volume. The term $\rho gh$ is the gravitational potential energy in each unit of volume.

To compare two points on the same streamline, write:

$$P_1 + \dfrac{1}{2}\rho v_1^2 + \rho g h_1 = P_2 + \dfrac{1}{2}\rho v_2^2 + \rho g h_2$$

A useful special case is two points at the same height. The $\rho gh$ terms cancel. Then the point with the higher speed has the lower static pressure. This comparison holds only when the stated assumptions hold. Height changes, viscosity, pumps, turbulence, compressibility, and comparing different streamlines can all change the result.

Bernoulli's equation helps explain the pressure around a wing. Airplane lift should not be explained by saying air must travel faster over the curved top because that path is longer. Air that splits at the front of the wing does not have to meet again at the back. Real lift comes from the pressure pattern around the wing and from the wing pushing air downward. Angle of attack, wing shape, and viscosity matter too.

<!-- ILLUSTRATION: horizontal pipe that narrows from a wide section (point 1, area A1, slow arrows, speed v1) to a narrow section (point 2, area A2, fast arrows, speed v2), with two vertical pressure gauges above points 1 and 2 where the gauge at point 2 shows a lower liquid column -->

## Examples

In exam questions, "neglect" or "ignore" means leave that effect out of your calculation. Use $g = 9.8 \text{ m/s}^2$ and water density $1000 \text{ kg/m}^3$ in the examples below unless a question gives other values.

### #1: Calculating Density

An object has a mass of $500 \text{ g}$ and a volume of $200 \text{ cm}^3$. Find its density.

**Solution:**

$$\rho = \dfrac{500}{200} = 2.5 \text{ g/cm}^3$$

The density is $2.5 \text{ g/cm}^3$, which is $2500 \text{ kg/m}^3$.

### #2: Pressure at Depth

A diver is $12 \text{ m}$ below the surface of a freshwater lake that is open to the air. The atmospheric pressure is $1.01 \times 10^5 \text{ Pa}$. Find the gauge pressure and the absolute pressure at the diver.

**Solution:**

1. The gauge pressure is $\rho gh$:

$$\rho gh = (1000)(9.8)(12) = 1.176 \times 10^5 \text{ Pa}$$

2. The absolute pressure adds the atmospheric pressure:

$$P = P_0 + \rho gh = 1.01 \times 10^5 + 1.176 \times 10^5 = 2.186 \times 10^5 \text{ Pa}$$

3. The gauge pressure is about $1.18 \times 10^5 \text{ Pa}$ and the absolute pressure is about $2.19 \times 10^5 \text{ Pa}$.

### #3: A Hydraulic Lift

A hydraulic lift has a small piston of area $20 \text{ cm}^2$ and a large piston of area $400 \text{ cm}^2$. A worker pushes the small piston with a force of $150 \text{ N}$. Neglect friction and assume both pistons are at the same height. Find the force on the large piston and the distance the small piston moves when the large piston rises $2.0 \text{ cm}$.

**Solution:**

1. The pressure change is the same at both pistons, so:

$$F_2 = F_1 \dfrac{A_2}{A_1} = 150 \times \dfrac{400}{20} = 3000 \text{ N}$$

2. The liquid volume moved is the same at both pistons, so $A_1 d_1 = A_2 d_2$:

$$d_1 = d_2 \dfrac{A_2}{A_1} = 2.0 \times \dfrac{400}{20} = 40 \text{ cm}$$

3. The large piston pushes up with $3000 \text{ N}$. The small piston moves $40 \text{ cm}$. The areas are in the same unit on top and bottom, so no unit change is needed.

### #4: Floating Fraction

A uniform block has a density of $800 \text{ kg/m}^3$ and a volume of $0.0020 \text{ m}^3$. It floats at rest in water. Find the volume of water it displaces.

**Solution:**

1. Find the block's mass and weight:

$$m = \rho V = (800)(0.0020) = 1.6 \text{ kg}$$

$$W = mg = (1.6)(9.8) = 15.68 \text{ N}$$

2. The block floats at rest, so the buoyant force equals its weight. Use $F_B = \rho_{fluid} g V_{displaced}$:

$$V_{displaced} = \dfrac{F_B}{\rho_{fluid} g} = \dfrac{15.68}{(1000)(9.8)} = 0.0016 \text{ m}^3$$

3. The block displaces $0.0016 \text{ m}^3$ of water. This is $80\%$ of its volume, which matches $\dfrac{800}{1000}$.

### #5: Buoyant Force on a Submerged Block

A solid block, fully submerged in water, displaces $300 \text{ cm}^3$ of water. Find the buoyant force.

**Solution:**

1. Change the volume to cubic meters. Since $1 \text{ cm}^3 = 10^{-6} \text{ m}^3$:

$$V = 300 \times 10^{-6} = 3.0 \times 10^{-4} \text{ m}^3$$

2. The buoyant force equals the weight of the displaced water:

$$F_B = \rho_{fluid} g V = (1000)(9.8)(3.0 \times 10^{-4}) = 2.94 \text{ N}$$

3. The buoyant force is $2.94 \text{ N}$ upward. It does not depend on what the block is made of.

### #6: Apparent Weight Under Water

A solid object has a mass of $2.7 \text{ kg}$ and a volume of $1.0 \times 10^{-3} \text{ m}^3$. It hangs from a spring scale and is fully submerged in water. What does the scale read in newtons?

**Solution:**

1. Weight in air:

$$W = mg = (2.7)(9.8) = 26.46 \text{ N}$$

2. Buoyant force, using the object's full volume as the displaced volume:

$$F_B = \rho_{fluid} g V = (1000)(9.8)(1.0 \times 10^{-3}) = 9.8 \text{ N}$$

3. The scale reads the apparent weight:

$$W_{apparent} = W - F_B = 26.46 - 9.8 = 16.66 \text{ N}$$

The scale reads about $16.7 \text{ N}$.

### #7: Continuity and Bernoulli in a Horizontal Pipe

Water flows steadily through a horizontal pipe. In the wide section, the area is $4.0 \times 10^{-3} \text{ m}^2$, the speed is $2.0 \text{ m/s}$, and the pressure is $2.00 \times 10^5 \text{ Pa}$. The pipe narrows to an area of $1.0 \times 10^{-3} \text{ m}^2$. Assume the water is incompressible and nonviscous. Find the speed and the pressure in the narrow section.

**Solution:**

1. Use continuity to find the speed:

$$v_2 = v_1 \dfrac{A_1}{A_2} = 2.0 \times \dfrac{4.0 \times 10^{-3}}{1.0 \times 10^{-3}} = 8.0 \text{ m/s}$$

2. The pipe is horizontal, so $h_1 = h_2$ and the height terms cancel:

$$P_1 + \dfrac{1}{2}\rho v_1^2 = P_2 + \dfrac{1}{2}\rho v_2^2$$

3. Solve for $P_2$:

$$P_2 = P_1 + \dfrac{1}{2}\rho (v_1^2 - v_2^2) = 2.00 \times 10^5 + \dfrac{1}{2}(1000)(4.0 - 64)$$

$$P_2 = 2.00 \times 10^5 - 3.0 \times 10^4 = 1.70 \times 10^5 \text{ Pa}$$

4. The water in the narrow section moves at $8.0 \text{ m/s}$ and has the lower pressure, $1.70 \times 10^5 \text{ Pa}$.

### #8: Bernoulli When the Height Changes

Water flows steadily through a pipe of constant width that rises $5.0 \text{ m}$ from point 1 to point 2. The pressure at point 1 is $3.00 \times 10^5 \text{ Pa}$. Assume ideal flow. Find the pressure at point 2.

**Solution:**

1. The pipe has constant width, so continuity gives $v_1 = v_2$. The $\dfrac{1}{2}\rho v^2$ terms cancel.

2. Bernoulli's equation becomes:

$$P_1 + \rho g h_1 = P_2 + \rho g h_2$$

3. Solve for $P_2$ with $h_2 - h_1 = 5.0 \text{ m}$:

$$P_2 = P_1 - \rho g (h_2 - h_1) = 3.00 \times 10^5 - (1000)(9.8)(5.0)$$

$$P_2 = 3.00 \times 10^5 - 0.49 \times 10^5 = 2.51 \times 10^5 \text{ Pa}$$

4. The pressure at point 2 is $2.51 \times 10^5 \text{ Pa}$. The speed did not change here, yet the pressure fell because the water is higher.

## Speed Tricks & Shortcuts

For buoyancy, use the **displaced fluid**, not the object's material:

$$F_B = \rho_{fluid}\, g\, V_{displaced}$$

For a floating object, set $F_B = W$. For a fully submerged object, the displaced volume is the object's volume.

For a float or sink question about a free object, compare its average density with the fluid's density. For tied-down objects, extra forces, or sealed bases, analyze the actual forces.

For a hydraulic lift, the force ratio equals the area ratio: $\dfrac{F_2}{F_1} = \dfrac{A_2}{A_1}$. Use the same area unit for both pistons. The distance ratio is the inverse of the area ratio, and the work stays equal in the ideal case.

For a liquid at rest, pressure at depth depends on the depth, the liquid's density, and $g$. Ignore container width and shape.

For Bernoulli questions, do not rely on "faster means lower pressure" alone. First check that both points are on the same streamline in steady, ideal flow. Then check the heights. If the heights differ, keep the $\rho gh$ term.

## Traps to Watch For

### #1: Using the Object's Density in the Buoyant Force

> The buoyant force formula uses the density and displaced volume of the **fluid**.

The object's density helps predict floating, but it does not go into $F_B = \rho_{fluid} g V_{displaced}$. A heavy object and a light object of the same volume, both fully submerged in water, feel the same buoyant force.

### #2: Saying Buoyant Force Always Equals the Object's Weight

> The buoyant force equals the object's weight only when the object floats or is suspended at rest.

A sinking object has $F_B < W$. What does not change is that the buoyant force equals the weight of the displaced fluid.

### #3: Assuming Bigger Objects Sink

> Size alone does not decide floating. Average density does.

A large hollow ship floats because its average density, with all the air inside, is less than water. A small solid piece of dense metal sinks.

### #4: Thinking Container Shape Changes Liquid Pressure

> For a liquid at rest, pressure depends on depth, density, and $g$, not on the container's shape or the amount of liquid.

A narrow tube and a wide tank filled to the same height give the same pressure at the bottom. The sloping or narrow walls of the container carry part of the liquid's weight, so the bottom pressure is not set by the total amount of liquid.

### #5: Expecting Free Work from a Hydraulic Lift

> A hydraulic system multiplies force, but the output work cannot be larger than the input work.

The large piston moves a shorter distance than the small piston. In a real machine, friction makes the output work even smaller.

### #6: Treating "Faster Fluid, Lower Pressure" as a Universal Rule

> That relationship comes from Bernoulli's equation under stated conditions, mainly at constant height.

A pump can raise both pressure and speed. Vertical flow trades pressure with height. Viscous and turbulent flows lose mechanical energy.

### #7: Using the Equal-Transit-Time Wing Myth

> Air that splits at a wing's front is not required to meet again at the back.

Do not argue that the top air must go faster just because the top surface is longer. Lift is explained by the real pressure pattern and the change in the air's motion.

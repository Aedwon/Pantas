---
_id: "lesson-mechanical-technical-reasoning-fluid-pressure"
title: "Fluid Pressure in Pipes and Containers"
summary: "Learn hydrostatic pressure, communicating vessels, hydraulic systems, continuity, and the conditions behind pressure-speed comparisons in flowing fluids."
subject: "subject-reasoning"
topic: "topic-mechanical-technical-reasoning"
estimatedMinutes: 12
isActive: true
---
## Core Concept

Fluid questions in mechanical reasoning use simple, idealized models. A **fluid** is a liquid or a gas. Each model works only under its stated conditions, so check the conditions first.

### What Pressure Means

**Pressure** is the force pressing on each unit of area:

$$P=\dfrac{F}{A}.$$

Force is measured in newtons ($\text{N}$). The unit of pressure is the **pascal** (Pa), which is $1\ \text{N}$ on each square meter. The same force on a smaller area gives a larger pressure.

**Density** $\rho$ is the mass of a fluid in each unit of volume. Water has a density of about $1000\ \text{kg/m}^3$. Oil is lighter: common cooking oils are about $910$ to $930\ \text{kg/m}^3$.

### Pressure in a Fluid at Rest

A fluid at rest is called **static**. Take a fluid of constant density $\rho$ at rest, with gravity $g\approx 9.8\ \text{m/s}^2$. Then

$$P=P_0+\rho gh,$$

where $h$ is the depth, the straight-down distance below the **free surface** (the top surface of the liquid). $P_0$ is the pressure pushing on that surface. In a container open to the air, $P_0$ is the air pressure, about $101{,}000$ Pa.

If $h=0$, the formula gives $P=P_0$, the pressure at the surface.

In the same static liquid, with the same $P_0$, a deeper point has greater pressure. Container shape does not change the pressure at a given depth. Depth means vertical distance, not the length along a slanted wall.

The comparison fails if the fluids differ or if $P_0$ differs. Then each point must be worked out with its own $\rho$ and $P_0$.

### Connected Open Containers

Vessels are **connected** when liquid can flow between them. Suppose they contain the **same liquid**, are open to the **same air pressure**, and have reached rest. Then their free surfaces settle at the same elevation.

Different liquids, a sealed surface, or unequal pressures on the surfaces can give different levels. Very narrow tubes can also change the level, because the liquid creeps up the glass (capillary effect).

For two different liquids that do not mix, use pressure. At the same level inside one continuous resting liquid, the pressure is the same. So the pressure at the boundary between the liquids, worked from each arm, must match.

<!-- FIGURE: {"kind": "fluid-vessel", "vessel": "connected", "columns": 2, "semanticsLabel": "A U-shaped tube with two containers of different widths connected at the bottom, with water surface level exactly equal in both."} -->
### Pressure in a Closed System (Hydraulics)

Pascal's principle says this: in a confined, resting, incompressible liquid, a pressure change at one place passes to every other place in the liquid without loss. A **hydraulic system** uses this with two pistons of different areas.

The pressure under both pistons is the same, so

$$\dfrac{F_1}{A_1}=\dfrac{F_2}{A_2}.$$

A small force on a small piston can balance a large force on a large piston. This holds when the pistons are at the same height, the liquid cannot be squeezed, and friction and leaks are ignored. If the pistons sit at different heights, add the $\rho gh$ difference.

The force gain is not a free gain in work. The small piston moves farther than the large piston, in the same ratio as the areas. Work in equals work out.

### Continuity in a Pipe

**Steady** flow means the speed at each point does not change with time. **Incompressible** means the density stays constant. A pipe's **cross-section** is the opening you would see if you cut across it, and $A$ is its area.

The volume of fluid passing a point each second is the **flow rate**, $Q=Av$, where $v$ is the average speed, measured in meters per second ($\text{m/s}$). For steady incompressible flow with no leaks, the flow rate going into a section equals the flow rate coming out. In one unbranched pipe,

$$A_1v_1=A_2v_2.$$

A smaller cross-section therefore means a larger average speed. If the pipe splits, add the branches: $A_1v_1=A_2v_2+A_3v_3$. Each branch's speed then depends on how the flow divides, not only on its size.

Gases can be squeezed. For a gas, this rule holds only when its density barely changes, as in slow airflow.

### Pressure and Speed

A **streamline** is the path a small bit of fluid follows. **Static pressure** is the pressure the fluid itself exerts, measured by a gauge moving along with the flow. For an ideal fluid, one with no internal friction (viscosity), in steady incompressible flow, Bernoulli's equation says that along a streamline

$$P+\tfrac12\rho v^2+\rho gy=\text{constant},$$

where $y$ is the height. At the **same height**, a higher speed goes with a lower static pressure. If the speeds are equal, the pressures are equal. If the height rises and the speed stays the same, the pressure falls.

To compare two points 1 and 2 on a streamline, write the constant sum for each and subtract. This gives the change in pressure:

$$\Delta P=P_2-P_1=-\tfrac12\rho(v_2^2-v_1^2)-\rho g(y_2-y_1).$$

If the height is equal, the second term is zero. If the speed is equal, the first term is zero.

"Faster flow always means lower pressure" is too broad. A pump adds energy.

Friction in a real pipe lowers the pressure along the pipe even when the speed stays the same. Height changes, fast gas flow, and points on different streamlines also break the simple rule.

## Examples

### #1: Hydrostatic Pressure

Point A and Point B lie in the same container of water at rest, both exposed ultimately to the same surface pressure. B is deeper than A. Which has greater pressure?

**Solution:**

Since $P=P_0+\rho gh$, **B** has greater pressure.

<!-- FIGURE: {"kind": "fluid-vessel", "vessel": "column", "points": ["A", "B"], "semanticsLabel": "A water-filled container with Point A marked near the surface and Point B near the bottom."} -->
### #2: Communicating Vessels

A wide arm and narrow arm are connected at the bottom, contain the same water, and are both open to the atmosphere. After equilibrium, which free surface is higher?

**Solution:**

Neither. Under these conditions, the free surfaces settle at the **same elevation**.

<!-- FIGURE: {"kind": "fluid-vessel", "vessel": "connected", "columns": 2, "semanticsLabel": "A U-shaped tube with a wide arm and a narrow arm, both open at the top, with water settled at the same level in both arms."} -->
### #3: Narrowing Pipe

Water flows steadily through an unbranched pipe that narrows. How does average speed change?

**Solution:**

For incompressible flow,

$$A_1v_1=A_2v_2.$$

The narrower section has the **higher average speed**.

<!-- FIGURE: {"kind": "fluid-vessel", "vessel": "pipe", "widths": [3, 1], "semanticsLabel": "A pipe narrowing from a wide section to a narrow section with fluid flowing through."} -->
### #4: Same-Height Ideal Bernoulli Comparison

In the same ideal horizontal pipe, one section is wider/slower and another is narrower/faster. Ignoring viscosity and losses, which section has lower static pressure?

**Solution:**

At equal height, Bernoulli's equation gives lower static pressure in the **faster, narrower** section.

<!-- FIGURE: {"kind": "fluid-vessel", "vessel": "pipe", "widths": [3, 1], "semanticsLabel": "A narrowing pipe with a wide section and a narrow section, for comparing the pressure in each."} -->
### #5: Pressure at a Depth

An open tank holds water. What is the pressure at a depth of $10$ m? Use $\rho=1000\ \text{kg/m}^3$, $g=9.8\ \text{m/s}^2$ and $P_0=101{,}000$ Pa.

**Solution:**

The water adds $\rho gh=1000\times 9.8\times 10=98{,}000$ Pa.

Then $P=101{,}000+98{,}000=199{,}000$ Pa. The pressure is **about $199{,}000$ Pa**, almost twice the surface pressure.

<!-- ILLUSTRATION: An open tank of water with a point marked 10 m below the surface. The pressure at that point is marked with a question mark. -->
### #6: Depth Is Not Enough

Point X is $1$ m deep in a sealed tank of water. The gas above the water has a pressure of $150{,}000$ Pa. Point Y is $3$ m deep in an open tank of water. Which point has the greater pressure?

**Solution:**

The surface pressures differ, so compare each total.

X: $150{,}000+1000\times 9.8\times 1=159{,}800$ Pa.

Y: $101{,}000+1000\times 9.8\times 3=130{,}400$ Pa.

**X** has the greater pressure, although it is shallower.

<!-- ILLUSTRATION: Two water tanks side by side. Tank X is sealed, with gas above the water at 150,000 Pa and Point X marked 1 m below the water surface. Tank Y is open to the air, with Point Y marked 3 m below the water surface. -->
### #7: Two Different Liquids

A U-tube is open at both ends. It holds water. A light oil, with density $800\ \text{kg/m}^3$, is poured into one arm. The water surface in the other arm is $10$ cm above the oil-water boundary. How high is the oil above that boundary?

**Solution:**

Both arms are open, so the air pressure is the same on both sides. At the boundary level, the water on that side is one continuous resting liquid, so its pressure equals the pressure at the same level in the other arm. Cancel $P_0$ and $g$:

$$\rho_{\text{oil}}h_{\text{oil}}=\rho_{\text{water}}h_{\text{water}}.$$

$800\,h_{\text{oil}}=1000\times 10$, so $h_{\text{oil}}=12.5$ cm.

The oil column is **$12.5$ cm** high. The lighter liquid stands higher, so the levels are not equal.

<!-- ILLUSTRATION: An open U-tube holding water and oil (density 800 kg/m3). One arm has an oil column above the oil-water boundary. The other arm has a water surface 10 cm above the boundary level. The height of the oil is marked with a question mark. -->
### #8: Hydraulic Lift

A hydraulic lift has a small piston of area $10\ \text{cm}^2$ and a large piston of area $200\ \text{cm}^2$. A $50$ N force pushes on the small piston. What force can the large piston support? Assume the pistons are level and ignore friction.

**Solution:**

$$F_2=F_1\dfrac{A_2}{A_1}=50\times\dfrac{200}{10}=1000\ \text{N}.$$

The large piston supports **$1000$ N**. It moves only $\dfrac{1}{20}$ as far as the small piston, so the work stays the same.

<!-- ILLUSTRATION: A hydraulic lift with a small piston of area 10 cm2 pushed by a 50 N force and a large piston of area 200 cm2 joined by one liquid-filled chamber at the same height. The force on the large piston is marked with a question mark. -->
### #9: A Pipe That Splits

Water flows steadily at $2$ m/s in a pipe of cross-section $10\ \text{cm}^2$. The pipe splits into two identical branches, each of cross-section $4\ \text{cm}^2$. What is the speed in each branch?

**Solution:**

The flow rate in is $10\times 2=20\ \text{cm}^2\text{m/s}$. The identical branches share it equally, so each carries $10$.

$$v=\dfrac{10}{4}=2.5\ \text{m/s}.$$

Each branch has a speed of **$2.5$ m/s**. If the branches were different, the split would not be equal, and the pipe sizes alone would not give the speeds.

<!-- ILLUSTRATION: A pipe of cross-section 10 cm2 with water at 2 m/s that splits into two identical branches of cross-section 4 cm2 each. The branch speeds are marked with a question mark. -->
### #10: Height and Speed Both Matter

Water flows steadily through a horizontal pipe. The speed rises from $2$ m/s to $6$ m/s where the pipe narrows. Then the pipe, at the same width as the narrow part, rises $5$ m. Ignore friction. By how much does the pressure change in each stage? Use $\rho=1000\ \text{kg/m}^3$ and $g=9.8\ \text{m/s}^2$.

**Solution:**

At the narrowing, the height is equal, so $\Delta P=-\tfrac12\rho(v_2^2-v_1^2)=-\tfrac12\times 1000\times(36-4)=-16{,}000$ Pa.

In the rising part, the width and speed stay the same. Only the height term changes: $\Delta P=-\rho g\Delta y=-1000\times 9.8\times 5=-49{,}000$ Pa.

The pressure falls by **$16{,}000$ Pa**, then by **$49{,}000$ Pa**.

<!-- ILLUSTRATION: A horizontal pipe narrowing so the water speed rises from 2 m/s to 6 m/s, then a section of the same narrow width that rises 5 m. The pressure changes in the two stages are marked with question marks. -->
## Speed Tricks & Shortcuts

**Hydrostatics:** compare depth only after confirming the same fluid and the same surface pressure.

**Different liquids:** equal pressure at equal level in one resting liquid gives $\rho_1h_1=\rho_2h_2$ for open arms.

**Hydraulics:** force scales with area, $F_2=F_1\dfrac{A_2}{A_1}$, for a confined incompressible liquid at one height.

**Continuity:** narrower means faster for steady incompressible flow in one unbranched stream. At a split, compare the total flow rate.

**Bernoulli:** speed-pressure comparisons need the rest of the equation and its assumptions. Check the height first.

## Traps to Watch For

### #1: "Bottom Pressure Is Always Greater"

> Deeper pressure is greater only under the stated hydrostatic conditions. Different surface pressures or fluids can change a comparison, as in Example 6.

### #2: "Connected Containers Always Have Equal Levels"

> Equal levels require the same connected liquid and equal pressure on the free surfaces at equilibrium, neglecting capillary effects. Two different liquids, as in Example 7, settle at different heights.

### #3: "A Narrow Pipe Always Makes Fluid Faster"

> The continuity shortcut assumes steady incompressible flow through the same flow path without branching or leakage.

### #4: "Faster Always Means Lower Pressure"

> Bernoulli relates pressure, speed, and height under ideal conditions. A pump, a height change, or friction can invalidate the simple paired rule.

### #5: "A Hydraulic Lift Gives Extra Energy"

> The force is larger, but the large piston moves a shorter distance. The work is the same, and friction makes the output smaller.

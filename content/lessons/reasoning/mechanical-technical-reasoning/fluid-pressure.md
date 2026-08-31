---
_id: "lesson-mechanical-technical-reasoning-fluid-pressure"
title: "Fluid Pressure in Pipes and Containers"
summary: "Learn hydrostatic pressure, communicating vessels, continuity, and the conditions behind pressure-speed comparisons in flowing fluids."
subject: "subject-reasoning"
topic: "topic-mechanical-technical-reasoning"
estimatedMinutes: 9
isActive: true
---
## Core Concept

Mechanical-reasoning fluid questions often use idealized versions of **hydrostatics** and **steady incompressible flow**. The assumptions matter.

### Pressure in a Fluid at Rest

For a fluid of approximately constant density $\rho$ at rest in a uniform gravitational field,

$$P=P_0+\rho gh,$$

where $h$ is depth below a reference free surface and $P_0$ is the pressure at that surface.

So, within the **same static fluid under the same surface pressure**, a deeper point has greater pressure. Container shape does not change the pressure at a specified depth.

### Connected Open Containers

If connected vessels contain the **same liquid**, are open to the **same atmospheric pressure**, and reach static equilibrium, their free surfaces settle at the same elevation. Different liquids, sealed surfaces, capillary effects, or unequal applied pressures can produce different levels.


<!-- FIGURE: {"kind": "fluid-vessel", "vessel": "connected", "columns": 2, "semanticsLabel": "A U-shaped tube with two containers of different widths connected at the bottom, with water surface level exactly equal in both."} -->
### Continuity in a Pipe

For steady incompressible flow through one unbranched pipe,

$$A_1v_1=A_2v_2.$$

A smaller cross-sectional area therefore corresponds to a larger average speed under those conditions.

### Pressure and Speed

Bernoulli's equation for an ideal steady incompressible flow along a streamline is

$$P+\frac12\rho v^2+\rho gy=\text{constant}.$$

At the **same elevation** in that idealized setting, a higher speed corresponds to a lower static pressure along the streamline. "Faster flow always means lower pressure" is too broad: height changes, pumps, losses, viscosity, compressibility, and different streamlines can change the relationship.

## Examples

### #1: Hydrostatic Pressure

Point A and Point B lie in the same container of water at rest, both exposed ultimately to the same surface pressure. B is deeper than A. Which has greater pressure?

**Solution:**

Since $P=P_0+\rho gh$, **B** has greater pressure.

<!-- FIGURE: {"kind": "fluid-vessel", "vessel": "column", "points": ["A", "B"], "semanticsLabel": "A water-filled container with Point A marked near the surface and Point B near the bottom, where deeper Point B experiences greater pressure."} -->
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

<!-- FIGURE: {"kind": "fluid-vessel", "vessel": "pipe", "widths": [3, 1], "semanticsLabel": "A pipe narrowing from a wide section to a narrow section with fluid flowing through, moving slower in the wide section and faster in the narrow section."} -->
### #4: Same-Height Ideal Bernoulli Comparison

In the same ideal horizontal pipe, one section is wider/slower and another is narrower/faster. Ignoring viscosity and losses, which section has lower static pressure?

**Solution:**

At equal height, Bernoulli's equation gives lower static pressure in the **faster, narrower** section.

<!-- FIGURE: {"kind": "fluid-vessel", "vessel": "pipe", "widths": [3, 1], "semanticsLabel": "A narrowing pipe with higher pressure in the wide slow section and lower pressure in the narrow fast section."} -->
## Speed Tricks & Shortcuts

**Hydrostatics:** compare depth only after confirming the same fluid and comparable surface pressure.

**Continuity:** narrower → faster is valid for steady incompressible flow in the same unbranched stream.

**Bernoulli:** speed-pressure comparisons need the rest of the equation and its assumptions; check elevation before using the shortcut.

## Traps to Watch For

### #1: "Bottom Pressure Is Always Greater"

> Deeper pressure is greater only under the stated hydrostatic conditions. Different surface pressures or fluids can change a comparison.

### #2: "Connected Containers Always Have Equal Levels"

> Equal levels require the same connected liquid and equal pressure on the free surfaces at equilibrium, neglecting capillary effects.

### #3: "A Narrow Pipe Always Makes Fluid Faster"

> The continuity shortcut assumes steady incompressible flow through the same flow path without branching or leakage.

### #4: "Faster Always Means Lower Pressure"

> Bernoulli relates pressure, speed, and elevation under ideal conditions. A pump, height change, or dissipative loss can invalidate the simple paired rule.

---
_id: "lesson-mechanical-technical-reasoning-pressure-in-a-resting-liquid"
title: "Pressure in a Resting Liquid"
summary: "Find pressure from depth, density, and surface pressure."
subject: "subject-reasoning"
topic: "topic-mechanical-technical-reasoning"
isActive: true
part: 1
partCount: 5
ordering: 0
keyPoints:
  - "Compare pressures at different depths in the same liquid."
  - "Calculate pressure when density or surface pressure changes."
---
## Core Concept

Fluid questions in mechanical reasoning use simple, idealized models. A **fluid** is a liquid or a gas. Each model works only under its stated conditions, so check the conditions first.

**Density** $\rho$ is the mass of a fluid in each unit of volume. Water has a density of about $1000\ \text{kg/m}^3$. Oil is lighter: common cooking oils are about $910$ to $930\ \text{kg/m}^3$.

### Pressure in a Fluid at Rest

A fluid at rest is called **static**. Take a fluid of constant density $\rho$ at rest, with gravity $g\approx 9.8\ \text{m/s}^2$. Then

$$P=P_0+\rho gh,$$

where $h$ is the depth, the straight-down distance below the **free surface** (the top surface of the liquid). $P_0$ is the pressure pushing on that surface. In a container open to the air, $P_0$ is the air pressure, about $101{,}000$ Pa.

If $h=0$, the formula gives $P=P_0$, the pressure at the surface.

In the same static liquid, with the same $P_0$, a deeper point has greater pressure. Container shape does not change the pressure at a given depth. Depth means vertical distance, not the length along a slanted wall.

The comparison fails if the fluids differ or if $P_0$ differs. Then each point must be worked out with its own $\rho$ and $P_0$.

## Examples

### #1: Hydrostatic Pressure

Point A and Point B lie in the same container of water at rest, both exposed ultimately to the same surface pressure. B is deeper than A. Which has greater pressure?

**Solution:**

Since $P=P_0+\rho gh$, **B** has greater pressure.

<!-- FIGURE: {"kind": "fluid-vessel", "vessel": "column", "points": ["A", "B"], "semanticsLabel": "A water-filled container with Point A marked near the surface and Point B near the bottom."} -->

### #2: Pressure at a Depth

An open tank holds water. What is the pressure at a depth of $10$ m? Use $\rho=1000\ \text{kg/m}^3$, $g=9.8\ \text{m/s}^2$ and $P_0=101{,}000$ Pa.

**Solution:**

The water adds $\rho gh=1000\times 9.8\times 10=98{,}000$ Pa.

Then $P=101{,}000+98{,}000=199{,}000$ Pa. The pressure is **about $199{,}000$ Pa**, almost twice the surface pressure.

<!-- ILLUSTRATION: An open tank of water with a point marked 10 m below the surface. The pressure at that point is marked with a question mark. -->

### #3: Depth Is Not Enough

Point X is $1$ m deep in a sealed tank of water. The gas above the water has a pressure of $150{,}000$ Pa. Point Y is $3$ m deep in an open tank of water. Which point has the greater pressure?

**Solution:**

The surface pressures differ, so compare each total.

X: $150{,}000+1000\times 9.8\times 1=159{,}800$ Pa.

Y: $101{,}000+1000\times 9.8\times 3=130{,}400$ Pa.

**X** has the greater pressure, although it is shallower.

<!-- ILLUSTRATION: Two water tanks side by side. Tank X is sealed, with gas above the water at 150,000 Pa and Point X marked 1 m below the water surface. Tank Y is open to the air, with Point Y marked 3 m below the water surface. -->

## Speed Tricks & Shortcuts

**Hydrostatics:** compare depth only after confirming the same fluid and the same surface pressure.

## Traps to Watch For

### #1: "Bottom Pressure Is Always Greater"

> Deeper pressure is greater only under the stated hydrostatic conditions. Different surface pressures or fluids can change a comparison, as in Example 6.

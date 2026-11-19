---
_id: "lesson-mechanical-technical-reasoning-flow-speed-height-and-pressure"
title: "Flow Speed, Height, and Pressure"
summary: "Use Bernoulli’s equation to compare pressure when speed or height changes."
subject: "subject-reasoning"
topic: "topic-mechanical-technical-reasoning"
isActive: true
part: 5
partCount: 5
ordering: 0
keyPoints:
  - "Compare pressure at two points on a streamline."
  - "Identify when the ideal flow model applies."
---
## Core Concept

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

### #1: Same-Height Ideal Bernoulli Comparison

In the same ideal horizontal pipe, one section is wider/slower and another is narrower/faster. Ignoring viscosity and losses, which section has lower static pressure?

**Solution:**

At equal height, Bernoulli's equation gives lower static pressure in the **faster, narrower** section.

<!-- FIGURE: {"kind": "fluid-vessel", "vessel": "pipe", "widths": [3, 1], "semanticsLabel": "A narrowing pipe with a wide section and a narrow section, for comparing the pressure in each."} -->

### #2: Height and Speed Both Matter

Water flows steadily through a horizontal pipe. The speed rises from $2$ m/s to $6$ m/s where the pipe narrows. Then the pipe, at the same width as the narrow part, rises $5$ m. Ignore friction. By how much does the pressure change in each stage? Use $\rho=1000\ \text{kg/m}^3$ and $g=9.8\ \text{m/s}^2$.

**Solution:**

At the narrowing, the height is equal, so $\Delta P=-\tfrac12\rho(v_2^2-v_1^2)=-\tfrac12\times 1000\times(36-4)=-16{,}000$ Pa.

In the rising part, the width and speed stay the same. Only the height term changes: $\Delta P=-\rho g\Delta y=-1000\times 9.8\times 5=-49{,}000$ Pa.

The pressure falls by **$16{,}000$ Pa**, then by **$49{,}000$ Pa**.

<!-- ILLUSTRATION: A horizontal pipe narrowing so the water speed rises from 2 m/s to 6 m/s, then a section of the same narrow width that rises 5 m. The pressure changes in the two stages are marked with question marks. -->

## Speed Tricks & Shortcuts

**Bernoulli:** speed-pressure comparisons need the rest of the equation and its assumptions. Check the height first.

## Traps to Watch For

### #1: "Faster Always Means Lower Pressure"

> Bernoulli relates pressure, speed, and height under ideal conditions. A pump, a height change, or friction can invalidate the simple paired rule.

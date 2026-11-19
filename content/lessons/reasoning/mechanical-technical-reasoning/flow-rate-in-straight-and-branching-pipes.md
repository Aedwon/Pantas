---
_id: "lesson-mechanical-technical-reasoning-flow-rate-in-straight-and-branching-pipes"
title: "Flow Rate in Straight and Branching Pipes"
summary: "Use flow rate to find speed in a pipe or branch."
subject: "subject-reasoning"
topic: "topic-mechanical-technical-reasoning"
isActive: true
part: 4
partCount: 5
ordering: 15
keyPoints:
  - "Find speed from cross-sectional area in an unbranched pipe."
  - "Add flow rates at a branch."
---
## Core Concept

### Continuity in a Pipe

**Steady** flow means the speed at each point does not change with time. **Incompressible** means the density stays constant. A pipe's **cross-section** is the opening you would see if you cut across it, and $A$ is its area.

The volume of fluid passing a point each second is the **flow rate**, $Q=Av$, where $v$ is the average speed, measured in meters per second ($\text{m/s}$). For steady incompressible flow with no leaks, the flow rate going into a section equals the flow rate coming out. In one unbranched pipe,

$$A_1v_1=A_2v_2.$$

A smaller cross-section therefore means a larger average speed. If the pipe splits, add the branches: $A_1v_1=A_2v_2+A_3v_3$. Each branch's speed then depends on how the flow divides, not only on its size.

Gases can be squeezed. For a gas, this rule holds only when its density barely changes, as in slow airflow.

## Examples

### #1: Narrowing Pipe

Water flows steadily through an unbranched pipe that narrows. How does average speed change?

**Solution:**

For incompressible flow,

$$A_1v_1=A_2v_2.$$

The narrower section has the **higher average speed**.

<!-- FIGURE: {"kind": "fluid-vessel", "vessel": "pipe", "widths": [3, 1], "semanticsLabel": "A pipe narrowing from a wide section to a narrow section with fluid flowing through."} -->

### #2: A Pipe That Splits

Water flows steadily at $2$ m/s in a pipe of cross-section $10\ \text{cm}^2$. The pipe splits into two identical branches, each with a cross-section of $4\ \text{cm}^2$. The outlets are at the same height and pressure. What is the speed in each branch?

**Solution:**

The flow rate in is $10\times 2=20\ \text{cm}^2\text{m/s}$. The branches are identical and have equal outlet conditions, so each carries $10\ \text{cm}^2\text{m/s}$.

$$v=\dfrac{10}{4}=2.5\ \text{m/s}.$$

Each branch has a speed of **$2.5$ m/s**. Different branches can split the flow unequally. Pipe sizes alone do not tell you the speeds.

<!-- ILLUSTRATION: A pipe of cross-section 10 cm2 with water at 2 m/s that splits into two identical branches of cross-section 4 cm2 each. The branch speeds are marked with a question mark. -->

## Speed Tricks & Shortcuts

**Continuity:** narrower means faster for steady incompressible flow in one unbranched stream. At a split, compare the total flow rate.

## Traps to Watch For

### #1: "A Narrow Pipe Always Makes Fluid Faster"

> The continuity shortcut assumes steady incompressible flow through the same flow path without branching or leakage.

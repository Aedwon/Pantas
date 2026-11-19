---
_id: "lesson-mechanical-technical-reasoning-pressure-and-force-in-hydraulics"
title: "Pressure and Force in Hydraulics"
summary: "Use pressure and piston area to find force in a hydraulic system."
subject: "subject-reasoning"
topic: "topic-mechanical-technical-reasoning"
isActive: true
part: 3
partCount: 5
ordering: 14
keyPoints:
  - "Calculate pressure from force and area."
  - "Relate piston forces and distances in a hydraulic lift."
---
## Core Concept

### What Pressure Means

**Pressure** is the force pressing on each unit of area:

$$P=\dfrac{F}{A}.$$

Force is measured in newtons ($\text{N}$). The unit of pressure is the **pascal** (Pa), which is $1\ \text{N}$ on each square meter. The same force on a smaller area gives a larger pressure.

### Pressure in a Closed System (Hydraulics)

Pascal's principle says this: in a confined, resting, incompressible liquid, a pressure change at one place passes to every other place in the liquid without loss. A **hydraulic system** uses this with two pistons of different areas.

The pressure under both pistons is the same, so

$$\dfrac{F_1}{A_1}=\dfrac{F_2}{A_2}.$$

A small force on a small piston can balance a large force on a large piston. This holds when the pistons are at the same height, the liquid cannot be squeezed, and friction and leaks are ignored. In a resting liquid, the pressure at the lower piston is higher by $\rho g$ times the height difference.

The force gain is not a free gain in work. The small piston moves farther than the large piston, in the same ratio as the areas. Work in equals work out.

## Examples

### #1: Hydraulic Lift

A hydraulic lift has a small piston of area $10\ \text{cm}^2$ and a large piston of area $200\ \text{cm}^2$. A $50$ N force pushes on the small piston. What force can the large piston support? Assume the pistons are level and ignore friction.

**Solution:**

$$F_2=F_1\dfrac{A_2}{A_1}=50\times\dfrac{200}{10}=1000\ \text{N}.$$

The large piston supports **$1000$ N**. It moves only $\dfrac{1}{20}$ as far as the small piston, so the work stays the same.

<!-- ILLUSTRATION: A hydraulic lift with a small piston of area 10 cm2 pushed by a 50 N force and a large piston of area 200 cm2 joined by one liquid-filled chamber at the same height. The force on the large piston is marked with a question mark. -->

## Speed Tricks & Shortcuts

**Hydraulics:** force scales with area, $F_2=F_1\dfrac{A_2}{A_1}$, for a confined incompressible liquid at one height.

## Traps to Watch For

### #1: "A Hydraulic Lift Gives Extra Energy"

> The force is larger, but the large piston moves a shorter distance. The work is the same, and friction makes the output smaller.

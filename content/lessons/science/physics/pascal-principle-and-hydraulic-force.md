---
_id: "lesson-physics-pascal-principle-and-hydraulic-force"
title: "Pascal’s Principle and Hydraulic Force"
summary: "Use a pressure change to find the output force of a hydraulic lift."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 4
partCount: 9
ordering: 0
keyPoints:
  - "Use Pascal’s principle and the piston areas to find output force."
---
## Core Concept

### Pascal's Principle and Hydraulic Systems

**Pascal's principle** says that when you change the pressure on an enclosed fluid at rest, the change is passed on, by the same amount, to each part of the fluid and to the container walls. The fluid must be incompressible, which means it cannot be squeezed into a smaller volume. Liquids behave this way very closely.

A **hydraulic system** uses this idea. Two pistons (sliding plugs) close two connected cylinders filled with liquid. The small piston has area $A_1$ and the large piston has area $A_2$. A force $F_1$ on the small piston raises the pressure in the liquid by $\dfrac{F_1}{A_1}$. That same pressure change pushes on the large piston.

$$\dfrac{F_1}{A_1} = \dfrac{F_2}{A_2}$$

This gives the output force:

$$F_2 = F_1 \dfrac{A_2}{A_1}$$

The formula $\dfrac{F_1}{A_1} = \dfrac{F_2}{A_2}$ assumes an ideal system: no friction, no trapped air, and both pistons at the same height. If the pistons are at different heights, the liquid's weight adds a pressure of $\rho gh$ between them. In real machines, friction and trapped air make the output force smaller.

<!-- ILLUSTRATION: hydraulic lift with a small piston of area A1 on the left and a large piston of area A2 on the right joined by a liquid-filled tube; arrows show force F1 pushing down on the small piston and force F2 pushing up on the large piston; distances d1 (large) and d2 (small) labeled -->

## Examples

### #1: A Hydraulic Lift

A hydraulic lift has a small piston of area $20 \text{ cm}^2$ and a large piston of area $400 \text{ cm}^2$. A worker pushes the small piston with a force of $150 \text{ N}$. Neglect friction and assume both pistons are at the same height. Find the force on the large piston and the distance the small piston moves when the large piston rises $2.0 \text{ cm}$.

**Solution:**

1. The pressure change is the same at both pistons, so:

$$F_2 = F_1 \dfrac{A_2}{A_1} = 150 \times \dfrac{400}{20} = 3000 \text{ N}$$

2. The liquid volume moved is the same at both pistons, so $A_1 d_1 = A_2 d_2$:

$$d_1 = d_2 \dfrac{A_2}{A_1} = 2.0 \times \dfrac{400}{20} = 40 \text{ cm}$$

3. The large piston pushes up with $3000 \text{ N}$. The small piston moves $40 \text{ cm}$. The areas are in the same unit on top and bottom, so no unit change is needed.

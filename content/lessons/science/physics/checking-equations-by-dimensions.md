---
_id: "lesson-physics-checking-equations-by-dimensions"
title: "Checking Equations by Dimensions"
summary: "Compare dimensions on both sides of an equation."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 5
partCount: 7
ordering: 5
keyPoints:
  - "Check that the dimensions in an equation agree."
---
## Core Concept

### Dimensions: Checking an Equation

The **dimension** of a quantity says what kind of quantity it is, not which unit it uses. Length has dimension $\text{L}$, mass $\text{M}$, and time $\text{T}$. Speed has dimension $\dfrac{\text{L}}{\text{T}}$.

Two rules let you check an equation:

- Both sides of an equation must have the same dimension.
- You can add or subtract only quantities with the same dimension.

Pure numbers have no dimension. Angles in radians, and numbers such as $\dfrac{1}{2}$ or $\pi$, are also dimensionless. The input of a function such as sine or a power of $10$ must be dimensionless too.

A dimension check can show that an equation is wrong. It cannot prove an equation is right. It does not see pure-number factors such as $\dfrac{1}{2}$, and it cannot tell apart two quantities that share a dimension, such as work and torque.

## Examples

### #1: Checking Equations by Dimensions

A student writes two equations for the displacement $s$ with initial velocity $u$, constant acceleration $a$, and time $t$:

$$s = ut + \dfrac{1}{2}at^2 \qquad \text{and} \qquad s = ut + at$$

Use dimensions to test each one.

**Solution:**
Distance has dimension $\text{L}$. Each term in the sum must have dimension $\text{L}$ too.

1. The term $ut$ has $\dfrac{\text{L}}{\text{T}} \times \text{T} = \text{L}$.
2. In the first equation, $\dfrac{1}{2}at^2$ has $\dfrac{\text{L}}{\text{T}^2} \times \text{T}^2 = \text{L}$. Both terms match $s$, so it passes.
3. In the second equation, $at$ has $\dfrac{\text{L}}{\text{T}^2} \times \text{T} = \dfrac{\text{L}}{\text{T}}$. This cannot be added to a length, so the second equation is wrong.

The test also would pass $s = ut + at^2$ with the $\dfrac{1}{2}$ left out. Dimensions do not see that missing factor.

## Traps to Watch For

### #1: Trusting a Dimension Check Too Much

> A passed dimension check shows the units are consistent, not that the equation is right.

An equation can have matching dimensions and still be wrong by a pure-number factor such as $\dfrac{1}{2}$, or use the wrong quantity. A failed check does show a mistake, as in the second equation of Example #1.

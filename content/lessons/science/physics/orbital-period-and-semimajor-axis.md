---
_id: "lesson-physics-orbital-period-and-semimajor-axis"
title: "Orbital Period and Semimajor Axis"
summary: "Use Kepler’s third law to compare orbital periods and sizes."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 3
partCount: 3
ordering: 56
keyPoints:
  - "Use period squared and semimajor axis cubed to compare orbits."
  - "Account for central mass when comparing orbits."
  - "Distinguish Kepler’s orbital patterns from Newton’s explanation."
---
## Core Concept

**Kepler's Third Law (Harmonic Law)**: for objects orbiting the same dominant central mass, the square of the orbital period $T$ is proportional to the cube of the orbit's **semimajor axis** $a$:

$$T^2 \propto a^3$$

For an elliptical orbit, $a$ is half the length of the major axis; equivalently, it is half the sum of the perihelion and aphelion distances measured from the focus. In a circular orbit, $a$ equals the orbital radius.

For a relatively small orbiting mass around central mass $M$, Newtonian gravity gives

$$T^2 = \dfrac{4\pi^2}{GM}a^3$$

Newton later showed that Kepler's laws follow from gravitational dynamics under the appropriate two-body approximation: Kepler established the empirical orbital patterns, and Newton supplied a dynamical explanation.

## Examples

### #1: Applying Kepler's Third Law

Planet A and Planet B orbit the same star. Planet A's orbital period is $4$ times Planet B's. How does Planet A's semimajor axis compare with Planet B's?

**Solution:**
Use the ratio form of Kepler's third law.

$$\frac{T_A^2}{T_B^2} = \frac{a_A^3}{a_B^3}$$

1. Given $T_A/T_B=4$,

$$\frac{T_A^2}{T_B^2}=4^2=16$$

2. Therefore,

$$\frac{a_A^3}{a_B^3}=16$$

3. Take the cube root.

$$\frac{a_A}{a_B}=\sqrt[3]{16}\approx2.52$$

4. Planet A's semimajor axis is about $2.52$ times Planet B's, not four times and not sixteen times.

## Speed Tricks & Shortcuts

For Kepler's third law, remember the exact pair of quantities: **period squared** and **semimajor axis cubed**. When comparing two objects orbiting the same central mass,

$$\left(\frac{T_1}{T_2}\right)^2 = \left(\frac{a_1}{a_2}\right)^3$$

## Traps to Watch For

### #1: Using an Undefined "Average Distance" in Kepler's Third Law

> The precise orbital-size quantity is the semimajor axis $a$.

For an ellipse, do not substitute an arbitrary time-average or arithmetic average of distances unless the problem explicitly establishes that it equals the semimajor axis.

### #2: Applying the Same Proportionality Constant to Different Central Masses

> $T^2/a^3$ depends on the central mass.

The simple ratio comparison works directly for planets orbiting the same star (or satellites orbiting the same planet). If the central masses differ, use the Newtonian form with $GM$.

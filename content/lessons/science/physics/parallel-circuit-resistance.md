---
_id: "lesson-physics-parallel-circuit-resistance"
title: "Parallel Circuit Resistance"
summary: "Use the branch rules for a parallel circuit."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 6
partCount: 11
ordering: 0
keyPoints:
  - "Identify what stays equal and what adds across parallel branches."
  - "Combine resistors in parallel."
---
## Core Concept

Parts in **parallel** are on separate branches. Each branch has the same voltage. The branch currents add up to the total current, and the resistances combine like this:

$$\dfrac{1}{R_{eq}}=\dfrac{1}{R_1}+\dfrac{1}{R_2}+\cdots$$

With two or more branches that all have resistance above $0$, the equivalent resistance of a parallel set is smaller than the smallest branch. More branches give the current more paths.

<!-- FIGURE: {"kind":"physics-energy-diagram","type":"series-parallel-circuit","illustrationKey":"science/physics/electricity-and-magnetism#2","bulbsPerCircuit":2,"seriesPath":"single loop one after another","parallelPath":"separate side-by-side branches","batteryShown":true} -->

## Examples

### #1: Parallel Circuit

A $12$ V battery is connected to a $6\ \Omega$ and a $12\ \Omega$ resistor in parallel. Find the total current.

**Solution:**

1. Combine the reciprocals:

$$\dfrac{1}{R_{eq}}=\dfrac{1}{6}+\dfrac{1}{12}=\dfrac{3}{12}$$

2. So $R_{eq}=4\ \Omega$. This is smaller than $6\ \Omega$, as it should be.
3. Total current:

$$I=\dfrac{12}{4}=3\ \mathrm{A}$$

4. Check by branches: $\dfrac{12}{6}=2$ A and $\dfrac{12}{12}=1$ A. They add to $3$ A.

## Speed Tricks & Shortcuts

For two equal resistors in parallel, the equivalent resistance is half of one. For $n$ equal resistors it is one resistor divided by $n$.

## Traps to Watch For

### #1: Adding Parallel Resistances Directly

> In parallel, add the reciprocals.

Do not add the resistances. Check that the answer is smaller than the smallest branch.

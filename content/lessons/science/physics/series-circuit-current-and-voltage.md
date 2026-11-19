---
_id: "lesson-physics-series-circuit-current-and-voltage"
title: "Series Circuit Current and Voltage"
summary: "Follow current and voltage around a single loop."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 5
partCount: 11
ordering: 0
keyPoints:
  - "Find resistance, current, and voltage in series."
  - "Predict what happens when a series path or parallel branch opens."
---
## Core Concept

### Series and Parallel Circuits

The **equivalent resistance** $R_{eq}$ is the one resistance that could replace the whole set. It would draw the same current from the same voltage.

Parts in **series** are in one loop, one after another. The same current passes through each part. The voltages add up to the source voltage, and the resistances add:

$$R_{eq}=R_1+R_2+\cdots$$

If one part of a series circuit fails open (breaks, leaving a gap), the only path is broken and current stops everywhere. If one branch of a parallel circuit fails open, the other branches still work, because each has its own path to the source.

## Examples

### #1: Series Circuit

A $12$ V battery is connected to a $2\ \Omega$ and a $4\ \Omega$ resistor in series. Find the current and the voltage across each resistor.

**Solution:**

1. Add the resistances:

$$R_{eq}=2+4=6\ \Omega$$

2. Find the current. It is the same in both resistors:

$$I=\dfrac{12}{6}=2\ \mathrm{A}$$

3. Find each voltage:

$$V_{2}=(2)(2)=4\ \mathrm{V},\quad V_{4}=(2)(4)=8\ \mathrm{V}$$

4. The sum is $4+8=12$ V, the battery voltage.

### #2: Series vs. Parallel Failure

Two bulbs are in series. In a separate circuit, two bulbs are in parallel. One bulb fails open in each circuit. What happens to the other bulb?

**Solution:**

1. Series: the failed bulb breaks the only path, so the other bulb goes dark.
2. Parallel: the other branch is still a complete path, so its bulb stays lit.

<!-- FIGURE: {"kind":"physics-energy-diagram","type":"circuit-failure","illustrationKey":"science/physics/electricity-and-magnetism#4","seriesOutcome":"other bulb goes dark","parallelOutcome":"other bulb stays lit","burnedOutBulbsPerCircuit":1} -->

## Speed Tricks & Shortcuts

For a simple series circuit: same current, voltages add. For a simple parallel circuit: same voltage on each branch, currents add.

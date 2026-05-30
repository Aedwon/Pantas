---
_id: "lesson-physics-fluid-mechanics"
title: "Fluid Mechanics (Density, Pressure, Buoyancy, Archimedes' Principle, Bernoulli's Principle)"
summary: "This lesson teaches you how density, pressure, and buoyancy work in fluids, and why moving fluids create pressure differences."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 12
isActive: true
---
## Core Concept

A **fluid** is any substance that FLOWS: liquids and gases both count.

### Density and Pressure

**Density** ($\rho$) is mass per unit volume:

$$\rho = \dfrac{m}{V}$$

**Pressure** ($P$) is force spread over an area:

$$P = \dfrac{F}{A}$$

Pressure in a fluid acts equally in ALL directions, and INCREASES with depth, since deeper fluid must support the weight of all the fluid above it.

### Archimedes' Principle and Buoyancy

**Archimedes' Principle**: the upward **buoyant force** on an object submerged (fully or partially) in a fluid EQUALS the WEIGHT of the fluid the object DISPLACES (pushes out of the way).

This explains floating and sinking: if an object's OWN weight is LESS than the weight of the fluid it would displace (meaning the object is LESS DENSE than the fluid), the buoyant force is strong enough to make it FLOAT. If the object's weight is MORE than the fluid it displaces (denser than the fluid), it SINKS.

<!-- ILLUSTRATION: two objects submerged in water, one less dense than water shown floating with a buoyant force arrow equal to its weight arrow, and one denser than water shown sinking with a buoyant force arrow smaller than its weight arrow -->

### Bernoulli's Principle

**Bernoulli's Principle** describes moving fluids: as a fluid's SPEED increases, its PRESSURE decreases (and vice versa), for fluid flowing steadily along a path. This inverse relationship between speed and pressure explains phenomena like airplane lift: air moving FASTER over an airplane wing's curved top surface has LOWER pressure than the slower-moving air beneath, creating a net upward force (lift).

## Examples

### #1: Calculating Density

An object has a mass of $500 \text{ g}$ and a volume of $200 \text{ cm}^3$. Find its density.

**Solution:**
Apply the density formula directly.

1. Substitute the values.

$$\rho = \dfrac{500}{200}$$

2. Compute.

$$\rho = 2.5 \text{ g/cm}^3$$

### #2: Will It Float or Sink?

An object has a density of $0.8 \text{ g/cm}^3$. It is placed in water, which has a density of $1.0 \text{ g/cm}^3$. Will the object float or sink?

**Solution:**
Compare the object's density to the fluid's density.

1. The object's density ($0.8 \text{ g/cm}^3$) is LESS than water's density ($1.0 \text{ g/cm}^3$).
2. An object LESS dense than the surrounding fluid will FLOAT.

### #3: Applying Archimedes' Principle

A solid block, fully submerged in water, displaces $300 \text{ cm}^3$ of water. Given that water has a density of $1 \text{ g/cm}^3$ (and using $g = 9.8 \text{ m/s}^2$), find the buoyant force acting on the block.

**Solution:**
The buoyant force equals the WEIGHT of the displaced water.

1. Find the mass of the displaced water using its density and volume.

$$m = \rho V = (1 \text{ g/cm}^3)(300 \text{ cm}^3) = 300 \text{ g} = 0.3 \text{ kg}$$

2. Find the weight of this displaced water.

$$W = mg = (0.3)(9.8)$$

3. Compute.

$$W = 2.94 \text{ N}$$

4. By Archimedes' principle, the buoyant force on the block equals this weight: $2.94 \text{ N}$.

### #4: Applying Bernoulli's Principle

Air flows over the curved TOP of an airplane wing faster than the air flowing beneath the FLAT bottom of the wing. Explain, using Bernoulli's principle, why this creates an upward lift force on the wing.

**Solution:**
Apply the inverse relationship between fluid speed and pressure.

1. Bernoulli's principle states that FASTER-moving fluid has LOWER pressure, and slower-moving fluid has HIGHER pressure.
2. Air moves FASTER over the wing's curved top, so the pressure ABOVE the wing is LOWER.
3. Air moves SLOWER beneath the wing's flatter bottom, so the pressure BELOW the wing is HIGHER.
4. This creates a pressure DIFFERENCE, with higher pressure below PUSHING UP more than the lower pressure above pushes down, resulting in a net UPWARD force: lift.

## Speed Tricks & Shortcuts

For "float or sink" questions, just compare densities directly — no calculation needed. Object density LESS than fluid density means float; object density MORE than fluid density means sink; EQUAL densities mean the object stays suspended (neutral buoyancy).

For Archimedes' principle problems, remember the buoyant force is found through the DISPLACED FLUID's weight, not the object's own weight. Find the volume of fluid displaced, convert to mass using the FLUID's density, then to weight.

For Bernoulli's principle, remember the simple inverse relationship: fluid speed UP means pressure DOWN, and fluid speed DOWN means pressure UP. This single rule explains airplane lift, shower curtains being pulled inward, and many other everyday fluid phenomena.

## Traps to Watch For

### #1: Using the Object's Density Instead of the Fluid's Density for Buoyant Force

> Archimedes' principle uses the DISPLACED FLUID's density (and volume) to find weight — NOT the submerged object's own density.

A common mistake calculates the displaced water's mass using the OBJECT's density instead of water's density. The buoyant force cares only about how much fluid was pushed out of the way, and that fluid's own properties, not what the submerged object itself is made of.

### #2: Assuming Bigger Objects Always Sink and Smaller Ones Always Float

> Whether an object floats or sinks depends on its DENSITY relative to the fluid, NOT its overall SIZE or MASS alone.

A massive steel ship floats because its overall SHAPE gives it a low average density (mostly hollow, air-filled space), while a small, solid rock of the same material sinks. Size and mass alone, without considering the resulting overall density, cannot predict floating or sinking.

### #3: Reversing Bernoulli's Speed-Pressure Relationship

> Bernoulli's principle states fluid speed and pressure are INVERSELY related: FASTER means LOWER pressure, not higher.

Assuming faster-moving fluid has HIGHER pressure (the opposite of the true relationship) would incorrectly predict downward force on an airplane wing instead of the actual lift force that keeps planes flying.

### #4: Forgetting That Pressure Increases with Depth

> Fluid pressure INCREASES the deeper you go, because deeper fluid must support the weight of all the fluid ABOVE it.

A common error treats fluid pressure as constant throughout a container, ignoring how much more pressure exists at the bottom of a deep pool compared to just below the surface.

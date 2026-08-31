---
_id: "lesson-physics-thermodynamics"
title: "Thermodynamics (Heat Transfer Mechanisms, Laws of Thermodynamics, Specific Heat Capacity)"
summary: "The three ways thermal energy transfers, the basic laws of thermodynamics, and how to calculate sensible heat using specific heat capacity."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 12
isActive: true
---
## Core Concept

**Thermodynamics** studies energy, heat transfer, work, temperature, and the macroscopic behavior of systems.

In thermodynamics, **heat** is energy transferred because of a temperature difference. Heat is not a substance stored inside an object; an object has internal energy, while heat describes energy in transit between systems.

### Heat Transfer Mechanisms

Thermal energy can be transferred in three main ways.

**Conduction**: energy transfers through microscopic interactions within matter or between objects in contact, without bulk motion of the material. A metal spoon getting hot while sitting in soup is a familiar example.

**Convection**: energy transfers through the bulk movement of a fluid. In **natural convection**, density differences caused by temperature differences can drive circulation; **forced convection** uses a fan, pump, or other external means to move the fluid.

**Radiation**: energy transfers by electromagnetic waves and therefore does not require matter as a medium. This is how energy from the Sun reaches Earth through space.

<!-- FIGURE: {"kind":"physics-energy-diagram","type":"heat-transfer-triptych","illustrationKey":"science/physics/thermodynamics#1","panels":[{"name":"conduction","scene":"heat through solid metal rod held over flame"},{"name":"convection","scene":"warm fluid rises and cool fluid sinks in heated water"},{"name":"radiation","scene":"wavy arrows from Sun through empty space to Earth"}]} -->

### Laws of Thermodynamics

**Zeroth Law**: if system A is in thermal equilibrium with system C, and system B is also in thermal equilibrium with C, then A and B are in thermal equilibrium with each other. This makes temperature a consistent measurable property.

**First Law**: energy conservation applied to a thermodynamic system. Using the common convention that $Q$ is heat added to the system and $W$ is work done **by** the system,

$$\Delta U = Q - W$$

where $\Delta U$ is the change in internal energy. Some books use the opposite sign convention for work, so always check the convention being used.

**Second Law**: natural processes have a preferred direction. One equivalent statement is that the total entropy of an isolated system does not decrease. Another is that heat does not flow spontaneously from a colder body to a hotter one; moving heat that way requires another effect, such as external work in a refrigerator.

**Third Law**: absolute zero cannot be reached in a finite sequence of thermodynamic operations. A related formulation states that the entropy of a pure, perfect crystal approaches zero as its temperature approaches $0\text{ K}$.

### Specific Heat Capacity

**Specific heat capacity** ($c$) tells how much energy is required per unit mass for a given temperature change. When there is **no phase change** and $c$ can be treated as approximately constant over the temperature interval,

$$Q = mc\Delta T$$

where $Q$ is the heat transferred to or from the substance, $m$ is mass, and $\Delta T=T_f-T_i$. The sign of $Q$ depends on the chosen convention; if $Q$ is defined as heat added to the object, heating gives $Q>0$ and cooling gives $Q<0$.

During melting, boiling, freezing, or condensation, temperature can remain constant while energy is transferred, so a latent-heat relation is needed instead of $Q=mc\Delta T$ alone.

## Examples

### #1: Identifying the Heat Transfer Mechanism

Classify each dominant mechanism: (a) a metal handle on a pan getting hot because energy conducts through the metal; (b) feeling the Sun's warmth; (c) a fan moving warm air around a room.

**Solution:**

1. (a) Energy moving through the metal without bulk motion: **conduction**.
2. (b) Energy arriving through electromagnetic waves: **radiation**.
3. (c) Energy carried with moving air: **forced convection**.

Real situations can involve more than one mechanism at the same time; these examples identify the dominant one described.

### #2: Applying the Second Law

A hot cup of coffee is left on a table in a cooler room. Explain what happens spontaneously.

**Solution:**

1. The coffee is hotter than its surroundings, so energy transfers from the coffee to the cooler environment.
2. The coffee cools toward thermal equilibrium with the room.
3. The reverse process—coffee spontaneously becoming hotter by extracting heat from the cooler room while nothing else changes—would violate the second-law direction of spontaneous heat transfer.

### #3: Calculating Heat Energy

Find the heat needed to raise the temperature of $2\text{ kg}$ of water by $10°C$, assuming no phase change and $c=4186\text{ J/(kg·°C)}$ over this interval.

**Solution:**

$$Q=mc\Delta T=(2)(4186)(10)=83{,}720\text{ J}$$

### #4: Comparing Temperature Changes

Equal masses of water and cooking oil start at the same temperature and each absorb the same amount of heat. Over the relevant range, the oil's specific heat capacity is lower than water's. Which has the larger temperature increase?

**Solution:**

From

$$\Delta T=\frac{Q}{mc}$$

both samples have the same $Q$ and $m$, so the sample with the smaller $c$ has the larger $\Delta T$. The oil therefore undergoes the larger temperature increase.

The equal-mass condition matters: if the masses differed, specific heat alone would not determine which temperature changed more.

## Speed Tricks & Shortcuts

Distinguish the transfer mechanisms by what carries the energy: microscopic interactions without bulk flow (conduction), moving fluid (convection), or electromagnetic waves (radiation).

For first-law problems, write down the sign convention before substituting values. With $W$ defined as work done by the system, use $\Delta U=Q-W$.

Use $Q=mc\Delta T$ only when the substance remains in the same phase and a suitable value of $c$ applies over the temperature interval.

## Traps to Watch For

### #1: Treating Heat as Something an Object "Contains"

> Heat is energy transferred because of a temperature difference; **internal energy** is a property of the system.

After transfer stops, it is better to describe the object's changed internal energy than to say it "contains heat."

### #2: Assuming Convection Always Means "Warm Fluid Rises"

> Natural convection can be driven by buoyancy from density differences, but convection more generally means heat transfer associated with bulk fluid motion.

Fans and pumps create forced convection, and density does not always vary with temperature in the simplest possible way.

### #3: Using $Q=mc\Delta T$ During a Phase Change

> During a phase change, energy can be transferred while temperature remains nearly constant.

Melting and boiling problems generally require latent heat in addition to, or instead of, sensible-heat calculations.

### #4: Stating the Third Law as "Every Substance Has Zero Entropy at 0 K"

> The zero-entropy formulation applies to a pure, perfect crystal; a more general statement is that absolute zero cannot be reached in a finite number of cooling steps.

Disorder, degeneracy, or imperfect crystalline structure can complicate the entropy limit.

### #5: Comparing Specific Heats Without Controlling Mass

> Temperature change depends on $Q/(mc)$, not on $c$ alone.

A lower specific heat produces a larger temperature change for the same heat input **and the same mass**.

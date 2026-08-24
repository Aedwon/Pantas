---
_id: "lesson-chemistry-thermodynamics-and-kinetics"
title: "Thermodynamics and Kinetics (Endothermic vs. Exothermic Reactions, Catalysts)"
summary: "How heat/enthalpy and thermodynamic favorability differ from reaction rate, and how temperature, concentration, surface area, and catalysts can affect kinetics."
subject: "subject-science"
topic: "topic-chemistry"
estimatedMinutes: 12
isActive: true
---
## Core Concept

Chemical reactions raise two different kinds of questions:

- **Thermodynamics** asks about state functions, energy/enthalpy changes, entropy, free energy, and equilibrium/favorability under specified conditions.
- **Kinetics** asks how rapidly a process occurs and through what reaction mechanism.

A reaction can be thermodynamically favorable yet kinetically slow because it faces a large activation barrier. Conversely, a rapid process is not automatically strongly product-favored at equilibrium.

### Endothermic vs. Exothermic

At constant pressure, the heat exchanged by a chemical process is described by its **enthalpy change**, $\Delta H$.

- **Exothermic:** $\Delta H<0$; heat is released from the reacting system to the surroundings.
- **Endothermic:** $\Delta H>0$; heat is absorbed by the reacting system from the surroundings.

A surrounding container may become warmer for an exothermic process or cooler for an endothermic one in a simple insulated setup, but "feels hot/cold" is an observation that also depends on heat capacities, heat transfer, mixing, and the apparatus. The definition is the direction/sign of heat or enthalpy change under the stated conditions.

An exothermic reaction is not necessarily **spontaneous** under all conditions, and an endothermic reaction is not necessarily nonspontaneous. Gibbs free energy includes both enthalpy and entropy contributions.

<!-- ILLUSTRATION: reaction-coordinate diagrams showing reactant/product energy difference separately from activation-energy barrier for catalyzed and uncatalyzed pathways -->

### Activation Energy and Reaction Rate

**Activation energy**, $E_a$, is the energetic barrier associated with reaching a transition state along a reaction pathway.

According to the Arrhenius relationship,

$$k=Ae^{-E_a/(RT)},$$

lowering $E_a$ generally increases the rate constant $k$ when other factors are comparable. But it is too broad to say "higher activation energy always means slower" without qualification: the pre-exponential factor $A$, temperature, concentrations, and reaction mechanism also affect rate.

Collision theory adds another requirement: reactant collisions must have sufficient energy and suitable orientation for the elementary process.

### Catalysts

A **catalyst** increases the rate of a reaction by providing an alternative mechanism/pathway with a lower-energy transition state and therefore a lower effective activation barrier. The catalyst participates in intermediate steps but is **regenerated overall**, so it is not consumed stoichiometrically as a reactant.

For a reversible reaction at fixed temperature, a catalyst speeds both forward and reverse processes and therefore helps the system reach equilibrium faster. It does **not** change the equilibrium constant or the equilibrium composition for that same reaction at that temperature.

Catalysts also do not change the overall enthalpy/free-energy difference between the same reactants and products. In real reaction networks, however, different catalysts can change **selectivity** by accelerating competing pathways differently, so the broad claim "a catalyst can never change the final product amount" is unsafe outside a specified single-reaction equilibrium problem.

### Factors Affecting Rate

Common factors include:

- **Temperature:** increasing temperature usually increases reaction rate because the rate constant changes strongly with temperature.
- **Concentration / partial pressure:** rate often changes with reactant concentration, but the exact dependence is given by the experimentally determined **rate law**. A reactant can even be zero-order over a range, so "higher concentration always makes every reaction faster" is not universal.
- **Surface area:** especially important for **heterogeneous reactions**, where increasing contact area between phases can increase rate.
- **Catalysts:** change mechanism and lower the effective activation barrier.

## Examples

### #1: Exothermic or Endothermic?

A hand-warmer reaction transfers heat to the surroundings. Another process absorbs heat from the surroundings at constant pressure.

**Solution:**

1. Heat transferred from system to surroundings: exothermic, $\Delta H<0$.
2. Heat absorbed by system from surroundings: endothermic, $\Delta H>0$.

### #2: What a Catalyst Changes at Equilibrium

A reversible reaction is allowed to reach equilibrium at a fixed temperature, once without a catalyst and once with a catalyst. What changes?

**Solution:**

1. The catalyst provides a faster pathway with lower activation barriers.
2. Forward and reverse reactions are both accelerated.
3. The catalyzed system reaches equilibrium sooner.
4. The equilibrium constant and equilibrium composition are unchanged at that temperature.

### #3: Crushing a Solid

A solid reacts with an acid at its surface. The same mass is crushed into fine powder before reaction. What should happen, all else comparable?

**Solution:**

1. Crushing increases exposed solid-liquid interfacial area.
2. More reaction sites are accessible at once.
3. For this heterogeneous reaction, the rate generally increases.

### #4: Why Energy Release Does Not Determine Speed

A student says, "This reaction releases a lot of heat, so it must occur instantly."

**Solution:**

1. Heat/enthalpy change is a thermodynamic quantity.
2. Reaction rate is a kinetic quantity controlled by the pathway, $E_a$, rate constant, concentrations, temperature, and other factors.
3. A highly exothermic reaction can remain extremely slow if its activation barrier is large.
4. Combustion is a familiar example: many fuels are thermodynamically capable of burning in oxygen but need ignition to proceed rapidly.

### #5: Does Doubling Concentration Always Double Rate?

A reaction has rate law

$$\text{rate}=k[A]^0[B].$$

What happens if $[A]$ doubles while everything else stays fixed?

**Solution:**

Because $[A]^0=1$, the rate does not change. This shows why reaction order must be determined from the rate law rather than guessed from the balanced equation or a general slogan.

## Speed Tricks & Shortcuts

Keep the categories separate:

- $\Delta H$ / heat exchange: thermochemistry.
- $\Delta G$, equilibrium: thermodynamics.
- $E_a$, rate law, mechanism, catalyst: kinetics.

For catalyst questions at equilibrium, remember: **faster arrival, same $K$ and same equilibrium composition at the same temperature**.

For concentration questions, use the **rate law** if one is given. Do not assume first-order dependence for every reactant.

For surface area, the effect is most directly relevant when reactants meet across a phase boundary, such as solid-liquid or solid-gas reactions.

## Traps to Watch For

### #1: Saying Exothermic Means Fast or Spontaneous

> Exothermicity describes $\Delta H$, not reaction rate and not by itself Gibbs free-energy favorability.

Kinetics and thermodynamics answer different questions.

### #2: Saying a Catalyst Changes Equilibrium

> At fixed temperature, a catalyst does not change the equilibrium constant or equilibrium composition of a reversible reaction.

It accelerates both directions and reaches that equilibrium sooner.

### #3: Saying a Catalyst Is Never Changed During the Mechanism

> A catalyst can form intermediates and undergo temporary chemical changes.

The defining point is that it is regenerated overall rather than consumed stoichiometrically.

### #4: Saying Higher Reactant Concentration Always Increases Rate

> The effect of concentration depends on the reaction's experimentally determined rate law.

Many reactions increase with concentration, but zero-order and more complex behaviors exist.

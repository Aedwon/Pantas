---
_id: "lesson-chemistry-mole-concept"
title: "The Mole Concept, Molar Mass, and Avogadro's Number"
summary: "How the mole connects the number of particles in a substance to its mass, using Avogadro's number and molar mass."
subject: "subject-science"
topic: "topic-chemistry"
estimatedMinutes: 12
isActive: true
---
## Core Concept

Atoms and molecules are far too small and numerous to count one by one. Chemists solve this with the **mole**: a counting unit, just like "a dozen" means $12$ of something, except a mole means an enormous number of something.

### Avogadro's Number

One mole of any substance always contains the same number of particles:

$$1 \text{ mole} = 6.022 \times 10^{23} \text{ particles}$$

This number is called **Avogadro's number**. It applies to atoms, molecules, ions, or any other particle you are counting: one mole of water molecules and one mole of table salt formula units both contain exactly $6.022 \times 10^{23}$ particles, even though they weigh completely different amounts.

<!-- ILLUSTRATION: balance scale showing one mole of carbon (12 grams) balancing against one mole of a different, heavier element, with both sides labeled as containing 6.022 x 10^23 atoms despite the different masses -->

### Molar Mass

**Molar mass** is the mass of one mole of a substance, in grams per mole ($\text{g/mol}$).

For a single element, molar mass is simply the atomic mass shown on the periodic table, with units of grams per mole instead of atomic mass units. For a compound, molar mass is the sum of the molar masses of every atom in its formula.

### Converting Between Moles, Mass, and Particles

Molar mass is the bridge between moles and grams; Avogadro's number is the bridge between moles and particles. The full conversion chain runs: **particles ↔ moles ↔ grams**, always passing through moles in the middle: you cannot convert directly from particles to grams without going through moles first.

$$\text{moles} = \dfrac{\text{given mass (g)}}{\text{molar mass (g/mol)}} \qquad \text{particles} = \text{moles} \times (6.022 \times 10^{23})$$

## Examples

### #1: Finding Molar Mass of a Compound

Find the molar mass of water ($H_2O$), given that hydrogen's atomic mass is about $1$ g/mol and oxygen's is about $16$ g/mol.

**Solution:**
Add up the molar mass of every atom in the formula.

1. Water has $2$ hydrogen atoms and $1$ oxygen atom.
2. Hydrogen's contribution: $2 \times 1 = 2$ g/mol.
3. Oxygen's contribution: $1 \times 16 = 16$ g/mol.
4. Add them together.

$$2 + 16 = 18 \text{ g/mol}$$

5. The molar mass of water is $18$ g/mol.

### #2: Converting Mass to Moles

How many moles are in $36$ grams of water (molar mass $18$ g/mol)?

**Solution:**
Divide the given mass by the molar mass.

1. Apply the formula.

$$\text{moles} = \dfrac{36 \text{ g}}{18 \text{ g/mol}}$$

2. Compute.

$$\text{moles} = 2 \text{ mol}$$

### #3: Converting Moles to Number of Particles

How many individual water molecules are in $2$ moles of water?

**Solution:**
Multiply the number of moles by Avogadro's number.

1. Apply the formula.

$$\text{particles} = 2 \text{ mol} \times (6.022 \times 10^{23} \text{ molecules/mol})$$

2. Compute.

$$\text{particles} = 1.2044 \times 10^{24} \text{ molecules}$$

### #4: Full Chain Conversion (Exam Level)

How many individual molecules are present in $9$ grams of water (molar mass $18$ g/mol)?

**Solution:**
Since you cannot jump straight from grams to particles, first convert grams to moles, then convert moles to particles.

1. Convert grams to moles.

$$\text{moles} = \dfrac{9 \text{ g}}{18 \text{ g/mol}} = 0.5 \text{ mol}$$

2. Convert moles to particles.

$$\text{particles} = 0.5 \text{ mol} \times (6.022 \times 10^{23})$$

3. Compute.

$$\text{particles} = 3.011 \times 10^{23} \text{ molecules}$$

## Speed Tricks & Shortcuts

Think of the mole as the middle stop on a two-step journey: grams and particles never convert directly into each other. Always pass through moles: grams → moles (using molar mass) → particles (using Avogadro's number), or the reverse.

To find a compound's molar mass fast, write out its formula, list each element's atomic mass from the periodic table next to its subscript count, multiply each pair, then add everything together in one pass.

Sanity-check your mole calculations: if the given mass is smaller than the molar mass, you should get fewer than $1$ mole; if it is a whole-number multiple of the molar mass, you get a clean whole (or simple fraction) number of moles.

## Traps to Watch For

### #1: Converting Directly from Grams to Particles

> Grams and particles are never directly convertible: moles must always be the middle step.

Skipping straight from a given mass to a particle count (without finding moles first) produces a badly wrong answer, since it mixes up two completely different conversion factors (molar mass and Avogadro's number) in one incorrect step.

### #2: Forgetting to Multiply Atomic Mass by the Subscript

> Every atom's contribution to molar mass must be multiplied by how many of that atom appear in the formula.

For water ($H_2O$), forgetting to double hydrogen's mass (using just $1$ g/mol instead of $2 \times 1 = 2$ g/mol) gives an incorrect molar mass of $17$ g/mol instead of the correct $18$ g/mol. Always check the subscript for each element before adding.

### #3: Confusing Atomic Mass Units with Grams per Mole

> An element's atomic mass (in atomic mass units, on the periodic table) has the same number as its molar mass (in grams per mole), but they are different units for different purposes.

A single atom's mass is measured in atomic mass units (amu), a tiny unit for a tiny particle. Molar mass describes a mole of that same substance (an enormous number of particles), measured in grams. The numeric value transfers directly, but understanding why (one mole's worth of atoms happens to weigh that many grams) avoids confusion in more advanced problems.

### #4: Using the Wrong Number of Significant Figures for Avogadro's Number

> Avogadro's number is approximately $6.022 \times 10^{23}$: using a rounded or altered version (like $6 \times 10^{23}$) without being told to approximate can throw off multi-step calculations.

For most exam problems, using $6.022 \times 10^{23}$ (or the value given in the problem) keeps your final answer accurate and matching the intended choice. If a problem explicitly says to round, follow its instruction, but do not round on your own unless asked.

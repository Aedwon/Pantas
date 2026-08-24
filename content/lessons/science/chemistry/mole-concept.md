---
_id: "lesson-chemistry-mole-concept"
title: "The Mole Concept, Molar Mass, and Avogadro Constant"
summary: "How the SI mole connects a specified number of elementary entities to amount of substance and how molar mass connects moles to mass."
subject: "subject-science"
topic: "topic-chemistry"
estimatedMinutes: 12
isActive: true
---
## Core Concept

Atoms, molecules, ions, and other microscopic entities are too numerous to count one by one in ordinary samples. Chemists use **amount of substance**, measured in moles.

### The Mole and Avogadro Constant

The SI definition is exact:

$$1\ \mathrm{mol}=6.02214076\times10^{23}\ \text{specified elementary entities}$$

The **Avogadro constant** is therefore exactly

$$N_A=6.02214076\times10^{23}\ \mathrm{mol^{-1}}.$$

The entity must be stated when ambiguity matters: one mole can refer to atoms, molecules, ions, electrons, formula units, or another specified group. For example, one mole of $H_2O$ contains one mole of water molecules; one mole of crystalline $NaCl$ is commonly counted as one mole of $NaCl$ formula units, not discrete $NaCl$ molecules.

### Molar Mass

**Molar mass** is mass divided by amount of substance, commonly reported in $\mathrm{g/mol}$.

For introductory calculations, an element's tabulated relative atomic mass gives a numerically very close molar mass in $\mathrm{g/mol}$. Since the 2019 SI redefinition, however, the mole is defined by the exact value of $N_A$; the molar mass of carbon-12 is no longer itself the quantity used to define the mole.

For a molecular or formula composition, add the molar-mass contributions of all atoms represented in the formula.

### Converting Moles, Mass, and Entities

$$n=\frac{m}{M}$$

where $n$ is amount in moles, $m$ is sample mass, and $M$ is molar mass.

The number of specified entities is:

$$N=nN_A$$

A grams-to-entities calculation therefore combines both relations. You may write it in one dimensional-analysis line or in two steps; there is no rule that the arithmetic must literally be written with "moles in the middle," only that the conversion factors be dimensionally correct.

## Examples

### #1: Molar Mass of Water

Using $H\approx1.008\,\mathrm{g/mol}$ and $O\approx16.00\,\mathrm{g/mol}$:

$$M(H_2O)=2(1.008)+16.00\approx18.02\,\mathrm{g/mol}$$

A problem may intentionally round atomic masses to $1$ and $16$, yielding $18\,\mathrm{g/mol}$; follow the values supplied by the problem.

### #2: Mass to Moles

Using the rounded classroom molar mass $18\,\mathrm{g/mol}$, how many moles are in $36$ g water?

$$n=\frac{36\,\mathrm g}{18\,\mathrm{g/mol}}=2.0\,\mathrm{mol}$$

### #3: Moles to Molecules

How many water molecules correspond to $2.0$ mol $H_2O$?

$$N=(2.0\,\mathrm{mol})(6.02214076\times10^{23}\,\mathrm{mol^{-1}})$$

$$N\approx1.2\times10^{24}\ \text{molecules}$$

The exact Avogadro constant does **not** force the final answer to eight significant digits; the measured/given quantity controls appropriate reporting precision.

### #4: Mass to Molecules

Using $18\,\mathrm{g/mol}$ as instructed, how many water molecules correspond to $9$ g water?

$$n=\frac{9}{18}=0.5\,\mathrm{mol}$$

$$N=(0.5)(6.02214076\times10^{23})\approx3.0\times10^{23}\ \text{molecules}$$

## Speed Tricks & Shortcuts

Use dimensional analysis: arrange conversion factors so unwanted units cancel.

For a chemical formula, multiply each element's molar-mass contribution by its subscript before adding.

Always name the entity. "One mole of oxygen" could mean oxygen atoms or $O_2$ molecules unless context specifies which.

## Traps to Watch For

### #1: Calling $6.022\times10^{23}$ the Exact Modern Value

> The exact SI value is $6.02214076\times10^{23}\,\mathrm{mol^{-1}}$.

$6.022\times10^{23}$ is a useful rounded value when the problem's precision warrants it.

### #2: Treating Avogadro's Constant as a Measured Source of Significant-Figure Uncertainty

> $N_A$ is exact in the SI.

Final significant figures come from measured or rounded input data, not uncertainty in $N_A$.

### #3: Calling Every Formula Unit a Molecule

> Molecular substances can be counted as molecules; ionic solids such as $NaCl$ are normally described using formula units.

Specify what entity is being counted.

### #4: Confusing Mass Number, Atomic Mass, and Molar Mass

> Mass number is an integer nucleon count for one nuclide; relative atomic mass is an isotope-weighted atomic-scale quantity; molar mass is mass per mole.

They are related but not interchangeable concepts.

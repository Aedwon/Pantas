---
_id: "lesson-chemistry-acids-bases-ph"
title: "Acids, Bases, and pH"
summary: "How Arrhenius and Brønsted-Lowry acids and bases are defined, how pH represents hydronium activity, and what neutralization means."
subject: "subject-science"
topic: "topic-chemistry"
estimatedMinutes: 11
isActive: true
---
## Core Concept

Acids and bases can be described with more than one useful model.

### Acid-Base Definitions

In the **Arrhenius** model for aqueous solution, acids increase the concentration of hydronium ions, $H_3O^+$, and bases increase the concentration of hydroxide ions, $OH^-$. Writing a bare $H^+(aq)$ is a common shorthand; free protons are strongly solvated in water.

In the broader **Brønsted-Lowry** model, an acid is a proton donor and a base is a proton acceptor. A Brønsted-Lowry acid-base reaction is therefore a **proton-transfer** reaction and need not involve $OH^-$ as a reactant.

### pH

Formally, pH is based on hydrogen-ion **activity**. In sufficiently dilute introductory aqueous solutions it is commonly approximated using hydronium concentration:

$$\mathrm{pH}\approx-\log_{10}[H_3O^+]$$

The often-drawn **0-to-14 pH scale is not a universal hard limit**. Concentrated solutions can have pH below $0$ or above $14$.

At **25 °C**, neutral water has

$$[H_3O^+]=[OH^-]=1.0\times10^{-7}\,M$$

and therefore $\mathrm{pH}=7.00$. At this temperature:

- pH $<7$: acidic.
- pH $=7$: neutral.
- pH $>7$: basic.

But $K_w$ changes with temperature, so **neutral pH is not always exactly 7**. Neutrality means equal hydronium and hydroxide activities/concentrations under the relevant model, not a permanently fixed number.

A change of one pH unit corresponds to a factor of $10$ in hydrogen-ion activity. Thus, under comparable dilute conditions, a pH-4 solution has about $100$ times the hydronium activity of a pH-6 solution. This does not mean the acid molecule itself is "100 times stronger"; **acid strength** is a different concept.

### Strong vs. Weak

A **strong acid** ionizes essentially completely in water; a **weak acid** ionizes only partially and establishes an equilibrium. Strength is not the same as concentration.

For soluble ionic hydroxides treated as strong bases, dissociation releases $OH^-$. Weak molecular bases such as ammonia react only partially with water to generate hydroxide.

### Neutralization

In the common strong-acid/strong-hydroxide case, the net ionic reaction is:

$$H_3O^+ + OH^- \rightarrow 2H_2O$$

and spectator ions remain as a salt solution.

However, **not every acid-base neutralization can be summarized literally as "acid + base → salt + water."** Brønsted-Lowry neutralization is fundamentally proton transfer. For example:

$$NH_3 + HCl \rightarrow NH_4Cl$$

has no water product in its simplified overall equation.

## Examples

### #1: Classifying pH at 25 °C

At $25\ ^\circ\mathrm C$, classify aqueous solutions with pH $2$, $7$, and $11$.

**Solution:**

1. pH $2<7$: acidic.
2. pH $7$: neutral at $25\ ^\circ\mathrm C$.
3. pH $11>7$: basic.

<!-- FIGURE: {"kind":"chemistry-diagram","type":"ph-scale","illustrationKey":"science/chemistry/acids-bases-ph#1","min":0,"max":14,"neutral":7,"regions":["acidic","neutral","basic"],"examples":[{"label":"lemon juice","ph":2},{"label":"pure water","ph":7},{"label":"soap","ph":10}]} -->
### #2: Comparing Hydronium Activity

At the same temperature and under dilute conditions, solution A has pH $4$ and solution B pH $6$.

**Solution:**

$$10^{6-4}=10^2=100$$

Solution A has about $100$ times the hydrogen-ion activity of solution B. This compares pH/hydronium level, not the intrinsic $K_a$ values of unspecified acids.

### #3: Strong or Weak Acid?

Acid X ionizes essentially completely in water at the concentration considered; acid Y establishes an equilibrium in which a substantial fraction remains un-ionized.

**Solution:**

1. X: strong acid in water.
2. Y: weak acid in water.

### #4: Strong Acid + Strong Base

Hydrochloric acid reacts with sodium hydroxide:

$$HCl+NaOH\rightarrow NaCl+H_2O$$

**Solution:**

1. In water, the strong acid supplies hydronium and the soluble strong base supplies hydroxide.
2. Their net ionic neutralization is $H_3O^+ + OH^-\rightarrow2H_2O$.
3. $Na^+$ and $Cl^-$ are spectator ions in the idealized reaction.
4. The resulting solution is exactly neutral only when stoichiometry, concentration, temperature, and salt hydrolysis conditions support that conclusion.

## Speed Tricks & Shortcuts

Use the pH $7$ divider only when the problem assumes approximately $25\ ^\circ\mathrm C$ or explicitly uses the standard classroom scale.

Count pH-unit differences to compare hydrogen-ion activity: $\Delta\mathrm{pH}=2$ means a factor of $10^2$.

Keep **strength** and **concentration** separate. Strength describes extent of ionization; concentration describes amount per volume.

For acid-base reactions, look for **proton transfer**. Water formation is a common special case, not the universal definition.

## Traps to Watch For

### #1: Treating 0–14 as Absolute pH Limits

> The familiar scale is a convenient range for many dilute aqueous solutions, not a mathematical boundary.

Concentrated acids or bases can fall outside it.

### #2: Saying Neutral Always Means pH 7

> Neutral means equal acid/base ion levels; pH 7 is the neutral value for water at about $25\ ^\circ\mathrm C$.

Because $K_w$ depends on temperature, neutral pH changes with temperature.

### #3: Confusing pH Difference with Acid Strength

> A lower pH means greater hydrogen-ion activity in that solution, not necessarily a larger intrinsic acid-ionization constant for the solute.

Concentration and acid strength both affect pH.

### #4: Saying Every Neutralization Makes Water

> Brønsted-Lowry neutralization is proton transfer.

Strong acid + hydroxide commonly makes water, but reactions such as $NH_3+HCl\rightarrow NH_4Cl$ show why "salt + water" is not universal.

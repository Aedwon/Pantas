---
_id: "lesson-chemistry-stoichiometry"
title: "Stoichiometry (Limiting/Excess Reactants, Percent Yield, Empirical/Molecular Formulas)"
summary: "How to use a balanced equation to find limiting reactants, percent yield, and a compound's empirical and molecular formulas."
subject: "subject-science"
topic: "topic-chemistry"
estimatedMinutes: 14
isActive: true
---
## Core Concept

**Stoichiometry** uses the coefficients of a balanced chemical equation as a recipe, telling you the exact mole ratios between reactants and products.

### Limiting and Excess Reactants

In most real reactions, you do not have the perfect amount of each reactant. The **limiting reactant** is the one that runs out first, stopping the reaction — it determines the maximum amount of product possible. The **excess reactant** is the one with some left over after the reaction stops.

To find the limiting reactant, calculate how much product each reactant could make on its own (assuming unlimited amounts of the other); whichever reactant produces the smaller amount of product is the limiting one.

<!-- ILLUSTRATION: assembly line making bicycles from wheels and frames, showing 10 wheels and 3 frames, with only 3 bicycles possible (frames run out first), wheels left over labeled "excess" -->

### Percent Yield

The **theoretical yield** is the maximum amount of product the balanced equation predicts, calculated from the limiting reactant. The **actual yield** is the amount actually collected in real life (usually less, due to losses or side reactions). **Percent yield** compares the two:

$$\text{percent yield} = \dfrac{\text{actual yield}}{\text{theoretical yield}} \times 100\%$$

### Empirical and Molecular Formulas

The **empirical formula** shows the simplest whole-number ratio of atoms in a compound. The **molecular formula** shows the actual total number of atoms in one real molecule, which is always a whole-number multiple of the empirical formula. For example, glucose has the molecular formula $C_6H_{12}O_6$, but its empirical formula (simplified ratio) is $CH_2O$, since dividing all three subscripts by their greatest common factor, $6$, gives $1{:}2{:}1$.

## Examples

### #1: Finding the Limiting Reactant

For the reaction $N_2 + 3H_2 \rightarrow 2NH_3$, a chemist starts with $4$ moles of $N_2$ and $9$ moles of $H_2$. Which reactant is limiting?

**Solution:**
Check how much $H_2$ is actually needed to react with all the $N_2$, and compare to what is available.

1. The balanced equation needs $3$ moles of $H_2$ for every $1$ mole of $N_2$.
2. For $4$ moles of $N_2$, the amount of $H_2$ needed is:

$$4 \times 3 = 12 \text{ moles of } H_2 \text{ needed}$$

3. Only $9$ moles of $H_2$ are available, which is less than the $12$ moles needed.
4. Since $H_2$ runs out before all the $N_2$ can react, $H_2$ is the limiting reactant (and $N_2$ is in excess).

### #2: Calculating Percent Yield

A reaction's balanced equation predicts a theoretical yield of $50$ grams of product. In the actual laboratory experiment, only $42$ grams were collected. Find the percent yield.

**Solution:**
Divide actual yield by theoretical yield, then convert to a percentage.

1. Apply the formula.

$$\text{percent yield} = \dfrac{42}{50} \times 100\%$$

2. Compute the fraction.

$$\dfrac{42}{50} = 0.84$$

3. Convert to a percentage.

$$0.84 \times 100\% = 84\%$$

4. The percent yield is $84\%$.

### #3: Finding an Empirical Formula

A compound is found to contain $2$ moles of carbon, $6$ moles of hydrogen, and $2$ moles of oxygen. Find its empirical formula.

**Solution:**
Divide every mole amount by the smallest number among them to get the simplest whole-number ratio.

1. The smallest amount is $2$ moles (both carbon and oxygen).
2. Divide each element's moles by $2$.

$$\dfrac{2}{2} = 1 \quad \dfrac{6}{2} = 3 \quad \dfrac{2}{2} = 1$$

3. The simplest ratio is carbon $1$, hydrogen $3$, oxygen $1$.
4. The empirical formula is $CH_3O$.

### #4: From Empirical Formula to Molecular Formula

A compound has the empirical formula $CH_2$ (empirical formula mass $= 14$ g/mol) and an actual molar mass of $56$ g/mol. Find its molecular formula.

**Solution:**
Find how many times the empirical formula "fits into" the true molar mass.

1. Divide the actual molar mass by the empirical formula mass.

$$\dfrac{56}{14} = 4$$

2. This means the molecular formula is the empirical formula multiplied by $4$.

$$C_{(1 \times 4)}H_{(2 \times 4)} = C_4H_8$$

3. The molecular formula is $C_4H_8$.

## Speed Tricks & Shortcuts

For limiting reactant problems, do not just compare the raw mole amounts of each reactant — always check them against the balanced equation's ratio first. A reactant with a "bigger number" of moles can still be limiting if the equation requires even more of it.

For empirical formula problems, always divide by the smallest mole value first. This one step guarantees you land on the simplest possible whole-number ratio in a single move.

Remember the empirical-to-molecular relationship as one multiplication: molecular formula mass ÷ empirical formula mass gives a whole number multiplier, applied to every subscript in the empirical formula.

## Traps to Watch For

### #1: Assuming the Smaller Mole Amount Is Always Limiting

> The limiting reactant depends on the equation'S ratio, not just on which reactant has fewer raw moles.

In Example 1, $N_2$ (only $4$ moles) actually has fewer moles than $H_2$ ($9$ moles), yet $H_2$ turns out to be the limiting reactant once the $1{:}3$ ratio is applied. Never skip the ratio check.

### #2: Reversing the Percent Yield Formula

> Percent yield divides actual yield by theoretical yield, never the other way around.

Dividing theoretical by actual would give a result greater than $100\%$ in this example ($50 \div 42 \approx 1.19$, or $119\%$), which does not match how percent yield is meant to work (percent yield is usually at or below $100\%$, since real yields rarely exceed the theoretical maximum).

### #3: Confusing Empirical and Molecular Formulas

> The empirical formula shows the simplest ratio; the molecular formula shows the true total count of atoms in one molecule.

A compound's empirical formula ($CH_2O$) and its molecular formula ($C_6H_{12}O_6$, for glucose) look different, but they represent the same substance — the molecular formula is just a whole-number multiple of the empirical ratio. Giving the empirical formula when the molecular formula is specifically asked for (or vice versa) misses the question's exact requirement.

### #4: Forgetting to Divide by the Correct Smallest Number

> When simplifying to an empirical formula, divide every element's mole count by the same smallest value — do not divide by different numbers for different elements.

If the mole amounts are $2$, $6$, and $2$, all three must be divided by the same number ($2$, the smallest), giving $1$, $3$, $1$. Dividing each element by a different number would break the true ratio between them.

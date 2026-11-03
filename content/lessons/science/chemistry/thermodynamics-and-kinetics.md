---
_id: "lesson-chemistry-thermodynamics-and-kinetics"
title: "Thermodynamics and Kinetics (Endothermic vs. Exothermic Reactions, Catalysts)"
summary: "Tells apart the heat of a reaction, its speed, and its equilibrium, and shows how temperature, concentration, surface area and catalysts change the rate."
subject: "subject-science"
topic: "topic-chemistry"
estimatedMinutes: 15
isActive: true
---
## Core Concept

A chemical reaction raises three separate questions. How much heat does it give out or take in? How fast does it go? Where does it end up?

**Thermodynamics** looks at energy changes and at whether a reaction can go forward on its own. **Kinetics** looks at how fast a reaction goes. Do not mix them up. A reaction can release a lot of heat and still be very slow.

### Endothermic vs. Exothermic

The heat a reaction exchanges at constant pressure is its **enthalpy change**, written $\Delta H$. It equals the enthalpy of the products minus the enthalpy of the reactants. It is measured in kilojoules ($\text{kJ}$).

- **Exothermic:** $\Delta H<0$. Heat flows out of the reacting chemicals into the surroundings.
- **Endothermic:** $\Delta H>0$. Heat flows from the surroundings into the reacting chemicals.

In a simple insulated setup, an exothermic reaction warms the surroundings and an endothermic one cools them. How hot or cold something feels also depends on the apparatus, so the sign of $\Delta H$ is the real definition.

<!-- FIGURE: {"kind":"chemistry-diagram","type":"reaction-energy","illustrationKey":"science/chemistry/thermodynamics-and-kinetics#1","profiles":[{"label":"exothermic","reactants":"high","products":"lower","energy":"released"},{"label":"endothermic","reactants":"low","products":"higher","energy":"absorbed"}]} -->

### Spontaneous Does Not Mean Fast

A reaction is **spontaneous** when it can go forward on its own, without a steady outside push. Spontaneous says nothing about speed.

Spontaneity depends on the Gibbs free energy change, $\Delta G=\Delta H-T\Delta S$, at constant temperature and pressure. Here $T$ is the temperature in kelvin. $\Delta S$ is the **entropy** change: it is positive when the particles and energy end up more spread out.

A reaction is spontaneous when $\Delta G<0$. So an exothermic reaction is not always spontaneous, and an endothermic one is not always nonspontaneous. If $\Delta H<0$ and $\Delta S>0$, $\Delta G$ is negative at every temperature. If $\Delta H>0$ and $\Delta S<0$, it is never negative. In the other two cases, the temperature decides.

### Activation Energy and Collision Theory

**Collision theory** says particles react only when they collide. A collision leads to a reaction only if the particles have enough energy and meet in a suitable orientation.

The smallest energy needed is the **activation energy**, $E_a$. It is the energy barrier between the reactants and the highest point of the pathway, called the **transition state**. A lower barrier means more collisions get over it.

The **rate of a reaction** is how fast the concentration of a reactant falls or of a product rises. Its unit is $\text{mol/(L}\cdot\text{s)}$. The **rate constant**, $k$, is a number that shows how fast a reaction goes at a given temperature, before the concentrations are counted in. The **Arrhenius equation** links it to $E_a$:

$$k=Ae^{-E_a/(RT)}$$

Here $A$ is a factor for how often collisions have the right orientation, $R$ is the gas constant, and $T$ is the temperature in kelvin. You need only the pattern. A lower $E_a$ or a higher $T$ gives a bigger $k$. A bigger $k$ means a faster reaction at the same concentrations.

A higher $E_a$ does not always mean a slower reaction, because $A$, $T$ and the concentrations also matter. When two reactions are compared, the same temperature and concentrations must be used.

<!-- ILLUSTRATION: energy profile with energy in kJ on the vertical axis and reaction progress on the horizontal axis: reactants at 50 kJ, peak at 120 kJ labeled transition state, products at 20 kJ; arrows for Ea forward = 70 kJ and delta H = -30 kJ; a dashed lower peak at 90 kJ labeled with catalyst -->

### Catalysts

A **catalyst** speeds up a reaction by giving it a new pathway with a lower activation energy. The catalyst can take part in the steps of that pathway. It is given back at the end, so it is not used up. Enzymes are catalysts made by living things.

For a reaction that can go both ways, a catalyst lowers the barrier in both directions by the same amount. It speeds up the forward and the reverse reaction, so equilibrium is reached sooner.

A catalyst does not change $\Delta H$, the equilibrium constant, or the equilibrium amounts at a given temperature. It cannot make a nonspontaneous reaction spontaneous. When several reactions compete for the same reactants, a different catalyst can change which product forms fastest.

### Factors That Change the Rate

- **Temperature:** for the reactions you meet in school, a higher temperature gives a faster rate. More particles have energy of at least $E_a$, and they collide more often.
- **Concentration or gas pressure:** more particles in the same space means more collisions. How much the rate changes is given by the rate law, explained next.
- **Surface area:** this matters when the reactants are in different phases, such as a solid and a liquid. Only particles at the surface of a solid can meet the other reactant. Crushing the solid exposes more of them.
- **Catalyst:** it lowers the activation energy, as above.

### Rate Law and Order

A **rate law** is an equation that tells how the rate depends on concentrations. For a reaction of $A$ and $B$ it has this form:

$$\text{rate}=k[A]^m[B]^n$$

The square brackets mean concentration in $\text{mol/L}$. The exponents $m$ and $n$ are the **orders** in $A$ and $B$. The **overall order** is $m+n$. The orders are found by experiment. They are not read from the coefficients of the balanced equation, because the equation does not show the steps of the reaction.

If the order in $A$ is $m$, then multiplying $[A]$ by a factor $f$ multiplies the rate by $f^m$. The other concentrations and the temperature must stay fixed.

- **Zero order** ($m=0$): the rate does not change, because $[A]^0=1$.
- **First order** ($m=1$): doubling $[A]$ doubles the rate.
- **Second order** ($m=2$): doubling $[A]$ makes the rate four times as big.

To find an order from data, compare two experiments in which only one concentration changes. This is the method of initial rates.

### Fair Tests: Variables and Controls

A rate experiment is fair only when one thing changes. The **independent variable** is the one thing you change on purpose. The **dependent variable** is what you measure, such as the time for a gas to form. The **controlled variables** are everything else, which you keep the same.

If two things change at once, you cannot tell which one caused the change in rate. A **control** is a baseline run with no change, kept for comparison.

### Chemical Equilibrium

Many reactions can go in both directions. Written with a double arrow, $A+B\rightleftharpoons C+D$, they are **reversible**. At the start, only the forward reaction runs fast. As products build up, the reverse reaction speeds up.

In a closed container, the two rates become equal. This is **dynamic equilibrium**. Both reactions keep going, so the amounts stay constant, but they are not necessarily equal. Nothing is leaving the system.

<!-- ILLUSTRATION: graph of rate against time: the forward rate curve falls and the reverse rate curve rises from zero until they meet and level off at the same height, with the meeting point labeled equilibrium -->

For $a\,A+b\,B\rightleftharpoons c\,C+d\,D$, the **equilibrium constant** is built from the concentrations at equilibrium:

$$K=\dfrac{[C]^c[D]^d}{[A]^a[B]^b}$$

Products are on top, reactants are on the bottom, and each concentration is raised to its coefficient. Pure solids and pure liquids are left out. A large $K$ means products are favored at equilibrium. A small $K$ means reactants are favored. $K$ does not tell how fast equilibrium is reached.

For a given equation, $K$ changes only with temperature.

### Le Chatelier's Principle

**Le Chatelier's principle** says: when a change is applied to a system at equilibrium, the system shifts in the direction that partly cancels the change. Shifting right means making more products. Shifting left means making more reactants.

- **Add a substance:** the system shifts away from it. **Remove a substance:** it shifts toward it. $K$ does not change.
- **Change the pressure by changing the volume:** shrinking the volume favors the side with fewer moles of gas. Enlarging it favors the side with more. If both sides have equal moles of gas, nothing shifts. $K$ does not change.
- **Add an unreactive gas at constant volume:** the concentrations do not change, so nothing shifts.
- **Raise the temperature:** the system shifts in the endothermic direction. Lowering it favors the exothermic direction. This changes $K$.
- **Add a catalyst:** nothing shifts. Equilibrium is reached sooner.

## Examples

### #1: Exothermic or Endothermic?

A cold pack becomes cool when its chemicals are mixed. A hand warmer becomes warm. Give the sign of $\Delta H$ for each.

**Solution:**

1. The cold pack takes heat from its surroundings, so it is endothermic: $\Delta H>0$.
2. The hand warmer gives heat to its surroundings, so it is exothermic: $\Delta H<0$.

### #2: Reading an Energy Profile

On an energy profile, the reactants are at $50\ \text{kJ}$, the transition state is at $120\ \text{kJ}$, and the products are at $20\ \text{kJ}$. A catalyst lowers the transition state to $90\ \text{kJ}$. Find $\Delta H$ and the forward and reverse activation energies, before and after the catalyst is added.

**Solution:**

1. The enthalpy change is the products minus the reactants:
$$\Delta H=20-50=-30\ \text{kJ}$$
2. Without the catalyst, the forward $E_a$ is the peak minus the reactants:
$$E_a=120-50=70\ \text{kJ}$$
3. The reverse $E_a$ is the peak minus the products:
$$E_a=120-20=100\ \text{kJ}$$
4. With the catalyst, the peak is $90\ \text{kJ}$. The forward $E_a$ is $90-50=40\ \text{kJ}$. The reverse $E_a$ is $90-20=70\ \text{kJ}$.
5. Both barriers fell by $30\ \text{kJ}$. $\Delta H$ is still $-30\ \text{kJ}$, so the reaction is exothermic.

### #3: Energy Release Does Not Mean Speed

A student says, "This reaction releases a lot of heat, so it must be fast." Is the student right?

**Solution:**

1. Heat released is given by $\Delta H$. Speed depends on the activation energy, the temperature, the concentrations and the pathway.
2. A reaction with a large negative $\Delta H$ can still have a high barrier and so be slow at room temperature.
3. Wood in air can release a lot of heat when it burns. It does not burn until something starts it with heat.
4. The student is not right. $\Delta H$ alone does not tell the speed.

### #4: Crushing a Solid

Marble chips react with hydrochloric acid at their surface. The same mass of marble is crushed to powder and added to the same acid. How does the rate change?

**Solution:**

1. Crushing exposes more marble surface to the acid.
2. More particles can collide with the acid at one time.
3. The rate is faster. If the acid is in excess, the total amount of gas that forms is the same, since the same mass of marble reacts.

### #5: Comparing Two Temperatures

Two flasks hold the same acid and the same mass of the same metal strips. One is kept at $20^\circ\text{C}$ and the other at $40^\circ\text{C}$. Which flask gives hydrogen gas faster, and why?

**Solution:**

1. The two flasks differ in only one thing: temperature. So any difference in rate comes from temperature.
2. At $40^\circ\text{C}$, more particles have energy of at least $E_a$, and they collide more often.
3. More collisions lead to a reaction, so the flask at $40^\circ\text{C}$ gives gas faster.

### #6: Using a Given Rate Law

A reaction has the rate law $\text{rate}=k[A]^2[B][C]^0$. Find the effect on the rate if $[A]$ is doubled and $[B]$ is halved, with $[C]$ and the temperature fixed. Then find the effect of doubling $[C]$ alone.

**Solution:**

1. Doubling $[A]$ gives a factor of $2^2=4$.
2. Halving $[B]$ gives a factor of $\left(\dfrac{1}{2}\right)^1=\dfrac{1}{2}$.
3. The rate changes by $4\times\dfrac{1}{2}=2$. It doubles.
4. Doubling $[C]$ gives $2^0=1$. The rate does not change.

### #7: Finding Orders from Data

Three runs of a reaction of $A$ and $B$ at the same temperature gave these initial rates.

- Run 1: $[A]=0.10\ \text{M}$, $[B]=0.10\ \text{M}$, rate $=2.0\times10^{-3}\ \text{M/s}$
- Run 2: $[A]=0.20\ \text{M}$, $[B]=0.10\ \text{M}$, rate $=4.0\times10^{-3}\ \text{M/s}$
- Run 3: $[A]=0.10\ \text{M}$, $[B]=0.20\ \text{M}$, rate $=8.0\times10^{-3}\ \text{M/s}$

Write the rate law and find $k$. Here $\text{M}$ means $\text{mol/L}$.

**Solution:**

1. Runs 1 and 2 differ only in $[A]$. It doubled, and the rate doubled, so the order in $A$ is $1$.
2. Runs 1 and 3 differ only in $[B]$. It doubled, and the rate became four times as big. Since $2^2=4$, the order in $B$ is $2$.
3. The rate law is:
$$\text{rate}=k[A][B]^2$$
4. Use Run 1 to find $k$:
$$k=\dfrac{2.0\times10^{-3}}{(0.10)(0.10)^2}=2.0\ \text{M}^{-2}\text{s}^{-1}$$

### #8: Planning a Fair Test

A student wants to test whether the concentration of hydrochloric acid affects the rate at which magnesium makes hydrogen. She uses $0.5\ \text{M}$ acid in one flask and $1.0\ \text{M}$ acid in another. She uses a magnesium ribbon in one flask and magnesium powder in the other. Name the variables and decide what the results can show.

**Solution:**

1. The independent variable is the acid concentration. The dependent variable is the rate of hydrogen formation, such as the volume of gas per minute.
2. The form of the magnesium was also changed, so it is not controlled. Surface area changes the rate too.
3. If the powder flask is faster, the student cannot tell whether acid concentration or surface area caused it.
4. To fix the test, use the same form and mass of magnesium, the same volume of acid, and the same temperature in both flasks.

### #9: Writing and Using $K$

At equilibrium in a closed container, the reaction $\text{H}_2(g)+\text{I}_2(g)\rightleftharpoons2\text{HI}(g)$ has $[\text{H}_2]=0.10\ \text{M}$, $[\text{I}_2]=0.10\ \text{M}$ and $[\text{HI}]=0.40\ \text{M}$. Find $K$ and say which side is favored.

**Solution:**

1. Products go on top. The coefficient $2$ of $\text{HI}$ becomes an exponent:
$$K=\dfrac{[\text{HI}]^2}{[\text{H}_2][\text{I}_2]}$$
2. Put in the values:
$$K=\dfrac{(0.40)^2}{(0.10)(0.10)}=\dfrac{0.16}{0.010}=16$$
3. $K>1$, so the product side is favored at equilibrium.

### #10: Shifting an Equilibrium

The reaction $\text{N}_2(g)+3\text{H}_2(g)\rightleftharpoons2\text{NH}_3(g)$ has $\Delta H=-92\ \text{kJ}$ for the equation as written. It is at equilibrium in a closed container. Which way does it shift if (a) the volume is made smaller, (b) the temperature is raised, (c) a catalyst is added?

**Solution:**

1. For (a), the left side has $1+3=4$ moles of gas and the right side has $2$. A smaller volume favors the side with fewer moles, so it shifts right.
2. For (b), $\Delta H<0$, so the forward reaction is exothermic. Raising the temperature favors the endothermic direction, which is the reverse. It shifts left, and $K$ gets smaller.
3. For (c), a catalyst speeds both directions equally. There is no shift and $K$ is unchanged. Equilibrium is reached sooner.

### #11: A Catalyst at Equilibrium

The same reversible reaction is run at the same temperature, once without and once with a catalyst. Compare the two runs.

**Solution:**

1. The catalyst lowers the activation energy in both directions.
2. The forward and reverse rates both go up, so equilibrium is reached sooner.
3. The equilibrium constant and the equilibrium amounts are the same in both runs.

## Speed Tricks & Shortcuts

Sort each quantity by the question it answers. $\Delta H$ answers how much heat. $\Delta G$ and $K$ answer where the reaction can go. $E_a$, the rate law and catalysts answer how fast.

To find the effect of a concentration change, raise the factor to the order, as in $f^m$. This works when the other concentrations and the temperature stay the same.

For a pressure change in an equilibrium question, count the moles of gas on each side first. Use this when the pressure changes because the volume changes. If the counts are equal, there is no shift.

For a temperature change in an equilibrium question, read the sign of $\Delta H$ first. Treat heat as a reactant in an endothermic reaction and as a product in an exothermic one, then shift away from what you add.

## Traps to Watch For

### #1: Exothermic Means Fast or Spontaneous

> A negative $\Delta H$ does not tell the speed, and it does not decide spontaneity alone.

Speed depends on kinetics, and spontaneity depends on $\Delta G$, which includes entropy. A test may offer "releases heat, so it is fast" as a wrong choice.

### #2: A Catalyst Shifts the Equilibrium

> A catalyst does not change $K$, the equilibrium amounts, or $\Delta H$.

It speeds the forward and the reverse reaction equally, so equilibrium comes sooner. Look for choices that say a catalyst increases the yield at equilibrium.

### #3: Orders From the Balanced Equation

> Orders come from experiment, not from the coefficients.

A balanced equation can have a coefficient of $2$ while the rate law shows order $0$ or $1$. Use the order given in the rate law or found from data.

### #4: More Concentration Always Means More Rate

> The effect of concentration depends on the order, and a zero-order reactant has no effect.

Doubling a concentration does nothing if its order is $0$, and quadruples the rate if its order is $2$.

### #5: Equal at Equilibrium

> At equilibrium the rates are equal, but the amounts need not be.

The forward and reverse rates match, and the concentrations stay constant. The concentrations of reactants and products can still be very different.

### #6: A Pressure Change Always Shifts the Equilibrium

> A pressure change shifts the position only when the moles of gas differ on the two sides, and only when the volume changes.

If the moles of gas are equal, such as in $\text{H}_2+\text{I}_2\rightleftharpoons2\text{HI}$, nothing shifts. Adding an unreactive gas at constant volume does not shift it either.

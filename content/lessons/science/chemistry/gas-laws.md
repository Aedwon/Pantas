---
_id: "lesson-chemistry-gas-laws"
title: "Gas Laws (Boyle's, Charles's, Gay-Lussac's, Combined, Avogadro's, Ideal Gas Law)"
summary: "The relationships between pressure, volume, temperature, and amount of gas, and how to use each gas law formula."
subject: "subject-science"
topic: "topic-chemistry"
estimatedMinutes: 13
isActive: true
---
## Core Concept

Gas behavior depends on four connected quantities: **pressure** ($P$), **volume** ($V$), **temperature** ($T$, always in kelvin for gas law calculations), and the **number of moles** ($n$). Each gas law fixes two of these quantities constant and studies how the other two relate.

**Boyle's Law**: at constant temperature and amount, pressure and volume are inversely related: squeeze a gas into a smaller volume, and its pressure goes up.

$$P_1 V_1 = P_2 V_2$$

**Charles's Law**: at constant pressure and amount, volume and temperature are directly related: heat a gas up, and it expands.

$$\dfrac{V_1}{T_1} = \dfrac{V_2}{T_2}$$

**Gay-Lussac's Law**: at constant volume and amount, pressure and temperature are directly related: heat a sealed, rigid container of gas, and its pressure rises.

$$\dfrac{P_1}{T_1} = \dfrac{P_2}{T_2}$$

**Avogadro's Law**: at constant pressure and temperature, volume and the number of moles are directly related: more gas particles need more space.

$$\dfrac{V_1}{n_1} = \dfrac{V_2}{n_2}$$

<!-- ILLUSTRATION: four small pistons or containers side by side, each showing one gas law in action: a piston being compressed (Boyle's), a balloon expanding when heated (Charles's), a sealed rigid can with rising pressure gauge when heated (Gay-Lussac's), and a container growing larger as more gas particles are added (Avogadro's) -->

**Combined Gas Law**: merges Boyle's, Charles's, and Gay-Lussac's laws into one formula, useful when pressure, volume, and temperature all change at once (with the amount of gas staying fixed):

$$\dfrac{P_1 V_1}{T_1} = \dfrac{P_2 V_2}{T_2}$$

**Ideal Gas Law**: adds in the amount of gas (moles) to relate all four quantities at once, without needing a "before and after" comparison:

$$PV = nRT$$

where $R$ is the universal gas constant.

## Examples

### #1: Applying Boyle's Law

A gas occupies $4$ liters at a pressure of $2$ atm. If the pressure is increased to $8$ atm at the same temperature, what is the new volume?

**Solution:**
Apply Boyle's Law, keeping units consistent.

1. Set up the equation.

$$P_1 V_1 = P_2 V_2$$

$$(2)(4) = (8)(V_2)$$

2. Compute the left side.

$$8 = 8V_2$$

3. Divide both sides by $8$.

$$V_2 = 1 \text{ liter}$$

4. As expected, increasing the pressure (by $4$ times) shrank the volume (to $\dfrac{1}{4}$ its original size): pressure and volume move in opposite directions.

### #2: Applying Charles's Law

A gas occupies $2$ liters at $300$ K. If it is heated to $600$ K at constant pressure, what is the new volume?

**Solution:**
Apply Charles's Law directly (temperature must be in Kelvin).

1. Set up the equation.

$$\dfrac{V_1}{T_1} = \dfrac{V_2}{T_2}$$

$$\dfrac{2}{300} = \dfrac{V_2}{600}$$

2. Cross multiply.

$$2 \times 600 = 300 \times V_2$$

3. Compute and solve for $V_2$.

$$1200 = 300 V_2$$

$$V_2 = 4 \text{ liters}$$

4. Doubling the temperature (from $300$ K to $600$ K) doubled the volume: temperature and volume move in the same direction.

### #3: Applying the Combined Gas Law

A gas has a pressure of $1$ atm, a volume of $3$ liters, and a temperature of $250$ K. If the pressure changes to $2$ atm and the temperature changes to $500$ K, find the new volume.

**Solution:**
All three quantities are changing, so use the combined gas law.

1. Set up the equation.

$$\dfrac{P_1 V_1}{T_1} = \dfrac{P_2 V_2}{T_2}$$

$$\dfrac{(1)(3)}{250} = \dfrac{(2)(V_2)}{500}$$

2. Cross multiply.

$$3 \times 500 = 250 \times 2 \times V_2$$

3. Compute both sides.

$$1500 = 500 V_2$$

4. Divide.

$$V_2 = 3 \text{ liters}$$

5. Interesting result: the volume stayed the same, because pressure doubled (which alone would halve the volume) while temperature also doubled (which alone would double the volume): these two effects canceled out exactly.

### #4: Applying the Ideal Gas Law

How many moles of gas are in a $10$-liter container at a pressure of $2$ atm and a temperature of $300$ K? (Use $R = 0.0821 \, \text{L·atm/(mol·K)}$.)

**Solution:**
Rearrange the ideal gas law to solve for $n$.

1. Start with the ideal gas law.

$$PV = nRT$$

2. Solve for $n$ by dividing both sides by $RT$.

$$n = \dfrac{PV}{RT}$$

3. Substitute the given values.

$$n = \dfrac{(2)(10)}{(0.0821)(300)}$$

4. Compute the top and bottom separately: top is $20$; bottom is $0.0821 \times 300 = 24.63$.

$$n = \dfrac{20}{24.63} \approx 0.81 \text{ moles}$$

## Speed Tricks & Shortcuts

To pick the right gas law fast, identify which quantity is being held constant: temperature and amount fixed → Boyle's; pressure and amount fixed → Charles's; volume and amount fixed → Gay-Lussac's; pressure and temperature fixed → Avogadro's. If three quantities change and amount stays fixed, use the combined gas law. If moles are given or asked for, use the ideal gas law.

Before calculating, predict the direction of the answer using the relationship type: pressure and volume are inverse (one up, other down); volume-temperature and pressure-temperature are direct (both up or both down together). This catches many arithmetic errors before you even finish computing.

Always convert temperature to kelvin before using any gas law formula. To convert, add $273$ to the Celsius temperature.

## Traps to Watch For

### #1: Forgetting to Convert Temperature to Kelvin

> All gas law formulas require temperature in kelvin, never Celsius or Fahrenheit.

Plugging in a Celsius temperature directly (especially a negative Celsius value) breaks the proportional relationships these laws depend on, since Kelvin is the only scale where zero truly means "no thermal energy." Always add $273$ to Celsius first.

### #2: Mixing Up Direct and Inverse Relationships

> Boyle's Law (pressure-volume) is inverse. Charles's Law and Gay-Lussac's Law are direct.

Applying a direct-relationship setup to Boyle's Law (or vice versa) flips the entire answer. Before computing, briefly reason through the physical intuition: squeezing a gas into less space raises its pressure (inverse); heating a gas makes it expand (direct).

### #3: Using the Wrong Gas Law When Multiple Quantities Change

> If pressure, volume, and temperature all change together (with a fixed amount of gas), use the combined gas law, not one of the three individual laws.

Trying to apply just Boyle's Law when temperature is also changing ignores an entire variable and produces an incorrect result. Check how many quantities are actually changing before selecting a formula.

### #4: Confusing the Ideal Gas Law's Constant with Combined Gas Law Problems

> The Ideal Gas Law ($PV = nRT$) is for a single snapshot in time (no "before and after"). The Combined Gas Law compares two different states of the same fixed amount of gas.

If a problem gives specific values of $P$, $V$, $n$, and $T$ all at one moment (not describing a change), use $PV = nRT$ directly. If a problem describes a gas changing from one condition to another (with moles staying fixed), use the combined gas law instead.

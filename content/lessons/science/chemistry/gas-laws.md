---
_id: "lesson-chemistry-gas-laws"
title: "Gas Laws (Boyle's, Charles's, Amontons's/Gay-Lussac's, Combined, Avogadro's, Ideal Gas Law)"
summary: "How the pressure, volume, temperature, and amount of a gas change together, why each gas law works, and when each equation applies."
subject: "subject-science"
topic: "topic-chemistry"
estimatedMinutes: 15
isActive: true
---
## Core Concept

A gas has no fixed shape or size. It spreads out to fill its container. Four quantities describe a gas sample, and the gas laws link them.

### The Four Quantities

**Pressure** ($P$) is the force a gas pushes on each unit of area of its container wall. Common units are atmosphere (atm), kilopascal (kPa), and millimeters of mercury (mmHg). They are related by $1\text{ atm}=101.325\text{ kPa}=760\text{ mmHg}$.

**Volume** ($V$) is the space the gas fills, which is the volume of its container. Common units are liter (L) and milliliter (mL), where $1\text{ L}=1000\text{ mL}$.

**Temperature** ($T$) tells how hot the gas is. Gas laws need it in kelvin, explained below.

**Amount** ($n$) is the number of moles of gas. One **mole** is $6.022\times10^{23}$ particles, the same idea taught in the mole concept lesson.

### Why Gases Behave This Way: Kinetic Molecular Theory

The **Kinetic Molecular Theory** is a model of an **ideal gas**, an imagined gas that follows the gas laws exactly. It has four ideas:

- Gas particles are very far apart compared with their own size, so their volume is treated as zero.
- The particles move all the time, in random directions, in straight lines until they collide.
- The particles do not attract or repel each other. Collisions lose no energy.
- The average kinetic energy (energy of motion) of the particles is proportional to the kelvin temperature. Hotter gas means faster particles.

Pressure comes from these collisions. Billions of particles hit the wall every second, and the many small pushes add up to a steady force.

<!-- ILLUSTRATION: a rigid box of gas particles drawn as dots with short arrows showing random straight-line motion, with a few arrows hitting the right wall and the label "collisions with the wall make pressure" -->

### Kelvin: The Absolute Temperature Scale

The **kelvin** scale starts at **absolute zero**, the lowest possible temperature, written $0$ K. Celsius puts its zero at the freezing point of water, which is not a true zero of temperature, so Celsius values can be negative. To convert, use:

$$T(\mathrm K)=T(^\circ\mathrm C)+273.15$$

Kinetic energy is proportional to the kelvin temperature, so the gas laws work with kelvin. Doubling the kelvin temperature doubles the average kinetic energy.

Going from $10\,^\circ\mathrm C$ to $20\,^\circ\mathrm C$ does not double anything. Always convert to kelvin before using a gas law that contains $T$.

### Reading a Gas Investigation: Three Kinds of Variables

An investigation changes one quantity and watches another.

The **independent variable** is the quantity the investigator changes on purpose. The **dependent variable** is the quantity measured to see the effect. The **controlled variables** are the quantities kept the same so the test is fair.

Each gas law is one such investigation of a gas. The other two quantities are controlled. The list below gives the variables of each law.

- Boyle: change $V$ and measure $P$, or the reverse. Control $n$ and $T$.
- Charles: change $T$ and measure $V$. Control $n$ and $P$.
- Gay-Lussac: change $T$ and measure $P$. Control $n$ and $V$.
- Avogadro: change $n$ and measure $V$. Control $P$ and $T$.

### Boyle's Law

For a fixed amount of gas at constant temperature, pressure and volume are **inversely proportional**. That means when one goes up, the other goes down by the same factor.

$$P_1V_1=P_2V_2$$

Squeezing the gas into half the volume puts the same particles in half the space. They hit the walls twice as often, so the pressure doubles. The same units must be used for $P_1$ and $P_2$, and the same units for $V_1$ and $V_2$.

### Charles's Law

For a fixed amount of gas at constant pressure, volume is **directly proportional** to the kelvin temperature. That means both change by the same factor.

$$\dfrac{V_1}{T_1}=\dfrac{V_2}{T_2}$$

Hotter particles move faster and hit the walls harder. To keep the pressure the same, the container must grow, so the particles spread out and hit less often. This needs a container that can change size, such as a balloon or a piston.

The law holds while the sample stays a gas. If cooling makes the sample condense into a liquid or a solid, the law no longer applies.

### Amontons's / Gay-Lussac's Law

For a fixed amount of gas at constant volume, pressure is directly proportional to the kelvin temperature.

$$\dfrac{P_1}{T_1}=\dfrac{P_2}{T_2}$$

The container cannot grow. Hotter particles hit the walls both harder and more often, so the pressure rises. This relation is called **Amontons's law** or **Gay-Lussac's law**.

### Avogadro's Law

At constant temperature and pressure, volume is directly proportional to the amount of gas.

$$\dfrac{V_1}{n_1}=\dfrac{V_2}{n_2}$$

More particles hit the walls more often. The container must grow to keep the pressure the same.

This applies when the gas can change volume. Adding gas to a rigid container does not change $V$, so the pressure rises instead.

<!-- FIGURE: {"kind":"chemistry-diagram","type":"gas-laws-gallery","illustrationKey":"science/chemistry/gas-laws#1","laws":[{"label":"Boyle's","scene":"piston compressed"},{"label":"Charles's","scene":"balloon expands when heated"},{"label":"Gay-Lussac's","scene":"sealed rigid can, pressure rises when heated"},{"label":"Avogadro's","scene":"container grows as more gas particles are added"}]} -->

### Combined and Ideal Gas Laws

The three ratio laws above are parts of one rule. For the **same fixed amount** of gas changing from state $1$ to state $2$:

$$\dfrac{P_1V_1}{T_1}=\dfrac{P_2V_2}{T_2}$$

If one quantity does not change, it cancels, and you get Boyle's, Charles's, or Gay-Lussac's law.

The **ideal gas law** describes one state of a gas, with all four quantities:

$$PV=nRT$$

$R$ is the **gas constant**. Its value depends on the units of $P$ and $V$. Two common values are:

$$R=0.082057\,\dfrac{\mathrm{L\cdot atm}}{\mathrm{mol\cdot K}}$$

$$R=8.314\,\dfrac{\mathrm{L\cdot kPa}}{\mathrm{mol\cdot K}}$$

Use the first value with atm and L. Use the second with kPa and L. In both, $T$ is in kelvin and $n$ is in moles.

### Molar Volume and STP

The **molar volume** is the volume of one mole of gas. It changes with temperature and pressure.

At $0\,^\circ\mathrm C$ and $1$ atm, one mole of ideal gas fills about $22.4$ L. This is where the number $22.4$ L comes from.

The conditions $0\,^\circ\mathrm C$ and $1$ atm are called **STP** (standard temperature and pressure) in many textbooks.

Some sources define STP with a pressure of $100$ kPa instead. At $0\,^\circ\mathrm C$ and $100$ kPa, one mole fills about $22.7$ L. Check which pressure the problem gives.

### When the Ideal Model Fails

Real gas particles have some volume, and they attract each other a little. The ideal model ignores both. It works best at **low pressure and high temperature**, where particles are far apart and moving fast.

At high pressure the particles are squeezed close and their own volume matters. At low temperature, near the temperature where the gas turns into a liquid, the attractions matter. Then the equations give answers that are noticeably wrong. When a problem says to **assume ideal behavior**, use the equations as written.

## Examples

### #1: Converting Temperatures

Convert $27\,^\circ\mathrm C$ to kelvin. Then convert $250$ K to degrees Celsius.

**Solution:**

1. To go from Celsius to kelvin, add $273.15$.

$$T=27+273.15=300.15\text{ K}$$

2. To go from kelvin to Celsius, subtract $273.15$.

$$T=250-273.15=-23.15\,^\circ\mathrm C$$

A kelvin temperature is never negative. A Celsius temperature can be.

### #2: Variables in a Gas Investigation

A student traps $50$ mL of air in a sealed syringe and keeps it in a water bath at room temperature. She pushes the plunger to different volumes and reads the pressure each time. Name the independent variable, the dependent variable, and the controlled variables. Then name the law the data should follow.

**Solution:**

1. The student sets the volume with the plunger, so volume is the independent variable.
2. She reads the pressure to see the effect, so pressure is the dependent variable.
3. The syringe is sealed, so the amount of air is controlled. The water bath keeps the temperature controlled.
4. With $n$ and $T$ fixed, $P$ and $V$ are inversely proportional, so the data should follow Boyle's law: $P_1V_1=P_2V_2$.

### #3: Boyle's Law

A gas occupies $4$ L at $2$ atm. At constant temperature, the pressure is changed to $8$ atm. Find the new volume. Assume ideal behavior.

**Solution:**

1. The amount of gas and the temperature are fixed, so use Boyle's law.

$$P_1V_1=P_2V_2$$

2. Put in the values.

$$(2)(4)=(8)V_2$$

3. Solve for $V_2$.

$$V_2=\dfrac{8}{8}=1\text{ L}$$

The pressure became $4$ times larger, so the volume became $4$ times smaller.

### #4: Charles's Law With Celsius Temperatures

A balloon holds $2.0$ L of air at $27\,^\circ\mathrm C$. It is warmed to $127\,^\circ\mathrm C$ at constant pressure. Find the new volume.

**Solution:**

1. Pressure and amount are fixed, so use Charles's law. First change both temperatures to kelvin.

$$T_1=27+273.15=300.15\text{ K}$$

$$T_2=127+273.15=400.15\text{ K}$$

2. Write the law and solve for $V_2$.

$$\dfrac{2.0}{300.15}=\dfrac{V_2}{400.15}$$

$$V_2=2.0\times\dfrac{400.15}{300.15}\approx2.67\text{ L}$$

The volume rose by a factor of about $1.33$, not by a factor of $127/27$, which is what Celsius values would wrongly give.

### #5: Gay-Lussac's Law

A sealed rigid tank holds gas at $150$ kPa and $27\,^\circ\mathrm C$. The tank is heated to $87\,^\circ\mathrm C$. Find the new pressure.

**Solution:**

1. The tank is sealed and rigid, so $n$ and $V$ are fixed. Use Gay-Lussac's law. Convert to kelvin.

$$T_1=300.15\text{ K}$$

$$T_2=87+273.15=360.15\text{ K}$$

2. Write the law and solve for $P_2$.

$$\dfrac{150}{300.15}=\dfrac{P_2}{360.15}$$

$$P_2=150\times\dfrac{360.15}{300.15}\approx180\text{ kPa}$$

The pressure unit stays kPa because $P_1$ was in kPa.

### #6: Avogadro's Law

A balloon holds $2.0$ L of gas that contains $0.10$ mol. More gas is added until the balloon holds $0.25$ mol. The temperature and pressure stay the same. Find the new volume.

**Solution:**

1. Temperature and pressure are fixed, so use Avogadro's law.

$$\dfrac{V_1}{n_1}=\dfrac{V_2}{n_2}$$

2. Put in the values.

$$\dfrac{2.0}{0.10}=\dfrac{V_2}{0.25}$$

3. Solve for $V_2$.

$$V_2=2.0\times\dfrac{0.25}{0.10}=5.0\text{ L}$$

The amount went up by a factor of $2.5$, so the volume did too.

### #7: Combined Gas Law

A fixed sample of gas has a volume of $6.0$ L at $1.0$ atm and $27\,^\circ\mathrm C$. It changes to $3.0$ atm and $87\,^\circ\mathrm C$. Find the new volume.

**Solution:**

1. The amount is fixed, but $P$, $V$, and $T$ all change. Use the combined law. Convert to kelvin: $T_1=300.15$ K and $T_2=360.15$ K.

$$\dfrac{P_1V_1}{T_1}=\dfrac{P_2V_2}{T_2}$$

2. Put in the values.

$$\dfrac{(1.0)(6.0)}{300.15}=\dfrac{(3.0)V_2}{360.15}$$

3. Solve for $V_2$.

$$V_2=\dfrac{(1.0)(6.0)(360.15)}{(3.0)(300.15)}\approx2.4\text{ L}$$

The higher pressure shrinks the gas. The higher temperature expands it a little. The pressure effect is larger.

### #8: Ideal Gas Law, Finding Moles

How many moles of an ideal gas occupy $10$ L at $2$ atm and $300$ K?

**Solution:**

1. One state with $P$, $V$, and $T$ is given, so use $PV=nRT$. The units are atm and L, so use $R=0.082057$ L$\cdot$atm/(mol$\cdot$K).
2. Rearrange for $n$.

$$n=\dfrac{PV}{RT}$$

3. Put in the values.

$$n=\dfrac{(2)(10)}{(0.082057)(300)}\approx0.81\text{ mol}$$

### #9: Ideal Gas Law, Finding Mass

A $10.0$ L tank holds oxygen gas ($\mathrm{O_2}$, molar mass $32.00$ g/mol) at $2.00$ atm and $27\,^\circ\mathrm C$. Find the mass of the gas. Assume ideal behavior.

**Solution:**

1. Convert the temperature: $T=27+273.15=300.15$ K.
2. Find the moles from $n=\dfrac{PV}{RT}$.

$$n=\dfrac{(2.00)(10.0)}{(0.082057)(300.15)}\approx0.812\text{ mol}$$

3. Multiply the moles by the molar mass.

$$m=0.812\times32.00\approx26.0\text{ g}$$

### #10: Molar Volume at Two Conditions

Find the volume of $0.50$ mol of an ideal gas at $25\,^\circ\mathrm C$ and $101.325$ kPa. Then say whether the $22.4$ L molar volume applies.

**Solution:**

1. Convert the temperature: $T=25+273.15=298.15$ K. The pressure is in kPa, so use $R=8.314$ L$\cdot$kPa/(mol$\cdot$K).
2. Rearrange $PV=nRT$ for $V$ and put in the values.

$$V=\dfrac{nRT}{P}=\dfrac{(0.50)(8.314)(298.15)}{101.325}\approx12.2\text{ L}$$

3. One mole would fill about $24.5$ L, not $22.4$ L. The value $22.4$ L is true at $0\,^\circ\mathrm C$ and $1$ atm. This gas is warmer at the same pressure, so it takes more space.

### #11: Explaining a Gas With Kinetic Molecular Theory

A sealed rigid can holds gas at $25\,^\circ\mathrm C$. The can is heated to $100\,^\circ\mathrm C$. Use the Kinetic Molecular Theory to explain the pressure change. Then say which idea of the theory fails first if the same gas is squeezed to a very high pressure.

**Solution:**

1. The can is sealed and rigid, so the number of particles and the volume stay the same.
2. A higher kelvin temperature means a higher average kinetic energy, so the particles move faster.
3. Faster particles hit the walls harder and more often. The many pushes add up to a larger force on each unit of area, so the pressure rises. This matches Gay-Lussac's law.
4. At very high pressure the particles are squeezed close together. The idea that their own volume is zero then fails first, because their volume is no longer small compared with the space they fill.

## Speed Tricks & Shortcuts

First find what is fixed. Boyle: $n$ and $T$. Charles: $n$ and $P$. Gay-Lussac: $n$ and $V$. Avogadro: $P$ and $T$. The fixed quantities pick the law.

Guess the direction before you calculate. If the gas is heated at constant pressure, the volume must rise. If it is squeezed at constant temperature, the pressure must rise. If your answer goes the other way, check your work.

In a ratio law, units cancel. You may leave $P$ or $V$ in any unit as long as both states use the same one. The temperature is the exception: it must be in kelvin in every gas law.

Use the combined law when a fixed amount of gas changes state. Use $PV=nRT$ when you know the amount, or need it. If you need $n$ in two states, apply $PV=nRT$ to each state.

## Traps to Watch For

### #1: Using Celsius in a Gas Law

> Put every temperature in kelvin before using $T$ in any gas law.

Problems often give Celsius values to test this. A gas that goes from $10\,^\circ\mathrm C$ to $20\,^\circ\mathrm C$ does not double its volume, because the kelvin temperatures are $283.15$ K and $293.15$ K. Some problems allow $273$ in place of $273.15$, but use $273.15$ unless the problem says otherwise.

### #2: Using 22.4 L at Any Condition

> The molar volume of $22.4$ L is true at $0\,^\circ\mathrm C$ and $1$ atm. Do not use it at other conditions without checking.

At $25\,^\circ\mathrm C$ and $1$ atm, one mole fills about $24.5$ L. At most other conditions it is different again. For any other condition, use $PV=nRT$ to find the molar volume.

### #3: Treating Ideal Gas Laws as Exact for Every Real Gas

> Real gases move away from the equations at high pressure and at low temperature.

The equations are good approximations at ordinary conditions. A gas near the temperature where it becomes a liquid can be far from the ideal answer. Do not use the laws to find a volume at a temperature where the gas has already condensed.

### #4: Thinking 0 K Means "No Energy"

> Absolute zero is the lower limit of the kelvin scale, but it is not a state of exactly zero energy.

Matter at absolute zero still keeps a small amount of energy that cannot be removed.

Real gases turn to liquid or solid long before they reach $0$ K, so Charles's law cannot be used to predict a zero volume. Kelvin is used here because the gas laws need a scale that starts at absolute zero.

### #5: Wrong Units for $R$ or Pressure

> The unit of $R$ decides which units of $P$ and $V$ you may use.

With $R=0.082057$ L$\cdot$atm/(mol$\cdot$K), pressure must be in atm and volume in L. Convert mL to L and kPa or mmHg to atm first.

A tire gauge or similar gauge may show pressure above the outside air. The gas laws need the full pressure of the gas, so add the outside pressure to a gauge reading.

### #6: Mixing Up Which Quantity Is Fixed

> Match the law to what stays the same, not to the quantities named.

Adding gas to a balloon raises $V$ at constant pressure, which is Avogadro's law. Adding the same gas to a rigid tank raises $P$ instead, and $V$ is fixed. Read whether the container can change size.

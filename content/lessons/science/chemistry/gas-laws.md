---
_id: "lesson-chemistry-gas-laws"
title: "Gas Laws (Boyle's, Charles's, Amontons's/Gay-Lussac's, Combined, Avogadro's, Ideal Gas Law)"
summary: "The idealized relationships between pressure, volume, temperature, and amount of gas, and when to use each equation."
subject: "subject-science"
topic: "topic-chemistry"
estimatedMinutes: 13
isActive: true
---
## Core Concept

Gas behavior is described using **pressure** ($P$), **volume** ($V$), **thermodynamic temperature** ($T$), and amount of substance ($n$). The familiar gas laws are highly useful models. Real gases approach ideal behavior most closely at relatively **low pressure and high temperature**; noticeable deviations occur when molecular volume and intermolecular forces matter.

For proportional gas-law calculations, temperature must be expressed on an **absolute scale**, normally kelvin:

$$T(\mathrm K)=T(^\circ\mathrm C)+273.15$$

### Boyle's Law

For a fixed amount of gas at constant temperature, ideal-gas pressure and volume are inversely proportional:

$$P_1V_1=P_2V_2$$

### Charles's Law

For a fixed amount of gas at constant pressure, volume is directly proportional to absolute temperature:

$$\frac{V_1}{T_1}=\frac{V_2}{T_2}$$

### Amontons's / Gay-Lussac's Law

For a fixed amount of gas at constant volume, pressure is directly proportional to absolute temperature:

$$\frac{P_1}{T_1}=\frac{P_2}{T_2}$$

The pressure-temperature relation is often called **Amontons's law** or **Gay-Lussac's law**.

### Avogadro's Law

At constant temperature and pressure, ideal-gas volume is proportional to the amount of gas:

$$\frac{V_1}{n_1}=\frac{V_2}{n_2}$$

This statement assumes the gas is allowed to change volume so that pressure and temperature stay fixed; adding particles to a rigid vessel instead raises pressure.

<!-- FIGURE: {"kind":"chemistry-diagram","type":"gas-laws-gallery","illustrationKey":"science/chemistry/gas-laws#1","laws":[{"label":"Boyle's","scene":"piston compressed"},{"label":"Charles's","scene":"balloon expands when heated"},{"label":"Gay-Lussac's","scene":"sealed rigid can, pressure rises when heated"},{"label":"Avogadro's","scene":"container grows as more gas particles are added"}]} -->

### Combined and Ideal Gas Laws

For the **same fixed amount** of gas changing between two states:

$$\frac{P_1V_1}{T_1}=\frac{P_2V_2}{T_2}$$

For one ideal-gas state:

$$PV=nRT$$

The numerical value of $R$ depends on the units used, so pressure and volume units must match the chosen gas constant.

## Examples

### #1: Boyle's Law

A gas occupies $4$ L at $2$ atm. At constant temperature, the pressure is changed to $8$ atm. Find the ideal-model volume.

**Solution:**

$$P_1V_1=P_2V_2$$

$$(2)(4)=(8)V_2$$

$$V_2=1\text{ L}$$

### #2: Charles's Law

A gas occupies $2$ L at $300$ K. At constant pressure it is heated to $600$ K. Find the ideal-model volume.

**Solution:**

$$\frac{2}{300}=\frac{V_2}{600}$$

$$V_2=4\text{ L}$$

### #3: Combined Gas Law

A fixed gas sample is at $1$ atm, $3$ L, and $250$ K. It changes to $2$ atm and $500$ K. Find $V_2$ under the ideal model.

**Solution:**

$$\frac{(1)(3)}{250}=\frac{(2)V_2}{500}$$

$$V_2=3\text{ L}$$

The pressure and temperature both doubled, so their effects cancel in this setup.

### #4: Ideal Gas Law

How many moles of an ideal gas occupy $10$ L at $2$ atm and $300$ K? Use $R=0.082057\,\mathrm{L\,atm\,mol^{-1}\,K^{-1}}$.

**Solution:**

$$n=\frac{PV}{RT}$$

$$n=\frac{(2)(10)}{(0.082057)(300)}\approx0.812\text{ mol}$$

The appropriate reported precision depends on the precision of the given measurements.

## Speed Tricks & Shortcuts

First identify which quantities are fixed. Boyle: fixed $n,T$; Charles: fixed $n,P$; Amontons/Gay-Lussac: fixed $n,V$; Avogadro: fixed $P,T$.

Use kelvin whenever a law relies on proportionality to temperature. Celsius does not have its zero at absolute zero, so ratios such as $V/T$ do not work with Celsius values.

Use the combined law when a fixed sample changes $P,V,T$. Use $PV=nRT$ whenever one state involves $P,V,n,T$ directly—including cases where you must apply it separately to two states.

## Traps to Watch For

### #1: Saying 0 K Means "No Thermal Energy"

> Zero kelvin is absolute zero, the lower bound of thermodynamic temperature, but it should not be described as a universal state of literally zero microscopic energy.

Quantum systems can retain zero-point energy. The reason kelvin is used here is that gas-law proportionalities require an absolute temperature scale.

### #2: Treating Ideal Gas Laws as Exact for Every Real Gas

> Real gases deviate most strongly at high pressures and low temperatures, where particle volume and attractions matter.

The equations are excellent approximations over many ordinary conditions, not exceptionless laws of nature for all gases.

### #3: Using $+273$ as an Exact Celsius-to-Kelvin Conversion

> The exact offset is $273.15$.

A problem may intentionally allow $273$ as a classroom approximation, but use $273.15$ unless the problem specifies otherwise.

### #4: Forgetting Unit Consistency in $PV=nRT$

> The units of $R$ determine the compatible pressure and volume units.

For example, $R\approx0.082057\,\mathrm{L\,atm\,mol^{-1}\,K^{-1}}$ requires liters and atmospheres.

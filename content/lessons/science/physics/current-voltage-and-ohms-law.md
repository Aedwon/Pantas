---
_id: "lesson-physics-current-voltage-and-ohms-law"
title: "Current, Voltage, and Ohm’s Law"
summary: "Relate charge flow, voltage, and resistance."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 4
partCount: 11
ordering: 102
keyPoints:
  - "Use charge and time to find current and identify its direction."
  - "Relate voltage to the energy given to a charge."
  - "Use Ohm’s law for a constant resistance."
---
## Core Concept

### Current, Voltage, and Resistance

**Current** is the flow of charge. For a steady flow, it is the charge $Q$ that passes a point each second: $I=\dfrac{Q}{t}$. Its unit is the ampere, $1\ \mathrm{A}=1\ \mathrm{C/s}$.

By convention, current points the way positive charge would flow, from the positive terminal (where a wire joins the battery) around the circuit to the negative one. This is called **conventional current**. In a metal wire, the electrons really move the other way.

**Voltage**, or potential difference, is the energy for each coulomb of charge: $V=\dfrac{W}{q}$. Its unit is the volt, $1\ \mathrm{V}=1\ \mathrm{J/C}$, where the joule ($\mathrm{J}$) is the unit of energy.

A battery gives each coulomb energy, so the battery supplies voltage. Here, a battery keeps the same voltage whatever the current. A resistor changes that energy to heat or light, so the voltage drops across it.

**Resistance** $R$ measures how strongly a part opposes current. Its unit is the ohm ($\Omega$). For an **ohmic** part, whose resistance stays constant, **Ohm's law** applies:

$$V=IR$$

Ohm's law is not true for every device. A diode or a bulb filament whose resistance changes with temperature is not ohmic.

## Examples

### #1: Current, Voltage, and Energy

A charge of $12$ C passes a point in $4.0$ s. A $12$ V battery moves $12$ C through a lamp. Find the current and the energy the battery gives.

**Solution:**

1. Current:

$$I=\dfrac{12}{4.0}=3.0\ \mathrm{A}$$

2. From $V=\dfrac{W}{q}$, the energy is:

$$W=qV=(12)(12)=144\ \mathrm{J}$$

### #2: Ohm's Law

An ohmic resistor has resistance $10\ \Omega$ and carries a current of $2$ A. Find the voltage across it.

<!-- FIGURE: {"kind":"physics-energy-diagram","type":"ohms-law-circuit","illustrationKey":"science/physics/electricity-and-magnetism#3","resistanceOhms":10,"currentAmps":2,"voltageLabel":"?"} -->

**Solution:**

$$V=IR=(2)(10)=20\ \mathrm{V}$$

## Traps to Watch For

### #1: Treating Ohm's Law as Universal

> Ohm's law with one constant $R$ fits only ohmic parts.

A bulb filament and a diode are examples. For these, $R=\dfrac{V}{I}$ still gives the resistance at one moment, but it changes as the current changes.

---
_id: "lesson-physics-converting-units-with-cancellation"
title: "Converting Units with Cancellation"
summary: "Cancel units with conversion factors for simple and compound units."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 3
partCount: 7
ordering: 0
keyPoints:
  - "Cancel units with conversion factors for simple or compound units."
---
## Core Concept

### Dimensional Analysis: Converting Units

**Dimensional analysis** is a method for converting between units by multiplying by **conversion factors**. A conversion factor is a fraction equal to $1$, built from two equal amounts. For example, $1\ \text{m} = 100\ \text{cm}$ gives $\dfrac{1\ \text{m}}{100\ \text{cm}}$.

Multiplying by it changes the units, not the actual size of the quantity.

Arrange each factor so the unwanted unit appears once on top and once on the bottom. It then cancels, and only the wanted unit is left.

## Examples

### #1: Converting Length

Convert $250$ centimeters to meters.

**Solution:**
Use $1\ \text{m} = 100\ \text{cm}$, arranged so centimeters cancel.

1. Put centimeters on the bottom of the factor, to cancel the given centimeters on top.

$$250\ \text{cm} \times \dfrac{1\ \text{m}}{100\ \text{cm}}$$

2. Cancel the centimeters and compute.

$$\dfrac{250}{100}\ \text{m} = 2.5\ \text{m}$$

### #2: Converting a Compound Unit

Convert a speed of $72$ kilometers per hour ($\text{km/h}$) into meters per second ($\text{m/s}$).

**Solution:**
Chain two conversion factors: kilometers to meters, and hours to seconds.

1. Convert kilometers to meters, using $1\ \text{km} = 1000\ \text{m}$.

$$72\ \dfrac{\text{km}}{\text{h}} \times \dfrac{1000\ \text{m}}{1\ \text{km}} = 72{,}000\ \dfrac{\text{m}}{\text{h}}$$

2. Convert hours to seconds, using $1\ \text{h} = 3600\ \text{s}$. The hour is on the bottom, so the factor has the hour on top.

$$72{,}000\ \dfrac{\text{m}}{\text{h}} \times \dfrac{1\ \text{h}}{3600\ \text{s}} = 20\ \dfrac{\text{m}}{\text{s}}$$

## Speed Tricks & Shortcuts

Write the units next to the numbers at every step of a calculation. If the units do not cancel to the expected result, a conversion factor is probably upside down.

For chained conversions, like $\text{km/h}$ to $\text{m/s}$, fix the top unit and the bottom unit one factor at a time. Combined, this conversion is a division by $3.6$, because $\dfrac{1000}{3600} = \dfrac{1}{3.6}$. The shortcut applies to this pair of units only. To go from $\text{m/s}$ to $\text{km/h}$, multiply by $3.6$.

## Traps to Watch For

### #1: Flipping the Conversion Factor

> Put the unwanted unit on the opposite side from where it sits in your starting value.

Multiplying $250\ \text{cm}$ by $\dfrac{100\ \text{cm}}{1\ \text{m}}$, the upside-down factor, leaves $\text{cm}^2/\text{m}$. That is a nonsense unit, and the number is $100^2 = 10{,}000$ times too big. Check that the units cancel before trusting the arithmetic.

### #2: Using Mixed Units in a Formula

> A formula that gives an SI result needs inputs in SI units.

A distance in kilometers and a time in seconds give a speed in $\text{km/s}$, not $\text{m/s}$. Mass in grams in $F = ma$ gives $\text{g} \cdot \text{m/s}^2$, which is not newtons. Convert first, or track the unit and convert at the end.

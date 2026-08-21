---
_id: "lesson-physics-units-and-measurements"
title: "Units, Measurements, and Conversions (Dimensional Analysis)"
summary: "The seven base SI units and how to convert between units using dimensional analysis."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 10
isActive: true
---
## Core Concept

Physics describes the world with numbers attached to units. A measurement without a unit is meaningless: saying a rope is "$5$ long" tells you nothing until you know if that means $5$ meters or $5$ centimeters.

### The Seven SI Base Units

Scientists worldwide use the **International System of Units (SI)**, built from seven base units, from which every other unit is derived:

- **Length**: meter ($m$)
- **Mass**: kilogram ($kg$)
- **Time**: second ($s$)
- **Electric current**: ampere ($A$)
- **Temperature**: kelvin ($K$)
- **Amount of substance**: mole ($mol$)
- **Luminous intensity**: candela ($cd$)

Every other unit in physics (like speed in $m/s$, or force in $kg \cdot m/s^2$, called a newton) is a combination of these seven base units.

| Base Quantity | SI Unit | Symbol |
| --- | --- | --- |
| Length | meter | $\text{m}$ |
| Mass | kilogram | $\text{kg}$ |
| Time | second | $\text{s}$ |
| Electric current | ampere | $\text{A}$ |
| Temperature | kelvin | $\text{K}$ |
| Amount of substance | mole | $\text{mol}$ |
| Luminous intensity | candela | $\text{cd}$ |

### Dimensional Analysis

**Dimensional analysis** is a method for converting between units by multiplying by **conversion factors**: fractions equal to $1$, built from equivalent measurements (like $\dfrac{1 \text{ m}}{100 \text{ cm}}$, since $1$ meter equals $100$ centimeters). Multiplying by a conversion factor never changes the actual quantity, only the units it is expressed in, because you are really just multiplying by $1$.

The trick is to arrange each conversion factor so the unwanted unit cancels out (appearing once on top and once on bottom), leaving only the units you want.

## Examples

### #1: Converting Length

Convert $250$ centimeters to meters.

**Solution:**
Use the relationship $1 \text{ m} = 100 \text{ cm}$, arranging it so centimeters cancel.

1. Set up the conversion factor with centimeters on the bottom (to cancel the given centimeters on top).

$$250 \text{ cm} \times \dfrac{1 \text{ m}}{100 \text{ cm}}$$

2. Cancel the "cm" units and compute.

$$\dfrac{250}{100} \text{ m} = 2.5 \text{ m}$$

### #2: Converting a Compound Unit

Convert a speed of $72$ kilometers per hour ($km/h$) into meters per second ($m/s$).

**Solution:**
Chain two conversion factors together: kilometers to meters, and hours to seconds.

1. Start with the given value.

$$72 \dfrac{\text{km}}{\text{h}}$$

2. Convert kilometers to meters (multiply by $1000$, since $1 \text{ km} = 1000 \text{ m}$).

$$72 \dfrac{\text{km}}{\text{h}} \times \dfrac{1000 \text{ m}}{1 \text{ km}} = 72000 \dfrac{\text{m}}{\text{h}}$$

3. Convert hours to seconds (multiply by $\dfrac{1 \text{ h}}{3600 \text{ s}}$, since $1 \text{ h} = 3600 \text{ s}$).

$$72000 \dfrac{\text{m}}{\text{h}} \times \dfrac{1 \text{ h}}{3600 \text{ s}}$$

4. Cancel "h" and compute.

$$\dfrac{72000}{3600} \dfrac{\text{m}}{\text{s}} = 20 \dfrac{\text{m}}{\text{s}}$$

### #3: Checking Units in a Formula

The formula for force is $F = ma$ (mass times acceleration). Using only SI base units, show that force works out to units of $kg \cdot m/s^2$.

**Solution:**
Substitute the base units for mass and acceleration directly.

1. Mass has units of $kg$.
2. Acceleration is a change in velocity ($m/s$) per unit time ($s$), so its units are $\dfrac{m/s}{s} = m/s^2$.
3. Multiply the two units together.

$$kg \times \dfrac{m}{s^2} = kg \cdot m/s^2$$

4. This combination of base units is given its own name: the newton ($N$).

## Speed Tricks & Shortcuts

Always write out units alongside numbers during a calculation, not just at the end. If the units do not cancel out to give the expected result, that is an immediate signal that a conversion factor was set up backwards.

Memorize a small set of common metric prefixes as powers of $10$: kilo- ($1000$, or $10^3$), centi- ($0.01$, or $10^{-2}$), milli- ($0.001$, or $10^{-3}$). Converting between these and the base unit is just a matter of moving the decimal point.

For chained conversions (like $km/h$ to $m/s$), handle the top unit and the bottom unit separately, one conversion factor at a time, rather than trying to do both changes in a single confusing step.

## Traps to Watch For

### #1: Flipping the Conversion Factor Upside Down

> Always arrange a conversion factor so the unwanted unit is on the opposite side from where it appears in your starting value, so it cancels out.

Multiplying $250 \text{ cm}$ by $\dfrac{100 \text{ cm}}{1 \text{ m}}$ (the upside-down version) leaves you with units of $\text{cm}^2/\text{m}$, a nonsense result, and a number that is wildly too large. Check that units actually cancel before trusting the arithmetic.

### #2: Mixing Units Within the Same Calculation

> Convert all quantities to the same unit system before combining them in a formula.

Plugging a distance in kilometers directly into a formula alongside a time in seconds (without converting one of them first) produces a meaningless result. Always check that every value going into a formula shares compatible units.

### #3: Forgetting That Squaring or Cubing a Unit Also Squares the Conversion Factor

> Converting an area or volume unit requires squaring or cubing the length conversion factor too, not just reusing the plain factor.

Converting $1 \text{ m}^2$ to $\text{cm}^2$ is not simply multiplying by $100$ (the length conversion factor); since area is length times length, the conversion factor must also be squared: $1 \text{ m}^2 = (100 \text{ cm})^2 = 10{,}000 \text{ cm}^2$.

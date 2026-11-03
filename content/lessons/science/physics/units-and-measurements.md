---
_id: "lesson-physics-units-and-measurements"
title: "Units, Measurements, and Conversions (Dimensional Analysis)"
summary: "SI base units and prefixes, unit conversion with conversion factors (including squared and cubed units), checking equations by units, significant figures, and measurement uncertainty."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 14
isActive: true
---
## Core Concept

Physics describes the world with numbers attached to units. A **quantity** is something you can measure, such as length, mass, or time. A **unit** is the standard amount you count it in. Saying a rope is "$5$ long" tells you nothing until you know if that means $5$ meters or $5$ centimeters.

### The Seven SI Base Units

Scientists worldwide use the **International System of Units (SI)**. It is built from seven **base units**, each for one base quantity:

- **Length**: meter ($\text{m}$)
- **Mass**: kilogram ($\text{kg}$)
- **Time**: second ($\text{s}$)
- **Electric current**: ampere ($\text{A}$)
- **Temperature**: kelvin ($\text{K}$)
- **Amount of substance**: mole ($\text{mol}$)
- **Luminous intensity** (how bright a light source looks): candela ($\text{cd}$)

Every other SI unit is a **derived unit**: a combination of base units. Speed is length per time, so its unit is $\text{m/s}$. Some derived units have their own names. Some other units, such as the hour and the liter, are not SI units but are still used with SI.

Two terms are needed before we build more units.

**Velocity** is how fast something moves, with a direction. **Acceleration** is how fast velocity changes, so it is a change in velocity per unit time. **Force** is a push or pull. Newton's second law says force equals mass times acceleration:

$$F = ma$$

The unit of force is the **newton** ($\text{N}$), defined as $1\ \text{N} = 1\ \text{kg} \cdot \text{m/s}^2$.

### Prefixes and Scientific Notation

A **prefix** goes in front of a unit and multiplies it by a power of $10$. A **power of $10$** such as $10^3$ means $10 \times 10 \times 10 = 1000$. A negative power such as $10^{-2}$ means $\dfrac{1}{10^2} = 0.01$. **Scientific notation** writes a number as $a \times 10^n$, where $a$ is at least $1$ and less than $10$, and $n$ is a whole number. For example, $4.5 \times 10^{-6}$ is in scientific notation, but $45 \times 10^{-7}$ is not, because $45$ is not less than $10$.

- giga ($\text{G}$): $10^9$
- mega ($\text{M}$): $10^6$
- kilo ($\text{k}$): $10^3$
- centi ($\text{c}$): $10^{-2}$
- milli ($\text{m}$): $10^{-3}$
- micro ($\mu$): $10^{-6}$
- nano ($\text{n}$): $10^{-9}$

Capital and small letters mean different things: $\text{Mm}$ is a megameter, but $\text{mm}$ is a millimeter. The kilogram is the one base unit that already carries a prefix. So prefixes for mass are attached to the gram: $1\ \text{mg} = 10^{-3}\ \text{g}$.

### Temperature Needs an Offset

The kelvin scale starts at absolute zero, the lowest possible temperature. The Celsius scale starts elsewhere. To change between them, add or subtract an offset:

$$T_{\text{K}} = T_{\text{C}} + 273.15$$

A temperature change is the same size on both scales: a rise of $5\ ^\circ\text{C}$ is a rise of $5\ \text{K}$.

### Dimensional Analysis: Converting Units

**Dimensional analysis** is a method for converting between units by multiplying by **conversion factors**. A conversion factor is a fraction equal to $1$, built from two equal amounts. For example, $1\ \text{m} = 100\ \text{cm}$ gives $\dfrac{1\ \text{m}}{100\ \text{cm}}$. Multiplying by it changes the units, not the actual size of the quantity.

Arrange each factor so the unwanted unit appears once on top and once on the bottom. It then cancels, and only the wanted unit is left.

The factor method works when one unit is a fixed multiple of the other. It does not work for temperature scales with different zero points, as the offset above shows.

### Squared and Cubed Units

Area and volume units are powers of a length unit. $1\ \text{m}^2$ means one meter times one meter. So the conversion factor must be raised to the same power:

$$1\ \text{m}^2 = (100\ \text{cm})^2 = 10{,}000\ \text{cm}^2$$

$$1\ \text{m}^3 = (100\ \text{cm})^3 = 1{,}000{,}000\ \text{cm}^3$$

<!-- ILLUSTRATION: a square 1 m by 1 m. Each side labeled "1 m = 100 cm". The square is divided into a grid of small squares 1 cm by 1 cm. A label says "1 m² = 100 × 100 = 10,000 cm²" -->

The liter ($\text{L}$) is defined as $1\ \text{L} = 1000\ \text{cm}^3$.

### Dimensions: Checking an Equation

The **dimension** of a quantity says what kind of quantity it is, not which unit it uses. Length has dimension $\text{L}$, mass $\text{M}$, and time $\text{T}$. Speed has dimension $\dfrac{\text{L}}{\text{T}}$.

Two rules let you check an equation:

- Both sides of an equation must have the same dimension.
- You can add or subtract only quantities with the same dimension.

Pure numbers have no dimension. Angles in radians, and numbers such as $\dfrac{1}{2}$ or $\pi$, are also dimensionless. The input of a function such as sine or a power of $10$ must be dimensionless too.

A dimension check can show that an equation is wrong. It cannot prove an equation is right. It does not see pure-number factors such as $\dfrac{1}{2}$, and it cannot tell apart two quantities that share a dimension, such as work and torque.

### Significant Figures

A measured number carries only as many digits as the instrument can give. **Significant figures** are the digits that carry meaning in a measured number. The counting rules:

- Every nonzero digit counts.
- A zero between two nonzero digits counts: $1005$ has $4$ significant figures and $2.05$ has $3$.
- A zero at the start of a number does not count: $0.0042$ has $2$ significant figures.
- A zero at the end counts if the number has a decimal point: $2.50$ has $3$, and $1200.$ has $4$. In $1200$ with no decimal point, the zeros are unclear. Scientific notation settles it: $1.2 \times 10^3$ has $2$ and $1.200 \times 10^3$ has $4$.

Exact numbers have unlimited significant figures. These are counted numbers (such as $12$ eggs) and defined values (such as $100\ \text{cm} = 1\ \text{m}$).

Two rounding rules for results:

- When you multiply or divide, keep as many significant figures as the measured number with the fewest.
- When you add or subtract, keep as many decimal places as the measured number with the fewest decimal places.

Round once, at the end of the whole calculation, not after every step. The examples below treat given values as exact unless the question says they are measured.

### Measurement Uncertainty

No measurement is perfectly exact. The **uncertainty** is the amount by which the true value might differ from your reading. It is written with a plus-or-minus sign: $15.3 \pm 0.1\ \text{cm}$ means the true length is likely between $15.2\ \text{cm}$ and $15.4\ \text{cm}$.

<!-- ILLUSTRATION: a pencil lying along a ruler marked in millimeters. The pencil tip is at 15.3 cm. A label reads "15.3 cm ± 0.1 cm" with the range 15.2 to 15.4 cm marked on the ruler -->

The uncertainty often comes from the instrument's smallest division. A common choice is half a division or one division. The question or lab method says which one to use.

The **percent uncertainty** compares the uncertainty with the reading:

$$\text{percent uncertainty} = \dfrac{\text{uncertainty}}{\text{measured value}} \times 100\%$$

**Accuracy** and **precision** are different. A measurement is **accurate** when it is close to the true value. A set of repeated measurements is **precise** when the readings are close to each other. A set can be precise but not accurate, if a scale is set wrong and gives the same wrong reading each time.

<!-- ILLUSTRATION: two targets. Left target: three dots tightly grouped far from the center, labeled "precise, not accurate". Right target: three dots spread around the center, labeled "accurate on average, not precise" -->

## Examples

### #1: Converting Length

Convert $250$ centimeters to meters.

**Solution:**
Use $1\ \text{m} = 100\ \text{cm}$, arranged so centimeters cancel.

1. Put centimeters on the bottom of the factor, to cancel the given centimeters on top.

$$250\ \text{cm} \times \dfrac{1\ \text{m}}{100\ \text{cm}}$$

2. Cancel the centimeters and compute.

$$\dfrac{250}{100}\ \text{m} = 2.5\ \text{m}$$

### #2: Converting with a Prefix

A sample has a mass of $4.5\ \text{mg}$. Express it in kilograms.

**Solution:**
Go through grams, because the prefixes work on the gram.

1. Change milligrams to grams, using $1\ \text{mg} = 10^{-3}\ \text{g}$.

$$4.5\ \text{mg} \times \dfrac{10^{-3}\ \text{g}}{1\ \text{mg}} = 4.5 \times 10^{-3}\ \text{g}$$

2. Change grams to kilograms, using $1\ \text{kg} = 10^{3}\ \text{g}$.

$$4.5 \times 10^{-3}\ \text{g} \times \dfrac{1\ \text{kg}}{10^{3}\ \text{g}} = 4.5 \times 10^{-6}\ \text{kg}$$

### #3: Converting a Compound Unit

Convert a speed of $72$ kilometers per hour ($\text{km/h}$) into meters per second ($\text{m/s}$).

**Solution:**
Chain two conversion factors: kilometers to meters, and hours to seconds.

1. Convert kilometers to meters, using $1\ \text{km} = 1000\ \text{m}$.

$$72\ \dfrac{\text{km}}{\text{h}} \times \dfrac{1000\ \text{m}}{1\ \text{km}} = 72{,}000\ \dfrac{\text{m}}{\text{h}}$$

2. Convert hours to seconds, using $1\ \text{h} = 3600\ \text{s}$. The hour is on the bottom, so the factor has the hour on top.

$$72{,}000\ \dfrac{\text{m}}{\text{h}} \times \dfrac{1\ \text{h}}{3600\ \text{s}} = 20\ \dfrac{\text{m}}{\text{s}}$$

### #4: Converting an Area

A floor has an area of $2.5\ \text{m}^2$. Express it in $\text{cm}^2$.

**Solution:**
The factor for length is $\dfrac{100\ \text{cm}}{1\ \text{m}}$. Area needs it squared.

1. Square the factor, number and unit both.

$$\left(\dfrac{100\ \text{cm}}{1\ \text{m}}\right)^2 = \dfrac{10{,}000\ \text{cm}^2}{1\ \text{m}^2}$$

2. Multiply and cancel the square meters.

$$2.5\ \text{m}^2 \times \dfrac{10{,}000\ \text{cm}^2}{1\ \text{m}^2} = 25{,}000\ \text{cm}^2$$

### #5: Converting a Density, with a Cubed Unit

The density of water is about $1000\ \text{kg/m}^3$. Express it in $\text{g/cm}^3$.

**Solution:**
The top unit needs kilograms to grams. The bottom unit needs cubic meters to cubic centimeters.

1. Convert the mass: $1\ \text{kg} = 1000\ \text{g}$.
2. Convert the volume: $1\ \text{m}^3 = 10^6\ \text{cm}^3$, from the cubed factor above.
3. Multiply by both factors, with each unwanted unit set to cancel.

$$1000\ \dfrac{\text{kg}}{\text{m}^3} \times \dfrac{1000\ \text{g}}{1\ \text{kg}} \times \dfrac{1\ \text{m}^3}{10^6\ \text{cm}^3} = \dfrac{10^6}{10^6}\ \dfrac{\text{g}}{\text{cm}^3} = 1\ \dfrac{\text{g}}{\text{cm}^3}$$

### #6: Finding a Derived Unit

Using only SI base units, show that the unit of force from $F = ma$ is $\text{kg} \cdot \text{m/s}^2$.

**Solution:**
Substitute the units of mass and acceleration.

1. Mass has the unit $\text{kg}$.
2. Acceleration is a change in velocity ($\text{m/s}$) per unit time ($\text{s}$). Its unit is $\dfrac{\text{m/s}}{\text{s}} = \text{m/s}^2$.
3. Multiply the two units.

$$\text{kg} \times \dfrac{\text{m}}{\text{s}^2} = \text{kg} \cdot \text{m/s}^2$$

4. This combination has its own name: the newton ($\text{N}$).

### #7: Checking Equations by Dimensions

A student writes two equations for the distance $s$ covered with starting speed $u$, constant acceleration $a$, and time $t$:

$$s = ut + \dfrac{1}{2}at^2 \qquad \text{and} \qquad s = ut + at$$

Use dimensions to test each one.

**Solution:**
Distance has dimension $\text{L}$. Each term in the sum must have dimension $\text{L}$ too.

1. The term $ut$ has $\dfrac{\text{L}}{\text{T}} \times \text{T} = \text{L}$.
2. In the first equation, $\dfrac{1}{2}at^2$ has $\dfrac{\text{L}}{\text{T}^2} \times \text{T}^2 = \text{L}$. Both terms match $s$, so it passes.
3. In the second equation, $at$ has $\dfrac{\text{L}}{\text{T}^2} \times \text{T} = \dfrac{\text{L}}{\text{T}}$. This cannot be added to a length, so the second equation is wrong.

The test also would pass $s = ut + at^2$ with the $\dfrac{1}{2}$ left out. Dimensions do not see that missing factor.

### #8: Significant Figures in a Calculation

A metal plate is measured to be $4.2\ \text{cm}$ long and $3.15\ \text{cm}$ wide. Find its area, using the significant figures of the measurements. Then add two measured masses, $12.11\ \text{g}$ and $0.3\ \text{g}$, and round the sum correctly.

**Solution:**
The area is a multiplication. The sum is an addition. Each has its own rule.

1. Multiply length by width.

$$4.2 \times 3.15 = 13.23\ \text{cm}^2$$

2. Here $4.2$ has $2$ significant figures and $3.15$ has $3$. Keep $2$ significant figures: the area is $13\ \text{cm}^2$.
3. Add the masses.

$$12.11 + 0.3 = 12.41\ \text{g}$$

4. Here $12.11$ has $2$ decimal places and $0.3$ has $1$. Keep $1$ decimal place: the sum is $12.4\ \text{g}$.

### #9: Percent Uncertainty

A ruler marked in millimeters gives a pencil length of $15.3\ \text{cm}$, with an uncertainty of $0.1\ \text{cm}$. Find the percent uncertainty.

**Solution:**
Divide the uncertainty by the measured value, then change to a percent.

1. Set up the ratio.

$$\dfrac{0.1}{15.3} \times 100\%$$

2. Compute and round to $2$ significant figures.

$$0.00654 \times 100\% \approx 0.65\%$$

The length can be written as $15.3\ \text{cm} \pm 0.65\%$.

### #10: Accuracy and Precision

A standard mass is exactly $100.0\ \text{g}$. Student A weighs it three times: $98.1\ \text{g}$, $98.0\ \text{g}$, $98.2\ \text{g}$. Student B gets $99.0\ \text{g}$, $101.2\ \text{g}$, $100.1\ \text{g}$. Describe each set.

**Solution:**
Check how close the readings are to each other, then how close their average is to $100.0\ \text{g}$.

1. Student A's readings differ by at most $0.2\ \text{g}$ from one another, so they are precise. Their average is $98.1\ \text{g}$, which is about $1.9\ \text{g}$ from the true value. So A is precise but not accurate.
2. Student B's readings spread over $2.2\ \text{g}$, so they are less precise. Their average is

$$\dfrac{99.0 + 101.2 + 100.1}{3} = 100.1\ \text{g}$$

3. This is within $0.1\ \text{g}$ of the true value. So B is accurate on average but less precise.

## Speed Tricks & Shortcuts

Write the units next to the numbers at every step of a calculation. If the units do not cancel to the expected result, a conversion factor is probably upside down.

A prefix conversion is a move of the decimal point. Going from a small unit to a bigger one (such as centimeters to meters) gives a smaller number. Going the other way gives a bigger number.

For squared and cubed units, square or cube the number as well. For example, $\text{m}^2$ to $\text{cm}^2$ multiplies by $100^2 = 10^4$.

For chained conversions, like $\text{km/h}$ to $\text{m/s}$, fix the top unit and the bottom unit one factor at a time. Combined, this conversion is a division by $3.6$, because $\dfrac{1000}{3600} = \dfrac{1}{3.6}$. The shortcut applies to this pair of units only. To go from $\text{m/s}$ to $\text{km/h}$, multiply by $3.6$.

Before using a formula, check that the units of each value fit it. In $F = ma$, mass in $\text{kg}$ and acceleration in $\text{m/s}^2$ give a force in newtons. Mass in grams does not.

## Traps to Watch For

### #1: Flipping the Conversion Factor

> Put the unwanted unit on the opposite side from where it sits in your starting value.

Multiplying $250\ \text{cm}$ by $\dfrac{100\ \text{cm}}{1\ \text{m}}$, the upside-down factor, leaves $\text{cm}^2/\text{m}$. That is a nonsense unit, and the number is $100^2 = 10{,}000$ times too big. Check that the units cancel before trusting the arithmetic.

### #2: Using Mixed Units in a Formula

> A formula that gives an SI result needs inputs in SI units.

A distance in kilometers and a time in seconds give a speed in $\text{km/s}$, not $\text{m/s}$. Mass in grams in $F = ma$ gives $\text{g} \cdot \text{m/s}^2$, which is not newtons. Convert first, or track the unit and convert at the end.

### #3: Using the Plain Factor for an Area or Volume

> For $\text{m}^2$ or $\text{m}^3$, raise the whole length factor to the same power.

Converting $1\ \text{m}^2$ to $\text{cm}^2$ is not multiplying by $100$. Area is length times length, so the factor is squared: $1\ \text{m}^2 = 10{,}000\ \text{cm}^2$. For volume, the factor is cubed.

### #4: Mixing Up the Significant-Figure Rules

> The rule depends on the operation: significant figures for multiplying and dividing, decimal places for adding and subtracting.

A sum like $12.11 + 0.3$ is rounded to one decimal place, giving $12.4$, even though $0.3$ has just one significant figure. Zeros also need care: leading zeros do not count, but the trailing zero in $2.50$ does. Defined values, like $100\ \text{cm}$ in a meter, are exact and do not limit the answer.

### #5: Confusing Accuracy with Precision

> Close to the true value means accurate. Close to each other means precise.

Tight readings can all be wrong by the same amount, such as from a scale that is not set to zero. Many digits on a display also do not make a measurement accurate.

### #6: Trusting a Dimension Check Too Much

> A passed dimension check shows the units are consistent, not that the equation is right.

An equation can have matching dimensions and still be wrong by a pure-number factor such as $\dfrac{1}{2}$, or use the wrong quantity. A failed check does show a mistake, as in the second equation of example $7$.

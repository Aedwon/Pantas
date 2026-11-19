---
_id: "lesson-trigonometry-converting-degrees-and-radians"
title: "Converting Degrees and Radians"
summary: "Explain what one radian measures."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 1
partCount: 3
ordering: 0
keyPoints:
  - "Explain what one radian measures."
  - "Convert degrees to radians."
  - "Convert radians to degrees."
---
## Core Concept

Degrees and radians are two languages for measuring the same angle.

You know degrees: a full circle is $360^\circ$, a straight line is $180^\circ$, a right angle is $90^\circ$.

A **radian** measures angles using the circle itself. One radian is the angle you get when the arc is exactly as long as the radius. Wrap the radius along the edge of the circle: the angle it covers is $1$ radian.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "circle-arc", "labels": ["Radius r", "Arc length = r", "Central Angle = 1 rad"], "semanticsLabel": "Circle showing radius r, an arc of length r along the edge, and central angle 1 radian."} -->

The bridge between the two languages:

$$180^\circ = \pi \text{ radians}$$

From this one fact come both conversion rules:

- Degrees to radians: multiply by $\dfrac{\pi}{180}$.
- Radians to degrees: multiply by $\dfrac{180}{\pi}$.

CETs test straight conversions, coterminal angles, and which quadrant an angle lands in. All three are quick points once the conversion is automatic.

## Examples

### #1: Degrees to Radians

Convert $60^\circ$ to radians.

**Solution:**
Multiply by $\dfrac{\pi}{180}$.

1. Set up the product.

$$60 \times \dfrac{\pi}{180}$$

2. Simplify the fraction $\dfrac{60}{180}$ to $\dfrac{1}{3}$.

$$60^\circ = \dfrac{\pi}{3}$$

3. So $60^\circ$ is $\dfrac{\pi}{3}$ radians.

### #2: Radians to Degrees

Convert $\dfrac{3\pi}{4}$ radians to degrees.

**Solution:**
Multiply by $\dfrac{180}{\pi}$. The $\pi$ symbols cancel.

1. Set up the product.

$$\dfrac{3\pi}{4} \times \dfrac{180}{\pi}$$

2. Cancel $\pi$ and divide $180$ by $4$.

$$3 \times 45 = 135$$

3. So $\dfrac{3\pi}{4}$ radians is $135^\circ$.

## Speed Tricks & Shortcuts

Memorize the anchor conversions and build everything from them: $30^\circ = \dfrac{\pi}{6}$, $45^\circ = \dfrac{\pi}{4}$, $60^\circ = \dfrac{\pi}{3}$, $90^\circ = \dfrac{\pi}{2}$, $180^\circ = \pi$, $360^\circ = 2\pi$. Then $135^\circ$ is just $3$ copies of $45^\circ$, so it is $\dfrac{3\pi}{4}$. Counting copies beats multiplying fractions.

## Traps to Watch For

### #1: Multiplying by the Wrong Fraction

> Degrees to radians uses $\dfrac{\pi}{180}$. Radians to degrees uses $\dfrac{180}{\pi}$.

Use the wrong one and the answer explodes or shrinks absurdly. Sanity check: a number without $\pi$ and bigger than $7$ is almost surely degrees; radian answers for common angles are small multiples of $\pi$.

### #2: A Radian Is Not a Degree Cousin

> $1$ radian is about $57.3^\circ$, much bigger than $1^\circ$.

When choices mix the two units, remember the scale: $2$ radians is already more than $114^\circ$. If you treat radians as "small degree-like numbers", every estimate you make will be wrong by a factor of about $57$.

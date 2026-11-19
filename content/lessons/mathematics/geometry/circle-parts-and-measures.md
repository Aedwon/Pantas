---
_id: "lesson-geometry-circle-parts-and-measures"
title: "Circle Parts and Measures"
summary: "Identify the parts of a circle. Use the radius to find circumference and area. Use a central angle to find arc length or sector area."
subject: "subject-mathematics"
topic: "topic-geometry"
isActive: true
part: 1
partCount: 5
ordering: 0
keyPoints:
  - "Identify the parts of a circle."
  - "Use the radius to find circumference and area."
  - "Use a central angle to find arc length or sector area."
---
## Core Concept

A **circle** is the set of all points at the same distance from a center point.

The parts, from the inside out:

- **Radius** ($r$): from the center to the edge.
- **Diameter** ($d$): all the way across through the center. Always $d = 2r$.
- **Chord**: a segment joining any two points on the circle. The diameter is the longest chord.
- **Secant**: a line that cuts through the circle at two points (a chord that keeps going).
- **Tangent**: a line that touches the circle at exactly one point. It is perpendicular to the radius at that point. **Perpendicular** means the two lines meet at $90^\circ$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "circle-elements", "labels": ["Radius", "Diameter", "Chord", "Secant", "Tangent", "Center O"], "semanticsLabel": "Circle showing center O, radius, diameter, chord, secant line crossing through, and tangent line perpendicular to the radius."} -->

- **Arc**: a piece of the circle's edge, measured in degrees. The whole circle is $360^\circ$.
- **Sector**: a pizza-slice region between two radii.

The basic size formulas:

$$C=2\pi r \qquad A=\pi r^2$$

**Circumference** $C$ is the distance around. **Area** $A$ is the space inside.

The number $\pi$ is the circumference divided by the diameter, for any circle. It is about $3.14$. Use that only when the question asks for a decimal.

Arcs and sectors are fractions of the circle. A central angle of $\theta$ degrees ($\theta$ is the angle) takes the fraction $\dfrac{\theta}{360}$ of everything. Arc length is a distance along the edge, not degrees.

$$\text{arc length}=\dfrac{\theta}{360}\cdot 2\pi r$$

$$\text{sector area}=\dfrac{\theta}{360}\cdot\pi r^2$$

## Examples

### #1: Circumference and Area

A circle has a radius of $7$ cm. Find its circumference and area in terms of $\pi$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "circle", "labels": ["r = 7 cm", "Center O"], "semanticsLabel": "Circle with center O and radius labeled r equals 7 cm."} -->

**Solution:**
"In terms of $\pi$" means leave $\pi$ as a symbol in the answer.

1. Circumference.

$$C=2\pi(7)=14\pi \text{ cm}$$

2. Area.

$$A=\pi(7)^2=49\pi \text{ cm}^2$$

### #2: Arc Length and Sector Area

A circle has radius $6$. A central angle measures $60^\circ$. Find the arc length and the sector area.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "circle-sector", "labels": ["r = 6", "60°", "Sector", "Arc length s"], "semanticsLabel": "Circle of radius 6 with a 60 degree central angle and shaded sector."} -->

**Solution:**

1. A $60^\circ$ slice is $\dfrac{60}{360} = \dfrac{1}{6}$ of the circle.
2. Arc length is one sixth of the circumference.

$$\dfrac{1}{6}\cdot 2\pi(6)=2\pi$$

3. Sector area is one sixth of the area.

$$\dfrac{1}{6}\cdot\pi(6)^2=6\pi$$

## Speed Tricks & Shortcuts

For a central angle, simplify $\dfrac{\text{angle}}{360}$ first: $90^\circ$ is $\dfrac{1}{4}$, $60^\circ$ is $\dfrac{1}{6}$, $45^\circ$ is $\dfrac{1}{8}$, $120^\circ$ is $\dfrac{1}{3}$.

## Traps to Watch For

### #1: Diameter in the Radius Formula

> The formulas use the radius. Halve the diameter first.

If the diameter is $10$, the area is $\pi(5)^2 = 25\pi$, not $\pi(10)^2 = 100\pi$.

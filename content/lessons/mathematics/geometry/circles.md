---
_id: "lesson-geometry-circles"
title: "Circles (Radii, Diameters, Chords, Tangents, Secants, Arcs, Sectors)"
summary: "The parts of a circle and how to compute arcs, angles, sectors, and tangent lengths."
subject: "subject-mathematics"
topic: "topic-geometry"
estimatedMinutes: 13
isActive: true
---
## Core Concept

A **circle** is the set of all points at the same distance from a center point.

The parts, from the inside out:

- **Radius** ($r$): from the center to the edge.
- **Diameter** ($d$): all the way across through the center. Always $d = 2r$.
- **Chord**: a segment joining any two points on the circle. The diameter is the longest chord.
- **Secant**: a line that cuts through the circle at two points (a chord that keeps going).
- **Tangent**: a line that touches the circle at exactly one point. A tangent is always perpendicular to the radius at the touching point.

<!-- ILLUSTRATION: circle with labeled radius, diameter, chord, secant line crossing through, and tangent line touching at one point with a square mark against the radius -->

- **Arc**: a piece of the circle's edge, measured in degrees. The whole circle is $360^\circ$.
- **Sector**: a pizza-slice region between two radii.

The two basic size formulas:

$$C = 2\pi r \qquad A = \pi r^2$$

Circumference $C$ is the distance around; area $A$ is the space inside.

The two angle rules that CETs test most:

- A **central angle** (vertex at the center) equals its intercepted arc.
- An **inscribed angle** (vertex on the circle) equals half its intercepted arc.

<!-- ILLUSTRATION: one circle showing a central angle of 80 degrees and an inscribed angle of 40 degrees intercepting the same arc -->

A famous special case: an angle inscribed in a semicircle is always $90^\circ$. If one side of an inscribed triangle is a diameter, that triangle is a right triangle.

Arcs and sectors are just fractions of the circle. An arc of $60^\circ$ is $\dfrac{60}{360} = \dfrac{1}{6}$ of everything: one sixth of the circumference, and its sector is one sixth of the area.

## Examples

### #1: Circumference and Area

A circle has a radius of $7$ cm. Find its circumference and area in terms of $\pi$.

**Solution:**
Plug $r = 7$ into both formulas.

1. Circumference.

$$C = 2\pi (7) = 14\pi \text{ cm}$$

2. Area.

$$A = \pi (7)^2 = 49\pi \text{ cm}^2$$

3. Leave answers "in terms of $\pi$" when the choices contain $\pi$. Do not multiply by $3.14$ unless asked.

### #2: Arc Length and Sector Area

A circle has radius $6$. A central angle measures $60^\circ$. Find the arc length and the area of the sector.

**Solution:**
A $60^\circ$ slice is $\dfrac{60}{360} = \dfrac{1}{6}$ of the circle.

1. Full circumference first.

$$C = 2\pi(6) = 12\pi$$

2. Take one sixth of it for the arc length.

$$\dfrac{12\pi}{6} = 2\pi$$

3. Full area next.

$$A = \pi(6)^2 = 36\pi$$

4. Take one sixth of it for the sector.

$$\dfrac{36\pi}{6} = 6\pi$$

5. Arc length: $2\pi$ units. Sector area: $6\pi$ square units.

### #3: Inscribed Angle

An inscribed angle intercepts an arc of $100^\circ$. Find the inscribed angle. Then: a central angle intercepting the same arc would measure how much?

**Solution:**
Inscribed means half; central means equal.

1. The inscribed angle is half its arc.

$$\dfrac{100}{2} = 50$$

2. The inscribed angle is $50^\circ$.
3. A central angle equals its arc, so it would be $100^\circ$, twice the inscribed angle.

### #4: Right Triangle in a Semicircle

Triangle $ABC$ is inscribed in a circle, and side $AB$ is a diameter of length $10$. If $AC = 6$, find $BC$.

**Solution:**
An angle inscribed in a semicircle is $90^\circ$, so angle $C$ is a right angle and $AB$ is the hypotenuse.

<!-- ILLUSTRATION: circle with horizontal diameter AB of length 10, point C on the upper arc, triangle ABC drawn with right angle marked at C, AC labeled 6 -->

1. Apply the Pythagorean theorem with hypotenuse $10$.

$$6^2 + BC^2 = 10^2$$

2. Compute the squares.

$$36 + BC^2 = 100$$

3. Subtract $36$.

$$BC^2 = 64$$

4. Take the square root.

$$BC = 8$$

5. $BC = 8$. Faster: recognize the $6$-$8$-$10$ triple, which is $3$-$4$-$5$ doubled.

### #5: Tangent Length

From a point $P$ outside a circle, the distance to the center is $13$ and the radius is $5$. How long is the tangent segment from $P$ to the circle?

**Solution:**
The radius to the tangent point is perpendicular to the tangent. That builds a right triangle: radius $5$, tangent $t$, and hypotenuse $13$ (center to $P$).

<!-- ILLUSTRATION: circle with center O, external point P, tangent segment from P touching the circle at T, radius OT drawn with a right angle mark at T, OP labeled 13 and OT labeled 5 -->

1. Apply the Pythagorean theorem. The center-to-point distance is the hypotenuse.

$$5^2 + t^2 = 13^2$$

2. Compute.

$$25 + t^2 = 169$$

3. Subtract $25$.

$$t^2 = 144$$

4. Take the square root.

$$t = 12$$

5. The tangent segment is $12$ units long. ($5$-$12$-$13$ strikes again.)

## Speed Tricks & Shortcuts

Treat every arc and sector problem as a fraction problem. Compute the fraction $\dfrac{\text{angle}}{360}$ first and simplify it. Common ones: $90^\circ$ is $\dfrac{1}{4}$, $60^\circ$ is $\dfrac{1}{6}$, $45^\circ$ is $\dfrac{1}{8}$, $120^\circ$ is $\dfrac{1}{3}$. Then multiply by circumference or area.

If a diameter appears in an inscribed triangle, the right angle is automatic and it is across from the diameter. Jump straight to the Pythagorean theorem, and check for triples before squaring.

Given the diameter, halve it immediately and write $r =$ on your scratch paper before touching any formula. This one habit prevents the most common circle error on the exam.

## Traps to Watch For

### #1: Diameter in the Radius Formula

> The formulas use the radius. Halve the diameter first.

If the diameter is $10$, the area is $\pi(5)^2 = 25\pi$, not $\pi(10)^2 = 100\pi$. Test-makers give the diameter on purpose, and $100\pi$ will absolutely be one of the choices.

### #2: Inscribed or Central?

> Central angle equals the arc. Inscribed angle is half the arc.

Check where the vertex sits before you compute. Vertex at the center: equal. Vertex on the circle: half. The doubled and halved answers are both in the choices every single time.

### #3: Arc Length vs. Sector Area

> Arc length is a piece of the circumference. Sector area is a piece of the area.

Both use the same fraction of $360$, so students grab the wrong base formula. Length questions ($2\pi r$) answer in plain units; area questions ($\pi r^2$) answer in square units. Let the units of the choices tip you off.

### #4: A Chord Is Not Always a Diameter

> A chord only equals the diameter when it passes through the center.

Given a chord of length $12$, do not conclude the radius is $6$. The diameter is the longest chord, so the radius is at least $6$, but any chord missing the center is shorter than the diameter. Problems that give a chord usually want the perpendicular-from-center right triangle, not a free radius.

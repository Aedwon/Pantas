---
_id: "lesson-geometry-circles"
title: "Circles (Radii, Diameters, Chords, Tangents, Secants, Arcs, Sectors)"
summary: "The parts of a circle and how to compute arcs, angles, sectors, chord lengths, and tangent and secant lengths."
subject: "subject-mathematics"
topic: "topic-geometry"
estimatedMinutes: 14
isActive: true
---
## Core Concept

A **circle** is the set of all points at the same distance from a center point.

The parts, from the inside out:

- **Radius** ($r$): from the center to the edge.
- **Diameter** ($d$): all the way across through the center. Always $d = 2r$.
- **Chord**: a segment joining any two points on the circle. The diameter is the longest chord.
- **Secant**: a line that cuts through the circle at two points (a chord that keeps going).
- **Tangent**: a line that touches the circle at exactly one point. It is perpendicular to the radius at that point. *Perpendicular* means the two lines meet at $90^\circ$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "circle-elements", "labels": ["Radius", "Diameter", "Chord", "Secant", "Tangent", "Center O"], "semanticsLabel": "Circle showing center O, radius, diameter, chord, secant line crossing through, and tangent line perpendicular to the radius."} -->

- **Arc**: a piece of the circle's edge, measured in degrees. The whole circle is $360^\circ$.
- **Sector**: a pizza-slice region between two radii.

The two basic size formulas:

$$C = 2\pi r \qquad A = \pi r^2$$

Circumference $C$ is the distance around. Area $A$ is the space inside.

### Angles and Fractions of a Circle

Two angle rules to know. The **intercepted arc** of an angle is the arc between its two sides.

- A **central angle** (vertex at the center) equals its intercepted arc.
- An **inscribed angle** (vertex on the circle) equals half its intercepted arc.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "circle-inscribed-central", "labels": ["Central: 80°", "Inscribed: 40°", "Arc = 80°"], "semanticsLabel": "Circle showing a central angle of 80 degrees and an inscribed angle of 40 degrees intercepting the same 80 degree arc."} -->

A special case: an angle inscribed in a semicircle is always $90^\circ$. If one side of an inscribed triangle is a diameter, that triangle is a right triangle.

Arcs and sectors are fractions of the circle. A central angle of $\theta$ degrees takes the fraction $\dfrac{\theta}{360}$ of everything:

$$\text{arc length} = \dfrac{\theta}{360}\cdot 2\pi r \qquad \text{sector area} = \dfrac{\theta}{360}\cdot \pi r^2$$

### The Right Triangle Rule

In a right triangle, the **hypotenuse** is the side across from the right angle. It is the longest side. Call the other two sides (the legs) $a$ and $b$, and the hypotenuse $c$. This is the Pythagorean theorem:

$$a^2 + b^2 = c^2$$

Right triangles appear in a semicircle, at a tangent, and at a chord.

### Chords, Tangents, and Secants

Distance from the center to a chord means the perpendicular distance.

- A line from the center perpendicular to a chord cuts the chord in half.
- Equal chords cut equal arcs and are the same distance from the center.
- Two tangents drawn from one outside point have equal lengths.
- Chords $AB$ and $CD$ crossing inside the circle at $P$ follow $PA \cdot PB = PC \cdot PD$.
- From an outside point $P$, a secant meets the circle at $A$ (nearer) and $B$ (farther). The outside part is $PA$. The whole secant is $PB$, not $AB$. A second secant, meeting at $C$ and $D$, gives $PA \cdot PB = PC \cdot PD$. A tangent touching at $T$ gives $PT^2 = PA \cdot PB$.

## Examples

### #1: Circumference and Area

A circle has a radius of $7$ cm. Find its circumference and area in terms of $\pi$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "circle", "labels": ["r = 7 cm", "Center O"], "semanticsLabel": "Circle with center O and radius labeled r equals 7 cm."} -->

**Solution:**
"In terms of $\pi$" means leave $\pi$ as a symbol in the answer.

1. Circumference.

$$C = 2\pi (7) = 14\pi \text{ cm}$$

2. Area.

$$A = \pi (7)^2 = 49\pi \text{ cm}^2$$


### #2: Arc Length and Sector Area

A circle has radius $6$. A central angle measures $60^\circ$. Find the arc length and the sector area.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "circle-sector", "labels": ["r = 6", "60°", "Sector", "Arc length s"], "semanticsLabel": "Circle of radius 6 with a 60 degree central angle and shaded sector."} -->

**Solution:**
A $60^\circ$ slice is $\dfrac{60}{360} = \dfrac{1}{6}$ of the circle.

1. Arc length: one sixth of the circumference.

$$\dfrac{1}{6}\cdot 2\pi(6) = 2\pi$$

2. Sector area: one sixth of the area.

$$\dfrac{1}{6}\cdot \pi(6)^2 = 6\pi$$

3. Arc length: $2\pi$ units. Sector area: $6\pi$ square units.

### #3: Inscribed Angle

An inscribed angle intercepts an arc of $100^\circ$. Find the inscribed angle and the central angle that intercept it.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "circle-inscribed-central", "labels": ["Central: 100°", "Inscribed: 50°", "Arc = 100°"], "semanticsLabel": "Circle with central angle 100 degrees and inscribed angle 50 degrees intercepting the same 100 degree arc."} -->

**Solution:**

1. The inscribed angle is half its arc.

$$\dfrac{100}{2} = 50$$

2. The inscribed angle is $50^\circ$.
3. A central angle equals its arc, so it is $100^\circ$.

### #4: Right Triangle in a Semicircle

Triangle $ABC$ is inscribed in a circle, and side $AB$ is a diameter of length $10$. If $AC = 6$, find $BC$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "circle-inscribed-triangle", "labels": ["A", "B", "C", "Diameter AB = 10", "AC = 6", "BC = ?", "90° at C"], "semanticsLabel": "Circle with inscribed right triangle ABC where diameter AB is 10, side AC is 6, and side BC is marked with a question mark."} -->

**Solution:**
An angle inscribed in a semicircle is $90^\circ$, so angle $C$ is a right angle and $AB$ is the hypotenuse.

1. Use the Pythagorean theorem with hypotenuse $10$.

$$6^2 + BC^2 = 10^2$$

2. Subtract $36$ and take the square root.

$$BC^2 = 100 - 36 = 64 \quad\Rightarrow\quad BC = 8$$

A **triple** is a set of three whole numbers that fit the theorem. Here, $6$, $8$, $10$ is the $3$, $4$, $5$ triple doubled.

### #5: Tangent Length

From a point $P$ outside a circle, the distance to the center is $13$ and the radius is $5$. How long is the tangent segment from $P$ to the circle?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "circle-tangent", "labels": ["Center O", "Point P", "Point T", "OT = 5", "OP = 13", "PT = ?", "90° at T"], "semanticsLabel": "Circle with center O, external point P at distance 13, radius OT equal to 5, and tangent PT labeled with a question mark meeting radius at a right angle."} -->

**Solution:**
The radius to the touching point $T$ is perpendicular to the tangent. This makes a right triangle with legs $5$ and $t$ and hypotenuse $13$ (center to $P$).

1. Use the Pythagorean theorem.

$$5^2 + t^2 = 13^2$$

2. Subtract $25$ and take the square root.

$$t^2 = 169 - 25 = 144 \quad\Rightarrow\quad t = 12$$

The tangent segment is $12$ units long. This is the $5$, $12$, $13$ triple.

### #6: Distance from the Center to a Chord

A circle has radius $13$. A chord is $24$ long. How far is the chord from the center?

<!-- ILLUSTRATION: circle with center O, radius 13, a chord of length 24 cut in half at 12 by a perpendicular from O of length d -->

**Solution:**

1. The perpendicular from the center cuts the chord in half. Each half is $12$.
2. The radius, half the chord, and $d$ form a right triangle with hypotenuse $13$.

$$d^2 + 12^2 = 13^2 \quad\Rightarrow\quad d^2 = 169 - 144 = 25$$

3. So $d = 5$.

### #7: Two Chords Crossing

Chords $AB$ and $CD$ cross at $P$ inside a circle. $AP = 4$, $PB = 9$, and $CP = 3$. Find $PD$.

<!-- ILLUSTRATION: chords AB and CD crossing at P; AP = 4, PB = 9, CP = 3, PD = ? -->

**Solution:**

1. Use the crossing-chords rule and substitute.

$$AP \cdot PB = CP \cdot PD \quad\Rightarrow\quad 4 \cdot 9 = 3 \cdot PD$$

2. Divide $36$ by $3$. $PD = 12$.

### #8: Tangent and Secant

From an outside point $P$, a tangent touches the circle at $T$. A secant from $P$ meets the circle at $A$ (nearer) and $B$ (farther). $PA = 4$ and $AB = 5$. Find $PT$.

<!-- ILLUSTRATION: outside point P, tangent PT, secant meeting the circle at A then B; PA = 4, AB = 5, PT = ? -->

**Solution:**

1. The whole secant is $PB = 4 + 5 = 9$.
2. Use the tangent-secant rule.

$$PT^2 = PA \cdot PB = 4 \cdot 9 = 36$$

3. Take the square root. $PT = 6$.

## Speed Tricks & Shortcuts

Treat every arc and sector problem as a fraction problem. Simplify $\dfrac{\text{angle}}{360}$ first. Common ones: $90^\circ$ is $\dfrac{1}{4}$, $60^\circ$ is $\dfrac{1}{6}$, $45^\circ$ is $\dfrac{1}{8}$, $120^\circ$ is $\dfrac{1}{3}$.

If a diameter is a side of an inscribed triangle, use the Pythagorean theorem and look for a triple, such as $3$, $4$, $5$ or $5$, $12$, $13$.

## Traps to Watch For

### #1: Diameter in the Radius Formula

> The formulas use the radius. Halve the diameter first.

If the diameter is $10$, the area is $\pi(5)^2 = 25\pi$, not $\pi(10)^2 = 100\pi$.

### #2: Inscribed or Central?

> Central angle equals the arc. Inscribed angle is half the arc.

Check the vertex first. At the center: equal to the arc. On the circle: half.

### #3: Arc Length vs. Sector Area

> Arc length is a piece of the circumference. Sector area is a piece of the area.

Both use the same fraction of $360$. Length uses $2\pi r$ and gives plain units. Area uses $\pi r^2$ and gives square units.

### #4: A Chord Is Not Always a Diameter

> A chord only equals the diameter when it passes through the center.

A chord of length $12$ does not mean the radius is $6$. A chord that misses the center is shorter than the diameter. Build a right triangle with the perpendicular from the center, as in example 6.

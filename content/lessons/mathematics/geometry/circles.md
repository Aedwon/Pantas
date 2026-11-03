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
- **Tangent**: a line that touches the circle at exactly one point. It is perpendicular to the radius at that point. **Perpendicular** means the two lines meet at $90^\circ$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "circle-elements", "labels": ["Radius", "Diameter", "Chord", "Secant", "Tangent", "Center O"], "semanticsLabel": "Circle showing center O, radius, diameter, chord, secant line crossing through, and tangent line perpendicular to the radius."} -->

- **Arc**: a piece of the circle's edge, measured in degrees. The whole circle is $360^\circ$.
- **Sector**: a pizza-slice region between two radii.

The basic size formulas:

$$C=2\pi r \qquad A=\pi r^2$$

**Circumference** $C$ is the distance around. **Area** $A$ is the space inside.

The number $\pi$ is the circumference divided by the diameter, for any circle. It is about $3.14$. Use that only when the question asks for a decimal.

### Angles and Fractions of a Circle

The **intercepted arc** of an angle lies between its two sides.

- A **central angle** (vertex at the center) equals its intercepted arc.
- An **inscribed angle** (vertex on the circle) equals half its intercepted arc.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "circle-inscribed-central", "labels": ["Central: 80°", "Inscribed: 40°", "Arc = 80°"], "semanticsLabel": "Circle showing a central angle of 80 degrees and an inscribed angle of 40 degrees intercepting the same 80 degree arc."} -->

A **semicircle** is half a circle, cut off by a diameter. Its arc is $180^\circ$, so an inscribed angle that intercepts it is $\dfrac{180}{2} = 90^\circ$.

An **inscribed triangle** has all three corners on the circle. If one side is a diameter, the angle across from it is $90^\circ$, so the triangle is a right triangle.

Arcs and sectors are fractions of the circle. A central angle of $\theta$ degrees ($\theta$ is the angle) takes the fraction $\dfrac{\theta}{360}$ of everything. Arc length is a distance along the edge, not degrees.

$$\text{arc length}=\dfrac{\theta}{360}\cdot 2\pi r$$

$$\text{sector area}=\dfrac{\theta}{360}\cdot\pi r^2$$

### The Right Triangle Rule

A right triangle has one $90^\circ$ angle. The **hypotenuse** $c$, across from it, is the longest side. The other two sides, the legs, are $a$ and $b$.

The **Pythagorean theorem** says:

$$a^2+b^2=c^2$$

### Chords, Tangents, and Secants

The distance from the center to a chord means the perpendicular distance.

- A line from the center perpendicular to a chord cuts the chord in half.
- In one circle, or in equal circles, equal chords cut equal arcs and are the same distance from the center.
- Two tangents from one outside point have equal lengths. Each, with its radius, makes a right triangle with the same hypotenuse, from that point to the center.
- Chords $AB$ and $CD$ cross at $P$ inside the circle. The products of the two parts of each chord are equal: $PA \cdot PB = PC \cdot PD$.
- From an outside point $P$, a secant meets the circle at $A$ (nearer) and $B$ (farther). The outside part is $PA$. The whole secant is $PB$, not $AB$.
- A second secant from $P$ meets it at $C$ (nearer) and $D$ (farther). Outside part times whole secant is equal for both: $PA \cdot PB = PC \cdot PD$.
- A tangent $PT$ acts like a secant whose two points meet at $T$, so $PT^2 = PA \cdot PB$.

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

### #3: Inscribed Angle

An inscribed angle intercepts an arc of $100^\circ$. Find the inscribed angle and the central angle that intercept it.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "circle-inscribed-central", "labels": ["Central: 100°", "Inscribed: 50°", "Arc = 100°"], "semanticsLabel": "Circle with central angle 100 degrees and inscribed angle 50 degrees intercepting the same 100 degree arc."} -->

**Solution:**

1. The inscribed angle is half its arc: $\dfrac{100}{2} = 50^\circ$.
2. A central angle equals its arc, so it is $100^\circ$.

### #4: Right Triangle in a Semicircle

Triangle $ABC$ is inscribed in a circle, and side $AB$ is a diameter of length $10$. If $AC = 6$, find $BC$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "circle-inscribed-triangle", "labels": ["A", "B", "C", "Diameter AB = 10", "AC = 6", "BC = ?", "90° at C"], "semanticsLabel": "Circle with inscribed right triangle ABC where diameter AB is 10, side AC is 6, and side BC is marked with a question mark."} -->

**Solution:**

1. An angle inscribed in a semicircle is $90^\circ$. So angle $C$ is right, and $AB$ is the hypotenuse.
2. Use the Pythagorean theorem.

$$6^2+BC^2=10^2$$

3. Subtract $36$ and take the square root.

$$BC^2=100-36=64 \quad\Rightarrow\quad BC=8$$

### #5: Tangent Length

From a point $P$ outside a circle, the distance to the center is $13$ and the radius is $5$. Tangents from $P$ touch the circle at $T$ and $S$. Find $PT$ and $PS$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "circle-tangent", "labels": ["Center O", "Point P", "Point T", "OT = 5", "OP = 13", "PT = ?", "90° at T"], "semanticsLabel": "Circle with center O, external point P at distance 13, radius OT equal to 5, and tangent PT labeled with a question mark meeting radius at a right angle."} -->

**Solution:**

1. Radius $OT$ is perpendicular to the tangent, so $OTP$ is a right triangle: legs $5$ and $t$ (the length $PT$), hypotenuse $13$.
2. Use the Pythagorean theorem.

$$5^2+t^2=13^2$$

3. Subtract $25$ and take the square root.

$$t^2=169-25=144 \quad\Rightarrow\quad t=12$$

4. Two tangents from $P$ are equal, so $PS = 12$ too.

### #6: Chord Distance and Equal Chords

A circle has radius $13$. Chords $AB$ and $EF$ are each $24$ long. How far is $AB$ from the center? What can you say about $EF$ and the arcs the chords cut off?

<!-- ILLUSTRATION: circle, radius 13; equal chords AB and EF, each 24; perpendicular h from O to AB -->

**Solution:**

1. The perpendicular from the center cuts the chord in half, so each half is $12$.
2. Call the distance $h$. The radius, half the chord, and $h$ form a right triangle with hypotenuse $13$.

$$h^2+12^2=13^2$$

3. Subtract $144$ and take the square root.

$$h^2=169-144=25 \quad\Rightarrow\quad h=5$$

4. $EF$ equals $AB$ in the same circle, so it is also $5$ from the center and cuts an equal arc.

### #7: Two Chords Crossing

Chords $AB$ and $CD$ cross at $P$ inside a circle. $AP = 4$, $PB = 9$, and $CP = 3$. Find $PD$.

<!-- ILLUSTRATION: chords AB and CD cross at P; AP = 4, PB = 9, CP = 3 -->

**Solution:**

1. Use the crossing-chords rule.

$$AP\cdot PB=CP\cdot PD \quad\Rightarrow\quad 4\cdot 9=3\cdot PD$$

2. Divide $36$ by $3$: $PD = 12$.

### #8: Two Secants

Two secants from an outside point $P$ meet the circle at $A$, $B$ and at $C$, $D$ (nearer point first). $PA = 3$, $AB = 5$, and $PC = 4$. Find $CD$.

<!-- ILLUSTRATION: P outside; secant P, A, B with PA = 3, AB = 5; secant P, C, D with PC = 4 -->

**Solution:**

1. The whole first secant is $PB = 3 + 5 = 8$.
2. Use the two-secant rule.

$$PA\cdot PB=PC\cdot PD \quad\Rightarrow\quad 3\cdot 8=4\cdot PD$$

3. Divide $24$ by $4$: $PD = 6$. So $CD = 6 - 4 = 2$.

### #9: Tangent and Secant

From $P$, a tangent touches the circle at $T$. A secant meets it at $A$ (nearer) and $B$. $PA = 4$ and $AB = 5$. Find $PT$.

<!-- ILLUSTRATION: P outside; tangent PT; secant P, A, B with PA = 4, AB = 5 -->

**Solution:**

1. The whole secant is $PB = 4 + 5 = 9$.
2. Use the tangent-secant rule.

$$PT^2=PA\cdot PB=4\cdot 9=36$$

3. Take the square root. $PT = 6$.

## Speed Tricks & Shortcuts

For a central angle, simplify $\dfrac{\text{angle}}{360}$ first: $90^\circ$ is $\dfrac{1}{4}$, $60^\circ$ is $\dfrac{1}{6}$, $45^\circ$ is $\dfrac{1}{8}$, $120^\circ$ is $\dfrac{1}{3}$.

If a diameter is a side of an inscribed triangle and you know one more side, use the Pythagorean theorem. A **triple** is three whole numbers that fit it, such as $3$, $4$, $5$ (or $6$, $8$, $10$) and $5$, $12$, $13$. A triple helps only when all three sides are whole numbers.

## Traps to Watch For

### #1: Diameter in the Radius Formula

> The formulas use the radius. Halve the diameter first.

If the diameter is $10$, the area is $\pi(5)^2 = 25\pi$, not $\pi(10)^2 = 100\pi$.

### #2: A Chord Is Not Always a Diameter

> A chord is a diameter only when it passes through the center.

A chord of length $12$ does not mean the radius is $6$. Use a perpendicular from the center, as in Example $6$.

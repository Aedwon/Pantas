---
_id: "lesson-geometry-chord-lengths-and-segments"
title: "Chord Lengths and Segments"
summary: "Use perpendicular distances and right triangles to find chord lengths and lengths in inscribed squares. Use the products of segment lengths when two chords cross inside a circle."
subject: "subject-mathematics"
topic: "topic-geometry"
isActive: true
part: 3
partCount: 5
ordering: 33
keyPoints:
  - "Use perpendicular distances and right triangles to find chord lengths and lengths in inscribed squares."
  - "Use the products of segment lengths when two chords cross inside a circle."
  - "Find the angle where two chords cross inside a circle."
---
## Core Concept

### The Right Triangle Rule

In an inscribed square, all four vertices lie on the circle and each diagonal is a diameter $d$. If its side is $s$, the right triangle formed by two sides gives $s^2+s^2=d^2$, so its area is $s^2=\dfrac{d^2}{2}$. For a diameter of $10$, the square area is $\dfrac{10^2}{2}=50$ square units.

A right triangle has one $90^\circ$ angle. The **hypotenuse** $c$, across from it, is the longest side. The other two sides, the legs, are $a$ and $b$.

The **Pythagorean theorem** says:

$$a^2+b^2=c^2$$

### Chords, Tangents, and Secants

The distance from the center to a chord means the perpendicular distance.

- A line from the center perpendicular to a chord cuts the chord in half.
- In one circle, or in equal circles, equal chords cut equal arcs and are the same distance from the center.

- Chords $AB$ and $CD$ cross at $P$ inside the circle. The products of the two parts of each chord are equal: $PA \cdot PB = PC \cdot PD$.

## Examples

### #1: Chord Distance and Equal Chords

A circle has radius $13$. Chords $AB$ and $EF$ are each $24$ long. How far is $AB$ from the center? What can you say about $EF$ and the arcs the chords cut off?

<!-- ILLUSTRATION: circle, radius 13; equal chords AB and EF, each 24; perpendicular h from O to AB -->

**Solution:**

1. The perpendicular from the center cuts the chord in half, so each half is $12$.
2. Call the distance $h$. The radius, half the chord, and $h$ form a right triangle with hypotenuse $13$.

$$h^2+12^2=13^2$$

3. Subtract $144$ and take the square root.

$$h^2=169-144=25 \quad\Rightarrow\quad h=5$$

4. $EF$ equals $AB$ in the same circle, so it is also $5$ from the center and cuts an equal arc.

### #2: Two Chords Crossing

When two chords cross inside a circle, an angle is half the sum of the arcs cut off by that angle and its vertical angle. If those arcs measure $80^\circ$ and $40^\circ$, the angle is $\dfrac{80+40}{2}=60^\circ$.

Chords $AB$ and $CD$ cross at $P$ inside a circle. $AP = 4$, $PB = 9$, and $CP = 3$. Find $PD$.

<!-- ILLUSTRATION: chords AB and CD cross at P; AP = 4, PB = 9, CP = 3 -->

**Solution:**

1. Use the crossing-chords rule.

$$AP\cdot PB=CP\cdot PD \quad\Rightarrow\quad 4\cdot 9=3\cdot PD$$

2. Divide $36$ by $3$: $PD = 12$.

## Traps to Watch For

### #1: A Chord Is Not Always a Diameter

> A chord is a diameter only when it passes through the center.

A chord of length $12$ does not mean the radius is $6$. Use a perpendicular from the center, as in the Chord Distance and Equal Chords example.

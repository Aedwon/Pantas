---
_id: "lesson-geometry-regular-polygon-angles-and-side-counts"
title: "Regular Polygon Angles and Side Counts"
summary: "Find interior and exterior angles in a regular polygon. Find the number of sides from a given angle."
subject: "subject-mathematics"
topic: "topic-geometry"
isActive: true
part: 2
partCount: 6
ordering: 26
keyPoints:
  - "Find interior and exterior angles in a regular polygon."
  - "Find the number of sides from a given angle."
---
## Core Concept

### Exterior Angle Sum

At a vertex of a convex polygon, extend one side past the vertex. The **exterior angle** is the angle between that extension and the next side. The interior and exterior angles at the same vertex form a **linear pair** (two angles side by side on a straight line), so they add to $180^\circ$.

If you take one exterior angle at each vertex, going around the polygon in one direction, they add to one full turn:

$$360^\circ$$

This is true for every convex polygon, whatever the number of sides. In a concave polygon, the exterior angle at a dent turns the other way and counts as negative, so the sum is still $360^\circ$. This lesson uses exterior angles of convex polygons.

For a regular polygon, divide the interior angle sum by $n$ to get each interior angle. Its exterior angles are also equal, so each exterior angle is $\dfrac{360^\circ}{n}$.

## Examples

### #1: Each Angle of a Regular Polygon

Find the measure of each interior angle of a regular octagon.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "polygon", "labels": ["Regular Octagon (n = 8)", "Each angle = ?"], "semanticsLabel": "Regular octagon with one interior angle highlighted with a question mark."} -->


**Solution:**
Find the total first, then share it equally among the $8$ corners.

1. Total interior sum for $n = 8$.

$$S = (8 - 2) \times 180 = 1080$$

2. Divide by the number of angles.

$$\dfrac{1080}{8} = 135$$

3. Each interior angle of a regular octagon is $135^\circ$.

### #2: Exterior Angles

Each exterior angle of a regular polygon measures $24^\circ$. How many sides does the polygon have?

<!-- ILLUSTRATION: one corner of a regular polygon with one side extended past the vertex, the exterior angle marked 24°, and the label "Sides n = ?"; only this corner is drawn, so the side count is not shown -->


**Solution:**
One exterior angle at each vertex adds to $360^\circ$, and in a regular polygon they are equal.

1. Divide the full turn by one exterior angle.

$$n = \dfrac{360}{24} = 15$$

2. The polygon has $15$ sides.
3. Each interior angle is $180 - 24 = 156^\circ$, since an interior angle and the adjacent exterior angle form a linear pair.

## Speed Tricks & Shortcuts

For each interior angle of a regular polygon, it is often faster to find the exterior angle first ($360 \div n$), then subtract from $180$. For a regular octagon: $360 \div 8 = 45$, and $180 - 45 = 135$.

For a regular polygon, if one exterior angle is given, divide $360$ by that angle to get the number of sides. If the result is not a whole number of at least $3$, no regular polygon has that exterior angle. For example, $50^\circ$ gives $7.2$, so it is not possible.

For a regular polygon with a given interior angle, subtract it from $180$ to get the exterior angle, then divide $360$ by that. For $140^\circ$: $180 - 140 = 40$, and $360 \div 40 = 9$ sides.

## Traps to Watch For

### #1: Exterior and Interior Sums Use Different Rules

> One exterior angle at each vertex of a convex polygon adds to $360^\circ$.

Do not use $(n - 2) \times 180$ for exterior angles. That formula is for the interior angle sum.

Do not count both exterior angles at a vertex, or the total doubles to $720^\circ$.

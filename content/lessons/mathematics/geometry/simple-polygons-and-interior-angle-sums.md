---
_id: "lesson-geometry-simple-polygons-and-interior-angle-sums"
title: "Simple Polygons and Interior Angle Sums"
summary: "Recognize simple, convex, and concave polygons. Use the interior angle sum to find a total or a side count."
subject: "subject-mathematics"
topic: "topic-geometry"
isActive: true
part: 1
partCount: 6
ordering: 25
keyPoints:
  - "Recognize simple, convex, and concave polygons."
  - "Use the interior angle sum to find a total or a side count."
---
## Core Concept

A **polygon** is a closed plane figure made of straight line segments. The segments are its sides. The corners are its vertices.

A polygon has at least $3$ sides.

A polygon is named by its side count: triangle ($3$), quadrilateral ($4$), pentagon ($5$), hexagon ($6$), heptagon ($7$), octagon ($8$), nonagon ($9$), decagon ($10$). A **regular** polygon has all sides equal and all interior angles equal. In this lesson, a regular polygon is also convex.

### Simple, Convex, and Concave

A polygon is **simple** if its sides touch only at the vertices and never cross. A **convex** polygon is a simple polygon in which every interior angle is less than $180^\circ$. A **concave** polygon is a simple polygon with at least one interior angle greater than $180^\circ$.

That angle makes a dent in the shape.

A bow-tie is neither simple nor convex, because two of its sides cross.

<!-- ILLUSTRATION: three four-sided figures side by side: a convex quadrilateral labeled "Convex: all angles less than 180°", an arrowhead quadrilateral with one reflex angle marked 225° labeled "Concave: one angle greater than 180°", and a bow-tie with two sides crossing labeled "Not simple: sides cross" -->

### Interior Angle Sum

An **interior angle** is an angle inside the polygon at a vertex. For a simple polygon with $n$ sides, convex or concave, the sum of the interior angles is:

$$S = (n - 2) \times 180^\circ$$

To see why, pick a vertex and draw diagonals from it. A **diagonal** is a segment that joins two vertices that are not next to each other. In a convex polygon, these diagonals divide the polygon into $n - 2$ triangles, and each triangle has angle sum $180^\circ$.

A concave polygon can also be cut into $n - 2$ triangles. One vertex may not be enough, though. An H-shaped polygon has no single vertex that reaches all the others inside the shape, so it needs diagonals from more than one vertex.

The sum is still $(n - 2) \times 180^\circ$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "polygon-triangulation", "labels": ["Hexagon (n = 6)", "4 Triangles", "(6 - 2) × 180° = 720°"], "semanticsLabel": "Hexagon with diagonals drawn from one vertex dividing it into 4 triangles."} -->

This formula does not work for a polygon whose sides cross. A bow-tie has $4$ vertices, but its four angles add to less than $360^\circ$.

## Examples

### #1: Interior Angle Sum

Find the sum of the interior angles of a hexagon.

<!-- ILLUSTRATION: a plain hexagon with no diagonals, labeled "Hexagon", with the label "Sum of interior angles = ?" beside it -->


**Solution:**
A hexagon has $n = 6$ sides.

1. Use the formula.

$$S = (6 - 2) \times 180$$

2. Compute.

$$S = 4 \times 180 = 720$$

3. The interior angles of any simple hexagon add up to $720^\circ$.

### #2: Working Backwards to Find $n$

The interior angles of a simple polygon add up to $1440^\circ$. How many sides does it have?

<!-- ILLUSTRATION: a simple closed polygon outline drawn without marked vertices, so its side count cannot be counted, with the labels "Sum of interior angles = 1440°" and "Sides n = ?" -->


**Solution:**
Use the formula in reverse.

1. Set up the equation.

$$(n - 2) \times 180 = 1440$$

2. Divide both sides by $180$.

$$n - 2 = 8$$

3. Add $2$.

$$n = 10$$

4. The polygon has $10$ sides. It is a decagon.

## Speed Tricks & Shortcuts

Memorize the small interior sums: triangle $180^\circ$, quadrilateral $360^\circ$, pentagon $540^\circ$, hexagon $720^\circ$. Each extra side adds exactly $180^\circ$ to the interior angle sum of a simple polygon.

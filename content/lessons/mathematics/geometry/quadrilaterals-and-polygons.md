---
_id: "lesson-geometry-quadrilaterals-and-polygons"
title: "Quadrilaterals and Polygons (Properties, Interior and Exterior Angle Sums)"
summary: "Simple and convex polygons, their angle sums, and the special quadrilaterals with their sides, angles, and diagonals."
subject: "subject-mathematics"
topic: "topic-geometry"
estimatedMinutes: 14
isActive: true
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

### Exterior Angle Sum

At a vertex of a convex polygon, extend one side past the vertex. The **exterior angle** is the angle between that extension and the next side. The interior and exterior angles at the same vertex form a **linear pair** (two angles side by side on a straight line), so they add to $180^\circ$.

If you take one exterior angle at each vertex, going around the polygon in one direction, they add to one full turn:

$$360^\circ$$

This is true for every convex polygon, whatever the number of sides. In a concave polygon, the exterior angle at a dent turns the other way and counts as negative, so the sum is still $360^\circ$. This lesson uses exterior angles of convex polygons.

For a regular polygon, divide the interior angle sum by $n$ to get each interior angle. Its exterior angles are also equal, so each exterior angle is $\dfrac{360^\circ}{n}$.

### Quadrilaterals

A quadrilateral has $n = 4$, so its interior angles add to $360^\circ$. This holds for every simple quadrilateral, convex or concave.

Some words you need. Two angles are **supplementary** if they add to $180^\circ$. **Consecutive** angles or sides are next to each other.

**Opposite** angles or sides are not next to each other. To **bisect** is to cut into two equal parts, and the point that cuts a segment this way is its **midpoint**.

Lines are **parallel** if they never meet. Lines are **perpendicular** if they meet at a right angle.

The special quadrilaterals form a family:

- **Parallelogram**: both pairs of opposite sides parallel. Opposite sides are equal, opposite angles are equal, consecutive angles are supplementary, and the diagonals bisect each other.
- **Rectangle**: a parallelogram with four right angles. Its diagonals are equal in length.
- **Rhombus**: a parallelogram with four equal sides. Its diagonals are perpendicular, and each diagonal bisects the two angles at the corners it joins.
- **Square**: a quadrilateral with four equal sides and four right angles. It is both a rectangle and a rhombus, so it has the properties of both.
- **Trapezoid**: this lesson uses the **exclusive convention**: a quadrilateral with exactly one pair of parallel sides. The parallel sides are the bases, and the other two sides are the legs. Some textbooks use an inclusive definition (at least one pair), so follow the convention stated in a problem when one is provided.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "quadrilateral-tree", "labels": ["Quadrilateral", "Trapezoid", "Parallelogram", "Rectangle", "Rhombus", "Square"], "semanticsLabel": "Hierarchy diagram showing parallelogram branching into rectangle and rhombus, merging into square, with trapezoid separate under the exclusive trapezoid convention."} -->

In a trapezoid, the two angles at the ends of one leg are supplementary. This is because the bases are parallel and the leg crosses both of them.

### Diagonals and Classification

The diagonals give a quick test for the type of a quadrilateral:

- If the diagonals bisect each other, the quadrilateral is a parallelogram.
- A parallelogram whose diagonals are also equal is a rectangle.
- A parallelogram whose diagonals are also perpendicular is a rhombus.
- A parallelogram whose diagonals are both equal and perpendicular is a square.

The diagonals of a rhombus cut it into right triangles. In a right triangle, the **hypotenuse** is the side opposite the right angle, and it is the longest side. Its square equals the sum of the squares of the other two sides.

Check all the given properties before you name the shape. Choose the most specific name that every given property supports.

Typical problems ask you to use the polygon angle formulas forward or backward, to find lengths or angles from the diagonals, or to name a quadrilateral from its properties.

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

### #2: Each Angle of a Regular Polygon

Find the measure of each interior angle of a regular octagon.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "polygon", "labels": ["Regular Octagon (n = 8)", "Each angle = ?"], "semanticsLabel": "Regular octagon with one interior angle highlighted with a question mark."} -->


**Solution:**
Find the total first, then share it equally among the $8$ corners.

1. Total interior sum for $n = 8$.

$$S = (8 - 2) \times 180 = 1080$$

2. Divide by the number of angles.

$$\dfrac{1080}{8} = 135$$

3. Each interior angle of a regular octagon is $135^\circ$.

### #3: Working Backwards to Find $n$

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

### #4: Exterior Angles

Each exterior angle of a regular polygon measures $24^\circ$. How many sides does the polygon have?

<!-- ILLUSTRATION: one corner of a regular polygon with one side extended past the vertex, the exterior angle marked 24°, and the label "Sides n = ?"; only this corner is drawn, so the side count is not shown -->


**Solution:**
One exterior angle at each vertex adds to $360^\circ$, and in a regular polygon they are equal.

1. Divide the full turn by one exterior angle.

$$n = \dfrac{360}{24} = 15$$

2. The polygon has $15$ sides.
3. Each interior angle is $180 - 24 = 156^\circ$, since an interior angle and the adjacent exterior angle form a linear pair.

### #5: A Quadrilateral with Three Known Angles

Three interior angles of a quadrilateral measure $30^\circ$, $45^\circ$, and $60^\circ$. The quadrilateral is simple. Find the fourth angle. Is the quadrilateral convex?

**Solution:**
The sum $(4 - 2) \times 180$ holds for any simple quadrilateral, convex or not.

1. The interior sum is $360^\circ$.
2. Add the three known angles.

$$30 + 45 + 60 = 135$$

3. Subtract from the total.

$$360 - 135 = 225$$

4. The fourth angle is $225^\circ$. It is greater than $180^\circ$, so the quadrilateral is concave, not convex.

<!-- ILLUSTRATION: arrowhead quadrilateral ABCD with interior angles A = 30°, B = 45°, C = 60° and the angle at D marked 225° on the inside of the dent -->

### #6: Parallelogram Angles with Algebra

In parallelogram $ABCD$, opposite angles $A$ and $C$ measure $(3x + 10)^\circ$ and $(5x - 30)^\circ$. Find the measure of angle $B$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "parallelogram", "labels": ["A", "B", "C", "D", "Angle A: (3x + 10)°", "Angle C: (5x - 30)°", "Angle B: ?"], "semanticsLabel": "Parallelogram ABCD with opposite angles A labeled 3x plus 10 degrees and C labeled 5x minus 30 degrees, and angle B marked with a question mark."} -->


**Solution:**
Opposite angles of a parallelogram are equal. Consecutive angles are supplementary.

1. Set the opposite angles equal.

$$3x + 10 = 5x - 30$$

2. Add $30$ and subtract $3x$ on both sides.

$$40 = 2x$$

$$x = 20$$

3. So angle $A = 3(20) + 10 = 70^\circ$. Check: $5(20) - 30 = 70$. Correct.
4. Angle $B$ is consecutive to angle $A$, so they add to $180^\circ$.

$$180 - 70 = 110$$

5. Angle $B$ measures $110^\circ$.

### #7: Angles of a Trapezoid

In trapezoid $ABCD$, side $AB$ is parallel to side $DC$. Angle $A$ measures $(2x + 10)^\circ$ and angle $D$ measures $(3x + 20)^\circ$. Find angle $A$.

<!-- ILLUSTRATION: trapezoid ABCD with AB on top parallel to DC on the bottom, leg AD on the left, angle A labeled (2x + 10)° and angle D labeled (3x + 20)° -->

**Solution:**
Angles $A$ and $D$ are at the two ends of leg $AD$. So they are supplementary.

1. Set up the equation.

$$(2x + 10) + (3x + 20) = 180$$

2. Combine the like terms.

$$5x + 30 = 180$$

3. Subtract $30$ from both sides, then divide by $5$.

$$5x = 150$$

$$x = 30$$

4. Angle $A = 2(30) + 10 = 70^\circ$.
5. Check: angle $D = 3(30) + 20 = 110^\circ$, and $70 + 110 = 180$. Correct.

### #8: Quadrilateral Angles in a Ratio

The four angles of a quadrilateral are in the ratio $1 : 2 : 3 : 4$. Find the largest angle.

<!-- ILLUSTRATION: a quadrilateral with the label "Interior angles in the ratio 1 : 2 : 3 : 4" and the label "Largest angle = ?" -->


**Solution:**
Call the angles $x$, $2x$, $3x$, $4x$. A quadrilateral's interior angles add to $360^\circ$.

1. Write the sum.

$$x + 2x + 3x + 4x = 360$$

2. Combine.

$$10x = 360$$

$$x = 36$$

3. The angles are $36^\circ$, $72^\circ$, $108^\circ$, and $144^\circ$.
4. The largest angle is $4(36) = 144^\circ$. Check the sum: $36 + 72 + 108 + 144 = 360$. Correct.

### #9: Angle at the Diagonals of a Rectangle

The diagonals of rectangle $ABCD$ cross at $O$. Angle $AOB$ measures $70^\circ$. Find angle $OAB$.

<!-- ILLUSTRATION: rectangle ABCD with diagonals AC and BD crossing at O, angle AOB marked 70°, angle OAB marked with a question mark -->

**Solution:**
A rectangle is a parallelogram, so its diagonals bisect each other. Its diagonals are also equal.

1. Half of each diagonal is the same length, so $OA = OB$.
2. Triangle $AOB$ has two equal sides, so it is isosceles, and the angles opposite the equal sides, $OAB$ and $OBA$, are equal.
3. The three angles of the triangle add to $180^\circ$.

$$2 \times \text{angle } OAB = 180 - 70 = 110$$

4. Angle $OAB$ measures $55^\circ$.

### #10: Side of a Rhombus from Its Diagonals

The diagonals of a rhombus measure $16$ cm and $12$ cm. Find the length of one side and the perimeter.

<!-- ILLUSTRATION: rhombus ABCD with diagonals AC = 16 cm and BD = 12 cm crossing at O, side AB marked with a question mark -->

**Solution:**
The diagonals of a rhombus bisect each other at a right angle. Each side is the hypotenuse of a right triangle. In a right triangle, the square of the hypotenuse equals the sum of the squares of the other two sides.

1. The half-diagonals are $\dfrac{16}{2} = 8$ cm and $\dfrac{12}{2} = 6$ cm.
2. Find one side.

$$s^2 = 8^2 + 6^2 = 64 + 36 = 100$$

$$s = 10$$

3. The side is $10$ cm.
4. All four sides of a rhombus are equal, so the perimeter is $4 \times 10 = 40$ cm.

### #11: Name the Quadrilateral from Its Diagonals

In quadrilateral $PQRS$, the diagonals $PR$ and $QS$ cross at $O$. Point $O$ is the midpoint of both diagonals. The diagonals are perpendicular. Diagonal $PR$ is not equal in length to diagonal $QS$. What is the most specific name for $PQRS$?

**Solution:**
Test each property against the family.

1. The diagonals bisect each other, so $PQRS$ is a parallelogram.
2. The diagonals are perpendicular, so the parallelogram is a rhombus.
3. The diagonals are not equal, so it is not a rectangle. Therefore it is not a square.
4. The most specific name is rhombus.

<!-- ILLUSTRATION: quadrilateral PQRS with diagonals PR and QS crossing at O at a right angle, equal tick marks on PO and OR, equal double tick marks on QO and OS, and PR drawn visibly longer than QS -->

## Speed Tricks & Shortcuts

For each interior angle of a regular polygon, it is often faster to find the exterior angle first ($360 \div n$), then subtract from $180$. For a regular octagon: $360 \div 8 = 45$, and $180 - 45 = 135$.

Memorize the small interior sums: triangle $180^\circ$, quadrilateral $360^\circ$, pentagon $540^\circ$, hexagon $720^\circ$. Each extra side adds exactly $180^\circ$ to the interior angle sum of a simple polygon.

For a regular polygon, if one exterior angle is given, divide $360$ by that angle to get the number of sides. If the result is not a whole number of at least $3$, no regular polygon has that exterior angle. For example, $50^\circ$ gives $7.2$, so it is not possible.

For a regular polygon with a given interior angle, subtract it from $180$ to get the exterior angle, then divide $360$ by that. For $140^\circ$: $180 - 140 = 40$, and $360 \div 40 = 9$ sides.

## Traps to Watch For

### #1: Exterior and Interior Sums Use Different Rules

> One exterior angle at each vertex of a convex polygon adds to $360^\circ$.

Do not use $(n - 2) \times 180$ for exterior angles. That formula is for the interior angle sum.

Do not count both exterior angles at a vertex, or the total doubles to $720^\circ$.

### #2: Consecutive Is Not Opposite

> In a parallelogram, opposite angles are equal; consecutive angles add to $180^\circ$.

Setting two consecutive angles equal, or making opposite angles supplementary, builds the wrong equation. The only exception is a rectangle or square, where all four angles are $90^\circ$. Check the positions first.

### #3: A Square Fits Both Names, but a Rhombus Need Not Be a Square

> Properties pass from the broader classes down to their special cases, not back up.

A square is both a rectangle and a rhombus. A rhombus is a square only if it also has a right angle. A rectangle is a square only if two consecutive sides are equal.

Under the exclusive convention, a parallelogram is not a trapezoid. Read the direction of a classification statement carefully.

### #4: Whose Diagonals Do What

> Rectangle diagonals are equal in length. Rhombus diagonals are perpendicular.

A rectangle that is not a square does not have perpendicular diagonals. A rhombus that is not a square does not have equal diagonals. A square has diagonals that are equal and perpendicular.

### #5: Equal or Perpendicular Diagonals Alone Are Not Enough

> Check that the diagonals bisect each other before you name a parallelogram type.

Equal diagonals alone do not make a rectangle. An isosceles trapezoid, which has two equal legs, also has equal diagonals.

Perpendicular diagonals alone do not make a rhombus. A kite, which has two pairs of equal consecutive sides, can have them too.

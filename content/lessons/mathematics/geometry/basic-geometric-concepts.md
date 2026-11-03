---
_id: "lesson-geometry-basic-geometric-concepts"
title: "Basic Geometric Concepts (Points, Lines, Planes, Angles)"
summary: "The building blocks of geometry: points, lines, planes, the kinds of angles, angle pairs, and bisectors, with equations for missing measures."
subject: "subject-mathematics"
topic: "topic-geometry"
estimatedMinutes: 12
isActive: true
---
## Core Concept

In school geometry, point, line, and plane are the **undefined terms**. They are basic ideas that we describe but do not define with simpler words.

A **point** is an exact location. It has no size at all. We name it with a capital letter, like point $A$.

A **line** goes on forever in both directions and has no endpoints. Through any two different points, exactly one line can be drawn. We write the line through $A$ and $B$ as $\overleftrightarrow{AB}$.

A **line segment** is the part of a line between two endpoints. Segment $AB$, written $\overline{AB}$, has a definite length, written $AB$. Its **midpoint** is the point on the segment that cuts it into two equal halves.

A **ray** has one endpoint and goes on forever in one direction. Ray $AB$, written $\overrightarrow{AB}$, starts at $A$ and passes through $B$. The order of the letters matters: $\overrightarrow{AB}$ and $\overrightarrow{BA}$ are different rays.

A **plane** is a flat surface that extends forever in all directions, like an endless tabletop. Points on the same line are **collinear**. Points on the same plane are **coplanar**.

Any two points are collinear, and any three points are coplanar. Three points are collinear when one line passes through all of them.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "basic-concepts", "labels": ["Point A", "Line AB", "Segment CD", "Ray EF", "Plane P"], "semanticsLabel": "Diagram of basic geometric elements showing point A, line AB with arrows at both ends, segment CD with endpoints, ray EF starting at E, and a flat plane drawn as a parallelogram."} -->

An **angle** is formed by two rays that share an endpoint. That endpoint is the **vertex**, and the two rays are the **sides**. We write an angle with three letters, with the vertex in the middle: $\angle ABC$ has vertex $B$. When only one angle sits at a vertex, we may write just $\angle B$.

We measure angles in degrees. A full turn is $360^\circ$. Angles are named by size:

- **Acute angle**: greater than $0^\circ$ and less than $90^\circ$.
- **Right angle**: exactly $90^\circ$. It forms a square corner.
- **Obtuse angle**: greater than $90^\circ$ and less than $180^\circ$.
- **Straight angle**: exactly $180^\circ$. Its two sides point in opposite directions and make a straight line.
- **Reflex angle**: greater than $180^\circ$ and less than $360^\circ$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "angle-gallery", "labels": ["Acute (<90°)", "Right (90°)", "Obtuse (>90°)", "Straight (180°)", "Reflex (>180°)"], "semanticsLabel": "Five angle types side by side showing acute, right with a square mark, obtuse, straight, and reflex angles."} -->

Angles also come in pairs with special sums.

**Complementary angles** are two angles whose measures add up to $90^\circ$. **Supplementary angles** are two angles whose measures add up to $180^\circ$. The two angles do not have to touch. Each angle in a complementary pair is acute, because the other angle takes up part of the $90^\circ$.

**Adjacent angles** share a vertex and one side, and they do not overlap. A **linear pair** is two adjacent angles whose other two sides are opposite rays. Because those outer sides form a straight line, the pair adds up to $180^\circ$.

Angles that sit side by side add up to the bigger angle they make together. So side-by-side angles that fill a straight line add up to $180^\circ$, and parts that fill a right angle add up to $90^\circ$.

**Vertical angles** are the angles that face each other when two lines cross, like the top and bottom angles of the letter X. Two crossing lines make two pairs of vertical angles. The angles in each pair are equal.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "vertical-angles", "labels": ["Vertical Pair 1", "Vertical Pair 2", "Linear Pair (180°)"], "semanticsLabel": "Two lines crossing in an X with opposite vertical angle pairs marked equal and an adjacent linear pair."} -->

An **angle bisector** is a ray from the vertex that cuts an angle into two equal angles. If ray $BD$ bisects $\angle ABC$, then $\angle ABD = \angle DBC$. Each of those is half of $\angle ABC$, and $\angle ABC$ is twice either one.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "angle-bisector", "labels": ["A", "B", "C", "D", "Ray BD bisects angle ABC", "Angle ABD = Angle DBC"], "semanticsLabel": "Angle ABC with vertex B and a ray BD inside it. Ray BD splits the angle into two equal angles, angle ABD and angle DBC, each marked with the same arc."} -->

Exam problems often combine these relationships with algebra. Write what the picture says as an equation, such as "equal" for vertical angles or bisected halves, "sum to $90$" for complements, and "sum to $180$" for supplements. Then solve for $x$.

## Mnemonics & Memory Aids

To keep complementary and supplementary apart, use the alphabet:

> C comes before S, and $90$ comes before $180$.

Or remember the shapes:

> Complementary makes a Corner. Supplementary makes a Straight line.

## Examples

### #1: Complementary Angles with Algebra

An angle measures $24^\circ$ more than its complement. Find the angle.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "complementary-angles", "labels": ["x", "90° - x", "Diff = 24°"], "semanticsLabel": "A right angle split by a ray into two complementary angles x and 90 minus x that differ by 24 degrees."} -->

**Solution:**
The complement of an angle is the angle you add to it to reach $90^\circ$.

1. Let the complement be $x$. Then the angle is $x + 24$.
2. Together they make $90^\circ$.

$$x + (x + 24) = 90$$

3. Combine like terms.

$$2x + 24 = 90$$

4. Subtract $24$, then divide by $2$.

$$2x = 66$$

$$x = 33$$

5. The complement is $33^\circ$, so the angle is $33 + 24 = 57^\circ$. Check: $33 + 57 = 90$. Correct.

### #2: Supplementary Angles in a Ratio

Two supplementary angles are in the ratio $2 : 3$. Find the two angles.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "supplementary-angles", "labels": ["2x", "3x", "Sum = 180°"], "semanticsLabel": "A straight line split by a ray into two supplementary angles labeled 2x and 3x summing to 180 degrees."} -->

**Solution:**
A ratio of $2 : 3$ means the angles are $2x$ and $3x$ for some number $x$.

1. Supplementary angles add to $180^\circ$.

$$2x + 3x = 180$$

2. Combine.

$$5x = 180$$

3. Divide by $5$.

$$x = 36$$

4. The angles are $2(36) = 72^\circ$ and $3(36) = 108^\circ$. Check: $72 + 108 = 180$. Correct.

### #3: Vertical Angles

Two lines intersect. One pair of vertical angles measures $(3x + 10)^\circ$ and $(5x - 20)^\circ$. Find the measure of these angles.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "vertical-angles", "labels": ["(3x + 10)°", "(5x - 20)°"], "semanticsLabel": "Two intersecting lines forming an X with opposite vertical angles labeled 3x plus 10 degrees and 5x minus 20 degrees."} -->

**Solution:**
Vertical angles are equal, so set the expressions equal.

1. Write the equation.

$$3x + 10 = 5x - 20$$

2. Subtract $3x$ from both sides and add $20$ to both sides.

$$30 = 2x$$

3. Divide by $2$.

$$x = 15$$

4. Substitute back: $3(15) + 10 = 55$. Each vertical angle is $55^\circ$.
5. Check the other expression: $5(15) - 20 = 75 - 20 = 55$. Correct.

### #4: Midpoint of a Segment

Point $M$ is the midpoint of $\overline{AB}$. If $AM = 2x + 3$ and $MB = 3x - 7$, find the length of $\overline{AB}$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "segment-midpoint", "labels": ["A", "M", "B", "2x + 3", "3x - 7"], "semanticsLabel": "Line segment AB with midpoint M dividing it into equal halves AM labeled 2x plus 3 and MB labeled 3x minus 7."} -->

**Solution:**
A midpoint makes the two halves equal.

1. Set the two halves equal.

$$2x + 3 = 3x - 7$$

2. Subtract $2x$ from both sides and add $7$ to both sides.

$$10 = x$$

3. Each half is $2(10) + 3 = 23$. Check: $3(10) - 7 = 23$.
4. The whole segment is both halves together.

$$AB = 23 + 23 = 46$$

5. The question asks for $AB$, so the answer is $46$, not $23$ and not $10$.

### #5: Three Angles on a Straight Line

Three angles sit side by side on a straight line. They measure $(2x)^\circ$, $(3x + 10)^\circ$, and $(x + 20)^\circ$. Find the measure of the largest angle.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "angles-on-line", "labels": ["(2x)°", "(3x + 10)°", "(x + 20)°", "180°"], "semanticsLabel": "A straight line with two rays creating three adjacent angles labeled 2x degrees, 3x plus 10 degrees, and x plus 20 degrees summing to 180 degrees."} -->

**Solution:**
Angles side by side along a straight line fill a straight angle, so they add up to $180^\circ$.

1. Write the sum.

$$2x + (3x + 10) + (x + 20) = 180$$

2. Combine like terms.

$$6x + 30 = 180$$

3. Subtract $30$, then divide by $6$.

$$6x = 150$$

$$x = 25$$

4. The angles are $2(25) = 50^\circ$, $3(25) + 10 = 85^\circ$, and $25 + 20 = 45^\circ$.
5. Check: $50 + 85 + 45 = 180$. Correct. The largest angle is $85^\circ$.

### #6: Angle Bisector

Ray $BD$ bisects $\angle ABC$. The measures are $\angle ABD = (2x + 5)^\circ$ and $\angle DBC = (4x - 15)^\circ$. Find $\angle ABC$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "angle-bisector-algebra", "labels": ["A", "B", "C", "D", "(2x + 5)°", "(4x - 15)°"], "semanticsLabel": "Angle ABC with vertex B and ray BD inside it. Angle ABD is labeled 2x plus 5 degrees and angle DBC is labeled 4x minus 15 degrees, and the two are marked equal."} -->

**Solution:**
A bisector makes the two smaller angles equal.

1. Set the two parts equal.

$$2x + 5 = 4x - 15$$

2. Subtract $2x$ from both sides and add $15$ to both sides.

$$20 = 2x$$

$$x = 10$$

3. Each part is $2(10) + 5 = 25^\circ$. Check: $4(10) - 15 = 25$.
4. The question asks for the whole angle, so add the two parts.

$$\angle ABC = 25 + 25 = 50^\circ$$

### #7: Finding a Part from the Whole Angle

Ray $BD$ bisects $\angle ABC$, and $\angle ABC = 84^\circ$. If $\angle ABD = (5x + 2)^\circ$, find $x$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "angle-bisector-whole", "labels": ["A", "B", "C", "D", "84°", "(5x + 2)°"], "semanticsLabel": "Angle ABC measuring 84 degrees with ray BD inside it bisecting the angle. Angle ABD is labeled 5x plus 2 degrees."} -->

**Solution:**
Each half of the angle is half of $84^\circ$.

1. Find one half.

$$\angle ABD = 84 \div 2 = 42$$

2. Set the expression equal to $42$.

$$5x + 2 = 42$$

3. Subtract $2$, then divide by $5$.

$$5x = 40$$

$$x = 8$$

4. Check: $5(8) + 2 = 42$, and $42 + 42 = 84$. Correct.

## Speed Tricks & Shortcuts

To find a complement fast, subtract from $90$: the complement of $37^\circ$ is $90 - 37 = 53^\circ$. To find a supplement, subtract from $180$: the supplement of $37^\circ$ is $180 - 37 = 143^\circ$. For an angle less than $90^\circ$, which has both, the supplement is the complement plus $90^\circ$.

When two lines cross, you need only one angle to find all four. Its vertical angle is equal, and each of its two neighbors is $180^\circ$ minus it. Given one angle of $55^\circ$, the four angles in order around the point are $55$, $125$, $55$, $125$.

For ratio problems like Example $2$, add the ratio parts first ($2 + 3 = 5$), divide the known total by that ($180 \div 5 = 36$), then multiply back. This works whenever the parts add to a known total.

For a bisector, the whole angle is twice either half, and each half is the whole divided by $2$. The same is true for a midpoint and a segment.

## Traps to Watch For

### #1: Complementary vs. Supplementary

> Complementary means $90^\circ$. Supplementary means $180^\circ$.

Swapping these is a common error. Before answering, ask yourself: corner or straight line? Also remember that an angle of $90^\circ$ or more has no complement, since its partner would have to be $0^\circ$ or negative.

### #2: Vertical Angles Are Equal, Linear Pairs Are Supplementary

> At a crossing, opposite angles are equal and neighbors add to $180^\circ$.

Set two expressions equal only when they label opposite (vertical) angles. Neighbors that share a side along a line add to $180^\circ$, so use a sum. If the two lines are perpendicular, all four angles are $90^\circ$. Check the positions in the figure before writing the equation.

### #3: Giving Half When Asked for the Whole

> A midpoint or bisector question may ask for the half or the whole. Read twice.

In Example $4$, solving gives $x = 10$ and a half-length of $23$. The question asks for the whole segment, so the answer is $46$. In Example $6$, the answer is the whole angle, $50^\circ$, not $25^\circ$ and not $x$.

### #4: A Line, a Segment, and a Ray Are Different

> $\overleftrightarrow{AB}$, $\overline{AB}$, and $\overrightarrow{AB}$ name three different objects.

A line has no endpoints, a segment has two, and a ray has one. A segment has a finite length, while a line and a ray do not. In notation questions, the symbol above the letters tells you which object is meant.

### #5: Bisecting Does Not Mean Perpendicular

> A bisector splits an angle into two equal parts. It does not have to make a right angle.

Example $6$ splits a $50^\circ$ angle into two $25^\circ$ angles. Equal halves does not mean $90^\circ$ halves. The parts are $90^\circ$ each only when the whole angle is a straight angle, $180^\circ$.

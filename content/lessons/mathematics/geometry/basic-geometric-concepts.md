---
_id: "lesson-geometry-basic-geometric-concepts"
title: "Basic Geometric Concepts (Points, Lines, Planes, Angles)"
summary: "The building blocks of geometry: points, lines, planes, and the different kinds of angles and angle pairs."
subject: "subject-mathematics"
topic: "topic-geometry"
estimatedMinutes: 12
isActive: true
---
## Core Concept

All of geometry is built from three undefined ideas: the point, the line, and the plane.

A **point** is an exact location. It has no size at all. We name it with a capital letter, like point $A$.

A **line** goes on forever in both directions. Through any two points, exactly one line can be drawn. We write line $AB$ as $\overleftrightarrow{AB}$.

A **line segment** is a piece of a line with two endpoints. Segment $AB$, written $\overline{AB}$, has a definite length. Its **midpoint** is the point that cuts it into two equal halves.

A **ray** starts at one endpoint and goes on forever in one direction, like a laser beam. Ray $AB$, written $\overrightarrow{AB}$, starts at $A$ and passes through $B$.

A **plane** is a flat surface that extends forever, like an endless tabletop. Points on the same line are **collinear**. Points on the same plane are **coplanar**.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "basic-concepts", "labels": ["Point A", "Line AB", "Segment CD", "Ray EF", "Plane P"], "semanticsLabel": "Diagram of basic geometric elements showing point A, line AB with arrows at both ends, segment CD with endpoints, ray EF starting at E, and a flat plane drawn as a parallelogram."} -->

An **angle** is formed by two rays that share an endpoint called the **vertex**. We measure angles in degrees.

- **Acute angle**: less than $90^\circ$.
- **Right angle**: exactly $90^\circ$. It forms a perfect corner.
- **Obtuse angle**: between $90^\circ$ and $180^\circ$.
- **Straight angle**: exactly $180^\circ$. It looks like a line.
- **Reflex angle**: bigger than $180^\circ$ but less than $360^\circ$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "angle-gallery", "labels": ["Acute (<90°)", "Right (90°)", "Obtuse (>90°)", "Straight (180°)", "Reflex (>180°)"], "semanticsLabel": "Five angle types side by side showing acute, right with a square mark, obtuse, straight, and reflex angles."} -->

Angles also come in important pairs.

**Complementary angles** add up to $90^\circ$. **Supplementary angles** add up to $180^\circ$.

**Adjacent angles** share a vertex and one side. A **linear pair** is two adjacent angles on a straight line; they are automatically supplementary.

**Vertical angles** are the opposite angles formed when two lines cross, like the top and bottom of the letter X. Vertical angles are always equal.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "vertical-angles", "labels": ["Vertical Pair 1", "Vertical Pair 2", "Linear Pair (180°)"], "semanticsLabel": "Two lines crossing in an X with opposite vertical angle pairs marked equal and an adjacent linear pair."} -->

An **angle bisector** is a ray that cuts an angle into two equal parts.

CETs rarely ask for these definitions directly. Instead they hide them inside algebra: "find $x$ if two vertical angles are $(3x + 10)^\circ$ and $(5x - 20)^\circ$." Know the relationships and the algebra is easy.

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
The "complement" of an angle is what you add to it to reach $90^\circ$.

1. Let the complement be $x$. Then the angle is $x + 24$.
2. Together they must make $90^\circ$.

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

<!-- FIGURE: {"kind": "geometry-diagram", "type": "segment-midpoint", "labels": ["A", "M", "B", "2x + 3", "3x - 7"], "semanticsLabel": "Segment AB with midpoint M showing left half 2x plus 3 equal to right half 3x minus 7."} -->

1. Set the two halves equal.

$$2x + 3 = 3x - 7$$

2. Subtract $2x$ from both sides and add $7$ to both sides.

$$10 = x$$

3. Each half is $2(10) + 3 = 23$.
4. The whole segment is both halves together.

$$AB = 23 + 23 = 46$$

5. The question asks for $AB$, so the answer is $46$, not $23$ and not $10$.

### #5: Three Angles on a Straight Line

Three angles sit side by side on a straight line. They measure $(2x)^\circ$, $(3x + 10)^\circ$, and $(x + 20)^\circ$. Find the measure of the largest angle.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "angles-on-line", "labels": ["(2x)°", "(3x + 10)°", "(x + 20)°", "180°"], "semanticsLabel": "A straight line with two rays creating three adjacent angles labeled 2x degrees, 3x plus 10 degrees, and x plus 20 degrees summing to 180 degrees."} -->


**Solution:**
Angles along a straight line add up to $180^\circ$.

1. Write the sum.

$$2x + (3x + 10) + (x + 20) = 180$$

2. Combine like terms.

$$6x + 30 = 180$$

3. Subtract $30$, then divide by $6$.

$$6x = 150$$

$$x = 25$$

4. The angles are $2(25) = 50^\circ$, $3(25) + 10 = 85^\circ$, and $25 + 20 = 45^\circ$.
5. Check: $50 + 85 + 45 = 180$. Correct. The largest angle is $85^\circ$.

## Speed Tricks & Shortcuts

To find a complement fast, subtract from $90$: the complement of $37^\circ$ is $90 - 37 = 53^\circ$. To find a supplement, subtract from $180$: the supplement of $37^\circ$ is $143^\circ$. Notice the supplement is always the complement plus $90$.

When two lines cross, you only ever need one angle. Its vertical angle is equal, and its two neighbors are $180^\circ$ minus it. Given one angle of $55^\circ$, the four angles are $55$, $125$, $55$, $125$ in order around the point.

For ratio problems like Example $2$, add the ratio parts first ($2 + 3 = 5$), divide the total by that ($180 \div 5 = 36$), then multiply back. This works for any "angles in a ratio" question, including triangles with $180^\circ$.

## Traps to Watch For

### #1: Complementary vs. Supplementary

> Complementary means $90^\circ$. Supplementary means $180^\circ$.

This swap is the most common trap in the whole topic. Test-makers write a complement question and put the supplement answer in the choices. Before shading, ask yourself: corner or straight line?

### #2: Vertical Angles Are Equal, Not Supplementary

> When two lines cross, the opposite angles are equal.

Students see two expressions at a crossing and automatically add them to $180$. That is only right for a linear pair, the two angles that are side by side. Angles across the X from each other are set equal. Look at the figure carefully before writing the equation.

### #3: Giving Half When Asked for the Whole

> A midpoint question may ask for the half or the whole. Read twice.

In Example $4$, solving gives $x = 10$ and a half-length of $23$. The choices will include $10$, $23$, and $46$. Only re-reading the question tells you which one to shade.

### #4: A Line Is Not a Segment

> $\overleftrightarrow{AB}$, $\overline{AB}$, and $\overrightarrow{AB}$ are three different things.

A line has no endpoints, a segment has two, and a ray has exactly one. Only a segment has a length you can measure. Exam questions about notation test exactly this, and the arrow style on top is the entire clue.

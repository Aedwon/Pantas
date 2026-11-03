---
_id: "lesson-geometry-parallel-perpendicular-lines"
title: "Parallel and Perpendicular Lines (Transversals, Angle Pairs)"
summary: "The angle pairs formed when a line crosses two parallel lines, how to solve for missing angles, and how equal angles prove lines are parallel."
subject: "subject-mathematics"
topic: "topic-geometry"
estimatedMinutes: 13
isActive: true
---
## Core Concept

**Parallel lines** lie in the same flat plane and never meet, however far you extend them. Think of train rails. We write $l \parallel m$.

**Perpendicular lines** cross at a right angle, which measures $90^\circ$. We write $l \perp m$. In a figure, a small square at the crossing shows a right angle, and matching arrow marks on two lines show that they are parallel.

A **transversal** is a line that cuts across two or more lines. When it cuts two lines, it makes eight angles, four at each crossing.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "transversal", "labels": ["1", "2", "3", "4", "5", "6", "7", "8"], "semanticsLabel": "Two parallel lines cut by a transversal with angles 1 through 4 at top intersection and 5 through 8 at bottom intersection."} -->

### Words for the angles

Two angles are **supplementary** if they add to $180^\circ$. An angle is **interior** if it lies between the two lines, and **exterior** if it lies outside them.

At one crossing, two angles that sit side by side on a straight line are a **linear pair**. They are supplementary. Two angles that face each other across the crossing are **vertical angles**. They are equal.

Linear pairs and vertical angles come from any two lines that cross. The lines do not need to be parallel.

A three-letter name such as angle $CAP$ names an angle by its corner. The middle letter is the corner. The angle opens toward the other two letters, $C$ and $P$.

### Pairs formed by parallel lines

If $l \parallel m$, these pairs are equal:

- **Corresponding angles** sit in the same corner position at each crossing, such as both "top left". They are equal.
- **Alternate interior angles** are interior and on opposite sides of the transversal. They are equal.
- **Alternate exterior angles** are exterior and on opposite sides of the transversal. They are equal.

One pair is supplementary. **Same-side interior angles** (also called co-interior angles) are interior and on the same side of the transversal. They add to $180^\circ$.

The letters help your eye. Alternate interior angles sit in the corners of a Z or a backward Z. Corresponding angles sit in an F, turned any way. Same-side interior angles sit inside a C or a U. Check the positions too, because a drawing can hide the letter.

### One angle gives all eight

Suppose the transversal is not perpendicular to the lines. Then the eight angles take two values: one angle $x$ and its supplement $180^\circ - x$. Around each crossing the values alternate.

If the transversal is perpendicular to one of the parallel lines, it is perpendicular to the other too. All eight angles are $90^\circ$, so equal and supplementary give the same answer.

### The reverse rule

The rules also work backward. If a transversal makes any one of these, the two lines are parallel:

- equal corresponding angles
- equal alternate interior angles
- equal alternate exterior angles
- same-side interior angles that add to $180^\circ$

In one plane, two lines that are both perpendicular to the same transversal are also parallel. Both corresponding angles are $90^\circ$, so they are equal.

## Examples

### #1: One Angle Unlocks All Eight

Lines $l$ and $m$ are parallel, cut by a transversal. At the top crossing, an interior angle measures $65^\circ$. Find its vertical angle, its linear pair neighbor, its corresponding angle, and its same-side interior angle.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "transversal", "labels": ["Line l", "Line m", "65°", "Vertical: 65°", "Linear pair: 115°", "Corresponding: 65°", "Same-side int: 115°"], "semanticsLabel": "Parallel lines l and m cut by a transversal with an interior top angle of 65 degrees and its vertical angle, linear pair, corresponding, and same-side interior angles."} -->

**Solution:**
The angle is not $90^\circ$, so every angle in the figure is either $65^\circ$ or its supplement.

1. The vertical angle faces the $65^\circ$ angle across the crossing, so it is $65^\circ$.
2. The linear pair neighbor completes a straight line.

$$180 - 65 = 115$$

3. The linear pair neighbor is $115^\circ$.
4. The corresponding angle is in the same corner at the bottom crossing, so it is $65^\circ$.
5. The same-side interior angle must add with $65^\circ$ to make $180^\circ$, so it is $115^\circ$.

### #2: Corresponding Angles with Algebra

Lines $p$ and $q$ are parallel. A transversal makes corresponding angles of $(2x + 30)^\circ$ and $(3x - 10)^\circ$. Find the measure of the angles.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "transversal", "labels": ["Line p", "Line q", "Corresponding: (2x + 30)°", "Corresponding: (3x - 10)°"], "semanticsLabel": "Parallel lines p and q cut by a transversal with corresponding angles labeled 2x plus 30 degrees and 3x minus 10 degrees."} -->

**Solution:**
Corresponding angles are equal, so set the expressions equal.

1. Write the equation.

$$2x + 30 = 3x - 10$$

2. Subtract $2x$ from both sides and add $10$ to both sides.

$$40 = x$$

3. Substitute back: $2(40) + 30 = 110$.
4. Check the other expression: $3(40) - 10 = 110$. Each angle is $110^\circ$.

### #3: Same-Side Interior Angles

Lines $a$ and $b$ are parallel. Two same-side interior angles measure $(3x + 20)^\circ$ and $(2x - 15)^\circ$. Find both angles.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "transversal", "labels": ["Line a", "Line b", "(3x + 20)°", "(2x - 15)°", "Sum = 180°"], "semanticsLabel": "Parallel lines a and b with same-side interior angles labeled 3x plus 20 degrees and 2x minus 15 degrees summing to 180 degrees."} -->

**Solution:**
Same-side interior angles are supplementary, so they add to $180^\circ$.

1. Write the sum equation.

$$(3x + 20) + (2x - 15) = 180$$

2. Combine like terms.

$$5x + 5 = 180$$

3. Subtract $5$, then divide by $5$.

$$5x = 175$$

$$x = 35$$

4. The angles are $3(35) + 20 = 125^\circ$ and $2(35) - 15 = 55^\circ$.
5. Check: $125 + 55 = 180$. Correct.

### #4: Which Rule Applies?

Lines $l$ and $m$ are parallel. An alternate interior angle pair measures $(4x)^\circ$ and $(3x + 18)^\circ$. Solve for $x$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "transversal", "labels": ["Line l", "Line m", "Alt interior: (4x)°", "Alt interior: (3x + 18)°"], "semanticsLabel": "Parallel lines l and m cut by a transversal with equal alternate interior angles labeled 4x degrees and 3x plus 18 degrees."} -->

**Solution:**
First decide: equal pair or supplementary pair? Alternate interior angles are equal.

1. Set the expressions equal.

$$4x = 3x + 18$$

2. Subtract $3x$ from both sides.

$$x = 18$$

3. Each angle is $4(18) = 72^\circ$. Check: $3(18) + 18 = 72$. Correct.

### #5: A Transversal Perpendicular to One Line

Line $t$ is perpendicular to line $l$, and $l \parallel m$. An angle between $t$ and $m$ measures $(4x + 10)^\circ$. Find $x$.

<!-- ILLUSTRATION: parallel lines l (top) and m (bottom) cut by a line t that makes a square right-angle mark with l; the angle between t and m is labeled (4x + 10)° -->

**Solution:**
The right angle between $t$ and $l$ has a corresponding angle at $m$. So $t$ is also perpendicular to $m$.

1. Corresponding angles are equal, so the angle at $m$ is $90^\circ$.
2. Set the expression equal to $90$.

$$4x + 10 = 90$$

3. Subtract $10$, then divide by $4$.

$$4x = 80$$

$$x = 20$$

4. Check: $4(20) + 10 = 90$. Correct.

### #6: Are the Lines Parallel? Use the Reverse Rule

A transversal cuts lines $r$ and $s$. Two corresponding angles measure $(5x + 10)^\circ$ and $(3x + 50)^\circ$. Find $x$ so that $r \parallel s$, and give the angle size.

<!-- ILLUSTRATION: lines r and s cut by a transversal, with corresponding angles labeled (5x + 10)° and (3x + 50)° in the same corner position at each crossing -->

**Solution:**
The lines are parallel exactly when the corresponding angles are equal.

1. Set the corresponding angles equal.

$$5x + 10 = 3x + 50$$

2. Subtract $3x$ and $10$ from both sides.

$$2x = 40$$

$$x = 20$$

3. Each angle is $5(20) + 10 = 110^\circ$. Check: $3(20) + 50 = 110$. Correct.

Now a check on a different figure. Two same-side interior angles measure $112^\circ$ and $70^\circ$. Their sum is $182^\circ$, not $180^\circ$, so the lines are not parallel.

### #7: The Zigzag Between Parallel Lines

Lines $l$ and $m$ are parallel. Point $A$ is on $l$ and point $B$ is on $m$, and both lie to the left of a point $P$ between the lines. Point $C$ is on $l$ to the right of $A$, and point $D$ is on $m$ to the right of $B$. Angle $CAP$ is $30^\circ$ and angle $DBP$ is $40^\circ$. Find angle $APB$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "parallel-zigzag", "labels": ["Line l", "Line m", "Point A on l", "Point C on l, right of A", "Point B on m", "Point D on m, right of B", "Point P between the lines, right of A and B", "Angle CAP = 30°", "Angle DBP = 40°", "Angle APB = ?"], "semanticsLabel": "Parallel lines l and m with a zigzag A to P to B. Point P is between the lines and to the right of A and B. Angle CAP is 30 degrees, angle DBP is 40 degrees, and angle APB is the unknown."} -->

**Solution:**
Draw a helper line through $P$, parallel to both lines. Let $E$ be a point on it to the left of $P$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "parallel-zigzag", "labels": ["Line l", "Line m", "Point A", "Point B", "Point P", "Point E on the helper line, left of P", "Helper line through P, parallel to l and m", "Angle APE = 30°", "Angle EPB = 40°"], "semanticsLabel": "Parallel lines l and m with point P between them and a dashed helper line through P parallel to both. Point E is on the helper line to the left of P. The helper line splits angle APB into angle APE of 30 degrees and angle EPB of 40 degrees."} -->

1. The helper line splits angle $APB$ into angle $APE$ and angle $EPB$.
2. Angle $APE$ and angle $CAP$ are alternate interior angles for the parallel lines $l$ and the helper line. So angle $APE$ is $30^\circ$.
3. Angle $EPB$ and angle $DBP$ are alternate interior angles for the helper line and $m$. So angle $EPB$ is $40^\circ$.
4. Add the two parts.

$$30 + 40 = 70$$

5. Angle $APB$ is $70^\circ$.

## Speed Tricks & Shortcuts

For two parallel lines cut by a transversal, any two of the eight angles are either equal or add to $180^\circ$. Name the pair first. A Z or F shape means equal, and a C or U shape means they add to $180^\circ$.

Once you find one angle, do not work out the rest from scratch. Use $x$ and $180 - x$, which alternate around each crossing. If the transversal is perpendicular, all eight angles are $90^\circ$.

For a zigzag like Example $7$, the angle at $P$ equals the sum of the two outer angles. This holds when both outer angles are measured on the side that faces $P$, with $A$ and $B$ on the same side of $P$. If the figure bends the other way, or one angle is measured on the other side, draw the helper line instead.

If you know the angle at $P$ and one outer angle, subtract to find the other.

## Traps to Watch For

### #1: The Lines Might Not Be Parallel

> Corresponding, alternate, and same-side angle rules need parallel lines.

If the problem does not say the lines are parallel (in words or with matching arrow marks), do not use these rules. A drawing can look parallel and not be. Vertical angles and linear pairs still hold, because they need only two crossing lines.

### #2: Equal or Supplementary?

> Same-side interior angles add to $180^\circ$. They are equal only when each is $90^\circ$.

Do not set two same-side interior angles equal to each other. If both expressions sit between the lines on the same side of the transversal, write a sum equation.

### #3: Corresponding vs. Alternate Confusion

> Corresponding angles are on the same side of the transversal; alternate angles are on opposite sides.

Corresponding angles sit in matching corners, one inside and one outside the lines. Alternate interior angles are both inside. Both pairs are equal when the lines are parallel, so the mix-up may not change your answer. A question may still ask you to name the pair.

### #4: Equal Angles in the Wrong Places

> Check the position of two equal angles before you call the lines parallel.

Equal corresponding, alternate interior, or alternate exterior angles prove it. Same-side interior angles prove it when they add to $180^\circ$. Equal same-side interior angles do this only when each is $90^\circ$, so otherwise check their sum.

Vertical angles are always equal, and a linear pair is equal when both are $90^\circ$. Both come from two crossing lines, so neither says anything about parallel lines.

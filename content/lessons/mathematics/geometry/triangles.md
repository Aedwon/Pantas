---
_id: "lesson-geometry-triangles"
title: "Triangles"
summary: "Triangle rules: angle sums, side limits, congruence, similarity, and the Pythagorean theorem."
subject: "subject-mathematics"
topic: "topic-geometry"
estimatedMinutes: 15
isActive: true
---
## Core Concept

A triangle has $3$ sides and $3$ angles, and one golden rule: the three interior angles always add up to $180^\circ$.

Triangles are named by sides (equilateral: all equal; isosceles: two equal; scalene: none equal) and by angles (acute, right, obtuse).

### Properties and Theorems (Triangle Inequality, Exterior Angle)

The **Triangle Inequality Theorem**: the sum of any two sides must be greater than the third side. Sides $2$, $3$, and $7$ cannot make a triangle, because $2 + 3 = 5$ is not greater than $7$. The two short sticks cannot reach each other.

The **Exterior Angle Theorem**: extend one side of a triangle and you create an exterior angle. That exterior angle equals the sum of the two remote interior angles (the two angles far from it).

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle-exterior", "labels": ["Remote Interior 1", "Remote Interior 2", "Exterior Angle = Sum"], "semanticsLabel": "Triangle with base extended showing exterior angle equal to the sum of two remote interior angles."} -->

Also useful: the longest side is always across from the biggest angle, and the shortest side is across from the smallest angle.

### Congruence Postulates (SSS, SAS, ASA, AAS, HL)

Two triangles are **congruent** when they are exact copies: same shape and same size. You can prove it with these shortcuts:

- **SSS**: all three sides match.
- **SAS**: two sides and the angle between them match.
- **ASA**: two angles and the side between them match.
- **AAS**: two angles and a non-included side match.
- **HL**: for right triangles only, the hypotenuse and one leg match.

Warning: SSA and AAA are not congruence proofs. AAA gives the same shape but maybe a different size.

### Similarity and Proportionality

Two triangles are **similar** when they have the same shape but possibly different sizes. Their angles match, and their sides are **proportional**: each side of the big triangle is the small triangle's side times the same scale factor.

Similarity powers the classic shadow problem: at the same time of day, a tree and a person make similar triangles with their shadows.

### Pythagorean Theorem and Special Right Triangles

In a right triangle with legs $a$ and $b$ and hypotenuse $c$ (the side across the right angle, always the longest):

$$a^2 + b^2 = c^2$$

Memorize the common **Pythagorean triples**: $3$-$4$-$5$, $5$-$12$-$13$, $8$-$15$-$17$, and their multiples like $6$-$8$-$10$.

Two **special right triangles** appear on every CET:

- **$45^\circ$-$45^\circ$-$90^\circ$**: the legs are equal, and the hypotenuse is a leg times $\sqrt{2}$.
- **$30^\circ$-$60^\circ$-$90^\circ$**: the short leg (across $30^\circ$) is half the hypotenuse, and the long leg is the short leg times $\sqrt{3}$.

## Examples

### #1: The Angle Sum

The angles of a triangle are in the ratio $1 : 2 : 3$. Find the angles and classify the triangle.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle", "labels": ["x", "2x", "3x (90°)", "Sum = 180°"], "semanticsLabel": "Right triangle with interior angles in ratio 1 to 2 to 3 labeled x, 2x, and 3x with a right angle square."} -->


**Solution:**
Ratio $1 : 2 : 3$ means the angles are $x$, $2x$, and $3x$.

1. The angles add to $180^\circ$.

$$x + 2x + 3x = 180$$

2. Combine and divide.

$$6x = 180$$

$$x = 30$$

3. The angles are $30^\circ$, $60^\circ$, and $90^\circ$.
4. One angle is exactly $90^\circ$, so this is a right triangle. (It is our special $30$-$60$-$90$ triangle!)

### #2: Range of the Third Side

Two sides of a triangle measure $5$ and $9$. How many integer lengths are possible for the third side?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle", "labels": ["Side a = 5", "Side b = 9", "Side c = ?", "4 < c < 14"], "semanticsLabel": "Triangle with sides 5 and 9 and unknown third side bounded between 4 and 14."} -->


**Solution:**
The third side $s$ must satisfy the triangle inequality in both directions.

1. It must be less than the sum of the other two.

$$s < 5 + 9 = 14$$

2. It must be greater than their difference.

$$s > 9 - 5 = 4$$

3. So $4 < s < 14$. The integers are $5, 6, 7, 8, 9, 10, 11, 12, 13$.
4. Count them: $9$ possible integer lengths. Note that $4$ and $14$ themselves are not allowed.

### #3: Exterior Angle Theorem

An exterior angle of a triangle measures $110^\circ$. One of the remote interior angles is $45^\circ$. Find the other remote interior angle.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle-exterior", "labels": ["45°", "?", "Exterior = 110°"], "semanticsLabel": "Triangle with extended side showing exterior angle 110 degrees, one remote interior angle 45 degrees, and the other marked with a question mark."} -->


**Solution:**
The exterior angle equals the sum of the two remote interior angles.

1. Write the equation with the unknown remote angle $x$.

$$45 + x = 110$$

2. Subtract $45$ from both sides.

$$x = 65$$

3. The other remote interior angle is $65^\circ$. No need to find the third angle of the triangle at all.

### #4: The Shadow Problem (Similarity)

A $1.5$-meter tall student casts a $2$-meter shadow. At the same time, a tree casts a $12$-meter shadow. How tall is the tree?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "similar-triangles", "labels": ["Student: h = 1.5 m", "Shadow = 2 m", "Tree: H = ?", "Shadow = 12 m", "Sun ray θ"], "semanticsLabel": "Two similar right triangles showing student height 1.5 meters with 2 meter shadow and tree height question mark with 12 meter shadow."} -->


**Solution:**
The sun's rays make similar triangles, so heights and shadows are proportional.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "similar-triangles", "labels": ["Student: 1.5", "Shadow: 2", "Tree: h", "Shadow: 12", "1.5 / 2 = h / 12"], "semanticsLabel": "Similar right triangles for student and tree with matching sun ray angles and proportional height to shadow ratio."} -->

1. Set up the proportion: height over shadow equals height over shadow.

$$\dfrac{h}{12} = \dfrac{1.5}{2}$$

2. Cross multiply.

$$2h = 1.5 \times 12 = 18$$

3. Divide by $2$.

$$h = 9$$

4. The tree is $9$ meters tall.

### #5: Pythagorean Theorem

A ladder $15$ feet long leans against a wall. Its foot is $9$ feet from the base of the wall. How high up the wall does the ladder reach?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle", "labels": ["Ladder = 15 ft", "Base = 9 ft", "Height = ?", "90° wall corner"], "semanticsLabel": "Right triangle formed by wall and ground with 15 foot ladder hypotenuse, 9 foot base, and height marked with a question mark."} -->


**Solution:**
The wall, ground, and ladder form a right triangle. The ladder is the hypotenuse.

1. Write the theorem with the unknown height $h$.

$$9^2 + h^2 = 15^2$$

2. Compute the squares.

$$81 + h^2 = 225$$

3. Subtract $81$.

$$h^2 = 144$$

4. Take the square root.

$$h = 12$$

5. The ladder reaches $12$ feet up. Shortcut: $9$-$12$-$15$ is just the $3$-$4$-$5$ triple times $3$.

### #6: Special Right Triangles

Find the missing sides: (a) a $45^\circ$-$45^\circ$-$90^\circ$ triangle with a leg of $5$; (b) a $30^\circ$-$60^\circ$-$90^\circ$ triangle with a hypotenuse of $12$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "special-right-triangles", "labels": ["45°-45°-90°: legs 5, hyp 5√2", "30°-60°-90°: hyp 12, short 6, long 6√3"], "semanticsLabel": "Two special right triangles showing a 45-45-90 triangle with legs 5 and a 30-60-90 triangle with hypotenuse 12."} -->


**Solution:**
Use the fixed side patterns. No Pythagorean grind needed.

1. For (a), the other leg is also $5$ (the legs are twins).
2. The hypotenuse is a leg times $\sqrt{2}$.

$$c = 5\sqrt{2}$$

3. For (b), the short leg (across the $30^\circ$ angle) is half the hypotenuse.

$$\text{short leg} = \dfrac{12}{2} = 6$$

4. The long leg is the short leg times $\sqrt{3}$.

$$\text{long leg} = 6\sqrt{3}$$

5. Answers: (a) legs $5$ and $5$, hypotenuse $5\sqrt{2}$; (b) sides $6$, $6\sqrt{3}$, and $12$.

## Speed Tricks & Shortcuts

Third-side range in one line: the third side is always between the difference and the sum of the other two sides.

Before squaring anything, scan for Pythagorean triples. Seeing $5$ and $13$? The missing leg is $12$. Seeing $8$ and $17$? It is $15$. Multiples count too: $10$-$24$-$26$ is $5$-$12$-$13$ doubled.

In a $30$-$60$-$90$ triangle, always find the short leg first (half the hypotenuse). Everything else grows from it. Working from the long leg first causes messy $\sqrt{3}$ fractions.

If a triangle's angles are in a ratio, divide $180$ by the ratio total. In Example $1$: $180 \div 6 = 30$, then multiply back.

## Traps to Watch For

### #1: The Fake Postulates

> SSA and AAA do not prove congruence.

Test-makers list SSA (sometimes written backwards) among the choices for congruence postulates. Two sides and a non-included angle can build two different triangles, so SSA fails. And AAA only proves similarity, never congruence, because size can differ.

### #2: Putting the Hypotenuse in the Wrong Spot

> The hypotenuse $c$ is always the longest side, across the right angle.

Given sides $9$ and $15$, students compute $9^2 + 15^2$ automatically. But if $15$ is the hypotenuse, the equation is $9^2 + b^2 = 15^2$. Read the problem to see which side sits across the right angle before you square.

### #3: Allowing the Boundary Values

> The triangle inequality is strict: the sum must be greater, not equal.

If two sides are $5$ and $9$, a third side of exactly $4$ or exactly $14$ makes the triangle collapse into a flat line. In counting problems like Example $2$, including the endpoints gives $11$ instead of $9$, and $11$ is waiting in the choices.

### #4: The Wrong Interior Angles

> The exterior angle equals the sum of the two remote angles, not its neighbor.

The interior angle right next to the exterior angle is its linear pair, adding to $180^\circ$. The theorem uses the two angles away from it. Mixing these up gives $180 - 110 = 70$ in Example $3$ instead of the correct $65$.

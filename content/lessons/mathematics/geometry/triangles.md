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

A triangle has $3$ sides and $3$ angles. Its interior angles add up to $180^\circ$.

By sides, triangles are **equilateral** (all equal), **isosceles** (at least two equal), or **scalene** (none equal). By angles, they are **acute** (all under $90^\circ$), **right** (one $90^\circ$), or **obtuse** (one over $90^\circ$).

In a **right triangle**, the two sides that form the right angle are the **legs**. The side across from the right angle is the **hypotenuse**. It is the longest side.

### Equal Sides and Equal Angles

In any triangle, equal sides sit across from equal angles. So in an isosceles triangle, the two angles across the two equal sides are equal. They are called the **base angles**. The reverse is also true: two equal angles mean the sides across from them are equal.

An equilateral triangle has three equal angles. Each one is $180^\circ \div 3 = 60^\circ$.

### Sides and Angles

The **Triangle Inequality Theorem** says the sum of any two sides must be greater than the third side. Sides $2$, $3$, and $7$ cannot make a triangle, because $2 + 3 = 5$ is not greater than $7$. The third side must be greater than the difference of the other two sides and less than their sum.

The longest side is across from the largest angle. The shortest side is across from the smallest angle. If two angles are equal, the sides across from them are equal too.

The **Exterior Angle Theorem** says that if you extend one side, the exterior angle equals the sum of the two remote interior angles (the two angles far from it).

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle-exterior", "labels": ["Remote Interior 1", "Remote Interior 2", "Exterior Angle = Sum"], "semanticsLabel": "Triangle with base extended showing exterior angle equal to the sum of two remote interior angles."} -->

### Congruence (SSS, SAS, ASA, AAS, HL)

Two triangles are **congruent** when they are exact copies. Their **corresponding** parts match.

In $\triangle ABC \cong \triangle DEF$, point $A$ matches $D$, $B$ matches $E$, and $C$ matches $F$. So side $AB$ matches $DE$, and $\angle C$ matches $\angle F$.

Prove congruence with these shortcuts. The parts must match in the same places in both triangles:

- **SSS**: all three sides match.
- **SAS**: two sides and the angle between them match.
- **ASA**: two angles and the side between them match.
- **AAS**: two angles and another side match.
- **HL**: in right triangles, the hypotenuse and one leg match. (The legs and the hypotenuse are explained above.)

Some equal parts are not given. Look for them in the figure.

A side shared by both triangles is equal to itself. Vertical angles (the opposite angles where two lines cross) are equal. A midpoint splits a segment into two equal parts.

Once the triangles are congruent, all their corresponding parts are equal. Use this to find a missing side or angle.

SSA means two sides and an angle that is not between them. It is not a congruence test, because it can build two different triangles. HL is the right-triangle case that does work.

SSA also fixes one triangle when the given side across from the given angle is at least as long as the other given side. For example, an angle of $120^\circ$ with a side $5$ next to it and a side $8$ across from it can make only one triangle. If the side across is shorter than the other given side and the angle is acute, two triangles may fit, so do not use SSA.

AAA does not prove congruence either. AAA gives the same shape but maybe a different size.

### Similarity

Two triangles are **similar** when they have the same shape but maybe different sizes. Corresponding angles are equal, and corresponding sides are **proportional**.

This means each side of the big triangle is the matching side of the small triangle times the same number. That number is the **scale factor**.

For example, a triangle with sides $3$, $4$, $5$ and a triangle with sides $6$, $8$, $10$ are similar. Each side doubles, so the scale factor is $2$. In any pair of corresponding sides, the ratios are equal: $\dfrac{6}{3} = \dfrac{8}{4} = \dfrac{10}{5}$.

Triangles are similar if two angles match (AA), all three side pairs are proportional (SSS), or two side pairs are proportional and the angle between them matches (SAS). Two angles are enough because the third angle is then fixed by the $180^\circ$ sum.

### The Pythagorean Theorem and Special Right Triangles

In a right triangle with legs $a$ and $b$ and hypotenuse $c$ (the longest side, across the right angle):

$$a^2 + b^2 = c^2$$

If a triangle's sides satisfy this, with $c$ as the longest side, it is a right triangle. If $a^2 + b^2$ is not equal to $c^2$, it is not.

**Why it works.** Draw a big square with side $a + b$. On each side, mark a point that splits it into a piece of length $a$ and a piece of length $b$. Join the marked points in order.

This cuts off four right triangles, one in each corner. Each has legs $a$ and $b$. Each long side of the middle shape is the hypotenuse of one of them, so all four sides of the middle shape equal $c$.

Now check the corners of the middle shape. At each one, the corner angle and the two acute angles of the triangles next to it lie along a straight side of the big square, so they add to $180^\circ$. The two acute angles of a right triangle add to $90^\circ$. So each corner is $90^\circ$, and the middle shape is a square of side $c$.

<!-- ILLUSTRATION: square of side a + b, four right triangles (legs a, b) in the corners, tilted square of side c in the middle -->

The big square equals four triangles plus the middle square. Each triangle has area $\dfrac{1}{2}ab$.

$$(a+b)^2 = 4 \cdot \dfrac{1}{2}ab + c^2$$

1. Expand the left side: $(a+b)^2 = a^2 + 2ab + b^2$.
2. Simplify the triangles: $4 \cdot \dfrac{1}{2}ab = 2ab$.
3. So $a^2 + 2ab + b^2 = 2ab + c^2$.
4. Subtract $2ab$ from both sides.

$$a^2 + b^2 = c^2$$

Common **Pythagorean triples** are $3$-$4$-$5$, $5$-$12$-$13$, $8$-$15$-$17$, and multiples like $6$-$8$-$10$.

Two **special right triangles** are common:

- **$45^\circ$-$45^\circ$-$90^\circ$**: the legs are equal, and the hypotenuse is a leg times $\sqrt{2}$.
- **$30^\circ$-$60^\circ$-$90^\circ$**: the short leg (across $30^\circ$) is half the hypotenuse, and the long leg is the short leg times $\sqrt{3}$.

## Examples

### #1: The Angle Sum

The angles of a triangle are in the ratio $1 : 2 : 3$. Find the angles and classify the triangle.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle", "labels": ["x", "2x", "3x (90°)", "Sum = 180°"], "semanticsLabel": "Right triangle with interior angles in ratio 1 to 2 to 3 labeled x, 2x, and 3x with a right angle square."} -->

**Solution:**
The angles are $x$, $2x$, and $3x$.

1. The angles add to $180^\circ$.

$$x + 2x + 3x = 180$$

2. Combine and divide.

$$6x = 180 \quad\Rightarrow\quad x = 30$$

3. The angles are $30^\circ$, $60^\circ$, and $90^\circ$. One angle is $90^\circ$, so this is a right triangle.

### #2: Range of the Third Side

Two sides of a triangle measure $5$ and $9$. How many integer lengths are possible for the third side?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle", "labels": ["Side a = 5", "Side b = 9", "Side c = ?", "4 < c < 14"], "semanticsLabel": "Triangle with sides 5 and 9 and unknown third side bounded between 4 and 14."} -->

**Solution:**
The third side $s$ must be less than the sum and greater than the difference.

1. Find the limits.

$$9 - 5 < s < 5 + 9$$

2. So $4 < s < 14$. The integers are $5$ through $13$, and $4$ and $14$ are not allowed.
3. There are $9$ possible integer lengths.

### #3: Ordering Sides by Angles

In $\triangle ABC$, $\angle A = 50^\circ$ and $\angle B = 60^\circ$. Which side is the longest, and which is the shortest?

<!-- ILLUSTRATION: triangle ABC with angle A = 50°, angle B = 60°, angle C = ? -->

**Solution:**
Find the third angle first.

1. $\angle C = 180^\circ - 50^\circ - 60^\circ = 70^\circ$.

2. The largest angle is $C$, so the longest side is $AB$.
3. The smallest angle is $A$, so the shortest side is $BC$.

### #4: Exterior Angle Theorem

An exterior angle of a triangle measures $110^\circ$. One of the remote interior angles is $45^\circ$. Find the other remote interior angle.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle-exterior", "labels": ["45°", "?", "Exterior = 110°"], "semanticsLabel": "Triangle with extended side showing exterior angle 110 degrees, one remote interior angle 45 degrees, and the other marked with a question mark."} -->

**Solution:**
The exterior angle equals the sum of the two remote interior angles.

1. Write the equation with the unknown angle $x$.

$$45 + x = 110 \quad\Rightarrow\quad x = 65$$

The other remote interior angle is $65^\circ$.

### #5: Isosceles Triangle

An isosceles triangle has one angle of $50^\circ$. Find the other two angles. There are two possible answers.

<!-- ILLUSTRATION: two isosceles triangles side by side; left has two base angles 50° and apex ?; right has apex 50° and two base angles ? -->

**Solution:**
The $50^\circ$ angle is either a base angle or the angle between the equal sides.

1. If $50^\circ$ is a base angle, the other base angle is also $50^\circ$. The third angle is $180^\circ - 50^\circ - 50^\circ = 80^\circ$.
2. If $50^\circ$ is the angle between the equal sides, the two base angles share $180^\circ - 50^\circ = 130^\circ$. Each is $\dfrac{130^\circ}{2} = 65^\circ$.

The angles are $50^\circ$, $50^\circ$, $80^\circ$ or $50^\circ$, $65^\circ$, $65^\circ$.

### #6: Matching Parts and Choosing the Rule

In $\triangle ABC$ and $\triangle DEF$, $\angle A = \angle D$, $\angle B = \angle E$, and $BC = EF$. Which congruence rule applies, and which side of $\triangle DEF$ equals $AC$?

<!-- ILLUSTRATION: triangles ABC and DEF; angles A and D one arc, angles B and E two arcs, sides BC and EF one tick -->

**Solution:**
Check where the equal side sits.

1. Two angles match, and side $BC$ is not between $\angle A$ and $\angle B$. The rule is AAS.
2. $AC$ is across from $\angle B$. Its match is across from $\angle E$, which is $DF$.

The rule is AAS, and $AC = DF$.

### #7: Proving Congruence from a Figure

(a) Segments $AB$ and $CD$ cross at $O$, and $O$ is the midpoint of both. If $AC = 7$, find $BD$.

(b) In quadrilateral $ABCD$, $AB = AD$ and $CB = CD$. If $\angle B = 100^\circ$, find $\angle D$.

<!-- ILLUSTRATION: (a) segments AB and CD crossing at O, with OA = OB and OC = OD marked by ticks, AC = 7; (b) quadrilateral ABCD with diagonal AC, AB = AD one tick, CB = CD two ticks, angle B = 100° -->

**Solution:**
Find the equal parts first, including the ones the figure hides.

1. For (a), $OA = OB$ and $OC = OD$ because $O$ is the midpoint of both segments. $\angle AOC = \angle BOD$ because they are vertical angles.
2. The equal angle is between the equal sides, so $\triangle AOC \cong \triangle BOD$ by SAS. Point $A$ matches $B$ and $C$ matches $D$, so $AC$ matches $BD$. Then $BD = 7$.
3. For (b), triangles $ABC$ and $ADC$ share side $AC$. With $AB = AD$ and $CB = CD$, all three sides match, so $\triangle ABC \cong \triangle ADC$ by SSS.
4. Point $B$ matches $D$, so $\angle D = \angle B = 100^\circ$.

The answers are (a) $BD = 7$ and (b) $\angle D = 100^\circ$.

### #8: The Shadow Problem (Similarity)

A $1.5$-meter tall student casts a $2$-meter shadow. At the same time, a tree casts a $12$-meter shadow. How tall is the tree?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "similar-triangles", "labels": ["Student: h = 1.5 m", "Shadow = 2 m", "Tree: H = ?", "Shadow = 12 m", "Sun ray θ"], "semanticsLabel": "Two similar right triangles showing student height 1.5 meters with 2 meter shadow and tree height question mark with 12 meter shadow."} -->

**Solution:**
The sun's rays make similar triangles. Each triangle has a right angle (the person or tree stands straight up) and the same sun angle at the end of the shadow. Two angles match, so the triangles are similar by AA. Heights and shadows are then proportional.

1. Set up the proportion with the tree height $h$.

$$\dfrac{h}{12} = \dfrac{1.5}{2} \quad\Rightarrow\quad h = \dfrac{1.5 \times 12}{2} = 9$$

The tree is $9$ meters tall.

### #9: Pythagorean Theorem

A ladder $15$ feet long leans against a wall. Its foot is $9$ feet from the base of the wall. How high up the wall does the ladder reach?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle", "labels": ["Ladder = 15 ft", "Base = 9 ft", "Height = ?", "90° wall corner"], "semanticsLabel": "Right triangle formed by wall and ground with 15 foot ladder hypotenuse, 9 foot base, and height marked with a question mark."} -->

**Solution:**
The wall, ground, and ladder form a right triangle. The ladder is the hypotenuse.

1. Write the theorem with the unknown height $h$.

$$9^2 + h^2 = 15^2$$

2. Subtract $81$ and take the square root.

$$h^2 = 225 - 81 = 144 \quad\Rightarrow\quad h = 12$$

The ladder reaches $12$ feet up the wall.

### #10: Special Right Triangles

Find the missing sides: (a) a $45^\circ$-$45^\circ$-$90^\circ$ triangle with a leg of $5$; (b) a $30^\circ$-$60^\circ$-$90^\circ$ triangle with a hypotenuse of $12$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "special-right-triangles", "labels": ["45°-45°-90°: legs 5, hyp 5√2", "30°-60°-90°: hyp 12, short 6, long 6√3"], "semanticsLabel": "Two special right triangles showing a 45-45-90 triangle with legs 5 and a 30-60-90 triangle with hypotenuse 12."} -->

**Solution:**
Use the fixed side patterns.

1. For (a), the other leg is also $5$. The hypotenuse is a leg times $\sqrt{2}$, so it is $5\sqrt{2}$.
2. For (b), the short leg is half the hypotenuse, $\dfrac{12}{2} = 6$.
3. The long leg is the short leg times $\sqrt{3}$, so it is $6\sqrt{3}$.

The answers are (a) $5$, $5$, and $5\sqrt{2}$; (b) $6$, $6\sqrt{3}$, and $12$.

## Speed Tricks & Shortcuts

Scan for Pythagorean triples before squaring. If a right triangle has a leg $5$ and hypotenuse $13$, the missing leg is $12$.

The triple $10$-$24$-$26$ is $5$-$12$-$13$ doubled. A triple only helps when the sides match it exactly. Otherwise, add the squares of the legs to find a hypotenuse. Subtract the square of the known leg from the square of the hypotenuse to find a leg.

In a $30$-$60$-$90$ triangle, find the short leg first. The short leg is the side across from $30^\circ$.


## Traps to Watch For

### #1: The Fake Postulates

> SSA and AAA do not prove congruence (SSA fixes one triangle only in some cases, such as HL, so do not use it as a test).

Two sides and an angle not between them can build two different triangles. AAA proves only similarity, because the size can differ.

### #2: Putting the Hypotenuse in the Wrong Spot

> The hypotenuse $c$ is always the longest side, across the right angle.

With sides $9$ and $15$, students often compute $9^2 + 15^2$. If $15$ is the hypotenuse, as in Example $9$, use $9^2 + b^2 = 15^2$.

### #3: Allowing the Boundary Values

> The triangle inequality is strict: the sum must be greater, not equal.

Exactly $4$ or $14$ flattens the triangle into a line. Including both in Example $2$ gives $11$ instead of $9$.

### #4: The Wrong Interior Angles

> The exterior angle equals the sum of the two remote angles, not its neighbor.

The neighbor interior angle and the exterior angle add to $180^\circ$. Using it gives $70$ in Example $4$ instead of $65$.

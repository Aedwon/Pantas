---
_id: "lesson-trigonometry-laws-of-sines-and-cosines"
title: "Laws of Sines and Cosines"
summary: "How to solve triangles that have no right angle using the Law of Sines and the Law of Cosines."
subject: "subject-mathematics"
topic: "topic-trigonometry"
estimatedMinutes: 15
isActive: true
---
## Core Concept

SOH-CAH-TOA works only on right triangles. An **oblique triangle** is a triangle with no right angle. To solve one, you need two bigger laws. Both laws also work on right triangles.

Use the standard labels. Side $a$ is opposite angle $A$, side $b$ is opposite angle $B$, and side $c$ is opposite angle $C$. A side and the angle across from it are a **matched pair**. To **solve** a triangle means to find its missing sides and angles.

The three angles of any triangle add to $180^\circ$. A bigger angle is always across from a longer side. Each side is shorter than the sum of the other two.

### Sine and cosine of angles up to $180^\circ$

An angle in a triangle can be obtuse, which means more than $90^\circ$ and less than $180^\circ$. For these angles, use two facts:

$$\sin(180^\circ - x) = \sin x \qquad \cos(180^\circ - x) = -\cos x$$

So $\sin 120^\circ = \sin 60^\circ = \dfrac{\sqrt{3}}{2}$, and $\cos 120^\circ = -\cos 60^\circ = -\dfrac{1}{2}$. The sine of an obtuse angle is positive. The cosine of an obtuse angle is negative.

Here are the values you need most:

- $\sin 30^\circ = \dfrac{1}{2}$, $\sin 45^\circ = \dfrac{\sqrt{2}}{2}$, $\sin 60^\circ = \dfrac{\sqrt{3}}{2}$
- $\cos 30^\circ = \dfrac{\sqrt{3}}{2}$, $\cos 45^\circ = \dfrac{\sqrt{2}}{2}$, $\cos 60^\circ = \dfrac{1}{2}$

### The Law of Sines

In any triangle, each side divided by the sine of its own opposite angle gives the same number:

$$\dfrac{a}{\sin A} = \dfrac{b}{\sin B} = \dfrac{c}{\sin C}$$

Use two of the three fractions at a time. To use it, you need one complete matched pair. You also need one more side or angle.

### The Law of Cosines

This law is the Pythagorean theorem with a correction term. Each form below has the side on the left and the angle across from it on the right:

$$c^2 = a^2 + b^2 - 2ab\cos C$$

$$a^2 = b^2 + c^2 - 2bc\cos A \qquad b^2 = a^2 + c^2 - 2ac\cos B$$

If $C = 90^\circ$, then $\cos C = 0$ and the correction disappears. You get plain Pythagoras. To find an angle, solve the first form for $\cos C$:

$$\cos C = \dfrac{a^2 + b^2 - c^2}{2ab}$$

A cosine fixes one angle between $0^\circ$ and $180^\circ$. A positive cosine means an acute angle. A negative cosine means an obtuse angle.

### Which law do you use?

The letters name what is given, in order around the triangle. S means a side and A means an angle. An **included angle** is the angle between two given sides.

- ASA: two angles and the side between them.
- AAS: two angles and a side that is not between them.
- SAS: two sides and the included angle.
- SSS: all three sides.
- SSA: two sides and an angle that is not between them.

Choose the law like this:

- ASA or AAS: find the third angle, then use the **Law of Sines**.
- SAS: use the **Law of Cosines** to find the third side.
- SSS: use the **Law of Cosines** to find an angle.
- SSA: use the **Law of Sines**. The given angle and its opposite side are a matched pair.

SAS and SSS have no matched pair, so the Law of Sines cannot start. ASA has no pair until you find the third angle.

### The ambiguous case (SSA)

Ambiguous means it can be read in more than one way. In SSA, the numbers may fit zero, one or two triangles. Say you know angle $A$, the side $a$ opposite it, and another side $b$.

1. Find $\sin B = \dfrac{b \sin A}{a}$.
2. If this is more than $1$, no triangle exists. A sine is never more than $1$.
3. If it equals $1$, then $B = 90^\circ$. One triangle exists if $A$ is acute. If $A$ is $90^\circ$ or more, $A + B$ is at least $180^\circ$, so no triangle exists.
4. If it is less than $1$, the calculator gives an acute angle $B_1$. A second angle $B_2 = 180^\circ - B_1$ has the same sine.
5. Keep $B_1$ or $B_2$ only if $A$ plus that angle is less than $180^\circ$. Each angle that stays gives one triangle.

A quick check with the sides: if $A$ is acute, let $h = b \sin A$. This is the height from the corner $C$ down to the opposite side.

- If $a < h$: no triangle.
- If $a = h$: one right triangle.
- If $h < a < b$: two triangles.
- If $a \ge b$: one triangle.

If $A$ is $90^\circ$ or more, a triangle exists only when $a > b$. Then there is exactly one. The biggest angle must face the longest side.

## Examples

### #1: Law of Sines (AAS)

In triangle $ABC$, angle $A = 30^\circ$, angle $B = 45^\circ$, and side $a = 10$. Find side $b$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle", "labels": ["A = 30°", "B = 45°", "a = 10", "b = ?", "C"], "semanticsLabel": "Triangle ABC with angle A equal to 30 degrees, angle B equal to 45 degrees, opposite side a equal to 10, and side b marked with a question mark."} -->

**Solution:**
We have the matched pair ($a$ with $A$), so the Law of Sines works.

1. Set up the proportion.

$$\dfrac{10}{\sin 30^\circ} = \dfrac{b}{\sin 45^\circ}$$

2. Substitute the exact values: $\sin 30^\circ = \dfrac{1}{2}$ and $\sin 45^\circ = \dfrac{\sqrt{2}}{2}$.

$$\dfrac{10}{\dfrac{1}{2}} = \dfrac{b}{\dfrac{\sqrt{2}}{2}}$$

3. The left side equals $20$. So:

$$b = 20 \times \dfrac{\sqrt{2}}{2} = 10\sqrt{2}$$

4. Side $b = 10\sqrt{2}$, about $14.14$. Check: angle $B$ is bigger than angle $A$, so side $b$ must be longer than $10$. It is.

### #2: The Third Angle Comes Free

In the same triangle (angles $30^\circ$ and $45^\circ$), find angle $C$ and state which side is longest.

**Solution:**
The angles of any triangle add to $180^\circ$.

1. Compute the third angle.

$$C = 180^\circ - 30^\circ - 45^\circ = 105^\circ$$

2. The biggest angle is $C$, so the longest side is the one opposite it: side $c$.
3. This size-order check catches wrong answers before you choose them.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle", "labels": ["A = 30°", "B = 45°", "C = 105°", "Longest side c"], "semanticsLabel": "Triangle ABC with angles 30, 45, and 105 degrees, showing side c opposite the 105 degree angle as the longest side."} -->

### #3: Law of Sines (ASA)

In triangle $ABC$, angle $A = 45^\circ$, angle $B = 75^\circ$, and side $c = 6$ lies between them. Find side $a$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle", "labels": ["A = 45°","B = 75°","c = 6","a = ?","C"], "semanticsLabel": "Triangle ABC with angle A equal to 45 degrees, angle B equal to 75 degrees, side c equal to 6 between them, and side a marked with a question mark."} -->

**Solution:**
The given side is between the two angles, so this is ASA. We have no matched pair yet. Find the third angle first.

1. Find angle $C$.

$$C = 180^\circ - 45^\circ - 75^\circ = 60^\circ$$

2. Now $c$ and $C$ are a matched pair. Pair $a$ with $A$.

$$\dfrac{a}{\sin 45^\circ} = \dfrac{6}{\sin 60^\circ}$$

3. Substitute the exact values.

$$a = 6 \times \dfrac{\sqrt{2}/2}{\sqrt{3}/2} = \dfrac{6\sqrt{2}}{\sqrt{3}}$$

4. Multiply top and bottom by $\sqrt{3}$.

$$a = \dfrac{6\sqrt{6}}{3} = 2\sqrt{6}$$

5. Side $a = 2\sqrt{6}$, about $4.90$. Check: $A$ is the smallest angle, so $a$ must be the shortest side. It is less than $6$.

### #4: Law of Cosines (SAS)

Two sides of a triangle measure $5$ and $8$, and the angle between them is $60^\circ$. Find the third side.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle", "labels": ["Side = 5", "Side = 8", "Included angle = 60°", "Third side c = ?"], "semanticsLabel": "Triangle with sides 5 and 8 meeting at a 60 degree included angle and opposite side marked with a question mark."} -->

**Solution:**
Two sides with the included angle: Law of Cosines.

1. Set up with $a = 5$, $b = 8$, $C = 60^\circ$.

$$c^2 = 5^2 + 8^2 - 2(5)(8)\cos 60^\circ$$

2. Substitute $\cos 60^\circ = \dfrac{1}{2}$.

$$c^2 = 25 + 64 - 80 \times \dfrac{1}{2}$$

3. Compute.

$$c^2 = 89 - 40 = 49$$

4. Take the square root.

$$c = 7$$

### #5: Law of Cosines (SSS) for an Angle

A triangle has sides $3$, $5$, and $7$. Find its largest angle.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle", "labels": ["Side = 3", "Side = 5", "Side = 7", "Largest angle = ?"], "semanticsLabel": "Triangle with sides 3, 5, and 7 and its largest angle marked with a question mark."} -->

**Solution:**
The largest angle sits opposite the longest side, $7$. Solve the Law of Cosines for that angle.

1. Call the wanted angle $C$, so $c = 7$.

$$\cos C = \dfrac{3^2 + 5^2 - 7^2}{2(3)(5)}$$

2. Compute the squares.

$$\cos C = \dfrac{9 + 25 - 49}{30}$$

3. Simplify.

$$\cos C = \dfrac{-15}{30} = -\dfrac{1}{2}$$

4. Cosine of $60^\circ$ is $\dfrac{1}{2}$. So an angle with cosine $-\dfrac{1}{2}$ is $180^\circ - 60^\circ$.

$$C = 120^\circ$$

5. The largest angle is $120^\circ$. The negative cosine told us early that the angle is obtuse.

### #6: SSA With Two Triangles

In triangle $ABC$, angle $A = 30^\circ$, side $a = 6$, and side $b = 6\sqrt{3}$. Find every possible angle $B$ and side $c$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle", "labels": ["A = 30°","a = 6","b = 6√3","B = ?","c = ?"], "semanticsLabel": "Triangle ABC with angle A equal to 30 degrees, side a equal to 6, side b equal to 6 root 3, and angle B and side c marked with question marks."} -->

**Solution:**
Side $a$ and angle $A$ are a matched pair, so use the Law of Sines.

1. Find $\sin B$.

$$\sin B = \dfrac{b \sin A}{a} = \dfrac{6\sqrt{3} \times \frac{1}{2}}{6} = \dfrac{\sqrt{3}}{2}$$

2. The sine is less than $1$. Two angles have this sine: $B_1 = 60^\circ$ and $B_2 = 180^\circ - 60^\circ = 120^\circ$.
3. Test the angle sums. $30^\circ + 60^\circ = 90^\circ$ and $30^\circ + 120^\circ = 150^\circ$. Both are less than $180^\circ$, so both triangles exist.
4. Find $C$ and $c$ for each.

$$B = 60^\circ:\ C = 90^\circ,\ c = \dfrac{6 \sin 90^\circ}{\sin 30^\circ} = 12$$

$$B = 120^\circ:\ C = 30^\circ,\ c = \dfrac{6 \sin 30^\circ}{\sin 30^\circ} = 6$$

5. Check with the side rule: $h = 6\sqrt{3} \times \dfrac{1}{2} \approx 5.2$. We have $h < a < b$, so two triangles is right.

### #7: SSA With No Triangle, and With a Right Triangle

Angle $A = 30^\circ$ and side $b = 8$. How many triangles exist if (a) $a = 3$, and (b) $a = 4$?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle", "labels": ["A = 30°","b = 8","a = ?"], "semanticsLabel": "Triangle with angle A equal to 30 degrees, side b equal to 8, and side a to be tested."} -->

**Solution:**
Find $\sin B = \dfrac{b \sin A}{a}$ each time.

1. For (a):

$$\sin B = \dfrac{8 \times \frac{1}{2}}{3} = \dfrac{4}{3}$$

2. A sine cannot be more than $1$. Side $a = 3$ is too short to reach the base. No triangle exists.
3. For (b):

$$\sin B = \dfrac{8 \times \frac{1}{2}}{4} = 1$$

4. So $B = 90^\circ$ and $C = 60^\circ$. Exactly one triangle exists, and it is a right triangle.
5. Check: $h = 8 \sin 30^\circ = 4$. In (a), $a < h$. In (b), $a = h$.

### #8: SSA With One Triangle

Angle $A = 45^\circ$, side $a = 2$, and side $b = \sqrt{2}$. How many triangles exist? Find angle $B$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle", "labels": ["A = 45°","a = 2","b = √2","B = ?"], "semanticsLabel": "Triangle ABC with angle A equal to 45 degrees, side a equal to 2, side b equal to root 2, and angle B marked with a question mark."} -->

**Solution:**
1. Find $\sin B$.

$$\sin B = \dfrac{\sqrt{2} \times \frac{\sqrt{2}}{2}}{2} = \dfrac{1}{2}$$

2. Two angles have this sine: $B_1 = 30^\circ$ and $B_2 = 150^\circ$.
3. Test the second angle: $45^\circ + 150^\circ = 195^\circ$. This is more than $180^\circ$, so $B_2$ is rejected.
4. Only $B = 30^\circ$ stays, so one triangle exists. Then $C = 105^\circ$.
5. Check with the side rule: $a = 2$ is longer than $b = \sqrt{2}$, so one triangle is right.

### #9: Two Ships (Exam Level)

Two ships leave the same port at the same time. After one hour, ship $X$ has sailed $3$ km and ship $Y$ has sailed $8$ km, and the angle between their paths is $60^\circ$. How far apart are the ships?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle", "labels": ["Port", "Ship X (3 km)", "Ship Y (8 km)", "Angle = 60°", "Distance d = ?"], "semanticsLabel": "Diagram of two ships leaving a port at a 60 degree angle, sailing 3 km and 8 km, with dashed distance between them marked with a question mark."} -->

**Solution:**
The port and the two ships form a triangle: two sides and the included angle. Law of Cosines.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle", "labels": ["Port", "Path 3 km", "Path 8 km", "60°", "Distance d"], "semanticsLabel": "Triangle formed by port and two ship paths of lengths 3 and 8 spreading at 60 degrees with dashed segment d."} -->

1. Set up.

$$d^2 = 3^2 + 8^2 - 2(3)(8)\cos 60^\circ$$

2. Substitute $\cos 60^\circ = \dfrac{1}{2}$.

$$d^2 = 9 + 64 - 48 \times \dfrac{1}{2}$$

3. Compute.

$$d^2 = 73 - 24 = 49$$

4. Take the square root.

$$d = 7$$

5. The ships are $7$ km apart.

### #10: Across a River (Exam Level)

Points $P$ and $Q$ are $60$ m apart on one bank of a river. A tree $T$ stands on the other bank. The angle at $P$ between $PQ$ and $PT$ is $30^\circ$. The angle at $Q$ between $QP$ and $QT$ is also $30^\circ$. Find the distance $PT$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle", "labels": ["P","Q","T","PQ = 60 m","Angle P = 30°","Angle Q = 30°","PT = ?"], "semanticsLabel": "Triangle with points P and Q 60 meters apart on one bank, a tree T on the other bank, angles of 30 degrees at P and at Q, and distance PT marked with a question mark."} -->

**Solution:**
Two angles and the side between them are given: ASA. Find the third angle first.

1. Find the angle at the tree.

$$T = 180^\circ - 30^\circ - 30^\circ = 120^\circ$$

2. Side $PQ$ is opposite angle $T$. Side $PT$ is opposite angle $Q$.

$$\dfrac{PT}{\sin 30^\circ} = \dfrac{60}{\sin 120^\circ}$$

3. Use $\sin 120^\circ = \sin 60^\circ = \dfrac{\sqrt{3}}{2}$.

$$PT = \dfrac{60 \times \frac{1}{2}}{\frac{\sqrt{3}}{2}} = \dfrac{60}{\sqrt{3}}$$

4. Multiply top and bottom by $\sqrt{3}$.

$$PT = \dfrac{60\sqrt{3}}{3} = 20\sqrt{3}$$

5. The tree is $20\sqrt{3}$ m, about $34.6$ m, from $P$. Check: $T$ is the biggest angle, so $PQ = 60$ is the longest side.

## Speed Tricks & Shortcuts

Ask first: "Do I have a side and its opposite angle?" If yes, try the Law of Sines. If you have two angles and no matched pair, find the third angle first. If you have SAS or SSS, use the Law of Cosines.

Special angles keep the arithmetic clean. Angles of $60^\circ$ and $120^\circ$ have cosines of $\dfrac{1}{2}$ and $-\dfrac{1}{2}$. Then the term $2ab\cos C$ becomes $ab$ or $-ab$.

Always run the size check at the end. Big sides must sit across from big angles. Each side must be less than the sum of the other two. This takes ten seconds and catches most setup errors.

In an SSA problem with an acute $A$, compare $a$ with $h = b \sin A$ and with $b$ before you compute. It tells you how many triangles to expect.

## Traps to Watch For

### #1: Losing the Sign of the Cosine

> For obtuse angles, $\cos C$ is negative, and subtracting a negative adds.

With $C = 120^\circ$, the term $-2ab\cos C$ becomes $-2ab \times \left(-\dfrac{1}{2}\right) = +ab$. Students drop the sign and subtract instead. The third side then comes out too short. Track the sign all the way through.

### #2: Mismatched Pairs in the Law of Sines

> Each fraction must hold a side and its own opposite angle.

Writing $\dfrac{a}{\sin B}$ scrambles the proportion. Before you compute, point at the triangle. Find side $a$, then the angle across from it, and only then write the fraction. Mislabeling is a common cause of wrong Law of Sines answers.

### #3: The Ambiguous Case (SSA)

> Two sides and a non-included angle can build two different triangles.

The Law of Sines gives $\sin B$, and two angles can share it: $B$ and $180^\circ - B$. Keep each one only if its sum with $A$ is less than $180^\circ$. A question may ask how many triangles are possible. The answer can be $0$, $1$ or $2$, so check before you assume one.

### #4: Answering with $c^2$

> The Law of Cosines gives the square of the side. Finish with the square root.

After a clean result such as $c^2 = 49$, it is easy to stop at $49$. A wrong choice may list it on purpose. The side is $7$. Circle the square-root step in your scratch work so you never skip it.

### #5: Finding a Large Angle With the Sine

> A sine cannot tell an acute angle from an obtuse one. A cosine can.

If $\sin B = \dfrac{1}{2}$, then $B$ could be $30^\circ$ or $150^\circ$. In SSS and SAS problems, use the Law of Cosines to find angles. It gives one answer. Use the Law of Sines for an angle only when you know the angle is acute, or when you test both answers as in an SSA problem.

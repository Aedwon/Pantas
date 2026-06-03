---
_id: "lesson-trigonometry-laws-of-sines-and-cosines"
title: "Laws of Sines and Cosines"
summary: "How to solve triangles that have no right angle using the Law of Sines and the Law of Cosines."
subject: "subject-mathematics"
topic: "topic-trigonometry"
estimatedMinutes: 13
isActive: true
---
## Core Concept

SOH-CAH-TOA only works on right triangles. For every other (oblique) triangle, you need two bigger laws. Standard labeling: side $a$ is opposite angle $A$, side $b$ opposite angle $B$, side $c$ opposite angle $C$.

**Law of Sines** — every side dances with its opposite angle at the same ratio:

$$\dfrac{a}{\sin A} = \dfrac{b}{\sin B} = \dfrac{c}{\sin C}$$

**Law of Cosines** — the Pythagorean theorem with a correction term:

$$c^2 = a^2 + b^2 - 2ab\cos C$$

Notice: if $C = 90^\circ$, then $\cos C = 0$ and the correction disappears, leaving plain Pythagoras.

Which law do you grab? Look at what is given:

- Two angles and any side (ASA or AAS): **Law of Sines**.
- Two sides and the angle opposite one of them (SSA): **Law of Sines**, carefully (this is the ambiguous case).
- Two sides and the included angle (SAS): **Law of Cosines**.
- All three sides (SSS): **Law of Cosines** to find an angle.

Memory hook: the Law of Sines needs a matched pair (a side with its opposite angle). No complete pair given? Then it must be the Law of Cosines.

## Examples

### #1: Law of Sines (AAS)

In triangle $ABC$, angle $A = 30^\circ$, angle $B = 45^\circ$, and side $a = 10$. Find side $b$.

<!-- ILLUSTRATION: a triangle ABC with angle A = 30°, angle B = 45°, side a = 10 opposite A, and side b opposite B marked "?" -->


**Solution:**
We have the pair ($a$ with $A$), so the Law of Sines works.

1. Set up the proportion.

$$\dfrac{10}{\sin 30^\circ} = \dfrac{b}{\sin 45^\circ}$$

2. Substitute exact values: $\sin 30^\circ = \dfrac{1}{2}$ and $\sin 45^\circ = \dfrac{\sqrt{2}}{2}$.

$$\dfrac{10}{\dfrac{1}{2}} = \dfrac{b}{\dfrac{\sqrt{2}}{2}}$$

3. The left side equals $20$. So:

$$b = 20 \times \dfrac{\sqrt{2}}{2} = 10\sqrt{2}$$

4. Side $b = 10\sqrt{2}$, about $14.14$. Sanity check: angle $B$ is bigger than angle $A$, so side $b$ should be longer than $10$. It is.

### #2: The Third Angle Comes Free

In the same triangle (angles $30^\circ$ and $45^\circ$), find angle $C$ and state which side is longest.

<!-- ILLUSTRATION: triangle ABC with angles A = 30°, B = 45°, and C = 105° marked; side c (opposite the largest angle C) highlighted as the longest -->


**Solution:**
Angles of any triangle add to $180^\circ$.

1. Compute the third angle.

$$C = 180 - 30 - 45 = 105^\circ$$

2. The biggest angle is $C$, so the longest side is the one opposite it: side $c$.
3. This size-order check (big angle across from big side) catches wrong answers before you shade them.

### #3: Law of Cosines (SAS)

Two sides of a triangle measure $5$ and $8$, and the angle between them is $60^\circ$. Find the third side.

<!-- ILLUSTRATION: a triangle with two sides 5 and 8 meeting at a 60° included angle, the third side (opposite the 60°) marked "?" -->


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

### #4: Law of Cosines (SSS) for an Angle

A triangle has sides $3$, $5$, and $7$. Find its largest angle.

<!-- ILLUSTRATION: a triangle with sides 3, 5, and 7; the angle opposite the longest side (7) marked "?" as the largest angle -->


**Solution:**
The largest angle sits opposite the largest side, $7$. Solve the Law of Cosines for that angle.

1. Set up with $c = 7$ opposite the wanted angle $C$.

$$7^2 = 3^2 + 5^2 - 2(3)(5)\cos C$$

2. Compute the squares.

$$49 = 9 + 25 - 30\cos C$$

3. Simplify.

$$49 = 34 - 30\cos C$$

$$15 = -30\cos C$$

4. Divide.

$$\cos C = -\dfrac{1}{2}$$

5. Which angle has cosine $-\dfrac{1}{2}$? Quadrant II reference angle $60^\circ$:

$$C = 120^\circ$$

6. The largest angle is $120^\circ$. The negative cosine told us early that the angle is obtuse.

### #5: Two Ships (Exam Level)

Two ships leave the same port at the same time. After one hour, ship $X$ has sailed $3$ km and ship $Y$ has sailed $8$ km, and the angle between their paths is $60^\circ$. How far apart are the ships?

<!-- ILLUSTRATION: a port point with two paths diverging at a 60° angle; ship X's path 3 km and ship Y's path 8 km, the dashed distance between the two ships marked "?" -->


**Solution:**
The port and the two ships form a triangle: two sides and the included angle. Law of Cosines.

<!-- ILLUSTRATION: port point with two ship paths spreading at 60 degrees, lengths 3 and 8, dashed segment d connecting the two ships -->

1. Set up.

$$d^2 = 3^2 + 8^2 - 2(3)(8)\cos 60^\circ$$

2. Substitute $\cos 60^\circ = \dfrac{1}{2}$.

$$d^2 = 9 + 64 - 48 \times \dfrac{1}{2}$$

3. Compute.

$$d^2 = 73 - 24 = 49$$

4. Square root.

$$d = 7$$

5. The ships are $7$ km apart.

## Speed Tricks & Shortcuts

Decision shortcut: ask "do I have a side and its opposite angle?" Yes: Law of Sines. No: Law of Cosines. This one question routes every problem correctly.

CET writers love angles of $60^\circ$ and $120^\circ$ in Law of Cosines problems because $\cos 60^\circ = \dfrac{1}{2}$ and $\cos 120^\circ = -\dfrac{1}{2}$ keep the arithmetic whole-number clean. Expect the correction term $2ab\cos C$ to simplify to just $ab$ (or $-ab$).

Always run the size check at the end: the answer must keep big sides across from big angles, and each side must be less than the sum of the other two. A ten-second check that catches most setup errors.

## Traps to Watch For

### #1: Losing the Sign of the Cosine

> For obtuse angles, $\cos C$ is negative, and subtracting a negative adds.

With $C = 120^\circ$, the term $-2ab\cos C$ becomes $-2ab \times \left(-\dfrac{1}{2}\right) = +ab$. Students drop the sign and subtract instead, getting a third side that is too short. Track the sign all the way through.

### #2: Mismatched Pairs in the Law of Sines

> Each fraction must hold a side and its own opposite angle.

Writing $\dfrac{a}{\sin B}$ scrambles the proportion. Before computing, point at the triangle: side $a$, the angle across from it is... only then write the fraction. Mislabeling is the top cause of wrong Law of Sines answers.

### #3: The Ambiguous Case (SSA)

> Two sides and a non-included angle can build two different triangles.

Given $a$, $b$, and angle $A$, the Law of Sines produces $\sin B$, and there may be two valid angles: $B$ and $180^\circ - B$. If both keep the angle sum under $180^\circ$, both triangles exist. When a question asks "how many triangles are possible", the answer can be $0$, $1$, or $2$ — check before assuming one.

### #4: Answering with $c^2$

> The Law of Cosines gives the square of the side. Finish with the square root.

After the clean computation $c^2 = 49$, tired students shade $49$. The choices include it on purpose. The side is $7$. Circle the final square-root step in your scratch work so you never skip it.

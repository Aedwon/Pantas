---
_id: "lesson-trigonometry-basic-trigonometric-ratios"
title: "Basic Trigonometric Ratios (SOH-CAH-TOA)"
summary: "The six trigonometric ratios of a right triangle and how to use them to find missing sides."
subject: "subject-mathematics"
topic: "topic-trigonometry"
estimatedMinutes: 15
isActive: true
---
## Core Concept

A **right triangle** has one angle of $90^\circ$. The other two angles are **acute**, which means each is less than $90^\circ$. Trigonometry starts with a right triangle and one chosen acute angle, written $\theta$ (the Greek letter theta). In this lesson, angles are measured in degrees.

The three sides get names based on where they sit relative to $\theta$:

- **Hypotenuse**: the side across from the right angle. It is the longest side.
- **Opposite**: the side across from $\theta$.
- **Adjacent**: the side next to $\theta$ that is not the hypotenuse. "Adjacent" means "next to".

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ", "Opposite", "Adjacent", "Hypotenuse", "90°"], "semanticsLabel": "Right triangle with acute angle theta, opposite side, adjacent side, and hypotenuse labeled relative to theta."} -->

A **ratio** compares two numbers by dividing one by the other. The three main trigonometric ratios compare two sides of the triangle. They are **sine** (sin), **cosine** (cos), and **tangent** (tan):

$$\sin \theta = \dfrac{\text{opposite}}{\text{hypotenuse}}$$

$$\cos \theta = \dfrac{\text{adjacent}}{\text{hypotenuse}}$$

$$\tan \theta = \dfrac{\text{opposite}}{\text{adjacent}}$$

Each has a **reciprocal** partner. A reciprocal is the ratio turned upside down. The partners are **cosecant** (csc), **secant** (sec), and **cotangent** (cot):

$$\csc \theta = \dfrac{1}{\sin \theta} = \dfrac{\text{hypotenuse}}{\text{opposite}}$$

$$\sec \theta = \dfrac{1}{\cos \theta} = \dfrac{\text{hypotenuse}}{\text{adjacent}}$$

$$\cot \theta = \dfrac{1}{\tan \theta} = \dfrac{\text{adjacent}}{\text{opposite}}$$

For an acute angle, every side is longer than zero, so all six ratios are positive and none of them divides by zero. Each leg is shorter than the hypotenuse. So $\sin \theta$ and $\cos \theta$ are between $0$ and $1$, and $\csc \theta$ and $\sec \theta$ are greater than $1$. The tangent can be any positive number.

The ratios depend only on the angle, not on the triangle's size. A $3$-$4$-$5$ triangle and a $6$-$8$-$10$ triangle give the same ratios. They are **similar triangles**: same angles, with all sides scaled by the same number.

The sides of a right triangle also obey the Pythagorean theorem. If the legs are $a$ and $b$ and the hypotenuse is $c$, then $a^2 + b^2 = c^2$.

The two acute angles of a right triangle add up to $90^\circ$. Two angles that add up to $90^\circ$ are **complementary**. Call the two acute angles $\theta$ and $90^\circ - \theta$. The side opposite one angle is the side adjacent to the other. So the ratios swap:

$$\sin \theta = \cos(90^\circ - \theta) \qquad \cos \theta = \sin(90^\circ - \theta)$$

$$\tan \theta = \cot(90^\circ - \theta) \qquad \cot \theta = \tan(90^\circ - \theta)$$

"Cosine" means "sine of the complement". These swaps hold for acute angles in a right triangle.

Some angles come up often, so their ratios are worth knowing. Two triangles give all of them.

First, cut a square along its diagonal. This gives a $45$-$45$-$90$ triangle. Take both legs as $1$. The Pythagorean theorem gives the hypotenuse $\sqrt{1^2 + 1^2} = \sqrt{2}$. Then $\sin 45^\circ = \dfrac{1}{\sqrt{2}} = \dfrac{\sqrt{2}}{2}$. Multiplying top and bottom by $\sqrt{2}$ removes the root from the bottom.

Second, cut an equilateral triangle with side $2$ down the middle. This gives a $30$-$60$-$90$ triangle. The short leg is $1$, the hypotenuse is $2$, and the long leg is $\sqrt{2^2 - 1^2} = \sqrt{3}$. The short leg is across the $30^\circ$ angle. The long leg is across the $60^\circ$ angle.

<!-- ILLUSTRATION: Two triangles side by side. Left: a 45-45-90 triangle with both legs labeled 1 and the hypotenuse labeled √2. Right: a 30-60-90 triangle with the short leg labeled 1 (across 30°), the long leg labeled √3 (across 60°), and the hypotenuse labeled 2. -->

Reading the ratios from these two triangles gives the values to memorize:

- $\sin 30^\circ = \dfrac{1}{2}$, $\cos 30^\circ = \dfrac{\sqrt{3}}{2}$, $\tan 30^\circ = \dfrac{1}{\sqrt{3}} = \dfrac{\sqrt{3}}{3}$
- $\sin 45^\circ = \dfrac{\sqrt{2}}{2}$, $\cos 45^\circ = \dfrac{\sqrt{2}}{2}$, $\tan 45^\circ = 1$
- $\sin 60^\circ = \dfrac{\sqrt{3}}{2}$, $\cos 60^\circ = \dfrac{1}{2}$, $\tan 60^\circ = \sqrt{3}$

## Mnemonics & Memory Aids

The famous one:

> SOH-CAH-TOA

**S**ine is **O**pposite over **H**ypotenuse. **C**osine is **A**djacent over **H**ypotenuse. **T**angent is **O**pposite over **A**djacent.

For the reciprocals, pair each ratio with the partner that starts with a different letter. Sin pairs with **c**sc. Cos pairs with **s**ec. The leftover pair is tan and cot.

For the special values of sine, the numerators of $30^\circ$, $45^\circ$, $60^\circ$ read $\sqrt{1}$, $\sqrt{2}$, $\sqrt{3}$ over $2$. Cosine reads the same list backward.

## Examples

### #1: Reading the Ratios from a Triangle

A right triangle has legs $3$ and $4$ and hypotenuse $5$. Let $\theta$ be the angle opposite the side of length $3$, and let $\phi$ (the Greek letter phi) be the other acute angle. Find $\sin \theta$, $\cos \theta$, and $\tan \theta$. Then find the same three ratios for $\phi$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ", "Opposite = 3", "Adjacent = 4", "Hypotenuse = 5", "90°"], "semanticsLabel": "Right triangle with angle theta opposite side 3, adjacent side 4, and hypotenuse 5."} -->

**Solution:**
Label the sides relative to $\theta$: opposite is $3$, adjacent is $4$, hypotenuse is $5$.

1. Sine is opposite over hypotenuse.

$$\sin \theta = \dfrac{3}{5}$$

2. Cosine is adjacent over hypotenuse.

$$\cos \theta = \dfrac{4}{5}$$

3. Tangent is opposite over adjacent.

$$\tan \theta = \dfrac{3}{4}$$

4. Now switch to $\phi$. The labels change with the angle. Across from $\phi$ is $4$, next to $\phi$ is $3$, and the hypotenuse is still $5$.

$$\sin \phi = \dfrac{4}{5} \qquad \cos \phi = \dfrac{3}{5} \qquad \tan \phi = \dfrac{4}{3}$$

5. Compare: $\sin \phi = \cos \theta$ and $\cos \phi = \sin \theta$. This fits the swap rule, because $\theta + \phi = 90^\circ$.

### #2: One Ratio Gives the Others

If $\sin \theta = \dfrac{5}{13}$ and $\theta$ is acute, find $\cos \theta$ and $\tan \theta$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ", "Opposite = 5", "Hypotenuse = 13", "90°"], "semanticsLabel": "Right triangle with angle theta, opposite side 5, and hypotenuse 13."} -->

**Solution:**
Build the triangle behind the ratio: opposite $5$, hypotenuse $13$. Find the missing adjacent side.

1. Use the Pythagorean theorem.

$$a^2 = 13^2 - 5^2 = 169 - 25 = 144$$

2. Take the square root.

$$a = 12$$

3. Now read off the other ratios.

$$\cos \theta = \dfrac{12}{13} \qquad \tan \theta = \dfrac{5}{12}$$

4. Recognizing the $5$-$12$-$13$ triple skips the squaring.

### #3: Finding a Missing Side

In a right triangle, the hypotenuse is $20$ and one acute angle measures $30^\circ$. Find the side opposite the $30^\circ$ angle.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["30°", "Hypotenuse = 20", "Opposite = ?", "90°"], "semanticsLabel": "Right triangle with 30 degree angle, hypotenuse 20, and opposite side labeled with a question mark."} -->

**Solution:**
We know the hypotenuse and want the opposite. The letters O and H live in SOH, so use sine.

1. Set up the ratio.

$$\sin 30^\circ = \dfrac{x}{20}$$

2. Substitute the memorized value $\sin 30^\circ = \dfrac{1}{2}$.

$$\dfrac{1}{2} = \dfrac{x}{20}$$

3. Multiply both sides by $20$.

$$x = 10$$

4. The opposite side is $10$. Shortcut: in a right triangle with a $30^\circ$ angle, the side across $30^\circ$ is half the hypotenuse.

### #4: Finding a Missing Side with Tangent

In a right triangle, one acute angle measures $60^\circ$ and the side next to it (not the hypotenuse) is $8$. Find the side opposite the $60^\circ$ angle.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["60°", "Adjacent = 8", "Opposite = ?", "90°"], "semanticsLabel": "Right triangle with 60 degree angle, adjacent side 8, and opposite side labeled with a question mark."} -->

**Solution:**
We know the adjacent side and want the opposite. The letters O and A live in TOA, so use tangent.

1. Set up the ratio.

$$\tan 60^\circ = \dfrac{x}{8}$$

2. Substitute $\tan 60^\circ = \sqrt{3}$.

$$\sqrt{3} = \dfrac{x}{8}$$

3. Multiply both sides by $8$.

$$x = 8\sqrt{3}$$

4. Check the size: $8\sqrt{3} \approx 13.9$. The side across the larger acute angle should be longer than the other leg, and it is.

### #5: Finding a Missing Hypotenuse

In a right triangle, one acute angle measures $45^\circ$ and the side opposite it is $8$. Find the hypotenuse.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["45°", "Opposite = 8", "Hypotenuse = ?", "90°"], "semanticsLabel": "Right triangle with 45 degree angle, opposite side 8, and hypotenuse labeled with a question mark."} -->

**Solution:**
We know the opposite and want the hypotenuse. Use sine.

1. Set up the ratio.

$$\sin 45^\circ = \dfrac{8}{x}$$

2. Substitute $\sin 45^\circ = \dfrac{\sqrt{2}}{2}$.

$$\dfrac{\sqrt{2}}{2} = \dfrac{8}{x}$$

3. The unknown is in the bottom. Swap it with the sine value: $x \cdot \dfrac{\sqrt{2}}{2} = 8$, so

$$x = \dfrac{8 \cdot 2}{\sqrt{2}} = \dfrac{16}{\sqrt{2}}$$

4. Remove the root from the bottom by multiplying top and bottom by $\sqrt{2}$.

$$x = \dfrac{16\sqrt{2}}{2} = 8\sqrt{2}$$

5. Check: in a $45$-$45$-$90$ triangle the hypotenuse is the leg times $\sqrt{2}$, and $8\sqrt{2}$ matches.

### #6: The Reciprocal Ratios

Using the triangle from Example $1$ (opposite $3$, adjacent $4$, hypotenuse $5$), find $\csc \theta$, $\sec \theta$, and $\cot \theta$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ", "Opp = 3", "Adj = 4", "Hyp = 5", "Reciprocal Ratios"], "semanticsLabel": "Right triangle with sides 3, 4, and 5 with angle theta for reading reciprocal trigonometric ratios."} -->

**Solution:**
Flip each main ratio upside down.

1. Cosecant flips sine.

$$\csc \theta = \dfrac{5}{3}$$

2. Secant flips cosine.

$$\sec \theta = \dfrac{5}{4}$$

3. Cotangent flips tangent.

$$\cot \theta = \dfrac{4}{3}$$

### #7: Complementary Angles

Part A: Write $\sin 25^\circ$ as a cosine. Part B: If $\sin 3x = \cos(x + 10^\circ)$ and both angles are acute, find $x$.

**Solution:**
Use the swap rule. For acute angles, the sine of one equals the cosine of its complement.

1. Part A: the complement of $25^\circ$ is $90^\circ - 25^\circ = 65^\circ$.

$$\sin 25^\circ = \cos 65^\circ$$

2. Part B: $\sin 3x = \cos(90^\circ - 3x)$. So the two cosines must have equal angles.

$$90^\circ - 3x = x + 10^\circ$$

3. Solve for $x$.

$$80^\circ = 4x \qquad x = 20^\circ$$

4. Check: $\sin 60^\circ = \dfrac{\sqrt{3}}{2}$ and $\cos 30^\circ = \dfrac{\sqrt{3}}{2}$. They match.

### #8: Exam-Level Combination

In a right triangle, $\tan \theta = \dfrac{3}{4}$ and the hypotenuse measures $20$. Find the two legs and the value of $\sin \theta$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ", "Hypotenuse = 20", "90°"], "semanticsLabel": "Right triangle with angle theta and hypotenuse 20. The legs are not labeled."} -->

**Solution:**
The tangent gives the shape of the triangle. The hypotenuse gives its size.

1. A tangent of $\dfrac{3}{4}$ means opposite and adjacent are in the ratio $3 : 4$. That is the $3$-$4$-$5$ triangle, so the hypotenuse is $5$ parts.
2. The real hypotenuse is $20$, so each part is $20 \div 5 = 4$.
3. Scale the legs.

$$\text{opposite} = 3 \times 4 = 12 \qquad \text{adjacent} = 4 \times 4 = 16$$

4. Now read the sine.

$$\sin \theta = \dfrac{12}{20} = \dfrac{3}{5}$$

5. Check with Pythagoras: $12^2 + 16^2 = 144 + 256 = 400 = 20^2$. Correct.

## Speed Tricks & Shortcuts

Choosing the right ratio is a two-question game: which side do I know, and which side do I want? Pick the ratio whose letters mention exactly those two sides. Know the hypotenuse, want the opposite? The pair O and H lives in SOH, so use sine.

When the unknown side is on top of the ratio, multiply to solve. When it is on the bottom, swap it with the other side of the equation, as in Example $5$.

Two shapes give quick answers. In a $30$-$60$-$90$ triangle, the sides are in the ratio $1 : \sqrt{3} : 2$, from short leg to long leg to hypotenuse. In a $45$-$45$-$90$ triangle, the sides are in the ratio $1 : 1 : \sqrt{2}$.

Complementary angles swap sine and cosine: $\sin \theta = \cos(90^\circ - \theta)$. So $\sin 25^\circ = \cos 65^\circ$ with no computation. To solve $\sin A = \cos B$ for acute angles, set $A + B = 90^\circ$.

Keep the Pythagorean triples ready: $3$-$4$-$5$, $5$-$12$-$13$, $8$-$15$-$17$, and $7$-$24$-$25$. Their multiples work too, like $6$-$8$-$10$. If the two known sides match a triple in their roles, the third side is the triple's remaining number. The triple's largest number must be the hypotenuse: legs $4$ and $5$ give a hypotenuse of $\sqrt{41}$, not $3$. If they do not match, use $a^2 + b^2 = c^2$.

## Traps to Watch For

### #1: Opposite and Adjacent Depend on the Angle

> Switch angles and the labels switch too.

The side that is opposite one acute angle is adjacent to the other. If a problem asks for ratios of both acute angles, relabel the triangle each time. Using one fixed labeling gives you the other angle's value instead, and that value is planted in the choices.

### #2: The Hypotenuse Is Never Opposite or Adjacent

> The hypotenuse has one identity: across from the right angle.

Students sometimes call the hypotenuse "adjacent" because it touches $\theta$. It does touch, but the name is reserved. The adjacent side is the other side touching $\theta$. Tangent never uses the hypotenuse at all.

### #3: Flipping the Wrong Reciprocal

> Cosecant goes with sine, secant goes with cosine.

The names feel backward: csc starts with c but flips sin, and sec starts with s but flips cos. Use the different-first-letter pairing from the mnemonic. Mixing them turns $\csc \theta = \dfrac{5}{3}$ into $\dfrac{5}{4}$, and both appear in the choices.

### #4: Ratios Are Not Lengths

> $\sin \theta = \dfrac{3}{5}$ does not mean the sides are $3$ and $5$.

The sides could be $6$ and $10$, or $30$ and $50$. Only the ratio is fixed. When a problem gives one real length, find the scale factor first (like in Example $8$) before naming any side.

### #5: Special Values Belong to Their Own Angles

> Do not carry a value from one special angle to another.

Sine is not proportional to the angle. Although $\sin 30^\circ = \dfrac{1}{2}$, the value of $\sin 60^\circ$ is not $1$ but $\dfrac{\sqrt{3}}{2}$. Likewise $\tan 45^\circ = 1$ only at $45^\circ$. Check which angle the question gives before you substitute.

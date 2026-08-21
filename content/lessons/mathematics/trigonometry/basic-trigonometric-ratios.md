---
_id: "lesson-trigonometry-basic-trigonometric-ratios"
title: "Basic Trigonometric Ratios (SOH-CAH-TOA)"
summary: "The six trigonometric ratios of a right triangle and how to use them to find missing sides."
subject: "subject-mathematics"
topic: "topic-trigonometry"
estimatedMinutes: 12
isActive: true
---
## Core Concept

Trigonometry starts with a right triangle and one chosen acute angle $\theta$. The three sides get names based on where they sit relative to $\theta$:

- **Hypotenuse**: across from the right angle. Always the longest.
- **Opposite**: the side across from $\theta$.
- **Adjacent**: the side next to $\theta$ (not the hypotenuse).

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ", "Opposite", "Adjacent", "Hypotenuse", "90°"], "semanticsLabel": "Right triangle with acute angle theta, opposite side, adjacent side, and hypotenuse labeled relative to theta."} -->

The three main ratios:

$$\sin \theta = \dfrac{\text{opposite}}{\text{hypotenuse}}$$

$$\cos \theta = \dfrac{\text{adjacent}}{\text{hypotenuse}}$$

$$\tan \theta = \dfrac{\text{opposite}}{\text{adjacent}}$$

Each has a **reciprocal** partner: cosecant, secant, and cotangent.

$$\csc \theta = \dfrac{1}{\sin \theta} \qquad \sec \theta = \dfrac{1}{\cos \theta} \qquad \cot \theta = \dfrac{1}{\tan \theta}$$

Important: the ratios depend only on the angle, not on the triangle's size. A $3$-$4$-$5$ triangle and a $6$-$8$-$10$ triangle give identical ratios, because they are similar triangles.

The exam values to memorize: $\sin 30^\circ = \dfrac{1}{2}$, $\cos 60^\circ = \dfrac{1}{2}$, $\sin 45^\circ = \cos 45^\circ = \dfrac{\sqrt{2}}{2}$, $\tan 45^\circ = 1$, $\sin 60^\circ = \cos 30^\circ = \dfrac{\sqrt{3}}{2}$, $\tan 30^\circ = \dfrac{\sqrt{3}}{3}$, and $\tan 60^\circ = \sqrt{3}$.

## Mnemonics & Memory Aids

The famous one:

> SOH-CAH-TOA

**S**ine is **O**pposite over **H**ypotenuse. **C**osine is **A**djacent over **H**ypotenuse. **T**angent is **O**pposite over **A**djacent.

For the reciprocals, match them by avoiding the same first letter: **s**in pairs with **c**sc, **c**os pairs with **s**ec. The leftover pair is tan and cot.

## Examples

### #1: Reading the Ratios from a Triangle

A right triangle has legs $3$ and $4$ and hypotenuse $5$. If $\theta$ is the angle opposite the side of length $3$, find $\sin \theta$, $\cos \theta$, and $\tan \theta$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ", "Opposite = 3", "Adjacent = 4", "Hypotenuse = 5", "90°"], "semanticsLabel": "Right triangle with angle theta opposite side 3, adjacent side 4, and hypotenuse 5."} -->


**Solution:**
Label the sides relative to $\theta$: opposite is $3$, adjacent is $4$, hypotenuse is $5$.

1. Sine is opposite over hypotenuse.

$$\sin \theta = \dfrac{3}{5}$$

2. Cosine is adjacent over hypotenuse.

$$\cos \theta = \dfrac{4}{5}$$

3. Tangent is opposite over adjacent.

$$\tan \theta = \dfrac{3}{4}$$

### #2: One Ratio Gives the Others

If $\sin \theta = \dfrac{5}{13}$ and $\theta$ is acute, find $\cos \theta$ and $\tan \theta$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ", "Opposite = 5", "Hypotenuse = 13", "Adjacent = 12", "90°"], "semanticsLabel": "Right triangle with angle theta, opposite side 5, hypotenuse 13, and adjacent side 12."} -->


**Solution:**
Build the triangle behind the ratio: opposite $5$, hypotenuse $13$. Find the missing adjacent side.

1. Use the Pythagorean theorem.

$$a^2 = 13^2 - 5^2 = 169 - 25 = 144$$

2. Take the square root.

$$a = 12$$

3. Now read off the other ratios.

$$\cos \theta = \dfrac{12}{13} \qquad \tan \theta = \dfrac{5}{12}$$

4. Recognizing the $5$-$12$-$13$ triple skips the squaring entirely.

### #3: Finding a Missing Side

In a right triangle, the hypotenuse is $20$ and one acute angle measures $30^\circ$. Find the side opposite the $30^\circ$ angle.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["30°", "Hypotenuse = 20", "Opposite = ?", "90°"], "semanticsLabel": "Right triangle with 30 degree angle, hypotenuse 20, and opposite side labeled with a question mark."} -->


**Solution:**
We know the hypotenuse and want the opposite: that is sine territory.

1. Set up the ratio.

$$\sin 30^\circ = \dfrac{x}{20}$$

2. Substitute the memorized value $\sin 30^\circ = \dfrac{1}{2}$.

$$\dfrac{1}{2} = \dfrac{x}{20}$$

3. Multiply both sides by $20$.

$$x = 10$$

4. The opposite side is $10$. Shortcut: in a $30$-$60$-$90$ triangle, the side across $30^\circ$ is always half the hypotenuse.

### #4: The Reciprocal Ratios

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

### #5: Exam-Level Combination

In a right triangle, $\tan \theta = \dfrac{3}{4}$ and the hypotenuse measures $20$. Find the two legs and the value of $\sin \theta$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ", "Opp = 3k = 12", "Adj = 4k = 16", "Hyp = 5k = 20", "90°"], "semanticsLabel": "Right triangle where tangent theta is 3 over 4 with hypotenuse 20 scaled to legs 12 and 16."} -->


**Solution:**
The tangent gives the shape of the triangle; the hypotenuse gives its size.

1. A tangent of $\dfrac{3}{4}$ means opposite and adjacent are in the ratio $3 : 4$. That is the $3$-$4$-$5$ family, so the hypotenuse pattern is $5$ parts.
2. The real hypotenuse is $20$, so each part is $20 \div 5 = 4$.
3. Scale the legs.

$$\text{opposite} = 3 \times 4 = 12 \qquad \text{adjacent} = 4 \times 4 = 16$$

4. Now read the sine.

$$\sin \theta = \dfrac{12}{20} = \dfrac{3}{5}$$

5. Check with Pythagoras: $12^2 + 16^2 = 144 + 256 = 400 = 20^2$. Correct.

## Speed Tricks & Shortcuts

Choosing the right ratio is a two-question game: which side do I know, and which side do I want? Pick the ratio whose letters mention exactly those two sides. Know the hypotenuse, want the opposite? The pair O and H lives in SOH, so use sine.

Complementary angles swap sine and cosine: $\sin \theta = \cos(90^\circ - \theta)$. So $\sin 25^\circ = \cos 65^\circ$ with zero computation. "Cosine" literally means "sine of the complement", and CETs test this as a one-liner.

Keep the Pythagorean triples hot: $3$-$4$-$5$, $5$-$12$-$13$, $8$-$15$-$17$. Almost every "find the third side first" ratio problem uses one of them.

## Traps to Watch For

### #1: Opposite and Adjacent Depend on the Angle

> Switch angles and the labels switch too.

The side that is opposite to one acute angle is adjacent to the other. If a problem computes ratios for both acute angles, relabel the triangle each time. Using one fixed labeling gives you the cofunction's value instead, which is planted in the choices.

### #2: The Hypotenuse Is Never Opposite or Adjacent

> The hypotenuse has one identity: across from the right angle.

Students sometimes call the hypotenuse "adjacent" because it touches $\theta$. It does touch, but it is reserved. The adjacent side is the other side touching $\theta$. Tangent, in particular, never involves the hypotenuse at all.

### #3: Flipping the Wrong Reciprocal

> Cosecant goes with sine, secant goes with cosine.

The names feel backwards: csc starts with c but flips sin, and sec starts with s but flips cos. Use the different-first-letter rule from the mnemonic. Mixing them turns $\csc \theta = \dfrac{5}{3}$ into $\dfrac{5}{4}$, and both appear in the choices.

### #4: Ratios Are Not Lengths

> $\sin \theta = \dfrac{3}{5}$ does not mean the sides are $3$ and $5$.

The sides could be $6$ and $10$, or $30$ and $50$. Only the ratio is fixed. When a problem gives one real length, find the scale factor first (like in Example $5$) before naming any side.

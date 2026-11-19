---
_id: "lesson-trigonometry-composing-trigonometric-functions"
title: "Composing Trigonometric Functions"
summary: "Evaluate a composition by finding the sides of a reference triangle."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 3
partCount: 3
ordering: 40
keyPoints:
  - "Evaluate a composition by finding the sides of a reference triangle."
  - "Use the domain and principal range to decide when inverse functions cancel."
---
## Core Concept

Useful problems in this topic include evaluating exact inverse values, respecting principal ranges, and simplifying compositions such as $\sin\left(\arccos \dfrac{3}{5}\right)$ by building a right triangle.

## Examples

### #1: Composition with a Triangle

Evaluate $\sin\left(\arccos \dfrac{3}{5}\right)$.

**Solution:**
Let $\theta = \arccos \dfrac{3}{5}$. Since the input is positive, $\theta$ is an acute principal angle. Build a right triangle whose cosine is $3/5$.

1. Cosine is adjacent over hypotenuse: adjacent $3$, hypotenuse $5$.
2. Find the opposite side with the Pythagorean theorem.

$$\text{opposite} = \sqrt{5^2 - 3^2} = \sqrt{16} = 4$$

3. Read the sine.

$$\sin \theta = \dfrac{4}{5}$$

4. Therefore:

$$\sin\left(\arccos \dfrac{3}{5}\right) = \dfrac{4}{5}$$

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ", "Adjacent = 3", "Hypotenuse = 5", "Opposite = 4", "90°"], "semanticsLabel": "Right triangle with angle theta, adjacent side 3, hypotenuse 5, and opposite side 4."} -->

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ = arccos(3/5)", "Adjacent = 3", "Hypotenuse = 5", "Opposite = 4", "sin θ = 4/5"], "semanticsLabel": "Right triangle for angle theta with adjacent side 3, hypotenuse 5, and opposite side 4 giving sine 4 fifths."} -->

### #2: Composition

Evaluate $\tan\left(\arcsin \dfrac{5}{13}\right)$.

**Solution:**
Let $\theta = \arcsin \dfrac{5}{13}$. The positive input gives an acute principal angle.

1. Sine is opposite over hypotenuse, so use opposite $5$ and hypotenuse $13$.
2. Find the adjacent side.

$$\text{adjacent} = \sqrt{13^2 - 5^2} = \sqrt{169 - 25} = \sqrt{144} = 12$$

3. Read the tangent.

$$\tan \theta = \dfrac{5}{12}$$

4. Therefore:

$$\tan\left(\arcsin \dfrac{5}{13}\right) = \dfrac{5}{12}$$

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ = arcsin(5/13)", "Opposite = 5", "Hypotenuse = 13", "Adjacent = 12", "tan θ = 5/12"], "semanticsLabel": "Right triangle for angle theta with opposite side 5, hypotenuse 13, and adjacent side 12 giving tangent 5 twelfths."} -->

## Speed Tricks & Shortcuts

For compositions such as $\sin(\arccos x)$ or $\tan(\arcsin x)$, a right triangle can avoid computing the angle explicitly. Use the inside function to label two sides, find the third side with the Pythagorean theorem, and then read the outside ratio. Keep the principal range in mind when the input can make the angle non-acute.

Same-function compositions cancel on the inverse function's input domain: $\sin(\arcsin x)=x$ for $x\in[-1,1]$. The reversed order needs more care: $\arcsin(\sin\theta)=\theta$ only when $\theta$ is already in arcsine's principal range.

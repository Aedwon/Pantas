---
_id: "lesson-trigonometry-special-angle-side-lengths"
title: "Special-Angle Side Lengths"
summary: "Find exact ratios for 30, 45, and 60 degrees."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 5
partCount: 6
ordering: 8
keyPoints:
  - "Find exact ratios for 30, 45, and 60 degrees."
  - "Use exact ratios to find a missing leg."
---
## Core Concept

Some angles come up often, so their ratios are worth knowing. Two triangles give all of them.

First, cut a square along its diagonal. This gives a $45$-$45$-$90$ triangle. Take both legs as $1$. The Pythagorean theorem gives the hypotenuse $\sqrt{1^2 + 1^2} = \sqrt{2}$. Then $\sin 45^\circ = \dfrac{1}{\sqrt{2}} = \dfrac{\sqrt{2}}{2}$. Multiplying top and bottom by $\sqrt{2}$ removes the root from the bottom.

Second, cut an equilateral triangle with side $2$ down the middle. This gives a $30$-$60$-$90$ triangle. The short leg is $1$, the hypotenuse is $2$, and the long leg is $\sqrt{2^2 - 1^2} = \sqrt{3}$. The short leg is across the $30^\circ$ angle. The long leg is across the $60^\circ$ angle.

<!-- ILLUSTRATION: Two triangles side by side. Left: a 45-45-90 triangle with both legs labeled 1 and the hypotenuse labeled √2. Right: a 30-60-90 triangle with the short leg labeled 1 (across 30°), the long leg labeled √3 (across 60°), and the hypotenuse labeled 2. -->

Reading the ratios from these two triangles gives the values to memorize:

- $\sin 30^\circ = \dfrac{1}{2}$, $\cos 30^\circ = \dfrac{\sqrt{3}}{2}$, $\tan 30^\circ = \dfrac{1}{\sqrt{3}} = \dfrac{\sqrt{3}}{3}$
- $\sin 45^\circ = \dfrac{\sqrt{2}}{2}$, $\cos 45^\circ = \dfrac{\sqrt{2}}{2}$, $\tan 45^\circ = 1$
- $\sin 60^\circ = \dfrac{\sqrt{3}}{2}$, $\cos 60^\circ = \dfrac{1}{2}$, $\tan 60^\circ = \sqrt{3}$

## Mnemonics & Memory Aids

For the special values of sine, the numerators of $30^\circ$, $45^\circ$, $60^\circ$ read $\sqrt{1}$, $\sqrt{2}$, $\sqrt{3}$ over $2$. Cosine reads the same list backward.

## Examples

### #1: Finding a Missing Side

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

### #2: Finding a Missing Side with Tangent

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

## Speed Tricks & Shortcuts

Two shapes give quick answers. In a $30$-$60$-$90$ triangle, the sides are in the ratio $1 : \sqrt{3} : 2$, from short leg to long leg to hypotenuse. In a $45$-$45$-$90$ triangle, the sides are in the ratio $1 : 1 : \sqrt{2}$.

## Traps to Watch For

### #1: Special Values Belong to Their Own Angles

> Do not carry a value from one special angle to another.

Sine is not proportional to the angle. Although $\sin 30^\circ = \dfrac{1}{2}$, the value of $\sin 60^\circ$ is not $1$ but $\dfrac{\sqrt{3}}{2}$. Likewise $\tan 45^\circ = 1$ only at $45^\circ$. Check which angle the question gives before you substitute.

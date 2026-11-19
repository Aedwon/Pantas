---
_id: "lesson-trigonometry-law-of-sines-with-two-angles"
title: "Law of Sines With Two Angles"
summary: "Use matched pairs in AAS and ASA problems."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 2
partCount: 7
ordering: 32
keyPoints:
  - "Use matched pairs in AAS and ASA problems."
  - "Find the missing angle from the angle sum."
---
## Core Concept

### The Law of Sines

In any triangle, each side divided by the sine of its own opposite angle gives the same number:

$$\dfrac{a}{\sin A} = \dfrac{b}{\sin B} = \dfrac{c}{\sin C}$$

Use two of the three fractions at a time. To use it, you need one complete matched pair. You also need one more side or angle.

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

## Traps to Watch For

### #1: Mismatched Pairs in the Law of Sines

> Each fraction must hold a side and its own opposite angle.

Writing $\dfrac{a}{\sin B}$ scrambles the proportion. Before you compute, point at the triangle. Find side $a$, then the angle across from it, and only then write the fraction. Mislabeling is a common cause of wrong Law of Sines answers.

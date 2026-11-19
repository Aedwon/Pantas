---
_id: "lesson-trigonometry-ambiguous-triangles-from-sine"
title: "Ambiguous Triangles From Sine"
summary: "Use the sine of the missing angle to test possible triangles."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 6
partCount: 7
ordering: 0
keyPoints:
  - "Use the sine of the missing angle to test possible triangles."
---
## Core Concept

### The ambiguous case (SSA)

Ambiguous means it can be read in more than one way. In SSA, the numbers may fit zero, one or two triangles. Say you know angle $A$, the side $a$ opposite it, and another side $b$.

1. Find $\sin B = \dfrac{b \sin A}{a}$.
2. If this is more than $1$, no triangle exists. A sine is never more than $1$.
3. If it equals $1$, then $B = 90^\circ$. One triangle exists if $A$ is acute. If $A$ is $90^\circ$ or more, $A + B$ is at least $180^\circ$, so no triangle exists.
4. If it is less than $1$, the calculator gives an acute angle $B_1$. A second angle $B_2 = 180^\circ - B_1$ has the same sine.
5. Keep $B_1$ or $B_2$ only if $A$ plus that angle is less than $180^\circ$. Each angle that stays gives one triangle.

## Examples

### #1: SSA With Two Triangles

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

### #2: SSA With One Triangle

Angle $A = 45^\circ$, side $a = 2$, and side $b = \sqrt{2}$. How many triangles exist? Find angle $B$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "triangle", "labels": ["A = 45°","a = 2","b = √2","B = ?"], "semanticsLabel": "Triangle ABC with angle A equal to 45 degrees, side a equal to 2, side b equal to root 2, and angle B marked with a question mark."} -->

**Solution:**
1. Find $\sin B$.

$$\sin B = \dfrac{\sqrt{2} \times \frac{\sqrt{2}}{2}}{2} = \dfrac{1}{2}$$

2. Two angles have this sine: $B_1 = 30^\circ$ and $B_2 = 150^\circ$.
3. Test the second angle: $45^\circ + 150^\circ = 195^\circ$. This is more than $180^\circ$, so $B_2$ is rejected.
4. Only $B = 30^\circ$ stays, so one triangle exists. Then $C = 105^\circ$.
5. Check with the side rule: $a = 2$ is longer than $b = \sqrt{2}$, so one triangle is right.

## Traps to Watch For

### #1: The Ambiguous Case (SSA)

> Two sides and a non-included angle can build two different triangles.

The Law of Sines gives $\sin B$, and two angles can share it: $B$ and $180^\circ - B$. Keep each one only if its sum with $A$ is less than $180^\circ$. A question may ask how many triangles are possible. The answer can be $0$, $1$ or $2$, so check before you assume one.

---
_id: "lesson-trigonometry-law-of-sines-surveys"
title: "Law of Sines in Surveys"
summary: "Find missing sides from two measured angles."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 3
partCount: 7
ordering: 33
keyPoints:
  - "Find missing sides from two measured angles."
---
## Core Concept

After you find the third angle, pair each known or unknown side with the angle across from it.

## Examples

### #1: Law of Sines (ASA)

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

### #2: Across a River (Exam Level)

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

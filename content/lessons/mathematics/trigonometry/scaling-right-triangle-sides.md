---
_id: "lesson-trigonometry-scaling-right-triangle-sides"
title: "Scaling Right Triangle Sides"
summary: "Solve for a missing side using a trigonometric ratio."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 6
partCount: 6
ordering: 9
keyPoints:
  - "Solve for a missing side using a trigonometric ratio."
  - "Scale the triangle sides using a given ratio and length."
---
## Core Concept

A ratio gives the shape of a right triangle, and a known length gives its scale. In the shortcut and trap below, Examples 5 and 8 refer to Examples 1 and 2 here.

## Examples

### #1: Finding a Missing Hypotenuse

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

### #2: Exam-Level Combination

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

## Traps to Watch For

### #1: Ratios Are Not Lengths

> $\sin \theta = \dfrac{3}{5}$ does not mean the sides are $3$ and $5$.

The sides could be $6$ and $10$, or $30$ and $50$. Only the ratio is fixed. When a problem gives one real length, find the scale factor first (like in Example $8$) before naming any side.

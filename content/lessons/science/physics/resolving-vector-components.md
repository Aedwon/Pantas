---
_id: "lesson-physics-resolving-vector-components"
title: "Resolving Vector Components"
summary: "Use right-triangle ratios to find the signed components of a vector."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 5
partCount: 6
ordering: 12
keyPoints:
  - "Find signed components from the magnitude and angle."
  - "Choose the right ratio for an angle measured from either axis."
---
## Core Concept

### Sine, Cosine, and Tangent

Take a right triangle and one of its acute angles, $\theta$. The **hypotenuse** is the longest side, across from the right angle. The **opposite** side faces $\theta$. The **adjacent** side touches $\theta$ and is not the hypotenuse.

$$\sin\theta=\dfrac{\text{opposite}}{\text{hypotenuse}},$$

$$\cos\theta=\dfrac{\text{adjacent}}{\text{hypotenuse}},$$

$$\tan\theta=\dfrac{\text{opposite}}{\text{adjacent}}.$$

The **inverse tangent**, written $\tan^{-1}$, goes the other way. If $\tan\theta=k$, then $\theta=\tan^{-1}k$. Set the calculator to degrees.

### Resolving a Vector into Components

The **components** of a vector are two perpendicular vectors that add up to it. Usually they lie along the $x$-axis (horizontal) and the $y$-axis (vertical). Finding them is called **resolving** the vector.

Suppose a vector of magnitude $V$ points at angle $\theta$, measured counterclockwise from the positive $x$-axis. Then

$$V_x=V\cos\theta,\qquad V_y=V\sin\theta.$$

These formulas also work for an angle from $0^\circ$ to $360^\circ$, and the signs come out correctly by themselves. Why: for an angle $\theta$ over $90^\circ$, $V\cos\theta$ is the horizontal part of the arrow. An arrow that points left has a negative horizontal part, so its cosine is negative. For example, at $150^\circ$ the arrow points up and to the left, so $\cos150^\circ=-\cos30^\circ$ and $\sin150^\circ=+\sin30^\circ$. The full unit-circle method is in the lesson The Unit Circle (Exact Values of Standard Angles). If the angle is measured from another line, such as the vertical, draw the right triangle and use opposite and adjacent sides again.

## Examples

### #1: Components

A $10\,\mathrm N$ force acts $30^\circ$ above the positive horizontal axis. Find its horizontal and vertical components.

**Solution:**

1. The angle is measured from the positive $x$-axis, so use the component formulas:

$$F_x=10\cos30^\circ=5\sqrt3\approx 8.66\,\mathrm N.$$

2. For the vertical component:

$$F_y=10\sin30^\circ=5\,\mathrm N.$$

Both components are positive because the vector lies in quadrant I. As a check, $\sqrt{8.66^2+5^2}=10$.

<!-- FIGURE: {"kind": "concept-diagram", "type": "vector-components", "magnitude": 10, "angle": 30, "unit": "N", "components": {"horizontal": "10 cos 30°", "vertical": "10 sin 30°"}, "semanticsLabel": "A 10 N force vector at 30 degrees above the horizontal resolved into horizontal and vertical components."} -->

### #2: Angle Measured from the Vertical

A rope pulls a crate with a force of $50\,\mathrm N$. The rope makes an angle of $40^\circ$ with the vertical, and the pull is upward and to the right. Find the horizontal and vertical components.

**Solution:**

1. Draw the right triangle. The angle $40^\circ$ is at the vertical side. So the vertical component is the adjacent side, and the horizontal component is the opposite side.
2. Horizontal component:

$$F_x=50\sin40^\circ\approx 32.1\,\mathrm N.$$

3. Vertical component:

$$F_y=50\cos40^\circ\approx 38.3\,\mathrm N.$$

Here the formulas are swapped compared with Example #6, because the angle is measured from the vertical.

<!-- ILLUSTRATION: a 50 N arrow pointing up and to the right, a vertical dashed line from its tail with the 40 degree angle between the dashed line and the arrow labeled, and the horizontal component 50 sin 40 and vertical component 50 cos 40 marked -->

## Traps to Watch For

### #1: Using Cosine for the Horizontal Component Every Time

> $V_x=V\cos\theta$ holds when $\theta$ is measured from the positive $x$-axis.

If the angle is measured from the vertical, the sine and cosine swap, as in Example #7. Draw the triangle and name the opposite and adjacent sides.

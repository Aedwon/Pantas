---
_id: "lesson-trigonometry-finding-acute-angles"
title: "Finding Acute Angles"
summary: "Use an exact ratio to find an acute angle."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 2
partCount: 6
ordering: 26
keyPoints:
  - "Use an exact ratio to find an acute angle."
  - "Use an inverse function in degree mode."
---
## Core Concept

**Finding an angle.** Use an inverse function when you know two sides and want the angle. The inverse sine, written $\sin^{-1}$, undoes the sine: if $\sin\theta=0.6$, then $\theta=\sin^{-1}(0.6)$. The inverse cosine $\cos^{-1}$ and inverse tangent $\tan^{-1}$ work the same way. Put your calculator in degree mode first. In a right triangle the other angles are acute, so the calculator's answer is the angle you want.

If the ratio is an exact value from that list, you can read the angle without a calculator. For other ratios, such as $\tan\theta=0.375$, use the calculator. Round only at the last step.

## Examples

### #1: Finding the Angle

A $10$-meter ladder leans against a vertical wall, with its foot $5$ meters from the wall. What angle does the ladder make with the horizontal ground?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["Ladder = 10 m", "Ground distance = 5 m", "Angle with ground = ?", "90°"], "semanticsLabel": "Right triangle showing 10 meter ladder against wall with foot 5 meters from base and ground angle marked with a question mark."} -->


**Solution:**
The ladder is the hypotenuse and the ground distance is adjacent to the wanted angle, so use cosine.

1. Set up the ratio.

$$\cos\theta=\dfrac{5}{10}=\dfrac12$$

2. The list gives the angle with cosine $\dfrac12$.

$$\theta=\cos^{-1}\left(\dfrac12\right)=60^\circ$$

3. The ladder makes a $60^\circ$ angle with the ground.

### #2: An Angle That Is Not a Special Angle

A ramp rises $3$ meters over a horizontal distance of $8$ meters. What angle does the ramp make with the ground? Give the answer to the nearest tenth of a degree.

<!-- ILLUSTRATION: A right triangle that models a ramp. The vertical side is labeled "Rise = 3 m", the horizontal side is labeled "Horizontal distance = 8 m", and the angle between the ramp and the ground is labeled "Angle = ?". -->

**Solution:**
The rise is opposite the wanted angle and the horizontal distance is adjacent, so use tangent.

1. Set up the ratio.

$$\tan\theta=\dfrac38=0.375$$

2. The value $0.375$ is not in the list of exact values, so use the inverse tangent on a calculator in degree mode.

$$\theta=\tan^{-1}(0.375)\approx20.6^\circ$$

3. The ramp makes an angle of about $20.6^\circ$ with the ground.

4. Check: $\tan20.6^\circ\approx0.376$, which is close to $\dfrac38$.

## Traps to Watch For

### #1: Wrong Calculator Mode

> An angle in degrees needs the calculator in degree mode.

In radian mode, $\tan35$ gives about $0.47$ instead of $0.70$, so every answer is wrong. Check the mode before you start, and test it with $\tan45$, which must give $1$ in degree mode.

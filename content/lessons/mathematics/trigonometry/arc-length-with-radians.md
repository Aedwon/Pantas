---
_id: "lesson-trigonometry-arc-length-with-radians"
title: "Arc Length With Radians"
summary: "Use a radius and a radian angle to find arc length or work backward."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 3
partCount: 3
ordering: 0
keyPoints:
  - "Use a radius and a radian angle to find arc length or work backward."
---
## Core Concept

Radians also give the cleanest arc length formula. For a central angle $\theta$ in radians and radius $r$:

$$s = r\theta$$

If you know the arc length and the radius, divide the arc length by the radius to find the angle in radians.

## Examples

### #1: Arc Length

A circle has a radius of $10$ cm. Find the length of the arc cut off by a central angle of $\dfrac{\pi}{5}$ radians. Then find the arc for a $72^\circ$ central angle.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "circle-arc", "labels": ["r = 10 cm", "θ = π/5 rad (72°)", "Arc s = rθ = 2π cm"], "semanticsLabel": "Circle of radius 10 cm with highlighted arc for central angle of pi over 5 radians or 72 degrees."} -->


**Solution:**
Use $s = r\theta$, but $\theta$ must be in radians.

1. First arc: the angle is already in radians.

$$s = 10 \times \dfrac{\pi}{5} = 2\pi \text{ cm}$$

2. Second arc: convert $72^\circ$ first. Simplify $\dfrac{72}{180} = \dfrac{2}{5}$.

$$72^\circ = \dfrac{2\pi}{5}$$

3. Now apply the formula.

$$s = 10 \times \dfrac{2\pi}{5} = 4\pi \text{ cm}$$

4. The arcs are $2\pi$ cm and $4\pi$ cm. Notice both angles gave clean answers because radians and $s = r\theta$ fit together perfectly.

## Traps to Watch For

### #1: Degrees Inside $s = r\theta$

> The arc length formula only accepts radians.

Plugging $72^\circ$ straight into $s = r\theta$ gives $720$, a nonsense arc for a circle of radius $10$. Convert to radians first, every time. Test-makers pick angle values that produce believable-looking wrong answers.

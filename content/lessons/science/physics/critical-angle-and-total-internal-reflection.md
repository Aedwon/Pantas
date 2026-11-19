---
_id: "lesson-physics-critical-angle-and-total-internal-reflection"
title: "Critical Angle and Total Internal Reflection"
summary: "Find the critical angle and check whether a ray stays inside a material."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 4
partCount: 5
ordering: 92
keyPoints:
  - "Find the critical angle and identify when total internal reflection occurs."
---
## Core Concept

At a real boundary, part of the light usually reflects and part refracts at the same time.

### Critical Angle and Total Internal Reflection

Take light going from a higher-$n$ medium to a lower-$n$ medium, such as glass to air. It bends away from the normal. If you raise the angle of incidence, the refracted ray leans over more and more.

At one special angle, the refracted ray skims along the boundary at $90^\circ$. This is the **critical angle** $\theta_c$. Put $\theta_2=90^\circ$ in Snell's law:

$$\sin\theta_c=\dfrac{n_2}{n_1}$$

If the angle of incidence is bigger than $\theta_c$, no light passes out. All of it reflects back into the first medium by the law of reflection. This is **total internal reflection**.

Two conditions must both hold. The light must start in the medium with the larger $n$ ($n_1>n_2$), and the angle of incidence must be bigger than $\theta_c$. If $n_1<n_2$, there is no critical angle, because the sine in the formula would be bigger than $1$.

Total internal reflection is how an optical fiber works. Light stays inside the glass core because the core has a higher $n$ than the layer around it, and the light hits the wall at large angles.

<!-- ILLUSTRATION: three ray diagrams of a ray going from glass (n = 1.50) up into air at a flat boundary with a normal line: incidence 30 degrees refracts away from the normal with a weak reflected ray, incidence 41.8 degrees refracts along the boundary, incidence 50 degrees reflects fully with equal angles -->

## Examples

### #1: Critical Angle and Total Internal Reflection

A ray inside glass ($n=1.50$) travels toward a glass-air boundary at an angle of incidence of $45^\circ$. Will it leave the glass?

<!-- ILLUSTRATION: ray in glass (n = 1.50) hitting the glass-air (n = 1.00) boundary at 45 degrees from the normal, normal drawn, what happens to the ray at the boundary marked with a question mark -->

**Solution:**

1. The light goes from the larger $n$ to the smaller $n$, so a critical angle exists. Find it:

$$\sin\theta_c=\dfrac{n_2}{n_1}=\dfrac{1.00}{1.50}=0.667$$

2. Take the inverse sine:

$$\theta_c=\sin^{-1}(0.667)\approx41.8^\circ$$

3. Compare: $45^\circ>41.8^\circ$. The light does not leave. It is totally reflected back into the glass at $45^\circ$ from the normal.

At $30^\circ$, which is below $41.8^\circ$, the light would leave into air, with a small reflected part.

## Speed Tricks & Shortcuts

For reflection, measure angles from the **normal**. If you are given the angle to the surface, subtract it from $90^\circ$.

In Snell's law, the medium with the larger $n$ has the smaller angle (when the ray is slanted).

For total internal reflection, check two things in order. First, is the light going into a smaller $n$? Then compare the angle of incidence with $\theta_c$. For a material in air, $\sin\theta_c=\dfrac{1}{n}$.

## Traps to Watch For

### #1: Using Total Internal Reflection From the Wrong Side

> Total internal reflection needs light going from larger $n$ to smaller $n$, and an angle above $\theta_c$.

Light going from air into glass never has a critical angle. Light in glass at an angle below $\theta_c$ leaves into air, but part of it also reflects. The reflected part grows as the angle nears $\theta_c$.

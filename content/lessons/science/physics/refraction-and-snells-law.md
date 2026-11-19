---
_id: "lesson-physics-refraction-and-snells-law"
title: "Refraction and Snell's Law"
summary: "Predict how a ray bends when it crosses a boundary."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 2
partCount: 5
ordering: 90
keyPoints:
  - "Predict the direction of a refracted ray."
  - "Find a refraction angle with Snell’s law."
---
## Core Concept

You will use the **sine** of an angle. For angles from $0^\circ$ to $90^\circ$, the sine is a number from $0$ to $1$, and a bigger angle has a bigger sine. To get an angle back from its sine, use the inverse sine key on a calculator, written $\sin^{-1}$.

### Refraction

**Refraction** is the bending of light, a change in its direction, as it passes from one medium into another. It is caused by the change in the speed of light at the boundary. If the ray meets the boundary at a slant, the change in speed turns the ray. A ray along the normal changes speed but does not bend. The **angle of incidence** and the **angle of refraction** are again measured from the normal.

The **index of refraction** $n$ of a material tells how much it slows light. Here $c$ is the speed of light in vacuum, about $3.00\times10^{8}$ m/s, and $v$ is the speed in the material.

$$n=\dfrac{c}{v}$$

**Snell's law** links the angles on the two sides. Medium $1$ is where the ray comes from. Medium $2$ is where it goes.

$$n_1\sin\theta_1=n_2\sin\theta_2$$

Use Snell's law to find the direction:

- If $n_2>n_1$, the light slows down and bends **toward the normal**.
- If $n_2<n_1$, the light speeds up and bends **away from the normal**.
- If $n_2=n_1$, or the ray travels along the normal ($\theta_1=0$), the direction does not change. The speed still changes if $n_2\ne n_1$.

## Examples

### #1: Bending Into a Slower Medium

A ray in air ($n=1.00$) strikes glass ($n=1.50$) at an angle of incidence of $30^\circ$. Find the angle of refraction.

<!-- ILLUSTRATION: ray going from air (n = 1.00) into glass (n = 1.50) at a flat boundary, normal drawn, incident angle 30 degrees in air, the angle in the glass marked with a question mark -->

**Solution:**

1. Write Snell's law and solve for $\sin\theta_2$:

$$\sin\theta_2=\dfrac{n_1\sin\theta_1}{n_2}=\dfrac{1.00\times\sin30^\circ}{1.50}$$

2. Put in $\sin30^\circ=0.5$:

$$\sin\theta_2=\dfrac{0.5}{1.50}=0.333$$

3. Take the inverse sine:

$$\theta_2=\sin^{-1}(0.333)\approx19.5^\circ$$

The ray bends toward the normal, as expected for entering a larger $n$.

### #2: Bending Into a Faster Medium

A ray in glass ($n=1.50$) meets a glass-air boundary at $20^\circ$ from the normal. Find the angle of refraction in air ($n=1.00$).

<!-- ILLUSTRATION: ray going from glass (n = 1.50) up into air (n = 1.00) at a flat boundary, normal drawn, incident angle 20 degrees in glass, the angle in the air marked with a question mark -->

**Solution:**

1. Solve Snell's law for $\sin\theta_2$:

$$\sin\theta_2=\dfrac{1.50\times\sin20^\circ}{1.00}$$

2. Put in $\sin20^\circ\approx0.342$:

$$\sin\theta_2\approx0.513$$

3. Take the inverse sine:

$$\theta_2\approx30.9^\circ$$

The ray bends away from the normal, as expected for entering a smaller $n$.

## Traps to Watch For

### #1: Saying Light Always Bends When It Enters a New Medium

> A ray changes direction only when it meets the boundary at a slant and the two $n$ values differ.

A ray along the normal keeps its direction but still changes speed and wavelength. The toward-normal and away-from-normal rules also apply only when the ray is slanted.

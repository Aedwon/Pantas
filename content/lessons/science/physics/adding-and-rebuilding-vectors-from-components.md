---
_id: "lesson-physics-adding-and-rebuilding-vectors-from-components"
title: "Adding and Rebuilding Vectors from Components"
summary: "Add components and find the resultant magnitude and direction."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 6
partCount: 6
ordering: 13
keyPoints:
  - "Add the separate horizontal and vertical components."
  - "Find magnitude and direction from the resultant components."
---
## Core Concept

### Adding Vectors by Components

This method works for any number of vectors in a plane.

1. Resolve each vector into $x$ and $y$ components.
2. Add all the $x$ components to get $R_x$. Add all the $y$ components to get $R_y$.
3. Rebuild the resultant from $R_x$ and $R_y$.

### Magnitude and Direction from Components

The components are perpendicular, so

$$R=\sqrt{R_x^2+R_y^2}.$$

If both components are nonzero, first find the acute angle $\alpha$ between the resultant and the $x$-axis:

$$\alpha=\tan^{-1}\!\left(\dfrac{|R_y|}{|R_x|}\right).$$

Then use the signs of $R_x$ and $R_y$ to find the **quadrant**. The quadrants are the four regions of the plane, numbered counterclockwise from the upper right. The angle from the positive $x$-axis, counterclockwise, is then:

- Quadrant I ($R_x>0$, $R_y>0$): $\theta=\alpha$.
- Quadrant II ($R_x<0$, $R_y>0$): $\theta=180^\circ-\alpha$.
- Quadrant III ($R_x<0$, $R_y<0$): $\theta=180^\circ+\alpha$.
- Quadrant IV ($R_x>0$, $R_y<0$): $\theta=360^\circ-\alpha$.

A calculator's $\tan^{-1}$ of the ratio $\dfrac{R_y}{R_x}$ gives an angle only between $-90^\circ$ and $90^\circ$. It cannot tell which quadrant the vector is in. That is why the signs must be checked.

If $R_x=0$, the ratio cannot be computed. The resultant points straight up (if $R_y>0$) or straight down (if $R_y<0$). If both components are $0$, the resultant is the zero vector and has no direction. If $R_y=0$, positive $R_x$ means right ($0^\circ$) and negative $R_x$ means left ($180^\circ$).

## Examples

### #1: Several Vectors and the Quadrant

A $20\,\mathrm N$ force acts at $150^\circ$ from the positive $x$-axis, measured counterclockwise. A $12\,\mathrm N$ force acts straight down. Find the magnitude and direction of the resultant.

**Solution:**

1. Resolve the $20\,\mathrm N$ force:

$$F_x=20\cos150^\circ\approx -17.32\,\mathrm N,\qquad F_y=20\sin150^\circ=10\,\mathrm N.$$

2. The $12\,\mathrm N$ force has components $0$ and $-12\,\mathrm N$.
3. Add the components:

$$R_x=-17.32+0=-17.32\,\mathrm N,\qquad R_y=10-12=-2\,\mathrm N.$$

4. Find the magnitude:

$$R=\sqrt{(-17.32)^2+(-2)^2}\approx 17.4\,\mathrm N.$$

5. Find the acute angle:

$$\alpha=\tan^{-1}\!\left(\dfrac{2}{17.32}\right)\approx 6.6^\circ.$$

6. Both components are negative, so the resultant is in quadrant III:

$$\theta=180^\circ+6.6^\circ=186.6^\circ.$$

The resultant is about $17.4\,\mathrm N$ at $186.6^\circ$ from the positive $x$-axis. That is $6.6^\circ$ below the negative $x$-axis. A calculator's $\tan^{-1}\!\left(\dfrac{-2}{-17.32}\right)$ would show only $6.6^\circ$, which points into quadrant I and is wrong.

<!-- ILLUSTRATION: x-y axes with a 20 N arrow at 150 degrees from the positive x-axis, a 12 N arrow pointing straight down, and the resultant of 17.4 N at 186.6 degrees in quadrant III with the 6.6 degree angle below the negative x-axis labeled -->

## Speed Tricks & Shortcuts

For vectors in a plane, the general method is components: resolve, add the $x$ components, add the $y$ components, then rebuild the magnitude and direction.

Before you trust an angle from $\tan^{-1}$, sketch the signs of $R_x$ and $R_y$. The sketch tells you the quadrant.

## Traps to Watch For

### #1: Trusting the Calculator Angle

> $\tan^{-1}$ returns an angle between $-90^\circ$ and $90^\circ$.

A vector in quadrant II or III needs a correction, as in Example #1. Check the signs of the components first, and then pick the quadrant.

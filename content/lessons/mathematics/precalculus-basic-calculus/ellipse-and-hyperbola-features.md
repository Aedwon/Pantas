---
_id: "lesson-precalculus-basic-calculus-ellipse-and-hyperbola-features"
title: "Ellipse and Hyperbola Features"
summary: "Use squared terms to read the axes and foci of ellipses and hyperbolas."
subject: "subject-mathematics"
topic: "topic-precalculus-basic-calculus"
isActive: true
part: 3
partCount: 3
ordering: 3
keyPoints:
  - "Find the axes and foci of an ellipse."
  - "Find the direction, foci, and asymptotes of a hyperbola."
---
## Core Concept

**Ellipse**, center $(h,k)$ and major/minor semi-axis lengths $a>b>0$:

Horizontal major axis:

$$\dfrac{(x-h)^2}{a^2}+\dfrac{(y-k)^2}{b^2}=1$$

Vertical major axis:

$$\dfrac{(x-h)^2}{b^2}+\dfrac{(y-k)^2}{a^2}=1$$

The larger denominator lies under the variable corresponding to the major-axis direction. The foci satisfy:

$$c^2=a^2-b^2$$

**Hyperbola**, center $(h,k)$:

Horizontal transverse axis:

$$\dfrac{(x-h)^2}{a^2}-\dfrac{(y-k)^2}{b^2}=1$$

Vertical transverse axis:

$$\dfrac{(y-k)^2}{a^2}-\dfrac{(x-h)^2}{b^2}=1$$

The positive squared term identifies the opening direction. For a horizontal hyperbola, the asymptotes are:

$$y-k=\pm\dfrac{b}{a}(x-h)$$

and the foci satisfy $c^2=a^2+b^2$.

## Examples

### #1: Features of an Ellipse

For $\dfrac{x^2}{25}+\dfrac{y^2}{9}=1$, find the vertices, major-axis length, and foci.

**Solution:**
The larger denominator is $25$, under $x^2$, so the major axis is horizontal.

1. $a=5$, $b=3$.
2. Vertices: $(-5,0)$ and $(5,0)$.
3. Major-axis length: $2a=10$.
4. Focal distance:

$$c^2=a^2-b^2=25-9=16$$

$$c=4$$

5. Foci: $(-4,0)$ and $(4,0)$.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "ellipse", "formula": "x^2/25 + y^2/9 = 1", "points": [[-5, 0], [5, 0], [0, -3], [0, 3], [-4, 0], [4, 0]], "semanticsLabel": "An ellipse centered at the origin with vertices at plus or minus 5, co-vertices at plus or minus 3, and foci at plus or minus 4."} -->

### #2: Features of a Hyperbola

For $\dfrac{x^2}{16}-\dfrac{y^2}{9}=1$, find the vertices and asymptotes.

**Solution:**
The positive term contains $x$, so the transverse axis is horizontal.

1. $a=4$, $b=3$.
2. Vertices: $(-4,0)$ and $(4,0)$.
3. Asymptotes:

$$y=\pm\dfrac{3}{4}x$$

<!-- FIGURE: {"kind": "coordinate-graph", "type": "hyperbola", "formula": "x^2/16 - y^2/9 = 1", "points": [[-4, 0], [4, 0]], "asymptoteSlopes": [0.75, -0.75], "semanticsLabel": "A hyperbola opening left and right with vertices at plus or minus 4 and dashed asymptotes through the origin."} -->

## Speed Tricks & Shortcuts

For an ellipse, with $a>b>0$, $c^2=a^2-b^2$. For a hyperbola, $c^2=a^2+b^2$.

## Traps to Watch For

### #1: Major Axis Direction

> In ellipse standard form, $a>b$ and the $a^2$ denominator lies along the major axis.

For $\dfrac{x^2}{9}+\dfrac{y^2}{25}=1$, rewrite the interpretation as the vertical-major-axis form: $a=5$ and the vertices are $(0,\pm5)$.

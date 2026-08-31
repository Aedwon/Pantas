---
_id: "lesson-precalculus-basic-calculus-conic-sections"
title: "Conic Sections (Circle, Parabola, Ellipse, Hyperbola)"
summary: "How to recognize common conic sections from standard equations and find their key features."
subject: "subject-mathematics"
topic: "topic-precalculus-basic-calculus"
estimatedMinutes: 14
isActive: true
---
## Core Concept

Intersecting a double cone with a plane can produce the familiar nondegenerate conic sections: a **circle**, **ellipse**, **parabola**, or **hyperbola**.

<!-- FIGURE: {"kind": "concept-diagram", "type": "conic-sections", "sections": ["circle", "ellipse", "parabola", "hyperbola"], "semanticsLabel": "A diagram of a double cone sliced four ways to produce a circle, an ellipse, a parabola, and a hyperbola."} -->

### Common axis-aligned standard forms

**Circle**, center $(h,k)$ and radius $r>0$:

$$(x-h)^2+(y-k)^2=r^2$$

**Parabola**, vertex $(h,k)$:

$$y=a(x-h)^2+k$$

opens vertically when $a\ne0$, while

$$x=a(y-k)^2+h$$

opens horizontally. A parabola has a vertex, not a center.

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

### Fast identification, with conditions

For a **nondegenerate, axis-aligned** quadratic equation with no $xy$ term, the squared-term pattern is useful:

- only one variable squared: parabola;
- both squared with equal nonzero coefficients and the same sign: circle after suitable normalization, if the equation represents a real nondegenerate circle;
- both squared with unequal coefficients and the same sign: ellipse after suitable normalization, if nondegenerate and real;
- squared coefficients with opposite signs: hyperbola.

A fully general quadratic may contain an $xy$ term, which can indicate a rotated conic, and some quadratic equations are degenerate (for example, a point, one or two lines, or no real graph). The quick coefficient test above is therefore intentionally limited to the axis-aligned nondegenerate cases taught in this lesson.

## Examples

### #1: Identifying Axis-Aligned Conics

Identify each conic: (a) $3x^2+3y^2=27$, (b) $y=2x^2-8x+1$, (c) $4x^2+9y^2=36$, (d) $x^2-y^2=16$.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "conic-gallery", "conics": ["circle", "parabola", "ellipse", "hyperbola"], "semanticsLabel": "A visual guide showing the four conic section curves: circle, parabola, ellipse, and hyperbola."} -->


**Solution:**
These equations have no $xy$ term and represent nondegenerate conics.

1. (a) Divide by $3$: $x^2+y^2=9$, a circle of radius $3$.
2. (b) Only $x$ is squared: a parabola opening upward because the quadratic coefficient is positive.
3. (c) Divide by $36$: $\dfrac{x^2}{9}+\dfrac{y^2}{4}=1$, an ellipse.
4. (d) Divide by $16$: $\dfrac{x^2}{16}-\dfrac{y^2}{16}=1$, a hyperbola.

### #2: Circle by Completing the Square

Find the center and radius of $x^2+y^2-6x+4y-12=0$.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "circle", "formula": "(x-3)^2 + (y+2)^2 = 25", "points": [[3, -2]], "radius": 5, "semanticsLabel": "A circle on a coordinate plane centered at (3, -2) with a radius of 5."} -->


**Solution:**
1. Group the variable terms and move the constant.

$$(x^2-6x)+(y^2+4y)=12$$

2. Add $9$ to complete the $x$ square and $4$ to complete the $y$ square, on both sides.

$$(x-3)^2+(y+2)^2=25$$

3. The center is $(3,-2)$ and the radius is $5$.

### #3: Vertex of a Parabola

Find the vertex of $y=x^2-6x+5$ and its direction of opening.

**Solution:**
1. The vertex's $x$-coordinate is:

$$x=-\dfrac{b}{2a}=-\dfrac{-6}{2}=3$$

2. Substitute $x=3$.

$$y=9-18+5=-4$$

3. The vertex is $(3,-4)$. Since the coefficient of $x^2$ is positive, the parabola opens upward.

### #4: Features of an Ellipse

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

### #5: Features of a Hyperbola

For $\dfrac{x^2}{16}-\dfrac{y^2}{9}=1$, find the vertices and asymptotes.

**Solution:**
The positive term contains $x$, so the transverse axis is horizontal.

1. $a=4$, $b=3$.
2. Vertices: $(-4,0)$ and $(4,0)$.
3. Asymptotes:

$$y=\pm\dfrac{3}{4}x$$

<!-- FIGURE: {"kind": "coordinate-graph", "type": "hyperbola", "formula": "x^2/16 - y^2/9 = 1", "points": [[-4, 0], [4, 0]], "asymptoteSlopes": [0.75, -0.75], "semanticsLabel": "A hyperbola opening left and right with vertices at plus or minus 4 and dashed asymptotes through the origin."} -->

## Speed Tricks & Shortcuts

For the axis-aligned nondegenerate equations used in this lesson, inspecting the squared terms is usually faster than completing squares merely to identify the conic. Keep the quick test within its scope: an $xy$ term or a degenerate equation needs additional analysis.

When completing a square for $x^2+Bx$, add $(B/2)^2$. If you add a quantity to one side of an equation, preserve equality by adding the same quantity to the other side.

For an ellipse, with $a>b>0$, $c^2=a^2-b^2$. For a hyperbola, $c^2=a^2+b^2$.

## Traps to Watch For

### #1: Radius vs. Radius Squared

> The right side of circle standard form is $r^2$.

From $(x-3)^2+(y+2)^2=25$, the radius is $5$, not $25$.

### #2: Reading the Center's Signs

> Standard form uses $(x-h)$ and $(y-k)$.

Thus $(x-3)^2+(y+2)^2$ has center $(3,-2)$.

### #3: Using the Coefficient Shortcut Outside Its Scope

> The simple same-sign/opposite-sign test assumes an axis-aligned, nondegenerate conic.

A general quadratic can include an $xy$ term and represent a rotated conic. Degenerate quadratics can instead represent lines, a point, or no real graph.

### #4: Major Axis Direction

> In ellipse standard form, $a>b$ and the $a^2$ denominator lies along the major axis.

For $\dfrac{x^2}{9}+\dfrac{y^2}{25}=1$, rewrite the interpretation as the vertical-major-axis form: $a=5$ and the vertices are $(0,\pm5)$.

---
_id: "lesson-precalculus-basic-calculus-circle-and-parabola-standard-forms"
title: "Circle and Parabola Standard Forms"
summary: "Use standard form to read features of circles and parabolas."
subject: "subject-mathematics"
topic: "topic-precalculus-basic-calculus"
isActive: true
part: 2
partCount: 3
ordering: 2
keyPoints:
  - "Find a circle\u2019s center and radius."
  - "Find a parabola\u2019s vertex and opening direction."
  - "Complete the square to find standard form."
---
## Core Concept

### Common axis-aligned standard forms

**Circle**, center $(h,k)$ and radius $r>0$:

$$(x-h)^2+(y-k)^2=r^2$$

**Parabola**, vertex $(h,k)$:

$$y=a(x-h)^2+k$$

opens vertically when $a\ne0$, while

$$x=a(y-k)^2+h$$

opens horizontally. A parabola has a vertex, not a center. For a horizontal parabola of the form $y^2=4px$ with $p\ne0$, the focus is $(p,0)$. The number $p$ tells how far to move from the vertex $(0,0)$ along the $x$-axis, right if positive and left if negative.

## Examples

### #1: Circle by Completing the Square

Find the center and radius of $x^2+y^2-6x+4y-12=0$.

**Solution:**
1. Group the variable terms and move the constant.

$$(x^2-6x)+(y^2+4y)=12$$

2. Add $9$ to complete the $x$ square and $4$ to complete the $y$ square, on both sides.

$$(x-3)^2+(y+2)^2=25$$

3. The center is $(3,-2)$ and the radius is $5$.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "circle", "formula": "(x-3)^2 + (y+2)^2 = 25", "points": [[3, -2]], "radius": 5, "semanticsLabel": "A circle on a coordinate plane centered at (3, -2) with a radius of 5."} -->

### #2: Vertex of a Parabola

Find the vertex of $y=x^2-6x+5$ and its direction of opening.

**Solution:**
1. The vertex's $x$-coordinate is:

$$x=-\dfrac{b}{2a}=-\dfrac{-6}{2}=3$$

2. Substitute $x=3$.

$$y=9-18+5=-4$$

3. The vertex is $(3,-4)$. Since the coefficient of $x^2$ is positive, the parabola opens upward.

## Speed Tricks & Shortcuts

When completing a square for $x^2+Bx$, add $(B/2)^2$. If you add a quantity to one side of an equation, preserve equality by adding the same quantity to the other side.

## Traps to Watch For

### #1: Radius vs. Radius Squared

> The right side of circle standard form is $r^2$.

From $(x-3)^2+(y+2)^2=25$, the radius is $5$, not $25$.

### #2: Reading the Center's Signs

> Standard form uses $(x-h)$ and $(y-k)$.

Thus $(x-3)^2+(y+2)^2$ has center $(3,-2)$.

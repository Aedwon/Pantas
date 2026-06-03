---
_id: "lesson-precalculus-basic-calculus-conic-sections"
title: "Conic Sections (Circle, Parabola, Ellipse, Hyperbola)"
summary: "How to recognize the four conic sections from their equations and find their key features."
subject: "subject-mathematics"
topic: "topic-precalculus-basic-calculus"
estimatedMinutes: 14
isActive: true
---
## Core Concept

Slice a cone with a flat blade and the cut edge draws one of four curves: a **circle**, an **ellipse**, a **parabola**, or a **hyperbola**. These are the conic sections.

<!-- ILLUSTRATION: double cone sliced four ways, horizontal cut giving a circle, tilted cut an ellipse, cut parallel to the side a parabola, vertical cut through both cones a hyperbola -->

Each has a standard equation centered at $(h, k)$:

**Circle** — all points at distance $r$ from the center:

$$(x - h)^2 + (y - k)^2 = r^2$$

**Parabola** — one squared variable only. The vertex form you know from quadratics, $y = a(x - h)^2 + k$, opens up or down; swapping roles, $x = a(y - k)^2 + h$, opens right or left.

**Ellipse** — a stretched circle, sums of both squared terms equal $1$:

$$\dfrac{(x - h)^2}{a^2} + \dfrac{(y - k)^2}{b^2} = 1$$

The larger denominator marks the **major axis** direction. Its half-length is $a$; the smaller half-length is $b$.

**Hyperbola** — like an ellipse but with a minus sign, giving two separate branches:

$$\dfrac{(x - h)^2}{a^2} - \dfrac{(y - k)^2}{b^2} = 1$$

The positive term tells which way it opens (this one opens left and right). Its branches hug two crossing **asymptote** lines.

Fast identification from a general equation $Ax^2 + By^2 + \ldots = C$: only one squared variable means parabola. Both squared with the same coefficient: circle. Same sign but different coefficients: ellipse. Opposite signs: hyperbola.

## Examples

### #1: Identifying the Conic

Identify each conic: (a) $3x^2 + 3y^2 = 27$, (b) $y = 2x^2 - 8x + 1$, (c) $4x^2 + 9y^2 = 36$, (d) $x^2 - y^2 = 16$.

<!-- ILLUSTRATION: the four conic shapes labeled — a circle, a parabola, an ellipse, and a hyperbola — for visual reference -->


**Solution:**
Apply the coefficient test.

1. (a) Both squared, equal coefficients ($3$ and $3$): a circle. Dividing by $3$ gives $x^2 + y^2 = 9$, radius $3$.
2. (b) Only $x$ is squared: a parabola, opening upward since $2$ is positive.
3. (c) Both squared, same sign, different coefficients ($4$ and $9$): an ellipse.
4. (d) Squared terms with opposite signs: a hyperbola.

### #2: Circle by Completing the Square

Find the center and radius of the circle $x^2 + y^2 - 6x + 4y - 12 = 0$.

<!-- ILLUSTRATION: a coordinate plane with a circle centered at (3, -2) and radius 5 drawn -->


**Solution:**
Group $x$ terms and $y$ terms, then complete each square.

1. Group and move the constant.

$$(x^2 - 6x) + (y^2 + 4y) = 12$$

2. Complete each square: half of $-6$ is $-3$, squared is $9$; half of $4$ is $2$, squared is $4$. Add both to both sides.

$$(x^2 - 6x + 9) + (y^2 + 4y + 4) = 12 + 9 + 4$$

3. Write as perfect squares.

$$(x - 3)^2 + (y + 2)^2 = 25$$

4. Center: $(3, -2)$. Radius: $\sqrt{25} = 5$.

### #3: Vertex of a Parabola

Find the vertex of the parabola $y = x^2 - 6x + 5$ and its direction of opening.

**Solution:**
Use the vertex formula on the quadratic.

1. The $x$-coordinate of the vertex.

$$x = \dfrac{-(-6)}{2(1)} = 3$$

2. Substitute back.

$$y = 3^2 - 6(3) + 5 = 9 - 18 + 5 = -4$$

3. The vertex is $(3, -4)$, and since the $x^2$ coefficient is positive, the parabola opens upward.

### #4: Features of an Ellipse

For the ellipse $\dfrac{x^2}{25} + \dfrac{y^2}{9} = 1$, find the vertices, the length of the major axis, and the foci.

**Solution:**
The bigger denominator sits under $x^2$, so the major axis is horizontal.

1. Read $a^2 = 25$ and $b^2 = 9$, so $a = 5$ and $b = 3$.
2. Vertices sit $a$ units left and right of the center $(0, 0)$: the points $(-5, 0)$ and $(5, 0)$.
3. The major axis length is $2a = 10$.
4. For the foci, use $c^2 = a^2 - b^2$.

$$c^2 = 25 - 9 = 16 \quad \Rightarrow \quad c = 4$$

5. The foci are $(-4, 0)$ and $(4, 0)$, on the major axis.

<!-- ILLUSTRATION: ellipse centered at origin, wider than tall, vertices at plus and minus 5 on the x-axis, co-vertices at plus and minus 3 on the y-axis, foci marked at plus and minus 4 -->

### #5: Features of a Hyperbola

For the hyperbola $\dfrac{x^2}{16} - \dfrac{y^2}{9} = 1$, find the vertices and the equations of the asymptotes.

**Solution:**
The positive term has $x$, so the branches open left and right.

1. Read $a^2 = 16$ and $b^2 = 9$: so $a = 4$ and $b = 3$.
2. Vertices sit $a$ units from the center along the opening direction: $(-4, 0)$ and $(4, 0)$.
3. The asymptotes of a left-right hyperbola centered at the origin are $y = \pm \dfrac{b}{a} x$.

$$y = \dfrac{3}{4}x \qquad y = -\dfrac{3}{4}x$$

<!-- ILLUSTRATION: hyperbola opening left and right with vertices at plus and minus 4, dashed asymptote lines through the origin with slopes 3/4 and -3/4 -->

## Speed Tricks & Shortcuts

For identification questions, you never need to complete any squares. Look only at the two squared terms: one squared is a parabola, equal coefficients a circle, same sign an ellipse, opposite signs a hyperbola. Five seconds per question.

Completing the square is always "half the middle coefficient, then square it" — and whatever you add inside, add to the other side too. Doing this smoothly is the whole skill for circle questions.

Remember which subtraction goes where: ellipse foci use $c^2 = a^2 - b^2$ (foci inside, so $c < a$), hyperbola foci use $c^2 = a^2 + b^2$ (foci beyond the vertices, so $c > a$). Inside is minus, outside is plus.

## Traps to Watch For

### #1: Radius or Radius Squared

> The circle equation shows $r^2$, not $r$.

From $(x - 3)^2 + (y + 2)^2 = 25$, the radius is $5$. Answering $25$ is the classic slip, and $25$ is always among the choices. The same trap runs in reverse: a circle with radius $7$ has equation ending in $= 49$.

### #2: Reading the Center's Signs Backwards

> $(x - 3)^2$ means $h = 3$; $(x + 3)^2$ means $h = -3$.

The standard form subtracts the center, so the sign you see is the opposite of the coordinate. A center of $(3, -2)$ comes from $(x - 3)^2$ and $(y + 2)^2$. Every choice list includes the sign-flipped center $( -3, 2)$.

### #3: Calling an Ellipse a Circle

> A circle needs equal coefficients on $x^2$ and $y^2$.

The equation $4x^2 + 9y^2 = 36$ is an ellipse, not a circle, because $4 \neq 9$. Divide through by $36$ and the different denominators ($9$ and $4$) confirm it. Only when the squared terms match exactly do you have a circle.

### #4: Major Axis in the Wrong Direction

> The larger denominator owns the major axis, wherever it sits.

In $\dfrac{x^2}{9} + \dfrac{y^2}{25} = 1$, the bigger number $25$ is under $y^2$, so the ellipse is tall, with vertices at $(0, \pm 5)$. Assuming the major axis is always horizontal flips the vertices and foci onto the wrong axis.

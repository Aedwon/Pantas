---
_id: "lesson-precalculus-basic-calculus-identifying-axis-aligned-conics"
title: "Identifying Axis-Aligned Conics"
summary: "Classify a conic by its squared terms when the shortcut applies."
subject: "subject-mathematics"
topic: "topic-precalculus-basic-calculus"
isActive: true
part: 1
partCount: 3
ordering: 1
keyPoints:
  - "Classify an axis-aligned conic by its squared terms."
  - "Check for degenerate cases and limits of the shortcut."
---
## Core Concept

Intersecting a double cone with a plane can produce the familiar nondegenerate conic sections: a **circle**, **ellipse**, **parabola**, or **hyperbola**.

<!-- FIGURE: {"kind": "concept-diagram", "type": "conic-sections", "sections": ["circle", "ellipse", "parabola", "hyperbola"], "semanticsLabel": "A diagram of a double cone sliced four ways to produce a circle, an ellipse, a parabola, and a hyperbola."} -->

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

## Speed Tricks & Shortcuts

For the axis-aligned nondegenerate equations used in this lesson, inspecting the squared terms is usually faster than completing squares merely to identify the conic. Keep the quick test within its scope: an $xy$ term or a degenerate equation needs additional analysis.

## Traps to Watch For

### #1: Using the Coefficient Shortcut Outside Its Scope

> The simple same-sign/opposite-sign test assumes an axis-aligned, nondegenerate conic.

A general quadratic can include an $xy$ term and represent a rotated conic. Degenerate quadratics can instead represent lines, a point, or no real graph.

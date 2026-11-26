---
_id: "lesson-spatial-abstract-reasoning-parallel-light-and-solid-shadows"
title: "Parallel Light and Solid Shadows"
summary: "Find the outline projected along parallel light rays."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
isActive: true
part: 3
partCount: 3
ordering: 17
keyPoints:
  - "Find the outline projected along parallel light rays."
---
## Core Concept

### Projections Along Parallel Light Rays

**Parallel rays** are light rays that travel in the exact same direction without spreading apart. A **projection** is the flat shadow outline cast onto a screen when parallel rays pass the solid.

To find the shadow on a screen at $90^\circ$ to the rays, look straight at the solid along the ray direction. The outer rim you see is the shadow shape. Painted marks do not change the shadow, and a hole appears in the shadow only when rays pass straight through it.

<!-- ILLUSTRATION: upright cone shown twice: left panel with vertical downward parallel rays casting a circle shadow on a horizontal floor; right panel with horizontal parallel rays casting an isosceles triangle shadow on a vertical wall -->

Test an upright **cone** resting on its round base in two ray directions:

1. Rays straight down from above: look down along the rays. The widest outer boundary is the circular base, so the shadow is a **circle**.
2. Rays horizontally from the side: look from the side along the rays. The outline narrows from the flat base to the pointed tip, so the shadow is a **triangle**.

Test an upright **cylinder** the same way: vertical rays along its axis cast a **circle**, while horizontal side rays cast a **rectangle**.

A nearby point light spreads rays outward from one spot, which stretches or changes the shadow. Keep the simple outline rule for parallel light only.

:::why
Why does a curved solid like a cylinder or cone cast a straight-edged shadow from the side? Parallel rays only record the widest outer boundary seen from that direction. From the side, a cone's rim forms two slanted straight lines and a flat base.
:::

:::pair #wrong-view-direction
Right: an upright cylinder under horizontal parallel light casts **a rectangle** on a vertical screen
Wrong: A circle
A circle is the top view seen along vertical rays, not the side view along horizontal rays. Always trace the direction the light travels before picking a shape.
:::

:::pair #base-shape-always
Right: shadows under parallel light show **the outline along the rays**, which changes with the ray direction
Wrong: They always retain the shape of the object's base.
The shadow matches the base only when light shines straight onto the base. Side rays show the solid's side profile instead.
:::

:::pair #slant-ellipse-error
Right: vertical parallel light on an upright cylinder casts **a circle** on a horizontal screen
Wrong: An ellipse
An oval shadow appears when the circular face or the screen is tilted to the rays. When vertical rays meet a horizontal screen at $90^\circ$, every diameter across the circle stays equal.
:::

:::check
A cube rests flat on a horizontal table while parallel light shines straight downward onto the table. What is the shape of its shadow?
:::answer
The answer is **a square**. Looking straight down along the vertical rays shows only the cube's square top face.
:::

## Examples

### #1: Cylinder, Parallel Light from Above

An upright cylinder receives parallel light straight downward onto a horizontal ground plane. What is its ideal shadow?

**Solution:**

1. Trace the ray direction: straight down along the cylinder's vertical axis.
2. Look straight down from above at the cylinder's widest outer boundary, which is its circular top and base.
3. Because the rays meet the horizontal ground at $90^\circ$, the circle does not stretch into an oval.

The projection is a **circle** with the same diameter as the cylinder.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "cylinder-shadow-above", "labels": ["Light from above", "Circular shadow"], "semanticsLabel": "An upright cylinder with light shining from above, casting a circular shadow on the ground."} -->

**Check:** Every cross-section of an upright cylinder from top to bottom is the same circle, so vertical rays project that exact circle.

### #2: Cylinder, Parallel Light from the Side

The same upright cylinder receives horizontal parallel light and casts a shadow onto a vertical wall perpendicular to the rays. What is its ideal shadow?

**Solution:**

1. Trace the ray direction: horizontal, across the cylinder's curved side.
2. Look horizontally at the outer boundary: two straight vertical edges on the left and right, plus flat top and bottom edges.
3. Measure its dimensions: the height equals the cylinder's height, and the width equals the cylinder's diameter.

The side projection is a **rectangle**.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "cylinder-shadow-side", "labels": ["Light from side", "Rectangular shadow"], "semanticsLabel": "An upright cylinder with light shining from the side, casting a rectangular shadow on the wall."} -->

**Check:** A cylinder has constant width from base to top, unlike a cone, so its side edges stay parallel and form a rectangle instead of a triangle.

### #3: Turning a Sphere Under Parallel Light

An opaque sphere is projected by parallel light onto a flat screen perpendicular to the rays. What happens to the shadow outline when the sphere turns in place?

<!-- ILLUSTRATION: opaque sphere between horizontal parallel light arrows on the left and a vertical screen on the right casting a circular shadow, with a curved turn arrow around the sphere -->

**Solution:**

1. Look at the sphere along the parallel rays before turning: every cross-section is a circle of the same radius, so the shadow is a **circle**.
2. Turn the sphere in place while keeping the screen perpendicular to the rays.
3. Check whether any flat face, corner, or narrower edge appears.

:::try
Finish the last step: state what happens to the shadow outline after the turn.
:::answer
The answer is **It stays a circle.** A sphere has the exact same circular width from every direction and has no flat faces or corners, so turning it never changes the shadow.

**Check:** Unlike a flat disk (which thins into a line when turned edge-on) or a cube (which can project a six-sided outline from a corner), a sphere looks identical from every angle.
:::

## Speed Tricks & Shortcuts

**Put your eye where the lamp sits.** Look straight toward the screen along the rays. The outer edge of the solid from that exact view is the shadow.

## Traps to Watch For

:::checklist
- Horizontal light on an upright cylinder or cone: use the side outline, not the circular top view. {#wrong-view-direction}
- Shadows from different ray angles: track the outline along the rays instead of keeping the base shape. {#base-shape-always}
- Rays hitting a circle at $90^\circ$ onto a flat screen: keep the shadow a true circle, not an ellipse. {#slant-ellipse-error}
:::

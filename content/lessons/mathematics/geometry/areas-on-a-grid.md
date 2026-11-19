---
_id: "lesson-geometry-areas-on-a-grid"
title: "Areas on a Grid"
summary: "Find areas by counting grid squares, splitting the shape, or subtracting from a rectangle."
subject: "subject-mathematics"
topic: "topic-geometry"
isActive: true
part: 2
partCount: 5
ordering: 50
keyPoints:
  - "Find areas by counting grid squares, splitting the shape, or subtracting from a rectangle."
---
## Core Concept

### Areas on a Grid

A **polygon** is a closed flat shape made of straight sides. On a square grid, count the little squares inside it. On a dot grid, imagine horizontal and vertical lines joining neighboring dots.

If neighboring lines or dots are $1$ unit apart, each small square has area $1$ square unit. Count full squares first. Join partial squares when their pieces make full squares. Two half-squares make $1$ square unit.

You can also split a polygon into rectangles and triangles. A rectangle with length $l$ and width $w$ has area:

$$A=lw$$

A triangle with base $b$ and height $h$ has area:

$$A=\dfrac{bh}{2}$$

The height meets the base at a right angle. Add the areas of pieces that cover the polygon without overlapping.

The **surrounding-rectangle method** works from the outside. Enclose the polygon in a rectangle. Find the areas inside that rectangle but outside the polygon, then subtract them:

$$A_{\text{polygon}}=A_{\text{rectangle}}-A_{\text{outside}}$$

## Examples

### #1: A Garden Plan on a Grid

A garden plan is drawn on a square grid with spacing of $1$ unit. Its bottom side is $6$ units long. Its left side rises straight up $2$ units. The top side runs $4$ units to the right, then a slanted side joins it to the bottom-right corner. Find the area in square units using three methods.

<!-- ILLUSTRATION: Unit square grid with polygon vertices at (0,0), (6,0), (4,2), and (0,2), joined in that order. Label bottom 6 units, left height 2 units, and top 4 units. Do not label any areas or shade counted pieces. -->

**Solution:**

1. Count full squares. The bottom row contains $5$ full squares. The top row contains $4$. Each row also has a half-square beside the slanted edge.

$$A=5+4+\dfrac{1}{2}+\dfrac{1}{2}$$

$$A=10\text{ square units}$$

2. Split the shape. Draw a vertical line down from the right end of the top side. It makes a rectangle $4$ units wide and $2$ units high. The remaining triangle has base $6-4=2$ units and height $2$ units.

$$A_{\text{rectangle}}=4\times2=8$$

$$A_{\text{triangle}}=\dfrac{2\times2}{2}=2$$

$$A=8+2=10\text{ square units}$$

3. Use a surrounding rectangle. Complete a rectangle $6$ units wide and $2$ units high. The missing upper-right triangle has base $2$ units and height $2$ units.

$$A_{\text{surrounding}}=6\times2=12$$

$$A_{\text{missing}}=\dfrac{2\times2}{2}=2$$

$$A=12-2=10\text{ square units}$$

The methods agree. To compare this garden with another grid shape, find that shape's area using the same grid spacing. Different outlines can enclose equal areas.

## Speed Tricks & Shortcuts

On a grid, count spaces between dots to measure a side. Use counting for small shapes. Split into rectangles and triangles when that gives fewer calculations. Use a surrounding rectangle when the missing pieces are simple.

## Traps to Watch For

### #1: Counting Dots as Area

> Count square spaces, not dots.

Dots show positions. They do not fill the polygon. A slanted boundary may cut through squares, so count those pieces by their areas.

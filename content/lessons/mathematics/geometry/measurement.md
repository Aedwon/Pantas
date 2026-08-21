---
_id: "lesson-geometry-measurement"
title: "Measurement"
summary: "The perimeter, area, surface area, and volume formulas for the figures that appear on every exam."
subject: "subject-mathematics"
topic: "topic-geometry"
estimatedMinutes: 15
isActive: true
---
## Core Concept

Measurement questions are formula questions. Know the formula, plug in carefully, and watch the units.

**Perimeter** is the distance around a flat figure, in plain units like cm. **Area** is the space inside, in square units like $\text{cm}^2$. **Volume** is the space a solid fills, in cubic units like $\text{cm}^3$. **Surface area** is the total area of all the outside faces of a solid.

### Perimeter and Area of 2D Figures

- **Square** with side $s$: perimeter $4s$, area $s^2$.
- **Rectangle** with length $l$ and width $w$: perimeter $2(l + w)$, area $lw$.
- **Triangle** with base $b$ and height $h$: area $\dfrac{1}{2}bh$. The height must be perpendicular to the base.
- **Parallelogram**: area $bh$. Again, $h$ is the straight-down height, not the slanted side.
- **Trapezoid** with parallel bases $b_1$ and $b_2$: area $\dfrac{1}{2}(b_1 + b_2)h$. Average the bases, times the height.
- **Circle** with radius $r$: circumference $2\pi r$, area $\pi r^2$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "shape-gallery", "labels": ["Square: s²", "Rectangle: lw", "Triangle: ½bh", "Parallelogram: bh", "Trapezoid: ½(b1+b2)h", "Circle: πr²"], "semanticsLabel": "Row of geometric shapes showing area formulas for square, rectangle, triangle, parallelogram, trapezoid, and circle."} -->

### Surface Area and Volume of 3D Solids

- **Cube** with edge $e$: volume $e^3$, surface area $6e^2$.
- **Rectangular prism** (box): volume $lwh$, surface area $2(lw + lh + wh)$.
- **Cylinder**: volume $\pi r^2 h$, surface area $2\pi r^2 + 2\pi r h$ (two lids plus the rolled-up label).
- **Cone**: volume $\dfrac{1}{3}\pi r^2 h$. A cone is one third of its cylinder.
- **Sphere**: volume $\dfrac{4}{3}\pi r^3$, surface area $4\pi r^2$.
- **Pyramid**: volume $\dfrac{1}{3} \times \text{base area} \times h$. Also one third of its prism.

The pattern to remember: pointy solids (cone, pyramid) take $\dfrac{1}{3}$ of their flat-topped partners.

## Examples

### #1: Rectangle from Its Perimeter

A rectangle has a perimeter of $26$ cm and a length of $8$ cm. Find its area.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "rectangle", "labels": ["Length = 8 cm", "Width = ?", "Perimeter = 26 cm"], "semanticsLabel": "Rectangle with length 8 cm, width marked with a question mark, and perimeter 26 cm."} -->


**Solution:**
Use the perimeter to find the missing width first.

1. Write the perimeter formula.

$$2(8 + w) = 26$$

2. Divide both sides by $2$.

$$8 + w = 13$$

3. Subtract $8$.

$$w = 5$$

4. Now compute the area.

$$A = 8 \times 5 = 40 \text{ cm}^2$$

5. The area is $40$ square centimeters. Note the two-step design: perimeter first, area second.

### #2: Area of a Trapezoid

A trapezoid has parallel bases of $8$ cm and $12$ cm and a height of $5$ cm. Find its area.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "trapezoid", "labels": ["b1 = 8 cm", "b2 = 12 cm", "h = 5 cm", "90°"], "semanticsLabel": "Trapezoid with parallel top base 8 cm, bottom base 12 cm, and height 5 cm marked with a right angle."} -->


**Solution:**
Average the two bases, then multiply by the height.

1. Add the bases.

$$8 + 12 = 20$$

2. Apply the formula.

$$A = \dfrac{1}{2}(20)(5)$$

3. Compute.

$$A = 10 \times 5 = 50 \text{ cm}^2$$

4. The area is $50$ square centimeters.

### #3: Shaded Region

A circle is inscribed in a square with side $10$, touching all four sides. Find the area of the region inside the square but outside the circle. Give the answer in terms of $\pi$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "inscribed-circle-square", "labels": ["Square side = 10", "Circle radius = 5", "Shaded corners"], "semanticsLabel": "Square with side length 10 containing an inscribed circle with shaded corner regions."} -->


**Solution:**
Shaded-region problems are subtraction problems: big area minus small area.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "inscribed-circle-square", "labels": ["Side = 10", "Radius = 5", "Shaded region = Area(square) - Area(circle)"], "semanticsLabel": "Square of side 10 and inscribed circle with shaded region between them."} -->

1. The square's area.

$$10^2 = 100$$

2. The circle touches all four sides, so its diameter equals the side: $d = 10$, which means $r = 5$.
3. The circle's area.

$$\pi (5)^2 = 25\pi$$

4. Subtract.

$$A = 100 - 25\pi$$

5. The shaded area is $100 - 25\pi$ square units, roughly $21.5$ if you estimate with $\pi \approx 3.14$.

### #4: Box Volume and Surface Area

A closed rectangular box measures $5$ cm by $4$ cm by $3$ cm. Find its volume and its total surface area.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "3d-box", "labels": ["Length = 5 cm", "Width = 4 cm", "Height = 3 cm"], "semanticsLabel": "Three-dimensional rectangular box with dimensions length 5 cm, width 4 cm, and height 3 cm."} -->


**Solution:**
Volume multiplies all three dimensions. Surface area adds the three different face areas, doubled.

1. Volume.

$$V = 5 \times 4 \times 3 = 60 \text{ cm}^3$$

2. The three face areas: $5 \times 4 = 20$, $5 \times 3 = 15$, and $4 \times 3 = 12$.
3. Each face has an identical twin on the opposite side.

$$SA = 2(20 + 15 + 12)$$

4. Compute.

$$SA = 2(47) = 94 \text{ cm}^2$$

5. Volume: $60$ cubic centimeters. Surface area: $94$ square centimeters.

### #5: Cylinder

A cylinder has a radius of $3$ cm and a height of $10$ cm. Find its volume and surface area in terms of $\pi$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "3d-cylinder", "labels": ["r = 3 cm", "h = 10 cm"], "semanticsLabel": "Three-dimensional cylinder with circular top radius 3 cm and height 10 cm."} -->


**Solution:**
Volume is the circular base times the height. Surface area is two lids plus the label.

1. Volume.

$$V = \pi (3)^2 (10) = 90\pi \text{ cm}^3$$

2. The two lids (circles).

$$2\pi (3)^2 = 18\pi$$

3. The label (a rolled-up rectangle: circumference times height).

$$2\pi (3)(10) = 60\pi$$

4. Add the parts.

$$SA = 18\pi + 60\pi = 78\pi \text{ cm}^2$$

### #6: Cone at Exam Level

A cone has a radius of $6$ cm and a height of $8$ cm. Find its volume in terms of $\pi$, and find its slant height.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "3d-cone", "labels": ["Radius r = 6 cm", "Height h = 8 cm", "Slant height l = ?", "90°"], "semanticsLabel": "Three-dimensional cone with base radius 6 cm, vertical height 8 cm, and slant height hypotenuse."} -->


**Solution:**
A cone is one third of a cylinder, and its slant height comes from the Pythagorean theorem.

1. Volume.

$$V = \dfrac{1}{3}\pi (6)^2 (8)$$

2. Compute step by step: $36 \times 8 = 288$, then divide by $3$.

$$V = 96\pi \text{ cm}^3$$

3. The radius, height, and slant height form a right triangle.

$$\ell^2 = 6^2 + 8^2 = 36 + 64 = 100$$

4. Take the square root.

$$\ell = 10$$

5. Volume: $96\pi$ cubic centimeters. Slant height: $10$ cm (the $6$-$8$-$10$ triple again).

## Speed Tricks & Shortcuts

If every side of a figure is scaled by $k$, the perimeter scales by $k$, the area scales by $k^2$, and the volume scales by $k^3$. Double a cube's edge and its volume becomes $8$ times bigger, not $2$ times. This single fact answers a whole family of CET questions instantly.

For shaded regions, do not hunt for a special formula. It is always whole minus hole: outer area minus inner area.

Estimate with $\pi \approx 3$ to eliminate answer choices fast. A circle of radius $5$ has area near $75$; any choice near $30$ or $300$ dies immediately.

## Traps to Watch For

### #1: Slant Side as Height

> Area formulas need the perpendicular height, never the slanted side.

In parallelograms, triangles, and trapezoids, test-makers label both the slant side and the true height. Using the slant gives a bigger, wrong area. The height is the one drawn with a right-angle mark, standing straight on the base.

### #2: Wrong Units of the Answer

> Perimeter is in cm, area in $\text{cm}^2$, volume in $\text{cm}^3$.

If a problem gives mixed units, like a length in meters and a width in centimeters, convert first, then multiply. And when choices differ only in units, the exponent on the unit tells you which formula they expect.

### #3: Diameter Given, Radius Needed

> Circle and cylinder formulas run on the radius.

A cylinder "with diameter $10$" has $r = 5$, and its base area is $25\pi$, not $100\pi$. This is the same trap as in the circles lesson, and it works just as often in 3D.

### #4: Forgetting the One Third

> Cones and pyramids are $\dfrac{1}{3}$ of the matching cylinder or prism.

Computing $\pi r^2 h$ for a cone gives an answer three times too big, and that answer is always among the choices. Pointy solid means divide by $3$.

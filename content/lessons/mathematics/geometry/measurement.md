---
_id: "lesson-geometry-measurement"
title: "Measurement"
summary: "Find perimeter, area, surface area, and volume, and use scale factors."
subject: "subject-mathematics"
topic: "topic-geometry"
estimatedMinutes: 15
isActive: true
---
## Core Concept

**Perimeter** is the distance around a flat figure. It uses length units, such as centimeters ($\text{cm}$). **Area** measures the space inside a flat figure in square units, such as $\text{cm}^2$.

**Volume** measures the space a solid fills in cubic units, such as $\text{cm}^3$. **Surface area** is the total area of the outside surfaces. It uses square units.

Use the same length unit for all dimensions before using a formula. For example, $1$ meter ($\text{m}$) equals $100$ centimeters. Choose a formula based on what the question asks you to measure.

### Perimeter and Area of Flat Figures

In these formulas, $P$ means perimeter and $A$ means area. A **base** is the side used with a matching height. The height $h$ is the perpendicular distance to that base, meeting it at a right angle ($90^\circ$).

- **Square**, side $s$: $P=4s$ and $A=s^2$.
- **Rectangle**, length $l$ and width $w$: $P=2(l+w)$ and $A=lw$.
- **Triangle**, base $b$ and height $h$: $A=\dfrac{1}{2}bh$.
- **Parallelogram**, base $b$ and height $h$: $A=bh$.
- **Trapezoid**, parallel bases $b_1$ and $b_2$: $A=\dfrac{1}{2}(b_1+b_2)h$.
- **Circle**, radius $r$: circumference $C=2\pi r$ and $A=\pi r^2$.

A slanted side is not the height unless it is perpendicular to the chosen base. The trapezoid's height is the perpendicular distance between its parallel bases.

A circle's **circumference** is its perimeter. Its **radius** runs from the center to the circle. The **diameter** $d$ runs across the center, so $d=2r$ and $r=\dfrac{d}{2}$.

The number $\pi$ is the ratio of a circle's circumference to its diameter. Use the value requested in the question. An answer "in terms of $\pi$" keeps $\pi$ in the answer instead of using a decimal.

<!-- ILLUSTRATION: Shape gallery showing square side s, rectangle length l and width w, triangle base b and perpendicular height h, parallelogram base b and perpendicular height h, trapezoid parallel bases b1 and b2 with perpendicular height h, and circle radius r; mark each perpendicular height with a right angle. -->

### Surface Area and Volume of Solids

Here, $V$ means volume and $SA$ means surface area. The height $h$ is perpendicular to the base. In a rectangular prism, $l$, $w$, and $h$ are length, width, and height.

- **Cube**, edge $e$: $V=e^3$ and $SA=6e^2$.
- **Rectangular prism**, or box: $V=lwh$ and $SA=2(lw+lh+wh)$.
- **Right circular cylinder**, radius $r$: $V=\pi r^2h$ and $SA=2\pi r^2+2\pi rh$.
- **Cone**, base radius $r$: $V=\dfrac{1}{3}\pi r^2h$.
- **Sphere**, radius $r$: $V=\dfrac{4}{3}\pi r^3$ and $SA=4\pi r^2$.
- **Pyramid**, base area $B$: $V=\dfrac{1}{3}Bh$.

A prism has matching parallel bases joined by flat side faces. A pyramid has a polygon base and triangular faces that meet at a point. A sphere is a ball-shaped solid whose surface is the same distance from its center in every direction.

A prism's volume is base area times height. A cylinder's volume also equals base area times height. Multiplying stacks the base area through the solid's height.

For a closed cylinder, surface area includes both circular ends. Unrolling its curved surface gives a rectangle with width $2\pi r$ and height $h$. Add that rectangle's area to the areas of both ends.

A cone has one third the volume of a cylinder with the same base radius and perpendicular height. A pyramid has one third the volume of a prism with the same base area and perpendicular height.

The **slant height** $\ell$ of a right circular cone runs along its surface from the tip to the base edge. In a right circular cone, the tip is directly above the base center. Its radius, perpendicular height, and slant height form a right triangle.

The **Pythagorean theorem** says that in a right triangle, the squares of the perpendicular sides add to the square of the longest side:

$$a^2+b^2=c^2$$

The longest side, $c$, is opposite the right angle. For the cone, this gives:

$$\ell^2=r^2+h^2$$

Take the positive square root to find the slant height. A length cannot be negative.

### Combined Regions and Scaling

When a smaller region lies fully inside a larger one, subtract to find the area outside the smaller region:

$$A_{\text{remaining}}=A_{\text{outer}}-A_{\text{inner}}$$

If a region is split into pieces that do not overlap, add their areas. If pieces overlap, do not count the shared area twice.

**Similar figures** have the same shape. Each length in one figure is multiplied by the same positive number to get its matching length in the other figure. Their sizes may differ.

A **scale factor** $k$ is the new length divided by its matching old length. These rules apply to similar figures when every length is multiplied by that same number $k$:

$$P_{\text{new}}=kP_{\text{old}}$$

$$A_{\text{new}}=k^2A_{\text{old}}$$

$$V_{\text{new}}=k^3V_{\text{old}}$$

Lengths have one factor of $k$. Area has two length dimensions, so it gets $k\times k=k^2$. Volume has three, so it gets $k\times k\times k=k^3$.

Surface area also scales by $k^2$. To work backward from an area ratio, take its positive square root. For a volume ratio, take its positive cube root.

## Examples

### #1: Rectangle from Its Perimeter

A rectangle has a perimeter of $26$ cm and a length of $8$ cm. Find its area.

<!-- ILLUSTRATION: Rectangle with length 8 cm, unknown width w, and perimeter 26 cm. -->

**Solution:**

1. Use the perimeter to find the width.

$$2(8+w)=26$$

2. Divide by $2$, then subtract $8$.

$$8+w=13$$

$$w=5\text{ cm}$$

3. Multiply length by width.

$$A=8\times5=40\text{ cm}^2$$

### #2: Choosing the Perpendicular Height

A parallelogram has a base of $12$ cm, a slanted side of $5$ cm, and a perpendicular height of $4$ cm. Find its area. A triangle has the same base and perpendicular height. Find its area too.

<!-- ILLUSTRATION: Parallelogram with horizontal base 12 cm, slanted side 5 cm, and dashed perpendicular height 4 cm with right-angle mark; beside it, triangle with base 12 cm and perpendicular height 4 cm. -->

**Solution:**

1. Use the perpendicular height, $4$ cm. The slanted side does not give the distance between the parallel bases.
2. Find the parallelogram's area.

$$A=12\times4=48\text{ cm}^2$$

3. A triangle with the same base and height has half that area.

$$A=\dfrac{1}{2}(12)(4)=24\text{ cm}^2$$

### #3: Area of a Trapezoid

A trapezoid has parallel bases of $8$ cm and $12$ cm and a perpendicular height of $5$ cm. Find its area.

<!-- ILLUSTRATION: Trapezoid with parallel top base 8 cm, bottom base 12 cm, and perpendicular height 5 cm marked with a right angle. -->

**Solution:**

1. Find the average base length.

$$\dfrac{8+12}{2}=10\text{ cm}$$

2. Multiply by the height.

$$A=10\times5=50\text{ cm}^2$$

### #4: Shaded Region

A circle is inscribed in a square with side $10$ cm, touching all its sides. Find the area inside the square but outside the circle. Give the answer in terms of $\pi$.

<!-- ILLUSTRATION: Square with side 10 cm and a circle touching all four sides; shade the four corner regions outside the circle. -->

**Solution:**

1. Find the square's area.

$$A_{\text{square}}=10^2=100\text{ cm}^2$$

2. The circle's diameter equals the square's side. Find the radius.

$$r=\dfrac{10}{2}=5\text{ cm}$$

3. Find the circle's area.

$$A_{\text{circle}}=\pi(5)^2=25\pi\text{ cm}^2$$

4. Subtract the circle's area from the square's area.

$$A=(100-25\pi)\text{ cm}^2$$

### #5: Adding Pieces with Mixed Units

An L-shaped floor consists of two rectangles that meet along an edge without overlapping. One measures $2$ m by $150$ cm. The other measures $1$ m by $1$ m. Find the total area in square meters.

<!-- ILLUSTRATION: L-shaped floor split into two nonoverlapping rectangles: first 2 m wide by 150 cm high, second 1 m by 1 m attached below the left half of the first; show the shared dividing edge. -->

**Solution:**

1. Convert the mixed length to meters.

$$150\text{ cm}=1.5\text{ m}$$

2. Find each area.

$$A_1=2(1.5)=3\text{ m}^2$$

$$A_2=1(1)=1\text{ m}^2$$

3. Add because the rectangles do not overlap.

$$A=3+1=4\text{ m}^2$$

### #6: Box Volume and Surface Area

A closed rectangular box measures $5$ cm by $4$ cm by $3$ cm. Find its volume and total surface area.

<!-- ILLUSTRATION: Closed rectangular box with length 5 cm, width 4 cm, and height 3 cm. -->

**Solution:**

1. Multiply the dimensions for volume.

$$V=5\times4\times3=60\text{ cm}^3$$

2. Find the three different face areas.

$$5\times4=20\text{ cm}^2$$

$$5\times3=15\text{ cm}^2$$

$$4\times3=12\text{ cm}^2$$

3. Each face has a matching opposite face. Double the sum.

$$SA=2(20+15+12)$$

$$SA=94\text{ cm}^2$$

### #7: Cylinder

A closed right circular cylinder has a radius of $3$ cm and a height of $10$ cm. Find its volume and surface area in terms of $\pi$.

<!-- ILLUSTRATION: Closed right circular cylinder with radius 3 cm marked from the center of the top circle and perpendicular height 10 cm. -->

**Solution:**

1. Multiply the base area by the height.

$$V=\pi(3)^2(10)=90\pi\text{ cm}^3$$

2. Find the area of both circular ends.

$$2\pi(3)^2=18\pi\text{ cm}^2$$

3. Find the curved surface area.

$$2\pi(3)(10)=60\pi\text{ cm}^2$$

4. Add the surface areas.

$$SA=18\pi+60\pi=78\pi\text{ cm}^2$$

### #8: Cone Volume and Slant Height

A right circular cone has a radius of $6$ cm and a perpendicular height of $8$ cm. Find its volume in terms of $\pi$ and its slant height.

<!-- ILLUSTRATION: Right circular cone with radius 6 cm, perpendicular height 8 cm from tip to base center, and unknown slant height ell from tip to base edge; mark the right angle between radius and height. -->

**Solution:**

1. Use the cone volume formula.

$$V=\dfrac{1}{3}\pi(6)^2(8)$$

$$V=96\pi\text{ cm}^3$$

2. The radius and height are perpendicular. The slant height is opposite the right angle.

$$\ell^2=6^2+8^2$$

$$\ell^2=36+64=100$$

3. Take the positive square root.

$$\ell=10\text{ cm}$$

### #9: Sphere

A sphere has a radius of $3$ cm. Find its volume and surface area in terms of $\pi$.

<!-- ILLUSTRATION: Sphere with center O and a radius from O to the surface labeled 3 cm. -->

**Solution:**

1. Cube the radius for volume.

$$V=\dfrac{4}{3}\pi(3)^3$$

$$V=\dfrac{4}{3}\pi(27)=36\pi\text{ cm}^3$$

2. Square the radius for surface area.

$$SA=4\pi(3)^2=36\pi\text{ cm}^2$$

The numerical coefficients match here, but the units measure different things.

### #10: Pyramid with a Rectangular Base

A pyramid has a rectangular base measuring $6$ cm by $4$ cm. Its perpendicular height is $9$ cm. Find its volume.

<!-- ILLUSTRATION: Pyramid with rectangular base 6 cm by 4 cm and dashed perpendicular height 9 cm from tip to base plane, marked with a right angle. -->

**Solution:**

1. Find the base area.

$$B=6\times4=24\text{ cm}^2$$

2. Multiply by height and divide by $3$.

$$V=\dfrac{1}{3}(24)(9)$$

$$V=72\text{ cm}^3$$

### #11: Scaling a Cube

A cube has an edge of $2$ cm. A larger cube has an edge of $6$ cm. Find the larger cube's volume and surface area.

<!-- ILLUSTRATION: Two cubes with corresponding edges labeled 2 cm and 6 cm. -->

**Solution:**

1. Find the smaller cube's volume and surface area.

$$V=2^3=8\text{ cm}^3$$

$$SA=6(2)^2=24\text{ cm}^2$$

2. Find the length scale factor.

$$k=\dfrac{6}{2}=3$$

3. Volume grows by $k^3$.

$$V_{\text{new}}=3^3(8)=216\text{ cm}^3$$

4. Surface area grows by $k^2$.

$$SA_{\text{new}}=3^2(24)=216\text{ cm}^2$$

### #12: Working Backward from Area

Two similar rectangles have areas of $20\text{ cm}^2$ and $180\text{ cm}^2$. The smaller rectangle has a perimeter of $18$ cm. Find the larger rectangle's perimeter.

<!-- ILLUSTRATION: Two similar rectangles with areas labeled 20 square centimeters and 180 square centimeters; label the smaller perimeter 18 cm and the larger perimeter unknown. -->

**Solution:**

1. The rectangles are similar, so all matching lengths have one scale factor. Their area ratio gives its square.

$$k^2=\dfrac{180}{20}=9$$

2. Take the positive square root.

$$k=3$$

3. Multiply the smaller perimeter by $k$.

$$P_{\text{new}}=3(18)=54\text{ cm}$$

## Speed Tricks & Shortcuts

If all lengths double, perimeter doubles, area becomes $4$ times as large, and volume becomes $8$ times as large. Check that all dimensions use the same scale factor before using these rules.

For a shaded region, decide what was shaded first. Subtract an inner region from an outer region when the inner one lies fully inside. Add separate shaded pieces when they do not overlap.

Use $\pi\approx3$ only for a rough size check. A circle with radius $5$ has area near $75$ square units. Use the requested value of $\pi$ for the final answer, especially when choices are close.

## Traps to Watch For

### #1: Slant Side as Height

> Area formulas use the height perpendicular to the chosen base.

A slanted side labeled $5$ cm does not replace a perpendicular height of $4$ cm. Look for the right-angle mark. A height may be drawn inside or outside a triangle.

### #2: Wrong Units of the Answer

> Length uses plain units, area uses square units, and volume uses cubic units.

Convert mixed length units before multiplying. A result in $\text{cm}^2$ is an area, while a result in $\text{cm}^3$ is a volume. Surface area also uses $\text{cm}^2$.

### #3: Diameter Given, Radius Needed

> Circle and cylinder formulas use the radius.

A cylinder with diameter $10$ cm has radius $5$ cm. Its base area is $25\pi\text{ cm}^2$. Using the diameter as the radius would give $100\pi\text{ cm}^2$.

### #4: Forgetting the One Third

> Match the base and perpendicular height before using the one-third comparison.

Using $\pi r^2h$ for a cone gives a volume $3$ times too large. Divide by $3$ for the cone. For a pyramid, divide base area times perpendicular height by $3$ too.

### #5: Using the Area Ratio as a Length Ratio

> Area ratios are squares of length ratios.

An area ratio of $9$ gives a length ratio of $3$, not $9$. A volume ratio of $8$ gives a length ratio of $2$. These rules require figures with the same shape and one scale factor for all lengths.

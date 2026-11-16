---
_id: "lesson-geometry-practical-measurement"
title: "Practical Measurement"
summary: "Find cube edges, grid areas, whole pieces, tile counts, turning distances, and space inside margins."
subject: "subject-mathematics"
topic: "topic-geometry"
estimatedMinutes: 15
isActive: true
---
## Core Concept

Measurement questions ask for a length, an area, a volume, or a count. **Area** is the space inside a flat shape. **Volume** is the space a solid fills. Read what the question asks before choosing a calculation.

### Cube Edges from Volume

A **cube** has equal edges. An edge is a straight side where two faces meet. If its edge length is $e$, its volume is:

$$V=e\times e\times e=e^3$$

To work backward, find the positive number that gives $V$ when multiplied by itself three times. This number is the **cube root** of $V$:

$$e=\sqrt[3]{V}$$

A **perfect cube** is the cube of a whole number. For a positive perfect-cube volume, try whole-number edges and check by multiplying. Volume uses cubic units, such as $\text{cm}^3$. The edge uses length units, such as centimeters.

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

### Whole Pieces and Floor Tiles

To cut equal rectangles from a sheet in rows, divide the sheet's length by the piece's length. Keep the whole-number part. Do the same for the widths, then multiply the counts:

$$N=(\text{pieces per row})(\text{rows})$$

Try turning the pieces so their length and width switch places. A partial piece does not count as a whole rectangle.

Dividing sheet area by piece area gives a limit on the number of whole pieces. It does not prove those pieces fit. To prove a maximum, show a layout that reaches the whole-number limit. Mixed directions may fit more than either simple row layout.

For a floor covered exactly by equal tiles, with no gaps or overlaps:

$$N=\dfrac{A_{\text{floor}}}{A_{\text{tile}}}$$

Convert lengths to the same unit before finding the areas. Since $1$ meter is $100$ centimeters, multiply meters by $100$ to get centimeters. Check that whole tiles fit along both sides if the question requires uncut tiles.

### Distance Around a Circle

The **circumference** is the distance around a circle. The **radius** $r$ runs from its center to its edge. The **diameter** $d$ runs across the center and equals $2r$.

$$C=2\pi r=\pi d$$

Here, $\pi$ is the ratio of circumference to diameter. Keep $\pi$ in the answer unless the question gives a value to use.

The tip of a turning hand traces a circle. The hand's length is the radius. A point on a wheel's edge also traces a circle when the wheel turns about a fixed center.

For steady turning, divide the elapsed time by the time for one full turn:

$$n=\dfrac{\text{elapsed time}}{\text{time per turn}}$$

Use the same time unit in that division. Multiply the circumference by the number of turns, including any fraction of a turn:

$$D=nC$$

### Space Inside Margins

A **margin** is an empty strip along an edge. For a rectangle of length $L$ and width $W$, an equal margin $m$ on each side leaves:

$$L_{\text{inside}}=L-2m$$

$$W_{\text{inside}}=W-2m$$

Subtract twice because there is a margin at each end of each dimension. Multiply the remaining lengths:

$$A_{\text{inside}}=(L-2m)(W-2m)$$

These formulas describe an inner rectangle when the margins leave positive length and width.

## Examples

### #1: Edge of a Cube-Shaped Box

A cube-shaped box has an inside volume of $216\text{ cm}^3$. What is the length of an inside edge?

**Solution:**

1. Find a number that gives $216$ when multiplied by itself three times. Try $5$ first.

$$5\times5\times5=125$$

2. That volume is too small. Try $6$.

$$6\times6\times6=216$$

3. The edge is the positive cube root of the volume.

$$e=\sqrt[3]{216}=6\text{ cm}$$

The answer is $6$ cm, not $6\text{ cm}^3$. We found a length.

### #2: A Garden Plan on a Grid

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

### #3: Labels Cut from a Sheet

A craft sheet measures $17$ cm by $6$ cm. Each rectangular label must measure $5$ cm by $3$ cm. What is the maximum number of whole labels that can be cut? Ignore the width of the cuts.

**Solution:**

1. Put the $5$ cm side along the sheet's $17$ cm side. Find the whole labels per row and the number of rows.

$$17\div5=3\text{ remainder }2$$

$$6\div3=2$$

$$N=3\times2=6$$

2. Turn the labels. Put their $3$ cm side along the sheet's $17$ cm side.

$$17\div3=5\text{ remainder }2$$

$$6\div5=1\text{ remainder }1$$

$$N=5\times1=5$$

3. Check whether any layout could fit more than $6$. Find the sheet area and label area.

$$A_{\text{sheet}}=17\times6=102\text{ cm}^2$$

$$A_{\text{label}}=5\times3=15\text{ cm}^2$$

$$102\div15=6.8$$

There is enough area for at most $6$ whole labels. The first layout fits $6$, so the maximum is $6$. The leftover strips cannot make another whole label.

### #4: Tiles for a Reading Room

A rectangular reading-room floor measures $6$ m by $4.5$ m. Square tiles have sides of $30$ cm. How many tiles cover the floor? Lay the tiles edge to edge with no gaps.

**Solution:**

1. Convert the floor dimensions to centimeters before multiplying.

$$6\text{ m}=6\times100=600\text{ cm}$$

$$4.5\text{ m}=4.5\times100=450\text{ cm}$$

2. Find the floor area and the area of one tile.

$$A_{\text{floor}}=600\times450=270{,}000\text{ cm}^2$$

$$A_{\text{tile}}=30\times30=900\text{ cm}^2$$

3. Divide the areas.

$$N=270{,}000\div900=300$$

4. Check that whole tiles fit along both sides.

$$600\div30=20$$

$$450\div30=15$$

$$20\times15=300$$

The floor needs $300$ tiles. No tiles need cutting for these dimensions.

### #5: A Turning Hand and a Wheel

A display has a hand $6$ cm long. It turns steadily about one fixed end, making one full turn in $60$ minutes. How far does its tip travel in $75$ minutes? Give the answer in terms of $\pi$.

**Solution:**

1. The radius is the hand's length. Find the distance for one turn.

$$C=2\pi(6)=12\pi\text{ cm}$$

2. Divide the elapsed time by the time for one turn.

$$n=\dfrac{75}{60}=\dfrac{5}{4}$$

3. Multiply by the number of turns.

$$D=12\pi\times\dfrac{5}{4}=15\pi\text{ cm}$$

The tip travels $15\pi$ cm. This includes the part of a turn after the first full turn.

Now a wheel with diameter $40$ cm turns about a fixed center. How far does a painted dot on its edge travel in $3$ full turns?

**Solution:**

1. Use the diameter to find the circumference.

$$C=\pi(40)=40\pi\text{ cm}$$

2. Multiply by the given turns.

$$D=3(40\pi)=120\pi\text{ cm}$$

The dot travels $120\pi$ cm along its circular path.

### #6: A Poster with Empty Margins

A poster sheet measures $24$ cm by $18$ cm. A margin $1.5$ cm wide must be left along each edge. Find the area available for the picture.

**Solution:**

1. Remove the margins at both ends of the longer dimension.

$$L_{\text{inside}}=24-2(1.5)=21\text{ cm}$$

2. Remove the margins at both ends of the shorter dimension.

$$W_{\text{inside}}=18-2(1.5)=15\text{ cm}$$

3. Multiply the inside dimensions.

$$A_{\text{inside}}=21\times15=315\text{ cm}^2$$

The picture can cover $315\text{ cm}^2$.

## Speed Tricks & Shortcuts

For a perfect-cube volume, test a likely edge by multiplying it three times. Dividing the volume by $3$ does not undo cubing.

On a grid, count spaces between dots to measure a side. Use counting for small shapes. Split into rectangles and triangles when that gives fewer calculations. Use a surrounding rectangle when the missing pieces are simple.

For whole rectangles, keep the whole-number part of each side count before multiplying. For a steadily turning hand, keep fractional turns because the tip travels during a partial turn too.

## Traps to Watch For

### #1: Counting Dots as Area

> Count square spaces, not dots.

Dots show positions. They do not fill the polygon. A slanted boundary may cut through squares, so count those pieces by their areas.

### #2: Using an Area Limit as a Layout

> Enough area does not prove whole rectangles fit.

Try both orientations and show where the pieces go. If neither row layout reaches the area limit, more checking is needed before calling a count the maximum.

### #3: Mixing Units

> Convert lengths before finding areas.

In the tile example, dividing the floor's area in square meters by a tile's area in square centimeters would mix different units. Converting first lets the area units match.

### #4: Removing One Margin per Dimension

> Each dimension loses a margin at both ends.

Subtracting $1.5$ cm just once in the poster example leaves one margin uncounted. Subtract $2(1.5)$ cm from each dimension, then find the inner area.

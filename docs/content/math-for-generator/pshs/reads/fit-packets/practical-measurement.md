# Lesson-fit packet mathematics__geometry__practical-measurement

## Lesson (content/lessons/mathematics/geometry/practical-measurement.md)

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

## Question file (content/questions/mathematics/geometry/practical-measurement.yaml)

```yaml
meta:
  subject: mathematics
  topic: geometry
  subtopic: practical-measurement
  exams: [pshs-nce]
questions:
  - id: q-geometry-practical-measurement-0001
    lesson: lesson-geometry-practical-measurement
    type: direct-computation
    difficulty: easy
    stem: |
      A cube has a volume of $125\text{ cm}^3$. What is its edge length in centimeters?
    choices:
      - text: '$5$'
        correct: true
      - text: '$25$'
        rationale: |
          This stops at the area of one face. A face does have two equal sides. Check that the edge multiplied three times gives the volume.
      - text: '$15$'
        rationale: |
          This adds three edges instead of giving one edge. The volume formula uses three equal factors. Check whether the question asks for their sum.
      - text: '$125$'
        rationale: |
          This keeps the volume as the edge length. Both describe the same cube. Check the difference between length and cubic units.
      - text: '$375$'
        rationale: |
          This multiplies the volume by three. Three equal factors appear in the volume formula. Check that a cube root undoes cubing.
    explanation: |
      The edge multiplied by itself three times must give $125$. Since $5\times5\times5=125$, the edge is $5$ cm.

  - id: q-geometry-practical-measurement-0002
    lesson: lesson-geometry-practical-measurement
    type: direct-computation
    difficulty: easy
    stem: |
      A polygon on a unit square grid contains exactly $7$ full squares and $6$ half-squares. What is its area in square units?
    choices:
      - text: '$10$'
        correct: true
      - text: '$13$'
        rationale: |
          This counts each half-square as a full square. Each is a visible piece. Check that two halves make one square.
      - text: '$7$'
        rationale: |
          This counts only full squares. They are the easiest parts to count. Check that the half-squares also cover space.
      - text: '$6.5$'
        rationale: |
          This halves the total number of pieces. Some pieces are halves. Check that the seven full squares stay whole.
      - text: '$20$'
        rationale: |
          This counts in half-square units. Each full square contains two halves. Check that the requested unit is a full square.
    explanation: |
      The $6$ half-squares make $6\div2=3$ full squares. Add them to the $7$ full squares: $7+3=10$ square units.

  - id: q-geometry-practical-measurement-0003
    lesson: lesson-geometry-practical-measurement
    type: word-problem
    difficulty: easy
    stem: |
      A floor is $2$ m long and $1$ m wide. Square tiles have sides of $50$ cm. How many whole tiles cover the floor without gaps or overlaps?
    choices:
      - text: '$8$'
        correct: true
      - text: '$4$'
        rationale: |
          This counts only the tiles along the length. That finds one row. Check how many rows fit across the width.
      - text: '$6$'
        rationale: |
          This adds the side counts of four and two. Both counts are needed. Check that rows and tiles per row are multiplied.
      - text: '$2$'
        rationale: |
          This reports the floor area in square meters. Area is needed for tiling. Check that one tile covers less than one square meter.
      - text: '$0.0008$'
        rationale: |
          This divides the floor area in square meters by the tile area in square centimeters. Both are areas. Check that their units match before dividing.
    explanation: |
      Convert first: $2$ m is $200$ cm and $1$ m is $100$ cm. There are $200\div50=4$ tiles along the length and $100\div50=2$ across the width. The floor needs $4\times2=8$ tiles.

  - id: q-geometry-practical-measurement-0004
    lesson: lesson-geometry-practical-measurement
    type: word-problem
    difficulty: easy
    stem: |
      A sheet is $14$ cm long and $10$ cm wide. A margin of $1$ cm is left along every edge. What is the area inside the margins, in square centimeters?
    choices:
      - text: '$96$'
        correct: true
      - text: '$117$'
        rationale: |
          This subtracts one margin from each dimension. One strip is visible on each named side. Check the opposite edge too.
      - text: '$140$'
        rationale: |
          This uses the full sheet area. The given dimensions describe the sheet. Check that margins leave less space inside.
      - text: '$120$'
        rationale: |
          This removes both margins from the length only. The length is reduced correctly. Check the two margins across the width.
      - text: '$112$'
        rationale: |
          This removes both margins from the width only. The width is reduced correctly. Check the two margins along the length.
    explanation: |
      The inner length is $14-2(1)=12$ cm. The inner width is $10-2(1)=8$ cm. The area is $12\times8=96\text{ cm}^2$.

  - id: q-geometry-practical-measurement-0005
    lesson: lesson-geometry-practical-measurement
    type: error-spotting
    difficulty: medium
    stem: |
      A student finds the edge of a cube whose volume is $729\text{ cm}^3$ by calculating $729\div3=243$ cm. What is the correct edge length in centimeters?
    choices:
      - text: '$9$'
        correct: true
      - text: '$243$'
        rationale: |
          This repeats the division by three. Cubing uses three factors. Check that division by three does not undo multiplication by the same number three times.
      - text: '$27$'
        rationale: |
          This takes the square root of the volume. Square roots undo a repeated product too. Check that volume has three equal factors.
      - text: '$81$'
        rationale: |
          This finds the area of one face after finding the edge. A face belongs to the cube. Check that the question asks for a length.
      - text: '$2187$'
        rationale: |
          This multiplies the volume by three. Three appears in the power. Check the product of three copies of the proposed edge.
    explanation: |
      Find a number whose cube is $729$. Since $9\times9\times9=729$, the edge is $9$ cm.

  - id: q-geometry-practical-measurement-0006
    lesson: lesson-geometry-practical-measurement
    type: direct-computation
    difficulty: medium
    figure: practical-measurement-grid-split
    stem: |
      A polygon on a unit square grid has vertices $(0,0)$, $(8,0)$, $(5,4)$, and $(0,4)$, joined in that order. Split it into a rectangle and a right triangle. What is its area in square units?
    choices:
      - text: '$26$'
        correct: true
      - text: '$20$'
        rationale: |
          This counts only the rectangle. Its width and height are easy to read. Check the triangle beside it.
      - text: '$32$'
        rationale: |
          This uses the surrounding rectangle without removing the missing corner. The full width is eight. Check the slanted boundary.
      - text: '$6$'
        rationale: |
          This reports only the triangle area. The triangle is one part of the split. Check that the rectangle also belongs to the polygon.
      - text: '$52$'
        rationale: |
          This multiplies the sum of the parallel sides by the height without halving. Both sides help measure the shape. Check that the split gives a rectangle and half a rectangle.
    explanation: |
      The left rectangle has area $5\times4=20$. The right triangle has base $8-5=3$ and height $4$, so its area is $\dfrac{3\times4}{2}=6$. Add: $20+6=26$ square units.

  - id: q-geometry-practical-measurement-0007
    lesson: lesson-geometry-practical-measurement
    type: word-problem
    difficulty: medium
    stem: |
      A sheet measures $11$ cm by $6$ cm. Each label measures $5$ cm by $3$ cm. Ignore the width of the cuts. What is the maximum number of whole labels that can be cut from the sheet?
    choices:
      - text: '$4$'
        correct: true
      - text: '$3$'
        rationale: |
          This uses only the turned layout. Three labels fit that way. Check the other orientation before choosing the maximum.
      - text: '$5$'
        rationale: |
          This rounds the area quotient up. The quotient is greater than four. Check that five labels need more area than the sheet has.
      - text: '$4.4$'
        rationale: |
          This uses the area quotient as the count. It measures how many label areas fit. Check that only whole labels count.
      - text: '$2$'
        rationale: |
          This counts only one row of labels. Two fit along the longer edge. Check that a second row fits across the sheet.
    explanation: |
      One layout gives $2\times2=4$ labels. Turning them gives $3\times1=3$. The area limit is $66\div15=4.4$, so at most $4$ whole labels are possible. The first layout reaches $4$.

  - id: q-geometry-practical-measurement-0008
    lesson: lesson-geometry-practical-measurement
    type: word-problem
    difficulty: medium
    stem: |
      A wheel of diameter $14$ cm turns about a fixed center. How far does a dot on its edge travel in $3$ full turns? Give the distance in centimeters, in terms of $\pi$.
    choices:
      - text: '$42\pi$'
        correct: true
      - text: '$84\pi$'
        rationale: |
          This treats the diameter as a radius. Both describe circle lengths. Check that the diameter formula is circumference equals pi times diameter.
      - text: '$14\pi$'
        rationale: |
          This finds the distance for one turn. Circumference is the right starting point. Check the given number of turns.
      - text: '$21\pi$'
        rationale: |
          This halves the diameter and then uses pi times that radius. Finding the radius is valid. Check the factor two in the radius formula.
      - text: '$147\pi$'
        rationale: |
          This multiplies the circle area by three. The radius is seven. Check that the dot travels along the boundary, which is a length.
    explanation: |
      One turn covers $\pi d=14\pi$ cm. Three turns cover $3(14\pi)=42\pi$ cm.

  - id: q-geometry-practical-measurement-0009
    lesson: lesson-geometry-practical-measurement
    type: word-problem
    difficulty: medium
    stem: |
      A room floor measures $3.6$ m by $2.4$ m. Square tiles have sides of $40$ cm. How many uncut tiles cover the floor edge to edge?
    choices:
      - text: '$54$'
        correct: true
      - text: '$15$'
        rationale: |
          This adds nine tiles and six rows. Both side counts are correct. Check that each row contains nine tiles.
      - text: '$9$'
        rationale: |
          This counts only the tiles along the length. That gives one row. Check the six rows across the width.
      - text: '$2160$'
        rationale: |
          This divides the floor area in square centimeters by the tile side length. The side length is given directly. Check that a tile covers forty times forty square centimeters.
      - text: '$0.54$'
        rationale: |
          This converts square meters using one hundred. That is the length conversion factor. Check that an area needs that factor twice.
    explanation: |
      Convert the floor dimensions to $360$ cm and $240$ cm. The side counts are $360\div40=9$ and $240\div40=6$. Multiply: $9\times6=54$ tiles.

  - id: q-geometry-practical-measurement-0010
    lesson: lesson-geometry-practical-measurement
    type: word-problem
    difficulty: medium
    stem: |
      A photo sheet measures $20$ cm by $16$ cm. An empty margin $1.5$ cm wide runs along each edge. What area, in square centimeters, is available for the photo?
    choices:
      - text: '$221$'
        correct: true
      - text: '$268.25$'
        rationale: |
          This subtracts one margin from each dimension. The margin width is one and a half. Check that each dimension has two ends.
      - text: '$260$'
        rationale: |
          This reduces only the width by three. That accounts for two strips. Check the strips at both ends of the length too.
      - text: '$272$'
        rationale: |
          This reduces only the length by three. That accounts for two strips. Check that the width also loses three centimeters.
      - text: '$212$'
        rationale: |
          This subtracts four full edge strips and counts the corners twice. Each edge needs a margin. Check where adjacent strips overlap.
    explanation: |
      Each dimension loses $2(1.5)=3$ cm. The inside measures $20-3=17$ cm by $16-3=13$ cm. Its area is $17\times13=221\text{ cm}^2$.

  - id: q-geometry-practical-measurement-0011
    lesson: lesson-geometry-practical-measurement
    type: word-problem
    difficulty: hard
    stem: |
      A square has side length $27$ cm. The numerical value of its area in square centimeters equals the numerical value of a cube's volume in cubic centimeters. What is the cube's edge length in centimeters?
    choices:
      - text: '$9$'
        correct: true
      - text: '$27$'
        rationale: |
          This copies the square's side as the cube's edge. The two shapes share a numerical measure. Check that the equality concerns area and volume.
      - text: '$243$'
        rationale: |
          This divides the square area by three. A cube has three length factors. Check that a cube root undoes cubing.
      - text: '$729$'
        rationale: |
          This reports the shared numerical area and volume. Finding that value is necessary. Check that one more step finds an edge.
      - text: '$3$'
        rationale: |
          This takes the cube root of the square's side. The side is the first number given. Check that the square's area must be found first.
    explanation: |
      The square's area is $27\times27=729\text{ cm}^2$. The cube therefore has volume $729\text{ cm}^3$. Since $9^3=729$, its edge is $9$ cm.

  - id: q-geometry-practical-measurement-0012
    lesson: lesson-geometry-practical-measurement
    type: direct-computation
    difficulty: hard
    figure: practical-measurement-grid-surrounding
    stem: |
      On a unit dot grid, a polygon has vertices $(0,0)$, $(6,0)$, $(6,2)$, $(4,5)$, and $(0,5)$, joined in that order. Use a surrounding rectangle to find its area in square units.
    choices:
      - text: '$27$'
        correct: true
      - text: '$30$'
        rationale: |
          This counts the whole surrounding rectangle. It covers the polygon. Check the missing upper-right corner.
      - text: '$24$'
        rationale: |
          This subtracts a full two-by-three rectangle. Those are the missing corner's side lengths. Check that the missing shape is a triangle.
      - text: '$3$'
        rationale: |
          This reports the missing triangle's area. Subtracting it is the final step. Check which region the question asks about.
      - text: '$33$'
        rationale: |
          This adds the missing triangle's area. Adding pieces works for a split shape. Check that this triangle lies outside the polygon.
    explanation: |
      The surrounding rectangle has area $6\times5=30$. The missing triangle has legs $6-4=2$ and $5-2=3$. Its area is $\dfrac{2\times3}{2}=3$, so the polygon's area is $30-3=27$ square units.

  - id: q-geometry-practical-measurement-0013
    lesson: lesson-geometry-practical-measurement
    type: word-problem
    difficulty: hard
    stem: |
      Rectangular tags measuring $4$ cm by $3$ cm are cut from a $9$ cm by $8$ cm sheet. Ignore the width of the cuts. What is the greatest number of whole tags that can be cut?
    choices:
      - text: '$6$'
        correct: true
      - text: '$4$'
        rationale: |
          This keeps the four-centimeter side along the nine-centimeter edge. That layout fits four tags. Check the turned layout.
      - text: '$2$'
        rationale: |
          This counts rows only in the turned layout. Two rows fit across the eight-centimeter side. Check that each row contains three tags.
      - text: '$8$'
        rationale: |
          This rounds the row count up in the first layout. A partial row seems to offer more space. Check that every tag needs its full width.
      - text: '$18$'
        rationale: |
          This divides the sheet area by the tag length only. Division is needed to count pieces. Check that the divisor is the tag area, four times three.
    explanation: |
      Put the $3$ cm side along the $9$ cm edge and the $4$ cm side along the $8$ cm edge. This gives $3\times2=6$ tags. The area limit is $(9\times8)\div(4\times3)=6$, so no layout can fit more.

  - id: q-geometry-practical-measurement-0014
    lesson: lesson-geometry-practical-measurement
    type: word-problem
    difficulty: hard
    stem: |
      A clock's minute hand is $4$ cm long. How far does its tip travel from $2{:}00$ to $4{:}30$ the same afternoon? Give the distance in centimeters, in terms of $\pi$.
    choices:
      - text: '$20\pi$'
        correct: true
      - text: '$8\pi$'
        rationale: |
          This counts one full turn. One circumference is eight pi. Check the full elapsed time.
      - text: '$16\pi$'
        rationale: |
          This counts only the two whole turns. Whole numbers work for cutting pieces. Check that a hand also moves during a half-turn.
      - text: '$10\pi$'
        rationale: |
          This treats the hand length as a diameter. It is a length across part of the clock. Check that the hand runs from the center to the tip.
      - text: '$40\pi$'
        rationale: |
          This uses the circle area for each turn. The area is sixteen pi. Check that tip travel is a length around the circle.
    explanation: |
      The elapsed time is $2.5$ hours. A minute hand makes one turn per hour, so it makes $2.5$ turns. Each turn covers $2\pi(4)=8\pi$ cm. The distance is $2.5(8\pi)=20\pi$ cm.

  - id: q-geometry-practical-measurement-0015
    lesson: lesson-geometry-practical-measurement
    type: word-problem
    difficulty: hard
    stem: |
      A school hall is $4.8$ m long and $350$ cm wide. Rectangular tiles measure $40$ cm by $25$ cm. Put each tile's $40$ cm side along the hall's length. How many uncut tiles cover the hall with no gaps or overlaps?
    choices:
      - text: '$168$'
        correct: true
      - text: '$26$'
        rationale: |
          This adds twelve tiles and fourteen rows. Both counts use matching units. Check that each row has twelve tiles.
      - text: '$12$'
        rationale: |
          This counts one row only. Twelve tiles span the length. Check how many rows span the width.
      - text: '$1680$'
        rationale: |
          This converts the length using one thousand instead of one hundred. Millimeters use a factor of one thousand. Check that the tile dimensions are in centimeters.
      - text: '$156$'
        rationale: |
          This counts only thirteen rows. Thirteen times twenty-five is close to the width. Check that fourteen rows fit exactly.
    explanation: |
      Convert $4.8$ m to $480$ cm first. There are $480\div40=12$ tiles along the length and $350\div25=14$ rows. The total is $12\times14=168$ tiles.

  - id: q-geometry-practical-measurement-0016
    lesson: lesson-geometry-practical-measurement
    type: direct-computation
    difficulty: exam
    figure: practical-measurement-grid-comparison
    stem: |
      Two polygons are drawn on dot grids with the same unit spacing. Polygon P has vertices $(0,0)$, $(6,0)$, $(4,4)$, and $(0,4)$. Polygon Q has vertices $(0,0)$, $(5,0)$, $(5,5)$, and $(0,3)$. Join each list in order and close it. Which pair gives the areas of P and Q, respectively, in square units?
    choices:
      - text: '$(20,20)$'
        correct: true
      - text: '$(24,25)$'
        rationale: |
          This counts each surrounding rectangle. The outer dimensions are easy to read. Check the corner missing from each polygon.
      - text: '$(16,15)$'
        rationale: |
          This counts only the rectangular part of each split. Those parts have clear right angles. Check the triangle that remains in each shape.
      - text: '$(16,20)$'
        rationale: |
          This subtracts a full two-by-four rectangle from P but handles Q correctly. The missing corner of P has those side lengths. Check that it is only half that rectangle.
      - text: '$(20,15)$'
        rationale: |
          This finds P correctly but leaves out Q's upper triangle. Q has a rectangular lower part. Check the area above its three-unit left side.
    explanation: |
      P fits in a $6$ by $4$ rectangle with a missing triangle of base $2$ and height $4$. Its area is $24-\dfrac{2\times4}{2}=20$. Q has a $5$ by $3$ rectangle and a triangle of base $5$ and height $2$. Its area is $15+\dfrac{5\times2}{2}=20$. Both areas are $20$ square units.

  - id: q-geometry-practical-measurement-0017
    lesson: lesson-geometry-practical-measurement
    type: word-problem
    difficulty: exam
    stem: |
      A $7$ cm by $6$ cm sheet is used to make $4$ cm by $3$ cm labels. Labels may face different directions on the same sheet. Ignore the width of the cuts. What is the maximum number of whole labels?
    choices:
      - text: '$3$'
        correct: true
      - text: '$2$'
        rationale: |
          This tests only layouts with every label facing the same way. Both simple row layouts give two. Check whether a turned label fits beside a pair.
      - text: '$4$'
        rationale: |
          This rounds the area limit up. The sheet has enough area for three and a half labels. Check that four labels need forty-eight square centimeters.
      - text: '$3.5$'
        rationale: |
          This reports the area quotient. It gives a useful upper limit. Check that half a label cannot count as a whole label.
      - text: '$6$'
        rationale: |
          This multiplies counts using the three-centimeter side along both sheet dimensions. Each label has one three-centimeter side. Check that its other side is four centimeters.
    explanation: |
      The area limit is $(7\times6)\div(4\times3)=3.5$, so at most $3$ whole labels fit. In a $4$ cm by $6$ cm strip, stack two $4$ cm by $3$ cm labels. The remaining $3$ cm by $6$ cm strip holds one turned $3$ cm by $4$ cm label. This fits $3$ labels.

  - id: q-geometry-practical-measurement-0018
    lesson: lesson-geometry-practical-measurement
    type: word-problem
    difficulty: exam
    stem: |
      A wheel with radius $7$ cm turns steadily about a fixed center, making one full turn every $20$ seconds. Using $\pi=\dfrac{22}{7}$, how far does a dot on its edge travel in $90$ seconds, in centimeters?
    choices:
      - text: '$198$'
        correct: true
      - text: '$176$'
        rationale: |
          This keeps only four whole turns. Whole counts are needed for cut pieces. Check that the dot travels during the last half-turn too.
      - text: '$99$'
        rationale: |
          This uses pi times the radius for one turn. Seven is the given circle length. Check the factor two in circumference.
      - text: '$396$'
        rationale: |
          This doubles the radius twice. Turning radius into diameter is needed once. Check whether the diameter formula already includes that change.
      - text: '$44$'
        rationale: |
          This finds one circumference only. That is the distance in twenty seconds. Check the number of turns in ninety seconds.
    explanation: |
      One turn covers $2\times\dfrac{22}{7}\times7=44$ cm. In $90$ seconds, the wheel makes $90\div20=4.5$ turns. The dot travels $44\times4.5=198$ cm.

  - id: q-geometry-practical-measurement-0019
    lesson: lesson-geometry-practical-measurement
    type: word-problem
    difficulty: exam
    stem: |
      A display board measures $0.9$ m by $0.6$ m. A blank margin $5$ cm wide must remain along every edge. What area inside the margins is available for a map, in square centimeters?
    choices:
      - text: '$4000$'
        correct: true
      - text: '$4675$'
        rationale: |
          This subtracts five centimeters once from each side length. That handles one edge in each direction. Check the opposite edges.
      - text: '$5400$'
        rationale: |
          This finds the full board area after conversion. Those dimensions describe the outer board. Check the blank strips around the map.
      - text: '$4500$'
        rationale: |
          This removes both margins from the width only. That gives the correct inner width of fifty. Check that the length also loses two margins.
      - text: '$3900$'
        rationale: |
          This subtracts four full edge strips and counts each corner twice. All four edges do have margins. Check where the strips overlap.
    explanation: |
      Convert first: the board is $90$ cm by $60$ cm. Subtract $2(5)=10$ cm from each dimension. The inside area is $(90-10)(60-10)=80\times50=4000\text{ cm}^2$.

  - id: q-geometry-practical-measurement-0020
    lesson: lesson-geometry-practical-measurement
    type: word-problem
    difficulty: exam
    stem: |
      A clock's hour hand is $8$ cm long and turns steadily once every $12$ hours. How far does its tip travel from $9{:}00$ a.m. to $3{:}00$ p.m. that day? Give the distance in centimeters, in terms of $\pi$.
    choices:
      - text: '$8\pi$'
        correct: true
      - text: '$16\pi$'
        rationale: |
          This counts one complete turn. Six hours can seem like a full trip across a clock face. Check that the hour hand takes twelve hours for a turn.
      - text: '$96\pi$'
        rationale: |
          This gives the hour hand six full turns. A minute hand makes one turn per hour. Check which hand the question names.
      - text: '$4\pi$'
        rationale: |
          This treats the hand length as a diameter before taking half a turn. Eight is the given length. Check that the hand extends from the center to the tip.
      - text: '$32\pi$'
        rationale: |
          This takes half the circle's area. Half is the right fraction of a turn. Check that travel uses circumference, measured in length units.
    explanation: |
      From $9{:}00$ a.m. to $3{:}00$ p.m. is $6$ hours. The hour hand makes $\dfrac{6}{12}=\dfrac{1}{2}$ turn. Its tip travels $\dfrac{1}{2}\times2\pi(8)=8\pi$ cm.
```

---
_id: "lesson-geometry-whole-pieces-and-floor-tiles"
title: "Whole Pieces and Floor Tiles"
summary: "Find how many whole pieces fit on a sheet. Count tiles after matching the units."
subject: "subject-mathematics"
topic: "topic-geometry"
isActive: true
part: 3
partCount: 5
ordering: 0
keyPoints:
  - "Find how many whole pieces fit on a sheet."
  - "Count tiles after matching the units."
---
## Core Concept

### Whole Pieces and Floor Tiles

To cut equal rectangles from a sheet in rows, divide the sheet's length by the piece's length. Keep the whole-number part. Do the same for the widths, then multiply the counts:

$$N=(\text{pieces per row})(\text{rows})$$

Try turning the pieces so their length and width switch places. A partial piece does not count as a whole rectangle.

Dividing sheet area by piece area gives a limit on the number of whole pieces. It does not prove those pieces fit. To prove a maximum, show a layout that reaches the whole-number limit. Mixed directions may fit more than either simple row layout.

For a floor covered exactly by equal tiles, with no gaps or overlaps:

$$N=\dfrac{A_{\text{floor}}}{A_{\text{tile}}}$$

Convert lengths to the same unit before finding the areas. Since $1$ meter is $100$ centimeters, multiply meters by $100$ to get centimeters. Check that whole tiles fit along both sides if the question requires uncut tiles.

## Examples

### #1: Labels Cut from a Sheet

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

### #2: Tiles for a Reading Room

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

## Speed Tricks & Shortcuts

For whole rectangles, keep the whole-number part of each side count before multiplying. For a steadily turning hand, keep fractional turns because the tip travels during a partial turn too.

## Traps to Watch For

### #1: Using an Area Limit as a Layout

> Enough area does not prove whole rectangles fit.

Try both orientations and show where the pieces go. If neither row layout reaches the area limit, more checking is needed before calling a count the maximum.

### #2: Mixing Units

> Convert lengths before finding areas.

In the tile example, dividing the floor's area in square meters by a tile's area in square centimeters would mix different units. Converting first lets the area units match.

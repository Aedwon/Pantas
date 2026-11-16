---
_id: "lesson-arithmetic-number-sense-counting-and-digit-patterns"
title: "Counting and Digit Patterns"
summary: "Use repeating digits, square sizes, and place value to solve counting patterns."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 1
partCount: 1
ordering: 42
keyPoints:
  - "Find the cycle of units digits, then use the exponent's remainder."
  - "Count squares by size before adding them."
  - "Connect a figure's number to its side length and border count."
  - "Use place value to make the smallest or largest sum or difference."
---
## Core Concept

### Repeating Units Digits

The **units digit** is the last digit of a whole number. A **power** means repeated multiplication: $7^3$ means $7\times7\times7$. The small raised number, called the **exponent**, tells how many copies to multiply.

The **base** is the number being repeatedly multiplied. In $7^3$, the base is $7$. For a whole-number base and a positive whole-number exponent, you can find the units digit without finding the whole power. Multiply the current units digit by the base, then keep just the new units digit. Digits to its left do not change that result.

A **cycle** is a group that repeats in the same order. Start with the first power and keep going until its units digit returns. From that point, the same multiplication gives the same following digits.

Divide the exponent by the cycle length. The **remainder** is what is left after making complete groups. A nonzero remainder gives the position in the cycle; a remainder of $0$ means use the last position.

This method starts at exponent $1$. For a nonzero base raised to exponent $0$, the value is $1$ instead.

The units digit of a sum depends only on the units digits of the numbers added.

For example, $27+38=65$: add $7+8=15$ and keep the last digit, $5$.

### Counting Squares by Size

A grid is a figure made from rows and columns of small squares. A square can cover several of those small squares. Count each possible size separately.

In a complete $n$ by $n$ grid, $n$ is the number of small squares along each side. For a square with side $k$ small squares, there are $n-k+1$ starting positions across and the same number down. So its count is:

$(n-k+1)^2$

Here $n$ is a positive whole number, and $k$ runs from $1$ through $n$. Add the counts to get:

$\text{total}=1^2+2^2+\cdots+n^2$

The dots mean continue through the square of each whole number up to $n$. This is a **sum of squares**. Count squares whose sides follow the grid lines, not tilted squares made from diagonal lines.

For a figure with missing parts, check which squares still have complete sides. Do not use the full-grid total without checking the missing lines.

### Growing Square Borders

A **border** is the outside row of tiles around a figure. In a filled square with side length $s$ tiles, there are $s^2$ tiles in total. Removing its border leaves an inner square with side length $s-2$.

For a whole-number side length $s\geq2$, the border count is:

$\text{border}=s^2-(s-2)^2$

You can also count the top and bottom rows, then the side tiles between them:

$\text{border}=2s+2(s-2)=4s-4$

Both rules count each corner once. For a single tile, the border count is $1$; these rules do not apply to that case.

If a pattern starts with side length $a$ and grows by $1$ tile per side each time, Figure $n$ has side length $a+(n-1)$. The **nth figure** means the figure at position $n$. First find its side length, then count its border.

### Placing Given Digits

**Place value** tells what a digit contributes. In $100a+10b+c$, the digits $a$, $b$, and $c$ occupy the hundreds, tens, and units places. A number with several digits cannot begin with $0$.

For the **sum**, or result of adding, small digits in larger places help make the total small. Large digits in larger places help make it large. Check the required lengths and the rule about zero first.

For a **difference**, subtract the smaller number from the larger unless the question gives another order. With a three-digit number minus a two-digit number, the place values are:

$100a+10b+c-(10d+e)$

To make this difference small, put small digits in the added places and large digits in the subtracted places. Among the added places, fill hundreds before tens before units. Among the subtracted places, fill tens before units.

To make that difference large, reverse those choices. These directions depend on the required number lengths. For two numbers of the same length, start by making their leading digits close if you want a small difference.

## Examples

### #1: The Last Digit of a Power

What is the units digit of $7^{46}$? What about $7^{48}$?

**Solution:**

1. Build the cycle from the first power. Keep only the units digit after each multiplication.

$7^1=7$

$7\times7=49$

$9\times7=63$

$3\times7=21$

$1\times7=7$

2. The units digits repeat as $7,9,3,1$. The cycle length is $4$.

3. Divide the first exponent by $4$.

$46=4\times11+2$

4. The remainder is $2$. Use the second digit in the cycle. The units digit of $7^{46}$ is $9$.

5. Check the other exponent.

$48=4\times12+0$

The remainder is $0$, so use the fourth digit. The units digit of $7^{48}$ is $1$.

### #2: Squares in a Complete Grid

A square window is divided into a $4$ by $4$ grid of equal small squares. How many squares of all sizes have sides along the grid lines?

<!-- ILLUSTRATION: A complete 4 by 4 square grid with equal cells, labeled 4 small squares across and 4 small squares down; no count totals or highlighted solution squares. -->

**Solution:**

1. Count squares with side length $1$. Each small cell is one square.

$4\times4=16$

2. Count squares with side length $2$. Their left edges can start in the first $3$ columns. Their top edges can start in the first $3$ rows.

$3\times3=9$

3. A square with side length $3$ has $2$ starting positions across and $2$ down.

$2\times2=4$

4. The whole window is one square with side length $4$.

$1\times1=1$

5. Add the counts for the different sizes.

$16+9+4+1=30$

There are $30$ squares. Counting just the small cells would miss the larger ones.

### #3: Squares in a Figure with a Missing Corner

Start with a $3$ by $3$ grid of unit squares. Remove the upper-right cell and its top and right outer edges. Keep the other grid lines. How many complete squares remain, using the grid lines as sides?

<!-- ILLUSTRATION: A 3 by 3 unit-square grid with the upper-right cell absent, including its top and right outer edges; retain all boundaries of the other eight cells; no highlighted groups or answer totals. -->

**Solution:**

1. Count the remaining unit squares. One cell was removed.

$9-1=8$

2. A complete $3$ by $3$ grid has $2\times2=4$ positions for a square with side length $2$. Check them by their upper-left corners: top left, top middle, middle left, and center.

3. The square starting at the top middle needs the removed upper-right corner. Its sides are incomplete. The other three positions still have complete sides.

$4-1=3$

4. A square with side length $3$ would need the full outside boundary. That boundary is broken, so there are $0$ squares of this size.

5. Add the counts.

$8+3+0=11$

The figure contains $11$ complete squares.

### #4: Border Tiles in a Growing Display

Figure $1$ is a $4$ by $4$ square of tiles. Figure $2$ is $5$ by $5$, and Figure $3$ is $6$ by $6$. Each new figure adds $1$ tile to each side length. Only the border tiles are blue. How many blue tiles are in Figure $12$?

<!-- ILLUSTRATION: Three filled square tile grids labeled Figure 1, Figure 2, and Figure 3, with side lengths 4, 5, and 6 tiles respectively; color only their outermost tiles blue and leave interiors white; do not show Figure 12 or border totals. -->

**Solution:**

1. Find how many growth steps come after Figure $1$.

$12-1=11$

2. Add these steps to the first side length.

$s=4+11=15$

3. The inside has $2$ fewer tiles along each side because a border row is removed from both ends.

$15-2=13$

4. Subtract the inside tile count from the full tile count.

$15^2-13^2=225-169$

$225-169=56$

5. Check by counting the top and bottom rows, then the sides between them.

$2\times15+2\times13=56$

Figure $12$ has $56$ blue tiles.

### #5: Smallest and Largest Differences

Use the digits $1$, $3$, $6$, $7$, and $8$ exactly once to form a three-digit number and a two-digit number. What are the smallest and largest possible differences when the two-digit number is subtracted from the three-digit number?

**Solution:**

1. For the smallest difference, choose the smallest hundreds digit, $1$. Here a digit contributes $100$ times its value in hundreds, $10$ times its value in tens, and its value in units. Keeping $1$ in hundreds leaves the larger digits for places that add less or for the number being subtracted.

2. Put the largest remaining digit, $8$, in the subtracted tens place. Put the next largest, $7$, in the subtracted units place. The number being subtracted is $87$.

3. Put $3$ in the added tens place and $6$ in the added units place. This makes the three-digit number $136$.

$136-87=49$

4. For the largest difference, put $8$ in hundreds and $7$ in the added tens place. Put the smallest digit, $1$, in the subtracted tens place.

5. The remaining digits are $3$ and $6$. Adding $6$ and subtracting $3$ gives the larger result. The numbers are $876$ and $13$.

$876-13=863$

The smallest difference is $49$. The largest is $863$. Each arrangement uses the five given digits once.

### #6: Sums with a Zero Digit

Use $0$, $2$, $5$, and $9$ exactly once to form two two-digit numbers. What are the smallest and largest possible sums?

**Solution:**

1. The tens digits cannot be $0$. For the smallest sum, use the smallest available nonzero digits in tens: $2$ and $5$.

$20+50=70$

2. Put the remaining digits, $0$ and $9$, in units. Their contribution is $9$ whichever number gets each digit.

$20+59=79$

3. For the largest sum, use the largest digits, $9$ and $5$, in tens. Use $0$ and $2$ in units.

$90+52=142$

The smallest sum is $79$, and the largest is $142$. Swapping the units digits gives other arrangements with the same sums.

## Speed Tricks & Shortcuts

### Keep Just the Last Digit

When finding a power's units digit, discard the other digits after each multiplication. If the base ends in $0$, $1$, $5$, or $6$, its positive whole-number powers keep that same last digit. Multiplying that last digit by itself confirms the repeating step.

### Count Positions, Not Guesses

For squares in a full grid, count starting positions across and down. For an incomplete figure, list the possible positions and cross out those with broken sides. Overlapping squares still count as separate squares.

### Find the Side Before the Border

The figure number may differ from its side length. Write the starting side length and the number of growth steps first. Then use the border rule.

## Traps to Watch For

### #1: A Zero Remainder

> A remainder of $0$ means the last position in the cycle.

It does not mean the units digit is $0$. In the power example, a complete cycle ends at $1$.

### #2: Counting Corners Twice

> Adding four full sides counts each corner twice.

For a square border with side length at least $2$, subtract $4$ from $4s$. Each of the four corners needs one extra count removed.

### #3: Sorting Digits without Reading the Task

> Check the operation and required number lengths before placing digits.

A small sum needs small legal tens digits. A small difference may need a large number being subtracted. Leading zeroes are not allowed when the task requires a two-digit or three-digit number.

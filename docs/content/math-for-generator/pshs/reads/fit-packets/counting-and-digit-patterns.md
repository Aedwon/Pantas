# Lesson-fit packet mathematics__arithmetic-number-sense__counting-and-digit-patterns

## Lesson (content/lessons/mathematics/arithmetic-number-sense/counting-and-digit-patterns.md)

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

## Question file (content/questions/mathematics/arithmetic-number-sense/counting-and-digit-patterns.yaml)

```yaml
meta:
  subject: mathematics
  topic: arithmetic-number-sense
  subtopic: counting-and-digit-patterns
  exams: [pshs-nce]
questions:
  - id: q-arithmetic-number-sense-counting-and-digit-patterns-0001
    lesson: lesson-arithmetic-number-sense-counting-and-digit-patterns
    keyPoint: 1
    type: direct-computation
    difficulty: easy
    stem: |
      What is the units digit of $4^3$?
    choices:
      - text: '$4$'
        correct: true
      - text: '$2$'
        rationale: |
          This uses $4\times3=12$ instead of a power. Both calculations use four and three. Check that the exponent means three factors of four.
      - text: '$3$'
        rationale: |
          This reports the exponent. The exponent tells how many factors to multiply. Check the last digit of the product.
      - text: '$6$'
        rationale: |
          This stops at the second power. The digit $6$ belongs to the cycle. Check which position an odd exponent uses.
      - text: '$8$'
        rationale: |
          This doubles the base instead of multiplying three copies. Doubling also uses repeated addition. Check that a power uses repeated multiplication.
    explanation: |
      The units digits of powers of $4$ repeat as $4,6$. Since $3=2\times1+1$, use the first digit. The units digit is $4$.

  - id: q-arithmetic-number-sense-counting-and-digit-patterns-0002
    lesson: lesson-arithmetic-number-sense-counting-and-digit-patterns
    keyPoint: 2
    type: word-problem
    difficulty: easy
    stem: |
      A complete $2$ by $2$ grid is made of equal small squares. How many squares of all sizes have sides along its grid lines?
    choices:
      - text: '$5$'
        correct: true
      - text: '$4$'
        rationale: |
          This counts only the small cells. Each cell is a square. Check whether the outside boundary forms another square.
      - text: '$6$'
        rationale: |
          This counts the outside square twice. It can be found from more than one corner. Check that the same boundary is counted once.
      - text: '$8$'
        rationale: |
          This adds the two side lengths and doubles the result. That counts lengths around the border. Check that the task asks for squares.
      - text: '$9$'
        rationale: |
          This squares the number of grid lines in each direction. Three lines mark two rows of cells. Check the spaces between lines.
    explanation: |
      There are $2^2=4$ small squares and $1^2=1$ large square. Add them: $4+1=5$.

  - id: q-arithmetic-number-sense-counting-and-digit-patterns-0003
    lesson: lesson-arithmetic-number-sense-counting-and-digit-patterns
    keyPoint: 3
    type: word-problem
    difficulty: easy
    stem: |
      A filled $3$ by $3$ square of tiles has only its outside border painted. How many tiles are painted?
    choices:
      - text: '$8$'
        correct: true
      - text: '$9$'
        rationale: |
          This counts every tile. Almost the whole small square is on the border. Check the center tile.
      - text: '$12$'
        rationale: |
          This counts four full sides. Each side has three tiles. Check that each corner was counted twice.
      - text: '$4$'
        rationale: |
          This counts only corners. The corners are border tiles. Check the tile between the corners on each side.
      - text: '$6$'
        rationale: |
          This counts just the top and bottom rows. Both rows are on the border. Check the middle tile on each remaining side.
    explanation: |
      The center is the only tile inside the border. The painted count is $3^2-1^2=9-1=8$.

  - id: q-arithmetic-number-sense-counting-and-digit-patterns-0004
    lesson: lesson-arithmetic-number-sense-counting-and-digit-patterns
    keyPoint: 4
    type: direct-computation
    difficulty: easy
    stem: |
      Use the digits $1$, $2$, $5$, and $8$ exactly once to form two two-digit numbers. What is the smallest possible sum?
    choices:
      - text: '$43$'
        correct: true
      - text: '$70$'
        rationale: |
          This uses $12+58$ after sorting the digits. Both numbers are small when read in order. Check whether both smallest digits can be in the tens places.
      - text: '$79$'
        rationale: |
          This uses $21+58$. Starting with a small two-digit number seems helpful. Check the other tens digit, $5$.
      - text: '$133$'
        rationale: |
          This uses $51+82$, the largest sum. Large tens digits increase the total. Check whether the task asks for the smallest sum.
      - text: '$16$'
        rationale: |
          This adds the four digits without place value. Every digit is used once. Check that tens digits contribute ten times their values.
    explanation: |
      Use $1$ and $2$ in the tens places. Their value is $10+20=30$. The units digits add to $5+8=13$. Thus the smallest sum is $30+13=43$, as in $15+28=43$.

  - id: q-arithmetic-number-sense-counting-and-digit-patterns-0005
    lesson: lesson-arithmetic-number-sense-counting-and-digit-patterns
    keyPoint: 1
    type: direct-computation
    difficulty: medium
    stem: |
      What is the units digit of $6^{57}$?
    choices:
      - text: '$6$'
        correct: true
      - text: '$2$'
        rationale: |
          This uses the units digit of $6\times57$. Multiplication appears in a power. Check that the exponent counts copies of the base.
      - text: '$7$'
        rationale: |
          This takes the last digit of the exponent. The exponent locates a cycle position. Check the units digits of the powers themselves.
      - text: '$1$'
        rationale: |
          This assumes every complete cycle ends in one. That happens for some bases. Check the cycle for six.
      - text: '$0$'
        rationale: |
          This reports the remainder after dividing by the cycle length of one. The remainder is zero. Check that zero means the last cycle entry.
    explanation: |
      The first power ends in $6$. Multiplying a number ending in $6$ by $6$ gives another number ending in $6$. The cycle has just one digit, so $6^{57}$ ends in $6$.

  - id: q-arithmetic-number-sense-counting-and-digit-patterns-0006
    lesson: lesson-arithmetic-number-sense-counting-and-digit-patterns
    keyPoint: 2
    type: word-problem
    difficulty: medium
    stem: |
      A square sheet is divided into a complete $3$ by $3$ grid. How many squares of all sizes have sides along the grid lines?
    choices:
      - text: '$14$'
        correct: true
      - text: '$9$'
        rationale: |
          This counts only the smallest squares. There are three rows of three. Check for squares that cover several cells.
      - text: '$10$'
        rationale: |
          This counts the cells and the whole sheet. Both sizes are easy to see. Check the squares with side length two.
      - text: '$13$'
        rationale: |
          This adds the one-cell and two-cell square counts. Those give $9+4$. Check the whole sheet too.
      - text: '$18$'
        rationale: |
          This uses $3\times(1+2+3)$. There are three square sizes. Check the number of starting positions for each size.
    explanation: |
      There are $3^2=9$ unit squares, $2^2=4$ squares with side length $2$, and one whole-sheet square. The total is $9+4+1=14$.

  - id: q-arithmetic-number-sense-counting-and-digit-patterns-0007
    lesson: lesson-arithmetic-number-sense-counting-and-digit-patterns
    keyPoint: 3
    type: word-problem
    difficulty: medium
    stem: |
      Figure $1$ is a $2$ by $2$ tile square. Each new figure increases the side length by one tile. Only border tiles are red. How many red tiles are in Figure $6$?
    choices:
      - text: '$24$'
        correct: true
      - text: '$20$'
        rationale: |
          This treats the figure number as the side length. The numbers are close. Check the stated side length of Figure one.
      - text: '$28$'
        rationale: |
          This counts four sides of length seven. The side length is right. Check the corners for double counting.
      - text: '$49$'
        rationale: |
          This counts the entire seven-by-seven square. All those tiles belong to the figure. Check which ones are on the border.
      - text: '$25$'
        rationale: |
          This counts the inner five-by-five square. Removing the border does leave that square. Check whether the question asks for inside or border tiles.
    explanation: |
      Figure $6$ comes $6-1=5$ steps after Figure $1$. Its side length is $2+5=7$. The border has $4\times7-4=24$ tiles.

  - id: q-arithmetic-number-sense-counting-and-digit-patterns-0008
    lesson: lesson-arithmetic-number-sense-counting-and-digit-patterns
    keyPoint: 4
    type: direct-computation
    difficulty: medium
    stem: |
      Use $1$, $2$, $4$, $7$, and $9$ exactly once to form a three-digit number and a two-digit number. What is the largest possible result when the two-digit number is subtracted from the three-digit number?
    choices:
      - text: '$962$'
        correct: true
      - text: '$935$'
        rationale: |
          This uses $947-12$. It puts the largest digit in hundreds and the smallest digits below. Check whether the tens and units of the three-digit number can be swapped.
      - text: '$958$'
        rationale: |
          This uses $972-14$. It keeps the first two places large. Check whether adding four and subtracting two gives more than adding two and subtracting four.
      - text: '$953$'
        rationale: |
          This uses $974-21$. The three-digit number is as large as possible. Check whether the number being subtracted can be smaller.
      - text: '$986$'
        rationale: |
          This adds $974+12$. It chooses useful digit positions. Check the required operation.
    explanation: |
      The place values are $100a+10b+c-10d-e$. Put $9$ in hundreds and $7$ in the added tens place. Put $1$ in the subtracted tens place. Of the digits left, add $4$ and subtract $2$. This gives $974-12=962$.

  - id: q-arithmetic-number-sense-counting-and-digit-patterns-0009
    lesson: lesson-arithmetic-number-sense-counting-and-digit-patterns
    keyPoint: 1
    type: direct-computation
    difficulty: medium
    stem: |
      What is the units digit of $3^{52}$?
    choices:
      - text: '$1$'
        correct: true
      - text: '$0$'
        rationale: |
          This treats a zero remainder as the answer. The exponent does divide evenly by four. Check the last entry of the cycle.
      - text: '$3$'
        rationale: |
          This restarts at the first cycle entry when the remainder is zero. The next power would start there. Check the entry that ends the completed cycle.
      - text: '$9$'
        rationale: |
          This uses the last digit of the exponent to choose the second entry. The exponent ends in two. Check its remainder when divided by four.
      - text: '$7$'
        rationale: |
          This stops one entry before the end of the cycle. Seven is part of the cycle. Check which entry matches a multiple of four.
    explanation: |
      The cycle is $3,9,7,1$. Since $52=4\times13$, there are thirteen full cycles. Each ends in $1$, so the units digit is $1$.

  - id: q-arithmetic-number-sense-counting-and-digit-patterns-0010
    lesson: lesson-arithmetic-number-sense-counting-and-digit-patterns
    keyPoint: 2
    type: direct-computation
    difficulty: medium
    stem: |
      In a complete $4$ by $4$ grid of unit squares, how many squares have side length exactly $2$ units?
    choices:
      - text: '$9$'
        correct: true
      - text: '$4$'
        rationale: |
          This counts only nonoverlapping two-by-two blocks. They do fit in the grid. Check the overlapping positions too.
      - text: '$16$'
        rationale: |
          This uses every cell as a starting position. There are sixteen cells. Check whether a two-unit side fits from the last row or column.
      - text: '$6$'
        rationale: |
          This adds three horizontal starts and three vertical starts. Both counts are needed. Check that every horizontal start pairs with every vertical start.
      - text: '$30$'
        rationale: |
          This counts all square sizes. Thirty is the full-grid total. Check the requested side length.
    explanation: |
      The top-left corner can start in any of $3$ columns and $3$ rows. This gives $3\times3=9$ squares with side length $2$.

  - id: q-arithmetic-number-sense-counting-and-digit-patterns-0011
    lesson: lesson-arithmetic-number-sense-counting-and-digit-patterns
    keyPoint: 3
    type: word-problem
    difficulty: hard
    stem: |
      A growing tile pattern begins with a $5$ by $5$ square at Figure $1$. Each following figure has one more tile along each side. How many tiles lie on the border of Figure $9$?
    choices:
      - text: '$48$'
        correct: true
      - text: '$32$'
        rationale: |
          This uses nine as the side length in $4s-4$. Nine is the figure number. Check the starting side length.
      - text: '$52$'
        rationale: |
          This uses four full sides of length thirteen. The side length is correct. Check whether corners are counted twice.
      - text: '$169$'
        rationale: |
          This counts all tiles in the thirteen-by-thirteen square. That is the correct side length. Check that only border tiles are requested.
      - text: '$44$'
        rationale: |
          This uses only seven growth steps. It leaves out the last increase. Check that nine figures have eight gaps.
    explanation: |
      There are $9-1=8$ growth steps. The side length is $5+8=13$. The border count is $4\times13-4=48$.

  - id: q-arithmetic-number-sense-counting-and-digit-patterns-0012
    lesson: lesson-arithmetic-number-sense-counting-and-digit-patterns
    keyPoint: 4
    type: direct-computation
    difficulty: hard
    stem: |
      Use the digits $0$, $2$, $4$, $6$, and $9$ exactly once to form a three-digit number and a two-digit number. Neither number may begin with zero. What is the smallest possible result of subtracting the two-digit number from the three-digit number?
    choices:
      - text: '$108$'
        correct: true
      - text: '$-72$'
        rationale: |
          This uses $024-96$. Putting zero in hundreds makes the first value small. Check that the first number must have three digits.
      - text: '$135$'
        rationale: |
          This uses $204-69$. The first number is as small as possible. Check whether the number being subtracted can be larger.
      - text: '$144$'
        rationale: |
          This uses $240-96$. It puts the largest digits in the number being subtracted. Check whether zero can contribute less in the added tens place.
      - text: '$112$'
        rationale: |
          This uses $206-94$. It gets the hundreds and tens places right. Check whether adding four and subtracting six gives less than adding six and subtracting four.
    explanation: |
      The hundreds digit must be at least $2$. Put $9$ in the subtracted tens place and $6$ in its units place. Put $0$ in the added tens place and $4$ in its units place. This gives $204-96=108$. A hundreds digit of $4$ or more cannot give a smaller result.

  - id: q-arithmetic-number-sense-counting-and-digit-patterns-0013
    lesson: lesson-arithmetic-number-sense-counting-and-digit-patterns
    keyPoint: 1
    type: direct-computation
    difficulty: hard
    stem: |
      What is the units digit of $12^{31}$?
    choices:
      - text: '$8$'
        correct: true
      - text: '$2$'
        rationale: |
          This uses only the last digit of the base. That finds the right cycle to study. Check the position given by the exponent.
      - text: '$4$'
        rationale: |
          This uses one fewer power, $12^{30}$. Counting the first factor as an extra step can shift the cycle. Check that exponent thirty-one selects the third entry.
      - text: '$6$'
        rationale: |
          This uses the final entry of the cycle. That works for a zero remainder. Check the remainder of thirty-one divided by four.
      - text: '$3$'
        rationale: |
          This reports the remainder itself. Three is the position in the cycle. Check the digit at that position.
    explanation: |
      Only the final digit $2$ of the base matters. Its cycle is $2,4,8,6$. Since $31=4\times7+3$, use the third entry, $8$.

  - id: q-arithmetic-number-sense-counting-and-digit-patterns-0014
    lesson: lesson-arithmetic-number-sense-counting-and-digit-patterns
    keyPoint: 2
    type: direct-computation
    difficulty: hard
    figure: counting-digit-patterns-missing-corner-14
    stem: |
      The figure starts as a complete $4$ by $4$ grid of unit squares. The upper-right cell is removed along with its top and right outer edges. All boundaries of the other cells remain. How many complete squares of all sizes have sides along the remaining grid lines?
    choices:
      - text: '$26$'
        correct: true
      - text: '$15$'
        rationale: |
          This counts only the remaining unit squares. One of the sixteen cells is gone. Check the larger square sizes too.
      - text: '$29$'
        rationale: |
          This subtracts just one from the complete-grid total. Only one cell was removed. Check the larger squares whose boundaries used its outer edges.
      - text: '$27$'
        rationale: |
          This removes one square of sizes one, two, and three. Each size does lose one. Check whether the full four-by-four boundary is still complete.
      - text: '$30$'
        rationale: |
          This keeps the full-grid total. Most grid lines remain. Check the boundaries that used the missing corner.
    explanation: |
      Count by side length. There are $16-1=15$ unit squares, $9-1=8$ squares of side $2$, and $4-1=3$ squares of side $3$. The whole grid has a broken boundary, so it adds none. The total is $15+8+3=26$.

  - id: q-arithmetic-number-sense-counting-and-digit-patterns-0015
    lesson: lesson-arithmetic-number-sense-counting-and-digit-patterns
    keyPoint: 3
    type: word-problem
    difficulty: hard
    stem: |
      Figure $1$ is a $3$ by $3$ tile square. Each new figure has one more tile along each side. Only border tiles are blue. How many more blue tiles does Figure $12$ have than Figure $5$?
    choices:
      - text: '$28$'
        correct: true
      - text: '$7$'
        rationale: |
          This counts growth steps only. There are seven steps between the figures. Check how many border tiles each step adds.
      - text: '$24$'
        rationale: |
          This counts only six increases of four. The endpoint figures can be left out when counting. Check the difference of their figure numbers.
      - text: '$32$'
        rationale: |
          This counts eight increases of four. Counting both endpoints gives eight figures. Check the number of gaps between them.
      - text: '$52$'
        rationale: |
          This gives the border count for Figure twelve. That count is needed. Check that the question asks how many more than Figure five.
    explanation: |
      Figure $5$ has side length $3+4=7$ and border count $4\times7-4=24$. Figure $12$ has side length $3+11=14$ and border count $4\times14-4=52$. The increase is $52-24=28$.

  - id: q-arithmetic-number-sense-counting-and-digit-patterns-0016
    lesson: lesson-arithmetic-number-sense-counting-and-digit-patterns
    keyPoint: 4
    type: direct-computation
    difficulty: hard
    stem: |
      Use $0$, $3$, $5$, $7$, and $8$ exactly once to form a three-digit number and a two-digit number. Neither number may begin with zero. What is the largest possible sum?
    choices:
      - text: '$923$'
        correct: true
      - text: '$833$'
        rationale: |
          This uses $753+80$. It puts seven in hundreds. Check whether the largest digit should fill that place.
      - text: '$905$'
        rationale: |
          This uses $875+30$. The three-digit number is large. Check whether the five can contribute more in a tens place.
      - text: '$878$'
        rationale: |
          This uses $803+75$. It puts zero in a tens place. Check whether five could contribute more there.
      - text: '$788$'
        rationale: |
          This uses $703+85$. It puts eight in a tens place. Check whether moving eight to hundreds would increase the sum.
    explanation: |
      The largest digit, $8$, goes in hundreds. Put the next largest digits, $7$ and $5$, in the two tens places. The units digits are $3$ and $0$. The sum is $800+70+50+3=923$, as in $873+50=923$.

  - id: q-arithmetic-number-sense-counting-and-digit-patterns-0017
    lesson: lesson-arithmetic-number-sense-counting-and-digit-patterns
    keyPoint: 1
    type: direct-computation
    difficulty: exam
    stem: |
      What is the units digit of $7^{83}+3^{42}$?
    choices:
      - text: '$2$'
        correct: true
      - text: '$3$'
        rationale: |
          This finds only the units digit of the first power. Its cycle gives three. Check the second term of the sum.
      - text: '$9$'
        rationale: |
          This finds only the units digit of the second power. Its cycle gives nine. Check that the two powers are added.
      - text: '$7$'
        rationale: |
          This multiplies the units digits, $3\times9$. Multiplication is used to build powers. Check the sign between the two powers.
      - text: '$0$'
        rationale: |
          This applies the cycle for ten to the sum of the bases. Seven plus three is ten. Check that powers must be found before adding.
    explanation: |
      The cycle for $7$ is $7,9,3,1$. Since $83=4\times20+3$, the first power ends in $3$. The cycle for $3$ is $3,9,7,1$. Since $42=4\times10+2$, the second power ends in $9$. Their sum ends like $3+9=12$, so its units digit is $2$.

  - id: q-arithmetic-number-sense-counting-and-digit-patterns-0018
    lesson: lesson-arithmetic-number-sense-counting-and-digit-patterns
    keyPoint: 2
    type: word-problem
    difficulty: exam
    stem: |
      A square window is divided into a complete $6$ by $6$ grid of equal panes. How many squares of all sizes have sides along the grid lines?
    choices:
      - text: '$91$'
        correct: true
      - text: '$36$'
        rationale: |
          This counts only the panes. Each pane is a square. Check the squares formed from several panes.
      - text: '$61$'
        rationale: |
          This counts only side lengths one and two, $36+25$. Those sizes are easy to find. Check the other four sizes.
      - text: '$90$'
        rationale: |
          This adds all sizes except the whole window. The smaller squares total ninety. Check the outside boundary.
      - text: '$126$'
        rationale: |
          This uses $6(1+2+3+4+5+6)$. Six square sizes are present. Check that each size has a different number of starting positions across and down.
    explanation: |
      The counts by side length are $36,25,16,9,4,1$. Add them: $36+25+16+9+4+1=91$.

  - id: q-arithmetic-number-sense-counting-and-digit-patterns-0019
    lesson: lesson-arithmetic-number-sense-counting-and-digit-patterns
    keyPoint: 3
    type: word-problem
    difficulty: exam
    stem: |
      Figure $1$ is a filled $5$ by $5$ tile square, Figure $2$ is $6$ by $6$, and Figure $3$ is $7$ by $7$. This growth continues by adding one tile to each side length. Only the outside border is green. How many green tiles are in Figure $18$?
    choices:
      - text: '$84$'
        correct: true
      - text: '$68$'
        rationale: |
          This uses eighteen as the side length in $4s-4$. It is the requested figure number. Check how the side length starts at five.
      - text: '$88$'
        rationale: |
          This uses four full sides of length twenty-two. That is the right side length. Check the four corners for double counting.
      - text: '$80$'
        rationale: |
          This uses a side length of twenty-one. It leaves out one growth step. Check the seventeen gaps after Figure one.
      - text: '$484$'
        rationale: |
          This counts every tile in the twenty-two-by-twenty-two square. The side length is right. Check that inside tiles are not green.
    explanation: |
      Figure $18$ has side length $5+(18-1)=22$. The inside has side length $20$. Subtract the inside tiles: $22^2-20^2=484-400=84$.

  - id: q-arithmetic-number-sense-counting-and-digit-patterns-0020
    lesson: lesson-arithmetic-number-sense-counting-and-digit-patterns
    keyPoint: 4
    type: direct-computation
    difficulty: exam
    stem: |
      Use the digits $1$, $4$, $5$, $8$, and $9$ exactly once to form a three-digit number and a two-digit number. What is the smallest possible difference when the two-digit number is subtracted from the three-digit number?
    choices:
      - text: '$47$'
        correct: true
      - text: '$65$'
        rationale: |
          This uses $154-89$. Putting one in hundreds is a good start. Check the order of the remaining digits in both numbers.
      - text: '$56$'
        rationale: |
          This uses $145-89$. It makes the first number as small as possible. Check whether the second number can be larger.
      - text: '$172$'
        rationale: |
          This uses $185-49$. It puts a small digit in the subtracted tens place. Check whether a larger number being subtracted would reduce the difference.
      - text: '$243$'
        rationale: |
          This adds $145+98$. These are useful digit arrangements for the minimum difference. Check the operation requested.
    explanation: |
      Put $1$ in hundreds to keep the three-digit number small. Put $9$ in the subtracted tens place and $8$ in its units place. The digits left make $45$, so the three-digit number is $145$. The difference is $145-98=47$. Using $4$ or more in hundreds gives at least $400-98=302$, so it cannot do better.
```

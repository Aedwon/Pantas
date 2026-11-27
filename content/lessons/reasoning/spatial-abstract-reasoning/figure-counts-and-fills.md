---
_id: "lesson-spatial-abstract-reasoning-figure-counts-and-fills"
title: "Figure Counts and Fills"
summary: "Continue side and dot counts."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
isActive: true
part: 1
partCount: 3
ordering: 1
keyPoints:
  - "Continue side and dot counts."
  - "Continue a repeating fill pattern."
---
## Core Concept

### Tracking One Feature at a Time

A **figure series** shows pictures in order and asks what comes next or fills a blank.

Track one visual feature at a time from left to right:

- number of sides or dots;
- which way a shape or line points;
- **fill** (the color or shading inside a shape);
- size;
- position inside the frame.

Check that your rule works on every shown step before picking an answer. For a figure with $2$, $4$, and $6$ dots, each step adds $2$ dots, so the next figure has $8$ dots.

:::check
A series shows circles with $10$, $7$, and $4$ dots, and the circles also turn darker at each step. How many dots belong in the fourth circle?
:::answer
The answer is **$1$ dot**. Tracking dot count alone gives $10, 7, 4$, which drops $3$ dots at each step ($4-3=1$).
:::

### Counting Sides and Dots

When a feature is a count, write the counts as a number sequence and find the difference between each pair.

<!-- FIGURE WANTED: three equal square frames containing circles with 1 dot, 2 dots, and 3 dots, followed by a blank fourth frame -->

Find the next dot count for circles with $1$, $2$, and $3$ dots:

1. Counts $1, 2, 3$ add $1$ dot per step.
2. Next count: $3+1=4$ dots.

The same method works for polygon sides: triangle ($3$), square ($4$), pentagon ($5$), hexagon ($6$), heptagon ($7$), and octagon ($8$).

:::pair #skip-a-count
Right: for triangle ($3$ sides), square ($4$), pentagon ($5$), the next shape has $5+1=6$ sides (**Hexagon with six sides**).
Wrong: pick **Heptagon with seven sides** ($7$ sides) by skipping $6$.
Seeing sides grow can make a larger jump look right. Always write the counts ($3, 4, 5$) and check the exact step size ($+1$).
:::

:::check
A series shows shapes with $3$, $5$, and $7$ sides. How many sides does the fourth shape have?
:::answer
The answer is **$9$ sides**. The side counts $3, 5, 7$ increase by $2$ each time, so $7+2=9$.
:::

### Repeating and Alternating Fills

To **alternate** means to switch back and forth between two states, such as black and white. Other patterns repeat a cycle of $3$ or more fills, such as black, black, white.

1. Group pentagons with black, black, white, black, black, ______: (black, black, white) then (black, black, ______).
2. The shape stays a pentagon, and the missing fill is **white**.

:::why
Why check if the cycle restarted? In $\dfrac{1}{4}, \dfrac{1}{2}, \dfrac{3}{4}, \dfrac{1}{4}, \dfrac{1}{2}$, figure $4$ drops back to $\dfrac{1}{4}$, proving the cycle resets after $\dfrac{3}{4}$.
:::

:::pair #repeat-last-fill
Right: in black, black, white, black, black, the next figure is a **White pentagon**.
Wrong: pick a **Black pentagon** because the last two figures are black.
Two matching figures at the end make it look like black continues. Compare the partial group with the first full group.
:::

:::pair #skip-cycle-restart
Right: in $\dfrac{1}{4}, \dfrac{1}{2}, \dfrac{3}{4}, \dfrac{1}{4}, \dfrac{1}{2}$, the next fills are $\dfrac{3}{4}$ and then a **Quarter-filled square**.
Wrong: keep increasing past $\dfrac{3}{4}$ to a **Fully filled square**.
The first three figures grow toward full, which hides the reset. Check figure $4$ for a restart.
:::

:::check
A series of triangles is filled white, gray, gray, black, white, gray, gray, ______. What fill belongs in the eighth triangle?
:::answer
The answer is **black**. The group white, gray, gray, black repeats, and the eighth triangle sits in the slot where the first group has black.
:::

## Examples

### #1: Increasing Number of Sides

A triangle is followed by a square, then a pentagon. Which figure completes the series: a circle, a triangle, a hexagon, or an octagon?

<!-- ILLUSTRATION: a triangle, a square, and a pentagon in separate frames, followed by a blank; choices circle, triangle, hexagon, and octagon -->

**Solution:**

1. Count the sides of each shown shape: triangle ($3$), square ($4$), pentagon ($5$).
2. Find the change between steps: $4-3=1$ and $5-4=1$.
3. Add $1$ side to the pentagon: $5+1=6$ sides.

The figure that completes the series is a **hexagon** ($6$ sides).

**Check:** A circle has no straight sides, a triangle ($3$) repeats the start, and an octagon ($8$) adds $3$ sides instead of $1$. Only a hexagon has $6$ sides.

### #2: Alternating Fill

The series shows a black circle, a white circle, a black circle, and a white circle. What figure comes next?

<!-- ILLUSTRATION: a black circle, a white circle with a black outline, a black circle, and a white circle with a black outline, followed by a blank frame -->

**Solution:**

1. Check the outline shape: every frame shows a circle, so the next figure is a circle.
2. Check the fill from left to right: black, white, black, white.
3. The fill alternates between black and white, so after white comes black.

The next figure is a **black circle**.

**Check:** Odd frames ($1$ and $3$) are black and even frames ($2$ and $4$) are white, so frame $5$ (odd) must be black.

### #3: Squares with Partial Fills

A series of squares is filled to $\dfrac{1}{4}$, $\dfrac{1}{2}$, $\dfrac{3}{4}$, $\dfrac{1}{4}$, and $\dfrac{1}{2}$. Continue the pattern for two further figures. What fill appears in the second further figure?

<!-- FIGURE WANTED: five equal square frames shaded from the bottom to 1/4, 1/2, 3/4, 1/4, and 1/2, followed by two blank frames -->

**Solution:**

1. Check the outline shape: every frame shows a square.
2. Find the repeating fill cycle: $\dfrac{1}{4}$, $\dfrac{1}{2}$, $\dfrac{3}{4}$, then back to $\dfrac{1}{4}$ at frame $4$.
3. Take the first step after the shown $\dfrac{1}{2}$ (frame $5$): frame $6$ is $\dfrac{3}{4}$ filled.

4. Frame $7$ comes after $\dfrac{3}{4}$, so the cycle resets to $\dfrac{1}{4}$.

The second further figure is a **quarter-filled square** ($\dfrac{1}{4}$).

**Check:** Do not stop after one step ($\dfrac{3}{4}$) and do not keep growing to a fully filled square, because the fourth frame already proved the cycle resets at $\dfrac{1}{4}$.

## Traps to Watch For

:::checklist
- Side or dot counts: write the numbers and check each step size, so $3, 4, 5$ goes to $6$ (hexagon), not $7$ (heptagon). {#skip-a-count}
- Two matching fills in a row: check the full repeating group, so black, black, white, black, black goes to white. {#repeat-last-fill}
- Growing fill that resets: check later figures for a restart before assuming full fill. {#skip-cycle-restart}
:::

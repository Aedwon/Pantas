---
_id: "lesson-spatial-abstract-reasoning-combined-and-mixed-figure-patterns"
title: "Combined and Mixed Figure Patterns"
summary: "Check every changing feature against the answer choices."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
isActive: true
part: 3
partCount: 3
ordering: 3
keyPoints:
  - "Check every changing feature against the answer choices."
  - "Separate odd and even positions into their own patterns."
---
## Core Concept

### Tracking Multiple Features Together

Many figure series change two or three features at once, such as size, fill, dot count, and turn angle. Follow one feature across all frames, write its next state, and repeat for each other feature.

1. Look at a row of $5$ triangles: small black, medium white, large black, small white, medium black, then a blank.
2. Track size alone: small, medium, large, small, medium. The $3$-step cycle puts **large** next.
3. Track fill alone: black, white, black, white, black. The alternating rule puts **white** next.
4. Combine both results: the sixth figure is a **large white triangle**.

:::why
Why write down each feature separately before looking at the choices? Wrong choices often copy one correct change while freezing a second feature at the previous frame.
:::

:::pair #freeze-one-feature
Right: after small black, medium white, large black, small white, medium black, the next figure is **Large white triangle**.
Wrong: pick **Large black triangle** because size moved to large.
Updating only size leaves the fill frozen at black. Check every changing feature before choosing.
:::

:::check
A series shows a small square with $1$ dot, a medium square with $2$ dots, a small square with $3$ dots, and a medium square with $4$ dots. What size and dot count belong in the fifth square?
:::answer
The answer is a **small square with $5$ dots**. Size alternates small and medium ($5$th is small), and dots increase by $1$ each time ($4+1=5$).
:::

### Interleaved Odd and Even Patterns

An **interleaved pattern** mixes two separate series in one row. Read positions $1, 3, 5, \dots$ (the odd positions) as one track, and positions $2, 4, 6, \dots$ (the even positions) as a second track.

<!-- FIGURE WANTED: five labeled frames in one row, 1 circle with 1 dot, 2 square with 4 dots, 3 circle with 2 dots, 4 square with 4 dots, 5 blank; bracket odd frames 1 3 5 above and even frames 2 4 below -->

1. Take this $5$-frame series: circle ($1$ dot), square ($4$ dots), circle ($2$ dots), square ($4$ dots), blank.
2. Group the odd positions ($1, 3, 5$): circle with $1$ dot, circle with $2$ dots, blank. Frame $5$ is a **circle with $3$ dots**.
3. Group the even positions ($2, 4$): square with $4$ dots, square with $4$ dots. The square track repeats $4$ dots.

:::why
Why skip neighboring frames when shapes switch back and forth? Each shape runs its own rule in its own slots, so frame $4$ cannot tell you what goes in frame $5$.
:::

:::pair #repeat-neighbor-track
Right: at odd position $5$ after square with $4$ dots, pick **Circle with three dots**.
Wrong: pick **Square with four dots** by continuing frame $4$ right into frame $5$.
Frame $4$ belongs to the even track. Position $5$ is odd, so follow frames $1$ and $3$ instead.
:::

:::pair #count-across-tracks
Right: compare odd frames $1$ and $3$ ($1$ dot, then $2$ dots) to get **Circle with three dots** at frame $5$.
Wrong: pick **Circle with five dots** by counting $5$ across all frames.
Counting across both tracks treats position number as dot count. Count only within the circle track.
:::

:::check
A series shows a left arrow, a circle with $2$ dots, an up arrow, a circle with $4$ dots, and a right arrow. What belongs in the sixth position?
:::answer
The answer is a **circle with $6$ dots**. Position $6$ is even, and the even positions ($2, 4, 6$) are circles rising by $2$ dots each time.
:::

## Examples

### #1: Two Features and Answer Choices

The available sizes, from smallest to largest, are small, medium, large, and extra large. The series shows a small black triangle, a medium white triangle, then a large black triangle. Which choice completes the series?

- A. Extra-large white triangle
- B. Extra-large black triangle
- C. Large white triangle
- D. Small white triangle

<!-- ILLUSTRATION: small black triangle, medium white triangle, large black triangle, blank; choices A extra-large white triangle, B extra-large black triangle, C large white triangle, D small white triangle; show four clearly different size levels -->

**Solution:**

1. Track the size across the three triangles: small, medium, large.
2. The next defined size in the given list is **extra large**.
3. Track the fill across the three triangles: black, white, black. Alternating gives **white** next.
4. Match both rules against the choices: choice A has extra-large size and white fill. Choice B misses the fill, while C and D miss the size.

The correct choice is **A (Extra-large white triangle)**.

**Check:** Check all three tracks in choice A: triangle outline stays the same, size steps up to extra large, and fill alternates from black to white.

### #2: Circles and Squares

The series shows a circle with $1$ dot, a white square, a circle with $2$ dots, and a black square. These are followed by a circle with $3$ dots, a white square, a circle with $4$ dots, and a blank. What belongs in the blank?

<!-- ILLUSTRATION: eight labeled positions in reading order, 1 outlined circle with 1 dot, 2 white square, 3 outlined circle with 2 dots, 4 black square, 5 outlined circle with 3 dots, 6 white square, 7 outlined circle with 4 dots, 8 blank; keep dots clearly visible inside circles -->

**Solution:**

1. The outlines alternate between circles and squares, so split odd and even positions.
2. Odd positions ($1, 3, 5, 7$) are outlined circles with $1, 2, 3, 4$ dots.
3. Even positions ($2, 4, 6$) are squares with fills white, black, white.

:::try
Finish the last step: position $8$ is even, so find the outline and fill that belong in the blank.
:::answer
The answer is a **black square**. Position $8$ continues the even square track, where fill alternates white, black, white, **black**.

**Check:** Notice frame $7$ has a circle with $4$ dots, so do not put $5$ dots in frame $8$; even frames follow only the square fill rule.
:::

## Traps to Watch For

:::checklist
- Multiple changing features: write each feature's next state before checking the choices, so you do not freeze one track. {#freeze-one-feature}
- Interleaved shapes: split odd positions ($1, 3, 5$) from even positions ($2, 4, 6$) before picking the next figure. {#repeat-neighbor-track}
- Dot counts in mixed tracks: count only within that shape's own positions, not across every frame. {#count-across-tracks}
:::

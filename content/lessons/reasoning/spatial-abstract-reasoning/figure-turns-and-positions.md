---
_id: "lesson-spatial-abstract-reasoning-figure-turns-and-positions"
title: "Figure Turns and Positions"
summary: "Track turn direction and compare the size of each turn."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
isActive: true
part: 2
partCount: 3
ordering: 2
keyPoints:
  - "Track turn direction and compare the size of each turn."
  - "Track a moving detail through its positions."
---
## Core Concept

### Turn Direction and Angle Size

**Clockwise** means turning the same way a clock's hands move (top to right to bottom to left). **Counterclockwise** means turning the opposite way.

A full turn is $360^\circ$, a half-turn is $180^\circ$, a quarter-turn is $90^\circ$, and an eighth-turn is $45^\circ$.

<!-- FIGURE WANTED: a compass-style circle showing 8 directions every 45 degrees clockwise from up (0 degrees) through upper-right (45 degrees) and right (90 degrees) back to up (360 degrees) -->

1. Look at a line inside a square pointing up ($0^\circ$), upper-right ($45^\circ$), then right ($90^\circ$).
2. Each step turns $45^\circ$ clockwise.
3. Add one more $45^\circ$ clockwise turn from right ($90^\circ$): $90^\circ+45^\circ=135^\circ$, which points **lower-right**.

:::pair #double-turn-angle
Right: from up, upper-right, right ($+45^\circ$ each), the next line points **lower-right** ($135^\circ$).
Wrong: jump straight to **down** ($180^\circ$).
Down is a main compass point, so it is tempting to skip the diagonal step. Measure each turn in $45^\circ$ steps before moving.
:::

:::check
An arrow points lower-left, then upper-left, then upper-right. What direction comes next?
:::answer
The answer is **lower-right**. Each step turns $90^\circ$ clockwise ($225^\circ, 315^\circ, 45^\circ$), so $45^\circ+90^\circ=135^\circ$ (lower-right).
:::

### Alternating vs. Continuous Turns

Not every rotation keeps spinning one way. Some series switch back and forth between two directions.

1. Check an arrow pointing up, right, up, right.
2. Moves: up to right ($90^\circ$ clockwise), right to up ($90^\circ$ counterclockwise), up to right.
3. Next from right: turn $90^\circ$ counterclockwise back to **up**.

:::why
Why check every frame after the first turn? The first pair looks like a continuous clockwise spin until frame $3$ flips back to up.
:::

:::pair #assume-continuous-turn
Right: for arrows pointing up, right, up, right, the next arrow points **up**.
Wrong: assume continuous clockwise turns and pick **down**.
Checking only two frames makes $90^\circ$ clockwise look certain. Verify your rule on frames $3$ and $4$.
:::

:::check
An arrow points left, up, left, up. If you take two more steps in this pattern, which way does the second new arrow point?
:::answer
The answer is **up**. One more step goes to left, and the second step goes back to up.
:::

### Moving Details Around a Frame

A small mark, such as a dot, can move from corner to corner or side to side inside a steady frame.

<!-- ILLUSTRATION: four equal square frames with one dot each, at top-left, top-right, bottom-right, and bottom-left in that order -->

1. Trace the dot in the four frames above: top-left, top-right, bottom-right, bottom-left.
2. At each step, the dot moves $1$ corner clockwise around the square.
3. After visiting all $4$ corners, the next move from bottom-left returns to **top-left**.

:::pair #skip-fourth-corner
Right: a dot at top-left, top-right, bottom-right moves $1$ more corner clockwise to **bottom-left**.
Wrong: restart early and pick **top-left**.
A square has $4$ corners, not $3$. Check that every corner on the loop was visited before restarting at top-left.
:::

:::check
A dot moves counterclockwise around a square's corners: top-right, top-left, bottom-left. Which corner comes next?
:::answer
The answer is **bottom-right**. Moving $1$ corner counterclockwise from bottom-left lands on bottom-right.
:::

## Examples

### #1: Constant Rotation

An arrow points up, then upper-right, then right, then lower-right. Which direction completes the series: down, left, up, or lower-left?

<!-- ILLUSTRATION: four equal frames containing arrows pointing up, upper-right, right, and lower-right, followed by a blank; choices are arrows pointing down, left, up, and lower-left -->

**Solution:**

1. Write each arrow's clockwise angle from up ($0^\circ$): $0^\circ$, $45^\circ$, $90^\circ$, $135^\circ$.
2. Each step adds $45^\circ$ clockwise.
3. Add $45^\circ$ to $135^\circ$:

$$\text{Next}=135^\circ+45^\circ=180^\circ$$

4. $180^\circ$ points straight **down**.

The answer is **down**.

**Check:** Notice the arrow takes $4$ steps of $45^\circ$ from up ($0^\circ$) to down ($180^\circ$), which equals one half-turn ($4\times45^\circ=180^\circ$).

### #2: Changing Position

A dot appears at the top-left, top-right, bottom-right, then bottom-left corner of a square frame. At which corner should the dot appear next?

<!-- ILLUSTRATION: five equal square frames, dots at top-left, top-right, bottom-right, bottom-left, then a blank fifth frame -->

**Solution:**

1. Trace the dot's path: top-left $\to$ top-right $\to$ bottom-right $\to$ bottom-left.
2. Each step moves $1$ corner clockwise along the outer edge of the square.
3. Move $1$ corner clockwise from bottom-left: that returns to **top-left**.

The dot appears at the **top-left** corner.

**Check:** All $4$ corners were visited in frames $1$ through $4$, so frame $5$ starts the second lap at top-left.

### #3: Growing Turns

The arrows in a series point up, upper-right, lower-right, then left. Which direction completes the series: down, right, up, or upper-left?

<!-- FIGURE WANTED: arrows pointing up, upper-right, lower-right, and left in four equal frames, followed by a blank; choices arrows pointing down, right, up, and upper-left; do not label turn angles (redraw of 04-arrows-pointing-up-upper-right.svg, whose fourth arrow points lower-left and fits no turn rule) -->

**Solution:**

1. Measure frame $1$ to $2$: up ($0^\circ$) to upper-right ($45^\circ$) is $+45^\circ$.
2. Measure frame $2$ to $3$: upper-right ($45^\circ$) to lower-right ($135^\circ$) is $+90^\circ$.
3. Measure frame $3$ to $4$: lower-right ($135^\circ$) to left ($270^\circ$) is $+135^\circ$.
4. Notice the turns grow by $45^\circ$ each time, so the next turn is $135^\circ+45^\circ=180^\circ$.
5. Add $180^\circ$ clockwise from left ($270^\circ$): $270^\circ+180^\circ=450^\circ$.
6. Subtract one full circle ($360^\circ$): $450^\circ-360^\circ=90^\circ$.
7. Read $90^\circ$ on the compass: the fifth arrow points **right**.

The answer is **right**.

**Check:** A $180^\circ$ turn always points the exact opposite way, and the opposite of left is right.

### #4: Arrows in Squares

An arrow inside a square points up, right, up, and right. Which direction completes the series: up, down, right, or left?

<!-- FIGURE WANTED: four equal square frames containing arrows pointing up, right, up, and right, followed by a blank fifth frame; choices arrows pointing up, down, right, and left -->

**Solution:**

1. Compare frame $1$ to $2$: the arrow turns $90^\circ$ clockwise from up to right.
2. Compare frame $2$ to $3$: the arrow turns $90^\circ$ counterclockwise back to up.
3. Compare frame $3$ to $4$: the arrow turns $90^\circ$ clockwise back to right.

4. Apply the alternating rule to the fourth arrow (pointing right): turn $90^\circ$ counterclockwise back to up.

The fifth arrow points **up**.

**Check:** Odd frames ($1$ and $3$) point up and even frames ($2$ and $4$) point right, so frame $5$ (odd) points up.

## Traps to Watch For

:::checklist
- Diagonal vs. main compass turns: count in $45^\circ$ steps, so $+45^\circ$ from right goes to lower-right, not down. {#double-turn-angle}
- Alternating turns: check frames $3$ and $4$ before assuming a continuous spin, so up, right, up, right returns to up. {#assume-continuous-turn}
- Corner loops in a square: when the rule moves one adjacent corner per step, check all $4$ corners before restarting at the first corner. {#skip-fourth-corner}
:::

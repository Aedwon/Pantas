---
_id: "lesson-logical-verbal-reasoning-sequence-positions-and-operations"
title: "Separate Positions and Alternating Operations"
summary: "Follow separate odd-position and even-position rules."
subject: "subject-reasoning"
topic: "topic-logical-verbal-reasoning"
isActive: true
part: 2
partCount: 4
ordering: 8
keyPoints:
  - "Follow separate odd-position and even-position rules."
  - "Track a repeating cycle of operations."
---
## Core Concept

### Separate Rules by Position

In an **interleaved pattern**, odd positions follow one rule and even positions follow another. Odd and even name the position ($1, 2, 3, 4, \ldots$), not the number value.

1. Look at $1, 10, 3, 8, 5, 6, \ldots$ and find the $7$th term.
2. Read the odd positions ($1, 3, 5$): $1, 3, 5$ (adds $2$ each time).
3. Read the even positions ($2, 4, 6$): $10, 8, 6$ (subtracts $2$ each time).
4. Position $7$ is odd, so continue the odd track: $5+2=7$.

:::why
Why read both tracks? Almost any list looks neat if you ignore half the terms, so check that the odd and even tracks both fit simple rules.
:::

:::pair #wrong-position-track
Right: the $7$th term of $1, 10, 3, 8, 5, 6, \ldots$ is $5+2=7$.
Wrong: the $7$th term is $4$.
$4$ continues the even track ($10, 8, 6, 4$). Label the blank's position first: position $7$ is odd.
:::

:::check
Find the $8$th term of $20, 2, 18, 5, 16, 8, 14, \ldots$
:::answer
The answer is $11$. Position $8$ is even. The even positions ($2, 5, 8$) increase by $3$, so position $8$ is $8+3=11$.
:::

### Alternating Operations

With **alternating operations**, the move switches back and forth between two steps from each term to the next.

1. Look at $4, 7, 6, 9, 8, 11, \ldots$
2. Write the move between each pair: $4+3=7$, $7-1=6$, $6+3=9$, $9-1=8$, $8+3=11$.
3. The shown terms fit the cycle $+3$, then $-1$.
4. The last move was $+3$, so the next move is $-1$: $11-1=10$.

:::pair #repeat-wrong-step
Right: after $8+3=11$ in the $+3, -1$ cycle, apply $-1$: $11-1=10$.
Wrong: apply $+3$ again: $11+3=14$.
The big jump $+3$ is easy to repeat by habit. Check which move just happened before taking the next step.
:::

### Two-Operation Rules

Some sequences repeat the same two-operation rule at every single step, such as "double and add $1$."

1. Look at $2, 5, 11, 23, 47, \ldots$
2. Test "$\times2$, then $+1$": $2\times2+1=5$, $5\times2+1=11$, $11\times2+1=23$, $23\times2+1=47$.
3. Apply the full rule to $47$: $47\times2+1=94+1=95$.

:::pair #drop-second-operation
Right: for $2, 5, 11, 23, 47, \ldots$, double $47$ and add $1$ to get $95$.
Wrong: double $47$ to get $94$.
Doubling gives most of the jump, so it is easy to stop early. Check both parts of the rule on the last step.
:::

## Examples

### #1: Interleaved Odd and Even Positions

Find the next term in the sequence: $2, 9, 4, 12, 6, 15, \ldots$

**Solution:**

1. Label positions $1$ to $6$. The blank is position $7$ (odd).
2. Odd positions ($1, 3, 5$): $2, 4, 6$ (add $2$).
3. Even positions ($2, 4, 6$): $9, 12, 15$ (add $3$).
4. Add $2$ to $6$ for position $7$:

$$\text{Term 7}=6+2=8$$

The next term is $8$.

### #2: Alternating Operations

Find the next term in the sequence: $3, 6, 8, 16, 18, 36, \ldots$

**Solution:**

1. Write each move left to right:

$$3\times2=6,\quad 6+2=8$$

$$8\times2=16,\quad 16+2=18$$

$$18\times2=36$$

2. The shown terms fit $\times2$, then $+2$, repeating.
3. The last move was $\times2$, so add $2$ to $36$ for term $7$:

$$\text{Term 7}=36+2=38$$

The next term is $38$.

### #3: Two-Operation Rule

Find the next term using the simplest two-operation rule that fits every step: $1, 4, 13, 40, \ldots$

**Solution:**

1. Test "multiply by $3$, add $1$" on terms $2$ and $3$:

$$\text{Term 2}=1\times3+1=4,\quad \text{Term 3}=4\times3+1=13$$

2. Confirm on term $4$:

$$\text{Term 4}=13\times3+1=40$$

3. Apply the full rule to $40$ for term $5$:

$$\text{Term 5}=40\times3+1=121$$

The next term is $121$.

### #4: Paired Letter Tracks

Find the next letter pair, using English alphabet positions ($A=1$ through $Z=26$): $AZ, BY, DW, GT, \ldots$

**Solution:**

1. Track the first letters separately: $A(1), B(2), D(4), G(7)$.
2. Their forward jumps are $+1, +2, +3$, so add $4$ next: $7+4=11$, which is $K$.
3. Track the second letters separately: $Z(26), Y(25), W(23), T(20)$. Their jumps are:

$$25-26=-1,\quad 23-25=-2,\quad 20-23=-3$$

:::try
Finish the last step: find the next jump, apply it to $T(20)$, and combine both letters.
:::answer
The answer is **$KP$**. The next jump is $-4$, so $20-4=16$, which is $P$.
:::

## Traps to Watch For

:::checklist
- Interleaved sequence: check whether the missing position is odd or even before picking a track, so position $7$ of $1, 10, 3, 8, 5, 6$ gives $7$, not $4$. {#wrong-position-track}
- Alternating cycle: check which step came last instead of repeating it, so $+3, -1$ after $11$ gives $10$, not $14$. {#repeat-wrong-step}
- Two-operation rule: apply both operations in order at the final step, so $47\times2+1=95$, not $94$. {#drop-second-operation}
:::

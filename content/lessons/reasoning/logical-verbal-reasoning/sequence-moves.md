---
_id: "lesson-logical-verbal-reasoning-sequence-moves"
title: "Repeated and Changing Moves"
summary: "Find a constant difference or ratio."
subject: "subject-reasoning"
topic: "topic-logical-verbal-reasoning"
isActive: true
part: 1
partCount: 4
ordering: 7
keyPoints:
  - "Find a constant difference or ratio."
  - "Continue a pattern of changing differences."
---
## Core Concept

### Constant Difference

A **sequence** is an ordered list of numbers or letters, and each item is a **term**. An **arithmetic pattern** adds or subtracts the same number at every step.

1. Check $31, 24, \ldots, 10, 3$.
2. Subtract adjacent terms: $24-31=-7$ and $3-10=-7$.
3. Apply the same move to $24$: $24-7=17$.
4. Check the next step: $17-7=10$, which matches the list.

:::pair #wrong-step-size
Right: for $31, 24, \ldots, 10, 3$, the missing term is $24-7=17$.
Wrong: the missing term is $7$.
$7$ is the size of each decrease, not the number that sits in the blank. Always apply the move to the term right before the gap.
:::

:::check
Find the missing term in $12, 18, 24, \ldots, 36$.
:::answer
The answer is $30$. Each step adds $6$, so $24+6=30$, and $30+6=36$.
:::

### Constant Ratio

A **geometric pattern** multiplies or divides every term by the same number, called the **ratio**.

1. Check $64, 32, \ldots, 8, 4$.
2. Compare ratios: $\dfrac{32}{64}=\dfrac{1}{2}$ and $\dfrac{4}{8}=\dfrac{1}{2}$.
3. Multiply $32$ by $\dfrac{1}{2}$ (or divide by $2$): $32\div2=16$.
4. Check the next step: $16\div2=8$, which fits.

:::why
Why check later pairs like $8$ to $4$? A single pair like $64$ to $32$ also fits subtracting $32$, which gives $0$ next and fails at $8$ and $4$.
:::

:::pair #add-last-gap-in-ratio
Right: for $2, 6, 18, 54, \ldots$, multiply by $3$: $54\times3=162$.
Wrong: add the last gap $54-18=36$: $54+36=90$.
Gaps stay equal only in arithmetic patterns. Here the ratios stay equal ($\dfrac{6}{2}=3$, $\dfrac{18}{6}=3$, $\dfrac{54}{18}=3$), so keep multiplying by $3$.
:::

:::check
Find the next term in $5, 15, 45, 135, \ldots$
:::answer
The answer is $405$. Each term is multiplied by $3$, so $135\times3=405$.
:::

### Changing Differences

With **changing differences**, the amount added or subtracted grows or shrinks by its own simple rule. Subtract each term from the next to see the moves.

1. Check $1, 4, 9, 16, \ldots$
2. Find the differences: $4-1=3$, $9-4=5$, and $16-9=7$.
3. The differences grow by $2$ each time, so the next difference is $7+2=9$.
4. Add $9$ to the last term: $16+9=25$.

:::pair #repeat-last-gap
Right: for $2, 3, 5, 8, 12, \ldots$, the gaps are $+1, +2, +3, +4$, so add $5$: $12+5=17$.
Wrong: repeat the last gap $+4$: $12+4=16$.
Repeating $+4$ fits only the last step. Check all gaps from the start to see that the gap grows by $1$ each time.
:::

:::check
Find the next term in $3, 5, 9, 15, 23, \ldots$
:::answer
The answer is $33$. The differences are $+2, +4, +6, +8$, so the next difference is $+10$, giving $23+10=33$.
:::

## Examples

### #1: Arithmetic Pattern

Find the next term in the sequence: $4, 9, 14, 19, \ldots$

**Solution:**

1. Find the difference between neighboring terms.

$$9-4=5,\quad 14-9=5,\quad 19-14=5$$

2. Every step adds $5$. Add $5$ to the last term.

$$19+5=24$$

The next term is $24$.

**Check:** Subtract $5$ backward from $24$: $24-5=19$, which matches the last shown term.

### #2: Geometric Pattern

Find the next term in the sequence: $2, 6, 18, 54, \ldots$

**Solution:**

1. Divide each term by the term before it to test for a constant ratio.

$$\dfrac{6}{2}=3,\quad \dfrac{18}{6}=3,\quad \dfrac{54}{18}=3$$

2. Every step multiplies by $3$. Multiply the last term by $3$.

$$54\times3=162$$

The next term is $162$.

**Check:** Split $54\times3$: $50\times3=150$ and $4\times3=12$, and $150+12=162$.

### #3: Missing Term in a Shrinking Pattern

Find the missing term in the sequence: $64, 32, \ldots, 8, 4$.

**Solution:**

1. Compare the first pair and the last pair: $64$ to $32$ halves the number, and $8$ to $4$ halves the number.
2. Divide $32$ by $2$ to fill the blank.

$$32\div2=16$$

The missing term is $16$.

**Check:** Divide $16$ by $2$ to step to the next shown term: $16\div2=8$, which matches.

### #4: Changing Differences

Find the next term in the sequence: $2, 3, 5, 8, 12, \ldots$

**Solution:**

1. Subtract each term from the next to list the differences.

$$3-2=1,\quad 5-3=2$$

$$8-5=3,\quad 12-8=4$$

2. The differences are $1, 2, 3, 4$, so each gap increases by $1$.
3. Find the next gap: $4+1=5$.

:::try
Finish the last step: add the next gap to $12$.
:::answer
The answer is $17$. Add $5$ to the last term: $12+5=17$.

**Check:** The differences $1, 2, 3, 4, 5$ increase by $1$ at every step, and $17-12=5$.
:::

## Traps to Watch For

:::checklist
- Asked for a missing term: put the result of the move in the blank, never the step size by itself. {#wrong-step-size}
- Rapidly growing numbers: test ratios before adding the last gap, so $2, 6, 18, 54$ multiplies by $3$ to $162$, not $90$. {#add-last-gap-in-ratio}
- Growing gaps between terms: check every gap from the start instead of repeating the last one, so $2, 3, 5, 8, 12$ adds $5$ to $17$. {#repeat-last-gap}
:::

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

A **sequence** is an ordered list of numbers or letters, and each item is a **term**. An **arithmetic pattern** adds or subtracts the same number at each step.

1. Find the missing term in $31, 24, \ldots, 10, 3$.
2. Subtract adjacent terms: $24-31=-7$ and $3-10=-7$.
3. Apply the same move to $24$: $24-7=17$.
4. Check the next step: $17-7=10$, which matches the list.

:::pair #wrong-step-size
Right: for $31, 24, \ldots, 10, 3$, the missing term is $24-7=17$.
Wrong: the missing term is $7$.
$7$ is the size of each decrease, not the number that sits in the blank. Apply the move to the term right before the gap.
:::

### Constant Ratio

A **geometric pattern** multiplies each term by the same number, called the **ratio**. Dividing by $2$ is the same as multiplying by a ratio of $\dfrac{1}{2}$.

1. Find the missing term in $64, 32, \ldots, 8, 4$.
2. Compare ratios: $\dfrac{32}{64}=\dfrac{1}{2}$ and $\dfrac{4}{8}=\dfrac{1}{2}$.
3. Multiply $32$ by $\dfrac{1}{2}$ (or divide by $2$): $32\div2=16$.
4. Check the next step: $16\div2=8$, which fits.

:::why
Why check later pairs like $8$ to $4$? A single pair like $64$ to $32$ also fits subtracting $32$, which gives $0$ next and fails at $8$ and $4$.
:::

:::pair #add-last-gap-in-ratio
Right: for $2, 6, 18, 54, \ldots$, multiply by $3$: $54\times3=162$.
Wrong: add the last gap $54-18=36$: $54+36=90$.
Equal gaps fit an arithmetic pattern. Here the gaps are $4, 12, 36$, but the ratios are equal ($\dfrac{6}{2}=3$, $\dfrac{18}{6}=3$, $\dfrac{54}{18}=3$), so keep multiplying by $3$.
:::

:::check
Find the missing term in $3, 12, \ldots, 192$.
:::answer
The answer is $48$. The ratio is $\dfrac{12}{3}=4$, so $12\times4=48$, and $48\times4=192$ fits.
:::

### Changing Differences

With **changing differences**, the amount added or subtracted grows or shrinks by its own simple rule. Subtract each term from the next to see the moves.

1. Find the next term in $1, 4, 9, 16, \ldots$
2. Find the differences: $4-1=3$, $9-4=5$, and $16-9=7$.
3. The differences grow by $2$ each time, so the next difference is $7+2=9$.
4. Add $9$ to the last term: $16+9=25$.

:::pair #repeat-last-gap
Right: for $2, 3, 5, 8, 12, \ldots$, the gaps are $+1, +2, +3, +4$, so add $5$: $12+5=17$.
Wrong: repeat the last gap $+4$: $12+4=16$.
Repeating $+4$ fits the last step only. Check each gap from the start: here the gap grows by $1$ each time.
:::

## Examples

### #1: Arithmetic Pattern

Find the next term in the sequence: $4, 9, 14, 19, \ldots$

**Solution:**

1. Subtract neighboring terms:

$$9-4=5,\quad 14-9=5,\quad 19-14=5$$

2. Add $5$ to $19$ for term $5$:

$$\text{Term 5}=19+5=24$$

The next term is $24$.

### #2: Geometric Pattern

Find the next term in the sequence: $4, 12, 36, 108, \ldots$

**Solution:**

1. Divide each term by the prior term for a constant ratio:

$$\dfrac{12}{4}=3,\quad \dfrac{36}{12}=3,\quad \dfrac{108}{36}=3$$

2. Multiply $108$ by $3$ for term $5$:

$$\text{Term 5}=108\times3=324$$

The next term is $324$.

### #3: Missing Term in a Shrinking Pattern

Find the missing term in the sequence: $243, 81, \ldots, 9, 3$.

**Solution:**

1. Compare the first pair and the last pair:

$$\dfrac{81}{243}=\dfrac{1}{3},\quad \dfrac{3}{9}=\dfrac{1}{3}$$

2. Divide $81$ by $3$ for term $3$:

$$\text{Term 3}=81\div3=27$$

3. Check the next step: $27\div3=9$, which matches the list.

The missing term is $27$.

### #4: Changing Differences

Find the next term in the sequence: $6, 8, 11, 15, 20, \ldots$

**Solution:**

1. List the differences:

$$8-6=2,\quad 11-8=3$$

$$15-11=4,\quad 20-15=5$$

2. The shown differences are $2, 3, 4, 5$, so each gap grows by $1$.
3. The next gap is $5+1=6$.

:::try
Finish the last step: add the next gap to $20$.
:::answer
The answer is $26$. Add the gap of $6$: $20+6=26$.
:::

## Traps to Watch For

:::checklist
- Asked for a missing term: put the result of the move in the blank, not the step size by itself. {#wrong-step-size}
- Rapidly growing numbers: test ratios and pick the simplest rule that fits every shown term: $54\times3=162$, not $90$. {#add-last-gap-in-ratio}
- Growing gaps between terms: check each gap from the start, then use the next gap: $12+5=17$, not $16$. {#repeat-last-gap}
:::

---
_id: "lesson-arithmetic-number-sense-same-remainder-numbers"
title: "Same-Remainder Numbers"
summary: "Use the LCM to find numbers with a common remainder."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 4
partCount: 4
ordering: 14
keyPoints:
  - "Write same-remainder numbers using the LCM."
  - "Check the remainder and the stated size condition."
---
## Core Concept

### Same-Remainder Formula

A **remainder** is the amount left over after dividing into whole groups. When dividing by a positive integer, the remainder is at least $0$ and smaller than the divisor.

Suppose a number $N$ leaves the same remainder $r$ when divided by several divisors. If you take away that leftover $r$, the new number $N-r$ divides cleanly by every divisor. So $N-r$ must be a common multiple of all the divisors.

Let $L$ be the LCM of the divisors. For positive divisors and a valid remainder $r$, every number with that common remainder has the form:

$$N=Lk+r$$

Here, $k$ is an integer. Plug in $k=0, 1, 2, \dots$ to list all nonnegative answers. The dots mean the list continues forever.

Find every nonnegative number $N$ that leaves remainder $2$ when divided by $4$, $6$, and $9$.

1. Factor the divisors and find their LCM $L$:

$$4=2^2$$

$$6=2\times 3$$

$$9=3^2$$

$$L=2^2\times 3^2$$

$$L=4\times 9$$

$$L=36$$

2. Write the formula with $L=36$ and $r=2$:

$$N=36k+2$$

3. Plug in $k=0, 1, 2$ to see the first three numbers:

$$36(0)+2=2$$

$$36(1)+2=38$$

$$36(2)+2=74$$

Consecutive answers are $L=36$ apart.

<!-- ILLUSTRATION: A number line with three marks at 2, 38 and 74, spaced to scale. Two equal jumps, each labeled +36, lead from 2 to 38 and from 38 to 74. Under the marks are k = 0, k = 1 and k = 2. Above the line is the formula N = 36k + 2. -->

:::why
Why does $k=0$ give $N=2$? When you divide $2$ by $4$, $6$, or $9$, each divisor fits $0$ times with $2$ left over. That makes $r$ the smallest nonnegative answer, even when a question asks for a larger number.
:::

:::pair #subtract-remainder
Right: numbers leaving remainder $2$ when divided by $4$, $6$, and $9$ have the form $N=36k+2$
Wrong: numbers leaving remainder $2$ when divided by $4$, $6$, and $9$ have the form $N=36k-2$
Because $N-2$ is a multiple of $36$, you must add $2$ to $36k$, not subtract it. For $k=1$, $36-2=34$ leaves remainder $4$ when divided by $6$, not $2$.
:::

:::pair #product-instead-of-lcm
Right: for divisors $4$, $6$, and $9$, use their LCM ($36$) so $N=36k+2$
Wrong: multiply $4\times 6\times 9=216$ so $N=216k+2$
Multiplying the divisors skips valid numbers such as $38$ and $74$. Use the LCM to get the true spacing.
:::

:::check
What is the second-smallest nonnegative number that leaves remainder $4$ when divided by $6$, $8$, and $12$?
:::answer
The answer is $28$. The LCM of $6$, $8$, and $12$ is $24$, so $N=24k+4$. Then $k=0$ gives $4$ and $k=1$ gives $28$.
:::

### Checking the Size Condition

Adding the remainder to $L$ (which uses $k=1$) is not always the final answer. Test $k=0$, $k=1$, $k=2$, and so on against the size condition in the question.

- For $k=0$, $N=r$. If $r$ already meets the condition, $r$ is the smallest answer.
- If the question requires a number larger than $r$, move up to $k=1$ or higher until the condition holds.

Find the smallest number greater than $10$ that leaves remainder $2$ when divided by $4$ and $6$. Their LCM is $12$, so $N=12k+2$. Test $k=0$ and $k=1$:

$$12(0)+2=2\quad\text{(too small)}$$

$$12(1)+2=14\quad\text{(greater than }10\text{)}$$

The smallest answer greater than $10$ is $14$.

:::pair #forget-remainder
Right: when $L=120$ and remainder $r=3$, the smallest answer above $10$ is $120(1)+3=123$
Wrong: when $L=120$ and remainder $r=3$, the smallest answer above $10$ is $120$
Here $120$ divides evenly by $6$, $8$, and $10$ with remainder $0$. Add the remainder $3$ back to the LCM.
:::

## Examples

### #1: Same-Remainder Problem

What is the smallest integer greater than $10$ that leaves a remainder of $1$ when divided by $4$, $6$, and $10$?

**Solution:**

1. The remainder $1$ is smaller than every divisor. Taking away $1$ must leave a common multiple of $4$, $6$, and $10$. Factor each divisor.

$$4=2^2$$

$$6=2\times 3$$

$$10=2\times 5$$

2. Find the LCM using the largest prime powers.

$$L=2^2\times 3\times 5$$

$$L=4\times 3\times 5$$

$$L=60$$

3. Write the formula $N=Lk+r$ with $L=60$ and $r=1$.

$$N=60k+1$$

4. Test $k=0$: $60(0)+1=1$, which is not greater than $10$.

:::try
Finish the last step: use $k=1$ in $N=60k+1$ to find the smallest allowed number.
:::answer
The answer is $61$. Plug in $k=1$ to get $60(1)+1=61$, which is greater than $10$.
:::

## Traps to Watch For

:::checklist
- Writing the formula for same-remainder numbers: add the remainder to $Lk$, so $N=Lk+r$, not $Lk-r$. {#subtract-remainder}
- Finding the spacing $L$ between answers: use the LCM of the divisors, not their product. {#product-instead-of-lcm}
- Stopping at the LCM or at $k=0$: add the remainder back and check the stated limit, so $120(1)+3=123$. {#forget-remainder}
:::

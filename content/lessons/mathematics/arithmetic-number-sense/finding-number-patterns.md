---
_id: "lesson-arithmetic-number-sense-finding-number-patterns"
title: "Finding Number Patterns"
summary: "Check differences and alternating operations to find a pattern."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 1
partCount: 9
ordering: 28
keyPoints:
  - 'Check differences and alternating operations to find a pattern.'
---
## Core Concept

A **sequence** is an ordered list of numbers called **terms**. A **series** is a sum of terms from a sequence. The dots at the end of a list mean that it continues.

### Check Differences and Ratios First

Before picking any rule, look at how neighboring terms change from left to right.

1. Subtract each term from the term after it. If the difference stays the same, add that constant number each step.

$$4,7,10,13,\dots$$

$$7-4=3,\quad10-7=3,\quad13-10=3$$

2. Divide each term by the nonzero term before it. If the ratio stays the same, multiply by that constant number each step.

$$2,6,18,54,\dots$$

$$6\div2=3,\quad18\div6=3,\quad54\div18=3$$

3. If neither stays the same, check whether each term is the sum of the two before it, such as $1,1,2,3,5,\dots$, or whether odd and even positions follow separate rules (covered in the next part).

:::check
What number follows $5,9,13,17,\dots$?
:::answer
The answer is $21$. Each term goes up by $4$, so $17+4=21$.
:::

### Growing Differences

Sometimes the first differences are not constant, yet they change in a simple pattern of their own. Subtract the differences a second time, or check for familiar numbers like squares ($1,4,9,16,25,\dots$).

Try $6,11,19,30,44,\dots$. Find each jump between neighboring terms.

$$11-6=5$$

$$19-11=8$$

$$30-19=11$$

$$44-30=14$$

The differences are $5,8,11,14$. Each difference is $3$ more than the one before it ($8-5=3$, $11-8=3$, $14-11=3$). So the next difference is $14+3=17$.

$$44+17=61$$

:::pair #repeat-last-difference
Right: $44+17=61$
Wrong: $44+14=58$
The differences grow by $3$ each step, so you cannot reuse $14$. Add $3$ to $14$ first to get the next step, $17$.
:::

Other times the jumps are consecutive square numbers, as in $2,3,7,16,32,\dots$.

$$3-2=1=1^2,\quad7-3=4=2^2$$

$$16-7=9=3^2,\quad32-16=16=4^2$$

The next jump is $5^2=25$, giving $32+25=57$.

:::pair #wrong-square-step
Right: $32+25=57$
Wrong: $32+20=52$
Consecutive squares ($1,4,9,16,25$) do not grow by a fixed $4$. Use the next square, $5^2=25$, instead of adding $4$ to $16$.
:::

:::why
Why subtract the differences a second time? When a sequence speeds up at a steady pace, the first jumps change every step, and the second subtraction reveals the hidden constant step.
:::

:::check
What number follows $1,3,7,13,21,\dots$?
:::answer
The answer is $31$. The differences are $2,4,6,8$, each growing by $2$, so the next difference is $10$ and $21+10=31$.
:::

### Alternating Operations

A sequence can also switch back and forth between two operations, such as multiplying and subtracting. Test your rule on every shown step from start to finish.

Try $3,12,10,40,38,152,\dots$.

$$3\times4=12$$

$$12-2=10$$

$$10\times4=40$$

$$40-2=38$$

$$38\times4=152$$

The rule alternates between $\times4$ and $-2$. Since the last step multiplied by $4$, the next step subtracts $2$.

$$152-2=150$$

:::pair #repeat-same-operation
Right: $152-2=150$
Wrong: $152\times4=608$
The rule alternates between two operations. Multiplying by $4$ came last, so subtracting $2$ must come next.
:::

:::check
What number follows $5,15,11,33,29,87,\dots$?
:::answer
The answer is $83$. The pattern alternates $\times3$ and $-4$, so the next step is $87-4=83$.
:::

## Examples

### #1: Discovering a Number Pattern

What number most reasonably completes the sequence $2,5,10,17,26,\dots$?

**Solution:**

1. Find the differences between neighboring terms.

$$5-2=3,\quad10-5=5$$

$$17-10=7,\quad26-17=9$$

2. The differences are $3,5,7,9$. Each difference is $2$ more than the one before it, so the next difference is $9+2=11$.

3. Add $11$ to the last given term.

$$26+11=37$$

The next number is $37$.

**Check:** Each term is $1$ more than a square number: $1^2+1=2$, $2^2+1=5$, $3^2+1=10$, $4^2+1=17$, and $5^2+1=26$. The sixth term is $6^2+1=37$, which matches.

### #2: Alternating Operations

What number most reasonably completes the sequence $4,7,14,17,34,\dots$?

**Solution:**

1. Check the first two steps. Adding $3$ gives $4+3=7$, and multiplying by $2$ gives $7\times2=14$.

2. Test whether $\text{"}+3\text{, then }\times2\text{"}$ works on the rest of the list.

$$14+3=17$$

$$17\times2=34$$

3. Every shown step fits the alternating rule. Since the last step multiplied by $2$, the next step adds $3$.

:::try
Finish the last step: $34+3$.
:::answer
The answer is $37$. Adding $3$ to $34$ gives $37$.

**Check:** Read every step in order: $4+3=7$, $7\times2=14$, $14+3=17$, $17\times2=34$, and $34+3=37$. No step breaks the rule.
:::

## Traps to Watch For

:::checklist
- Growing differences between terms: add the rise to the last difference first, so $44+17=61$. {#repeat-last-difference}
- Differences that are consecutive squares: find the next square number, so $32+5^2=57$. {#wrong-square-step}
- Alternating operations: switch to the other operation on the next step, so $152-2=150$. {#repeat-same-operation}
:::

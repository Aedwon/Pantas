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

Before picking any rule, look at how neighboring terms change.

1. Subtract each term from the term after it. If the difference stays the same, add that constant number each step.

$$4,7,10,13,\dots$$

$$7-4=3$$

$$10-7=3$$

$$13-10=3$$

2. Divide each term by the nonzero term before it. If the ratio stays the same, multiply by that constant number each step. A $0$ must be followed by $0$; if a $0$ is followed by a nonzero term, the list is not geometric.

$$2,6,18,54,\dots$$

$$6\div2=3$$

$$18\div6=3$$

$$54\div18=3$$

3. If neither stays the same, check whether each term is the sum of the two before it, such as $1,1,2,3,5,\dots$, or whether odd and even positions follow separate rules (covered in the next part).

### Growing Differences

If the differences are not constant, subtract them a second time, or check for squares ($1,4,9,16,25,\dots$).

Find the next term of $6,11,19,30,44,\dots$. Subtract neighboring terms.

$$11-6=5$$

$$19-11=8$$

$$30-19=11$$

$$44-30=14$$

The differences are $5,8,11,14$. Subtract them a second time.

$$8-5=3$$

$$11-8=3$$

$$14-11=3$$

<!-- ILLUSTRATION: Five boxes in a row hold the terms 6, 11, 19, 30, 44. Arcs below the row show the jumps between neighboring terms: +5, +8, +11, +14. Below those, three smaller arcs show the second jumps between neighboring jumps: +3, +3, +3. Every jump is 3 more than the one before it, so the next jump is 14 + 3 = 17. -->

Each difference is $3$ more than the one before it, so the next difference is:

$$14+3=17$$

Add it to the last term:

$$44+17=61$$

:::pair #repeat-last-difference
Right: $44+17=61$
Wrong: $44+14=58$
The differences grow by $3$ each step, so you cannot reuse $14$. Add $3$ to $14$ first to get the next step, $17$.
:::

Other times the jumps are consecutive square numbers. Find the next term of $2,3,7,16,32,\dots$.

$$3-2=1$$

$$7-3=4$$

$$16-7=9$$

$$32-16=16$$

The jumps are $1,4,9,16$, which are $1^2,2^2,3^2,4^2$. The next jump is $5^2$.

$$5^2=25$$

$$32+25=57$$

:::pair #wrong-square-step
Right: $32+25=57$
Wrong: $32+20=52$
The wrong line treats $4$ as a fixed rise from one square to the next. The rises from $1$ to $4$ to $9$ are $3$ and $5$, so use the next square, $5^2=25$.
:::

:::why
Why subtract the differences a second time? When a sequence speeds up at a steady pace, the first jumps change every step, and the second subtraction reveals the hidden constant step.
:::

:::check
The differences between terms grow by the same amount each time. What is the sixth term of $3,7,13,21,\dots$?
:::answer
The answer is $43$. The differences are $4,6,8$, each growing by $2$. The next differences are $10$ and $12$, so the terms continue $21+10=31$ and $31+12=43$.
:::

### Alternating Operations

A sequence can also switch back and forth between two operations, such as multiplying and subtracting. Test your rule on every shown step from start to finish.

Find the next term of $3,12,10,40,38,152,\dots$.

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

## Examples

### #1: Discovering a Number Pattern

What number most reasonably completes the sequence $2,5,10,17,26,\dots$?

**Solution:**

1. Find the differences between neighboring terms.

$$5-2=3$$

$$10-5=5$$

$$17-10=7$$

$$26-17=9$$

2. The differences are $3,5,7,9$. Subtract them a second time.

$$5-3=2$$

$$7-5=2$$

$$9-7=2$$

3. Each difference is $2$ more than the one before it, so the next difference is $9+2$.

$$9+2=11$$

4. Add $11$ to the last given term.

$$26+11=37$$

The next number is $37$.

### #2: Alternating Operations

What number most reasonably completes the sequence $5,8,16,19,38,\dots$?

**Solution:**

1. Check the first two steps.

$$5+3=8$$

$$8\times2=16$$

2. Test whether the rule $+3$, then $\times2$ works on the rest of the list.

$$16+3=19$$

$$19\times2=38$$

3. Every shown step fits the alternating rule. The last step took $19$ to $38$.

:::try
Finish the last step: find the next term after $38$.
:::answer
The answer is $41$. The last step multiplied, so the next step adds $3$ to $38$.
:::

## Traps to Watch For

:::checklist
- Growing differences between terms: add the steady increase to the last difference first, so $44+17=61$. {#repeat-last-difference}
- Differences that are consecutive squares: find the next square number, so $32+5^2=57$. {#wrong-square-step}
- Alternating operations: switch to the other operation on the next step, so $152-2=150$. {#repeat-same-operation}
:::

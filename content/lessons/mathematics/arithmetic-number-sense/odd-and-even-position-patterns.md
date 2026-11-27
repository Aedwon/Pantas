---
_id: "lesson-arithmetic-number-sense-odd-and-even-position-patterns"
title: "Odd- and Even-Position Patterns"
summary: "Check separate patterns in odd and even positions."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 2
partCount: 9
ordering: 29
keyPoints:
  - 'Check separate patterns in odd and even positions.'
---
## Core Concept

### Splitting Odd and Even Positions

Some sequences weave two separate lists together. **Odd positions** are positions $1,3,5,7,\dots$, and **even positions** are positions $2,4,6,8,\dots$.

When one rule does not fit neighboring terms, read every other term to separate the two groups.

<!-- FIGURE WANTED: six term boxes for 4, 81, 8, 27, 16, 9 in a row; teal top arcs link the 1st, 3rd, and 5th terms (4, 8, 16) labeled "odd positions: x 2"; gray bottom arcs link the 2nd, 4th, and 6th terms (81, 27, 9) labeled "even positions: / 3" -->

Look at $4,81,8,27,16,9,\dots$ and find the next two terms in order.

1. Read the odd positions (first, third, fifth): $4,8,16$. Each term doubles.

$$4\times2=8$$

$$8\times2=16$$

2. Read the even positions (second, fourth, sixth): $81,27,9$. Each term divides by $3$.

$$81\div3=27$$

$$27\div3=9$$

3. The seventh position is odd, so continue the odd group first.

$$16\times2=32$$

4. The eighth position is even, so continue the even group second.

$$9\div3=3$$

The next two numbers are $32,3$.

:::pair #reverse-position-order
Right: $32,3$
Wrong: $3,32$
Position $7$ is odd and position $8$ is even. Write the odd-position answer first, then the even-position answer.
:::

:::why
Why can one sequence hold two unrelated rules? Every other position skips the terms between, so the odd group and the even group never touch each other.
:::

### Testing Every Step and Finding Missing Terms

A rule must fit every shown term in its group, not only the first two terms. When a blank sits in the middle of a sequence, count its position first. Then check both neighbors in that same group.

Find the missing term in $7,50,12,43,17,\square,22,29$.

1. Count positions from left to right. The blank is in position $6$, which is even.

2. Pull out the even-position terms: $50,43,\square,29$.

3. Find the step from the first two even-position terms.

$$43-50=-7$$

4. Subtract $7$ from $43$ to fill the blank.

$$43-7=36$$

5. Check the next step in the even group to make sure the rule holds through the end.

$$36-7=29$$

Since $29$ matches the eighth term, the missing term is $36$. Check every shown jump in the group, because two different rules can match the same first two numbers.

:::pair #mix-position-groups
Right: $\square=43-7=36$
Wrong: $\square=17+5=22$
Position $6$ is even, so it belongs with $50,43,29$, not with the odd-position rule $+5$.
:::

:::pair #copy-wrong-step
Right: $43-7=36$
Wrong: $43-5=38$
Subtracting $5$ borrows the size of the odd-position step ($+5$) and applies it to an even-position term. Compute the step inside the matching group.
:::

:::check
Find the missing term in $6,40,10,34,\square,28,18,22$.
:::answer
The answer is $14$. The blank is in position $5$, which is odd. The odd-position terms $6,10,\square,18$ go up by $4$, so $10+4=14$ and $14+4=18$.
:::

## Examples

### #1: Two Patterns in One List

What number most reasonably completes the sequence $2,20,5,18,8,16,\dots$?

**Solution:**

1. Neighboring terms do not have a constant difference or ratio. Check every other term starting at the first position: $2,5,8$.

$$5-2=3$$

$$8-5=3$$

2. Check the terms in the even positions: $20,18,16$.

$$18-20=-2$$

$$16-18=-2$$

3. The odd-position terms increase by $3$, and the even-position terms decrease by $2$. Count positions: six terms are shown, so the next term is in position $7$, which is odd.

:::try
Finish the last step: find the seventh term using the odd-position rule.
:::answer
The answer is $11$. The odd-position terms go up by $3$, so add $3$ to the fifth term: $8+3=11$.
:::

## Speed Tricks & Shortcuts

### Pattern Check

If a sequence is not arithmetic or geometric, check the differences between neighboring terms first. If those do not help, check whether each term is the sum of the two terms before it. Then check alternating operations and separate odd-position and even-position lists.

## Traps to Watch For

:::checklist
- Asked for two next numbers: put the odd-position term first, then the even-position term ($32,3$). {#reverse-position-order}
- Finding a missing term in a mixed list: count its position first and stay inside its own group ($43-7=36$). {#mix-position-groups}
- Calculating the step for an even or odd group: use terms from that same group only ($43-7=36$, never borrow the other group's step). {#copy-wrong-step}
:::

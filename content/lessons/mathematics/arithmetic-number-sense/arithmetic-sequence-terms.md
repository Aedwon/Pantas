---
_id: "lesson-arithmetic-number-sense-arithmetic-sequence-terms"
title: "Arithmetic Sequence Terms"
summary: "Find a term using the common difference."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 3
partCount: 9
ordering: 30
keyPoints:
  - 'Find a term using the common difference.'
  - 'Count terms using the first term, last term, and common difference.'
---
## Core Concept

### Common Difference and Finding Any Term

An **arithmetic sequence** has the same difference between neighboring terms. That constant jump is the **common difference** $d$. Subtract any term from the term right after it to find $d$.

We write $a_1$ for the first term and $a_n$ for the term in position $n$, counting from $1$. Look at $5,9,13,17,21,\dots$.

$$d=9-5=4$$

Check the next jump.

$$13-9=4$$

Each step adds $4$.

<!-- ILLUSTRATION: Five boxes in a row labeled a1 = 5, a2 = 9, a3 = 13, a4 = 17 and a5 = 21. A curved arc labeled +4 joins each box to the next, four arcs in all. A bracket under the row spans from the first box to the fifth and reads "4 steps (n - 1), not 5", showing that reaching position 5 takes 4 steps. -->

To reach the fifth term from $a_1=5$, you take $4$ steps of $+4$, not $5$ steps. In an arithmetic sequence, reaching position $n$ takes $n-1$ equal steps from $a_1$:

$$a_n=a_1+(n-1)d$$

Find the fifteenth term ($a_{15}$) of $5,9,13,17,\dots$ from $a_1$ and $d$.

1. Count the steps from $a_1$ to $a_{15}$.

$$n-1=15-1=14$$

2. Multiply the $14$ steps by $d=4$.

$$14\times4=56$$

3. Add that total change to $a_1=5$.

$$a_{15}=5+56=61$$

:::pair #off-by-one-steps
Right: $a_{15}=5+(15-1)(4)=5+56=61$
Wrong: $a_{15}=5+15(4)=65$
Multiplying by $15$ takes one step too many. The first term takes $0$ steps, so position $n$ needs $n-1$ steps.
:::

:::why
Why is the step count $n-1$ instead of $n$? You already stand on $a_1$ at the start, so reaching $a_2$ takes $1$ step, reaching $a_3$ takes $2$ steps, and reaching $a_n$ takes $n-1$ steps.
:::

### Working Backwards and Inserting Means

When you know two terms far apart, count the gaps between their positions to find $d$. Find $a_1$ from $a_3=11$ and $a_8=31$.

1. Subtract the positions to count the steps between them.

$$8-3=5$$

2. Subtract the two terms to find the total change.

$$31-11=20$$

3. Divide the change by the $5$ steps.

$$d=\dfrac{20}{5}=4$$

4. Step backward $3-1=2$ steps from $a_3=11$ to find $a_1$.

$$a_1=11-2(4)$$

$$a_1=3$$

:::pair #report-difference-not-term
Right: $d=4$, then $a_1=11-2(4)=3$
Wrong: $d=4$, so $a_1=4$
Finding $d=4$ is only the first step. Check whether the question asks for $d$ or for a term like $a_1$.
:::

The same gap count works when you insert **arithmetic means** between two numbers so all terms form one arithmetic sequence. Find $d$ when $3$ means go between $4$ and $28$. That makes $5$ terms in all, which gives $3+1=4$ equal gaps.

$$28-4=24$$

$$d=\dfrac{24}{4}=6$$

Adding $6$ each step gives $4,10,16,22,28$.

:::check
In an arithmetic sequence, $a_2=9$ and $a_6=25$. What is $a_{10}$?
:::answer
The answer is $41$. Positions $2$ to $6$ are $4$ steps, so $d=\dfrac{25-9}{4}=4$. Then $a_{10}=25+4(4)=41$.
:::

### Counting Terms in a Sequence

Let $n$ be the number of terms. When you know $a_1$, the last term $a_n$, and a nonzero common difference $d$, divide the total change by $d$ to count the gaps. Then add $1$ so the first term is counted too:

$$n=\dfrac{a_n-a_1}{d}+1$$

Use this only when $a_n$ belongs to the sequence. The result $n$ must be a positive whole number.

Count the terms in $18,24,30,\dots,246$.

1. Find $d$ from the first two terms.

$$d=24-18=6$$

2. Find the total change from $18$ to $246$.

$$246-18=228$$

3. Divide by $d=6$ to count the gaps.

$$\dfrac{228}{6}=38$$

4. Add $1$ to include the first term, $18$.

$$n=38+1=39$$

:::pair #forget-plus-one
Right: $\dfrac{246-18}{6}+1=38+1=39$
Wrong: $\dfrac{246-18}{6}=38$
Dividing $(246-18)\div6$ counts only the $38$ gaps between terms. Add $1$ so the first term is counted.
:::

## Examples

### #1: Finding a Far Term in an Arithmetic Sequence

Find the $25^{\text{th}}$ term of the arithmetic sequence $4,7,10,13,\dots$.

**Solution:**

1. Read $a_1=4$ and find $d$.

$$d=7-4=3$$

2. Count the steps from the first term to the $25^{\text{th}}$ term.

$$n-1=25-1=24$$

3. Multiply the steps by $d$.

$$24\times3=72$$

4. Add that change to $a_1$.

$$a_{25}=4+72=76$$

The $25^{\text{th}}$ term is $76$.

### #2: Counting Arithmetic Terms

Find how many terms are in the arithmetic sequence $7,11,15,\dots,83$.

**Solution:**

1. Read $a_1=7$ and $a_n=83$, then find $d$.

$$d=11-7=4$$

2. Subtract the first term from the last term to get the total increase.

$$83-7=76$$

3. Divide by $d=4$ to count the gaps between terms.

$$\dfrac{76}{4}=19$$

:::try
Finish the last step: add $1$ to count the first term and find $n$.
:::answer
The answer is $20$. Including the first term gives $n=19+1=20$.
:::

## Speed Tricks & Shortcuts

### Number of Terms in an Arithmetic Sequence

Subtract the first term from the last term, divide by the nonzero common difference, and add $1$ to include the first term. The answer must be a positive whole number.

## Traps to Watch For

:::checklist
- Finding the $n^{\text{th}}$ term: take $n-1$ steps from $a_1$, so $a_{15}=5+14(4)=61$. {#off-by-one-steps}
- Solving for an earlier term after finding $d$: finish the question instead of stopping at $d$, so $a_1=11-2(4)=3$. {#report-difference-not-term}
- Counting terms from first to last: add $1$ after dividing the range by $d$, so $38+1=39$. {#forget-plus-one}
:::

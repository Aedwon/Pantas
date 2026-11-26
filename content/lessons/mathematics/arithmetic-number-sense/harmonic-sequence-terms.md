---
_id: "lesson-arithmetic-number-sense-harmonic-sequence-terms"
title: "Harmonic Sequence Terms"
summary: "Find harmonic terms by taking reciprocals twice."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 8
partCount: 9
ordering: 35
keyPoints:
  - 'Find harmonic terms by taking reciprocals twice.'
---
## Core Concept

### What a Reciprocal and a Harmonic Sequence Are

The **reciprocal** of a nonzero number $x$ is $\dfrac{1}{x}$. To take the reciprocal of a fraction with nonzero numerator and denominator, swap the top and bottom numbers.

- The reciprocal of $\dfrac{2}{3}$ is $\dfrac{3}{2}$.
- The reciprocal of $\dfrac{1}{5}$ is $\dfrac{5}{1}$, which is $5$.
- The reciprocal of $4$ (or $\dfrac{4}{1}$) is $\dfrac{1}{4}$.

In a **harmonic sequence**, the reciprocals of the terms form an arithmetic sequence. All terms of a harmonic sequence must be nonzero so every term has a reciprocal.

Test the harmonic sequence $\dfrac{1}{3},\dfrac{1}{7},\dfrac{1}{11},\dots$.

1. Take the reciprocal of each term.

$$3,7,11,\dots$$

2. Subtract neighboring terms to check for a constant difference.

$$7-3=4,\quad11-7=4$$

The reciprocals form an arithmetic sequence with common difference $d=4$.

Not every harmonic sequence starts with $1$ in the numerator. Check $6,3,2,\dots$:

1. Take the reciprocal of each term.

$$\dfrac{1}{6},\dfrac{1}{3},\dfrac{1}{2},\dots$$

2. Rewrite with a common denominator of $6$ to compare the jumps.

$$\dfrac{1}{6},\dfrac{2}{6},\dfrac{3}{6},\dots$$

The reciprocals increase by $d=\dfrac{1}{6}$ each step, so $6,3,2,\dots$ is also harmonic. The fourth reciprocal is $\dfrac{4}{6}=\dfrac{2}{3}$, and flipping back gives $\dfrac{3}{2}$.

:::why
Why not subtract neighboring harmonic terms directly? In $\dfrac{1}{3},\dfrac{1}{7},\dfrac{1}{11}$, the differences keep changing because the steady $+4$ step lives in the flipped fractions, not in the original terms.
:::

:::check
Write the reciprocal arithmetic sequence for $\dfrac{1}{4},\dfrac{1}{9},\dfrac{1}{14},\dots$ and find its common difference.
:::answer
The arithmetic sequence is $4,9,14,\dots$ with common difference $5$. Flip each fraction and subtract: $9-4=5$.
:::

### Finding a Harmonic Term in Three Steps

Because the reciprocals form an arithmetic sequence, you can find any harmonic term in three steps:

1. Flip each given term to write the reciprocal arithmetic sequence.
2. Find the $n^{\text{th}}$ term of that arithmetic sequence using $a_n=a_1+(n-1)d$.
3. Flip that result back to return to the harmonic sequence.

Find the fourth term of $\dfrac{1}{3},\dfrac{1}{7},\dfrac{1}{11},\dots$.

1. Flip the terms to get $3,7,11,\dots$, so $a_1=3$ and $d=4$.

2. Use $n-1=4-1=3$ steps to find $a_4$ in the arithmetic sequence.

$$a_4=3+(4-1)(4)$$

$$a_4=3+12=15$$

3. Flip $15$ back to return to the harmonic sequence: $\dfrac{1}{15}$.

:::pair #forget-final-reciprocal
Right: $\dfrac{1}{15}$
Wrong: $15$
$15$ is the fourth term of the helper arithmetic sequence, not the harmonic sequence. Flip it back to $\dfrac{1}{15}$ at the end.
:::

:::pair #wrong-step-count-harmonic
Right: $a_4=3+(4-1)(4)=15$, so the term is $\dfrac{1}{15}$.
Wrong: $a_4=3+4(4)=19$, so the term is $\dfrac{1}{19}$.
From the first term to the fourth term is $4-1=3$ steps, not $4$ steps.
:::

:::pair #flip-difference-instead
Right: Find $a_4=15$ first, then flip to $\dfrac{1}{15}$.
Wrong: Flip $d=4$ to $\dfrac{1}{4}$.
The common difference $4$ only tells how much each denominator grows. Finish finding the full term before flipping.
:::

:::check
Find the fifth term of the harmonic sequence $\dfrac{1}{2},\dfrac{1}{6},\dfrac{1}{10},\dots$.
:::answer
The answer is $\dfrac{1}{18}$. The reciprocals $2,6,10,\dots$ have $d=4$, so $a_5=2+4(4)=18$, and flipping back gives $\dfrac{1}{18}$.
:::

## Examples

### #1: Finding a Term in a Harmonic Sequence

Find the $6^{\text{th}}$ term of the harmonic sequence $\dfrac{1}{2},\dfrac{1}{5},\dfrac{1}{8},\dots$.

**Solution:**

1. Flip each term to form the reciprocal arithmetic sequence: $2,5,8,\dots$.

2. Read $a_1=2$ and compute $d=5-2=3$.

3. Find the $6^{\text{th}}$ term of this arithmetic sequence using $n-1=6-1=5$ steps.

$$a_6=2+(6-1)(3)=2+15=17$$

:::try
Finish the last step: return from the arithmetic term $17$ to the $6^{\text{th}}$ harmonic term.
:::answer
The answer is $\dfrac{1}{17}$. Taking the reciprocal of $17$ returns to the harmonic sequence.

**Check:** List the first six arithmetic reciprocals one by one, adding $3$ each time: $2,5,8,11,14,17$. The sixth reciprocal is $17$, so the sixth harmonic term is $\dfrac{1}{17}$.
:::

## Traps to Watch For

:::checklist
- Finishing the arithmetic step: take the reciprocal one last time to return to the harmonic term ($\dfrac{1}{15}$, not $15$). {#forget-final-reciprocal}
- Counting steps to position $n$ in the reciprocal sequence: use $n-1$ steps from $a_1$ ($a_4=3+3(4)=15$). {#wrong-step-count-harmonic}
- Knowing the common difference $d$: finish computing $a_n$ before taking the reciprocal, never flip $d$ itself. {#flip-difference-instead}
:::

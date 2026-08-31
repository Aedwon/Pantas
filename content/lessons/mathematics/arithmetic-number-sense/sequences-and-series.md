---
_id: "lesson-arithmetic-number-sense-sequences-and-series"
title: "Sequences and Series (Arithmetic, Geometric, Fibonacci, Harmonic)"
summary: "Find patterns, terms, and sums in common types of number sequences."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
estimatedMinutes: 12
isActive: true
---
## Core Concept

A **sequence** is an ordered list of terms. A **series** is a sum of terms from a sequence.

1. **Arithmetic sequence.** The difference between consecutive terms is constant. This value is the **common difference** $d$.

2. **Geometric sequence.** The ratio between consecutive nonzero terms is constant. This value is the **common ratio** $r$.

3. **Fibonacci-type sequence.** Each term after the first two is the sum of the two preceding terms. A common Fibonacci sequence begins $1,1,2,3,5,8,\dots$; another standard convention begins $0,1,1,2,3,5,\dots$.

4. **Harmonic sequence.** The reciprocals of its nonzero terms form an arithmetic sequence.

### The Formulas You Need

Here $a_1$ is the first term, $n$ is the number of terms, $d$ is the common difference, and $r$ is the common ratio.

Arithmetic term:

$$a_n=a_1+(n-1)d$$

Arithmetic series:

$$S_n=\dfrac{n}{2}(a_1+a_n)$$

Since $a_n=a_1+(n-1)d$, the same sum can also be written as:

$$S_n=\dfrac{n}{2}\left[2a_1+(n-1)d\right]$$

Geometric term:

$$a_n=a_1r^{n-1}$$

Finite geometric series for $r\ne1$:

$$S_n=\dfrac{a_1(1-r^n)}{1-r}$$

If $r=1$, all $n$ terms equal $a_1$, so $S_n=na_1$.

Infinite geometric series converges only when $|r|<1$:

$$S_\infty=\dfrac{a_1}{1-r}$$

If $|r|\ge1$, the infinite geometric series diverges and has no finite sum.

## Examples

### #1: Finding a Far Term in an Arithmetic Sequence

What is the $25^{\text{th}}$ term of $4,7,10,13,\dots$?

**Solution:**

1. $a_1=4$ and $d=3$.
2. Use the arithmetic-term formula.

$$a_{25}=4+(25-1)(3)=4+72=76$$

### #2: Arithmetic Series in a Word Problem

A theater has $20$ seats in the first row, $24$ in the second, and $28$ in the third. If there are $15$ rows and the pattern continues, what is the total number of seats?

**Solution:**

1. $a_1=20$, $d=4$, and $n=15$.
2. Use the arithmetic-series formula that contains $d$.

$$S_{15}=\dfrac{15}{2}\left[2(20)+(15-1)(4)\right]$$

$$S_{15}=\dfrac{15}{2}(40+56)=\dfrac{15}{2}(96)=720$$

The theater has $720$ seats.

### #3: Geometric Sequence with Alternating Signs

Find the $8^{\text{th}}$ term of $3,-6,12,-24,\dots$.

**Solution:**

1. The common ratio is $r=-2$ and $a_1=3$.
2. Use the geometric-term formula.

$$a_8=3(-2)^{7}=3(-128)=-384$$

### #4: Evaluating an Infinite Geometric Series

Evaluate $18+6+2+\dfrac{2}{3}+\dots$.

**Solution:**

1. The common ratio is $r=\dfrac{1}{3}$, so $|r|<1$ and the series converges.
2. Use the infinite-geometric-series formula.

$$S=\dfrac{18}{1-\dfrac{1}{3}}=18\times\dfrac{3}{2}=27$$

### #5: Finding a Term in a Harmonic Sequence

Find the $6^{\text{th}}$ term of the harmonic sequence $\dfrac{1}{2},\dfrac{1}{5},\dfrac{1}{8},\dots$.

**Solution:**

1. Take reciprocals. They form the arithmetic sequence $2,5,8,\dots$ with $d=3$.
2. Find its sixth term.

$$a_6=2+(6-1)(3)=17$$

3. Take the reciprocal to return to the harmonic sequence.

$$\dfrac{1}{17}$$

### #6: Fibonacci-Type Sequence with Variables

If $x,y,z$ are three consecutive terms of a Fibonacci-type sequence and $x=2a+1$ and $y=3a-2$, what is $z$ in terms of $a$?

**Solution:**

1. Consecutive terms satisfy $x+y=z$.
2. Substitute.

$$z=(2a+1)+(3a-2)=5a-1$$

## Speed Tricks & Shortcuts

**Number of Terms in an Arithmetic Sequence.**
If the first term, last term, and nonzero common difference are known and the last term belongs to the sequence:

$$n=\dfrac{\text{Last}-\text{First}}{d}+1$$

**Middle-Term Average.**
For a finite arithmetic sequence with an odd number of terms, the middle term equals the average of all the terms. Therefore, the sum equals the middle term times the number of terms.

For $5,10,15,20,25$, the middle term is $15$ and there are $5$ terms, so the sum is $75$.

## Traps to Watch For

### #1: Term vs. Sum Confusion

Use $a_n$ for a term and $S_n$ for a sum of terms.

### #2: Forgetting the Reciprocal in a Harmonic Sequence

After solving in the reciprocal arithmetic sequence, take the reciprocal again to return to the harmonic sequence.

### #3: Applying the Infinite Geometric Formula When the Series Diverges

> The finite sum formula and the infinite sum formula have different conditions.

An infinite geometric series has a finite sum only when $|r|<1$. If $|r|\ge1$, it diverges; do not describe the result as a finite "infinite sum."

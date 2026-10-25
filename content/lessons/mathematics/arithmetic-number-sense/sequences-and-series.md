---
_id: "lesson-arithmetic-number-sense-sequences-and-series"
title: "Sequences and Series (Arithmetic, Geometric, Fibonacci, Harmonic)"
summary: "Find patterns, terms, and sums in common types of number sequences."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
estimatedMinutes: 15
isActive: true
---
## Core Concept

A **sequence** is an ordered list of terms. A **series** is a sum of terms from a sequence.

### Common Sequence Types

An **arithmetic sequence** has the same difference between consecutive terms. This value is the **common difference** $d$.

A **geometric sequence** has the same ratio between consecutive nonzero terms. This value is the **common ratio** $r$.

In a **Fibonacci-type sequence**, each term after the first two is the sum of the two terms before it. For three consecutive terms $x,y,z$:

$$z=x+y$$

A common Fibonacci sequence begins $1,1,2,3,5,8,\dots$. Another standard convention begins $0,1,1,2,3,5,\dots$.

The **reciprocal** of a nonzero number $x$ is $\dfrac{1}{x}$. In a **harmonic sequence**, the reciprocals of the nonzero terms form an arithmetic sequence.

### Finding a Number Pattern

Not every number pattern is arithmetic, geometric, Fibonacci-type, or harmonic. Before choosing a formula, look at how each term changes.

Try these checks:

- Subtract neighboring terms. A constant difference means the pattern is arithmetic.
- Divide neighboring nonzero terms. A constant ratio means the pattern is geometric.
- If neither works, check whether the operations alternate.
- Check whether the differences form their own simple pattern.
- Check whether terms repeat in pairs or groups.

A pattern rule should fit every shown step. If it works for only part of the list, keep looking.

### The Formulas You Need

Here $a_1$ is the first term, $n$ is the number of terms, $d$ is the common difference, and $r$ is the common ratio.

For an arithmetic sequence:

$$a_n=a_1+(n-1)d$$

For an arithmetic series:

$$S_n=\dfrac{n}{2}(a_1+a_n)$$

Since $a_n=a_1+(n-1)d$, the same sum can also be written as:

$$S_n=\dfrac{n}{2}\left[2a_1+(n-1)d\right]$$

For a geometric sequence:

$$a_n=a_1r^{n-1}$$

For a finite geometric series with $r\ne1$:

$$S_n=\dfrac{a_1(1-r^n)}{1-r}$$

If $r=1$, every term equals $a_1$. Then:

$$S_n=na_1$$

An infinite geometric series **converges** when its sum gets closer and closer to one finite number as more terms are added. The symbol $|r|$ means the absolute value of $r$, which is its distance from $0$.

An infinite geometric series converges only when $|r|<1$. Then:

$$S_\infty=\dfrac{a_1}{1-r}$$

If $|r|\ge1$, the series **diverges**. This means it does not settle to a finite sum.

## Examples

### #1: Discovering a Number Pattern

What number comes next in $2,5,10,17,26,\dots$?

**Solution:**

1. Find the differences between neighboring terms.

$$5-2=3,\quad10-5=5,\quad17-10=7$$

$$26-17=9$$

2. The differences are $3,5,7,9$, which increase by $2$. The next difference is $11$.

$$26+11=37$$

The next number is $37$.

### #2: Finding a Far Term in an Arithmetic Sequence

What is the $25^{\text{th}}$ term of $4,7,10,13,\dots$?

**Solution:**

1. The first term is $a_1=4$, and the common difference is $d=3$.
2. Use the arithmetic-term formula.

$$a_{25}=4+(25-1)(3)=76$$

### #3: Arithmetic Series in a Word Problem

A theater has $20$ seats in the first row, $24$ in the second, and $28$ in the third. If there are $15$ rows and the pattern continues, what is the total number of seats?

**Solution:**

1. Here $a_1=20$, $d=4$, and $n=15$.
2. Use the arithmetic-series formula that contains $d$.

$$S_{15}=\dfrac{15}{2}\left[2(20)+(15-1)(4)\right]$$

3. Simplify.

$$S_{15}=\dfrac{15}{2}(96)=720$$

The theater has $720$ seats.

### #4: Geometric Sequence with Alternating Signs

Find the $8^{\text{th}}$ term of $3,-6,12,-24,\dots$.

**Solution:**

1. The common ratio is $r=-2$, and $a_1=3$.
2. Use the geometric-term formula.

$$a_8=3(-2)^7=-384$$

### #5: Finite Geometric Series

Find the sum of the first $6$ terms of the geometric sequence $3,6,12,24,\dots$.

**Solution:**

1. Here $a_1=3$, $r=2$, and $n=6$.
2. Use the finite geometric-series formula.

$$S_6=\dfrac{3(1-2^6)}{1-2}$$

3. Simplify.

$$S_6=3(63)=189$$

The sum is $189$.

### #6: Evaluating an Infinite Geometric Series

"Evaluate" means find the final number answer.

Evaluate $18+6+2+\dfrac{2}{3}+\dots$.

**Solution:**

1. The common ratio is $r=\dfrac{1}{3}$. Since $|r|<1$, the series converges.
2. Use the infinite geometric-series formula.

$$S=\dfrac{18}{1-\dfrac{1}{3}}$$

3. Simplify.

$$S=18\times\dfrac{3}{2}=27$$

### #7: Finding a Term in a Harmonic Sequence

Find the $6^{\text{th}}$ term of the harmonic sequence $\dfrac{1}{2},\dfrac{1}{5},\dfrac{1}{8},\dots$.

**Solution:**

1. Take the reciprocals. They form the arithmetic sequence $2,5,8,\dots$ with $d=3$.
2. Find the $6^{\text{th}}$ term of that arithmetic sequence.

$$a_6=2+(6-1)(3)=17$$

3. Take the reciprocal to return to the harmonic sequence.

$$\dfrac{1}{17}$$

### #8: Fibonacci-Type Sequence with Variables

If $x,y,z$ are three consecutive terms of a Fibonacci-type sequence, $x=2a+1$, and $y=3a-2$, what is $z$ in terms of $a$?

**Solution:**

1. For three consecutive terms, $z=x+y$.
2. Substitute the given expressions.

$$z=(2a+1)+(3a-2)=5a-1$$

### #9: Finite Geometric Series with $r=1$

A geometric series has $8$ terms, and every term is $5$. What is the sum?

**Solution:**

1. Since every term is the same, $r=1$. Use $S_n=na_1$.

$$S_8=8(5)=40$$

2. The sum is $40$.

### #10: An Infinite Geometric Series That Diverges

Does the infinite geometric series $3+6+12+24+\dots$ have a finite sum?

**Solution:**

1. The common ratio is $r=2$.
2. Since $|r|\ge1$, the series diverges.

It does not have a finite sum.

## Speed Tricks & Shortcuts

**Number of Terms in an Arithmetic Sequence.** If the first term, last term, and nonzero common difference are known, and the last term belongs to the sequence:

$$n=\dfrac{\text{Last}-\text{First}}{d}+1$$

**Middle-Term Average.** For a finite arithmetic sequence with an odd number of terms, the middle term equals the average of all the terms. The sum is the middle term times the number of terms.

For $5,10,15,20,25$, the middle term is $15$ and there are $5$ terms, so the sum is $75$.

**Pattern Check.** If a sequence is not arithmetic or geometric, write the differences between terms first. A simple pattern in those differences can reveal the next term quickly.

## Traps to Watch For

### #1: Term vs. Sum Confusion

> A term and a sum are different quantities.

Use $a_n$ for one term. Use $S_n$ for the sum of terms.

### #2: Forgetting the Reciprocal in a Harmonic Sequence

> A harmonic sequence becomes arithmetic only after you take reciprocals.

Solve the arithmetic pattern using the reciprocals. Then take the reciprocal again to return to the harmonic sequence.

### #3: Using the Infinite Sum Formula When the Series Diverges

> The infinite geometric-series formula works only when $|r|<1$.

If $|r|\ge1$, the series diverges and has no finite sum. Do not use $S_\infty=\dfrac{a_1}{1-r}$ in that case.

### #4: Forcing the Wrong Pattern

> A rule must fit every shown step in the sequence.

A rule that matches only the first few terms is not enough. Check the whole given pattern before choosing the next term.
